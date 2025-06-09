#' Filter by languages
#'
#' @param obj A scielo_query object.
#' @param ... Language codes to filter by ("es", "pt", "en").
#' @param operator Boolean operator ("AND" or "OR").
#' @return The modified query object.
#' @export
#' @examples
#' query <- search_scielo("medicine") |> languages("es", "en")
languages <- function(obj, ..., operator = "OR") {
  if (!inherits(obj, "scielo_query")) {
    stop("Object must be created with search_scielo()", call. = FALSE)
  }
  # Flatten ... into a character vector
  values <- unlist(list(...), use.names = FALSE)
  obj$languages <- unique(c(obj$languages, values))
  obj$lang_operator <- match.arg(operator, c("AND", "OR"))
  obj
}
