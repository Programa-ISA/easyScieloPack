#' Filter by journal names
#'
#' @param obj A scielo_query object.
#' @param ... Journal names to filter by.
#' @return The modified query object.
#' @export
#' @examples
#' query <- search_scielo("biology") |> journals("Revista de Biología Tropical")
journals <- function(obj, ...) {
  if (!inherits(obj, "scielo_query")) {
    stop("Object must be created with search_scielo()", call. = FALSE)
  }
  obj$journals <- unique(c(obj$journals, ...))
  obj
}
