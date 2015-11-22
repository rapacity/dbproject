#include "share/atspre_staload.hats"
#include "share/atspre_define.hats"
#define ATS_DYNLOADFLAG 0
#include "share/HATS/atspre_staload_libats_ML.hats"
staload "libc/SATS/stdlib.sats"
#include "dict.dats"
#include "postgresql.dats"
#include "jinj.dats"
#include "group.dats"
#include "jinj_group.dats"
#include "sqljson.dats"
#include "monad.dats"
#include "pcre.dats"
#include "database.dats"
#include "validation.dats"
#include "httpd.dats"
#include "shell-magick.dats"

dataviewtype Failure =
  | UserNotFound
  | AlbumNotFound
  | PhotoNotFound
  | InvalidEmailAddress
  | RegistrationFailure
  // Field validation
  | InvalidFieldType
  | InvalidDateField
  | InvalidEmailField
  | InvalidGenderField
  | FieldMustNotBeBlank
  | InvalidFieldRange
  // Dispatch error
  | MethodNotFound
  // Authentication error
  | AlreadyLoggedIn
  | LoginFailed
  | FieldValidationFailure of (string)
  | AuthenticationFailure
  | Failure
  | ControllerFailure

fun failure_free(f: Failure): void =
  case+ f of
  | ~UserNotFound() => ()
  | ~AlbumNotFound() => ()
  | ~PhotoNotFound() => ()
  | ~InvalidEmailAddress() => ()
  | ~RegistrationFailure() => ()
  | ~InvalidFieldType() => ()
  | ~InvalidDateField() => ()
  | ~InvalidEmailField() => ()
  | ~InvalidGenderField() => ()
  | ~FieldMustNotBeBlank() => ()
  | ~InvalidFieldRange() => ()
  | ~MethodNotFound() => ()
  | ~AlreadyLoggedIn() => ()
  | ~LoginFailed() => ()
  | ~FieldValidationFailure(_) => ()
  | ~AuthenticationFailure() => ()
  | ~Failure() => ()
  | ~ControllerFailure() => ()


dataviewtype KRM =
  | KRM of (string, dbresult, jgfn0)
  | KV of (string, string)

dataviewtype Success =
  | Success
  | Direct of (List0_vt(KRM))

dataviewtype Request = REQUEST of @{
  db=dbconn,
  post=dict,
  get=dict,
  cookies=dict,
  files=dict,
  session=dict
}

dataviewtype BadRequest = BadRequest of (Request, Failure)
dataviewtype GoodRequest = GoodRequest of (Request, Success)

val kleisi_Req_Req_BadReq = kleisi<Request,Request,BadRequest>
val kleisi_Req_GoodReq_BadReq = kleisi<Request,GoodRequest,BadRequest>

overload >=> with kleisi_Req_Req_BadReq
overload >=> with kleisi_Req_GoodReq_BadReq

typedef Controller = Switch3(Request, GoodRequest, BadRequest)


fun MakeGoodRequest2(req: Request, succ: Success) : Either_vt(GoodRequest, BadRequest) =
  Left(GoodRequest(req, succ))

overload MakeGoodRequest with MakeGoodRequest2

fun MakeGoodRequest1(req: Request) : Either_vt(GoodRequest, BadRequest) =
  Left(GoodRequest(req, Success))

overload MakeGoodRequest with MakeGoodRequest1

fun MakeBadRequest2(req: Request, fail: Failure) : Either_vt(GoodRequest, BadRequest) =
  Right(BadRequest(req, fail))

overload MakeBadRequest with MakeBadRequest2

fun MakeBadRequest1(req: Request) : Either_vt(GoodRequest, BadRequest) =
  Right(BadRequest(req, ControllerFailure))

overload MakeBadRequest with MakeBadRequest1


// Validation 
// ----------------------------------------------------------------------------
fun checkp(field: string, pred: Pred(string)): Switch(Request, BadRequest) =
  lam request => let
    val+@REQUEST(r) = request
    val mstr = dict_get_opt(r.post, field)
    val is_valid =
      case+ mstr of
      | ~Some_vt(str) => pred(str)
      | ~None_vt() => false
    prval () = fold@(request)
  in
    if is_valid then
      Left(request)
    else
      Right(BadRequest(request, FieldValidationFailure(field)))
  end

fun checkf(field: string, pred: Pred(string)): Switch(Request, BadRequest) =
  lam request => let
    val+@REQUEST(r) = request
    val mstr = dict_get_opt(r.files, field)
    val is_valid =
      case+ mstr of
      | ~Some_vt(str) => pred(str)
      | ~None_vt() => false
    prval () = fold@(request)
  in
    if is_valid then
      Left(request)
    else
      Right(BadRequest(request, FieldValidationFailure(field)))
  end

val ensure_loggedin = 
 (lam request => let
    val+@REQUEST(r) = request
    val check = atoi(dict_get(r.session, "user_id"))
    prval () = fold@(request)
  in
    if check > 0 then Left(request)
    else Right(BadRequest(request, AuthenticationFailure()))
  end) : Switch(Request, BadRequest)
    
val ensure_not_loggedin = 
 (lam request => let
    val+@REQUEST(r) = request
    val check = atoi(dict_get(r.session, "user_id"))
    prval () = fold@(request)
  in
    if check = 0 then Left(request)
    else Right(BadRequest(request, AlreadyLoggedIn()))
  end) : Switch(Request, BadRequest)


// ----------------------------------------------------------------------------
 

// We give anonymous users an id of 0
val authenticate =
  (lam request => let
    val+@REQUEST(r) = request
    val result = get_session_user(r.db, dict_get(r.post, "session"))
    val user_id = if result.count() = 1 then atoi(result.get(0, 0)) else 0
    val () = free(result)
    val () = dict_set(r.session, "user_id", itoa(user_id)) 
    prval () = fold@(request)
  in
    Left(request)
  end) : Switch(Request, BadRequest)


// ----------------------------------------------------------------------------

fun failure_tostring(err: !Failure): string =
  case+ err of
  | UserNotFound()            => "UserNotFound"
  | AlbumNotFound()           => "AlbumNotFound"
  | PhotoNotFound()           => "PhotoNotFound"
  | InvalidDateField()        => "InvalidDateField"
  | InvalidEmailField()       => "InvalidEmailField"
  | InvalidGenderField()      => "InvalidGenderField"
  | FieldMustNotBeBlank()     => "FieldMustNotBeBlank"
  | InvalidFieldRange()       => "InvalidFieldRange"
  | MethodNotFound()          => "MethodNotFound"
  | RegistrationFailure()     => "RegistrationFailure"
  | AlreadyLoggedIn()         => "AlreadyLoggedIn"
  | LoginFailed()             => "LoginFailed"
  | Failure()                 => "failure"
  | ControllerFailure()       => "ControllerFailure"
  | AuthenticationFailure()   => "AuthenticationFailure"
  | InvalidEmailAddress()     => "InvalidEmailAddress"
  | InvalidFieldType()        => "InvalidFieldType"
  | FieldValidationFailure(str) => "FieldValidationFailure: " + str



fun report_failure(f: Failure, out: !jinj): void = {
  val _ = put_kv(out, "status", "failure")
  val _ = put_kv(out, "method", failure_tostring(f))
  val () = failure_free(f)
}

// ----------------------------------------------------------------------------
// Beginning of client-interaction methods. 
// ----------------------------------------------------------------------------

#include "application.dats"

fun report_generic_success(out: !jinj): void = {
  val _ = put_kv(out, "status", "success")
}

fun report_direct(out: !jinj, result: List0_vt(KRM)): void = {
  val _ = put_kv(out, "status", "success")
  fun loop(out: !jinj, lst: List0_vt(KRM)): void =
    case+ lst of
    | ~list_vt_nil() => ()
    | ~list_vt_cons(~KV(key, value),t) => let
      val n = put_kv(out, key, value)
    in 
      loop(out, t)
    end
    | ~list_vt_cons(~KRM(key, result, model),t) => let
      val n = put_jkey(out, key)
      val n = start_jvalue(out)
      val n = result.tojson(out, model)
      val () = free(result)
    in
      loop(out, t)
    end
  val () = loop(out, result)
  val _ = start_jvalue(out)
}


// ----------------------------------------------------------------------------

fun report_success(s: Success, out: !jinj): void = {
  val _ = case+ s of
  | ~Success() => report_generic_success(out)
  | ~Direct(result) => report_direct(out, result)
}

typedef request_method = Switch3(Request, GoodRequest, BadRequest)

val method_not_found =
  (lam request => Right(BadRequest(request, MethodNotFound)))
    : request_method

fun lookup_method(req: !Request): request_method = let
    val+@REQUEST(r) = req
    val method_name = dict_get(r.post, "method")
    #include "router.dats"
    prval () = fold@(req)
in 
  method
end



fun extract_db(req: Request): dbconn = db where {
  val ~REQUEST(@{ db=db, post=post, get=get, cookies=cookies,
    files=files, session=session }) = req
}

fun finish(result: Either_vt(GoodRequest,BadRequest), out: !jinj): Request =
  case+ result of
  | ~Left(~GoodRequest(req, s)) => req where { val () = report_success(s, out) }
  | ~Right(~BadRequest(req, f)) => req where { val () = report_failure(f, out) }


fun create_request(db: dbconn, m: mhdrequest_t): Request =
  REQUEST(@{db=db, post=m.postdata, get=m.getdata, cookies=m.cookies,
    files=m.files, session=make_empty_dict()})

fun process_mhdrequest(dbconfig: string, mhdreq: mhdrequest_t): strptr = let
  val db = connectdb(dbconfig)
  val () = assertloc(db.connection_ok())
  val buf = stringbuf_make_nil(i2sz(1024))
  val j   = start_jinj(buf)
  val _   = start_jobject(j)
  val req = create_request(db, mhdreq)
  val method = authenticate >=> lookup_method(req)
  val result = method(req)
  val req = finish(result, j)
  val db  = extract_db(req)
  val ()  = free(db)
  val _   = end_jobject(j)
  val buf = finish_jinj(j)
  val strptr = stringbuf_takeout_all(buf)
  val () = free(buf)
  val () = assertloc(ptrcast(strptr) > 0)
  val () = println!(strptr)
in
  strptr
end

// hack around ATSERRORnotenvless
val dbconfig = ref<string>("")

fun start_webserver(config: string, port: int) = {
  val () = !dbconfig := config
  implement answer_callback$ready<>(req) = process_mhdrequest(!dbconfig, req)
  val daemon = MHD_start_daemon4(MHD_USE_THREAD_PER_CONNECTION, port, nullp,
    nullp, answer_callback, nullp, MHD_OPTION_NOTIFY_COMPLETED, request_completed,
    nullp, MHD_OPTION_END)
  val dptr = MHD_Daemon_ptr2ptr(daemon)
  val () = assertloc(dptr > nullp)
  val c = getchar0() 
  val () = MHD_stop_daemon(daemon)
}


implement main0(argc, argv) =
  if argc < 3 then
    println!("./main.out <dbconfig> <portno>")
  else 
    start_webserver(argv[1], atoi(argv[2]))
  
