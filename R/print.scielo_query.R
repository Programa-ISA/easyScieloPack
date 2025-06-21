#' Print method for scielo_query objects
#'
#' Executes the query stored in a `scielo_query` object and fetches the results as a data frame.
#' When the object is printed or evaluated, it will display the search results.
#'
#' @param x A `scielo_query` object created with `search_scielo()`.
#' @param ... Additional arguments (currently unused).
#' @return A `data.frame` containing the query results (title, authors, year, DOI, abstract).
#' @export
#' @importFrom dplyr bind_rows
#' @importFrom utils URLencode
#' @importFrom magrittr %>% 
#' @importFrom rlang .data
#' @method print scielo_query
#' @examples
#' \dontrun{
#' # Search for articles and get results as a data frame
#' query_results <- search_scielo("environmental sciences") |>
#'    journals("Uniciencia") |>
#'    categories("sciences") |>
#'    languages("es") |>
#'    nmax(10)
#'
#' # The 'query_results' object is a data.frame and will be printed automatically
#' query_results
#'
#' # You can also explicitly print it or assign it to a variable
#' my_df <- print(query_results)
#' head(my_df)
#' }
print.scielo_query <- function(x, ...) {
  obj <- x # For consistency with internal functions using 'obj'
  
  # 1. Validation and package loading moved to fetch_scielo_results or utility functions
  #    Or at least, the package loading for scraping specific libs should be in fetch_scielo_results.
  #    Basic validation can remain here.
  if (!inherits(obj, "scielo_query")) {
    stop("Input object must be of class 'scielo_query', created with `search_scielo()`.", call. = FALSE)
  }
  
  # 2. Delegate the heavy lifting to the new fetch_scielo_results function
  df <- fetch_scielo_results(obj)
  
  # 3. Handle printing and invisible return
  if (interactive()) {
    print(df)
  }
  invisible(df)
}