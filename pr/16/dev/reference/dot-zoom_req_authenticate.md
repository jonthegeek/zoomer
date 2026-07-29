# Zoom request OAuth authentication

This function is the main way authentication is handled in this package.
It tries to find a token non-interactively if possible, but bothers the
user if necessary.

## Usage

``` r
.zoom_req_authenticate(
  request,
  client = zoom_client(),
  scopes = "recording:read",
  cache_disk = getOption("zoom.cache_disk", FALSE),
  cache_key = getOption("zoom.cache_key", NULL),
  token = NULL
)
```

## Arguments

- request:

  A
  [`httr2::request()`](https://httr2.r-lib.org/reference/request.html).

- client:

  A Zoom OAuth client created with
  [`zoom_client()`](https://jonthegeek.github.io/zoomer/dev/reference/zoom_client.md).

- scopes:

  A character vector of allowed scopes, such as "recording:read".

- cache_disk:

  Deprecated; no longer used. Token caching is handled in-memory via the
  package environment. Kept for backward compatibility.

- cache_key:

  If you are authenticating with multiple users using the same client,
  use this key to differentiate between those users.

- token:

  A Zoom API OAuth token, or the `access_token` string from such a
  token. We recommend that you instead supply a `client`, in which case
  an appropriate token will be located if possible.

## Value

An [`httr2::request()`](https://httr2.r-lib.org/reference/request.html)
with Zoom OAuth authentication information.
