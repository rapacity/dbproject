
fun regexp(regex: string): Pred(string) =
  lam str =>
    (regstr_match_string(regex, str) = 0)

fun in_range(minlen: int, maxlen: int): Pred(string) = 
  lam str =>
    let
      val len = sz2i(strlen(str))
    in
      minlen <= len && len <= maxlen
    end

fun has_length(len: int): Pred(string) =
  lam str =>
    (len = sz2i(strlen(str)))

// http://www.postgresql.org/docs/9.2/static/datatype-datetime.html
// MDY = MM/DD/YYYY
val is_date    = regexp("^[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]$")
val is_email   = regexp("^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$")
val is_int     = regexp("^[0-9]+$")
val is_gender  = regexp("^(M|F|N)$")
val is_taglist = regexp("^[{](([a-z][_a-z0-9]*)(,[a-z][_a-z0-9]*)*)?[}]$")
val is_tag     = regexp("^[a-z][a-z0-9_]*$")
val not_blank  = lam (a: string): bool =<cloref1> string_isnot_empty(a)
val is_uuid    = has_length(36)


