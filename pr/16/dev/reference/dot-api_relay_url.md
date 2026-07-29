# OAuth relay URL registered with Zoom

Returns the publicly reachable redirect URI registered in the Zoom app
config (e.g. a Cloudflare Worker URL). Set via
`options(zoom.redirect_url = "https://...")`. The relay must forward
incoming requests to `http://localhost:{port}/callback`, reading the
port from the `state` query parameter (format `"{port}:{nonce}"`).

## Usage

``` r
.api_relay_url()
```

## Value

A character scalar URL, or an error if not configured.
