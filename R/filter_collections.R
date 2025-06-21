#' Filter by SciELO collection (country or ISO code)
#'
#' @param obj A scielo_query object.
#' @param ... Country names ("Costa Rica") or collection codes ("cri").
#' @return Modified query object with collection filter.
#' @export
#' @examples
#' search_scielo("agua potable") |> collections("Costa Rica", "mex")
#' Normalize collection names to SciELO codes
#' @keywords internal
normalize_collections <- function(collections) {
  country_to_code <- c(
    "Costa Rica" = "cri", "México" = "mex", "Brasil" = "bra", "Colombia" = "col",
    "Argentina" = "arg", "Chile" = "chl", "Cuba" = "cub", "Perú" = "per",
    "Venezuela" = "ven", "Uruguay" = "ury", "Ecuador" = "ecu", "Paraguay" = "pry", "Panamá" = "pan"
  )
  
  normalize <- function(x) tolower(iconv(x, to = "ASCII//TRANSLIT"))
  
  sapply(collections, function(val) {
    if (tolower(val) %in% country_to_code) {
      return(country_to_code[[val]])
    }
    
    match_idx <- match(normalize(val), normalize(names(country_to_code)))
    if (!is.na(match_idx)) {
      return(unname(country_to_code[match_idx]))
    }
    
    val # fallback to original value if no match
  }, USE.NAMES = FALSE)
}

