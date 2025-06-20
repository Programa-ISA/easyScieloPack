#' Print method for scielo_query objects
#'
#' Executes the query stored in a `scielo_query` object and fetches the results as a datatable,
#' displaying them when the object is printed or evaluated.
#'
#' @param x A `scielo_query` object created with `search_scielo()`.  <-- CAMBIO AQUÍ
#' @param ... Additional arguments passed to or from other methods. <-- NUEVO PARÁMETRO
#' @return A `DT::datatable` object containing the query results (title, authors, year, DOI).
#' @export
#' @importFrom utils URLencode
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @method print scielo_query  <-- ¡ESTA ES LA LÍNEA CRUCIAL!
#' @examples
#' \dontrun{
#' search_scielo("environmental sciences") |>
#'    journals("Uniciencia") |>
#'    categories("sciences") |>
#'    languages("es") |>
#'    nmax(10)
#' }
print.scielo_query <- function(x, ...) { # <-- CAMBIO AQUÍ (obj a x, y añadir ...)
  obj <- x # Mantén esta línea si prefieres usar 'obj' dentro de la función para mayor claridad
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
  
  # Helper to build year filters
  build_year_filter <- function(start_year, end_year) {
    if (is.null(start_year) || is.null(end_year)) return("")
    
    # Generate sequence of years
    years <- seq(start_year, end_year)
    # Create an array of strings, each formatted as '&filter%5Byear_cluster%5D%5B%5D=YYYY'
    # Then collapse them into a single string.
    paste0(paste0("&filter%5Byear_cluster%5D%5B%5D=", years), collapse = "")
  }
  # Combine filters into one string
  filters <- paste0(
    build_filter("in", obj$collections),
    build_filter("journal_title", obj$journals),
    build_filter("la", obj$languages),
    build_operator("la", obj$lang_operator),
    build_filter("wok_subject_categories", obj$categories),
    build_year_filter(obj$year_start, obj$year_end)
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
  
  
  # If n_max is not specified, try to get the total number of hits from the first page
  if (is.null(obj$n_max)) {
    total_hits_node <- first_page %>%
      rvest::html_node("#TotalHits")
    
    if (!is.null(total_hits_node)) {
      total_hits <- total_hits_node %>%
        rvest::html_text(trim = TRUE) %>%
        gsub("\\D", "", .) %>% # Remove non-numeric characters
        as.integer()
      obj$n_max <- total_hits
    } else {
      # Fallback if TotalHits node is not found, assume a reasonable default or error
      warning("Could not determine total number of hits from the page. Setting n_max to a default of 100 or consider setting it manually.")
      obj$n_max <- 100 # Default to 100 if total hits cannot be determined
    }
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
    
    # If no articles are found on the current page, stop fetching
    if (length(articles) == 0) {
      if (total == 0) {
        message("No articles found for the given query and filters.")
      }
      break
    }
    
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
      
      # Get ID
      article_id <- article %>%
        rvest::html_attr("id")
      
      # Plus abstract in English
      abstract_id <- paste0(article_id, "_en")
      
      # Search el abstract
      abstract_text <- NA
      if (!is.na(abstract_id)) {
        abstract_node <- page %>%
          rvest::html_node(sprintf("div#%s", abstract_id))
        if (!is.null(abstract_node)) {
          abstract_text <- abstract_node %>%
            rvest::html_text(trim = TRUE)
        }
      }
      
      results[[length(results) + 1]] <- data.frame(
        title = ifelse(is.null(title), NA, title), # Handle potentially missing title
        authors = ifelse(is.null(authors), NA, authors), # Handle potentially missing authors
        year = ifelse(is.null(year), NA, year),      # Handle potentially missing year
        doi = ifelse(is.null(doi), NA, doi),          # Handle potentially missing DOI
        abstract = abstract_text,
        stringsAsFactors = FALSE
      )
      
      total <- total + 1
    }
    
    from_idx <- from_idx + count
  }
  
  df <- dplyr::bind_rows(results)
  print(DT::datatable(df))
  invisible(df)
}