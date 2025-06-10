#' Create a SciELO query object
#'
#' Initializes a query to search in the SciELO database with support for multiple filters.
#'
#' @param query Search string (e.g., "climate change").
#' @param lang Language for results ("es" for Spanish, "pt" for Portuguese, "en" for English).
#' @return An object of class 'scielo_query' containing the search parameters.
#' @export
#' @examples
#' # Basic usage:
#' query <- search_scielo("biodiversity conservation")
#'
#' # With filters:
#' query <- search_scielo("forest") |>
#'    languages("en") |>
#'    categories("ecology") |>
#'    journals("Uniciencia")
search_scielo <- function(query, lang = "es") {
  structure(
    list(
      query = query,
      lang = lang,
      n_max = NULL,
      journals = character(),
      languages = character(),
      lang_operator = "AND",
      categories = character(),
      year_start = NULL, # Explicitly initialize year_start
      year_end = NULL    # Explicitly initialize year_end
    ),
    class = "scielo_query"
  )
}
