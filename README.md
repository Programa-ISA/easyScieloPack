# easyScieloPak <img src="https://img.shields.io/badge/R-package-blue.svg" alt="R badge" align="right"/>

**easyScieloPak** is an R package that allows you to search and access academic articles from [SciELO](https://scielo.org) programmatically.

## Features

- Build custom search queries for SciELO.
- Filter results by year, collection, language, and more.
- Retrieve article metadata including title, authors, publication year, and link.
- Designed with a pipeable and intuitive syntax.

## Installation

# Install from GitHub
# install.packages("devtools")
devtools::install_github("yourusername/easyScieloPak")

## library(easyScieloPak)

# Create a query
q <- scielo_query("salud ambiental Costa Rica")$
  collection("cri")$
  from(2020)$
  to(2023)

# Run the query and get results
results <- q$run()
head(results)
library(easyScieloPak)

# Create a query
q <- scielo_query("salud ambiental Costa Rica")$
  collection("cri")$
  from(2020)$
  to(2023)

# Run the query and get results
results <- q$run()
head(results)


## About SciELO
SciELO is a bibliographic database and digital library of open access journals. This package provides a lightweight and unofficial way to retrieve information from SciELO’s search portal.

## Disclaimer
This package is not affiliated with or endorsed by SciELO. Web scraping is used as a fallback due to the lack of a public API. Please use responsibly and respect their terms of use.

## Contributing
Feel free to open issues or submit pull requests to improve functionality, usability, or documentation.



AAAAAA
