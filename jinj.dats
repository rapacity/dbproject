
#include "share/atspre_staload.hats"
#include "share/atspre_define.hats"

#define ATS_DYNLOADFLAG 0

#include "share/HATS/atspre_staload_libats_ML.hats"





staload "libats/SATS/stringbuf.sats"
staload _ = "libats/DATS/stringbuf.dats"

//dynload "libats/DATS/stringbuf.dats"



staload UN = "prelude/SATS/unsafe.sats"

staload "contrib/json-c/SATS/json.sats"
staload _ = "contrib/json-c/DATS/json.dats"



// TODO switch fully to json-c





fun bool_tojson(out: !stringbuf, o: bool): int =
  stringbuf_insert_bool(out, o)
   
fun string_tojson(out: !stringbuf, o: string): int = let
  val jso = json_object_new_string(o)
  val str = json_object_to_json_string(jso)
  val n = stringbuf_insert_string(out, $UN.castvwtp0{string}(str))
  val _ = json_object_put(jso)
in
  n 
end
   
fun int_tojson(out: !stringbuf, o: int): int =
  stringbuf_insert_int(out, o)


overload tojson with bool_tojson
overload tojson with string_tojson
overload tojson with int_tojson
overload free with stringbuf_free
overload free with strptr_free


datatype jstate =
  | jrhead
  | jrbody
  | jahead
  | jabody
  | johead
  | jobody
  | jkhead
  | jkbody


dataviewtype jinj =
  JINJ of @{out=stringbuf, stack=List0(jstate)}


fun start_jinj(out: stringbuf): jinj = 
  JINJ(@{out=out,stack=list_cons(jrhead, list_nil())})



#define :: list_cons


fun start_jkey(j: !jinj): int = n where {
  val+@JINJ(x) = j
  val n =
    (case- x.stack of
     | jobody() :: t => stringbuf_insert_char(x.out, ',')
     | johead() :: t => 0  where { val () = x.stack := jobody :: t }) : int
  prval () = fold@(j)
}


fun start_jvalue(j: !jinj): int = n where {
  val+@JINJ(x) = j
  val n =
    (case- x.stack of
     | jahead() :: t => 0 where { val () = x.stack := jabody :: t }
     | jabody() :: t => stringbuf_insert_char(x.out, ',')
     | _ => 0)
  prval () = fold@(j)
}


fun start_jobject(j: !jinj): int = n where {
  val+@JINJ(x) = j
  val n = stringbuf_insert_char(x.out, '\{')
  val () = x.stack := johead() :: x.stack
  prval () = fold@(j)
}


fun start_jarray(j: !jinj): int = n where {
  val+@JINJ(x) = j
  val n = stringbuf_insert_char(x.out, '\[')
  val () = x.stack := jahead() :: x.stack
  prval () = fold@(j)
}


fun end_jobject(j: !jinj): int = n where {
  val+@JINJ(x) = j
  val- h :: t = x.stack
  val n = stringbuf_insert_char(x.out, '}')
  val () = x.stack := t
  prval () = fold@(j)
}



fun end_jarray(j: !jinj): int = n where {
  val+@JINJ(x) = j
  val- h :: t = x.stack
  val n = stringbuf_insert_char(x.out, ']')
  val () = x.stack := t
  prval () = fold@(j)
}


fun jinj_print(j: !jinj, p: (!stringbuf) -<cloref1> int): int = n where {
  val+@JINJ(x) = j
  val n = p(x.out)
  prval () = fold@(j)
}


fun put_kv(j: !jinj, key: string, value: string): int =
  start_jkey(j) +
  jinj_print(j, lam out => tojson(out, key)) +
  jinj_print(j, lam out => stringbuf_insert_char(out, ':')) +
  start_jvalue(j) +
  jinj_print(j, lam out => tojson(out, value))


fun put_jkey(j: !jinj, key: string): int = 
  start_jkey(j) +
  jinj_print(j, lam out => tojson(out, key)) +
  jinj_print(j, lam out => stringbuf_insert_char(out, ':'))
 


fun put_jvalue(j: !jinj, value: string): int =
  start_jvalue(j) +
  jinj_print(j, lam out => tojson(out, value))
 

fun finish_jinj(j: jinj): stringbuf = let
  val~JINJ(@{out=out,stack=stack}) = j
in
  out
end

 



// implement main0() = let
// //  val out = stringbuf_make_nil(i2sz(1024))
// //  val j = start_jinj(out)
// //  val out = finish_jinj(j)
// //  val () = stringbuf_free(out)
// in
// 
// end


////

 
(* 

implement main0() = let
  var js = start_jinj()

  val out = stringbuf_make_nil(i2sz(1024))


  val _ = start_jobject(out, js)
  val _ = put_kv(out, js, "kek", "lol")
  val _ = put_kv(out, js, "kek", "lol")
  val _ = put_kv(out, js, "kek", "lol")
  val _ = put_kv(out, js, "kek", "lol")
  val _ = put_kv(out, js, "kek", "lol")
  val _ = put_jkey(out, js, "toaster")
  val _ = start_jvalue(out, js)
  val _ = start_jarray(out, js)
  val _ = put_jvalue(out, js, "omg")
  val _ = put_jvalue(out, js, "omg")
  val _ = put_jvalue(out, js, "omg")
  val _ = put_jvalue(out, js, "omg")
  val _ = end_jarray(out, js)
  val _ = end_jobject(out, js)
  val str = stringbuf_takeout_all(out)

  val () = println!(str)
  val () = stringbuf_free(out)
  val () = strptr_free(str)
in

end

*)














