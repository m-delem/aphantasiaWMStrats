# Analysis helpers promoted out of `inst/scripts/`, so that a script and a
# vignette computing the same quantity compute it with the same code.
#
# The scripts had already drifted: `06a-reliability.R` carried local copies
# of an ILR transform and a per-feature mean that were superseded by
# `ilr_coords()` and `compose_features()`, and `mars_knots()` existed in
# two versions across two scripts, one of which ran on items rather than
# participants and found knots in trial-level noise.

#' Spearman-Brown correction
#'
#' @param r A half-test correlation.
#' @returns The implied full-test reliability.
#' @export
spearman_brown <- function(r) 2 * r / (1 + r)

#' Split-half reliability of a per-feature score
#'
#' @description
#' Splits at the **trial** level rather than by odd and even items, because
#' items within a trial share a memory load: an odd-even split would
#' correlate two halves of the same trial and overstate reliability.
#'
#' Participants are included per feature, on their own responded-trial
#' count, since someone can be measurable on colour and not on orientation.
#'
#' @param data Item-level data for one version, test blocks only.
#' @param feature One of `"word"`, `"angle"`, `"color"`.
#' @param n_splits Number of random splits.
#' @param thresholds Minimum responded trials per feature, defaulting to
#'   [wm_thresholds()].
#' @param trial_col Name of the column identifying a trial.
#'
#' @returns A numeric vector of `n_splits` half-test correlations, on the
#'   raw scale. Apply [spearman_brown()] to get full-test reliability.
#' @export
split_half_reliability <- function(
    data,
    feature,
    n_splits = 1000,
    thresholds = wm_thresholds(),
    trial_col = "trial_uid"
) {
  score     <- data[[paste0("score_", feature)]]
  responded <- data[[paste0("responded_", feature)]]
  trials    <- unique(data[[trial_col]])

  counts <- tapply(responded, data$id, sum)
  eligible <- data$id %in% names(which(counts >= thresholds[[feature]]))

  vapply(
    seq_len(n_splits),
    function(k) {
      first <- sample(trials, length(trials) %/% 2)
      in_first  <- eligible & responded & data[[trial_col]] %in% first
      in_second <- eligible & responded & !(data[[trial_col]] %in% first)
      a <- tapply(score[in_first], data$id[in_first], mean)
      b <- tapply(score[in_second], data$id[in_second], mean)
      common <- intersect(names(a), names(b))
      if (length(common) > 2) {
        suppressWarnings(stats::cor(a[common], b[common]))
      } else {
        NA_real_
      }
    },
    numeric(1)
  )
}

#' Spearman correlation with its sample size
#'
#' @param x,y Numeric vectors.
#' @returns A one-row tibble with `rho`, `p` and `n`.
#' @export
correlation_test <- function(x, y) {
  usable <- stats::complete.cases(x, y)
  fit <- suppressWarnings(
    stats::cor.test(x[usable], y[usable], method = "spearman")
  )
  tibble::tibble(rho = unname(fit$estimate), p = fit$p.value, n = sum(usable))
}

#' Cronbach's alpha
#'
#' @param items A data frame or matrix of items, one column each.
#' @returns A single numeric value.
#' @export
cronbach_alpha <- function(items) {
  items <- items[stats::complete.cases(items), , drop = FALSE]
  k <- ncol(items)
  k / (k - 1) *
    (1 - sum(apply(items, 2, stats::var)) / stats::var(rowSums(items)))
}

#' MARS knot search, on participant means
#'
#' @description
#' Asks whether a hinge in the relationship between a feature and VVIQ is
#' identifiable before a segmented model is fitted, so that a model which
#' would only report its own prior is not fitted at all.
#'
#' Two things it has to get right, both of which were got wrong first.
#' Knots come off the **pruned** model (`selected.terms`), not off `$cuts`,
#' which also carries candidate terms the backward pass discarded: reading
#' `$cuts` whole reported five knots where the fitted model had one. And it
#' runs on **one row per participant**, because the question is the shape
#' of a between-person relationship. Run on items, each participant
#' contributes about 63 rows carrying the same VVIQ value, which inflates
#' the sample 63-fold and places knots in trial-level noise while the
#' cross-validated fit stays near zero.
#'
#' Note what silence means: no knot survives GCV pruning, not that the
#' predictor is unrelated to the outcome. Pruning at this sample size is
#' conservative and will drop a weak linear term.
#'
#' @param data One row per participant.
#' @param outcome Name of the outcome column.
#' @param predictor Name of the predictor column.
#'
#' @returns A list with `knots`, `n_terms`, `n`, `rsq` and `grsq`.
#' @export
mars_knots <- function(data, outcome, predictor = "vviq") {
  rlang::check_installed("earth", reason = "to search for knots.")

  # earth() defaults to na.fail, and a participant with no responded trials
  # on a feature has an NA mean
  usable <- data[!is.na(data[[outcome]]) & !is.na(data[[predictor]]), ,
                 drop = FALSE]
  fit <- earth::earth(
    stats::as.formula(paste(outcome, "~", predictor)),
    data = usable
  )
  cuts <- fit$cuts[fit$selected.terms, , drop = FALSE]

  list(
    knots   = sort(unique(cuts[cuts != 0])),
    n_terms = length(fit$selected.terms),
    n       = nrow(usable),
    rsq     = fit$rsq,
    grsq    = fit$grsq
  )
}

#' Descriptive summary of the compositional parts
#'
#' @param parts A data frame with `part_*` columns.
#' @param label A label for the sample, carried through to the output.
#'
#' @returns A tibble with one row per part.
#' @export
composition_summary <- function(parts, label = NA_character_) {
  parts |>
    dplyr::select(tidyselect::starts_with("part_")) |>
    tidyr::pivot_longer(tidyselect::everything(),
                        names_to = "part", values_to = "value") |>
    dplyr::summarise(
      sample = label,
      mean   = mean(.data$value),
      sd     = stats::sd(.data$value),
      min    = min(.data$value),
      max    = max(.data$value),
      .by    = "part"
    )
}

#' Correlations between features after removing each participant's level
#'
#' @description
#' Residualising each participant's feature means on their own mean, which
#' is what "do they trade off" asks. The reference is **not zero**:
#' residualising three variables on their own mean induces a correlation of
#' about -0.5 by construction, so only departures from that carry
#' information.
#'
#' Computed on the raw means rather than on the closed parts. Closing
#' forces the deviations to sum to zero exactly, which pins the
#' correlations and makes the comparison uninformative.
#'
#' @param means A data frame with `mean_*` columns, as returned by
#'   [compose_features()].
#' @param labels Optional named vector for renaming the output.
#'
#' @returns A correlation matrix.
#' @export
centred_correlations <- function(means, labels = NULL) {
  m <- as.matrix(dplyr::select(means, tidyselect::starts_with("mean_")))
  colnames(m) <- sub("^mean_", "", colnames(m))
  if (!is.null(labels)) colnames(m) <- labels[colnames(m)]
  stats::cor(t(apply(m, 1, \(x) x - mean(x))))
}

#' Variance carried by each ILR coordinate, under each partition
#'
#' @description
#' Shows what the choice of sequential binary partition does and does not
#' change. The **total** is invariant: any two-coordinate ILR basis is a
#' rotation of the same geometry. Only the split between the first and
#' second coordinate moves, which is why a partition should be chosen for
#' the contrast it names rather than for the variance it captures.
#'
#' @param parts A data frame with `part_*` columns.
#' @param label A label for the sample.
#' @param first Which features to try as the first contrast.
#'
#' @returns A tibble with one row per candidate partition.
#' @export
partition_variance <- function(
    parts,
    label = NA_character_,
    first = c("word", "color", "angle")
) {
  purrr::map(
    first,
    function(f) {
      z <- ilr_coords(parts, first = f)
      v1 <- stats::var(z$ilr1)
      v2 <- stats::var(z$ilr2)
      tibble::tibble(
        sample     = label,
        first      = f,
        var_ilr1   = v1,
        var_ilr2   = v2,
        ilr1_share = v1 / (v1 + v2)
      )
    }
  ) |>
    purrr::list_rbind()
}

#' Participant-level correlations from a multivariate model
#'
#' @description
#' Pulls the group-level correlation parameters out of a fitted model and
#' returns them tidily, with the response names recovered from the
#' parameter names rather than assumed. brms names these
#' `cor_<group>__<a>_Intercept__<b>_Intercept`, and the order of `a` and
#' `b` follows the order the responses appear in the formula, so a caller
#' asking for a specific pair cannot know in advance which way round it is.
#'
#' Also reports whether each posterior is narrower than the marginal prior
#' on a single correlation under `lkj(eta)` (see [lkj_marginal()]). With
#' fifteen correlations estimated from fewer than a hundred participants,
#' some will not have moved, and a correlation that did not move is not a
#' finding.
#'
#' @param draws A `draws_df`, or anything with the correlation columns,
#'   typically `brms::as_draws_df(model)`.
#' @param group The grouping factor name used in the model.
#' @param lkj The LKJ shape parameter the model was fitted with, used for
#'   the `moved` column. `NULL` skips that column.
#' @param dimension Size of the correlation matrix, for the same purpose.
#'
#' @returns A tibble with one row per correlation: the two responses, the
#'   median, a 95% interval, the probability of direction, and `moved`.
#' @export
posterior_correlations <- function(
    draws,
    group = "id",
    lkj = 4,
    dimension = NULL
) {
  pattern <- paste0("^cor_", group, "__(.+)_Intercept__(.+)_Intercept$")
  columns <- grep(pattern, names(draws), value = TRUE)
  if (!length(columns)) {
    stop("No correlation parameters matching '", pattern, "'.\nAvailable: ",
         paste(grep("^cor_", names(draws), value = TRUE), collapse = ", "))
  }

  prior_sd <-
    if (is.null(lkj)) NA_real_
    else {
      d <- if (is.null(dimension)) ceiling((1 + sqrt(1 + 8 * length(columns))) / 2) else dimension
      stats::sd(lkj_marginal(1e5, lkj, d))
    }

  purrr::map(
    columns,
    function(column) {
      parts <- strsplit(sub(pattern, "\\1|\\2", column), "|",
                               fixed = TRUE)[[1]]
      values <- draws[[column]]
      tibble::tibble(
        response_a = parts[1],
        response_b = parts[2],
        median = stats::median(values),
        # unname(): quantile() returns a named value, and the name rides
        # along into the column, so anyone pulling a bound out gets a
        # named vector labelled '2.5%'
        lower  = unname(stats::quantile(values, 0.025)),
        upper  = unname(stats::quantile(values, 0.975)),
        pd     = max(mean(values > 0), mean(values < 0)),
        moved  = stats::sd(values) < prior_sd
      )
    }
  ) |>
    purrr::list_rbind()
}
