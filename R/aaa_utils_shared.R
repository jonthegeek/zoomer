#' Character vector to comma-separated values
#'
#' Collapse a character vector to comma-separate values.
#'
#' @param x A character vector to collapse.
#' @return A character scalar like "this,that".
#' @keywords internal
.chr2csv <- function(x) {
  return(paste(x[!is.na(x)], collapse = ","))
}
