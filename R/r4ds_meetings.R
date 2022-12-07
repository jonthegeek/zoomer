`%>%` <- magrittr::`%>%`

client <- httr2::oauth_client(
  id = "sKSC6UBCRp6SZYkhgkgfRg",
  token_url = "https://zoom.us/oauth/token",
  secret = httr2::obfuscated("mBFA8vzO10cIm-ia9_tURe5INxPuoawppQqaBM-JIacjN5y0vROTkbiaZV9NJLRu")
)

token <- httr2::oauth_flow_auth_code(
  client = client,
  auth_url = "https://zoom.us/oauth/authorize",
  port = 8546L,
  scope = "recording:read",
  pkce = FALSE
)

all_recordings <- httr2::request(
  "https://api.zoom.us/v2/users/yntI9xIgSRCk0LvDdaAtIg/recordings"
) %>%
  httr2::req_auth_bearer_token(token$access_token) %>%
  httr2::req_url_query(from = "2022-12-01") %>%
  httr2::req_perform() %>%
  httr2::resp_body_json()

if (length(all_recordings$meetings)) {
  old_timeout <- options(timeout = 1000)
  for (meeting_num in seq_along(all_recordings$meetings)) {
    for (
      file_num in seq_along(
        all_recordings$meetings[[meeting_num]]$recording_files
      )
    ) {
      httr2::request(
        all_recordings$meetings[[meeting_num]]$recording_files[[file_num]]$download_url
      ) %>%
        httr2::req_auth_bearer_token(token$access_token) %>%
        httr2::req_perform() %>%
        httr2::resp_body_raw() %>%
        writeBin(
          con = fs::path_home(
            "Downloads",
            paste(
              all_recordings$meetings[[meeting_num]]$topic,
              lubridate::date(
                lubridate::with_tz(
                  lubridate::ymd_hms(
                    all_recordings$meetings[[meeting_num]]$start_time
                  ),
                  "America/Chicago"
                )
              ),
              sep = "_"
            ),
            ext = tolower(
              all_recordings$meetings[[meeting_num]]$recording_files[[file_num]]$file_extension
            )
          )
        )
    }
  }

  # THEN delete the recordings. Ideally we'd delete as we go, but the API
  # appears to delete all recordings for a given meeting at once even though
  # they're separate in the recording list.
  for (meeting_num in seq_along(all_recordings$meetings)) {
    # Delete that meeting's recordings.
    httr2::request("https://api.zoom.us/v2/") %>%
      httr2::req_url_path_append(
        "meetings",
        all_recordings$meetings[[meeting_num]]$uuid,
        "recordings"
      ) %>%
      httr2::req_method("DELETE") %>%
      httr2::req_auth_bearer_token(token$access_token) %>%
      httr2::req_perform()
  }
  options(old_timeout)
}
