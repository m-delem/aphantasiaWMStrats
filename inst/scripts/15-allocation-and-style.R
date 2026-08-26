# ------------------------------------------------------------------------- #
# 15-allocation-and-style.R ----
#
# The study's design-time prediction, tested for the first time.
#
# From the thesis working hypotheses, Chapter 2 Part III:
#
#   "The prediction is that the resulting allocation pattern tracks
#    cognitive style and inner experience, and not imagery vividness
#    alone. A verbaliser should protect the verbal feature at the expense
#    of the others; a spatialiser should protect the orientation."
#
# Every model in 11-compositional-analysis.md predicts allocation from
# vividness and the floor group. That is the axis the prediction says is
# NOT sufficient on its own, and the OSIVQ has never entered a model
# anywhere in this package. This script closes that gap.
#
# "Not vividness alone" is a claim about WHICH PREDICTORS ARE NEEDED, so
# it is answered by a model comparison rather than by reading coefficients
# out of one saturated model. The space below is fixed here, before
# fitting, and is the same method 02-II of the thesis used to choose the
# functional form of a relationship rather than assume it.
#
# NOT the joint model, and not the performance model. The prediction is
# about allocation. Adding six predictors across the joint model's six
# responses would cost 36 fixed effects on 86 participants to answer a
# question that model was not built for.
# ------------------------------------------------------------------------- #

devtools::load_all()
library(ggplot2)

# Run configuration ----
TEST_RUN <- FALSE

set.seed(20260826)

fit_config <-
  if (TEST_RUN) {
    list(chains = 2, iterations = 100, warmup = 100, refresh = 0,
         prefix = "test-")
  } else {
    list(chains = 4, iterations = 2000, warmup = 1000, refresh = 500,
         prefix = "")
  }

model_dir  <- here::here("inst/models")
fig_dir    <- here::here("inst/scripts/figures")
result_dir <- here::here("inst/results")
fs::dir_create(c(model_dir, fig_dir, result_dir))

model_path <- function(name) {
  fs::path(model_dir, paste0(fit_config$prefix, name))
}

rule <- function(txt) cat("\n", strrep("-", 70), "\n", txt, "\n", sep = "")

# ------------------------------------------------------------------------- #
# 1. Data ----
# ------------------------------------------------------------------------- #
rule("1. Sample")

v1 <- get_data("v1") |> dplyr::filter(grepl("^expe_block", .data$expe_phase))

parity <- v1 |>
  dplyr::summarise(
    parity_rate = (sum(.data$responded_parity_1) +
                     sum(.data$responded_parity_2)) / (2 * dplyr::n()),
    .by = "id"
  )

parts <- compose_features(dplyr::filter(v1, .data$id %in% engaged_ids(v1)), id)
parts <- parts[stats::complete.cases(parts), ]

model_data <-
  parts |>
  dplyr::bind_cols(
    ilr_coords(dplyr::select(parts, tidyselect::starts_with("part_")))
  ) |>
  dplyr::inner_join(questionnaire_scales(get_data()), by = "id") |>
  dplyr::left_join(parity, by = "id") |>
  dplyr::mutate(
    complete_aphant = factor(
      dplyr::if_else(.data$vviq == 16, "floor", "above_floor"),
      levels = c("above_floor", "floor")
    ),
    # standardised so the coefficients are comparable across instruments
    # on incompatible ranges: OSIVQ runs 1-5, NIEQ 0-100
    dplyr::across(
      c("osivq_object", "osivq_spatial", "osivq_verbal",
        "nieq_inner_voice", "nieq_unsymbolised"),
      \(x) as.numeric(scale(x))
    )
  )

cat("\nparticipants:", nrow(model_data),
    "| at the VVIQ floor:", sum(model_data$vviq == 16), "\n")

cat("\nCollinearity is not a problem here, which is worth checking rather\n")
cat("than assuming: the imagery scales converge hard (07), so a set of\n")
cat("predictors drawn from the same battery could easily be redundant.\n\n")
# On the set that is actually FITTED. An earlier version of this check
# included osivq_object, which the models exclude, and reported a VIF of
# 10.6 on vviq that belonged to a specification nobody runs.
inflation <- car::vif(stats::lm(
  ilr1 ~ vviq + complete_aphant + parity_rate + osivq_spatial + osivq_verbal +
    nieq_inner_voice + nieq_unsymbolised,
  data = model_data
))
print(round(inflation, 2))

cat("\nosivq_object correlates",
    round(stats::cor(model_data$osivq_object, model_data$vviq,
                     method = "spearman"), 2),
    "with VVIQ: it is a near-substitute\n")
cat("MEASUREMENT of the same construct, which is why 12 §4b excludes it\n")
cat("rather than entering vividness twice.\n")

# ------------------------------------------------------------------------- #
# 2. Two models, not a space ----
# ------------------------------------------------------------------------- #
rule("2. The comparison")

cat("\nThe predictor set was decided in 12-scale-structure.R §4b, from how\n")
cat("the questionnaires relate to EACH OTHER and never from how any of\n")
cat("them relates to allocation. That is what makes it prospective, and\n")
cat("it is why this script fits two models rather than searching a space:\n")
cat("an eight-model comparison on", nrow(model_data), "participants would mostly report its\n")
cat("own uncertainty.\n")

cat("\n'Not vividness alone' is a COMPARATIVE claim, so the pre-declared\n")
cat("model has to be present beside the full one. Two models, one LOO\n")
cat("comparison, which is the minimum that answers the prediction as it\n")
cat("was written.\n")

vividness_only <- "vviq + complete_aphant + parity_rate"
full_set <- paste("vviq + complete_aphant + parity_rate +",
                  "osivq_spatial + osivq_verbal +",
                  "nieq_inner_voice + nieq_unsymbolised")

cat("\n  Vividness : ilr1, ilr2 ~", vividness_only, "\n")
cat("  Full      : ilr1, ilr2 ~", full_set, "\n")

cat("\nExcluded, with reasons, all fixed in 12 §4b:\n")
cat("  osivq_object, nieq_imagery  correlate 0.87 and 0.87 with VVIQ:\n")
cat("    entering them would enter vividness twice\n")
cat("  nieq_emotions               no hypothesis attached\n")
cat("  nieq_sensory_focus          no hypothesis, and fails its own\n")
cat("                              reliability check at 0.49 (07)\n")

cat("\nnieq_unsymbolised is KEPT despite correlating -0.40 with VVIQ,\n")
cat("because a hypothesis attaches to it and the model can show what it\n")
cat("contributes rather than having that decided in advance.\n")

# ------------------------------------------------------------------------- #
# 3. Fit ----
# ------------------------------------------------------------------------- #
rule("3. Fitting")

fit_allocation <- function(rhs, file) {
  fit_brms_model(
    formula = composition_formula(rhs),
    data    = model_data,
    prior   = composition_priors(),
    file    = model_path(file),
    chains  = fit_config$chains,
    iterations = fit_config$iterations,
    warmup  = fit_config$warmup,
    refresh = fit_config$refresh
  )
}

fits <- list(
  Vividness = fit_allocation(vividness_only, "alloc-vividness"),
  Full      = fit_allocation(full_set, "alloc-full")
)

# ------------------------------------------------------------------------- #
# 4. Does the fuller model earn its predictors? ----
# ------------------------------------------------------------------------- #
rule("4. Model comparison")

fits <- lapply(fits, brms::add_criterion, "loo")
comparison <- loo::loo_compare(lapply(fits, \(fit) fit$criteria$loo))
if (!"model" %in% names(comparison)) {
  comparison <- tibble::rownames_to_column(as.data.frame(comparison), "model")
}
cat("\n")
print(as.data.frame(comparison[, c("model", "elpd_diff", "se_diff")]),
      row.names = FALSE, digits = 3)

saveRDS(comparison, fs::path(result_dir, "allocation-loo.rds"))

difference <- comparison$elpd_diff[2]
standard_error <- comparison$se_diff[2]
cat("\nThe fuller model is", abs(round(difference, 1)), "elpd behind, which is",
    round(abs(difference / standard_error), 1), "standard errors.\n")
cat("\nRead that as a statement about the SET, not about each predictor.\n")
cat("LOO charges for all four extras; if three are noise and one is real,\n")
cat("the real one does not have to pay for the other three. §5 is where\n")
cat("the individual coefficients are read.\n")

# ------------------------------------------------------------------------- #
# 5. The prediction, as coefficients ----
# ------------------------------------------------------------------------- #
rule("5. Does style predict allocation?")

cat("\nThe design-time prediction is directional and specific:\n")
cat("  a VERBALISER protects the WORD feature  -> osivq_verbal raises ilr1\n")
cat("  a SPATIALISER protects the ORIENTATION  -> osivq_spatial lowers ilr2\n")
cat("    (ilr2 contrasts colour against orientation, so protecting\n")
cat("     orientation means a NEGATIVE coefficient)\n\n")

estimates <- as.data.frame(brms::fixef(fits$Full))
estimates$parameter <- rownames(estimates)

print(
  estimates |>
    dplyr::filter(!grepl("Intercept", .data$parameter)) |>
    dplyr::select("parameter", "Estimate", "Q2.5", "Q97.5"),
  row.names = FALSE, digits = 3
)

saveRDS(estimates, fs::path(result_dir, "allocation-estimates.rds"))

rope_for <- function(response, term) {
  draws <- brms::as_draws_df(fits$Full)[[paste0("b_", response, "_", term)]]
  report_rope(draws, outcome_sd = stats::sd(model_data[[response]]))
}

cat("\nAgainst a ROPE of a tenth of each coordinate's own SD:\n\n")
print(as.data.frame(dplyr::bind_rows(
  dplyr::mutate(rope_for("ilr1", "osivq_verbal"),     term = "verbal -> ilr1"),
  dplyr::mutate(rope_for("ilr2", "osivq_spatial"),    term = "spatial -> ilr2"),
  dplyr::mutate(rope_for("ilr1", "nieq_inner_voice"), term = "inner voice -> ilr1"),
  dplyr::mutate(rope_for("ilr1", "nieq_unsymbolised"), term = "unsymbolised -> ilr1"),
  dplyr::mutate(rope_for("ilr1", "complete_aphantfloor"), term = "floor -> ilr1")
) |> dplyr::relocate("term")), row.names = FALSE)

cat("\nWHAT THE UNSYMBOLISED COEFFICIENT DOES AND DOES NOT SHOW. With\n")
cat("vividness in the model, a coefficient near zero demonstrates\n")
cat("redundancy CONDITIONAL ON VIVIDNESS. It does not show that\n")
cat("unsymbolised is unrelated to allocation: marginally it is related,\n")
cat("and 12 §4b carries that. Two different claims, one tested here.\n")

# ------------------------------------------------------------------------- #
# 6. What the answer means for the rest of the package ----
# ------------------------------------------------------------------------- #
rule("6. Consequences, stated before the numbers were seen")

cat("\nIf style predicts allocation and vividness adds nothing on top:\n")
cat("  the design-time prediction is supported, and the floor-group\n")
cat("  offset reported throughout is a style effect wearing a vividness\n")
cat("  label. Every page reporting it needs rereading.\n")
cat("\nIf vividness predicts allocation and style adds nothing:\n")
cat("  the prediction is NOT supported, which is a real result: it says\n")
cat("  allocation tracks whether someone has imagery, not what kind of\n")
cat("  thinker they are.\n")
cat("\nIf both contribute:\n")
cat("  the prediction is supported in its exact form, 'style AND NOT\n")
cat("  vividness alone', and the composition becomes the place where the\n")
cat("  strands meet.\n")
cat("\nIf neither separates from the intercept:\n")
cat("  the honest reading is that 78 participants cannot resolve a\n")
cat("  six-predictor question, and the pre-declared model stands by\n")
cat("  default rather than by evidence.\n")

rule("Done. Comparison in inst/results/allocation-loo.rds.")
