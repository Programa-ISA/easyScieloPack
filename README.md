# easyScieloPak <img src="https://img.shields.io/badge/R-package-blue.svg" alt="R badge" align="right"/>

**easyScieloPak** is an R package that allows you to search and access academic articles from [SciELO](https://scielo.org) programmatically.

## Objective

The main goal of **easyScieloPak** is to simplify the process of querying SciELO from R by:
- Making queries readable and reproducible.
- Allowing filters like year, collection (country), language, journal, and subject category.
- Handling pagination, data parsing, and cleaning automatically.
- Providing clear and validated feedback when a query is incorrect.
- Minimizing errors due to anti-scraping measures (e.g., 403 HTTP errors).


## Features

- Build custom search queries for SciELO.
- Filter results by year, collection, language, and more.
- Retrieve article metadata including title, authors, publication year, and link.
- Designed with intuitive syntax.
- Intelligent request handling to avoid triggering SciELO's anti-bot protection.



## Installation

You can install the development version of **easyScieloPak** from GitHub using either `devtools` or `remotes`:

# Using devtools
install.packages("devtools")
devtools::install_github("https://github.com/PabloIxcamparij/easyScieloPack.git")

# Or using remotes
install.packages("remotes")
remotes::install_github("https://github.com/PabloIxcamparij/easyScieloPack.git")

# library(easyScieloPak)

# Create a query
library(easyScieloPak)

df <- search_scielo("salud ambiental",
                    collections = "Ecuador",
                    languages = "es",
                    n_max = 5)
head(df)

df <- search_scielo("ecology",
              collections = "Chile",
              languages = "en",
              n_max = 8)

View(df) # View results in RStudio

## Current Limitations

- Each filter only supports **one value at a time** (e.g., only one country, language, journal, or category).

- Web scraping may be sensitive to structural changes in the SciELO website.

- The number of fetched articles is limited by `n_max` (default fallback is 100).

- No official API is available, so the package depends on website scraping.

- **Rate-limiting / Blocking (403 errors)**: In some cases, SciELO may detect automated access and temporarily block the search, resulting in a 403 HTTP error. This is a common limitation of scraping. If this occurs, try the following:
  - Wait a few minutes before retrying.
  - Restart your R session or switch IP/network.
  - Avoid sending too many queries in a short period.
  
  *Note: Reinstalling the package has no direct effect on the block.*

-**Default fallback limit**: If the total number of available results cannot be determined, the query will default to fetching a maximum of 100 articles.

 Recent Improvements
-Rotating User-Agents: Each request uses a different User-Agent string (Chrome, Firefox, Safari variants) to appear more like a real browser and avoid blocking.

-Random delays between requests reduce server load and minimize scraping detection.

-Retry logic: If a request fails, the package retries automatically with a different User-Agent.

## Planned Improvements

The current version of `easyScieloPak` is fully functional for basic academic exploration through SciELO. However, the following enhancements are planned for future versions:

- **Support for multiple filter values**: Currently, each filter (e.g., language, category, journal) only accepts a single value. Future versions aim to support multiple values for broader and more flexible queries (e.g., `languages("es", "en", "pt")`).
  
- **Improved scraping resistance**: We plan to implement smarter mechanisms to reduce the chances of triggering SciELO's anti-scraping protections (e.g., rotating user agents, request throttling, caching mechanisms).

- **Caching and offline mode**: Possibility to cache previous search results locally for offline use or repeated queries.

- **Enhanced error diagnostics**: Provide clearer messages and helper functions when 403 or parsing issues occur.

- **Journal/code normalization functions**: Automatic mapping of journal names to their normalized internal identifiers.


## About SciELO
SciELO is a multidisciplinary open-access platform hosting scientific journals from over 15 countries. It plays a vital role in disseminating research output from Latin America and beyond.

This package provides a lightweight, unofficial method to interact with SciELO’s search interface.

## Disclaimer
- This package is not affiliated with or endorsed by SciELO.
- It relies on web scraping, and therefore may break if the HTML structure of SciELO changes.
- Use this tool responsibly, especially for automated queries.
- Please review SciELO’s terms of use before running large queries: https://www.scielo.org/en/sobre-o-scielo/

## Contributing
Feel free to open issues or submit pull requests to improve functionality, usability, or documentation.


