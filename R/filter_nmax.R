#' Set maximum number of results
#'
#' Limits the number of results to return from a SciELO query.
#'
#' @param obj A scielo_query object from `search_scielo()`.
#' @param value Maximum number of results (integer).
#' @return The modified scielo_query object.
#' @export
#' @examples
#' # Create query limited to 20 results:
#' query <- search_scielo("salud ambiental Costa Rica") |>
#'   nmax(20)
nmax <- function(obj, value) {
  if (!inherits(obj, "scielo_query")) {
    stop("El objeto debe ser creado con search_scielo()", call. = FALSE)
  }
  if (!is.numeric(value) || value <= 0) {
    stop("value debe ser un número positivo", call. = FALSE)
  }
  obj$n_max <- as.integer(value)
  obj
}
