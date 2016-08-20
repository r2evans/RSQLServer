# Driver -----------------------------------------------------------------

#' SQL Server Driver class
#'
#' @seealso \code{\link{SQLServer}}
#' @keywords internal
#' @importClassesFrom rJava jobjRef
#' @export

setClass("SQLServerDriver", contains = "DBIDriver",
  slots = c(jdrv = "jobjRef"))


# Connection -------------------------------------------------------------

#' SQL Server Connection class
#'
#' @keywords internal
#' @export

setClass("SQLServerConnection", contains = 'DBIConnection',
  slots = c(jc = "jobjRef"))


# Result -----------------------------------------------------------------

#' SQL Server Result classes
#'
#' The \code{SQLServerResult} class extends the \code{DBIResult} class, while
#' the \code{SQLServerUpdateResult} class extends the \code{SQLServerResult}
#' class. The latter is created by a called to \code{dbSendStatement} as the
#' JDBC API does not return a ResultSet but rather an integer value. The
#' \code{dbGetRowsAffected} called on \code{SQLServerUpdateResult} returns the
#' value produced by the JDBC API.
#'
#' @keywords internal
#' @export

setClass ("SQLServerPreResult", contains = 'DBIResult',
  slots = c(stat = "jobjRef"))

#' @keywords internal
#' @rdname SQLServerResult-class
#' @export

setClass ("SQLServerResult", contains = 'SQLServerPreResult',
  slots = c(jr = "jobjRef", md = "jobjRef", pull = "jobjRef"))

#' @keywords internal
#' @rdname SQLServerResult-class
#' @export

setClass ("SQLServerUpdateResult", contains = 'SQLServerResult')

