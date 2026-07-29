# Construct an OAuth client

Construct an OAuth client

## Usage

``` r
.api_client(client_id = "", client_secret = "")
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
