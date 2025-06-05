#' Set the maximum number of rows to return
#'
#' @param obj A scielo_query object.
#' @param value An integer number.
#' @return The modified query object.
#' @export
nmax <- function(obj, value) {
  if (!inherits(obj, "scielo_query")) stop("El objeto no es de clase 'scielo_query'")
  obj$n_max <- value
  obj
}
