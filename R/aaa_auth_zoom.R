#' Visit Zoom Created Apps
#'
#' Launch the Zoom "Created Apps" page (where you can configure OAuth 2.0
#' Clients). Navigate to "Develop > Build App" if you don't have an app, and
#' choose "OAuth". Set the "OAuth allow list" to "http://localhost:8888". You'll
#' also have to give the app allowed scopes. After you configure your app,
#' copy/paste the Client ID and Client Secret into the `ZOOM_CLIENT_ID` and
#' `ZOOM_CLIENT_ID` environment variables. We recommend placing these
#' environment variables in your `.Renviron` file.
#'
#' @return The url of the "Created Apps" page, invisibly.
#' @export
#' @examples
#' zoom_app_mgmt_url <- zoom_browse_app_management()
#' # Copy/paste values from your client.
#' Sys.setenv(ZOOM_CLIENT_ID = "raNdOMletTeRS")
#' Sys.setenv(ZOOM_CLIENT_SECRET = "RanDomleTTerSandNumb3rs")
zoom_browse_app_management <- function() {
  return(.api_browse_oauth_app(.api_oauth_app_mgmt_url))
}

#' Construct a Zoom OAuth client
#'
#' Builds the OAuth client object for Zoom apis.
#'
#' @inheritParams .oauth-parameters
#' @inherit .oauth-client return
#' @export
#' @examples
#' zoom_client <- zoom_client()
zoom_client <- function(client_id = Sys.getenv("ZOOM_CLIENT_ID"),
                        client_secret = Sys.getenv("ZOOM_CLIENT_SECRET")) {
  return(.api_client(client_id, client_secret))
}

#' Authenticate with a Zoom OAuth client
#'
#' @description
#' `r lifecycle::badge("questioning")`
#'
#' Load or generate a Zoom OAuth token for use in the other functions in this
#' package. The primary use of this function is to cache values early in a
#' script (so the user can walk away). Otherwise the other functions in this
#' package will prompt for authentication when needed. Once the values are
#' cached, the rest of this package will use them by default for that client.
#'
#' @inheritParams .oauth-parameters
#' @inherit .oauth-token return
#' @export
zoom_authenticate <- function(client = zoom_client(),
                              cache_key = getOption("zoom.cache_key", NULL),
                              scopes = "recording:read",
                              force = FALSE,
                              refresh_token = NULL) {
  # I'll probably remove this. With the rotating refresh tokens, I'm not sure
  # it's useful. I'll decide after this PR, and, if we keep it, figure out how
  # to test it.

  # nocov start
  return(
    .api_authenticate(
      client,
      cache_key,
      scopes,
      force,
      refresh_token
    )
  )
  # nocov end
}

#' Zoom request OAuth authentication
#'
#' This function is the main way authentication is handled in this package. It
#' tries to find a token non-interactively if possible, but bothers the user if
#' necessary.
#'
#' @inheritParams .oauth-req-auth
#' @inheritParams .oauth-parameters
#' @inherit .oauth-req-auth return
#' @keywords internal
.zoom_req_authenticate <- function(request,
                                   client = zoom_client(),
                                   scopes = "recording:read",
                                   cache_disk = getOption(
                                     "zoom.cache_disk", FALSE
                                   ),
                                   cache_key = getOption(
                                     "zoom.cache_key", NULL
                                   ),
                                   token = NULL) {
  return(.api_req_authenticate(
    request,
    client,
    scopes,
    cache_disk,
    cache_key,
    token
  ))
}
