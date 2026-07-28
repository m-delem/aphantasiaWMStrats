#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom grDevices palette.colors
#' @importFrom rlang .data
## usethis namespace: end
NULL

.onAttach <- function(libname, pkgname) {
  packageStartupMessage(glue::glue_col(
    "{blue
    Welcome to {green aphantasiaWMStrats}.
    }
    ",
    .literal = TRUE))
}

# To avoid check NOTE on package sub-dependencies not called
ignore_unused_imports <- function() {
  crayon::underline # for glue_col
  rlang::expr
  dplyr::mutate
  stringr::str_detect
  return(NULL)
}
