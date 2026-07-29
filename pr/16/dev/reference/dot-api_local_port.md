# Local OAuth redirect port

Returns the local port for the httpuv redirect-capture server. Customize
via `options(zoom.redirect_port = <integer>)`. Default is `1410`. Must
match the port your Cloudflare Worker (or equivalent relay) forwards to.

## Usage

``` r
.api_local_port()
```

## Value

An integer scalar.
