# zoom_client constructs a client

    Code
      zoom_client("a", "b")
    Output
      <httr2_oauth_client>
      * name     : "345dd027121de1e3ec3a99ef06844d61"
      * id       : "a"
      * secret   : <REDACTED>
      * token_url: "https://zoom.us/oauth/token"
      * auth     : "oauth_client_req_auth_header"

---

    Code
      zoom_client()
    Output
      <httr2_oauth_client>
      * name     : "7e62dff099691f36ae37acb8087b75c9"
      * id       : "an_id"
      * secret   : <REDACTED>
      * token_url: "https://zoom.us/oauth/token"
      * auth     : "oauth_client_req_auth_header"

# .zoom_req_authenticate adds decorations w/ simple token

    Code
      .zoom_req_authenticate(httr2::request("fakeurl"), client = zoom_client("a", "b"),
      scopes = "recording:read", cache_disk = FALSE, cache_key = FALSE, token = "a_fake_token")
    Output
      <httr2_request>
      GET fakeurl
      Headers:
      * Authorization: <REDACTED>
      Body: empty

# .zoom_req_authenticate adds decorations w/ full token

    Code
      .zoom_req_authenticate(httr2::request("fakeurl"), client = zoom_client("a", "b"),
      scopes = "recording:read", cache_disk = FALSE, cache_key = FALSE, token = httr2::oauth_token(
        "a_fake_token", expires_in = 1e+10, .date = as.POSIXct(1672531200, tz = "UTC",
          origin = "1970-01-01 00:00.00 UTC")))
    Output
      <httr2_request>
      GET fakeurl
      Headers:
      * Authorization: <REDACTED>
      Body: empty

