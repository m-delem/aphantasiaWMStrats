# ------------------------------------------------------------------------- #
# make-poster-figures.R ----
#
# The three poster figures, at A0 print size. Run from the package root.
#
# Sizes assume a two-column A0 portrait with the figures in the right
# column at roughly 340 mm wide. base_size = 26 is large for a figure but
# correct for a poster read from two metres.
#
# f3 is the hero. The ternary (f2) was tried as the hero first and does not
# work at distance: the two group clouds overlap almost completely, which
# is honest but carries nothing from three metres. Use it as the stylised
# concept graphic in the top band instead, or beside f3 as supporting
# detail.
# ------------------------------------------------------------------------- #

devtools::load_all()
library(dplyr)
library(ggplot2)

output_dir <- here::here("inst/scripts/figures/poster")
fs::dir_create(output_dir)

v1 <- get_data("v1") |> dplyr::filter(grepl("^expe_block", expe_phase))

participant_info <- v1 |>
  summarise(
    vviq = first(vviq_total_score),
    imagery_group = first(vviq_group_2),
    parity_rate = (sum(responded_parity_1) + sum(responded_parity_2)) /
      (2 * n()),
    .by = id
  )

parts <- compose_features(filter(v1, id %in% engaged_ids(v1)), id)
parts <- parts[stats::complete.cases(parts), ]

# --------------------------------------------------------------------- #
# f2. The ternary ----
# --------------------------------------------------------------------- #

ternary_data <- parts |>
  left_join(participant_info, by = "id") |>
  filter(!is.na(imagery_group))

f2 <- plot_composition_ternary(
  ternary_data,
  group = as.character(ternary_data$imagery_group),
  base_size = 26,
  point_size = 4.5
  ) +
  labs(caption = NULL) +
  theme(
    legend.position = "bottom",
    legend.title = element_blank(),
    plot.margin = margin_auto(7)
  )

save_ggplot(fs::path(output_dir, "f2-ternary.pdf"), f2,
            width = 340, height = 300)

# --------------------------------------------------------------------- #
# f3. Allocation, the hero figure ----
# --------------------------------------------------------------------- #

composition_model <- readRDS(here::here("inst/models/comp-floor.rds"))
composition_data <- composition_model$data

grid <- tibble::tibble(
  vviq = seq(16, 80, length.out = 200),
  complete_aphant = factor("above_floor", levels = c("above_floor", "floor")),
  parity_rate = stats::median(composition_data$parity_rate)
)
above_floor <- brms::posterior_epred(composition_model, newdata = grid,
                                     resp = "ilr1")

floor_row <- grid[1, ]
floor_row$complete_aphant <- factor("floor",
                                    levels = c("above_floor", "floor"))
floor_draws <- as.vector(brms::posterior_epred(
  composition_model, newdata = floor_row, resp = "ilr1"))

effect <- brms::fixef(composition_model)["ilr1_complete_aphantfloor", ]

f3 <- plot_floor_group(
  observed = filter(composition_data, vviq > 16) |>
    transmute(x = vviq, y = ilr1),
  fitted = tibble::tibble(
    x = grid$vviq,
    estimate = apply(above_floor, 2, stats::median),
    lower = apply(above_floor, 2, stats::quantile, 0.025),
    upper = apply(above_floor, 2, stats::quantile, 0.975)
  ),
  floor_draws = floor_draws,
  floor_observed = filter(composition_data, vviq == 16)$ilr1,
  effect_label = sprintf("%.2f\n[%.2f, %.2f]", effect[["Estimate"]],
                         effect[["Q2.5"]], effect[["Q97.5"]]),
  # NOT "more words <-> more colour & orientation": higher ilr1 means MORE
  # words, and the floor group sits higher. The first draft had this
  # inverted, which would have reversed the poster's headline.
  y_lab = "Share of effort on WORDS,\nrelative to colour and orientation",
  base_size = 26, point_size = 4,
  left_expansion = 0.09, arrow_nudge = -5.5
)

save_ggplot(fs::path(output_dir, "f3-allocation.pdf"), f3,
            width = 340, height = 240)

# --------------------------------------------------------------------- #
# f4. Unsymbolised thinking ----
# --------------------------------------------------------------------- #

scales <- questionnaire_scales(all_data) |>
  mutate(complete_aphant = factor(
    if_else(vviq == 16, "floor", "above_floor"),
    levels = c("above_floor", "floor")))

nieq_model <- readRDS(here::here("inst/models/nieq-floor-unsymbolised.rds"))

nieq_grid <- tibble::tibble(
  vviq = seq(16, 80, length.out = 200),
  complete_aphant = factor("above_floor", levels = c("above_floor", "floor")))
nieq_above <- brms::posterior_epred(nieq_model, newdata = nieq_grid)

nieq_floor_row <- nieq_grid[1, ]
nieq_floor_row$complete_aphant <- factor("floor",
                                         levels = c("above_floor", "floor"))
nieq_floor_draws <- as.vector(
  brms::posterior_epred(nieq_model, newdata = nieq_floor_row))

f4 <- plot_floor_group(
  observed = scales |> filter(vviq > 16) |>
    transmute(x = vviq, y = nieq_unsymbolised / 100),
  fitted = tibble::tibble(
    x = nieq_grid$vviq,
    estimate = apply(nieq_above, 2, stats::median),
    lower = apply(nieq_above, 2, stats::quantile, 0.025),
    upper = apply(nieq_above, 2, stats::quantile, 0.975)
  ),
  floor_draws = nieq_floor_draws,
  floor_observed = filter(scales, vviq == 16)$nieq_unsymbolised / 100,
  # No arrow label. The finding here is the SLOPE, not the offset, and
  # labelling an offset whose interval contains zero would say the
  # opposite of what the model found.
  effect_label = NULL,
  y_lab = "Unsymbolised thinking (NIEQ)",
  base_size = 26, point_size = 4,
  left_expansion = 0.03, arrow_nudge = -4
) +
  scale_y_continuous(labels = \(x) round(100 * x), limits = c(0, 1))

save_ggplot(fs::path(output_dir, "f4-unsymbolised.pdf"), f4,
            width = 340, height = 240)
