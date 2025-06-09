#' Run the SciELO query and retrieve results
#'
#' Executes the query stored in a `scielo_query` object and fetches the results as a datatable.
#'
#' @param obj A `scielo_query` object created with `search_scielo()`.
#' @return A `DT::datatable` object containing the query results (title, authors, year, DOI).
#' @export
#' @importFrom utils URLencode
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @examples
#' \dontrun{
#' search_scielo("salud ambiental Costa Rica") |>
#'   journals("Población y Salud en Mesoamérica") |>
#'   categories("health", "sciences") |>
#'   languages("es") |>
#'   nmax(10) |>
#'   run()
#' }
run <- function(obj) {
  if (!inherits(obj, "scielo_query")) {
    stop("The object must be created with search_scielo()", call. = FALSE)
  }

  # Load required packages silently
  suppressPackageStartupMessages({
    requireNamespace("httr", quietly = TRUE)
    requireNamespace("xml2", quietly = TRUE)
    requireNamespace("rvest", quietly = TRUE)
    requireNamespace("dplyr", quietly = TRUE)
    requireNamespace("DT", quietly = TRUE)
    requireNamespace("stringr", quietly = TRUE)
  })

  base_url <- "https://search.scielo.org/"
  encoded_query <- URLencode(obj$query)
  results <- list()
  total <- 0
  from_idx <- 1
  count <- 15

  # Helper to build filters
  build_filter <- function(param, values) {
    if (length(values) == 0) return("")
    paste0("&", paste0("filter%5B", param, "%5D%5B%5D=", vapply(values, URLencode, ""), collapse = ""))
  }

  build_operator <- function(param, op) {
    if (length(op) == 0) return("")
    paste0("&filter_boolean_operator%5B", param, "%5D%5B%5D=", op)
  }

  # Combine filters into one string
  filters <- paste0(
    build_filter("in", obj$collections),
    build_filter("journal_title", obj$journals),
    build_filter("la", obj$languages),
    build_operator("la", obj$lang_operator),
    build_filter("wok_subject_categories", obj$categories)
  )

  # First request
  first_url <- paste0(
    base_url,
    "?lang=", obj$lang,
    "&count=", count,
    "&from=", from_idx,
    "&output=site&format=summary&sort=&fb=&page=1",
    "&q=", encoded_query,
    filters
  )
  first_resp <- httr::GET(first_url)

  if (httr::status_code(first_resp) != 200) {
    stop("Failed to fetch the first page of results.")
  }

  first_page <- xml2::read_html(first_resp)

  if (is.null(obj$n_max)) {
    total_hits <- first_page %>%
      rvest::html_node("#TotalHits") %>%
      rvest::html_text(trim = TRUE) %>%
      gsub("\\D", "", .) %>%
      as.integer()
    obj$n_max <- total_hits
  }

  while (total < obj$n_max) {
    url <- paste0(
      base_url,
      "?lang=", obj$lang,
      "&count=", count,
      "&from=", from_idx,
      "&output=site&format=summary&sort=&fb=&page=", ceiling(from_idx / count),
      "&q=", encoded_query,
      filters
    )

    resp <- httr::GET(url)
    if (httr::status_code(resp) != 200) {
      warning(paste("Failed to fetch results starting from index", from_idx))
      break
    }

    page <- xml2::read_html(resp)
    articles <- page %>% rvest::html_nodes(".item")

    if (length(articles) == 0) break

    for (article in articles) {
      if (total >= obj$n_max) break

      title <- article %>%
        rvest::html_node(".title") %>%
        rvest::html_text(trim = TRUE)

      authors <- article %>%
        rvest::html_node(".authors") %>%
        rvest::html_text(trim = TRUE)

      doi <- article %>%
        rvest::html_node(".DOIResults a") %>%
        rvest::html_attr("href")

      year <- article %>%
        rvest::html_node(".source") %>%
        rvest::html_nodes("span") %>%
        rvest::html_text(trim = TRUE) %>%
        paste(collapse = " ") %>%
        stringr::str_extract("\\b\\d{4}\\b")

      results[[length(results) + 1]] <- data.frame(
        title = title,
        authors = authors,
        year = year,
        doi = doi,
        stringsAsFactors = FALSE
      )

      total <- total + 1
    }

    from_idx <- from_idx + count
  }


  df <- dplyr::bind_rows(results)
  DT::datatable(df)
}
