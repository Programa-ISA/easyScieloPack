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
#' 

fetch_scielo_results <- function(query_obj) {
  
  # Load required packages and provide clear error messages if missing
  required_packages <- c("httr", "xml2", "rvest", "dplyr", "stringr")
  missing_packages <- c()
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      missing_packages <- c(missing_packages, pkg)
    }
  }
  if (length(missing_packages) > 0) {
    stop(paste0(
      "The following packages are required but not installed: ",
      paste(missing_packages, collapse = ", "),
      ". Please install them using `install.packages(\"", paste(missing_packages, collapse = "\", \""), "\")`."
    ), call. = FALSE)
  }
  
  
  results_list <- list() # To store results from each page
  total_articles_fetched <- 0
  current_from_idx <- 1
  items_per_page <- 15 # Fixed by SciELO's search interface
  
  
  # Determine n_max:
  # First, try to get total hits from an initial request if n_max is NULL.
  # This avoids fetching all pages if the user only wants a few, and provides better default behavior.
  effective_n_max <- query_obj$n_max
  
  if (is.null(effective_n_max)) {
    # Build URL for the first page only to get total hits
    initial_url <- build_scielo_url(query_obj, page_from_idx = 1, items_per_page = items_per_page)
    
    initial_resp <- tryCatch({
      httr::GET(initial_url, httr::user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"))
    }, error = function(e) {
      stop(paste0("Failed to connect to SciELO for initial query. Check your internet connection or the SciELO website availability. Error: ", e$message), call. = FALSE)
    })
    
    if (httr::status_code(initial_resp) != 200) {
      stop(paste0(
        "Failed to fetch initial page from SciELO. HTTP Status Code: ", httr::status_code(initial_resp), ". ",
        "URL attempted: ", initial_url, ". ",
        "This might be due to an invalid query, filter, or a temporary issue with the SciELO server."
      ), call. = FALSE)
    }
    
    initial_page_html <- xml2::read_html(initial_resp)
    
    total_hits_node <- initial_page_html %>% rvest::html_node("#TotalHits")
    if (!is.null(total_hits_node)) {
      total_hits <- total_hits_node %>%
        rvest::html_text(trim = TRUE) %>%
        gsub("\\D", "", .) %>% # Remove non-numeric characters
        as.integer()
      effective_n_max <- total_hits
    } else {
      warning("Could not determine total number of hits from SciELO page. Proceeding with a default n_max of 100 or consider setting `n_max` manually.", call. = FALSE)
      effective_n_max <- 100 # Fallback default
    }
  } else if (effective_n_max < 1) {
    warning("`n_max` must be a positive integer. Setting `n_max` to a default of 100.", call. = FALSE)
    effective_n_max <- 100
  }
  
  
  # Main pagination loop
  while (total_articles_fetched < effective_n_max) {
    current_url <- build_scielo_url(query_obj, page_from_idx = current_from_idx, items_per_page = items_per_page)
    
    resp <- tryCatch({
      httr::GET(current_url, httr::user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"))
    }, error = function(e) {
      warning(paste0("Failed to connect to SciELO for page starting at index ", current_from_idx, ". Skipping further results. Error: ", e$message), call. = FALSE)
      return(NULL) # Indicate failure for this page
    })
    
    if (is.null(resp) || httr::status_code(resp) != 200) {
      warning(paste0(
        "Failed to fetch results starting from index ", current_from_idx, ". HTTP Status Code: ",
        httr::status_code(resp), ". URL attempted: ", current_url, ". ",
        "Skipping further results."
      ), call. = FALSE)
      break # Stop fetching if a page fails
    }
    
    current_page_html <- xml2::read_html(resp)
    articles_on_page <- parse_scielo_page(current_page_html, query_obj)
    
    if (length(articles_on_page) == 0) {
      if (total_articles_fetched == 0) {
        message("No articles found for the given query and filters across all pages. Please refine your search terms.")
      }
      break # No more articles or reached end of results
    }
    
    # Add fetched articles to results list, respecting n_max
    for (article_df in articles_on_page) {
      if (total_articles_fetched < effective_n_max) {
        results_list[[length(results_list) + 1]] <- article_df
        total_articles_fetched <- total_articles_fetched + 1
      } else {
        break # Reached n_max
      }
    }
    
    current_from_idx <- current_from_idx + items_per_page
  }
  
  if (length(results_list) == 0) {
    return(data.frame(
      title = character(0),
      authors = character(0),
      year = character(0), # Keep as character if original source can be non-numeric
      doi = character(0),
      abstract = character(0),
      stringsAsFactors = FALSE
    ))
  }
  
  final_df <- dplyr::bind_rows(results_list)
  return(final_df)
}