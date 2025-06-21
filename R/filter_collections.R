#' Filter by SciELO collection (country or ISO code)
#'
#' @param obj A scielo_query object.
#' @param ... Country names ("Costa Rica") or collection codes ("cri").
#' @return Modified query object with collection filter.
#' @export
#' @examples
#' search_scielo("agua potable") |> collections("Costa Rica", "mex")
collections <- function(obj, ...) {
  if (!inherits(obj, "scielo_query")) {
    stop("Object must be created with search_scielo()", call. = FALSE)
  }
  
  country_to_code <- c(
    "Costa Rica" = "cri", "México" = "mex", "Brasil" = "bra", "Colombia" = "col",
    "Argentina" = "arg", "Chile" = "chl", "Cuba" = "cub", "Perú" = "per",
    "Venezuela" = "ven", "Uruguay" = "ury", "Paraguay" = "pry", "Panamá" = "pan"
  )
  
  inputs <- unlist(list(...), use.names = FALSE)
  
  normalize <- function(x) tolower(iconv(x, to = "ASCII//TRANSLIT"))
  
  codes <- sapply(inputs, function(val) {
    if (tolower(val) %in% country_to_code) {
      return(country_to_code[[val]])
    }
    
    match_idx <- match(normalize(val), normalize(names(country_to_code)))
    if (!is.na(match_idx)) {
      return(unname(country_to_code[match_idx]))
    }
    
    val
  }, USE.NAMES = FALSE)
  
  obj$collections <- unique(c(obj$collections, codes))
  obj
}
