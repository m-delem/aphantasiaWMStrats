#' Get CFA-WM data, optionally filtered by version
#'
#' Convenience accessor for [all_data]. Returns the full combined dataset by
#' default, or a subset restricted to one or more study versions.
#'
#' @param version Character vector. One or more of `"v1"`, `"v2"`, `"v3"`,
#'   or `"all"` (the default). `"all"` is equivalent to
#'   `c("v1", "v2", "v3")` and cannot be combined with the others.
#' @param data Internal. The data frame to filter; defaults to [all_data]
#'   and is not meant to be set by end users. Exposed as an argument (rather
#'   than referencing [all_data] directly in the function body) so the
#'   filtering/validation logic can be tested against a small synthetic
#'   stand-in without touching the real package data.
#'
#' @return A tibble with the same columns as [all_data], filtered to the
#'   requested version(s).
#'
#' @examples
#' get_data()
#' get_data(version = "v3")
#' get_data(version = c("v1", "v2"))
#'
#' @export
get_data <- function(version = "all", data = all_data) {
  valid_versions <- c("v1", "v2", "v3")

  if (!is.character(version) || length(version) == 0) {
    stop(
      "`version` must be a character vector containing \"all\" or one or ",
      "more of ", paste(dQuote(valid_versions, q = FALSE), collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  if ("all" %in% version) {
    if (length(version) > 1) {
      stop(
        "`version = \"all\"` cannot be combined with specific versions. ",
        "Use either `version = \"all\"` or a subset of ",
        paste(dQuote(valid_versions, q = FALSE), collapse = ", "), ".",
        call. = FALSE
      )
    }
    version <- valid_versions
  }

  unknown <- setdiff(version, valid_versions)
  if (length(unknown) > 0) {
    stop(
      "Unrecognised version", if (length(unknown) > 1) "s" else "", ": ",
      paste(dQuote(unknown, q = FALSE), collapse = ", "),
      ". `version` must be \"all\" or one or more of ",
      paste(dQuote(valid_versions, q = FALSE), collapse = ", "), ".",
      call. = FALSE
    )
  }

  output <- data |> dplyr::filter(.data$version %in% !!version)

  return(output)
}
