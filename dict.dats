

staload "libats/SATS/funmap_rbtree.sats"
staload "libats/DATS/funmap_rbtree.dats"
staload STRC = "libc/SATS/string.sats"


typedef dict_key = string
typedef dict_itm = string
datatype dict = dict of (ref(map(dict_key, dict_itm)))

implement compare_key_key<string>(a: string, b: string): int = $STRC.strcmp(a,b)

fun make_empty_dict(): dict =
  dict(ref<map(dict_key,dict_itm)>(funmap_nil()))

fun dict_set(d: dict, k: dict_key, v: dict_itm): void = let
  val dict(r) = d
  var m : map(dict_key,dict_itm) = ref_get_elt(r)
  val o = funmap_insert_opt<dict_key,dict_itm>(m,k,v) 
  val () = case+ o of ~Some_vt(o) => () | ~None_vt() => ()
  val () = ref_set_elt(r,m)
in
end

overload .set with dict_set
overload [] with dict_set

fun dict_get(d: dict, k: dict_key): dict_itm = let
  val dict(r) = d
  var m : map(dict_key,dict_itm) = ref_get_elt(r)
  val o = funmap_search_opt<dict_key,dict_itm>(m,k) 
in
  case+ o of
  | ~Some_vt(s) => s
  | ~None_vt() => ""
end


fun dict_get_opt(d: dict, k: dict_key): Option_vt(dict_itm) = let
  val dict(r) = d
  var m : map(dict_key,dict_itm) = ref_get_elt(r)
in
  funmap_search_opt<dict_key,dict_itm>(m,k) 
end

overload .get with dict_get
overload [] with dict_get


fun dummy_request(): dict =
  make_empty_dict()




