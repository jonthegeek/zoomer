# Construct a Zoom OAuth client

Builds the OAuth client object for Zoom apis.

## Usage

``` r
zoom_client(
  client_id = Sys.getenv("ZOOM_CLIENT_ID"),
  client_secret = Sys.getenv("ZOOM_CLIENT_SECRET")
)
```

## Arguments

- client_id:

  A Zoom OAuth App client ID. We recommend you save it as an environment
  variable, `ZOOM_CLIENT_ID`.

- client_secret:

  A Zoom OAuth App client secret. We recommend you save it as an
  environment variable, `ZOOM_CLIENT_SECRET`.

## Value

A Zoom
[`httr2::oauth_client()`](https://httr2.r-lib.org/reference/oauth_client.html).

## Examples

``` r
zoom_client <- zoom_client()
```
