# -----------------------------------------------------------------------
# 03-validity-checks.R
#
# Implements the two remaining checks of 03-validity-checks.md:
#   §2.4  VVIQ / imagery-group sensitivity of the per-feature scores
#   §2.5  Reporting propensity as an outcome in its own right
#
# §2.1 (reliability), §2.2 (compositional stability) and §2.3 (self-report
# convergence) are in 02-reliability.R.
#
# Sample: v1 only (N=88), per 02-pooling-strategy.md §3.5. Section 2.5 also
# reports the across-version comparison, because that is where the apparent
# propensity effect turned out to live.
#
# §2.4 is run BOTH ways, per that section's amendment: once counting
# non-responses as zeros and once on responded trials only. Reporting only
# the first would roughly double the apparent association, because the
# score-0 convention folds reporting propensity into the score.
# -----------------------------------------------------------------------

devtools::load_all()
library(ggplot2)

theme_set(theme_pdf())
rule <- function(text) cat("\n", strrep("-", 70), "\n", text, "\n", sep = "")

engagement_thresholds <- c(Word = 32L, Orientation = 22L, Colour = 29L)

# One row per stimulus per feature, as in the scoring vignette.
trials_by_feature <- all_data |>
  dplyr::filter(grepl("^expe_block", expe_phase)) |>
  dplyr::mutate(participant = paste(id, version, sep = "_")) |>
  dplyr::select(
    id, participant, version, vviq = vviq_total_score,
    imagery_group = vviq_group_2,
    score_word, score_angle, score_color,
    responded_word, responded_angle, responded_color
  ) |>
  tidyr::pivot_longer(
    cols = c(tidyselect::starts_with("score_"),
             tidyselect::starts_with("responded_")),
    names_to = c(".value", "feature"),
    names_pattern = "(score|responded)_(word|angle|color)"
  ) |>
  dplyr::mutate(feature = factor(feature, levels = c("word", "angle", "color"),
                                 labels = c("Word", "Orientation", "Colour")))

v1_trials <- dplyr::filter(trials_by_feature, version == "v1")

# Participant x feature summaries: both scorings, plus response counts.
v1_participants <- v1_trials |>
  dplyr::summarise(
    score_with_zeros = mean(score),
    score_responded_only = mean(score[responded]),
    n_answered = sum(responded),
    n_trials = dplyr::n(),
    vviq = dplyr::first(vviq),
    imagery_group = dplyr::first(imagery_group),
    .by = c(id, feature)
  ) |>
  dplyr::mutate(clears_threshold = n_answered >= engagement_thresholds[feature])

# -----------------------------------------------------------------------
# §2.4  VVIQ / imagery-group sensitivity, run both ways
# -----------------------------------------------------------------------
rule("2.4  Does anything in WM-FTT track VVIQ? (v1, both scorings)")

correlation_test <- function(score, vviq) {
  usable <- stats::complete.cases(score, vviq)
  fit <- suppressWarnings(
    stats::cor.test(score[usable], vviq[usable], method = "spearman"))
  tibble::tibble(rho = unname(fit$estimate), p = fit$p.value, n = sum(usable))
}

vviq_continuous <- v1_participants |>
  dplyr::filter(clears_threshold) |>
  dplyr::reframe(
    dplyr::bind_rows(
      dplyr::mutate(correlation_test(score_with_zeros, vviq),
                    scoring = "non-responses as zeros"),
      dplyr::mutate(correlation_test(score_responded_only, vviq),
                    scoring = "responded trials only")
    ),
    .by = feature
  ) |>
  dplyr::select(feature, scoring, n, rho, p)

cat("\nSpearman correlation with continuous VVIQ:\n\n")
print(as.data.frame(vviq_continuous), row.names = FALSE, digits = 3)

cat("\nThe gap between the two scorings is the artifact 03 §2.4 warns about.\n")
cat("Reporting only the first row of each pair would overstate the result.\n")

group_comparison <- v1_participants |>
  dplyr::filter(clears_threshold, !is.na(imagery_group)) |>
  dplyr::summarise(
    n = dplyr::n(),
    mean_score = mean(score_responded_only, na.rm = TRUE),
    sd_score = stats::sd(score_responded_only, na.rm = TRUE),
    .by = c(feature, imagery_group)
  ) |>
  dplyr::arrange(feature, imagery_group)

cat("\nBy imagery group, responded trials only:\n\n")
print(as.data.frame(group_comparison), row.names = FALSE, digits = 3)

group_tests <- v1_participants |>
  dplyr::filter(clears_threshold, !is.na(imagery_group)) |>
  dplyr::reframe({
    fit <- stats::wilcox.test(score_responded_only ~ imagery_group, exact = FALSE)
    tibble::tibble(W = unname(fit$statistic), p = fit$p.value)
  }, .by = feature)

cat("\nAphantasia vs typical, Wilcoxon rank-sum, responded trials only:\n\n")
print(as.data.frame(group_tests), row.names = FALSE, digits = 3)

cat("\nNote the four-group VVIQ split is unusable in v1 (hyperphantasia n=3),\n")
cat("so only the two-group split is tested here (02-pooling-strategy §3.5).\n")

p_vviq <- v1_participants |>
  dplyr::filter(clears_threshold) |>
  ggplot(aes(vviq, score_responded_only)) +
  geom_point(alpha = 0.6, size = 2) +
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE) +
  facet_wrap(~feature, scales = "free_y") +
  labs(x = "VVIQ total score", y = "Mean score, responded trials only",
       title = "Recall accuracy against imagery vividness (v1)")
save_ggplot("inst/scripts/figures/v1-vviq-accuracy.pdf", p_vviq,
            ncol = 2, height = 70)

# -----------------------------------------------------------------------
# §2.5  Reporting propensity as an outcome
# -----------------------------------------------------------------------
rule("2.5  Reporting propensity as an outcome (08-response-propensity.md)")

cat("\nNon-response rates by version and feature:\n\n")
trials_by_feature |>
  dplyr::summarise(non_response = 1 - mean(responded), .by = c(version, feature)) |>
  tidyr::pivot_wider(names_from = feature, values_from = non_response) |>
  as.data.frame() |>
  print(row.names = FALSE, digits = 3)

# Reporting propensity: responded trials out of 63, per participant per
# feature, against VVIQ.
#
# Model choice, decided against the data rather than in advance. A mixed
# binomial with a participant random intercept is the natural structure,
# but it is overdispersed by a factor of 4.2, and absorbing that with an
# observation-level random effect produces a degenerate fit (dispersion
# 0.17, one feature's SE an order of magnitude below the others, a
# non-positive-definite covariance matrix). It is not identifiable at this
# sample size. A quasi-binomial GLM instead scales the standard errors by
# the estimated dispersion without needing the extra variance component.
#
# Its own limitation, stated rather than hidden: it does not model the
# correlation between a participant's three rows, so its p-values are
# optimistic. The rank correlations below are the conservative comparison,
# and where the two disagree the honest reading is "suggestive, not
# established".
propensity_data <- v1_participants |>
  dplyr::filter(!is.na(vviq)) |>
  dplyr::mutate(vviq_centred = vviq - mean(vviq))

simple_slope <- function(reference_feature) {
  fit <- stats::glm(
    cbind(n_answered, n_trials - n_answered) ~ vviq_centred * feature,
    data = dplyr::mutate(propensity_data,
                         feature = stats::relevel(feature, ref = reference_feature)),
    family = stats::quasibinomial()
  )
  coefficient <- summary(fit)$coefficients["vviq_centred", ]
  tibble::tibble(feature = reference_feature, log_odds_per_vviq_point = coefficient[1],
                 se = coefficient[2], t = coefficient[3], p = coefficient[4])
}

propensity_slopes <- purrr::map(levels(propensity_data$feature), simple_slope) |>
  purrr::list_rbind()

cat("\nQuasi-binomial GLM, v1: responded ~ VVIQ * feature\n")
cat("Slope of VVIQ on the log-odds of responding, per feature:\n\n")
print(as.data.frame(propensity_slopes), row.names = FALSE, digits = 3)

dispersion <- summary(stats::glm(
  cbind(n_answered, n_trials - n_answered) ~ vviq_centred * feature,
  data = propensity_data, family = stats::quasibinomial()))$dispersion
cat("\n  dispersion estimate:", round(dispersion, 1),
    "-- far above 1, hence the quasi-binomial\n")

cat("\nConservative comparison, participant-level rank correlation (v1):\n\n")
propensity_data |>
  dplyr::mutate(non_response = 1 - n_answered / n_trials) |>
  dplyr::reframe(correlation_test(non_response, vviq), .by = feature) |>
  dplyr::select(feature, n, rho, p) |>
  as.data.frame() |>
  print(row.names = FALSE, digits = 3)

cat("\nWithin-version correlations, for comparison with the pooled figure:\n\n")
trials_by_feature |>
  dplyr::summarise(non_response = 1 - mean(responded),
                   vviq = dplyr::first(vviq),
                   .by = c(participant, version, feature)) |>
  dplyr::reframe(correlation_test(non_response, vviq), .by = c(version, feature)) |>
  dplyr::select(version, feature, n, rho, p) |>
  as.data.frame() |>
  print(row.names = FALSE, digits = 3)

p_propensity <- v1_participants |>
  dplyr::filter(!is.na(vviq)) |>
  ggplot(aes(vviq, 1 - n_answered / n_trials)) +
  geom_point(alpha = 0.6, size = 2) +
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE) +
  facet_wrap(~feature) +
  labs(x = "VVIQ total score", y = "Non-response rate",
       title = "Reporting propensity against imagery vividness (v1)")
save_ggplot("inst/scripts/figures/v1-propensity-vviq.pdf", p_propensity,
            ncol = 2, height = 70)

rule("Done. Figures written to inst/scripts/figures/")

# -----------------------------------------------------------------------
# §2.7  OSIVQ multitrait-multimethod check
# -----------------------------------------------------------------------
rule("2.7  OSIVQ convergent/discriminant validity")

# OSIVQ's three subscales map onto WM-FTT's three features:
#   object -> colour, spatial -> orientation, verbal -> word.
# The prediction is a PATTERN, not three separate correlations: the
# matching diagonal should exceed the mismatched off-diagonal.

participants <- all_data |>
  dplyr::filter(version == "v1") |>
  dplyr::distinct(id, .keep_all = TRUE)

# Reliabilities computed from the raw items, not taken from the manual.
# NOTE: v1/v2 store four reverse-keyed OSIVQ items UNREVERSED in
# osivq_items, while v3 stores them reversed. The subscale *means* are
# correct in both. Recomputing alpha from v1's stored items without
# reversing gives 0.25 for verbal instead of 0.84. See R/data.R.
reverse_keyed <- c("osivq_q41v", "osivq_q09v", "osivq_q02v", "osivq_q42s")

cronbach_alpha <- function(items) {
  items <- items[stats::complete.cases(items), , drop = FALSE]
  k <- ncol(items)
  k / (k - 1) * (1 - sum(apply(items, 2, stats::var)) / stats::var(rowSums(items)))
}

osivq_items <- purrr::list_rbind(participants$osivq_items)
for (item in reverse_keyed) osivq_items[[item]] <- 6 - osivq_items[[item]]

osivq_alpha <- c(
  object  = cronbach_alpha(osivq_items[, grepl("o$", names(osivq_items)), drop = FALSE]),
  spatial = cronbach_alpha(osivq_items[, grepl("s$", names(osivq_items)), drop = FALSE]),
  verbal  = cronbach_alpha(osivq_items[, grepl("v$", names(osivq_items)), drop = FALSE])
)
cat("\nOSIVQ subscale alpha in v1, after reversing the reverse-keyed items:\n")
print(round(osivq_alpha, 3))

feature_reliability <- c(Colour = 0.833, Orientation = 0.822, Word = 0.445)

mtmm_data <- v1_participants |>
  dplyr::filter(clears_threshold) |>
  dplyr::select(id, feature, score_responded_only) |>
  tidyr::pivot_wider(names_from = feature, values_from = score_responded_only) |>
  dplyr::inner_join(
    dplyr::select(participants, id, object = object_mean,
                  spatial = spatial_mean, verbal = verbal_mean),
    by = "id"
  )

subscales <- c("object", "spatial", "verbal")
features <- c("Colour", "Orientation", "Word")

mtmm <- tidyr::expand_grid(subscale = subscales, feature = features) |>
  dplyr::mutate(
    r = purrr::map2_dbl(subscale, feature, \(s, f)
                        stats::cor(mtmm_data[[s]], mtmm_data[[f]], method = "spearman",
                                   use = "complete.obs")),
    p = purrr::map2_dbl(subscale, feature, \(s, f) {
      ok <- stats::complete.cases(mtmm_data[[s]], mtmm_data[[f]])
      suppressWarnings(stats::cor.test(mtmm_data[[s]][ok], mtmm_data[[f]][ok],
                                       method = "spearman")$p.value)
    }),
    disattenuated = r / sqrt(osivq_alpha[subscale] * feature_reliability[feature]),
    cell = dplyr::if_else(
      paste(subscale, feature) %in%
        c("object Colour", "spatial Orientation", "verbal Word"),
      "diagonal (predicted)", "off-diagonal")
  )

cat("\nMTMM matrix, Spearman correlations:\n\n")
mtmm |>
  dplyr::select(subscale, feature, r, p, disattenuated, cell) |>
  as.data.frame() |>
  print(row.names = FALSE, digits = 3)

cat("\nPattern test: does the predicted diagonal exceed the off-diagonal?\n\n")
mtmm |>
  dplyr::summarise(mean_abs_r = mean(abs(r)),
                   mean_abs_disattenuated = mean(abs(disattenuated)),
                   .by = cell) |>
  as.data.frame() |>
  print(row.names = FALSE, digits = 3)

cat("\nDisattenuation divides by the square root of both reliabilities, so\n")
cat("the Word column is inflated most (its reliability is 0.45). Both raw\n")
cat("and disattenuated are shown rather than the flattering one alone.\n")
