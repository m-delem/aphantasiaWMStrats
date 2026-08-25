# ------------------------------------------------------------------------- #
# 10-performance-modelling.R ----
#
# Implements 10-performance-modelling.md §11.
#
# Doc references below are to the planning set in `inst/planning/`.
#
# Primary model, Option C-prime (10 §11.2): a multivariate model with a
# per-feature response family and correlated participant random
# intercepts. The `|p|` in `(1 | p | id)` is what carries the
# cross-feature dependency Option C existed to capture, delivered as
# three named pairwise correlations rather than random slopes read
# relative to an arbitrary reference feature.
#
# Families, per 10 §11.3, chosen by what each boundary means:
#   word        zero-one-inflated Beta   90.7% at exactly 1 is a real mass
#   orientation Beta                     no boundary mass at all
#   colour      Beta, after an SV squeeze  exact 1s are pixel resolution
#
# Word is retained but excluded from individual-differences inference
# (10 §11.4). Its split-half reliability is 0.445; its coefficients are
# reported with that number attached and no claim is drawn from them.
#
# The hurdle is staged (10 §11.6): everything here is conditional on
# responding, and §7 fits the joint propensity/accuracy model on
# orientation alone as a test of whether that conditioning was legitimate.
#
# WHAT HAS AND HAS NOT BEEN RUN: the data preparation, the SV squeeze, the
# boundary table and the MARS pre-check have been executed against the
# real data. Every brms formula and prior in this script has been checked
# with `get_prior()`, `validate_prior()` and `make_stancode()`, which run
# without compiling. No model here has been sampled. Set TEST_RUN <- TRUE
# for a fast pass before committing to full sampling.
# ------------------------------------------------------------------------- #

devtools::load_all()
library(ggplot2)

# Run configuration ----
TEST_RUN <- FALSE

set.seed(20260822)

fit_config <-
  if (TEST_RUN) {
    # every model here is trial-level, so a test pass thins the trials
    # rather than the participants: the random-effect structure is what
    # needs exercising, and it needs all 79 groups to exercise it
    list(chains = 2, iterations = 100, warmup = 100, refresh = 0,
         prefix = "test-", trials_per_id = 6)
  } else {
    list(chains = 4, iterations = 2000, warmup = 1000, refresh = 500,
         prefix = "", trials_per_id = Inf)
  }

# Sample. "engaged" is the 79 participants of 11 §13.1, which keeps this
# strand comparable with the compositional one. The multilevel structure
# here would tolerate the looser sample, since partial pooling handles
# unequal trial counts natively, but the engagement thresholds are a
# measurement-adequacy rule and they do not stop applying because the
# model got better. Set to "all" for the sensitivity fit.
SAMPLE <- c("engaged", "all")[1]

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
responses <- c(word = "scoreword", angle = "scoreangle", color = "scorecolor")

if (TEST_RUN) rule("TEST_RUN is TRUE: tiny fits, cached under test- prefix")

# ------------------------------------------------------------------------- #
# 1. Data, and the two boundary problems ----
# ------------------------------------------------------------------------- #
rule("1. Sample and response distributions")

raw <-
  get_data("v1") |>
  dplyr::filter(grepl("^expe_block", .data$expe_phase))

participant_info <-
  raw |>
  dplyr::summarise(
    vviq          = dplyr::first(.data$vviq_total_score),
    imagery_group = dplyr::first(.data$vviq_group_2),
    # The proportion of parity probes ANSWERED, not a mean of
    # `parity_*_acc`: that column scores an unanswered probe as 0, and 92%
    # of its v1 zeros are unanswered rather than wrong, so a mean of it is
    # a response rate wearing an accuracy name (03 §11.1).
    parity_rate = (sum(.data$responded_parity_1) +
                     sum(.data$responded_parity_2)) / (2 * dplyr::n()),
    .by = "id"
  )

eligible <- participant_info$id[!is.na(participant_info$vviq)]
if (SAMPLE == "engaged") {
  eligible <- intersect(eligible, engaged_ids(raw))
}

model_data <-
  raw |>
  dplyr::filter(.data$id %in% eligible) |>
  dplyr::left_join(participant_info, by = "id") |>
  dplyr::mutate(
    complete_aphant = factor(
      dplyr::if_else(.data$vviq == 16, "floor", "above_floor"),
      levels = c("above_floor", "floor")
    ),
    trial_c = as.numeric(scale(.data$trial_number, scale = FALSE))
  )

if (is.finite(fit_config$trials_per_id)) {
  model_data <- model_data |>
    dplyr::slice_head(n = fit_config$trials_per_id * 3, by = "id")
}

cat("\nsample:", SAMPLE, "|", dplyr::n_distinct(model_data$id), "participants,",
    nrow(model_data), "items\n")
cat("at the VVIQ floor:", dplyr::n_distinct(model_data$id[model_data$vviq == 16]),
    " above floor:", dplyr::n_distinct(model_data$id[model_data$vviq > 16]), "\n")

# Boundary mass on responded trials. This is the table 10 §11.1 records,
# recomputed here rather than trusted, because the family choice below
# rests entirely on it.
boundary_table <-
  purrr::map(
    features,
    function(f) {
      score     <- model_data[[paste0("score_", f)]]
      responded <- model_data[[paste0("responded_", f)]]
      tibble::tibble(
        feature      = labels[[f]],
        n_responded  = sum(responded),
        at_zero      = mean(score[responded] == 0),
        at_one       = mean(score[responded] == 1)
      )
    }
  ) |>
  purrr::list_rbind()

print(as.data.frame(boundary_table), row.names = FALSE, digits = 3)

cat("\nOrientation has no boundary mass at all once non-responders are\n")
cat("removed, so it is a clean Beta. The other two each need something,\n")
cat("and they need different things.\n")

# The Smithson-Verkuilen squeeze, for colour ----
#
# Beta has zero density at exactly 0 and 1, so a single boundary value
# gives the likelihood a zero and the fit errors rather than degrades.
# Smithson & Verkuilen (2006) pull the whole variable a hair inside the
# open interval: y' = (y * (n - 1) + 0.5) / n.
#
# Applied to colour and NOT to word, because of what the boundary means
# (10 §11.3). Colour score is cosine similarity on a continuous wheel, so
# an exact 1 is an error of exactly zero degrees, which is pixel
# resolution rather than a behaviour. Word's ceiling is a real mass: a
# recalled word either matches or it does not, and that earns an
# inflation component instead.
n_colour <- sum(model_data$responded_color)

model_data <-
  model_data |>
  dplyr::mutate(
    score_color_raw = .data$score_color,
    score_color = squeeze_boundaries(.data$score_color, n = n_colour)
  )

cat("\nSV squeeze on colour, n =", n_colour, "responded trials:\n")
cat("  exact ones:", sum(model_data$score_color_raw == 1 &
                           model_data$responded_color),
    "-> now", signif(max(model_data$score_color[model_data$responded_color]), 7), "\n")
cat("  largest displacement of any value:",
    signif(max(abs(model_data$score_color - model_data$score_color_raw)[
      model_data$responded_color]), 3), "\n")
cat("  `score_color_raw` keeps the untransformed values for descriptives.\n")

# Figure 1: what the three response distributions look like ----
distribution_data <-
  model_data |>
  dplyr::select("id", "complete_aphant",
                tidyselect::all_of(paste0("score_", features)),
                tidyselect::all_of(paste0("responded_", features))) |>
  tidyr::pivot_longer(
    c(tidyselect::starts_with("score_"),
      tidyselect::starts_with("responded_")),
    names_to = c(".value", "feature"),
    names_pattern = "(score|responded)_(word|angle|color)"
  ) |>
  dplyr::filter(.data$responded) |>
  dplyr::mutate(
    feature = factor(labels[.data$feature], levels = unname(labels)),
    group = dplyr::if_else(.data$complete_aphant == "floor",
                           "VVIQ floor", "Above floor")
  )

p_distributions <-
  distribution_data |>
  ggplot(aes(x = .data$score, fill = .data$feature)) +
  geom_histogram(bins = 40, colour = NA) +
  facet_grid(group ~ feature, scales = "free_y") +
  scale_discrete_feature(aesthetics = "fill") +
  labs(
    x = "Score on responded trials",
    y = "Trials",
    title = "Why one response family cannot serve all three features",
    caption = paste(
      "Word piles at 1; orientation and colour are clean on the open",
      "interval. Colour shown before the squeeze."
    )
  ) +
  theme_pdf(legend.position = "none")

save_ggplot("inst/scripts/figures/p1-response-distributions.pdf",
            p_distributions, ncol = 2, height = 80, return = TRUE)

# ------------------------------------------------------------------------- #
# 2. Priors ----
# ------------------------------------------------------------------------- #
rule("2. Priors")

# All three families use a logit link on mu, so coefficients are on the
# log-odds scale and the priors are set per coefficient rather than per
# class. A single `class = "b"` prior would put the same scale on a VVIQ
# slope (per point, over a 64-point range) and on a binary group offset,
# which are not remotely the same quantity.
#
# Note the response names: brms strips non-alphanumeric characters, so
# these are `scoreword`, `scoreangle`, `scorecolor`, not the column names.
# response_priors() is in R/, so the vignette reporting these models builds
# its priors from the same function rather than a second copy.
performance_priors <- function(response_names = responses) {
  do.call(c, lapply(unname(response_names), response_priors,
                    terms = c("vviq", "complete_aphant")))
}

# lkj(2) mildly favours the identity, so the cross-feature correlations
# have to be earned from the data rather than assumed.
c_prime_priors <- c(performance_priors(), brms::prior("lkj(2)", class = "cor"))

cat("\nvviq slope: normal(0, 0.05) on the log-odds scale. Over the 64-point\n")
cat("VVIQ range that still admits a swing of several log-odds, so it is\n")
cat("weakly informative rather than restrictive.\n")
cat("floor offset: normal(0, 1). lkj(2) on the correlation matrix.\n")

# ------------------------------------------------------------------------- #
# 3. Option A: three independent models, the deliberate wrong baseline ----
# ------------------------------------------------------------------------- #
rule("3. Option A, three independent univariate models")

cat("\n05 §1's narrative arc starts here on purpose. A treats the three\n")
cat("features as unrelated outcomes, which the task's design makes false:\n")
cat("points are traded across features within a trial, so a participant\n")
cat("who does well on one has spent effort they cannot spend elsewhere.\n")
cat("A is fitted, reported, and then shown to be the wrong model.\n")

# Priors are built from the terms the model actually contains. A prior
# naming a coefficient that is not in the model matches no parameter and
# recent brms versions reject the whole call, which is how the intercept-
# only and two-group candidates in §4 would otherwise fail.
univariate_priors <- function(rhs) {
  terms <- c("vviq", "complete_aphant", "imagery_group", "parity_rate")
  response_priors(NULL, terms = terms[vapply(terms, grepl, logical(1), rhs)])
}

fit_univariate <- function(response, family, name, rhs =
                             "vviq + complete_aphant + (1 | id)") {
  subset_flag <- paste0("responded_", sub("^score_", "", response))
  fit_brms_model(
    formula = brms::bf(
      stats::as.formula(
        paste0(response, " | subset(", subset_flag, ") ~ ", rhs)
      ),
      family = family
    ),
    data   = model_data,
    prior  = univariate_priors(rhs),
    file   = model_path(name),
    chains = fit_config$chains,
    iterations = fit_config$iterations,
    warmup = fit_config$warmup,
    refresh = fit_config$refresh
  )
}

a_word <- fit_univariate("score_word", brms::zero_one_inflated_beta(),
                         "perf-a-word")
a_angle <- fit_univariate("score_angle", brms::Beta(), "perf-a-angle")
a_color <- fit_univariate("score_color", brms::Beta(), "perf-a-color")

option_a <- list(Word = a_word, Orientation = a_angle, Colour = a_color)

cat("\nFloor-group offsets under Option A, log-odds:\n\n")
purrr::imap(
  option_a,
  \(fit, feature) {
    tibble::as_tibble(brms::fixef(fit)["complete_aphantfloor", , drop = FALSE]) |>
      dplyr::mutate(feature = feature, .before = 1)
  }
) |>
  purrr::list_rbind() |>
  as.data.frame() |>
  print(row.names = FALSE, digits = 3)

# ------------------------------------------------------------------------- #
# 4. How VVIQ enters, compared on orientation ----
# ------------------------------------------------------------------------- #
rule("4. Functional form of the VVIQ relationship")

cat("\nRun on orientation alone, mirroring 11 §13.6's decision to compare\n")
cat("forms where the signal is. Orientation is the best-measured feature\n")
cat("(split-half 0.822) and 06 §2.4 already associates it with VVIQ.\n")
cat("\nThe target was fixed on those grounds before the pre-check ran, and\n")
cat("is not revised in light of it. If colour turns out to carry the knot\n")
cat("and orientation does not, that is worth recording and is not a reason\n")
cat("to switch the comparison onto colour after the fact.\n")

# The MARS pre-check, on PARTICIPANT MEANS rather than items.
#
# Two things it has to get right. Knots come off the PRUNED model
# (`selected.terms`), not off `$cuts`, which also carries the candidate
# terms the backward pass discarded; that was the bug in 11 §13.6. And it
# runs on one row per participant, because the question is the shape of a
# BETWEEN-person relationship. Run on items, each participant contributes
# about 63 rows carrying the same VVIQ value, which inflates n by a factor
# of 63 and lets MARS place knots in trial-level noise while the
# cross-validated fit stays near zero.
#
# A hinge that marks the floor group has to sit low on the VVIQ scale.
# The aphantasia cutoff is 32, above-floor median VVIQ is 57, and only 11
# of 79 participants sit below 40, so 40 is the ceiling of the region
# where a floor-related knot could plausibly live. Knots above it are
# MARS flexing in the dense part of the scale, which is a different claim
# and not one this model is for.
FLOOR_REGION <- 40

participant_means <-
  model_data |>
  compose_features(id) |>
  dplyr::left_join(participant_info, by = "id")

mars_knots <- function(feature) {
  column <- paste0("mean_", feature)
  # A participant with no responded trials on a feature has an NA mean,
  # and earth() defaults to na.fail. That happens whenever TEST_RUN thins
  # the trials, and it can happen on the full data under SAMPLE = "all",
  # so the rows are dropped here and the count is reported rather than
  # the failure being deferred to the caller.
  usable <- participant_means[
    !is.na(participant_means[[column]]) & !is.na(participant_means$vviq), ,
    drop = FALSE
  ]
  fit <- earth::earth(stats::as.formula(paste(column, "~ vviq")),
                      data = usable)
  cuts <- fit$cuts[fit$selected.terms, , drop = FALSE]
  list(knots = sort(unique(cuts[cuts != 0])),
       n_terms = length(fit$selected.terms),
       n = nrow(usable),
       rsq = fit$rsq, grsq = fit$grsq)
}

if (requireNamespace("earth", quietly = TRUE)) {
  if (TEST_RUN) {
    cat("\nTEST_RUN thins the trials, so the participant means below are\n")
    cat("computed from a fraction of the data. Do not read this pre-check\n")
    cat("from a test pass.\n")
  }
  for (f in features) {
    m <- mars_knots(f)
    cat(sprintf(
      "\n  %-11s: n %2d | %d term(s) | knots: %-20s | RSq %.3f | GRSq %.3f",
      labels[[f]], m$n, m$n_terms,
      if (length(m$knots)) paste(m$knots, collapse = ", ") else "none",
      m$rsq, m$grsq))
  }
  cat("\n\n")

  cat("MARS silence means no HINGE worth keeping under GCV pruning, not\n")
  cat("that VVIQ is unrelated to the feature: 06 §2.4 reports rho = +0.229\n")
  cat("for orientation. Pruning at n = 79 is conservative and will drop a\n")
  cat("weak linear term. The LOO comparison below is what tests that.\n")

  orientation <- mars_knots("angle")
  candidate_knots <- orientation$knots[orientation$knots <= FLOOR_REGION]

  # The criterion is about WHERE a knot sits, not how many there are. Two
  # knots below 40 would be fine and the lower one would seed the model,
  # since the segmented form has a single k and the lower hinge is the one
  # that could mark the floor. What disqualifies the model is no knot in
  # the region at all, or a cross-validated fit of nothing.
  SEED_KNOT <- if (length(candidate_knots)) min(candidate_knots) else NA
  if (!is.na(SEED_KNOT) && orientation$grsq <= 0) {
    cat("MARS has a knot at", SEED_KNOT, "but a GRSq of",
        round(orientation$grsq, 3), ", so the fit does not generalise.\n")
    cat("No segmented model.\n")
    SEED_KNOT <- NA
  }
} else {
  cat("\n`earth` not installed, skipping the pre-check.\n")
  SEED_KNOT <- NA
}

# Option A's orientation fit IS the floor-group candidate, so it is reused
# rather than refitted.
f_floor  <- a_angle
f_null   <- fit_univariate("score_angle", brms::Beta(), "perf-form-null",
                           rhs = "1 + (1 | id)")
f_group  <- fit_univariate("score_angle", brms::Beta(), "perf-form-group",
                           rhs = "imagery_group + (1 | id)")
f_linear <- fit_univariate("score_angle", brms::Beta(), "perf-form-linear",
                           rhs = "vviq + (1 | id)")

candidates <- list(
  "Intercept only"       = f_null,
  "Two-group split"      = f_group,
  "Linear VVIQ"          = f_linear,
  "Floor-group additive" = f_floor
)

# The segmented model is fitted only if MARS located a single interior
# knot. Without one there is nothing to seed it from, and at this sample
# size it would report its prior. 11 §13.6 records what an unidentified
# knot looks like: an interval running past the end of the scale.
if (!is.na(SEED_KNOT)) {
  f_segmented <- fit_brms_model(
    formula = brms::bf(
      score_angle | subset(responded_angle) ~
        a + b1 * vviq + b2 * (vviq - k) * step(vviq - k),
      a ~ 1 + (1 | id), b1 ~ 1, b2 ~ 1, k ~ 1,
      nl = TRUE, family = brms::Beta()
    ),
    data = model_data,
    prior = c(
      brms::prior(normal(0, 1.5), nlpar = "a"),
      brms::prior(normal(0, 0.05), nlpar = "b1"),
      brms::prior(normal(0, 0.05), nlpar = "b2"),
      brms::prior_string(paste0("normal(", SEED_KNOT, ", 10)"), nlpar = "k")
    ),
    file   = model_path("perf-form-segmented"),
    chains = fit_config$chains,
    iterations = fit_config$iterations,
    warmup = fit_config$warmup,
    refresh = fit_config$refresh
  )
  candidates[["Segmented"]] <- f_segmented
} else {
  cat("No knot below VVIQ", FLOOR_REGION,
      "on orientation, so no segmented model.\n")
  cat("Knots higher up the scale describe curvature among typical imagers,\n")
  cat("which is a different question from whether the floor group sits\n")
  cat("off the line.\n")
}

# `loo_compare()` dispatches on its first argument, so a list of fits goes
# to loo's default method and is rejected. Compare the extracted loo
# objects, as brms does internally.
candidates <- lapply(candidates, brms::add_criterion, "loo")
form_comparison <- loo::loo_compare(
  lapply(candidates, \(fit) fit$criteria$loo)
)
print(form_comparison, digits = 2)

saveRDS(form_comparison,
        fs::path(result_dir, paste0(fit_config$prefix, "perf-form-loo.rds")))

cat("\nThe floor-group form is primary because it was pre-declared\n")
cat("(10 §11.5), not because it wins here. Check the N < 100 diagnostic\n")
cat("flag before reading anything into the differences: 11 §13.6 hit it,\n")
cat("and it means loo's standard errors are themselves unreliable.\n")

# recent loo versions return a `model` column already; older ones put the
# names in the row names
form_table <- as.data.frame(form_comparison)
if (!"model" %in% names(form_table)) {
  form_table <- tibble::rownames_to_column(form_table, "model")
}

p_form <-
  form_table |>
  dplyr::mutate(model = stats::reorder(.data$model, .data$elpd_diff)) |>
  ggplot(aes(x = .data$elpd_diff, y = .data$model)) +
  geom_vline(xintercept = 0, linetype = "dashed", linewidth = 0.2) +
  geom_pointrange(
    aes(xmin = .data$elpd_diff - .data$se_diff,
        xmax = .data$elpd_diff + .data$se_diff),
    size = 0.2
  ) +
  labs(
    x = "elpd difference from the best model,\nwith one standard error",
    y = NULL,
    title = "How VVIQ enters,\ncompared on orientation",
    caption = "Intervals overlapping zero mean the data do not separate the forms."
  ) +
  theme_pdf()

save_ggplot("inst/scripts/figures/p2-form-comparison.pdf",
            p_form, ncol = 1, height = 60, return = TRUE)

# ------------------------------------------------------------------------- #
# 5. Option C-prime, the primary model ----
# ------------------------------------------------------------------------- #
rule("5. Option C-prime")

# Built by performance_formula() in R/ rather than written out here, so
# that the vignette reporting this model shows the object that produced it.
# Print it to see all three responses.
c_prime_formula <- performance_formula(parity = FALSE)

# `subset()` on each response is what lets one row carry three features
# with independent non-response. Without it a row missing any one feature
# would drop out of all three models.
m_c_prime <- fit_brms_model(
  formula = c_prime_formula,
  data    = model_data,
  prior   = c_prime_priors,
  file    = model_path("perf-c-prime"),
  chains  = fit_config$chains,
  iterations = fit_config$iterations,
  warmup  = fit_config$warmup,
  refresh = fit_config$refresh
)

print(brms::fixef(m_c_prime), digits = 3)

cat("\nWORD'S COEFFICIENTS ARE NOT FOR INFERENCE (10 §11.4). Word's\n")
cat("split-half reliability is 0.445 [0.251, 0.605], and the precision\n")
cat("criterion of 06 §2.1 asks for 93 trials of the 63 that exist. Its\n")
cat("rows are reported so the model is complete, not so they can be read.\n")

# The dependency structure, made legible (10 §4) ----
#
# Item 1 of §4: pull the correlations out of the posterior draws rather
# than reading VarCorr() point estimates, so they can be plotted with
# their uncertainty.
draws <- brms::as_draws_df(m_c_prime)

correlation_pairs <- list(
  c("word", "angle"), c("word", "color"), c("angle", "color")
)

correlation_draws <-
  purrr::map(
    correlation_pairs,
    function(pair) {
      column <- paste0("cor_id__", responses[[pair[1]]], "_Intercept__",
                       responses[[pair[2]]], "_Intercept")
      if (!column %in% names(draws)) {
        stop("Parameter not found: ", column, "\nAvailable: ",
             paste(grep("^cor_id", names(draws), value = TRUE),
                   collapse = ", "))
      }
      tibble::tibble(
        pair = paste(labels[[pair[1]]], "and", labels[[pair[2]]]),
        r    = draws[[column]]
      )
    }
  ) |>
  purrr::list_rbind()

correlation_summary <-
  correlation_draws |>
  dplyr::summarise(
    median = stats::median(.data$r),
    lower  = stats::quantile(.data$r, 0.025),
    upper  = stats::quantile(.data$r, 0.975),
    "P(r < 0)" = mean(.data$r < 0),
    .by = "pair"
  )

cat("\nParticipant-level correlations between features:\n\n")
print(as.data.frame(correlation_summary), row.names = FALSE, digits = 3)

saveRDS(correlation_summary,
        fs::path(result_dir, paste0(fit_config$prefix, "perf-correlations.rds")))

cat("\nRead these against 11 §13.3, whose raw partial correlations sit near\n")
cat("the -0.5 that closure induces on its own. These are not closed, so\n")
cat("the sign carries information: negative would be a genuine trade-off,\n")
cat("positive means participants good at one feature tend to be good at\n")
cat("the other, and the trade-off the task imposes is a within-trial\n")
cat("constraint rather than a between-person one.\n")

# Item 2 of §4: one readable plot per pair, zero marked.
p_correlations <-
  correlation_draws |>
  ggplot(aes(x = .data$r, y = .data$pair, fill = .data$pair)) +
  geom_vline(xintercept = 0, linetype = "dashed", linewidth = 0.2) +
  ggplot2::stat_summary(
    fun = stats::median,
    fun.min = \(x) stats::quantile(x, 0.025),
    fun.max = \(x) stats::quantile(x, 0.975),
    geom = "pointrange", size = 0.25, orientation = "y"
  ) +
  scale_x_continuous(limits = c(-1, 1)) +
  labs(
    x = "Participant-level correlation between features",
    y = NULL,
    title = "Does doing well on one feature\ncost you on another?",
    caption = paste(
      "Random-intercept correlations from the multivariate model,\nwith",
      "95% credible intervals."
    )
  ) +
  theme_pdf(legend.position = "none")

save_ggplot("inst/scripts/figures/p3-feature-correlations.pdf",
            p_correlations, ncol = 1, height = 60, return = TRUE)

# Figure 4: partial pooling made visible (10 §4, item 3) ----
observed_means <-
  model_data |>
  compose_features(id) |>
  dplyr::select("id", tidyselect::starts_with("mean_")) |>
  tidyr::pivot_longer(tidyselect::starts_with("mean_"),
                      names_to = "feature", values_to = "observed",
                      names_prefix = "mean_")

# Model-implied means come from posterior_epred(), NOT from
# plogis(intercept + random effect). Two reasons, both of which broke the
# first version of this figure:
#
#   - for word the linear predictor is ZOIB's `mu`, the mean of the Beta
#     component conditional on the score being strictly inside (0, 1). The
#     ZOIB mean is zoi * coi + (1 - zoi) * mu, and with 91% of word trials
#     at exactly 1 those are wildly different: plogis(-0.78) = 0.31 against
#     an observed mean near 0.93.
#   - the intercept sits at vviq = 0, which is 16 to 80 units outside the
#     data, so even the plain-Beta features came out displaced.
#
# posterior_epred() handles the response scale, the inflation components
# and each participant's own covariate values in one go.
fitted_means <-
  purrr::map(
    features,
    function(f) {
      responded <- model_data[[paste0("responded_", f)]]
      epred <- brms::posterior_epred(m_c_prime, resp = responses[[f]])
      tibble::tibble(
        id = model_data$id[responded],
        feature = f,
        modelled = apply(epred, 2, mean)
      ) |>
        dplyr::summarise(modelled = mean(.data$modelled),
                         .by = c("id", "feature"))
    }
  ) |>
  purrr::list_rbind()

shrinkage_data <-
  dplyr::inner_join(observed_means, fitted_means, by = c("id", "feature")) |>
  dplyr::mutate(feature = factor(labels[.data$feature],
                                 levels = unname(labels)))

p_shrinkage <-
  shrinkage_data |>
  ggplot(aes(x = .data$observed, y = .data$modelled, colour = .data$feature)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed",
              linewidth = 0.2) +
  geom_point(size = 1, alpha = 0.7) +
  facet_wrap(~ feature) +
  scale_discrete_feature(aesthetics = "colour") +
  labs(
    x = "Observed mean, responded trials",
    y = "Model-implied mean",
    title = "Partial pooling: where the model disagrees with the raw average",
    caption = paste(
      "Points off the diagonal are participants whose estimate has been",
      "pulled toward the group, most visibly those with few trials."
    )
  ) +
  theme_pdf(legend.position = "none")

save_ggplot("inst/scripts/figures/p4-shrinkage.pdf",
            p_shrinkage, ncol = 2, height = 70, return = TRUE)

# Figure 5: the A-versus-C-prime contrast (10 §4, item 4) ----
#
# The narrative payoff of §1. The same quantity, the floor-group offset,
# estimated by the model that ignores the dependency and by the model
# that respects it.
contrast_data <-
  dplyr::bind_rows(
    purrr::imap(
      option_a,
      \(fit, feature) {
        # NOT named `estimate`: tibble() exposes each column to the
        # expressions after it, so a column called `estimate` would shadow
        # this vector and the next line would index into a length-1 double
        values <- brms::fixef(fit)["complete_aphantfloor", ]
        tibble::tibble(feature = feature, model = "A: independent",
                       estimate = values[["Estimate"]],
                       lower = values[["Q2.5"]], upper = values[["Q97.5"]])
      }
    ) |> purrr::list_rbind(),
    purrr::map(
      features,
      function(f) {
        row <- paste0(responses[[f]], "_complete_aphantfloor")
        values <- brms::fixef(m_c_prime)[row, ]
        tibble::tibble(feature = labels[[f]], model = "C-prime: correlated",
                       estimate = values[["Estimate"]],
                       lower = values[["Q2.5"]], upper = values[["Q97.5"]])
      }
    ) |> purrr::list_rbind()
  ) |>
  dplyr::mutate(feature = factor(.data$feature, levels = unname(labels)))

p_contrast <-
  contrast_data |>
  ggplot(aes(x = .data$estimate, y = .data$feature, colour = .data$model)) +
  geom_vline(xintercept = 0, linetype = "dashed", linewidth = 0.2) +
  geom_pointrange(
    aes(xmin = .data$lower, xmax = .data$upper),
    position = position_dodge(width = 0.4), size = 0.25
  ) +
  scale_colour_manual(values = unname(palette.colors()[c(9, 6)]), name = NULL) +
  labs(
    x = "Floor-group offset, log-odds",
    y = NULL,
    title = "What respecting the dependency\nstructure changes",
    caption = paste(
      "Same quantity, estimated by three independent models\nand by one",
      "model with correlated participant effects."
    )
  ) +
  theme_pdf()

save_ggplot("inst/scripts/figures/p5-option-a-vs-c.pdf",
            p_contrast, ncol = 1, height = 65, return = TRUE)

# ------------------------------------------------------------------------- #
# 6. Was conditioning on responding legitimate? ----
# ------------------------------------------------------------------------- #
rule("6. Joint propensity and accuracy, orientation only")

cat("\nEverything above is conditional on responding, which conditions on a\n")
cat("selected subsample. If participants who abstain more also perform\n")
cat("differently when they do answer, those estimates are biased, and no\n")
cat("separate analysis can detect it. This model estimates the one\n")
cat("quantity that would: the participant-level correlation between\n")
cat("response propensity and conditional accuracy (10 §11.6).\n")
cat("\nOrientation only, deliberately. It has the highest non-response and\n")
cat("the cleanest Beta, so it is where the problem surfaces first, and a\n")
cat("convergence failure on all three at once would teach nothing.\n")

# save_pars: see 09-joint-model.R. Applied here and NOT to the C-prime
# model above, because figure p4 calls ranef() on that one and needs the
# per-participant deviations this would discard.
m_joint <- fit_brms_model(
  formula =
    brms::bf(responded_angle ~ vviq + complete_aphant + (1 | p | id),
             family = brms::bernoulli()) +
    brms::bf(score_angle | subset(responded_angle) ~
               vviq + complete_aphant + (1 | p | id),
             family = brms::Beta()) +
    brms::set_rescor(FALSE),
  data   = model_data,
  prior  = c(
    performance_priors(c("respondedangle", "scoreangle")),
    brms::prior("lkj(2)", class = "cor")
  ),
  save_pars = brms::save_pars(group = FALSE),
  file   = model_path("perf-joint-orientation"),
  chains = fit_config$chains,
  iterations = fit_config$iterations,
  warmup = fit_config$warmup,
  refresh = fit_config$refresh
)

print(brms::fixef(m_joint), digits = 3)

joint_draws <- brms::as_draws_df(m_joint)
joint_column <- "cor_id__respondedangle_Intercept__scoreangle_Intercept"
if (!joint_column %in% names(joint_draws)) {
  stop("Parameter not found: ", joint_column, "\nAvailable: ",
       paste(grep("^cor_id", names(joint_draws), value = TRUE),
             collapse = ", "))
}

joint_correlation <- report_rope(
  joint_draws[[joint_column]],
  outcome_sd = 1,      # a correlation is already on its own scale
  rope_factor = 0.1    # so the ROPE is |r| < 0.1
)

cat("\nCorrelation between response propensity and conditional accuracy:\n\n")
print(as.data.frame(joint_correlation), row.names = FALSE)

saveRDS(joint_correlation,
        fs::path(result_dir, paste0(fit_config$prefix, "perf-joint-cor.rds")))

cat("\nWhat this decides, stated before the number was seen (10 §11.6):\n")
cat("  inside the ROPE -> the separation is vindicated, 05 keeps accuracy,\n")
cat("    08 keeps propensity, and both are reported separately.\n")
cat("  outside the ROPE -> the joint model becomes primary for orientation\n")
cat("    and colour, and 06 inherits an explicit caveat, since its entire\n")
cat("    compositional analysis is responders-only.\n")

p_joint <-
  tibble::tibble(r = joint_draws[[joint_column]]) |>
  ggplot(aes(x = .data$r)) +
  geom_vline(xintercept = c(-0.1, 0.1), linetype = "dotted",
             linewidth = 0.2) +
  geom_vline(xintercept = 0, linetype = "dashed", linewidth = 0.2) +
  geom_density(fill = unname(palette.colors()[4]), colour = NA, alpha = 0.7) +
  scale_x_continuous(limits = c(-1, 1)) +
  labs(
    x = "Correlation between propensity to respond\nand accuracy when responding",
    y = "Posterior density",
    title = "Was analysing responders only legitimate?",
    caption = "Dotted lines mark the region of practical equivalence."
  ) +
  theme_pdf()

save_ggplot("inst/scripts/figures/p6-propensity-accuracy.pdf",
            p_joint, ncol = 1, height = 60, return = TRUE)

rule("Done. Figures in inst/scripts/figures/, models in inst/models/.")
