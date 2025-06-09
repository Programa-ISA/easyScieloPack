#' Filter by subject categories
#'
#' @param obj A scielo_query object.
#' @param ... Subject categories to filter by.
#' @return The modified query object.
#' @export
#' @examples
#' query <- search_scielo("ecology") |> categories("environmental sciences")
categories <- function(obj, ...) {
  if (!inherits(obj, "scielo_query")) {
    stop("Object must be created with search_scielo()", call. = FALSE)
  }
  obj$categories <- unique(c(obj$categories, ...))
  obj
}
