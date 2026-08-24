# ------------------------------------------------------------------------- #
# 09-floor-group.R ----
#
# The floor-group model, per 09-floor-group.md. Moved out of
# 03b-validity-checks.R: this asks a substantive question about complete
# aphantasia rather than about whether the instrument works, so it is
# analysis, not a validity check.
#
# Sample: v1 only, and v1-only by construction rather than by scope. The
# model needs both a floor group and a populated above-floor continuum to
# fit a line through; v2 (8 aphantasia to 1 typical) and v3 (17 to 4)
# cannot supply the second.
#
# Doc references below are to the planning set in `inst/planning/`.
# ------------------------------------------------------------------------- #

devtools::load_all()

rule <- function(text) cat("\n", strrep("-", 70), "\n", text, "\n", sep = "")
engagement_thresholds <- c(Word = 32L, Orientation = 22L, Colour = 29L)

v1_participants <- all_data |>
  dplyr::filter(grepl("^expe_block", expe_phase), version == "v1") |>
  dplyr::select(id, vviq = vviq_total_score,
                score_word, score_angle, score_color,
                responded_word, responded_angle, responded_color) |>
  tidyr::pivot_longer(c(tidyselect::starts_with("score_"),
                        tidyselect::starts_with("responded_")),
                      names_to = c(".value", "feature"),
                      names_pattern = "(score|responded)_(word|angle|color)") |>
  dplyr::mutate(feature = factor(feature, levels = c("word", "angle", "color"),
                                 labels = c("Word", "Orientation", "Colour"))) |>
  dplyr::summarise(score_responded_only = mean(score[responded]),
                   n_answered = sum(responded), n_trials = dplyr::n(),
                   vviq = dplyr::first(vviq), .by = c(id, feature)) |>
  dplyr::mutate(clears_threshold = n_answered >= engagement_thresholds[feature])

# ------------------------------------------------------------------------- #
# §2.6  Floor-group model: is complete aphantasia its own group? ----
# ------------------------------------------------------------------------- #
rule("2.6  Floor-group model (idiom carried over from aphantasiaEmotions)")

# VVIQ has a hard floor at 16, and complete aphantasics pile there with no
# variance among themselves. A slope specific to that group is therefore
# unidentifiable; what the data can support is a single offset, how far
# their mean sits from where the above-floor relationship predicts it.
# Same formula as aphantasiaEmotions' floor-group model, minus the
# study-level random effects (one study here).
floor_data <- v1_participants |>
  dplyr::filter(!is.na(vviq)) |>
  dplyr::mutate(complete_aphant = factor(
    dplyr::if_else(vviq == 16, "floor", "above_floor"),
    levels = c("above_floor", "floor")))

cat("\nVVIQ distribution in v1, the premise this model rests on:\n\n")
floor_data |>
  dplyr::distinct(id, vviq) |>
  dplyr::count(vviq_band = cut(vviq, c(15, 16, 25, 40, 60, 80),
                               include.lowest = TRUE)) |>
  as.data.frame() |>
  print(row.names = FALSE)

floor_offset <- function(this_feature) {
  fit <- stats::lm(score_responded_only ~ vviq + complete_aphant,
                   data = dplyr::filter(floor_data, feature == this_feature,
                                        clears_threshold,
                                        !is.na(score_responded_only)))
  coefficients <- summary(fit)$coefficients
  interval <- stats::confint(fit)["complete_aphantfloor", ]
  tibble::tibble(
    feature = this_feature,
    above_floor_slope = coefficients["vviq", 1],
    slope_p = coefficients["vviq", 4],
    floor_offset = coefficients["complete_aphantfloor", 1],
    offset_lower = interval[1], offset_upper = interval[2],
    offset_p = coefficients["complete_aphantfloor", 4]
  )
}

cat("\nAccuracy (responded trials only, threshold-clearing participants):\n\n")
purrr::map(levels(floor_data$feature), floor_offset) |>
  purrr::list_rbind() |>
  as.data.frame() |>
  print(row.names = FALSE, digits = 3)

cat("\nReporting propensity, same decomposition:\n\n")
purrr::map(levels(floor_data$feature), function(this_feature) {
  fit <- stats::glm(
    cbind(n_answered, n_trials - n_answered) ~ vviq + complete_aphant,
    data = dplyr::filter(floor_data, feature == this_feature),
    family = stats::quasibinomial())
  coefficients <- summary(fit)$coefficients
  tibble::tibble(feature = this_feature,
                 above_floor_slope = coefficients["vviq", 1],
                 slope_p = coefficients["vviq", 4],
                 floor_offset = coefficients["complete_aphantfloor", 1],
                 offset_p = coefficients["complete_aphantfloor", 4])
}) |>
  purrr::list_rbind() |>
  as.data.frame() |>
  print(row.names = FALSE, digits = 3)

cat("\nFragility check: how well is the above-floor line constrained?\n")
above_floor <- dplyr::filter(floor_data, feature == "Orientation",
                             complete_aphant == "above_floor")
cat("  above-floor n:", nrow(above_floor),
    "| median VVIQ:", stats::median(above_floor$vviq),
    "| n below VVIQ 40:", sum(above_floor$vviq < 40), "\n")
cat("  The line is anchored by a cluster at 50-80 plus a handful of\n")
cat("  scattered points, so extrapolating it to 16 leans on a linearity\n")
cat("  assumption the data barely constrains. Treat as exploratory.\n")
