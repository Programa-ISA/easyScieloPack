#' Run the SciELO query and get results
#'
#' Executes a SciELO query and returns the results as a data frame and interactive table.
#'
#' @param obj A scielo_query object created with `search_scielo()`.
#' @return A DT::datatable object containing the results (title, authors, year, DOI).
#' @export
#' @importFrom utils URLencode
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @examples
#' \dontrun{
#' # After creating a query:
#' results <- search_scielo("salud ambiental Costa Rica") |>
#'   nmax(5) |>
#'   run()
#' }
run <- function(obj) {
  # Verificación de clase mejorada
  if (!inherits(obj, "scielo_query")) {
    stop("El objeto debe ser creado con search_scielo()", call. = FALSE)
  }

  # Carga de dependencias silenciosa
  suppressPackageStartupMessages({
    requireNamespace("httr", quietly = TRUE)
    requireNamespace("xml2", quietly = TRUE)
    requireNamespace("rvest", quietly = TRUE)
    requireNamespace("dplyr", quietly = TRUE)
    requireNamespace("DT", quietly = TRUE)
  })

  base_url <- "https://search.scielo.org/"
  encoded_query <- URLencode(obj$query)
  results <- list()
  total <- 0
  from_idx <- 1
  count <- 15

  # Construir URL
  first_url <- paste0(
    base_url,
    "?lang=", obj$lang,
    "&count=", count,
    "&from=", from_idx,
    "&output=site&format=summary&sort=&fb=&page=1",
    "&q=", encoded_query
  )

  first_resp <- httr::GET(first_url)

  if (httr::status_code(first_resp) != 200) {
    stop("Error al acceder a la primera página de resultados.")
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
      "&q=", encoded_query
    )

    resp <- httr::GET(url)
    if (httr::status_code(resp) != 200) {
      warning(paste("Error al acceder a los resultados desde", from_idx))
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

      fecha <- article %>%
        rvest::html_node(".source") %>%
        rvest::html_nodes("span") %>%
        rvest::html_text(trim = TRUE) %>%
        paste(collapse = " ") %>%
        stringr::str_extract("\\b\\d{4}\\b") # extrae el año


      results[[length(results) + 1]] <- data.frame(
        title = title,
        authors = authors,
        year = fecha,
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
