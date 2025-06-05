#' Create a new SciELO query object
#'
#' @param query Search term.
#' @param lang Language (default "es").
#'
#' @return An object of class `scielo_query`.
#' @export
search_scielo <- function(query, lang = "es") {
  structure(list(
    query = query,
    n_max = NULL,
    lang = lang
  ), class = "scielo_query")
}
