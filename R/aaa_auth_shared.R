# These are functions that are sharable outside of zoomer, or will be with minor
# edits. I think I'll set them up to work with usethis::use_standalone(), and
# then the default behavior will be to copy them into the package for
# customization. That way they can take advantage of shared parameter definition
# tweaks.

#' Visit an OAuth client management page
#'
#' @param app_mgmt_url The page where the client can be managed.
#' @return The `app_mgmt_url`, invisibly.
#' @keywords internal
.api_browse_oauth_app <- function(app_mgmt_url) {
  if (rlang::is_interactive()) { # nocov start
    utils::browseURL(app_mgmt_url)
  } # nocov end
  return(invisible(app_mgmt_url))
}

#' Construct an OAuth client
#'
#' @inheritParams .oauth-parameters
#' @inherit .oauth-client return
#' @keywords internal
.api_client <- function(client_id = "", client_secret = "") {
  if (!nchar(client_id) || !nchar(client_secret)) {
    cli::cli_abort(
      "Please provide a {.arg client_id} and {.arg client_secret}.",
      class = "missing_client_params"
    )
  }
  return(
    httr2::oauth_client(
      id = client_id,
      token_url = .api_token_url,
      secret = client_secret,
      auth = "header"
    )
  )
}

#' Authenticate with an API
#'
#' @inheritParams .oauth-parameters
#' @inherit .oauth-token return
#' @keywords internal
.api_authenticate <- function(client, cache_key, scopes, force, refresh_token) {
  # nocov start

  # I only need/use this in zoom_authenticate, which I'm questioning and might
  # delete. I'll test this completely in youtubeR and/or its own package.
  if (force) {
    if (is.null(refresh_token)) {
      token <- NULL
    } else {
      token <- .refresh_oauth_token(
        client,
        cache_key = cache_key,
        refresh_token = refresh_token
      )
    }
  } else {
    # This tries everything that we can try without bugging the user.
    token <- .api_get_token_noninteractive(
      client,
      cache_key = cache_key,
      refresh_token = refresh_token
    )
  }

  if (rlang::is_interactive() && is.null(token)) {
    scopes <- .chr2csv(scopes)
    token <- httr2::oauth_flow_auth_code(
      client = client,
      auth_url = .api_authorization_url,
      scope = scopes,
      redirect_uri = paste0(httr2::oauth_redirect_uri(), ":8888")
    )
  }

  the[[rlang::hash(c(client$name, cache_key))]] <- token
  return(invisible(token))
  # nocov end
}

#' Authenticate a request with OAuth2.0
#'
#' @inheritParams .oauth-req-auth
#' @inheritParams .oauth-parameters
#' @inherit .oauth-req-auth return
#' @keywords internal
.api_req_authenticate <- function(request,
                                  client,
                                  scopes,
                                  cache_disk,
                                  cache_key,
                                  token) {
  if (!is.null(token)) {
    if (inherits(token, "httr2_token")) {
      if (!.api_token_is_expired(token)) {
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
    token <- .api_get_token_noninteractive(client, cache_key = cache_key)
    if (!is.null(token)) {
      return(httr2::req_auth_bearer_token(request, token$access_token))
    }
  }

  scopes <- .chr2csv(scopes)

  return(
    httr2::req_oauth_auth_code(
      req = request,
      client = client,
      auth_url = .api_authorization_url,
      scope = scopes,
      cache_disk = cache_disk,
      cache_key = cache_key,
      pkce = FALSE,
      redirect_uri = paste0(httr2::oauth_redirect_uri(), ":8888")
    )
  )
}

#' Is a token expired?
#'
#' @inheritParams .oauth-parameters
#' @return A logical scalar indicating whether the token is expired.
#' @keywords internal
.api_token_is_expired <- function(token) {
  return(token[["expires_at"]] < as.integer(Sys.time()))
}

#' Retrieve an OAuth token if possible
#'
#' @inheritParams .oauth-parameters
#' @inherit .oauth-token return
#' @keywords internal
.api_get_token_noninteractive <- function(client,
                                          cache_key = NULL,
                                          refresh_token = NULL) {
  # For the shared version: take an argument "pkg", then `the <-
  # rlang::pkg_env(pkg)$the`` and refer to that the everywhere that I have
  # `the`.

  key <- rlang::hash(c(client$name, cache_key))
  if (!is.null(the[[key]]) && !.api_token_is_expired(the[[key]])) {
    return(the[[key]])
  }

  return(
    .refresh_oauth_token(
      client,
      cache_key = cache_key,
      refresh_token = refresh_token
    )
  )
}

#' Find and use a refresh token
#'
#' @inheritParams .oauth-parameters
#' @inherit .oauth-token return
#' @keywords internal
.refresh_oauth_token <- function(client,
                                 cache_key = NULL,
                                 refresh_token = NULL) {
  # For the shared version: take an argument "pkg", then the <-
  # rlang::pkg_env(pkg)$the and refer to that the everywhere that I have `the`.
  # I'll also need the name of the envvar as an arg, or maybe set it from the
  # package name. And of course .hack_refresh should be dealt with so we don't
  # have to do the hack.

  key <- rlang::hash(c(client$name, cache_key))
  refresh_token <- refresh_token %||%
    the[[key]]$refresh_token %||%
    Sys.getenv("ZOOM_REFRESH_TOKEN")
  if (nchar(refresh_token)) {
    the[[key]] <- suppressWarnings(
      httr2::oauth_flow_refresh(client, refresh_token)
    )
    return(the[[key]])
  }
  return(NULL)
}
