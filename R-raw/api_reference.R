## Adapted from
## https://github.com/rstudio/swagger/issues/1#issuecomment-395627756 by
## hrbrmstr

library(glue)
library(styler)
library(tidyverse)
library(jsonlite)

# OpenAPI spec sourced from
# https://marketplace.zoom.us/docs/api-reference/zoom-api/methods
api_spec <- jsonlite::read_json("R-raw/swagger.json")
base_path <- api_spec$servers[[1]]$url

methods <- tibble::enframe(
  x = api_spec$paths,
  name = "path"
) %>%
  tidyr::unnest_wider(value) %>%
  tidyr::pivot_longer(
    get:put,
    names_to = "http"
  ) %>%
  dplyr::mutate(
    http = toupper(http),
    is_null = purrr::map_lgl(value, is.null)
  ) %>%
  dplyr::filter(!is_null) %>%
  dplyr::select(-is_null) %>%
  tidyr::unnest_wider(
    value
  ) %>%
  dplyr::filter(is.na(deprecated) | !deprecated) %>%
  dplyr::select(-deprecated)

methods

# I *think* I want to divide it into a file for each path start, and then the
# rest of the path (minus anything in {}) is the function name. The {} ones are
# a special case, and those things should become parameters to the function. I
# shouldn't call that a special case, though, because that's 201 of 253 methods.
# This plan isn't exactly right yet. See things that start with
# "/metrics/meetings" for some definite counter-examples.

# "/metrics/meetings/{meetingId}/participants/{participantId}/qos" feels like it
# should be something like meeting_participant_qos.
