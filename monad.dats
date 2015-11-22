

#include "share/atspre_staload.hats"
#include "share/atspre_define.hats"
#define ATS_DYNLOADFLAG 0

dataviewtype either_vt(a: vt@ype+, b: vt@ype+, bool) =
  | Left(a, b, true) of (a)
  | Right(a, b, false) of (b)

viewtypedef Either_vt(a:vt@ype, b:vt@ype) = [c:bool] either_vt(a, b, c)
typedef Switch3(a:vt@ype+,b:vt@ype+,c:vt@ype+) = a -<cloref1> Either_vt(b,c)
typedef Switch2(a:vt@ype+,b:vt@ype+) = Switch3(a,a,b)
typedef Switch(a:vt@ype+,b:vt@ype+) = Switch2(a,b)
typedef TwoTrack(a:vt@ype+,b:vt@ype+) = Either_vt(a,b) -<cloref1> Either_vt(a,b)
typedef OneTrack(a:vt@ype+,b:vt@ype+) = (a -<cloref> b)

fun {a,b:vt@ype+} bind(f: Switch(a,b)): TwoTrack(a,b) =
  lam (a: Either_vt(a, b)): Either_vt(a,b) =<cloref1>
    case+ a of
    | ~Left(x) => f(x)
    | ~Right(x) => Right(x)


fun {a,b:vt@ype+} pipe(f: a, g: Switch(a,b)): Either_vt(a,b) = g(f)

symintr |>
infixl |>
overload |> with pipe


fun {a,b:vt@ype+} bind_pipe(f1: Either_vt(a,b), f2: Switch(a,b)): Either_vt(a,b) =
  case+ f1 of
  | ~Left(a) => f2(a) 
  | ~Right(b) => Right(b)

symintr >>=
infixl >>=
overload >>= with bind_pipe


fun {a,b,f:vt@ype+} map(f2: a -> b): (Either_vt(a,f) -<cloref1> Either_vt(b,f)) =
  lam (f1: Either_vt(a,f)) =<cloref1>
    case+ f1 of
    | ~Left(a) => Left(f2(a))
    | ~Right(b) => Right(b)



fun {a,b,c:vt@ype+}compose(f: a -<cloref1> b, f2: b -<cloref1> c): (a -<cloref1> c) =
  lam i =<cloref1> f2(f(i))


symintr >>
infixl >>
overload >> with compose


fun {a,b,f:vt@ype+}kleisi(f1: Switch(a,f), f2: Switch3(a,b,f)):<cloref1> Switch3(a,b,f) =
  lam (x: a): Either_vt(b,f) =<cloref1>
    case+ f1(x) of
    | ~Left(s) => f2(s)
    | ~Right(f) => Right f 


symintr >=>
//overload >=> with kleisi
infixl >=>


extern fun {b:t@ype+}merge$rule(b,b): b

fun {a,b:t@ype+}merge(f1: a -<cloref1> b, f2: a -<cloref1> b):<cloref1> (a -<cloref1> b) =
  lam a =>
    merge$rule<b>(f1(a), f2(a))



typedef Pred(a:t@ype+) = a -<cloref1> bool

fun {a:t@ype+}bool_merge_conj(f1: Pred(a), f2: Pred(a)):<cloref1> Pred(a) =
  lam a =>
    f1(a) && f2(a)


overload * with bool_merge_conj


fun {a:t@ype+}bool_merge_disj(f1: Pred(a), f2: Pred(a)):<cloref1> Pred(a) =
  lam a =>
    f1(a) || f2(a)

overload + with bool_merge_disj


