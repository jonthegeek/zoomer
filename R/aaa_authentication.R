# Sharable ---------------------------------------------------------------------

.is_expired <- function(expiration_ts) {
  return(
    expiration_ts < as.integer(Sys.time())
  )
}

.get_token_noninteractive <- function(client, refresh_token = NULL) {
  # For the shared version: take an argument "pkg", then `the <-
  # rlang::pkg_env(pkg)$the`` and refer to that the everywhere that I have
  # `the`.

  key <- rlang::hash(client)
  if (!is.null(the[[key]])) {
    if (!.is_expired(the[[key]]$expires_at)) {
      return(the[[key]])
    }
  }

  return(.refresh_oauth_token(client, refresh_token = refresh_token))
}

.refresh_oauth_token <- function(client, refresh_token = NULL) {
  # For the shared version: take an argument "pkg", then the <-
  # rlang::pkg_env(pkg)$the and refer to that the everywhere that I have the.
  # I'll also need the name of the envvar as an arg, or maybe set it from the
  # package name.

  refresh_token <- refresh_token %||%
    the[[rlang::hash(client)]]$refresh_token %||%
    Sys.getenv("ZOOM_REFRESH_TOKEN")
  if (nchar(refresh_token)) {
    # Hopefully it's only temporary that I need to use the hacked version of
    # this.
    return(.hack_refresh(client, refresh_token))
  }
  return(NULL)
}

.browse_oauth_app <- function(app_mgmt_url) {
  if (rlang::is_interactive()) { # nocov start
    utils::browseURL(app_mgmt_url)
  } # nocov end
  return(invisible(app_mgmt_url))
}

#' Smush a string to a comma-separated list
#'
#' @param string A character vector to smush.
#'
#' @return A character scalar like "this,that".
#' @keywords internal
.str2csv <- function(string) {
  return(paste(string, collapse = ","))
}

# Customized -------------------------------------------------------------------

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
#'
#' @examples
#' zoom_app_mgmt_url <- browse_zoom_app_management()
#' # Copy/paste values from your client.
#' Sys.setenv(ZOOM_CLIENT_ID = "raNdOMletTeRS")
#' Sys.setenv(ZOOM_CLIENT_SECRET = "RanDomleTTerSandNumb3rs")
browse_zoom_app_management <- function() {
  return(.browse_oauth_app(.zoom_oauth_app_url))
}

#' Construct a Zoom OAuth client
#'
#' Builds the OAuth client object for Zoom apis.
#'
#' @param client_id A Zoom OAuth App client ID. We recommend you save it as an
#'   environment variable, `ZOOM_CLIENT_ID`.
#' @param client_secret A Zoom OAuth App client secret. We recommend you save it
#'   as an environment variable, `ZOOM_CLIENT_SECRET`.
#'
#' @return An [httr2::oauth_client()] object.
#' @export
#'
#' @examples
#' zoom_client <- zoom_client()
zoom_client <- function(client_id = Sys.getenv("ZOOM_CLIENT_ID"),
                        client_secret = Sys.getenv("ZOOM_CLIENT_SECRET")) {
  return(
    httr2::oauth_client(
      id = client_id,
      token_url = .zoom_token_url,
      secret = client_secret,
      auth = "header",
      name = "zoom_rest_api"
    )
  )
}

#' Authenticate with a Zoom OAuth client
#'
#' Load or generate a Zoom OAuth token for use in the other functions in
#' this package. The primary use of this function is to cache values early in a
#' script (so the user can walk away). Otherwise the other functions in this
#' package will prompt for authentication when needed. Once the values are
#' cached, the rest of this package will use them by default for that client.
#'
#' @param client A Zoom OAuth client created with [zoom_client()].
#' @param scopes A character vector of allowed scopes, such as "recording:read".
#' @param force A logical indicating whether to force a refresh of the token.
#' @param refresh_token A refresh token associated with this `client`. This
#'   parameter exists primarily for testing. If you wish to provide a refresh
#'   token (for example, for automated processes), we recommend setting a
#'   `ZOOM_REFRESH_TOKEN` environment variable.
#'
#' @return A Zoom OAuth token, invisibly.
#' @export
zoom_authenticate <- function(client = zoom_client(),
                              scopes = "recording:read",
                              force = FALSE,
                              refresh_token = NULL) {
  # TODO: Add caching of refresh tokens. Use httr2's caching as inspiration.
  if (force) {
    if (is.null(refresh_token)) {
      token <- NULL
    } else {
      token <- .refresh_oauth_token(client, refresh_token)
    }
  } else {
    # This tries everything that we can try without bugging the user.
    token <- .get_token_noninteractive(client, refresh_token)
  }

  # Long-term we might need to mock this for testing.
  if (rlang::is_interactive() && is.null(token)) { # nocov start
    scopes <- .str2csv(scopes)
    token <- httr2::oauth_flow_auth_code(
      client = client,
      auth_url = .zoom_auth_url,
      scope = scopes,
      port = 8888L
    )

    the[[rlang::hash(client)]] <- token
  } # nocov end

  return(invisible(token))
}

#' Zoom OAuth authentication
#'
#' This function is the main way authentication is handled in this package. It
#' tries to find a token non-interactively if possible, but bothers the user if
#' necessary.
#'
#' @inheritParams zoom_authenticate
#' @inheritParams httr2::req_oauth_auth_code
#' @param request A [httr2::request()].
#' @param cache_key If you are authenticating with multiple users using the same
#'   client, use this key to differentiate between those users.
#' @param token A Zoom API OAuth token, or the `access_token` string from such a
#'   token. We recommend that you instead supply a `client`, in which case an
#'   appropriate token will be located if possible.
#'
#' @return A [httr2::request()] with oauth authentication information.
#' @keywords internal
.zoom_req_auth <- function(request,
                           client = zoom_client(),
                           scopes = "recording:read",
                           cache_disk = getOption("zoom.cache_disk", FALSE),
                           cache_key = getOption("zoom.cache_key", NULL),
                           token = NULL) {
  if (!is.null(token)) {
    if (inherits(token, "httr2_token")) {
      if (!.is_expired(token[["expires_at"]])) {
        return(httr2::req_auth_bearer_token(request, token[["access_token"]]))
      }
    } else {
      return(httr2::req_auth_bearer_token(request, token))
    }
  }

  # If cache_disk is TRUE, we need to let httr2 deal with things; we can't dig
  # into that cache without digging into unexported httr2 functions (and thus
  # implementation might change).
  if (!cache_disk) {
    token <- .get_token_noninteractive(client)
    if (!is.null(token)) {
      return(httr2::req_auth_bearer_token(request, token$access_token))
    }
  }

  scopes <- .str2csv(scopes)

  return(
    httr2::req_oauth_auth_code(
      req = request,
      client = client,
      auth_url = .zoom_auth_url,
      scope = scopes,
      cache_disk = cache_disk,
      cache_key = cache_key,
      pkce = FALSE,
      port = 8888L
    )
  )
}

#' Hack oauth_flow_refresh for revolving refresh_token
#'
#' This is a (hopefully) temporary hack to trick [httr2::oauth_flow_refresh()]
#' into allowing us to refresh even when the refresh token changes.
#'
#' @param client A Zoom OAuth client created with [zoom_client()].
#' @param refresh_token A refresh token. The default behavior is to look in a
#'   `ZOOM_REFRESH_TOKEN` environment variable.
#'
#' @return An [httr2::oauth_token()].
#' @keywords internal
.hack_refresh <- function(client = zoom_client(),
                          refresh_token = Sys.getenv("ZOOM_REFRESH_TOKEN")) {
  fn <- httr2::oauth_flow_refresh

  line_4_check <- as.character(rlang::fn_body(fn)[[4]])
  line_4_expected <- c(
    "if",
    "!is.null(token$refresh_token) && token$refresh_token != refresh_token",
    "{\n    abort(\"Refresh token has changed! Please update stored value\")\n}"
  )
  if (!all(line_4_check == line_4_expected)) {
    cli::cli_abort("httr2::oauth_flow_refresh has changed.")
  }

  rlang::fn_body(fn)[[4]] <- NULL
  return(
    fn(
      client = client,
      refresh_token = refresh_token
    )
  )
}
