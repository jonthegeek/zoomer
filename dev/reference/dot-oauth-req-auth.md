# OAuth request authentication documentation

OAuth request authentication documentation

## Arguments

- token:

  A Zoom API OAuth token, or the `access_token` string from such a
  token. We recommend that you instead supply a `client`, in which case
  an appropriate token will be located if possible.

## Value

An [`httr2::request()`](https://httr2.r-lib.org/reference/request.html)
with Zoom OAuth authentication information.
