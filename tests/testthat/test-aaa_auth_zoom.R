test_that("zoom_browse_app_management returns the expected url", {
  # Force non-interactive mode for easier interactive testing.
  rlang::local_interactive(FALSE)

  expect_identical(
    zoom_browse_app_management(),
    "https://marketplace.zoom.us/user/build"
  )
})

test_that("zoom_client constructs a client", {
  expect_snapshot({zoom_client("a", "b")})
  withr::local_envvar(
    ZOOM_CLIENT_ID = "an_id",
    ZOOM_CLIENT_SECRET = "a_secret"
  )
  expect_snapshot({zoom_client()})
})

test_that("zoom_client errors as expected", {
  expect_error(
    zoom_client("", ""),
    class = "missing_client_params"
  )

  withr::local_envvar(
    ZOOM_CLIENT_ID = NA,
    ZOOM_CLIENT_SECRET = NA
  )
  expect_error(
    zoom_client(),
    class = "missing_client_params"
  )
})

test_that(".zoom_req_authenticate adds the expected decorations", {
  # We'll test actual requests separately; this just check that a request gets
  # decorated as expected, without actually performing the request.
  expect_snapshot({
    .zoom_req_authenticate(
      httr2::request("fakeurl"),
      client = zoom_client("a", "b"),
      scopes = "recording:read",
      cache_disk = FALSE,
      cache_key = FALSE
    )
  })
  expect_snapshot({
    .zoom_req_authenticate(
      httr2::request("fakeurl"),
      client = zoom_client("a", "b"),
      scopes = "recording:read",
      cache_disk = FALSE,
      cache_key = FALSE,
      token = "a_fake_token"
    )
  })
  expect_snapshot({
    .zoom_req_authenticate(
      httr2::request("fakeurl"),
      client = zoom_client("a", "b"),
      scopes = "recording:read",
      cache_disk = FALSE,
      cache_key = FALSE,
      token = httr2::oauth_token(
        "a_fake_token",
        # Make it last a long time so it effectively never expires, but can
        # still be checked.
        expires_in = 1e10,
        .date = as.POSIXct(
          1672531200,
          tz = "UTC",
          origin = "1970-01-01 00:00.00 UTC"
        )
      )
    )
  })
})
