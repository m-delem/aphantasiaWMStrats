# Scoring for the WM-FTT recall task. See inst/planning/01-score-computation.md for the
# design rationale; the roxygen below records what was implemented and why.

#' Normalise a string for edit-distance comparison
#'
#' Lowercases, strips all whitespace, and removes diacritics by decomposing
#' to NFKD and dropping combining marks. This deliberately mirrors the
#' front end's preprocessing (`plugin-colored-rotated-label-feedback.js`),
#' so that the only difference between [score_word()] and the task's own
#' live feedback is the distance metric itself, not the input handling.
#'
#' @param x Character vector.
#' @return Character vector, normalised. `NA` in, `NA` out.
#' @export
normalise_word <- function(x) {
  x <- tolower(x)
  x <- gsub("\\s+", "", x)
  # NFKD then drop combining marks: "é" -> "e" + U+0301 -> "e"
  x <- stringi::stri_trans_nfkd(x)
  gsub("[\u0300-\u036f]", "", x, perl = TRUE)
}

#' Damerau-Levenshtein distance (optimal string alignment)
#'
#' Local implementation rather than a `stringdist` dependency, consistent
#' with this project's preference for self-contained code with the
#' reasoning attached. Also unit-testable against known values, which
#' matters here: the front end's own edit distance turned out to be broken
#' (see [all_data]), and the failure was
#' invisible precisely because nothing tested it.
#'
#' This is the *restricted* variant (optimal string alignment): adjacent
#' transpositions cost 1, but a substring may not be edited more than once.
#' For single short words the restricted and unrestricted variants agree
#' except in contrived cases, and Gonthier (2022) does not distinguish them.
#'
#' @param a,b Single strings.
#' @return Integer distance. `NA` if either input is `NA`.
#' @export
damerau_levenshtein <- function(a, b) {
  if (is.na(a) || is.na(b)) return(NA_integer_)
  m <- nchar(a)
  n <- nchar(b)
  if (m == 0L) return(n)
  if (n == 0L) return(m)

  x <- strsplit(a, "")[[1]]
  y <- strsplit(b, "")[[1]]

  # Row 0 and column 0 both carry the cost of deleting/inserting a prefix.
  # Getting exactly this wrong is what broke the front end's version.
  d <- matrix(0L, m + 1L, n + 1L)
  d[, 1L] <- 0:m
  d[1L, ] <- 0:n

  for (i in seq_len(m)) {
    for (j in seq_len(n)) {
      cost <- if (x[i] == y[j]) 0L else 1L
      d[i + 1L, j + 1L] <- min(
        d[i, j + 1L] + 1L,   # deletion
        d[i + 1L, j] + 1L,   # insertion
        d[i, j] + cost       # substitution
      )
      if (i > 1L && j > 1L && x[i] == y[j - 1L] && x[i - 1L] == y[j]) {
        d[i + 1L, j + 1L] <- min(d[i + 1L, j + 1L], d[i - 1L, j - 1L] + cost)
      }
    }
  }
  d[m + 1L, n + 1L]
}

#' Word-recall similarity (Gonthier 2022 edit-distance scoring)
#'
#' `similarity = (nchar(target) - min(DL, nchar(target))) / nchar(target)`,
#' where `DL` is the Damerau-Levenshtein distance between the normalised
#' target and response. Bounded \[0, 1\] and floored at 0 by construction:
#' the cap on `DL` before subtraction prevents a negative score when the
#' response is longer than the target.
#'
#' Two deliberate departures from the task's live feedback: the
#' denominator is `nchar(target)`
#' alone rather than `max(nchar(target), nchar(response))`, and the metric
#' is Damerau-Levenshtein rather than plain Levenshtein. Note that the
#' live-feedback column `live_diff_word` is not a valid edit distance at
#' all, so this is not a refinement of it — see [all_data].
#'
#' **Scope caveat.** Gonthier's method is developed and validated for
#' serial span tasks, where a trial's target and response are each a
#' sequence of several stimuli encoded as one string. WM-FTT compares one
#' target word to one recalled word. The distance computation transfers
#' directly; the validation does not cover this exact use.
#'
#' An empty response scores 0 by construction, which is why non-responses
#' need no special case for this feature (unlike colour — see
#' [compute_scores()]).
#'
#' @param target,response Character vectors of equal length.
#' @return Numeric vector in \[0, 1\].
#' @export
score_word <- function(target, response) {
  stopifnot(length(target) == length(response))
  tw <- normalise_word(target)
  rw <- normalise_word(response)
  n <- nchar(tw)
  dl <- mapply(damerau_levenshtein, tw, rw, USE.NAMES = FALSE)
  out <- (n - pmin(dl, n)) / n
  # A zero-length target would be a data error, not a score of 0.
  out[!is.na(n) & n == 0L] <- NA_real_
  out
}

#' Angular similarity via cosine
#'
#' `similarity = (cos(2 * pi * error / period) + 1) / 2`, where `error` is
#' the circular distance between target and response on a circle of
#' circumference `period`. Returns 1 for a perfect match and 0 for a
#' maximally wrong answer, using the full \[0, 1\] range.
#'
#' @section Choice of period:
#' The two angular features have **different periods**, and were initially
#' treated as one case:
#'
#' * **Colour** is a hue wheel: `period = 360`. Red at 5° and red at 355°
#'   are 10° apart, not 350°.
#' * **Orientation** is the tilt of a plain rectangle, which has 180°
#'   rotational symmetry: `period = 180`. A rectangle at +80° and one at
#'   -80° differ by 160° arithmetically but are only 20° apart as
#'   orientations, and both look near-horizontal. The response widget
#'   clamps to \[-90, 90\] (`normalizeAngle()` in `utils.js`), which is
#'   exactly one period.
#'
#' Using `period = 360` for orientation would treat a 90° error —
#' perpendicular, the most wrong an orientation can be — as similarity
#' 0.5 rather than 0, and would compress the observed range to
#' \[0.13, 1\]. See [compute_scores()]'s `orientation_period` argument;
#' this remains flagged for confirmation against real distributions.
#'
#' @param target,response Numeric vectors of angles in degrees.
#' @param period Circumference of the angular space, in degrees.
#' @return Numeric vector in \[0, 1\].
#' @export
score_angular <- function(target, response, period) {
  stopifnot(length(target) == length(response), period > 0)
  raw <- abs(target - response) %% period
  err <- pmin(raw, period - raw)          # circular distance
  (cos(2 * pi * err / period) + 1) / 2
}

#' Compute WM-FTT recall scores
#'
#' Adds raw and per-version-standardised similarity scores for the three
#' recalled features, plus response indicators, to a stimulus-level frame
#' such as [all_data]. Scores are computed from raw target/response values
#' rather than derived from the front end's `live_diff_*` columns, which
#' are display-only and, for the word feature, not a valid edit distance
#' (see [all_data]).
#'
#' @section Columns added:
#' * `score_word`, `score_angle`, `score_color` — raw similarity in
#'   \[0, 1\], higher is better. Note the direction is **opposite** to the
#'   `live_diff_*` columns, which are dissimilarities.
#' * `score_word_z`, `score_angle_z`, `score_color_z` — the above,
#'   z-scored within `version`. Both are kept: raw for anything needing
#'   absolute performance, standardised for cross-feature comparison and
#'   clustering. Note that standardised scores cannot be used for any
#'   log-ratio transform, since roughly half of them are negative.
#' * `responded_word`, `responded_angle`, `responded_color` — logical.
#'
#' @section Non-responses:
#' The task encodes non-response with per-feature sentinels rather than
#' `NA`: an empty `response_word`, a `response_color_angle` of 999, and a
#' `response_angle` of exactly 90 (the orientation widget's untouched
#' starting position). These are scored **0** and flagged, rather than set
#' to `NA`, because non-response here is very unlikely to be
#' missing-at-random — a participant who skips colour is plausibly
#' reporting the absence of a colour representation, and `NA` would let
#' listwise deletion silently drop exactly those observations. Scoring 0
#' produces a visible distortion in the distribution instead of an
#' invisible one in the inference.
#'
#' `responded_angle` is an **inference** (`response_angle != 90`), not an
#' observation, unlike the other two. Max `target_angle` is 61°, and no
#' block trial has a target within 20° of 90°, so a 90° response is never
#' near-correct — but a genuine deliberate 90° cannot be distinguished
#' from an untouched slider.
#'
#' @section Standardisation moments:
#' Means and SDs are computed on **experimental-block rows only**
#' (`expe_phase` matching `^expe_block`) and then applied to every row, so
#' that tutorial and training rows are scored on the same scale without
#' contributing to it. Tutorial rows carry hardcoded placeholder values in
#' the front end's own columns; their target/response values are real, so
#' they are scored here, but they should be filtered before any aggregate.
#'
#' @param data A stimulus-level data frame, e.g. [all_data].
#' @param orientation_period,colour_period Angular periods in degrees. See
#'   [score_angular()] for why they differ.
#' @param no_response_angle Sentinel marking an untouched orientation
#'   widget.
#' @param no_response_colour Sentinel marking an untouched colour wheel.
#' @return `data` with the columns above appended.
#' @export
compute_scores <- function(data,
                           orientation_period = 180,
                           colour_period = 360,
                           no_response_angle = 90,
                           no_response_colour = 999) {
  required <- c(
    "version", "expe_phase",
    "target_word", "response_word",
    "target_angle", "response_angle",
    "target_color_angle", "response_color_angle"
  )
  missing_cols <- setdiff(required, names(data))
  if (length(missing_cols)) {
    stop("compute_scores() needs missing column(s): ",
         paste(missing_cols, collapse = ", "), call. = FALSE)
  }

  out <- dplyr::mutate(
    data,
    responded_word  = !is.na(.data$response_word) & .data$response_word != "",
    responded_angle = !is.na(.data$response_angle) &
      .data$response_angle != no_response_angle,
    responded_color = !is.na(.data$response_color_angle) &
      .data$response_color_angle != no_response_colour,

    score_word = score_word(.data$target_word, .data$response_word),
    score_angle = score_angular(.data$target_angle, .data$response_angle,
                                period = orientation_period),
    score_color = score_angular(.data$target_color_angle,
                                .data$response_color_angle,
                                period = colour_period),

    # Word already reaches 0 for an empty response; the other two are
    # forced, colour necessarily so (999 is not an angle).
    score_angle = ifelse(.data$responded_angle, .data$score_angle, 0),
    score_color = ifelse(.data$responded_color, .data$score_color, 0)
  )

  standardise_by_version(out, c("score_word", "score_angle", "score_color"))
}

#' Z-score columns within version, using experimental-block moments
#'
#' @param data Frame carrying `version` and `expe_phase`.
#' @param cols Character vector of columns to standardise; each gains a
#'   `_z` counterpart.
#' @return `data` with the `_z` columns appended.
#' @keywords internal
standardise_by_version <- function(data, cols) {
  blocks <- grepl("^expe_block", data$expe_phase)
  for (cn in cols) {
    z <- rep(NA_real_, nrow(data))
    for (v in unique(data$version)) {
      in_v <- data$version == v
      ref <- data[[cn]][in_v & blocks]
      mu <- mean(ref, na.rm = TRUE)
      sdev <- stats::sd(ref, na.rm = TRUE)
      # A zero-variance version would make every z-score infinite; leave
      # it NA and let the caller notice rather than shipping Inf.
      z[in_v] <- if (is.na(sdev) || sdev == 0) NA_real_ else
        (data[[cn]][in_v] - mu) / sdev
    }
    data[[paste0(cn, "_z")]] <- z
  }
  data
}
