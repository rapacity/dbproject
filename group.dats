#include "share/atspre_staload.hats"
#include "share/atspre_define.hats"
#define ATS_DYNLOADFLAG 0
#include "share/HATS/atspre_staload_libats_ML.hats"


fun {a:t@ype+}insert_lst(lst: List0(List1(a)), itm: a, pred: (List1(a), a) -<cloref1> bool): List0(List1(a)) =
  case+ lst of
  | list_nil() => list_cons(list_cons(itm, list_nil()), list_nil())
  | list_cons(x,xs) =>
    if pred(x,itm) then 
      list_cons(list_cons(itm,x),xs)
    else
      list_cons(x,insert_lst(xs, itm, pred))

fun {a:t@ype+}insert_itm(lst: List0(List1(a)), itm: a, pred: (a, a) -<cloref1> bool): List0(List1(a)) =
  insert_lst(lst, itm, lstpred) where {
    fun lstpred(lst: List1(a), itm: a):<cloref1> bool =
      case+ lst of
      | list_cons(x,xs) => pred(x, itm)
  }


fun {a,b:t@ype+}list_foldleft(lst: List0(a), accum: b, f: (a, b) -<cloref1> b): b =
  case+ lst of
  | list_nil() => accum
  | list_cons(h,t) => list_foldleft<a,b>(t, f(h,accum), f)
  

fun {a:t@ype+}group(lst: List0(a), pred: (a, a) -<cloref1> bool): List0(List1(a)) =
  list_foldleft<a,List0(List1(a))>(lst, list_nil(),
    lam (a:a, b:List0(List1(a))):List0(List1(a)) =<cloref1> insert_itm<a>(b, a, pred))


fun {a:t@ype+}compact_group{n,m:nat | m <= n}{x:nat}(lst: list(List1(list(a, n)),x), m: int m)
  : list((list(a,m),List1(list(a,n-m))),x) =
    list_vt2t(
      list_map_cloref<List1(list(a,n))><(list(a,m),List1(list(a,n-m)))>
      (lst,
        lam l =<cloref1> let
          val+list_cons(h,t) = l
          val header = list_vt2t(list_take(h, m))
          val grouping = list_vt2t(list_map_cloref<list(a,n)><list(a,n-m)>(l, lam g =<cloref1> list_drop(g,m)))
        in
          @(header, grouping)
        end))


fun {a:t@ype+}compare_head{i,n: nat | i <= n}(l1: list(a,n), l2: list(a,n), i: int i): bool =
  if i = 0 then
    true
  else
    case+ (l1, l2) of
    | (list_cons(h1, t1), list_cons(h2, t2)) =>
      if gcompare_val_val<a>(h1, h2) = 0 then
        compare_head(t1, t2, i - 1)
      else
        false

