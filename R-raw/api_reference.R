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

# Manually get a list of cloud recordings to figure out some rules, 'cuz that's
# the one area I actually care about.

# methods %>%
#   dplyr::filter(
#     stringr::str_starts(path, "/meetings/\\{meetingId\\}/recordings")
#   ) %>%
#   dplyr::pull(path)
#
# methods %>%
#   dplyr::filter(
#     stringr::str_starts(path, "/users/\\{userId\\}/recordings")
#   ) %>%
#   dplyr::glimpse()
#
# this_row <- methods %>%
#   dplyr::filter(
#     stringr::str_starts(path, "/users/\\{userId\\}/recordings")
#   ) %>%
#   head(1)

# All of them begin with /, so we can just systematically skip
# method_parts[[1]].

# this_path <- this_row$path
# r_file <- stringr::str_extract(this_path, "(?<=^\\/)[^/]+")
# function_name = snakecase::to_snake_case(this_row$operationId)

# Ooooooh, operationId is basically function name, except I want to make it
# prettier.
methods %>%
  dplyr::mutate(
    r_file = stringr::str_extract(path, "(?<=^\\/)[^/]+"),
    function_name = snakecase::to_snake_case(operationId)
    # method_parts = stringr::str_split(path, "/"),
    # r_file = purrr::map_chr(method_parts, 2),
    # idstuff = purrr::map_lgl(
    #   method_parts,
    #   ~any(stringr::str_detect(.x, "\\{"))
  ) %>%
  View()

