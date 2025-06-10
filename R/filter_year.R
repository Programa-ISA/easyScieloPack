#' Filter by year range
#'
#' Sets a range of years to filter the SciELO query results.
#'
#' @param obj A `scielo_query` object.
#' @param start_year Starting year (inclusive).
#' @param end_year Ending year (inclusive).
#' @return The modified `scielo_query` object.
#' @export
#' @examples
#' # Filter for a single year
#' query <- search_scielo("biology") |> years(2020, 2020)
#'
#' # Filter for a range of years
#' query <- search_scielo("medicine") |> years(2018, 2022)
years <- function(obj, start_year, end_year) {

  if (!inherits(obj, "scielo_query")) {
    stop("Object must be created with search_scielo()", call. = FALSE)
  }

  # Validate inputs
  if (!is.numeric(start_year)) { # Corrected: Added closing parenthesis
    stop("start_year must be a numeric value", call. = FALSE)
  }

  if (!is.numeric(end_year)) {
    stop("end_year must be a numeric value", call. = FALSE)
  }

  if (start_year > end_year) {
    stop("start_year must be less than or equal to end_year", call. = FALSE)
  }

  # Store the year range in the query object
  obj$year_start <- as.integer(start_year)
  obj$year_end <- as.integer(end_year)

  obj
}
