#' The questionnaire scales, in one participant-level frame
#'
#' @description
#' Pulls the nine scale scores out of the stimulus-level data and returns
#' one row per participant.
#'
#' **Pooled across task versions, deliberately.** Every argument in
#' `05-version-scope.md` for restricting to v1 is about task comparability:
#' group balance for a behavioural contrast, non-response rates differing
#' three-fold, per-version standardisation being unstable. None of it
#' touches a questionnaire score. The instruments are identical and were
#' administered identically in all three versions, so version is a property
#' of the task rather than of the scales, and pooling recovers roughly a
#' third more participants for the one analysis in this project that most
#' needs them.
#'
#' What pooling does change is the *composition* of the sample: later
#' recruitment targeted aphantasics, so the pooled sample is about a third
#' floor-group where v1 is a quarter. Any clustering fitted on it should be
#' checked against a v1-only fit before its labels are used downstream.
#' See [cluster_stability()].
#'
#' @param data Stimulus-level data, typically `all_data`.
#' @param complete_only Drop participants missing any scale. Clustering
#'   needs complete cases, so this defaults to `TRUE`.
#'
#' @returns A tibble with one row per participant.
#' @export
questionnaire_scales <- function(data, complete_only = TRUE) {
  scales <- data |>
    dplyr::distinct(.data$id, .keep_all = TRUE) |>
    dplyr::select(
      "id", "version",
      vviq = "vviq_total_score",
      osivq_object = "object_mean",
      osivq_spatial = "spatial_mean",
      osivq_verbal = "verbal_mean",
      nieq_imagery = "nieq_mental_imagery",
      "nieq_inner_voice", "nieq_emotions",
      "nieq_sensory_focus", "nieq_unsymbolised"
    )

  if (complete_only) {
    scales <- scales[stats::complete.cases(scales), , drop = FALSE]
  }
  scales
}

#' Scale scores, standardised for combining
#'
#' @description
#' The scales are on incompatible ranges: VVIQ runs 16 to 80, OSIVQ
#' subscales 1 to 5, NIEQ dimensions 0 to 100. Anything that combines them,
#' or measures distance across them, needs them on one scale first.
#'
#' Standardising rather than weighting by item count, which is what the
#' earlier clustering study did. Item-count weights assume items are
#' interchangeable units across instruments with different response formats
#' and reliabilities, which is a stronger assumption than it looks and one
#' nobody can check from outside. With scales that converge as hard as
#' these do the weighting barely changes the result, so the version that is
#' easier to defend wins.
#'
#' @param scales A frame from [questionnaire_scales()].
#'
#' @returns The same frame with the scale columns z-scored.
#' @export
standardise_scales <- function(scales) {
  dplyr::mutate(
    scales,
    # numeric columns only: a caller who has already attached cluster
    # labels or group factors should not have them coerced
    dplyr::across(
      tidyselect::where(is.numeric) & -tidyselect::any_of(c("id", "version")),
      \(x) as.numeric(scale(x))
    )
  )
}

#' Collapse the imagery scales into one composite
#'
#' @description
#' Three instruments here measure imagery vividness in three different
#' formats: VVIQ, OSIVQ's object subscale, and NIEQ's mental-imagery
#' dimension. In this sample they correlate around 0.86 with each other
#' against 0.15 to 0.38 for the other OSIVQ subscales, giving an alpha near
#' 0.97. That is one construct measured three ways.
#'
#' Left separate they would **triple-weight imagery** in any distance
#' metric, so a clustering would find imagery groups by construction and
#' the exploratory strand could not say anything the confirmatory strand
#' did not. Collapsing them is what makes "is there structure beyond
#' vividness" answerable.
#'
#' @param scales A standardised frame from [standardise_scales()].
#' @param components Which columns form the composite.
#'
#' @returns The frame with the components replaced by `imagery`.
#' @export
add_imagery_composite <- function(
    scales,
    components = c("vviq", "osivq_object", "nieq_imagery")
) {
  composite <- rowMeans(
    as.matrix(scales[, components, drop = FALSE]), na.rm = TRUE
  )
  scales |>
    dplyr::mutate(imagery = as.numeric(scale(composite)),
                  .before = tidyselect::all_of(components[1])) |>
    dplyr::select(-tidyselect::all_of(components))
}

#' Is a clustering of the pooled sample the same clustering of v1?
#'
#' @description
#' The pooled sample is about a third floor-group where v1 is a quarter,
#' because later recruitment targeted aphantasics. Cluster centroids are
#' fitted to whatever sample they are given, so v1 participants' labels are
#' partly determined by participants who enter no other analysis.
#'
#' This refits on the restricted sample and cross-tabulates, so the
#' question is answered rather than assumed. Substantial agreement means
#' the pooling is innocent and the larger sample can be kept; disagreement
#' means the pooled solution is describing the versions that were excluded
#' from everything else.
#'
#' @param pooled,restricted Cluster assignments for the same participants,
#'   from the two fits, as vectors of equal length.
#'
#' @returns A list with the cross-tabulation, the proportion of
#'   participants whose label is preserved under the best matching of
#'   labels, and the adjusted Rand index.
#' @export
cluster_stability <- function(pooled, restricted) {
  table <- table(pooled = pooled, restricted = restricted)

  # Cluster labels are arbitrary, so agreement is only meaningful after
  # matching each pooled cluster to whichever restricted cluster it most
  # overlaps with.
  best <- sum(apply(table, 1, max)) / sum(table)

  list(
    crosstab = table,
    agreement = best,
    adjusted_rand = adjusted_rand_index(pooled, restricted)
  )
}

#' Adjusted Rand index
#'
#' @description
#' Agreement between two partitions of the same participants, corrected for
#' the agreement expected by chance. 1 is identical, 0 is chance.
#'
#' Used here for the question the exploratory strand exists to answer: does
#' a clustering recover the imagery grouping, or find something else? An
#' index near 1 against the vividness split is a reportable null.
#'
#' @param a,b Two partitions, as vectors of equal length.
#'
#' @returns A single numeric value.
#' @export
adjusted_rand_index <- function(a, b) {
  counts <- table(a, b)
  choose2 <- function(x) sum(x * (x - 1) / 2)

  index <- choose2(counts)
  expected <- choose2(rowSums(counts)) * choose2(colSums(counts)) /
    choose2(sum(counts))
  maximum <- (choose2(rowSums(counts)) + choose2(colSums(counts))) / 2

  (index - expected) / (maximum - expected)
}
