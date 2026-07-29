# Authenticate a request with OAuth2.0

Authenticate a request with OAuth2.0

## Usage

``` r
.api_req_authenticate(request, client, scopes, cache_disk, cache_key, token)
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
