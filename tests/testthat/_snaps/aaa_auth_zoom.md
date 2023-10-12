# zoom_client constructs a client

    Code
      zoom_client("a", "b")
    Message
      <httr2_oauth_client>
      name: 4d52a7da68952b85f039e85a90f9bbd2
      id: a
      secret: <REDACTED>
      token_url: https://zoom.us/oauth/token
      auth: oauth_client_req_auth_header

---

    Code
      zoom_client()
    Message
      <httr2_oauth_client>
      name: 35b8999c5d14ef946a5b6a038ea958cd
      id: an_id
      secret: <REDACTED>
      token_url: https://zoom.us/oauth/token
      auth: oauth_client_req_auth_header

# .zoom_req_authenticate adds decorations w/o token

    Code
      .zoom_req_authenticate(httr2::request("fakeurl"), client = zoom_client("a", "b"),
      scopes = "recording:read", cache_disk = FALSE, cache_key = FALSE)
    Message
      <httr2_request>
      GET fakeurl
      Body: empty
      Policies:
      * auth_oauth: a list

# .zoom_req_authenticate adds decorations w/ simple token

    Code
      .zoom_req_authenticate(httr2::request("fakeurl"), client = zoom_client("a", "b"),
      scopes = "recording:read", cache_disk = FALSE, cache_key = FALSE, token = "a_fake_token")
    Message
      <httr2_request>
      GET fakeurl
      Headers:
      * Authorization: '<REDACTED>'
      Body: empty

# .zoom_req_authenticate adds decorations w/ full token

    Code
      .zoom_req_authenticate(httr2::request("fakeurl"), client = zoom_client("a", "b"),
      scopes = "recording:read", cache_disk = FALSE, cache_key = FALSE, token = httr2::oauth_token(
        "a_fake_token", expires_in = 1e+10, .date = as.POSIXct(1672531200, tz = "UTC",
          origin = "1970-01-01 00:00.00 UTC")))
    Message
      <httr2_request>
      GET fakeurl
      Headers:
      * Authorization: '<REDACTED>'
      Body: empty

