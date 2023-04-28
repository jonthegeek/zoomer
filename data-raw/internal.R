.zoom_auth_url <- "https://zoom.us/oauth/authorize"
.zoom_token_url <- "https://zoom.us/oauth/token"
.zoom_oauth_app_url <- "https://marketplace.zoom.us/user/build"

usethis::use_data(
  .zoom_auth_url,
  .zoom_token_url,
  .zoom_oauth_app_url,
  internal = TRUE,
  overwrite = TRUE
)

rm(
  .zoom_auth_url,
  .zoom_token_url,
  .zoom_oauth_app_url
)
