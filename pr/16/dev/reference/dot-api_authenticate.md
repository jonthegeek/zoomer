# Authenticate with an API

Authenticate with an API

## Usage

``` r
.api_authenticate(client, cache_key, scopes, force, refresh_token)
```

## Arguments

- client:

  A Zoom OAuth client created with
  [`zoom_client()`](https://jonthegeek.github.io/zoomer/dev/reference/zoom_client.md).

- cache_key:

  If you are authenticating with multiple users using the same client,
  use this key to differentiate between those users.

- scopes:

  A character vector of allowed scopes, such as "recording:read".

- force:

  A logical indicating whether to force a refresh of the token.

- refresh_token:

  A refresh token associated with this `client`.

## Value

A Zoom
[`httr2::oauth_token()`](https://httr2.r-lib.org/reference/oauth_token.html),
invisibly.
