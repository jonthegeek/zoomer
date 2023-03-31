library(httr2)
library(fs)
library(lubridate)
library(stringr)

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
) |>
  httr2::req_auth_bearer_token(token$access_token) |>
  httr2::req_url_query(from = "2023-01-01") |>
  httr2::req_perform() |>
  httr2::resp_body_json()

if (length(all_recordings$meetings)) {
  old_timeout <- options(timeout = 1000)
  for (meeting_num in seq_along(all_recordings$meetings)) {
    this_meeting <- all_recordings$meetings[[meeting_num]]
    this_meeting$ready_to_delete <- rep(
      FALSE, length(this_meeting$recording_files)
    )
    for (file_num in seq_along(this_meeting$recording_files)) {
      this_file <- this_meeting$recording_files[[file_num]]
      if (this_file$status == "completed") {
        # if (this_file$file_size > 490000000) {
        #   message("File too large!")
        #   next
        # }

        httr2::request(this_file$download_url) |>
          httr2::req_auth_bearer_token(token$access_token) |>
          httr2::req_perform() |>
          httr2::resp_body_raw() |>
          writeBin(
            con = fs::path_home(
              "Downloads",
              paste(
                this_meeting$topic,
                lubridate::date(
                  lubridate::with_tz(
                    lubridate::ymd_hms(
                      this_meeting$start_time
                    ),
                    "America/Chicago"
                  )
                ),
                stringr::str_pad(meeting_num, 2, pad = "0"),
                stringr::str_pad(file_num, 2, pad = "0"),
                sep = "_"
              ),
              ext = tolower(this_file$file_extension)
            )
          )
        this_meeting$ready_to_delete[[file_num]] <- TRUE
      }
    }

    if (all(this_meeting$ready_to_delete)) {
      # Delete the recording for this meeting.
      httr2::request("https://api.zoom.us/v2/") |>
        httr2::req_url_path_append("meetings", this_meeting$uuid, "recordings") |>
        httr2::req_method("DELETE") |>
        httr2::req_auth_bearer_token(token$access_token) |>
        httr2::req_perform()
    } else {
      message("This meeting isn't ready yet!")
    }
  }
  options(old_timeout)
}
