
#include "share/atspre_staload.hats"
#include "share/atspre_define.hats"
#include "share/HATS/atspre_staload_libats_ML.hats"

staload UN = "prelude/SATS/unsafe.sats"
staload "libc/SATS/unistd.sats"
staload "libc/sys/SATS/stat.sats"
staload "libc/SATS/stdio.sats"
staload "libats/SATS/stringbuf.sats"
staload _ = "libats/DATS/stringbuf.dats"

%{
#include <microhttpd.h>
%}


#define nullp the_null_ptr


viewtypedef mhdrequest_t = @{
  cookies=dict,
  postdata=dict,
  getdata=dict,
  files=dict,
  pp=ptr
}


dataviewtype mhdrequest_vt = MHDREQUEST of mhdrequest_t


absvtype mhdrequest = ptr
assume mhdrequest = mhdrequest_vt


fun create_mhdrequest(): mhdrequest =
  (MHDREQUEST
      @{cookies=make_empty_dict(),
        postdata=make_empty_dict(), 
        getdata=make_empty_dict(),
        files=make_empty_dict(),
        pp=nullp})


macdef MHD_NO = $extval(int, "MHD_NO")
macdef MHD_YES = $extval(int, "MHD_YES")
macdef MHD_HTTP_METHOD_POST = $extval(string, "MHD_HTTP_METHOD_POST")


typedef MHD_ResponseMemoryMode = int // $extype"MHD_ResponseMemoryMode"
macdef MHD_RESPMEM_PERSISTENT = $extval(MHD_ResponseMemoryMode, "MHD_RESPMEM_PERSISTENT")
macdef MHD_RESPMEM_MUST_COPY = $extval(MHD_ResponseMemoryMode, "MHD_RESPMEM_MUST_COPY")
macdef MHD_RESPMEM_MUST_FREE = $extval(MHD_ResponseMemoryMode, "MHD_RESPMEM_MUST_FREE")


typedef httpcode = int
macdef MHD_HTTP_OK = $extval(httpcode, "MHD_HTTP_OK")


typedef MHD_FLAG = int
macdef MHD_USE_SELECT_INTERNALLY = $extval(MHD_FLAG, "MHD_USE_SELECT_INTERNALLY")
macdef MHD_USE_THREAD_PER_CONNECTION = $extval(MHD_FLAG, "MHD_USE_THREAD_PER_CONNECTION")


typedef MHD_OPTION = int
macdef MHD_OPTION_END = $extval(MHD_OPTION, "MHD_OPTION_END")
macdef MHD_OPTION_CONNECTION_MEMORY_LIMIT = $extval(MHD_OPTION, "MHD_OPTION_CONNECTION_MEMORY_LIMIT")
macdef MHD_OPTION_NOTIFY_COMPLETED = $extval(MHD_OPTION, "MHD_OPTION_NOTIFY_COMPLETED")

typedef MHD_ValueKind = int
macdef MHD_COOKIE_KIND = $extval(MHD_OPTION, "MHD_COOKIE_KIND")
macdef MHD_GET_ARGUMENT_KIND = $extval(MHD_OPTION, "MHD_GET_ARGUMENT_INFO")
macdef MHD_POSTDATA_KIND = $extval(MHD_OPTION, "MHD_POSTDATA_KIND")

typedef MHD_RequestTerminationCode = int

absvtype MHD_Daemon_ptr (l:addr) = ptr
vtypedef MHD_Daemon_ptr0 = [l:addr] MHD_Daemon_ptr (l)
vtypedef MHD_Daemon_ptr1 = [l:addr | l > null] MHD_Daemon_ptr (l)

absvtype MHD_Response_ptr (l:addr) = ptr
vtypedef MHD_Response_ptr0 = [l:addr] MHD_Response_ptr (l)
vtypedef MHD_Response_ptr1 = [l:addr | l > null] MHD_Response_ptr (l)

//struct MHD_Connection *connection
absvtype MHD_Connection_ptr (l:addr) = ptr
vtypedef MHD_Connection_ptr0 = [l:addr] MHD_Connection_ptr (l)
vtypedef MHD_Connection_ptr1 = [l:addr | l > null] MHD_Connection_ptr (l)

absvtype MHD_PostProcessor_ptr (l:addr) = ptr
vtypedef MHD_PostProcessor_ptr0 = [l:addr] MHD_PostProcessor_ptr (l)
vtypedef MHD_PostProcessor_ptr1 = [l:addr | l > null] MHD_PostProcessor_ptr (l)


typedef MHD_AccessHandlerCallback =  (ptr, !MHD_Connection_ptr1, string, string, string, string, ref(size_t), ref(ptr)) -> int
typedef MHD_RequestCompletedCallback = (ptr, !MHD_Connection_ptr1, ref(ptr), MHD_RequestTerminationCode) -> void

extern fun MHD_create_response_from_buffer(size_t, string, MHD_ResponseMemoryMode): MHD_Response_ptr1
  = "mac#MHD_create_response_from_buffer"


extern fun MHD_create_response_from_buffer_strptr(size_t, strptr, MHD_ResponseMemoryMode): MHD_Response_ptr1
  = "mac#MHD_create_response_from_buffer"


extern fun MHD_queue_response(!MHD_Connection_ptr1, httpcode, !MHD_Response_ptr1): int
  = "mac#MHD_queue_response" 

extern fun MHD_destroy_response(MHD_Response_ptr1): void
  = "mac#MHD_destroy_response"


// MHD_AcceptPolicyCallback 3rd arg
extern fun MHD_start_daemon4
  (MHD_FLAG, int, ptr, ptr, MHD_AccessHandlerCallback, ptr, int, MHD_RequestCompletedCallback, ptr, int) 
    : MHD_Daemon_ptr0
      = "mac#MHD_start_daemon"

extern fun MHD_start_daemon3
  (MHD_FLAG, int, ptr, ptr, MHD_AccessHandlerCallback, ptr, int, ptr, int)
    : MHD_Daemon_ptr0
      = "mac#MHD_start_daemon"


extern fun MHD_start_daemon2
  (MHD_FLAG, int, ptr, ptr, MHD_AccessHandlerCallback, ptr, int, int)
    : MHD_Daemon_ptr0
      = "mac#MHD_start_daemon"


extern fun MHD_start_daemon1
  (MHD_FLAG, int, ptr, ptr, MHD_AccessHandlerCallback, ptr, int)
    : MHD_Daemon_ptr0
      = "mac#MHD_start_daemon"


extern fun MHD_stop_daemon(MHD_Daemon_ptr1): void
  = "mac#MHD_stop_daemon"


extern fun MHD_create_response_from_fd(size_t, int): MHD_Response_ptr1
  = "mac#MHD_create_response_from_fd"


extern fun MHD_lookup_connection_value(!MHD_Connection_ptr1, MHD_ValueKind, string): string0
  = "mac#MHD_lookup_connection_value"


extern fun MHD_post_process
  (MHD_PostProcessor_ptr1, string, size_t): string0 =
     "mac#MHD_post_process"


typedef MHD_PostDataIterator = {n:nat} (ptr, MHD_ValueKind, string, string0, string0, string0, string(n), uint64, int n) -> int



extern fun MHD_create_post_processor
  (!MHD_Connection_ptr1, size_t, MHD_PostDataIterator, ptr): MHD_PostProcessor_ptr0
    = "mac#MHD_create_post_processor"

extern fun MHD_destroy_post_processor(MHD_PostProcessor_ptr1): void
  = "mac#MHD_destroy_post_processor"


%{
size_t file_get_size(void *fd) {
  struct stat buf;
  fstat(fileno(fd), &buf);
  return buf.st_size;
}

char *realpath_(char *string) {
  return realpath(string, NULL);
}

void pacifylinreq(void *ptr) { }
%}

extern castfn MHD_Response_ptr2ptr{l:addr}(!MHD_Response_ptr(l)): ptr(l)
extern castfn MHD_Daemon_ptr2ptr{l:addr}(!MHD_Daemon_ptr(l)): ptr(l)
extern fun realpath(string): Strptr0 = "mac#realpath_"
extern fun file_get_size(!FILEref): size_t = "mac#file_get_size"
extern fun MHD_add_response_header(!MHD_Response_ptr1, string, string): int = "mac#"
extern fun mystrrchr(string, int): string0 = "mac#strrchr"
extern castfn ptr2mhdrequest(ptr): mhdrequest
extern castfn mhdrequest2ptr(!mhdrequest): ptr
extern fun pacifylinreq(mhdrequest): void = "mac#"
extern castfn string2bytes{n:nat}(string(n)): array(byte,n)
extern fun myfwrite(ptr, size_t, size_t, FILEref): int = "mac#fwrite"
extern fun mktemp(string): string = "mac#mktemp"
extern fun myrename(string, string): int = "mac#rename"
extern fun myremove(string): int = "mac#remove"
extern castfn pp2ptr(MHD_PostProcessor_ptr0): ptr
extern castfn ptr2pp(ptr): MHD_PostProcessor_ptr1
extern fun {}answer_callback$ready(req: !mhdrequest_t): strptr

fun free_mhdrequest_vt(req: mhdrequest_vt): void = {
  val ~MHDREQUEST(@{cookies=a0,postdata=a1,getdata=a2,files=a3,pp=pp}) = req
  // TODO delete files left over 
  val () = if pp != nullp then MHD_destroy_post_processor(ptr2pp(pp))
}


fun send_file(conn: !MHD_Connection_ptr1, path: string): int = let
  val file = fileref_open_exn(path, file_mode_r)
  val size = file_get_size(file)
  val fd = dup(fileno(file))
  val response = MHD_create_response_from_fd(size, fd)
  val ret = MHD_queue_response(conn, MHD_HTTP_OK, response)
  val () = MHD_destroy_response(response)
  val () = fileref_close(file)
in
  ret
end


fun send_stringn(conn: !MHD_Connection_ptr1, str: string, len: size_t): int = let
  val response = MHD_create_response_from_buffer(len, str, MHD_RESPMEM_PERSISTENT)
  val ret = MHD_queue_response(conn, MHD_HTTP_OK, response)
  val () = MHD_destroy_response(response)
in
  ret
end


fun send_string(conn: !MHD_Connection_ptr1, str: string): int =  
  send_stringn(conn, str, strlen(str))


fun send_json_strptr(conn: !MHD_Connection_ptr1, str: strptr): int = let
  val response = MHD_create_response_from_buffer_strptr($UN.cast{size_t}(strptr_length(str)), str, MHD_RESPMEM_MUST_FREE)
  val _ = MHD_add_response_header(response, "Content-Type", "application/json");
  val ret = MHD_queue_response(conn, MHD_HTTP_OK, response)
  val () = MHD_destroy_response(response)
in
  ret
end


fun filename_extension(filename: string): string = let
  val str = mystrrchr(filename, char2int0('.'))
in
  if string2ptr(str) > nullp then
    string_copy(str)
  else
    ""
end
  

fun post_iterator{n: nat}
  (cls: ptr, kind: MHD_ValueKind, key: string, filename: string0,
   content_type: string0, transfer_encoding: string0, data: string(n),
   off: uint64, size: int n): int = let
  val key = string_copy(key)
  val req = ptr2mhdrequest(cls)
  val+@MHDREQUEST(x) = req
  val () =
    if string2ptr(filename) > nullp then {
      // it is a file 
      val path = dict_get(x.files, key)
      val path =
       (if path = "" then tmp_ext where {
          val tmp     = string_copy("uploads/UPLXXXXXXX")
          val _       = mktemp(tmp)
          val tmp_ext = tmp + filename_extension(filename)
          val _ = myrename(tmp, tmp_ext)
          val () = dict_set(x.files, key, tmp_ext)
        } else path) : string
      val out = fileref_open_exn(path, file_mode_aa)
      val z = myfwrite(string2ptr(data), sizeof<char>, i2sz(size), out)
      val () = fileref_close(out)
    } else {
      // not a file
      val newdata = string_make_substring(data, i2sz(0), i2sz(size))
      val olddata = dict_get(x.postdata, key)
      val totdata = string_append(olddata, newdata)
      val () = dict_set(x.postdata, key, totdata)
      val () = println!("received post key (", key, "): ", totdata)
    }
  prval () = fold@(req)
  val () = pacifylinreq(req)
in
  MHD_YES
end



fun {}process_query
  (cls: ptr, conn: !MHD_Connection_ptr1, url: string, method: string,
    version: string, upload_data: string, upload_size: ref(size_t), cons_cls: ref(ptr)): int = 
if !cons_cls = nullp then let
    // we create a new request 
    val req = create_mhdrequest()
    val reqptr = mhdrequest2ptr(req)
    val pp = pp2ptr(MHD_create_post_processor(conn, i2sz(4096), post_iterator, reqptr))
    val+@MHDREQUEST(x) = req
    val () = if pp > nullp then x.pp := pp
    val () = !cons_cls := reqptr
    prval () = fold@(req)
    val () = pacifylinreq(req)
  in
    MHD_YES
  end
else if !upload_size <> 0 then let
     // we continue collecting the request
     val req = ptr2mhdrequest(!cons_cls)
     val+@MHDREQUEST(x) = req
     val _ = if x.pp != nullp then MHD_post_process(ptr2pp(x.pp), upload_data, !upload_size) else ""
     val () = !upload_size := i2sz(0)
     prval () = fold@(req)
     val () = pacifylinreq(req)
   in
     MHD_YES
   end 
else let
    // we are done with all the postdata, and ready for processing
    val req = ptr2mhdrequest(!cons_cls)
    val+@MHDREQUEST(x) = req
    val pp = x.pp
    val () = x.pp := nullp 
    val () = if pp != nullp then MHD_destroy_post_processor(ptr2pp(pp))
    val response = answer_callback$ready(x)
    val ret = send_json_strptr(conn, response)
    prval () = fold@(req)
     val () = pacifylinreq(req)
  in
    ret
  end

fun {}answer_callback
  (cls: ptr, conn: !MHD_Connection_ptr1, url: string, method: string,
    version: string, upload_data: string, upload_size: ref(size_t), cons_cls: ref(ptr)): int = let
  val url = (if url = "/" then "/index.html" else url): string
  val filename = string_append("website", url)
in
  if url = "/request" then
    process_query(cls, conn, url, method, version, upload_data, upload_size, cons_cls)
  else if test_file_exists(filename) then
    send_file(conn, filename)
  else
    send_string(conn, "")
end

fun request_completed
  (cls: ptr, conn: !MHD_Connection_ptr1, cons_cls: ref(ptr), toe: MHD_RequestTerminationCode): void = {
  val maybe_ptr = !cons_cls
  val () = if maybe_ptr != nullp then free_mhdrequest_vt(ptr2mhdrequest(maybe_ptr))
  val () = !cons_cls := nullp
}
  
