#' Minimum responded trials per feature
#'
#' @description
#' A participant contributes to a feature only if the standard error of
#' their mean is at most half the between-person SD. That criterion needs 22
#' responded trials for orientation and 29 for colour. For word it asks for
#' 93 of the 63 trials that exist, because word's between-person variance is
#' small relative to its trial-level noise, so word falls back to a floor of
#' 32 responded trials. That floor is a data-sufficiency rule and **not** a
#' precision guarantee: no achievable trial count makes a participant's word
#' mean precise enough to rank against another's.
#'
#' Hard-coded rather than recomputed, because the rule was fixed before any
#' contact with VVIQ and must not drift with the sample it is applied to.
#'
#' @returns A named integer vector, one threshold per feature.
#' @export
wm_thresholds <- function() {
  c(word = 32L, angle = 22L, color = 29L)
}

#' Participants clearing the engagement thresholds
#'
#' @param data Item-level data, typically `get_data("v1")` filtered to the
#'   test blocks.
#' @param thresholds Named integer vector, defaults to [wm_thresholds()].
#'
#' @returns A character vector of participant ids clearing every threshold.
#' @export
engaged_ids <- function(data, thresholds = wm_thresholds()) {
  counts <-
    data |>
    dplyr::summarise(
      dplyr::across(
        tidyselect::starts_with("responded_"),
        \(x) sum(x, na.rm = TRUE)
      ),
      .by = "id"
    )

  clears <- vapply(
    names(thresholds),
    \(f) counts[[paste0("responded_", f)]] >= thresholds[[f]],
    logical(nrow(counts))
  )

  counts$id[rowSums(clears) == length(thresholds)]
}

#' Responders-only compositional parts
#'
#' @description
#' Builds the three-part composition (word, orientation, colour) from
#' **responded trials only**. Scores of 0 recorded for non-responses do not
#' measure allocation, they measure which features a participant declined.
#' That is a separate quantity, and mixing the two would make the
#' composition partly an index of who answered what. Non-response rates
#' differ by feature and, in the pooled data, by imagery group.
#'
#' Grouping is left to the caller through `...`, which is what lets the same
#' function build participant-level compositions (`id`) and trial-level ones
#' (`id`, `trial_uid`).
#'
#' @param data Item-level data.
#' @param ... Grouping columns, tidy-evaluated (e.g. `id`, or `id, trial_uid`).
#' @param features Feature stems, in the canonical order used throughout the
#'   package.
#'
#' @returns A tibble with the grouping columns, `n_word`/`n_angle`/`n_color`
#'   (responded items contributing to each part), the raw responders-only
#'   means `mean_*`, and the closed parts `part_*` summing to 1. Groups
#'   missing a part entirely are returned with `NA` parts rather than
#'   dropped, so the caller decides what to do with them.
#' @export
compose_features <- function(
    data,
    ...,
    features = c("word", "angle", "color")
) {
  groups <- rlang::enquos(...)

  data |>
    dplyr::select(
      !!!groups,
      tidyselect::starts_with("score_") & !tidyselect::ends_with("_z"),
      tidyselect::starts_with("responded_")
    ) |>
    tidyr::pivot_longer(
      c(
        tidyselect::starts_with("score_"),
        tidyselect::starts_with("responded_")
      ),
      names_to = c(".value", "feature"),
      names_pattern = "(score|responded)_(word|angle|color)"
    ) |>
    dplyr::summarise(
      n    = sum(.data$responded),
      mean = mean(.data$score[.data$responded]),
      .by  = c(!!!groups, "feature")
    ) |>
    tidyr::pivot_wider(
      names_from  = "feature",
      values_from = c("n", "mean"),
      names_sep   = "_"
    ) |>
    dplyr::mutate(
      total = rowSums(dplyr::pick(paste0("mean_", features))),
      dplyr::across(
        tidyselect::all_of(paste0("mean_", features)),
        \(x) x / .data$total,
        .names = "part_{.col}"
      )
    ) |>
    dplyr::rename_with(
      \(x) sub("part_mean_", "part_", x),
      tidyselect::starts_with("part_mean_")
    ) |>
    dplyr::select(-"total")
}

#' Isometric log-ratio coordinates for a three-part composition
#'
#' @description
#' The balanced ILR transform, with the sequential binary partition (SBP)
#' given explicitly by `first`. This choice belongs to the researcher and
#' should not be made on statistical grounds: picking whichever partition
#' maximises a contrast selects a split nobody has a substantive interest
#' in. It is therefore an explicit argument with a default matching the
#' study's own decision, rather than a hidden constant.
#'
#' Convention, identical to the one used in `inst/scripts/02-reliability.R`,
#' so that the split-half stability estimates computed there apply to these
#' coordinates unchanged:
#'
#' \deqn{ilr_1 = \sqrt{2/3} \log(p_1 / \sqrt{p_2 p_3})}
#' \deqn{ilr_2 = \sqrt{1/2} \log(p_2 / p_3)}
#'
#' where \eqn{p_1} is `first` and \eqn{p_2, p_3} are the remaining two parts
#' in the canonical order `word, color, angle`. For the default
#' (`first = "word"`), `ilr1` is verbal versus non-verbal allocation and
#' `ilr2` is colour versus orientation.
#'
#' Any two-coordinate ILR basis is a rotation of the same geometry: the
#' omnibus test, the Aitchison distances and the total variance do not
#' depend on `first`. What depends on it is which single-coordinate claim
#' can be stated.
#'
#' @param parts A data frame or matrix with the three closed parts, named
#'   either `part_word`/`part_angle`/`part_color` or `word`/`angle`/`color`.
#' @param first The feature contrasted against the other two in the first
#'   coordinate. One of `"word"` (default), `"color"`, `"angle"`.
#'
#' @returns A tibble with `ilr1` and `ilr2`, and attributes `first` and
#'   `balance` recording which partition produced them.
#' @export
ilr_coords <- function(parts, first = c("word", "color", "angle")) {
  first <- match.arg(first)
  canonical <- c("word", "color", "angle")

  parts <- as.data.frame(parts)
  names(parts) <- sub("^part_", "", names(parts))
  if (!all(canonical %in% names(parts))) {
    stop("`parts` must contain the three parts word, color and angle.")
  }

  rest <- setdiff(canonical, first)
  p1 <- parts[[first]]
  p2 <- parts[[rest[1]]]
  p3 <- parts[[rest[2]]]

  if (any(c(p1, p2, p3) <= 0, na.rm = TRUE)) {
    stop(
      "Log-ratio transforms need strictly positive parts. ",
      "Drop or impute the zero parts before calling `ilr_coords()`."
    )
  }

  out <- tibble::tibble(
    ilr1 = sqrt(2 / 3) * log(p1 / sqrt(p2 * p3)),
    ilr2 = sqrt(1 / 2) * log(p2 / p3)
  )

  attr(out, "first") <- first
  attr(out, "balance") <- c(
    ilr1 = paste0(first, " vs (", rest[1], " + ", rest[2], ")"),
    ilr2 = paste0(rest[1], " vs ", rest[2])
  )
  out
}
