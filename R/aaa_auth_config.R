#' OAuth parameters
#'
#' These parameters are used in multiple authentication functions. Define them
#' here so they're consistent.
#'
#' @param cache_disk Should the access token be cached on disk? Cached tokens
#'   are encrypted and automatically deleted 30 days after creation. See
#'   [httr2::req_oauth_auth_code()].
#' @param cache_key If you are authenticating with multiple users using the same
#'   client, use this key to differentiate between those users.
#' @param client A Zoom OAuth client created with [zoom_client()].
#' @param client_id A Zoom OAuth App client ID. We recommend you save it as an
#'   environment variable, `ZOOM_CLIENT_ID`.
#' @param client_secret A Zoom OAuth App client secret. We recommend you save it
#'   as an environment variable, `ZOOM_CLIENT_SECRET`.
#' @param force A logical indicating whether to force a refresh of the token.
#' @param refresh_token A refresh token associated with this `client`.
#' @param request A [httr2::request()].
#' @param scopes A character vector of allowed scopes, such as "recording:read".
#' @param token An Zoom API [httr2::oauth_token()].
#'
#' @name .oauth-parameters
#' @keywords internal
NULL

#' OAuth token documentation
#' @return A Zoom [httr2::oauth_token()], invisibly.
#' @name .oauth-token
NULL

#' OAuth client documentation
#' @return A Zoom [httr2::oauth_client()].
#' @name .oauth-client
NULL

#' OAuth request authentication documentation
#' @param token A Zoom API OAuth token, or the `access_token` string from such a
#'   token. We recommend that you instead supply a `client`, in which case an
#'   appropriate token will be located if possible.
#' @return An [httr2::request()] with Zoom OAuth authentication information.
#' @name .oauth-req-auth
NULL

# The API documentation should list an "authorization" endpoint and a "token" or
# "access token" endpoint. Paste those here.
.api_authorization_url <- "https://zoom.us/oauth/authorize"
.api_token_url <- "https://zoom.us/oauth/token"

# The API will also have a way to build an "App" or a "Client". Provide that url
# here.
.api_oauth_app_mgmt_url <- "https://marketplace.zoom.us/user/build"

# Configure defaults and other things specific to this API in aaa_auth_zoom.R.
