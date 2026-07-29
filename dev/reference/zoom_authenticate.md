# Authenticate with a Zoom OAuth client

**\[questioning\]**

Load or generate a Zoom OAuth token for use in the other functions in
this package. The primary use of this function is to cache values early
in a script (so the user can walk away). Otherwise the other functions
in this package will prompt for authentication when needed. Once the
values are cached, the rest of this package will use them by default for
that client.

## Usage

``` r
zoom_authenticate(
  client = zoom_client(),
  cache_key = getOption("zoom.cache_key", NULL),
  scopes = "recording:read",
  force = FALSE,
  refresh_token = NULL
)
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
