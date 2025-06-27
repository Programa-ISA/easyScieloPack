# fetch_scielo_results.R

#' Fetch search results from SciELO
#'
#' This is the core function that performs the web scraping and data extraction.
#' It handles pagination and combines results into a single data frame.
#'
#' @param query_obj A `scielo_query` object.
#' @return A `data.frame` containing all fetched articles.
#'
#' @importFrom httr GET status_code user_agent
#' @importFrom xml2 read_html
#' @importFrom dplyr bind_rows
#' @importFrom magrittr %>%
#' @export
fetch_scielo_results <- function(query_obj) {
  # Check for required packages
  required_packages <- c("httr", "xml2", "rvest", "dplyr", "stringr")
  missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
  if (length(missing_packages) > 0) {
    stop(paste0("Missing required packages: ", paste(missing_packages, collapse = ", "), ".\n",
                "Install them using install.packages()."), call. = FALSE)
  }
  
  # Initialization
  results_list <- list()
  total_articles_fetched <- 0
  current_from_idx <- 1
  items_per_page <- 15
  effective_n_max <- query_obj$n_max
  
  # Determine n_max if not provided
  if (is.null(effective_n_max)) {
    initial_url <- build_scielo_url(query_obj, page_from_idx = 1, items_per_page = items_per_page)
    initial_resp <- tryCatch(httr::GET(initial_url, httr::user_agent("Mozilla/5.0")),
                             error = function(e) stop("Initial connection failed: ", e$message, call. = FALSE))
    
    if (httr::status_code(initial_resp) != 200) {
      stop("Initial page fetch failed. Status: ", httr::status_code(initial_resp), call. = FALSE)
    }
    
    initial_page_html <- xml2::read_html(initial_resp)
    total_hits_node <- initial_page_html %>% rvest::html_node("#TotalHits")
    if (!is.null(total_hits_node)) {
      total_hits <- total_hits_node %>% rvest::html_text(trim = TRUE) %>% gsub("\\D", "", .) %>% as.integer()
      effective_n_max <- total_hits
    } else {
      warning("Could not determine total hits. Defaulting to 100.", call. = FALSE)
      effective_n_max <- 100
    }
  }
  
  # Pagination loop
  while (total_articles_fetched < effective_n_max) {
    current_url <- build_scielo_url(query_obj, current_from_idx, items_per_page)
    resp <- tryCatch(httr::GET(current_url, httr::user_agent("Mozilla/5.0")),
                     error = function(e) {
                       warning("Failed at index ", current_from_idx, ": ", e$message, call. = FALSE)
                       return(NULL)
                     })
    
    if (is.null(resp) || httr::status_code(resp) != 200) {
      warning("HTTP error at index ", current_from_idx, ". Status: ", httr::status_code(resp), call. = FALSE)
      break
    }
    
    current_page_html <- xml2::read_html(resp)
    articles_on_page <- parse_scielo_page(current_page_html, query_obj)
    
    if (length(articles_on_page) == 0) {
      if (total_articles_fetched == 0) message("No articles found.")
      break
    }
    
    for (article_df in articles_on_page) {
      if (total_articles_fetched < effective_n_max) {
        results_list[[length(results_list) + 1]] <- article_df
        total_articles_fetched <- total_articles_fetched + 1
      } else break
    }
    current_from_idx <- current_from_idx + items_per_page
  }
  
  if (length(results_list) == 0) {
    return(data.frame(title=character(), authors=character(), year=character(), doi=character(), abstract=character(), stringsAsFactors = FALSE))
  }
  
  dplyr::bind_rows(results_list)
}
