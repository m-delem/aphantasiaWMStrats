# ------------------------------------------------------------------------- #
# 11-compositional-analysis.R ----
#
# Numbered references below are to the planning set in `inst/planning/`.
#
# Implements 11-compositional-analysis.md.
#
# Sample: v1 only (05-version-scope.md §3.5), restricted to the 81
# participants clearing the engagement thresholds of 06 §2.1. That is a
# change from 11 §7, which asked only for units with all three parts
# present. §1 below records why, with the numbers that motivated it: the
# looser sample's compositional variance is dominated by six participants
# who answered as few as one orientation trial.
#
# Input scores: RAW responders-only means, not standardised (11 §7 as
# reversed 2026-08-20; z-scores are ~50% negative and no log-ratio
# transform accepts negative parts).
#
# SBP: word vs (colour + orientation) first, then colour vs orientation.
# Chosen on substantive grounds per 11 §2, not statistical ones. See §3.
#
# VVIQ: the floor-group form (vviq + complete_aphant, 08-predictor-form.md) is
# the pre-declared primary. Alternative functional forms are compared in §4
# and the comparison is reported whatever it says.
#
# WHAT HAS AND HAS NOT BEEN RUN: everything up to §4 has been executed
# against the real data. The brms fits in §4 and §5 were written but not
# run by their author; set TEST_RUN <- TRUE for a fast pass that checks the
# whole pipeline executes before committing to full sampling.
# ------------------------------------------------------------------------- #

devtools::load_all()
library(ggplot2)

# Run configuration ----
# TEST_RUN fits tiny models with a different cache prefix, so a smoke test
# can never overwrite a real fit.
TEST_RUN <- FALSE

set.seed(20260821)

fit_config <-
  if (TEST_RUN) {
    list(chains = 2, iterations = 100, warmup = 100, refresh = 0,
         prefix = "test-", trials_per_id = 6)
  } else {
    list(chains = 4, iterations = 2000, warmup = 1000, refresh = 500,
         prefix = "", trials_per_id = Inf)
  }

fig_dir    <- here::here("inst/scripts/figures")
model_dir  <- here::here("inst/models")
result_dir <- here::here("inst/results")
fs::dir_create(c(fig_dir, model_dir, result_dir))

model_path <- function(name) {
  fs::path(model_dir, paste0(fit_config$prefix, name))
}

rule <- function(txt) cat("\n", strrep("-", 70), "\n", txt, "\n", sep = "")

features <- c("word", "angle", "color")
labels   <- c(word = "Word", angle = "Orientation", color = "Colour")

if (TEST_RUN) rule("TEST_RUN is TRUE: tiny fits, cached under test- prefix")

# ------------------------------------------------------------------------- #
# 1. Sample construction, and why the engagement threshold is applied here ----
# ------------------------------------------------------------------------- #
rule("1. Sample")

d <-
  get_data("v1") |>
  dplyr::filter(grepl("^expe_block", .data$expe_phase)) |>
  dplyr::mutate(trial_uid = paste(.data$expe_phase, .data$trial_number,
                                  sep = "_"))

participant_info <-
  d |>
  dplyr::summarise(
    vviq          = dplyr::first(.data$vviq_total_score),
    imagery_group = dplyr::first(.data$vviq_group_2),
    # The proportion of parity probes ANSWERED (03 §11.1). The accuracy
    # column scores an unanswered probe as 0, so a mean of it measures
    # willingness to do the distractor task, not accuracy on it.
    parity_rate = (sum(.data$responded_parity_1) +
                     sum(.data$responded_parity_2)) / (2 * dplyr::n()),
    .by = "id"
  )

engaged <- engaged_ids(d)

# Sample A: all three parts present, which is all 11 §7 asked for.
# Sample B: A plus the engagement thresholds of 06 §2.1.
compositions_all <- compose_features(d, id)
sample_a <- compositions_all |>
  dplyr::filter(stats::complete.cases(dplyr::pick(tidyselect::starts_with("part_"))))
sample_b <- sample_a |> dplyr::filter(.data$id %in% engaged)

cat("\nv1 participants:", dplyr::n_distinct(d$id), "\n")
cat("A, all three parts present:      ", nrow(sample_a), "\n")
cat("B, also clearing 06 §2.1 thresholds:", nrow(sample_b), "\n")

dropped <- dplyr::anti_join(sample_a, sample_b, by = "id")
cat("\nThe", nrow(dropped), "units the thresholds remove:\n\n")
dropped |>
  dplyr::select("id", tidyselect::starts_with("n_"),
                tidyselect::starts_with("part_")) |>
  dplyr::mutate(id = substr(.data$id, 1, 8)) |>
  as.data.frame() |>
  print(row.names = FALSE, digits = 3)

cat("\nFive of them answered between 1 and 10 of the 63 orientation trials.\n")
cat("A composition resting on one responded trial is not an allocation\n")
cat("profile, and 06 §2.2's stability gate was computed on B, so B is the\n")
cat("sample used from here. Both are reported in §2 and §3 so the effect of\n")
cat("the choice is visible rather than assumed.\n")

# The modelling sample additionally needs VVIQ.
model_base <-
  sample_b |>
  dplyr::left_join(participant_info, by = "id") |>
  dplyr::filter(!is.na(.data$vviq))

model_data <-
  model_base |>
  dplyr::bind_cols(ilr_coords(dplyr::select(
    model_base, tidyselect::starts_with("part_")
  ))) |>
  dplyr::mutate(
    complete_aphant = factor(
      dplyr::if_else(.data$vviq == 16, "floor", "above_floor"),
      levels = c("above_floor", "floor")
    )
  )

cat("\nModelling sample, B with VVIQ present:", nrow(model_data), "\n")
cat("  at the VVIQ floor (16):", sum(model_data$vviq == 16),
    " above floor:", sum(model_data$vviq > 16), "\n")
print(table(model_data$imagery_group))

cat("\nParity engagement, the covariate 11 §8 specifies (03 §11.6):\n")
print(round(stats::quantile(model_data$parity_rate, c(0, .1, .25, .5, .75, 1)), 3))
cat("\nThis is the CORRECTED parity variable (03 §11.6): the proportion of\n")
cat("probes answered, which is the dual-task load actually incurred. The\n")
cat("spike at exactly 0 is 25 participants who never touched the secondary\n")
cat("task, which under v1's incentives is the rational move and not\n")
cat("disengagement: 23 of them clear the recall engagement thresholds.\n")
cat("It predicts recall accuracy at p = .14 to .63 and does not differ by\n")
cat("floor group (p = .925), so it is carried as load rather than as a\n")
cat("confound control.\n")

# ------------------------------------------------------------------------- #
# 2. How much the composition varies (11 §8.5, recomputed on v1) ----
# ------------------------------------------------------------------------- #
rule("2. Composition descriptives")

# composition_summary(), centred_correlations() and partition_variance()
# are in R/ now, so the vignette reporting these tables computes them with
# the same code.
part_summary <- composition_summary

spread_table <- dplyr::bind_rows(
  part_summary(sample_a, "A (n=87)"),
  part_summary(sample_b, "B (n=81)")
)
print(as.data.frame(spread_table), row.names = FALSE, digits = 3)

# 11 §8.5's partial correlations, which motivated the "two-way trade-off"
# reading. Residualising three parts on their own mean induces about -0.5
# by construction, so that is the reference, not zero.
# Computed on the raw responders-only means, not the closed parts. Closing
# forces the deviations to sum to zero exactly, which pins the correlations
# by construction and makes the comparison uninformative. 11 §8.5's own
# quantity is the raw-means one.
centred_cor <- function(parts) {
  centred_correlations(parts, labels = labels)
}

cat("\nPartial correlations between parts, controlling overall level:\n")
cat("\nSample A (n = 87), which is what 11 §8.5 reports on pooled data:\n")
print(round(centred_cor(sample_a), 3))
cat("\nSample B (n = 81):\n")
print(round(centred_cor(sample_b), 3))

cat("\nDOC-VS-DATA FLAG: 11 §8.5 reads these as showing the task achieved a\n")
cat("two-way trade-off, orientation against colour, with word largely free.\n")
cat("On B all three sit near the -0.5 that closure induces on its own, so\n")
cat("that reading does not survive the engagement filter. It describes six\n")
cat("low-engagement participants. The separate evidence that word is too\n")
cat("easy (90% at ceiling, reliability 0.445) is untouched by this and the\n")
cat("v4 recommendation stands on those grounds instead.\n")

# Figure 1: the composition itself ----
ternary_data <-
  sample_b |>
  dplyr::left_join(participant_info, by = "id") |>
  dplyr::filter(!is.na(.data$imagery_group))

p_ternary <-
  plot_composition_ternary(
    ternary_data,
    group = as.character(ternary_data$imagery_group),
    plot.margin = ggplot2::margin_auto(5)
  ) +
  labs(
    caption = paste(
      "Centred and scaled: parts vary by an SD of about 0.025, so an",
      "uncentred triangle would show a single dot."
    )
  )

save_ggplot(
  "inst/scripts/figures/c1-composition-ternary.pdf",
  p_ternary, ncol = 1, height = 75, return = TRUE)

# ------------------------------------------------------------------------- #
# 3. The SBP, and the variance split 11 §2 records as awkward ----
# ------------------------------------------------------------------------- #
rule("3. Sequential binary partition")

# partition_variance() is in R/. Relabelling for display happens at the
# call site rather than in a wrapper of the same name, which would shadow
# the package function it calls.

variance_table <-
  dplyr::bind_rows(
    partition_variance(sample_a, "A (n=87)"),
    partition_variance(sample_b, "B (n=81)")
  ) |>
  dplyr::mutate(first = labels[.data$first])
print(as.data.frame(variance_table), row.names = FALSE, digits = 3)

cat("\nDOC-VS-DATA FLAG: 11 §2's amendment records 39% / 28% / 83% for the\n")
cat("three first contrasts. Those were computed on 117 pooled units with no\n")
cat("engagement filter, a sample 05 §3.5 has since retired. On B the three\n")
cat("shares are much closer together, so the tension the amendment describes\n")
cat("is largely an artifact of the same six units as §2.\n")
cat("\nThis does not change the decision, and must not be presented as a\n")
cat("reason for it. The partition is word vs (colour + orientation) because\n")
cat("that is the contrast the thesis argues about. Two further points make\n")
cat("the choice cheaper than 11 §2 feared:\n")
cat("  - any two-coordinate ILR basis is a rotation of the same geometry, so\n")
cat("    the omnibus test and total variance do not depend on it. Only which\n")
cat("    single-coordinate sentence can be written does.\n")
cat("  - 06 §2.2's stability gate (0.771 / 0.721) was computed for this\n")
cat("    partition specifically. Switching would leave the strand without a\n")
cat("    cleared gate until 06a-reliability.R is re-run.\n")
cat("\nilr1 rests partly on word, whose own split-half reliability is 0.445\n")
cat("(06 §2.1). A ratio can be stable where a level is not, and the gate says\n")
cat("it is, but no claim here may treat word as well measured.\n")

# Figure 2: what the partition choice costs ----
p_partition <-
  variance_table |>
  tidyr::pivot_longer(c("var_ilr1", "var_ilr2"),
                      names_to = "coordinate", values_to = "variance") |>
  dplyr::mutate(
    coordinate = dplyr::if_else(.data$coordinate == "var_ilr1",
                                "First coordinate", "Second coordinate"),
    first = factor(.data$first, levels = c("Word", "Colour", "Orientation"))
  ) |>
  ggplot(aes(x = .data$first, y = .data$variance, fill = .data$coordinate)) +
  # stacked in absolute units rather than filled to 100%: the collapse in
  # total variance between A and B is as much the point as the split
  geom_col() +
  facet_wrap(~ sample) +
  scale_fill_manual(values = unname(palette.colors()[c(6, 9)]), name = NULL) +
  labs(
    x = "Feature contrasted first",
    y = "ILR variance",
    title = "Where the compositional variance sits, by partition",
    caption = paste(
      "A: all three parts present. B: also clearing the engagement",
      "thresholds. Six units carry roughly three quarters of A's variance."
    )
  ) +
  theme_pdf(legend.position = "bottom")

save_ggplot(
  "inst/scripts/figures/c2-partition-variance.pdf",
  p_partition, ncol = 2, height = 70, return = TRUE)

# ------------------------------------------------------------------------- #
# 4. Participant-level models: how should VVIQ enter? ----
# ------------------------------------------------------------------------- #
rule("4. Participant-level model space")

# Pre-check: is a segmented model with an estimated knot identifiable here?
# aphantasiaEmotions seeded one from a MARS search at VVIQ = 24. In this
# sample 18 of 79 sit at exactly 16 and only 6 lie between 17 and 25, so
# there may be nothing in the region a knot would have to occupy. Ask
# before fitting rather than fitting and then interpreting a prior.
#
# Read the knots off the PRUNED model (`selected.terms`), not off `$cuts`,
# which also carries the candidate terms the backward pass discarded. An
# earlier version of this check read `$cuts` whole and reported five knots
# where the fitted model has one.
# mars_knots() is in R/, called directly rather than wrapped.

if (requireNamespace("earth", quietly = TRUE)) {
  mars <- lapply(c("ilr1", "ilr2"), \(v) mars_knots(model_data, outcome = v))
  names(mars) <- c("ilr1", "ilr2")
  for (coordinate in names(mars)) {
    m <- mars[[coordinate]]
    cat(sprintf(
      "\n  %s: %d term(s) retained | knots: %-8s | RSq %.3f | GRSq %.3f",
      coordinate, m$n_terms,
      if (length(m$knots)) paste(m$knots, collapse = ", ") else "none",
      m$rsq, m$grsq))
  }
  cat("\n\nOne interior knot on ilr1 and none on ilr2, so a segmented model is\n")
  cat("worth fitting and is fitted below, seeded from the knot found here.\n")
  cat("Note where the signal is: MARS explains nothing at all on ilr2. That\n")
  cat("is a reason to run the functional-form comparison on ilr1 rather than\n")
  cat("on both coordinates at once.\n")
  SEED_KNOT <- if (length(mars$ilr1$knots) == 1) mars$ilr1$knots else 25
} else {
  cat("\n`earth` not installed. The segmented model is seeded from the knot\n")
  cat("found on 2026-08-21 (VVIQ = 25) rather than skipped, but the\n")
  cat("consistency check that would catch a data change is not running.\n")
  SEED_KNOT <- 25
}

cat("\nVVIQ distribution in the modelling sample:\n\n")
model_data |>
  dplyr::count(vviq_band = cut(.data$vviq, c(15, 16, 25, 40, 60, 80),
                               include.lowest = TRUE)) |>
  as.data.frame() |>
  print(row.names = FALSE)

# Priors. The ILR coordinates have SDs near 0.09 and 0.10, so a normal(0,
# 0.15) on the regression coefficients is weakly informative on the same
# ratio aphantasiaEmotions used (prior SD about 1.7x the outcome SD).
#
# In a multivariate model the population-level coefficients belong to a
# response, so `class = "b"` on its own matches no parameter and recent
# brms versions reject it outright. Hence the explicit `resp`.
ilr_prior <- composition_priors()

# rescor is set explicitly rather than left to the default. It matters: the
# rotation-invariance argument in §3 holds for a genuine multivariate model
# with correlated residuals, not for two independent fits.
#
# The two responses are given as separate bf() calls rather than through
# mvbind(). Both are documented brms idioms and fit the same model, but
# mvbind() has to be resolved from inside the formula, which is fragile when
# the formula is built from a string and brms is not attached.
# composition_formula() is in R/. rescor is estimated there, which is
# what makes the omnibus test invariant to the partition.

fit_composition <- function(rhs, name) {
  fit_brms_model(
    formula = composition_formula(rhs),
    data   = model_data,
    prior  = ilr_prior,
    file   = model_path(name),
    chains = fit_config$chains,
    iterations = fit_config$iterations,
    warmup = fit_config$warmup,
    refresh = fit_config$refresh
  )
}

# The functional-form comparison, on ilr1 ----
#
# Univariate, and deliberately so. The question here is what shape the VVIQ
# relationship has, and per the MARS pre-check the only coordinate with any
# shape to describe is ilr1. Fitting the segmented model to ilr2 as well
# would be fitting four nonlinear parameters to a coordinate MARS reduced to
# an intercept. Univariate elpd values are comparable within this table;
# they are not comparable with the multivariate fits below, and the two
# tables are kept apart for that reason.
fit_ilr1 <- function(rhs, name) {
  fit_brms_model(
    formula = stats::as.formula(paste("ilr1 ~", rhs)),
    data   = model_data,
    prior  = brms::prior(normal(0, 0.15), class = "b"),
    file   = model_path(name),
    chains = fit_config$chains,
    iterations = fit_config$iterations,
    warmup = fit_config$warmup,
    refresh = fit_config$refresh
  )
}

f_null   <- fit_ilr1("1 + parity_rate", "ilr1-null")
f_group  <- fit_ilr1("imagery_group + parity_rate", "ilr1-group")
f_linear <- fit_ilr1("vviq + parity_rate", "ilr1-linear")
f_floor  <- fit_ilr1("vviq + complete_aphant + parity_rate", "ilr1-floor")

# The segmented model, as the direct response to "a single categorical and
# a single continuous model is not a comparison". Parametrised as an
# intercept, a pre-knot slope, a CHANGE in slope after the knot, and the
# knot itself, with the knot's prior centred on the MARS estimate.
f_segmented <- fit_brms_model(
  formula = brms::bf(
    ilr1 ~ a + b1 * vviq + b2 * (vviq - k) * step(vviq - k),
    a ~ 1, b1 ~ 1, b2 ~ 1, k ~ 1,
    nl = TRUE
  ),
  data = model_data,
  prior = c(
    brms::prior(normal(0, 0.5), nlpar = "a"),
    brms::prior(normal(0, 0.15), nlpar = "b1"),
    brms::prior(normal(0, 0.15), nlpar = "b2"),
    brms::prior_string(paste0("normal(", SEED_KNOT, ", 10)"), nlpar = "k")
  ),
  file   = model_path("ilr1-segmented"),
  chains = fit_config$chains,
  iterations = fit_config$iterations,
  warmup = fit_config$warmup,
  refresh = fit_config$refresh
)

candidates <- list(
  "Intercept only"       = f_null,
  "Two-group split"      = f_group,
  "Linear VVIQ"          = f_linear,
  "Floor-group additive" = f_floor,
  "Segmented"            = f_segmented
)

# `loo_compare()` dispatches on its FIRST argument. Handing it a list sends
# it to loo's default method, which wants loo objects and rejects fits with
# "All inputs should have class 'loo'". Attach the criterion to each fit,
# then compare the extracted loo objects, which is what brms itself does
# internally and which keeps the list's names as row labels.
candidates <- lapply(candidates, brms::add_criterion, "loo")
comparison <- loo::loo_compare(lapply(candidates, \(fit) fit$criteria$loo))
print(comparison, digits = 2)

saveRDS(comparison, fs::path(result_dir,
                             paste0(fit_config$prefix, "comp-loo.rds")))

cat("\nPredicted in advance, in the planning conversation: at n = 79 with an\n")
cat("outcome whose total variance is 0.018, the elpd differences will sit\n")
cat("inside their standard errors and the comparison will not separate the\n")
cat("candidates. If that is what the table shows, it is the result, and the\n")
cat("floor-group form stays primary because it was pre-declared, not\n")
cat("because it won.\n")

cat("\nSegmented model, for comparison with the floor-group form:\n\n")
print(brms::fixef(f_segmented), digits = 3)
cat("\nThe two are near-relatives. A knot low on the VVIQ scale with a\n")
cat("near-flat arm below it is what a floor offset looks like when it is\n")
cat("estimated as a hinge instead of an indicator.\n")

# The multivariate models, for inference ----
m_floor  <- fit_composition("vviq + complete_aphant + parity_rate", "comp-floor")
m_floor_noparity <- fit_composition("vviq + complete_aphant",
                                    "comp-floor-noparity")

cat("\nParity covariate, kept or dropped (§1's flag):\n\n")
print(brms::fixef(m_floor_noparity)[, c("Estimate", "Q2.5", "Q97.5")], digits = 3)

# Primary model, reported against a ROPE ----
cat("\nPrimary model: floor-group additive form.\n\n")
print(brms::fixef(m_floor), digits = 3)

draws <- brms::as_draws_df(m_floor)
sd_ilr <- c(ilr1 = stats::sd(model_data$ilr1), ilr2 = stats::sd(model_data$ilr2))

rope_table <-
  purrr::map(
    c("ilr1", "ilr2"),
    function(resp) {
      purrr::map(
        c("vviq", "complete_aphantfloor"),
        function(term) {
          column <- paste0("b_", resp, "_", term)
          report_rope(draws[[column]], outcome_sd = sd_ilr[[resp]]) |>
            dplyr::mutate(coordinate = resp, term = term, .before = 1)
        }
      ) |> purrr::list_rbind()
    }
  ) |> purrr::list_rbind()

cat("\nAgainst a ROPE of 0.1 outcome SD:\n\n")
print(as.data.frame(rope_table), row.names = FALSE)

saveRDS(rope_table, fs::path(result_dir,
                             paste0(fit_config$prefix, "comp-rope.rds")))

# Figure 3: model comparison ----
# recent loo versions return a `model` column already; older ones put the
# names in the row names
loo_table <- as.data.frame(comparison)
if (!"model" %in% names(loo_table)) {
  loo_table <- tibble::rownames_to_column(loo_table, "model")
}

p_loo <-
  loo_table |>
  dplyr::mutate(model = stats::reorder(.data$model, .data$elpd_diff)) |>
  ggplot(aes(x = .data$elpd_diff, y = .data$model)) +
  geom_vline(xintercept = 0, linetype = "dashed", linewidth = 0.2) +
  geom_pointrange(
    aes(xmin = .data$elpd_diff - .data$se_diff,
        xmax = .data$elpd_diff + .data$se_diff),
    size = 0.2
  ) +
  labs(
    x = "elpd difference from the best model, with one standard error",
    y = NULL,
    title = "How VVIQ enters the compositional model",
    caption = "Intervals overlapping zero mean the data do not separate the forms."
  ) +
  theme_pdf()

save_ggplot("inst/scripts/figures/c3-model-comparison.pdf",
            p_loo, ncol = 1, height = 60, return = TRUE)

# Figure 4: the fitted relationship ----
grid <- tidyr::expand_grid(
  vviq = seq(16, 80, by = 1),
  parity_rate = stats::median(model_data$parity_rate)
) |>
  dplyr::mutate(
    complete_aphant = factor(
      dplyr::if_else(.data$vviq == 16, "floor", "above_floor"),
      levels = c("above_floor", "floor")
    )
  )

epred <- brms::posterior_epred(m_floor, newdata = grid)

# A multivariate fit returns a draws x observations x responses array. The
# third dimension's names are what the facets are keyed on, so fall back
# rather than producing NA facet labels if brms stops supplying them.
response_names <- dimnames(epred)[[3]]
if (is.null(response_names)) response_names <- c("ilr1", "ilr2")

fitted_lines <-
  purrr::map(
    seq_along(response_names),
    function(k) {
      tibble::tibble(
        vviq     = grid$vviq,
        estimate = apply(epred[, , k], 2, mean),
        lower    = apply(epred[, , k], 2, stats::quantile, 0.025),
        upper    = apply(epred[, , k], 2, stats::quantile, 0.975),
        coordinate = response_names[k]
      )
    }
  ) |>
  purrr::list_rbind()

coordinate_labels <- c(
  ilr1 = "Words vs (colours + orientations)",
  ilr2 = "Colours vs orientations"
)

observed <-
  model_data |>
  dplyr::select("id", "vviq", "imagery_group", "ilr1", "ilr2") |>
  tidyr::pivot_longer(c("ilr1", "ilr2"),
                      names_to = "coordinate", values_to = "value")

p_effect <-
  ggplot(mapping = aes(x = .data$vviq)) +
  geom_ribbon(
    data = fitted_lines,
    aes(ymin = .data$lower, ymax = .data$upper),
    alpha = 0.15
  ) +
  geom_line(data = fitted_lines, aes(y = .data$estimate), linewidth = 0.4) +
  geom_point(
    data = observed,
    aes(y = .data$value, colour = .data$imagery_group,
        shape = .data$imagery_group),
    size = 1, alpha = 0.8
  ) +
  facet_wrap(~ coordinate, scales = "free_y",
             labeller = labeller(coordinate = coordinate_labels)) +
  scale_x_vviq() +
  scale_discrete_aphantasia(aesthetics = "colour") +
  scale_shape_aphantasia() +
  labs(
    x = "VVIQ total score",
    y = "ILR coordinate",
    title = "Relative allocation against imagery vividness",
    caption = paste(
      "Floor-group model: a slope above VVIQ 16 plus an offset for the",
      "floor group itself."
    )
  ) +
  theme_pdf()

save_ggplot("inst/scripts/figures/c4-composition-vviq.pdf",
            p_effect, ncol = 2, height = 75, return = TRUE)

# ------------------------------------------------------------------------- #
# 5. Trial-level compositions: the multilevel model ----
# ------------------------------------------------------------------------- #
rule("5. Trial-level compositional model")

cat("\n06 §3 assumed multilevel structure without checking there was any, and\n")
cat("the participant-level analysis above has one composition per person, so\n")
cat("a random intercept there is unidentifiable. But each trial is itself a\n")
cat("composition of three feature scores, which does give the structure the\n")
cat("doc assumed. Whether it survives a log-ratio transform is an empirical\n")
cat("question about zeros:\n")

trial_parts <-
  d |>
  dplyr::filter(.data$id %in% model_data$id) |>
  compose_features(id, trial_uid, trial_number)

usable <-
  trial_parts |>
  dplyr::filter(
    stats::complete.cases(dplyr::pick(tidyselect::starts_with("part_"))),
    dplyr::if_all(tidyselect::starts_with("part_"), \(x) x > 0)
  )

cat("\n  trial-level compositions:      ", nrow(trial_parts), "\n")
cat("  missing a part entirely:       ",
    sum(!stats::complete.cases(dplyr::select(trial_parts,
                                             tidyselect::starts_with("part_")))), "\n")
cat("  containing an exact zero part: ",
    nrow(trial_parts) - nrow(usable) -
      sum(!stats::complete.cases(dplyr::select(trial_parts,
                                               tidyselect::starts_with("part_")))), "\n")
cat("  usable without zero replacement:", nrow(usable),
    sprintf(" (%.1f%%)\n", 100 * nrow(usable) / nrow(trial_parts)))
cat("\nDropped rather than imputed. There is no zero-replacement strategy\n")
cat("worth defending for 0.4% of rows, and an unbalanced multilevel model\n")
cat("handles the loss natively.\n")

trial_data <-
  usable |>
  dplyr::bind_cols(ilr_coords(dplyr::select(usable,
                                            tidyselect::starts_with("part_")))) |>
  dplyr::left_join(participant_info, by = "id") |>
  dplyr::mutate(
    complete_aphant = factor(
      dplyr::if_else(.data$vviq == 16, "floor", "above_floor"),
      levels = c("above_floor", "floor")
    ),
    trial_c = as.numeric(scale(.data$trial_number, scale = FALSE))
  )

if (is.finite(fit_config$trials_per_id)) {
  trial_data <- trial_data |>
    dplyr::slice_head(n = fit_config$trials_per_id, by = "id")
  cat("\nTEST_RUN: subset to", fit_config$trials_per_id, "trials per person,",
      nrow(trial_data), "rows.\n")
}

# The ILR of a mean is not the mean of the ILRs, so this model's
# between-person quantity is NOT the participant-level model's outcome
# estimated better. It is a different quantity, and the writeup must not
# present the two as one result twice.
# save_pars: see 09-joint-model.R. The ICC below needs sd_id__ and sigma,
# which are hyperparameters and are kept; only the per-participant
# deviations are dropped.
m_trial <- fit_brms_model(
  formula = composition_formula(
    "vviq + complete_aphant + parity_rate + trial_c + (1 | p | id)"
  ),
  data   = trial_data,
  prior  = ilr_prior,
  save_pars = brms::save_pars(group = FALSE),
  file   = model_path("comp-trial-multilevel"),
  chains = fit_config$chains,
  iterations = fit_config$iterations,
  warmup = fit_config$warmup,
  refresh = fit_config$refresh
)

print(brms::fixef(m_trial), digits = 3)

# ICC per coordinate: a model-based reliability for the composition, which
# complements 06 §2.2's split-half 0.771 / 0.721 and comes from the same fit
# as the effects.
trial_draws <- brms::as_draws_df(m_trial)

icc_draws <-
  purrr::map(
    c("ilr1", "ilr2"),
    function(resp) {
      between_name <- paste0("sd_id__", resp, "_Intercept")
      within_name  <- paste0("sigma_", resp)
      missing <- setdiff(c(between_name, within_name), names(trial_draws))
      if (length(missing)) {
        stop(
          "Parameter(s) not found: ", paste(missing, collapse = ", "),
          ".\nAvailable: ",
          paste(grep("^sd_|^sigma", names(trial_draws), value = TRUE),
                collapse = ", ")
        )
      }
      between <- trial_draws[[between_name]]
      within  <- trial_draws[[within_name]]
      tibble::tibble(
        coordinate = resp,
        icc = between^2 / (between^2 + within^2)
      )
    }
  ) |>
  purrr::list_rbind()

icc_summary <-
  icc_draws |>
  dplyr::summarise(
    median = stats::median(.data$icc),
    lower  = stats::quantile(.data$icc, 0.025),
    upper  = stats::quantile(.data$icc, 0.975),
    .by    = "coordinate"
  )

cat("\nIntraclass correlation of each ILR coordinate:\n\n")
print(as.data.frame(icc_summary), row.names = FALSE, digits = 3)

cat("\nRead against 06 §2.2's split-half stability (ilr1 0.771, ilr2 0.721).\n")
cat("These are different estimands: split-half asks how well half the trials\n")
cat("predict the other half, the ICC asks what share of trial-level variance\n")
cat("is between people. They should agree in direction, not in value.\n")

saveRDS(icc_summary, fs::path(result_dir,
                              paste0(fit_config$prefix, "comp-icc.rds")))

# Figure 5: where the variance lives ----
p_icc <-
  icc_draws |>
  dplyr::mutate(coordinate = coordinate_labels[.data$coordinate]) |>
  ggplot(aes(x = .data$icc, fill = .data$coordinate)) +
  geom_density(alpha = 0.6, colour = NA) +
  scale_fill_manual(values = unname(palette.colors()[c(6, 9)]), name = NULL) +
  scale_x_continuous(limits = c(0, 1)) +
  labs(
    x = "Between-person share of trial-level variance (ICC)",
    y = "Posterior density",
    title = "How much of the composition is a property of the person",
    caption = paste(
      "Estimated from", nrow(trial_data), "trial-level compositions across",
      dplyr::n_distinct(trial_data$id), "participants."
    )
  ) +
  theme_pdf()

save_ggplot("inst/scripts/figures/c5-composition-icc.pdf",
            p_icc, ncol = 1, height = 65, return = TRUE)

rule("Done. Figures in inst/scripts/figures/, models in inst/models/.")
