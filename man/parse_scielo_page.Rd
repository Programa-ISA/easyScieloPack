% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/html_parsers.R
\name{parse_scielo_page}
\alias{parse_scielo_page}
\title{Parses a single SciELO search results HTML page.}
\usage{
parse_scielo_page(html_page, query_obj)
}
\arguments{
\item{html_page}{An \code{xml_document} object representing the parsed HTML page.}

\item{query_obj}{A 'scielo_query' object (used for abstract language preference).}
}
\value{
A list of data frames, each representing an article.
}
\description{
Parses a single SciELO search results HTML page.
}
\keyword{internal}
