# OAuth parameters

These parameters are used in multiple authentication functions. Define
them here so they're consistent.

## Arguments

- cache_disk:

  Deprecated; no longer used. Token caching is handled in-memory via the
  package environment. Kept for backward compatibility.

- cache_key:

  If you are authenticating with multiple users using the same client,
  use this key to differentiate between those users.

- client:

  A Zoom OAuth client created with
  [`zoom_client()`](https://jonthegeek.github.io/zoomer/dev/reference/zoom_client.md).

- client_id:

  A Zoom OAuth App client ID. We recommend you save it as an environment
  variable, `ZOOM_CLIENT_ID`.

- client_secret:

  A Zoom OAuth App client secret. We recommend you save it as an
  environment variable, `ZOOM_CLIENT_SECRET`.

- force:

  A logical indicating whether to force a refresh of the token.

- refresh_token:

  A refresh token associated with this `client`.

- request:

  A
  [`httr2::request()`](https://httr2.r-lib.org/reference/request.html).

- scopes:

  A character vector of allowed scopes, such as "recording:read".

- token:

  An Zoom API
  [`httr2::oauth_token()`](https://httr2.r-lib.org/reference/oauth_token.html).
