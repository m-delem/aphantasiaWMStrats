# ------------------------------------------------------------------------- #
# 09-joint-model.R ----
#
# Implements 09-joint-model.md §8.
#
# Doc references below are to the planning set in `inst/planning/`.
#
# Six responses: three Bernoulli gates for whether a feature was reported,
# three bounded accuracies for how well, sharing a 6x6 correlated
# participant random-intercept matrix. The 15 correlations are the reason
# the model exists (09 §8.3); the fixed effects are the confirmatory
# quantities.
#
# Sample: all 86 participants with VVIQ. The engagement thresholds of
# 06 §2.1 are deliberately NOT applied (09 §8.7): they exist to stop
# imprecise participant means being treated as measurements, and this
# model forms no participant means. 10 and 11 stay on 79, so every
# reported quantity has to name its sample.
#
# THE REPORTING SET IS FIXED IN 09 §8.3 AND HARD-CODED BELOW. Anything
# outside it that turns out to be interesting is exploratory and says so.
#
# WHAT HAS AND HAS NOT BEEN RUN: data preparation, the descriptive tables
# and the prior calculation have been executed against the real data.
# Every formula and prior has been checked with `get_prior()`,
# `validate_prior()` and `make_standata()`, which run without compiling.
# No model here has been sampled. Set TEST_RUN <- TRUE first.
# ------------------------------------------------------------------------- #

devtools::load_all()
library(ggplot2)

# Run configuration ----
TEST_RUN <- TRUE

set.seed(20260824)

fit_config <-
  if (TEST_RUN) {
    list(chains = 2, iterations = 100, warmup = 100, refresh = 0,
         prefix = "test-", trials_per_id = 6)
  } else {
    list(chains = 4, iterations = 2000, warmup = 1000, refresh = 500,
         prefix = "", trials_per_id = Inf)
  }

# 09 §8.6: expect this to be slow, and expect to need both of these.
# The INCLUDE_PARITY / INCLUDE_WORD_ACC fallback switches are gone: the
# full model samples, so the fallbacks documented in 09 §8.6 are a manual
# edit if they are ever needed rather than a permanent branch.
adapt_delta   <- 0.99
max_treedepth <- 15

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

# brms strips non-alphanumeric characters from response names, so these are
# what appear in priors and in draw columns, not the column names.
gates     <- c(word = "respondedword", angle = "respondedangle",
               color = "respondedcolor")
accuracy  <- c(word = "scoreword", angle = "scoreangle",
               color = "scorecolor")

if (TEST_RUN) rule("TEST_RUN is TRUE: tiny fits, cached under test- prefix")

# ------------------------------------------------------------------------- #
# 1. Data ----
# ------------------------------------------------------------------------- #
rule("1. Sample")

raw <-
  get_data("v1") |>
  dplyr::filter(grepl("^expe_block", .data$expe_phase))

if (!"responded_parity_1" %in% names(raw)) {
  stop("`responded_parity_*` missing. Re-run data-raw/04_apply_manual_review.R ",
       "after the compute_scores() change of 03 §11.2.")
}

participant_info <-
  raw |>
  dplyr::summarise(
    vviq          = dplyr::first(.data$vviq_total_score),
    imagery_group = dplyr::first(.data$vviq_group_2),
    # The corrected parity variable (03 §11.6): the proportion of probes
    # answered, which is the dual-task load actually incurred. NOT a mean
    # of `parity_*_acc`, which scores unanswered probes as 0 and is a
    # response-rate variable wearing an accuracy name.
    parity_rate = (sum(.data$responded_parity_1) +
                     sum(.data$responded_parity_2)) / (2 * dplyr::n()),
    .by = "id"
  )

model_data <-
  raw |>
  dplyr::left_join(participant_info, by = "id") |>
  dplyr::filter(!is.na(.data$vviq)) |>
  dplyr::mutate(
    complete_aphant = factor(
      dplyr::if_else(.data$vviq == 16, "floor", "above_floor"),
      levels = c("above_floor", "floor")
    )
  )

if (is.finite(fit_config$trials_per_id)) {
  model_data <- model_data |>
    dplyr::slice_head(n = fit_config$trials_per_id * 3, by = "id")
}

# SV squeeze on colour only (10 §11.3): an exact 1 is an error of exactly
# zero degrees on a continuous wheel, which is pixel resolution rather
# than a behaviour. Word's ceiling is a real mass and gets an inflation
# component instead.
n_colour <- sum(model_data$responded_color)
model_data <-
  model_data |>
  dplyr::mutate(
    score_color_raw = .data$score_color,
    score_color = squeeze_boundaries(.data$score_color, n = n_colour)
  )

cat("\nparticipants:", dplyr::n_distinct(model_data$id),
    "| items:", nrow(model_data), "\n")
cat("at the VVIQ floor:",
    dplyr::n_distinct(model_data$id[model_data$vviq == 16]),
    "| above floor:",
    dplyr::n_distinct(model_data$id[model_data$vviq > 16]), "\n")

engaged <- engaged_ids(raw)
cat("\nof these,", sum(!unique(model_data$id) %in% engaged),
    "would be excluded by 06 §2.1's engagement thresholds and are kept.\n")
cat("That is the point of the model: they are invisible to every\n")
cat("responders-only analysis and highly informative about propensity.\n")

# What the six responses look like before any model touches them.
response_summary <-
  purrr::map(
    features,
    function(f) {
      responded <- model_data[[paste0("responded_", f)]]
      score     <- model_data[[paste0("score_", f)]]
      tibble::tibble(
        feature       = labels[[f]],
        response_rate = mean(responded),
        n_responded   = sum(responded),
        accuracy      = mean(score[responded])
      )
    }
  ) |>
  purrr::list_rbind()

cat("\n")
print(as.data.frame(response_summary), row.names = FALSE, digits = 3)

cat("\nparity response rate: median",
    round(stats::median(participant_info$parity_rate, na.rm = TRUE), 3),
    "| at exactly 0:",
    sum(participant_info$parity_rate == 0, na.rm = TRUE), "\n")

# ------------------------------------------------------------------------- #
# 2. Priors ----
# ------------------------------------------------------------------------- #
rule("2. Priors")

# Formulas and priors come from the package (`joint_formula()`,
# `joint_priors()`, `response_priors()`), not from local copies. That is
# what lets the vignette reporting this model display the object that
# produced it: models are loaded there with `file_refit = "never"`, and
# brms does not check that the formula it is handed matches the cached
# fit's.
#
# 09 §8.5: lkj(4), not the lkj(2) used in 10, because 15 correlations from
# 86 clusters need more regularisation than 3 do.
lkj_eta <- 4

prior_sd <- stats::sd(lkj_marginal(1e5, lkj_eta, 6))
cat("\nlkj(", lkj_eta, ") on a 6x6 matrix puts a marginal SD of ",
    round(prior_sd, 3), " on each\n", sep = "")
cat("correlation, so a correlation has to be earned rather than assumed.\n")

# ------------------------------------------------------------------------- #
# 3. The response-propensity model ----
# ------------------------------------------------------------------------- #
rule("3. The response-propensity model (three gates)")

cat("\nThis is 04-response-propensity.md's own model, not a warm-up for the\n")
cat("next one: whether a feature gets reported, as a function of imagery,\n")
cat("with participant random effects. It is also the only place the three\n")
cat("propensity correlations are estimated WITHOUT the accuracy arms\n")
cat("pulling on them, which is what §8's comparison uses.\n")

# The gates alone. Not scaffolding: this is 04-response-propensity.md's
# own model, and it gives the three propensity correlations estimated
# without the accuracy arms pulling on them, which §8 below compares
# against.
gates_only <- joint_formula(accuracy_features = character(0))

m_gates <- fit_brms_model(
  formula = gates_only,
  data    = model_data,
  prior   = joint_priors(accuracy_features = character(0), lkj = lkj_eta),
  file    = model_path("joint-gates"),
  chains  = fit_config$chains,
  iterations = fit_config$iterations,
  warmup  = fit_config$warmup,
  refresh = fit_config$refresh,
  adapt_delta = adapt_delta,
  max_treedepth = max_treedepth
)

print(brms::fixef(m_gates), digits = 3)

# ------------------------------------------------------------------------- #
# 4. The joint model, all six responses ----
# ------------------------------------------------------------------------- #
rule("4. The joint model, all six responses")

# Print these two in the vignette: they are what the model is.
joint_specification <- joint_formula()
joint_specification

accuracy_responses <- unname(accuracy)

m_joint <- fit_brms_model(
  formula = joint_specification,
  data    = model_data,
  prior   = joint_priors(lkj = lkj_eta),
  file    = model_path("joint-full"),
  chains  = fit_config$chains,
  iterations = fit_config$iterations,
  warmup  = fit_config$warmup,
  refresh = fit_config$refresh,
  adapt_delta = adapt_delta,
  max_treedepth = max_treedepth
)

print(brms::fixef(m_joint), digits = 3)

draws <- brms::as_draws_df(m_joint)

# ------------------------------------------------------------------------- #
# 5. Tier 1: the six correlations the model exists for ----
# ------------------------------------------------------------------------- #
rule("5. Tier 1 correlations (09 §8.3)")

# brms names these by the order the responses appear in the formula, so
# the column may be either way round. Try both, and fail with the list of
# what exists rather than returning NULL into a plot.
correlation_draws <- function(a, b) {
  candidates <- c(
    paste0("cor_id__", a, "_Intercept__", b, "_Intercept"),
    paste0("cor_id__", b, "_Intercept__", a, "_Intercept")
  )
  found <- candidates[candidates %in% names(draws)]
  if (!length(found)) {
    stop("Neither of:\n  ", paste(candidates, collapse = "\n  "),
         "\nAvailable:\n  ",
         paste(grep("^cor_id", names(draws), value = TRUE), collapse = "\n  "))
  }
  draws[[found[1]]]
}

# HARD-CODED FROM 09 §8.3. Not derived from the fit, so it cannot drift.
tier_1 <- tibble::tribble(
  ~a,                ~b,                ~pair,                        ~family,
  gates[["word"]],   accuracy[["word"]],   "Word gate and accuracy",     "Selection",
  gates[["angle"]],  accuracy[["angle"]],  "Orientation gate and accuracy", "Selection",
  gates[["color"]],  accuracy[["color"]],  "Colour gate and accuracy",   "Selection",
  accuracy[["word"]], accuracy[["angle"]], "Word and Orientation",       "Trade-off",
  accuracy[["word"]], accuracy[["color"]], "Word and Colour",            "Trade-off",
  accuracy[["angle"]], accuracy[["color"]], "Orientation and Colour",    "Trade-off"
)

summarise_correlations <- function(spec) {
  purrr::pmap(
    spec,
    function(a, b, pair, family) {
      r <- correlation_draws(a, b)
      tibble::tibble(
        family = family, pair = pair,
        median = stats::median(r),
        lower  = stats::quantile(r, 0.025),
        upper  = stats::quantile(r, 0.975),
        pd     = max(mean(r > 0), mean(r < 0)),
        moved  = stats::sd(r) < prior_sd
      )
    }
  ) |> purrr::list_rbind()
}

tier_1_summary <- summarise_correlations(tier_1)
cat("\n")
print(as.data.frame(tier_1_summary), row.names = FALSE, digits = 3)

saveRDS(tier_1_summary,
        fs::path(result_dir, paste0(fit_config$prefix, "joint-tier1.rds")))

cat("\n`moved` is TRUE where the posterior is narrower than the lkj(",
    lkj_eta, ") marginal\n", sep = "")
cat("prior (SD ", round(prior_sd, 3),
    "). A correlation that did not move is not a finding.\n", sep = "")

cat("\nWhat these decide, stated in 09 §8.4 before the numbers existed:\n")
cat("  selection near zero -> the responders-only analyses in 10 and 11\n")
cat("    were legitimate, and 10 §11.6's 0.512 was feature-specific.\n")
cat("  selection large across all three -> a general engagement trait,\n")
cat("    11 inherits its caveat, and this becomes the only defensible\n")
cat("    view of accuracy.\n")
cat("  accuracy correlations positive -> shared ability dominates between\n")
cat("    people, and 11 §13.3's negative partials were closure artifacts.\n")
cat("    This is what 10 §11 predicts (+0.586 for orientation/colour).\n")

# Figure j1: the headline.
tier_1_plot_data <-
  purrr::pmap(
    tier_1,
    function(a, b, pair, family) {
      tibble::tibble(family = family, pair = pair, r = correlation_draws(a, b))
    }
  ) |> purrr::list_rbind()

p_tier1 <-
  tier_1_plot_data |>
  ggplot(aes(x = .data$r, y = .data$pair, colour = .data$family)) +
  geom_vline(xintercept = 0, linetype = "dashed", linewidth = 0.2) +
  stat_summary(
    fun = stats::median,
    fun.min = \(x) stats::quantile(x, 0.025),
    fun.max = \(x) stats::quantile(x, 0.975),
    geom = "pointrange", size = 0.25, orientation = "y"
  ) +
  facet_grid(family ~ ., scales = "free_y", space = "free_y") +
  scale_x_continuous(limits = c(-1, 1)) +
  scale_colour_manual(values = unname(palette.colors()[c(6, 4)]),
                      guide = "none") +
  labs(
    x = "Participant-level correlation",
    y = NULL,
    title = "Selection and trade-off, from one model",
    caption = paste(
      "Selection: does willingness to report go with accuracy when",
      "reporting?\nTrade-off: does doing well on one feature cost another?"
    )
  ) +
  theme_pdf()

save_ggplot("inst/scripts/figures/j1-tier1-correlations.pdf",
            p_tier1, ncol = 1, height = 75, return = TRUE)

# ------------------------------------------------------------------------- #
# 6. Tier 2: the remaining nine, as a table ----
# ------------------------------------------------------------------------- #
rule("6. Tier 2 correlations")

all_responses <- c(unname(gates), accuracy_responses)
pairs <- utils::combn(all_responses, 2, simplify = FALSE)

# Matched on an order-independent key, since a correlation between two
# responses is the same parameter whichever way round the pair is written.
pair_key <- function(a, b) paste(pmin(a, b), pmax(a, b))

tier_2 <-
  purrr::map(
    pairs,
    \(p) tibble::tibble(a = p[1], b = p[2],
                        pair = paste(p[1], "and", p[2]), family = "All")
  ) |>
  purrr::list_rbind() |>
  dplyr::filter(!pair_key(.data$a, .data$b) %in%
                  pair_key(tier_1$a, tier_1$b))

stopifnot(nrow(tier_1) + nrow(tier_2) == length(pairs))

tier_2_summary <- summarise_correlations(tier_2)
cat("\n")
print(as.data.frame(tier_2_summary), row.names = FALSE, digits = 3)

saveRDS(tier_2_summary,
        fs::path(result_dir, paste0(fit_config$prefix, "joint-tier2.rds")))

cat("\nReported for completeness. Anything here that is interesting is\n")
cat("EXPLORATORY and must be labelled so: it was not in 09 §8.3's set.\n")

# Figure j2: the whole matrix, so the reader sees what was not foregrounded.
matrix_data <-
  dplyr::bind_rows(tier_1_summary, tier_2_summary) |>
  dplyr::bind_cols(dplyr::bind_rows(tier_1, tier_2)[, c("a", "b")])

p_matrix <-
  matrix_data |>
  ggplot(aes(x = .data$a, y = .data$b, fill = .data$median)) +
  geom_tile(colour = "white", linewidth = 0.4) +
  geom_text(aes(label = sprintf("%.2f", .data$median)), size = 2) +
  scale_fill_gradient2(limits = c(-1, 1), name = "r") +
  labs(
    x = NULL, y = NULL,
    title = "All fifteen participant-level correlations",
    caption = "Six were pre-specified as of interest (09 §8.3); the rest are exploratory."
  ) +
  theme_pdf(axis.text.x = element_text(angle = 45, hjust = 1))

save_ggplot("inst/scripts/figures/j2-correlation-matrix.pdf",
            p_matrix, ncol = 1, height = 85, return = TRUE)

# ------------------------------------------------------------------------- #
# 7. Tier 3: the fixed effects ----
# ------------------------------------------------------------------------- #
rule("7. Fixed effects (09 §8.3, tier 3)")

fixed <- as.data.frame(brms::fixef(m_joint))
fixed$parameter <- rownames(fixed)

floor_effects <-
  fixed |>
  dplyr::filter(grepl("complete_aphantfloor$", .data$parameter)) |>
  dplyr::mutate(
    response = sub("_complete_aphantfloor$", "", .data$parameter),
    kind = dplyr::if_else(grepl("^responded", .data$response),
                          "Gate: willing to report", "Accuracy when reporting"),
    feature = labels[dplyr::case_when(
      grepl("word$", .data$response) ~ "word",
      grepl("angle$", .data$response) ~ "angle",
      TRUE ~ "color"
    )]
  )

cat("\nFloor-group offsets, log-odds:\n\n")
print(floor_effects[, c("kind", "feature", "Estimate", "Q2.5", "Q97.5")],
      row.names = FALSE, digits = 3)

cat("\nThe gate rows are the claim no earlier analysis could make: whether\n")
cat("complete aphantasics differ in what they are WILLING TO REPORT.\n")
cat("Word's ACCURACY row stays excluded from individual-differences\n")
cat("inference (10 §11.4, split-half 0.445). Its gate row does not:\n")
cat("whether someone answers is not a low-reliability quantity.\n")

saveRDS(floor_effects,
        fs::path(result_dir, paste0(fit_config$prefix, "joint-floor.rds")))

p_floor <-
  floor_effects |>
  ggplot(aes(x = .data$Estimate, y = .data$feature, colour = .data$kind)) +
  geom_vline(xintercept = 0, linetype = "dashed", linewidth = 0.2) +
  geom_pointrange(aes(xmin = .data$Q2.5, xmax = .data$Q97.5),
                  position = position_dodge(width = 0.4), size = 0.25) +
  scale_colour_manual(values = unname(palette.colors()[c(2, 3)]), name = NULL) +
  labs(
    x = "Floor-group offset, log-odds",
    y = NULL,
    title = "What complete aphantasia changes",
    caption = "Willingness to report and accuracy when reporting, from one model."
  ) +
  theme_pdf()

save_ggplot("inst/scripts/figures/j3-floor-effects.pdf",
            p_floor, ncol = 1, height = 65, return = TRUE)

# ------------------------------------------------------------------------- #
# 8. Sanity checks against the simpler models ----
# ------------------------------------------------------------------------- #
rule("8. Sanity checks (09 §8.6)")

cat("\nThese are CONVERGENCE AND ROBUSTNESS CHECKS, not corroboration\n")
cat("(09 §8.8). Same data through a simpler lens, so agreement is not\n")
cat("independent evidence. They also run on 79 participants against this\n")
cat("model's 86, so agreement is approximate by construction.\n")

# Each row names the parameter it checks, so the comparison cannot drift
# out of alignment with the reference values.
floor_offset <- function(response) {
  row <- paste0(response, "_complete_aphantfloor")
  if (!row %in% rownames(brms::fixef(m_joint))) return(NA_real_)
  unname(brms::fixef(m_joint)[row, "Estimate"])
}
safe_correlation <- function(a, b) {
  tryCatch(stats::median(correlation_draws(a, b)), error = \(e) NA_real_)
}

reference <- tibble::tribble(
  ~quantity,                          ~from,       ~published, ~this_model,
  "word accuracy floor offset",       "10 §11 C'",      0.587, floor_offset(accuracy[["word"]]),
  "orientation accuracy floor offset","10 §11 C'",     -0.109, floor_offset(accuracy[["angle"]]),
  "colour accuracy floor offset",     "10 §11 C'",     -0.238, floor_offset(accuracy[["color"]]),
  "cor(orientation, colour accuracy)","10 §11 C'",      0.586, safe_correlation(accuracy[["angle"]], accuracy[["color"]]),
  "cor(orientation gate, accuracy)",  "10 §11.6",       0.512, safe_correlation(gates[["angle"]], accuracy[["angle"]])
)
reference$difference <- reference$this_model - reference$published

cat("\n")
print(as.data.frame(reference), row.names = FALSE, digits = 3)

cat("\nGate coefficients, propensity-only model against the joint model:\n\n")
stage_comparison <-
  dplyr::inner_join(
    tibble::as_tibble(brms::fixef(m_gates), rownames = "parameter") |>
      dplyr::select("parameter", propensity_only = "Estimate"),
    tibble::as_tibble(brms::fixef(m_joint), rownames = "parameter") |>
      dplyr::select("parameter", joint = "Estimate"),
    by = "parameter"
  )
print(as.data.frame(stage_comparison), row.names = FALSE, digits = 3)

cat("\nLarge movement here means the accuracy arms are pulling the gates,\n")
cat("which is informative rather than wrong, but it should be visible.\n")

rule("Done. Figures in inst/scripts/figures/, models in inst/models/.")
