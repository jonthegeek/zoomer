# Interactive OAuth authorization-code flow via local server

Starts a local HTTP server (via httpuv) to capture the OAuth redirect,
opens the browser for the user to authorize, and exchanges the returned
code for a token. The token is cached in-memory.

## Usage

``` r
.api_oauth_interactive(client, scopes, cache_key = NULL)
```

## Arguments

- client:

  A Zoom OAuth client created with
  [`zoom_client()`](https://jonthegeek.github.io/zoomer/dev/reference/zoom_client.md).

- scopes:

  A character vector of allowed scopes, such as "recording:read".

- cache_key:

  If you are authenticating with multiple users using the same client,
  use this key to differentiate between those users.

## Value

An
[`httr2::oauth_token()`](https://httr2.r-lib.org/reference/oauth_token.html),
invisibly.

## Details

Zoom does not permit localhost redirect URIs, so a publicly reachable
relay (e.g. a Cloudflare Worker) must be registered as the redirect URL
in the Zoom app config. The relay reads the local port from the `state`
parameter (format `"{port}:{nonce}"`) and issues a 302 to
`http://localhost:{port}/callback`, where httpuv captures the code.
