

typedef pairHT(m:int, n:int) = (list(string,m),List1(list(string,n-m)))
typedef jgfn(n:int) = (!jinj, List0(list(string,n)), list(string,n)) -<cloref1> int 
typedef jgfn0 = [n:nat] jgfn(n)

fun sql_object{n:nat}(out: !jinj, rows: List0(list(string,n)), col_names: list(string,n)):<cloref1> int = let
  fun aux_kv{z:nat}(out: !jinj, keys: list(string,z), vals: list(string,z)):<cloref1> int =
    case+ (keys, vals) of
    | (list_nil(), list_nil()) => 0
    | (list_cons(h1,t1), list_cons(h2,t2)) => put_kv(out,h1,h2) + aux_kv(out,t1,t2)
  fun loop(out: !jinj, lst: List0(list(string,n))):<cloref1> int =
    case+ lst of
    | list_nil() => 0
    | list_cons(l1, t) =>
        start_jvalue(out) +
        start_jobject(out) +
        aux_kv(out,col_names,l1) +
        end_jobject(out) +
        loop(out, t)
in
  start_jvalue(out) +
  start_jarray(out) +
  loop(out, rows) +
  end_jarray(out)
end

fun sql_group_by{m:nat}(take: int m, group_name: string, group_map: jgfn0): jgfn0 = let
  fun aux{n:nat}(out: !jinj, rows: List0(list(string,n)), col_names: list(string, n)):<cloref1> int = let
    prval () = $UN.prop_assert{m <= n}()
    val (colh, colt) = list_split_at(col_names, take)
    val colh    = list_vt2t(colh)
    val pred    = lam (l1:list(string,n), l2:list(string,n)):bool =<cloref1> compare_head<string>(l1, l2, take)
    val groups  = group<list(string,n)>(rows, pred)
    val compact = compact_group<string>(groups, take)

    val group_name = group_name
    val group_map = $UN.cast{jgfn(n-m)}(group_map)

    fun aux_kv{z:nat}(out: !jinj, keys: list(string,z), vals: list(string,z)):<cloref1> int =
      case+ (keys, vals) of
      | (list_nil(), list_nil()) => 0
      | (list_cons(h1,t1), list_cons(h2,t2)) => put_kv(out,h1,h2) + aux_kv(out,t1,t2)
    fun loop(out: !jinj, lst: List0(pairHT(m,n))):<cloref1> int =
      case+ lst of
      | list_nil() => 0
      | list_cons((l1,l2), t) =>
          start_jvalue(out) +
          start_jobject(out) +
          aux_kv(out,colh,l1) +
          put_jkey(out, group_name) +
          group_map(out, l2, colt) +
          end_jobject(out) +
          loop(out, t)
  in
    start_jvalue(out) +
    start_jarray(out) +
    loop(out, compact) +
    end_jarray(out)
  end 
in
  $UN.cast{jgfn0}(aux)
end


fun sql_group_by_{m:nat}(take: int m, group_name: string): jgfn0 =
  $UN.cast{jgfn0}(sql_group_by(take, group_name, $UN.cast{jgfn0}(sql_object)))


overload s_group_by with sql_group_by
overload s_group_by with sql_group_by_


