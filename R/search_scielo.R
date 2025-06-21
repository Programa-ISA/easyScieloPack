#' Create a SciELO query object
#'
#' Initializes a query to search in the SciELO database with support for multiple filters.
#'
#' @param query Search string (e.g., "climate change").
#' @param lang Language for results ("es" for Spanish, "pt" for Portuguese, "en" for English).
#' @param n_max Maximum number of results to return (integer). Defaults to NULL (no limit).
#' @param journals A character vector of journal titles to filter by. Defaults to NULL.
#' @param languages A character vector of languages to filter by (e.g., "en", "es", "pt"). Defaults to NULL.
#' @param lang_operator Operator for combining multiple language filters ("AND" or "OR"). Defaults to "AND".
#' @param categories A character vector of subject categories to filter by. Defaults to NULL.
#' @param year_start Start year for filtering results by publication year (integer). Defaults to NULL.
#' @param year_end End year for filtering results by publication year (integer). Defaults to NULL.
#' @return An object of class 'scielo_query' containing the search parameters.
#' @export
#' @examples
#' # Basic usage:
#' query_basic <- search_scielo("biodiversity conservation")
#'
#' # With filters passed directly:
#' query_filtered <- search_scielo(
#'    query = "pesticidas salud ambiental",
#'    lang = "es", # This was already present
#'    languages = "en", # Article language filter (English)
#'    journals = c("Uniciencia", "Revista Ambiente & Água"),
#'    categories = "ecology",
#'    n_max = 50,
#'    year_start = 2010,
#'    year_end = 2023E
#' )
#'
#' # You can still use the pipe syntax for more granular control or chaining:
#' query_piped <- search_scielo("forest") |>
#'    languages("en") |>
#'    categories("ecology") |>
#'    journals("Uniciencia")
search_scielo <- function(query,
                          lang = "en",
                          lang_operator = "AND",
                          n_max = NULL,
                          journals = NULL,
                          collections = NULL,
                          languages = NULL,
                          categories = NULL,
                          year_start = NULL,
                          year_end = NULL) {
  
  structure(
    list(
      query = query,
      lang = lang,
      n_max = n_max,
      lang_operator = lang_operator,
      journals = if (is.null(journals)) character() else as.character(journals),
      languages = if (is.null(languages)) character() else as.character(languages),
      collections = if (is.null(collections)) character() else normalize_collections(as.character(collections)),
      categories = if (is.null(categories)) character() else as.character(categories),
      year_start = year_start,
      year_end = year_end
    ),
    class = "scielo_query"
  )
}