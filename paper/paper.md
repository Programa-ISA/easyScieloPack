---
title: 'easyScieloPack: An R package for programmatic and reproducible literature search in the SciELO database'
tags:
  - R
  - literature review
  - reproducibility
  - bibliographic databases
  - SciELO
authors:
  - name: Keneth Masis-Leandro
    orcid: 0000-0003-0946-973X
    equal-contrib: true
    affiliation: 1
  - name: José Pablo Sorto-Ixcamparij
    equal-contrib: true
    affiliation: 2
affiliations:
  - name: Infants' Environmental Health (ISA) Program, Central American Institute for Studies on Toxic Substances (IRET), Universidad Nacional, Heredia, Costa Rica
    index: 1
  - name: Carrera de Informática Empresarial, Sede Guanacaste, Universidad de Costa Rica, Liberia, Costa Rica
    index: 2
date: 02 September 2025
bibliography: paper.bib
---

# Summary

The initial phase of a literature review, searching for and documenting a corpus of academic works, is often overlooked and poorly documented, despite being critical to the review's integrity [@Brocke:2009; @Cram:2020]. Programmatic approaches can enhance reproducibility by embedding search logic directly into code, enabling automated, traceable, and transparent workflows as recommended by the Preferred Reporting Items for Systematic reviews and Meta-Analyses (PRISMA-S) [@Rethlefsen:2021]. However, such tools are rare for regionally focused databases.

To address this gap for the SciELO database, we developed `easyScieloPack`, an R package that provides a scriptable interface to SciELO. It allows users to programmatically construct, execute, and document complex literature searches with filters for year, country, language, journal, and subject category. The package returns results as tidy data frames containing key metadata (title, authors, DOI, abstract, etc.), making the output immediately ready for downstream analysis, visualization, or export.

# Statement of need

SciELO is a crucial open-access platform indexing peer-reviewed journals from Latin America, the Caribbean, South Africa, Portugal, and Spain. Its importance is underscored by the significant underrepresentation of these regions' output in major commercial databases like Scopus and Web of Science, which index only a small fraction of Latin American journals and systematically underrepresent non-English publications [@Cespedes:2021].

Researchers relying on SciELO are currently forced to use manual, point-and-click searches. This process is inherently difficult to document precisely, impossible to reproduce exactly, and inefficient for testing complex search strategies or updating reviews. While programmatic tools like `easyPubMed` [@Fantini:2025] exist for other databases, no equivalent open-source solution has been available for SciELO. `easyScieloPack` meets this need by providing a programmable and transparent workflow for researchers, librarians, and students conducting systematic reviews or bibliometric analyses who require a reproducible method to retrieve literature from this essential database.

# Installation and Usage

The `easyScieloPack` package is available on the Comprehensive R Archive Network (CRAN). The released version can be installed from an R session using:

```{r}
install.packages("easyScieloPack")
```

The development version can be installed from GitHub using the remotes package:

```{r}
remotes::install_github("Programa-ISA/easyScieloPack")
```

A basic workflow to search for articles is straightforward:

```{r}
library(easyScieloPack)

# Search for articles in English from Colombian journals
results_en <- search_scielo(query = "Machine Learning",
                            languages = "en", 
                            collections = "Colombia")

# Search for articles in Spanish from the same collection
results_es <- search_scielo(query = "Machine Learning",
                            languages = "es", 
                            collections = "Colombia")

# Compare the number of results
nrow(results_en)  # Returns 86 results in English
nrow(results_es)  # Returns 77 results in Spanish
```

The package supports multiple search filters:

```{r}
search_scielo(
  query,                  # Search term (e.g., "climate change")
  lang = "en",            # Interface language for SciELO website
  n_max = NULL,           # Maximum number of results to return
  journals = NULL,        # Vector of journal names to filter
  collections = NULL,     # Country name or ISO code
  languages = NULL,       # Vector of article languages
  categories = NULL,      # Vector of subject categories
  year_start = NULL,      # Start year for filtering articles
  year_end = NULL         # End year for filtering articles
)
```

# Acknowledgements

We would like to thank Berendina van Wendel de Joode, coordinator of the Infants' Environmental Health (ISA) Program, for enabling us to test the package in real-world research contexts and for her support throughout its development.

# References 







