#' Create a SciELO query object
#'
#' Initializes a query to search in the SciELO database. This is the first function
#' to use in the workflow, followed by `nmax()` and `run()`.
#'
#' @param query Search string (e.g., "climate change").
#' @param lang Language for results ("es" for Spanish, "pt" for Portuguese, "en" for English).
#' @return An object of class 'scielo_query' containing the search parameters.
#' @export
#' @examples
#' # Basic usage:
#' query <- search_scielo("biodiversity conservation")
#'
#' # Complete workflow:
#' resultados <- search_scielo("salud ambiental Costa Rica") |>
#'   nmax(10) |>
#'   run()
search_scielo <- function(query, lang = "es") {
  structure(
    list(
      query = query,
      lang = lang,
      n_max = NULL
    ),
    class = "scielo_query"
  )
}
