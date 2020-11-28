# Scrape initial versions of functions from the API reference.

library(magrittr)

page <- xml2::read_html("https://marketplace.zoom.us/docs/api-reference/zoom-api/accounts/accounts")

page

method <- rvest::html_nodes(page, ".TextBlock-header-token") %>%
  rvest::html_text()

rvest::html_nodes(page, ".HubBlockList")[[1]] %>%
  rvest::html_nodes(".mr-3") %>%
  rvest::html_text()

fun_args <- page %>%
  rvest::html_table() %>%
  purrr::pluck(2)
