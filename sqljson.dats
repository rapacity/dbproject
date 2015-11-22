



fun list_tabulate_tlin_aux{i,n: nat | i <= n}(a: !dbresult, i: int i, n: int n, f: (!dbresult, intGte(0)) -<cloref1> string): list(string, n-i) =
  if i = n then list_nil()
  else list_cons(f(a,i), list_tabulate_tlin_aux{i+1,n}(a, i+1, n, f))

fun list_tabulate_tlin{n: nat}(a: !dbresult, n: int n, f: (!dbresult, intGte(0)) -<cloref1> string): list(string, n) =
  list_tabulate_tlin_aux(a, 0, n, f)


fun get_ncolnames{n:nat}(res: !dbresult, n: int n): list(string,n) = let
  fun get_field(r: !dbresult, i: intGte(0)):<cloref1> string = PQfname(r, i)
in
  list_tabulate_tlin(res, n, get_field)
end

fun get_row{n:nat}(res: !dbresult, row_no: intGte(0), colcount: int n): list(string,n) = let
  fun get_field(r: !dbresult, i: intGte(0)):<cloref1> string = r.get(row_no, i)
in
  list_tabulate_tlin(res, colcount, get_field)
end

fun get_rows{ncols:nat}(res: !dbresult, ncols: int ncols): List0(list(string,ncols)) = let
  fun loop{i,n:nat| i <= n}(res: !dbresult, i: int i, n: int n):<cloref1> List0(list(string,ncols)) =
    if i = n then list_nil()
    else list_cons(get_row(res, i, ncols), loop(res, i+1, n))
in
  loop(res, 0, res.count())
end





fun result_tojson(res: !dbresult, out: !jinj, model: jgfn0): int = let
  val rowcount = res.count()
  val colcount = res.ncols()
  fun aux{nrows,ncols: nat}(res: !dbresult, out: !jinj, nrows: int nrows, ncols: int ncols):<cloref1> int =  let
    val ncolnames = get_ncolnames(res, ncols) : list(string, ncols)
    val rows = get_rows(res, ncols) : List0(list(string, ncols))
    val model = $UN.cast{jgfn(ncols)}(model)
  in
    model(out, rows, ncolnames)
  end 
in
  aux(res, out, rowcount, colcount)
end


overload .tojson with result_tojson


overload groupBy with s_group_by


val asObjects = $UN.cast{jgfn0}(sql_object)


