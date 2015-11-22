

%{
#include <libpq-fe.h>
%}

typedef PGconn = $extype"PGconn"
typedef PGresult = $extype"PGresult"
typedef Oid = $extype"Oid"

typedef PGconn_ptr = ptr
typedef PGresult_ptr = ptr
typedef Oid_ptr = ptr


absvtype PGconn_ptr (l:addr) = ptr
vtypedef PGconn_ptr0 = [l:addr] PGconn_ptr (l)
vtypedef PGconn_ptr1 = [l:addr| l > null] PGconn_ptr (l)

absvtype PGresult_ptr (l:addr) = ptr
vtypedef PGresult_ptr0 = [l:addr] PGresult_ptr (l)
vtypedef PGresult_ptr1 = [l:addr| l > null] PGresult_ptr (l)



typedef ConnStatusType = int // $extype"ConnStatusType"
macdef CONNECTION_STARTED           = $extval(ConnStatusType, "CONNECTION_STARTED")
macdef CONNECTION_MADE              = $extval(ConnStatusType, "CONNECTION_MADE")
macdef CONNECTION_AWAITING_RESPONSE = $extval(ConnStatusType, "CONNECTION_AWAITING_RESPONSE")
macdef CONNECTION_AUTH_OK           = $extval(ConnStatusType, "CONNECTION_AUTH_OK")
macdef CONNECTION_SSL_STARTUP       = $extval(ConnStatusType, "CONNECTION_SSL_STARTUP")
macdef CONNECTION_SETENV            = $extval(ConnStatusType, "CONNECTION_SETENV")
macdef CONNECTION_OK                = $extval(ConnStatusType, "CONNECTION_OK")
macdef CONNECTION_BAD               = $extval(ConnStatusType, "CONNECTION_BAD")


//abst@ype ExecStatusType = $extype"ExecStatusType"
typedef ExecStatusType = int
macdef PGRES_EMPTY_QUERY     = $extval(ExecStatusType, "PGRES_EMPTY_QUERY")
macdef PGRES_COMMAND_OK      = $extval(ExecStatusType, "PGRES_COMMAND_OK")
macdef PGRES_TUPLES_OK       = $extval(ExecStatusType, "PGRES_TUPLES_OK")
macdef PGRES_COPY_OUT        = $extval(ExecStatusType, "PGRES_COPY_OUT")
macdef PGRES_COPY_IN         = $extval(ExecStatusType, "PGRES_COPY_IN")
macdef PGRES_BAD_RESPONSE    = $extval(ExecStatusType, "PGRES_BAD_RESPONSE")
macdef PGRES_NONFATAL_ERROR  = $extval(ExecStatusType, "PGRES_NONFATAL_ERROR")
macdef PGRES_FATAL_ERROR     = $extval(ExecStatusType, "PGRES_FATAL_ERROR")
macdef PGRES_COPY_BOTH       = $extval(ExecStatusType, "PGRES_COPY_BOTH")
macdef PGRES_SINGLE_TUPLE    = $extval(ExecStatusType, "PGRES_SINGLE_TUPLE")


extern fun PQconnectdb(string): PGconn_ptr1 = "mac#PQconnectdb"
extern fun PQstatus(!PGconn_ptr1): ConnStatusType = "mac#PQstatus"
extern fun PQfinish(PGconn_ptr1): void = "mac#PQfinish"
extern fun PQexec(!PGconn_ptr1, string): PGresult_ptr1 = "mac#PQexec"
extern fun PQresultStatus(!PGresult_ptr1): ExecStatusType = "mac#PQresultStatus"
extern fun PQclear(PGresult_ptr1): void = "mac#PQclear"
extern fun PQntuples(!PGresult_ptr1): intGte(0) = "mac#PQntuples"
extern fun PQgetvalue{r,c:nat}
  (!PGresult_ptr1, int r, int c): string = "mac#PQgetvalue"
extern fun PQnfields(!PGresult_ptr1): [c:nat] int c = "mac#PQnfields"
extern fun PQfname
  (!PGresult_ptr1, intGte(0)): string = "mac#PQfname"
extern fun PQprepare(!PGconn_ptr1, string, string, int, Oid_ptr): PGresult_ptr1 = "mac#PQprepare"
extern fun PQexecPrepared(!PGconn_ptr1, string, int, ptr, ptr, ptr, int): PGresult_ptr1 = "mac#PQexecPrepared"
extern fun PQexecParams{n:nat}
  (!PGconn_ptr1, string, int n, Oid_ptr, ptr, ptr, ptr, int): PGresult_ptr1 = "mac#PQexecParams"
extern fun PQgetisnull{r,c:nat}
  (PGresult_ptr, int r, int c): bool = "mac#PQgetisnull"





fun querya{n:nat}(conn: !PGconn_ptr1, stmt: string, argc: int n, argv: ptr): PGresult_ptr1 =
  PQexecParams(conn, stmt, argc, the_null_ptr, argv, the_null_ptr, the_null_ptr, 0)


fun queryv0(conn: !PGconn_ptr1, stmt: string): PGresult_ptr1 =
  querya(conn, stmt, 0, the_null_ptr)

fun queryv1(conn: !PGconn_ptr1, stmt: string, a0: string): PGresult_ptr1 = let
  val params = (arrayptr)$arrpsz{string}(a0)
  val result = querya(conn, stmt, 1, arrayptr2ptr(params))
  val () = arrayptr_free(params)
in
  result
end
 
fun queryv2(conn: !PGconn_ptr1, stmt: string, a0: string, a1: string): PGresult_ptr1 = let
  val params = (arrayptr)$arrpsz{string}(a0, a1)
  val result = querya(conn, stmt, 2, arrayptr2ptr(params))
  val () = arrayptr_free(params)
in
  result
end
 
fun queryv3(conn: !PGconn_ptr1, stmt: string, a0: string, a1: string, a2: string): PGresult_ptr1 = let
  val params = (arrayptr)$arrpsz{string}(a0, a1, a2)
  val result = querya(conn, stmt, 3, arrayptr2ptr(params))
  val () = arrayptr_free(params)
in
  result
end

fun queryv4(conn: !PGconn_ptr1, stmt: string, a0: string, a1: string, a2: string, a3: string): PGresult_ptr1 = let
  val params = (arrayptr)$arrpsz{string}(a0, a1, a2, a3)
  val result = querya(conn, stmt, 4, arrayptr2ptr(params))
  val () = arrayptr_free(params)
in
  result
end

fun queryv5(conn: !PGconn_ptr1, stmt: string, a0: string, a1: string, a2: string, a3: string, a4: string): PGresult_ptr1 = let
  val params = (arrayptr)$arrpsz{string}(a0, a1, a2, a3, a4)
  val result = querya(conn, stmt, 5, arrayptr2ptr(params))
  val () = arrayptr_free(params)
in
  result
end


fun queryv6(conn: !PGconn_ptr1, stmt: string, a0: string, a1: string, a2: string, a3: string, a4: string, a5: string): PGresult_ptr1 = let
  val params = (arrayptr)$arrpsz{string}(a0, a1, a2, a3, a4, a5)
  val result = querya(conn, stmt, 6, arrayptr2ptr(params))
  val () = arrayptr_free(params)
in
  result
end


fun queryv7(conn: !PGconn_ptr1, stmt: string, a0: string, a1: string, a2: string, a3: string, a4: string, a5: string, a6: string): PGresult_ptr1 = let
  val params = (arrayptr)$arrpsz{string}(a0, a1, a2, a3, a4, a5, a6)
  val result = querya(conn, stmt, 7, arrayptr2ptr(params))
  val () = arrayptr_free(params)
in
  result
end

fun queryv8(conn: !PGconn_ptr1, stmt: string, a0: string, a1: string, a2: string, a3: string, a4: string, a5: string, a6: string, a7: string): PGresult_ptr1 = let
  val params = (arrayptr)$arrpsz{string}(a0, a1, a2, a3, a4, a5, a6, a7)
  val result = querya(conn, stmt, 8, arrayptr2ptr(params))
  val () = arrayptr_free(params)
in
  result
end




overload query with queryv0
overload query with queryv1
overload query with queryv2
overload query with queryv3
overload query with queryv4
overload query with queryv5
overload query with queryv6
overload query with queryv7
overload query with queryv8

overload .query with query

viewtypedef dbconn = PGconn_ptr1
viewtypedef dbresult = PGresult_ptr1



fun is_rescommand_ok(res: !PGresult_ptr1): bool = 
  PQresultStatus(res) = PGRES_COMMAND_OK
  

fun is_restuples_ok(res: !PGresult_ptr1): bool =
  PQresultStatus(res) = PGRES_TUPLES_OK
  
val rowcount = PQntuples

val getv = PQgetvalue


val connectdb = PQconnectdb

overload .free with PQclear
overload .count with PQntuples
overload .ncols with PQnfields

overload .get with PQgetvalue

overload .fname with PQfname


overload .status with PQresultStatus
overload .status with PQstatus
overload .free with PQfinish

overload free with PQfinish
overload free with PQclear



//overload [] with PQgetvalue of 0
fun {a: vt@ype+} result_map(res: PGresult_ptr1, f: (!PGresult_ptr1) -<cloref1> a): a = let
  val r = f(res)
  val () = PQclear(res)
in
  r
end

overload .map with result_map

fun result_query_ok(res: !PGresult_ptr1): bool =
  res.status() = PGRES_TUPLES_OK


overload .query_ok with result_query_ok

fun result_command_ok(res: !PGresult_ptr1): bool =
  res.status() = PGRES_COMMAND_OK

overload .command_ok with result_command_ok


fun db_connection_ok(db: !dbconn): bool =
  db.status() = CONNECTION_OK


overload .connection_ok with db_connection_ok





