# Retrieve an OAuth token if possible

Retrieve an OAuth token if possible

## Usage

``` r
.api_get_token_noninteractive(client, cache_key = NULL, refresh_token = NULL)
```

## Arguments

- client:

  A Zoom OAuth client created with
  [`zoom_client()`](https://jonthegeek.github.io/zoomer/dev/reference/zoom_client.md).

- cache_key:

  If you are authenticating with multiple users using the same client,
  use this key to differentiate between those users.

- refresh_token:

  A refresh token associated with this `client`.

## Value

A Zoom
[`httr2::oauth_token()`](https://httr2.r-lib.org/reference/oauth_token.html),
invisibly.
