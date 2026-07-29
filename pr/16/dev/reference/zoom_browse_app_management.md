# Visit Zoom Created Apps

Launch the Zoom "Created Apps" page (where you can configure OAuth 2.0
Clients). Navigate to "Develop \> Build App" if you don't have an app,
and choose "OAuth".

## Usage

``` r
zoom_browse_app_management()
```

## Value

The url of the "Created Apps" page, invisibly.

## Details

**One-time relay setup** (Zoom no longer accepts localhost redirect
URIs):

1.  Create a [Cloudflare Worker](https://workers.cloudflare.com/) using
    the script in
    `system.file("cloudflare/oauth-relay.js", package = "zoomer")`. The
    Worker reads the local port from the OAuth `state` parameter and
    issues a `302` redirect to `http://localhost:{port}/callback`.

2.  Set the Zoom app's **OAuth Redirect URL** to your Worker's URL (e.g.
    `https://zoomer-oauth.your-handle.workers.dev/callback`).

3.  Add `options(zoom.redirect_url = "https://...")` to your
    `.Rprofile`. Optionally set `options(zoom.redirect_port = 1410L)` if
    you need a non-default local port.

After configuring your app, copy/paste the Client ID and Client Secret
into the `ZOOM_CLIENT_ID` and `ZOOM_CLIENT_SECRET` environment
variables. We recommend placing these in your `.Renviron` file.

## Examples

``` r
zoom_app_mgmt_url <- zoom_browse_app_management()
# Copy/paste values from your client.
Sys.setenv(ZOOM_CLIENT_ID = "raNdOMletTeRS")
Sys.setenv(ZOOM_CLIENT_SECRET = "RanDomleTTerSandNumb3rs")
```
