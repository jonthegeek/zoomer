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

#' Local OAuth redirect port
#'
#' Returns the local port for the httpuv redirect-capture server. Customize
#' via `options(zoom.redirect_port = <integer>)`. Default is `1410`. Must
#' match the port your Cloudflare Worker (or equivalent relay) forwards to.
#'
#' @return An integer scalar.
#' @keywords internal
.api_local_port <- function() {
  as.integer(getOption("zoom.redirect_port", 1410L))
}

#' OAuth relay URL registered with Zoom
#'
#' Returns the publicly reachable redirect URI registered in the Zoom app
#' config (e.g. a Cloudflare Worker URL). Set via
#' `options(zoom.redirect_url = "https://...")`. The relay must forward
#' incoming requests to `http://localhost:{port}/callback`, reading the port
#' from the `state` query parameter (format `"{port}:{nonce}"`).
#'
#' @return A character scalar URL, or an error if not configured.
#' @keywords internal
.api_relay_url <- function() {
  url <- getOption("zoom.redirect_url")
  if (is.null(url)) {
    cli::cli_abort(
      c(
        "No OAuth relay URL configured.",
        "i" = "Set {.code options(zoom.redirect_url = 'https://...')} in your {.file .Rprofile}.",
        "i" = "See {.fn zoom_browse_app_management} for setup instructions."
      ),
      class = "zoom_redirect_url_missing"
    )
  }
  url
}

#' Parse a URL query string into a named list
#'
#' @param qs A raw query string (with or without a leading `?`).
#' @return A named list of decoded key-value pairs.
#' @keywords internal
.parse_query_string <- function(qs) {
  qs <- sub("^[?]", "", qs %||% "")
  if (!nchar(qs)) {
    return(list())
  }
  pairs <- strsplit(qs, "&", fixed = TRUE)[[1L]]
  result <- list()
  for (pair in pairs) {
    kv <- strsplit(pair, "=", fixed = TRUE)[[1L]]
    if (length(kv) >= 1L) {
      key <- httpuv::decodeURIComponent(kv[[1L]])
      val <- if (length(kv) >= 2L) httpuv::decodeURIComponent(kv[[2L]]) else ""
      result[[key]] <- val
    }
  }
  result
}

#' Interactive OAuth authorization-code flow via local server
#'
#' Starts a local HTTP server (via httpuv) to capture the OAuth redirect,
#' opens the browser for the user to authorize, and exchanges the returned code
#' for a token. The token is cached in-memory.
#'
#' Zoom does not permit localhost redirect URIs, so a publicly reachable relay
#' (e.g. a Cloudflare Worker) must be registered as the redirect URL in the
#' Zoom app config. The relay reads the local port from the `state` parameter
#' (format `"{port}:{nonce}"`) and issues a 302 to
#' `http://localhost:{port}/callback`, where httpuv captures the code.
#'
#' @inheritParams .oauth-parameters
#' @return An [httr2::oauth_token()], invisibly.
#' @keywords internal
.api_oauth_interactive <- function(client, scopes, cache_key = NULL) {
  # nocov start
  port <- .api_local_port()
  relay_url <- .api_relay_url()

  # Encode the local port in the state so the relay knows where to forward.
  # Format: "{port}:{32-char nonce}". The nonce provides CSRF protection;
  # the port prefix is for relay routing only.
  nonce <- paste(sample(c(letters, LETTERS, 0:9), 32L, replace = TRUE), collapse = "")
  state_val <- paste0(port, ":", nonce)

  auth_url <- paste0(
    .api_authorization_url,
    "?response_type=code",
    "&client_id=", utils::URLencode(client$id, reserved = TRUE),
    "&redirect_uri=", utils::URLencode(relay_url, reserved = TRUE),
    "&scope=", utils::URLencode(scopes, reserved = TRUE),
    "&state=", utils::URLencode(state_val, reserved = TRUE)
  )

  code <- NULL

  server <- httpuv::startServer("127.0.0.1", port, list(
    call = function(req) {
      if (req$PATH_INFO == "/callback") {
        params <- .parse_query_string(req$QUERY_STRING)
        if (identical(params$state, state_val) && !is.null(params$code)) {
          code <<- params$code
          body <- paste0(
            "<!DOCTYPE html><html><body style='font-family:sans-serif;",
            "text-align:center;padding:3em'>",
            "<h1>\u2713 Authorization complete</h1>",
            "<p>You may close this tab and return to R.</p>",
            "</body></html>"
          )
        } else {
          body <- paste0(
            "<!DOCTYPE html><html><body style='font-family:sans-serif;",
            "text-align:center;padding:3em'>",
            "<h1>\u26a0 Authorization failed</h1>",
            "<p>State mismatch or missing code. Please try again.</p>",
            "</body></html>"
          )
        }
      } else {
        body <- ""
      }
      list(
        status = 200L,
        headers = list("Content-Type" = "text/html; charset=utf-8"),
        body = body
      )
    }
  ))
  on.exit(httpuv::stopServer(server), add = TRUE)

  cli::cli_inform("Opening browser for Zoom authorization\u2026")
  utils::browseURL(auth_url)
  cli::cli_inform(c(
    "i" = "Waiting for browser redirect (2 min timeout)\u2026",
    "i" = "Press {.kbd Ctrl+C} to cancel."
  ))

  deadline <- Sys.time() + 120
  while (is.null(code) && Sys.time() < deadline) {
    httpuv::service(100L)
  }

  if (is.null(code)) {
    cli::cli_abort("Authorization timed out.", class = "zoom_auth_timeout")
  }

  # The redirect_uri in the token exchange must match what was sent to Zoom.
  resp <- httr2::request(.api_token_url) |>
    httr2::req_auth_basic(client$id, client$secret) |>
    httr2::req_body_form(
      grant_type = "authorization_code",
      code = code,
      redirect_uri = relay_url
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  token <- httr2::oauth_token(
    access_token = resp$access_token,
    token_type = resp[["token_type"]] %||% "bearer",
    expires_in = resp[["expires_in"]],
    refresh_token = resp[["refresh_token"]]
  )

  the[[rlang::hash(c(client$name, cache_key))]] <- token
  return(invisible(token))
  # nocov end
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
    token <- .api_oauth_interactive(client, scopes, cache_key = cache_key)
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

  token <- .api_get_token_noninteractive(client, cache_key = cache_key)
  if (!is.null(token)) {
    return(httr2::req_auth_bearer_token(request, token$access_token))
  }

  if (!rlang::is_interactive()) {
    cli::cli_abort(
      c(
        "No token found and session is non-interactive.",
        "i" = "Call {.fn zoom_authenticate} before starting your script.",
        "i" = "Or pass a {.arg token} directly."
      ),
      class = "zoom_auth_required"
    )
  }

  scopes <- .chr2csv(scopes)
  token <- .api_oauth_interactive(client, scopes, cache_key = cache_key)
  return(httr2::req_auth_bearer_token(request, token$access_token))
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
