# ------------------------------------------------------------------------- #
# 20-thesis-figures.R ----
#
# Every figure the thesis chapter (Chapter 2, Part III) draws from this
# package, as vector PDFs at their printed size. Run from the package root,
# after the models exist in inst/models (scripts 08 to 15).
#
# What each figure is for, and where it sits in the chapter:
#
#   t1  allocation at the imagery floor        results, the headline result
#   t2  every floor-group offset, one figure   results, the synthesis figure
#   t3  the four NIEQ dimensions               results, exploratory strand
#   t4  strategies named, floor vs above       results, what participants said
#   t5  behaviour against report               results, the convergence check
#   t6  partial pooling, three features        methods, why word is demoted
#
# t2 and t5 are new; the others re-render EOR figures at print size. The
# protocol figure (trial flow with screens) is TikZ and lives in the thesis
# project, not here.
#
# Sizes. The thesis is A4 with 2 cm margins, so the text width is 170 mm.
# base_size = 8 reads like the 9-10 pt captions around it. Every figure is
# designed at its final printed width and never scaled in LaTeX.
#
# Colours. The floor group is the same red as in plot_floor_group() on every
# figure, so a reader who has learnt it once keeps it. Above-floor
# participants take a viridis blue in categorical plots and the viridis
# gradient in continuous ones, which is what plot_floor_group() already does.
# ------------------------------------------------------------------------- #

devtools::load_all()
library(dplyr)
library(tidyr)
library(ggplot2)
library(patchwork)

fig_dir   <- here::here("inst/scripts/figures/thesis")
model_dir <- here::here("inst/models")
fs::dir_create(fig_dir)

load_model <- function(name) {
  path <- fs::path(model_dir, paste0(name, ".rds"))
  if (!fs::file_exists(path)) {
    stop("Model not found: ", path, ". Run the fitting scripts first.",
         call. = FALSE)
  }
  readRDS(path)
}

base         <- 8
floor_fill   <- "#C44E52"   # as in plot_floor_group()
floor_colour <- "#8B3A3E"
above_colour <- "#3B528B"   # viridis, mid-range, for categorical two-group plots
floor_levels <- c("above_floor", "floor")
floor_factor <- function(vviq) {
  factor(if_else(vviq == 16, "floor", "above_floor"), levels = floor_levels)
}

rule <- function(txt) cat("\n", strrep("-", 70), "\n", txt, "\n", sep = "")

# ------------------------------------------------------------------------- #
# 0. The frames, rebuilt exactly as the vignettes build them ----
#
# Two things need rebuilding rather than reading from a model's `$data`:
# the composition model has no participant term, so its `$data` carries no
# `id`, and the strategy figures need one.
# ------------------------------------------------------------------------- #
rule("Building the analysis frames")

v1 <- get_data("v1") |>
  filter(grepl("^expe_block", expe_phase))

participant_info <- v1 |>
  summarise(
    vviq = first(vviq_total_score),
    imagery_group = first(vviq_group_2),
    parity_rate = (sum(responded_parity_1) + sum(responded_parity_2)) /
      (2 * n()),
    .by = id
  )

all_parts <- compose_features(v1, id) |>
  filter(complete.cases(pick(everything())))
engaged_parts <- filter(all_parts, id %in% engaged_ids(v1))

# `reported`: engaged, with or without a vividness score (the convergence
# check, t5, does not need one). `model_data`: the 79 the composition model
# was fitted on.
reported <- engaged_parts |>
  bind_cols(ilr_coords(select(engaged_parts, starts_with("part_")))) |>
  left_join(participant_info, by = "id") |>
  mutate(complete_aphant = floor_factor(vviq))
model_data <- filter(reported, !is.na(vviq))

composition_model <- load_model("comp-floor")
stopifnot(nrow(model_data) == nrow(composition_model$data))
cat("Composition frame:", nrow(model_data), "participants\n")

# ------------------------------------------------------------------------- #
# t1. Allocation at the imagery floor ----
#
# The VVIQ histogram stacked above the floor-group panel, as the performance
# page does for orientation: the histogram is the argument for the model's
# shape, and the panel is the result.
# ------------------------------------------------------------------------- #
rule("t1: allocation at the floor")

grid <- tibble(
  vviq = seq(16, 80, length.out = 200),
  complete_aphant = factor("above_floor", levels = floor_levels),
  parity_rate = median(model_data$parity_rate)
)
above_floor <-
  brms::posterior_epred(composition_model, newdata = grid, resp = "ilr1")
floor_row <- grid[1, ]
floor_row$complete_aphant <- factor("floor", levels = floor_levels)
floor_draws <-
  as.vector(brms::posterior_epred(
    composition_model,
    newdata = floor_row,
    resp = "ilr1"))
effect <- brms::fixef(composition_model)["ilr1_complete_aphantfloor", ]

t1_main <-
  plot_floor_group(
    observed = model_data |>
      filter(vviq > 16) |>
      transmute(x = vviq, y = ilr1),
    fitted = tibble(
      x = grid$vviq,
      estimate = apply(above_floor, 2, median),
      lower = apply(above_floor, 2, quantile, 0.025),
      upper = apply(above_floor, 2, quantile, 0.975)
    ),
    floor_draws = floor_draws,
    floor_observed = filter(model_data, vviq == 16)$ilr1,
    effect_label = sprintf("%.2f\n[%.2f, %.2f]", effect[["Estimate"]],
                           effect[["Q2.5"]], effect[["Q97.5"]]),
    y_lab = "Allocation to words (ilr 1)\nagainst orientation and colour",
    base_theme = theme_minimal,
    base_size = base,
    point_size = 1.3,
    left_expansion = 0.11,
    arrow_nudge = -5.5,
    show_sample_mean = FALSE,
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.minor.y = element_blank(),
    axis.ticks.x = element_line(color = "grey82", linewidth = 0.2)
  )

t1_hist <-
  plot_vviq_histogram(
    base_theme = theme_minimal,
    model_data$vviq,
    base_size = base,
    left_expansion = 0.18,
    y_lab = "Participant\ncount",
    axis.text.x = element_blank(),
    axis.line.x = element_line(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.minor.y = element_blank(),
  ) +
  scale_y_continuous(expand = expansion(c(0, 0.05)))

t1 <- t1_hist / t1_main + plot_layout(heights = c(1, 4))

save_ggplot(fs::path(fig_dir, "t1-allocation-floor.pdf"), t1, height = 100)

# ------------------------------------------------------------------------- #
# t2. Every floor-group offset the study estimates ----
#
# New. No EOR page carries this because each page owns its own models. Four
# panels, one per family of outcome, each in its model's native units with
# its own x-axis: log-ratio units for the composition, log-odds for the six
# joint-model responses, logit for the NIEQ Beta models. The units are not
# comparable across panels and the figure does not pretend they are; what
# is comparable is which intervals clear zero. The ROPE is drawn only where
# the EOR defines one (a tenth of the outcome SD, composition page).
#
# Stacked with patchwork rather than facet_grid because facet_grid cannot
# give rows different x scales.
# ------------------------------------------------------------------------- #
rule("t2: floor-group offsets across models")

floor_rows <- function(model, responses = NULL, labels = responses) {
  fe <- brms::fixef(model)
  rows <- if (is.null(responses)) "complete_aphantfloor" else
    paste0(responses, "_complete_aphantfloor")
  stopifnot(all(rows %in% rownames(fe)))
  tibble(
    outcome  = if (is.null(responses)) "single" else labels,
    estimate = fe[rows, "Estimate"],
    lower    = fe[rows, "Q2.5"],
    upper    = fe[rows, "Q97.5"]
  )
}

joint_model <- load_model("joint-full")
nieq_dims   <- c(unsymbolised = "Unsymbolised thinking",
                 inner_voice = "Inner voice",
                 emotions = "Emotions",
                 sensory_focus = "Sensory focus")
nieq_models <- lapply(names(nieq_dims), \(d) load_model(paste0("nieq-floor-", d)))
names(nieq_models) <- names(nieq_dims)

offsets <- list(
  allocation = floor_rows(
    composition_model, c("ilr1", "ilr2"),
    c("Words against orientation\nand colour (ilr1)",
      "Colour against\norientation (ilr2)")) |>
    mutate(rope = 0.1 * c(sd(model_data$ilr1), sd(model_data$ilr2))),
  reporting = floor_rows(
    joint_model, c("respondedword", "respondedangle", "respondedcolor"),
    c("Word", "Orientation", "Colour")),
  accuracy = floor_rows(
    joint_model, c("scoreword", "scoreangle", "scorecolor"),
    c("Word", "Orientation", "Colour")),
  nieq = bind_rows(lapply(names(nieq_models), \(d)
    mutate(floor_rows(nieq_models[[d]]), outcome = nieq_dims[[d]])))
)

panel_titles <- c(
  allocation = "Allocation (log-ratio units)",
  reporting  = "Willingness to report a feature (log-odds)",
  accuracy   = "Accuracy when reporting (log-odds)",
  nieq       = "Inner experience, NIEQ (logit of the 0-100 score)"
)

forest_panel <- function(df, title, first = FALSE, last = FALSE) {
  df <- df |>
    mutate(
      outcome = factor(outcome, levels = rev(unique(outcome))),
      clears  = if_else(lower > 0 | upper < 0,
                        "95% interval excludes zero",
                        "95% interval includes zero")
    )
  p <-
    ggplot(df, aes(x = estimate, y = outcome)) +
    geom_vline(
      xintercept = 0,
      linetype = "dashed",
      linewidth = 0.3,
      colour = "grey60")
  if ("rope" %in% names(df)) {
    p <- p +
      geom_segment(
        aes(x = -rope, xend = rope, y = outcome, yend = outcome),
        colour = "grey82",
        linewidth = 2.8,
        lineend = "butt"
    )
  }
  p +
    geom_pointrange(
      aes(xmin = lower, xmax = upper, shape = clears),
      colour = floor_colour, fill = "white",
      size = 0.35, linewidth = 0.45
    ) +
    scale_shape_manual(
      values = c("95% interval excludes zero" = 16,
                 "95% interval includes zero" = 21),
      drop = FALSE, name = NULL
    ) +
    labs(
      x = if (last) {
        "Floor-group offset, posterior mean and 95% interval"} else NULL,
      y = NULL,
      title = title) +
    theme_pdf(
      base_theme = theme_bw,
      base_size = base,
      title_hjust = 0,
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      plot.title = element_text(size = rel(1), face = "bold"),
      plot.title.position = "plot",
      legend.position = if (first) {"top"} else "none",
      legend.margin = margin_auto(5),
      legend.text = element_text(size = 7),
      legend.justification = "right",
      axis.title.x = element_text(size = 7, hjust = 1),
      axis.text.x = element_text(size = 5)
    )
}

t2 <-
  wrap_plots(
    forest_panel(offsets$allocation, panel_titles["allocation"], first = TRUE),
    forest_panel(offsets$reporting,  panel_titles["reporting"]),
    forest_panel(offsets$accuracy,   panel_titles["accuracy"]),
    forest_panel(offsets$nieq,       panel_titles["nieq"], last = TRUE),
    ncol = 1,
    heights = c(2, 3, 3, 4)
  )

save_ggplot(fs::path(fig_dir, "t2-floor-offsets.pdf"), t2, height = 150)

# ------------------------------------------------------------------------- #
# t3. The four NIEQ dimensions in the floor-group form ----
#
# Pooled across versions, as the beyond-vividness page argues is allowed
# for questionnaires and nowhere else. The arrow label is the difference in
# expected score on the 0-100 scale, computed from the posterior predictions
# rather than read off the logit coefficient, so that the label and the
# arrow measure the same thing.
# ------------------------------------------------------------------------- #
rule("t3: NIEQ floor-group panels")

scales <- questionnaire_scales(all_data)

nieq_panel <- function(dim, label, x_lab = NULL) {
  model <- nieq_models[[dim]]
  grid <- tibble(
    vviq = seq(16, 80, length.out = 200),
    complete_aphant = factor("above_floor", levels = floor_levels)
  )
  above <- brms::posterior_epred(model, newdata = grid)
  floor_row <- grid[1, ]
  floor_row$complete_aphant <- factor("floor", levels = floor_levels)
  floor_draws <- as.vector(brms::posterior_epred(model, newdata = floor_row))
  delta <- 100 * (floor_draws - above[, 1])   # column 1 of `grid` is VVIQ = 16

  # the slope above the floor, two ways: the coefficient the EOR reports
  # (logit per VVIQ point), and its consequence on the 0-100 scale across
  # the above-floor range, from the same posterior predictions as the curve
  slope_logit <- brms::fixef(model)["vviq", ]
  i17 <- which.min(abs(grid$vviq - 17))
  slope_points <- 100 * (above[, ncol(above)] - above[, i17])
  slope_caption <- sprintf(
    "Slope above the floor: %.3f [%.3f, %.3f] logit per VVIQ point\n%+.0f points [%+.0f, %+.0f] from VVIQ 17 to 80",
    slope_logit[["Estimate"]], slope_logit[["Q2.5"]], slope_logit[["Q97.5"]],
    median(slope_points), quantile(slope_points, 0.025),
    quantile(slope_points, 0.975)
  )

  observed <- tibble(x = scales$vviq, y = scales[[paste0("nieq_", dim)]] / 100)

  plot_floor_group(
    observed = filter(observed, x > 16),
    fitted = tibble(
      x = grid$vviq,
      estimate = apply(above, 2, median),
      lower = apply(above, 2, quantile, 0.025),
      upper = apply(above, 2, quantile, 0.975)
    ),
    floor_draws = floor_draws,
    floor_observed = filter(observed, x == 16)$y,
    effect_label = sprintf("%+.0f\n[%+.0f, %+.0f]", median(delta),
                           quantile(delta, 0.025), quantile(delta, 0.975)),
    caption = slope_caption,
    x_lab = x_lab, y_lab = label,
    base_theme = theme_bw,
    base_size = base,
    point_size = 1.1,
    left_expansion = 0.1,
    arrow_nudge = -7,
    show_sample_mean = FALSE,
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.minor.y = element_blank(),
    plot.caption = element_text(
      hjust = 1,
      size = rel(0.8),
      colour = "grey30",
      lineheight = 1.1),
    plot.caption.position = "plot"
  ) +
    scale_y_continuous(labels = \(x) round(100 * x), limits = c(0, 1))
}

t3 <- wrap_plots(
  nieq_panel("unsymbolised",  nieq_dims[["unsymbolised"]]),
  nieq_panel("inner_voice",   nieq_dims[["inner_voice"]]),
  nieq_panel("emotions",      nieq_dims[["emotions"]],      x_lab = "VVIQ total score"),
  nieq_panel("sensory_focus", nieq_dims[["sensory_focus"]], x_lab = "VVIQ total score"),
  ncol = 2
)
save_ggplot(fs::path(fig_dir, "t3-nieq-floor.pdf"), t3, ncol = 2, height = 125)

# ------------------------------------------------------------------------- #
# t4. Strategies named, floor against above floor ----
#
# The composition page's strategy table as a dumbbell plot: one row per
# feature x strategy, the two groups as the two ends. The table's message
# survives the redrawing: no floor participant named imagery for anything,
# and orientation is where the floor group names no strategy at all.
# ------------------------------------------------------------------------- #
rule("t4: strategies named")

v1_people <- distinct(get_data("v1"), id, .keep_all = TRUE)
strategy_items <- bind_rows(v1_people$strategy_items)
strategy_items$id <- v1_people$id

strategy_labels <- c(
  repetition       = "Verbal repetition",
  mental_image     = "Mental imagery",
  semantic         = "Semantic association",
  spatial_body     = "Body-centred spatial",
  spatial_cardinal = "Cardinal directions",
  none             = "No strategy"
)

strategy_profile <-
  strategy_items |>
  select(id, matches("q0[123]")) |>
  pivot_longer(-id, names_to = "item", values_to = "strategy") |>
  filter(strategy %in% names(strategy_labels)) |>
  mutate(feature = case_when(
    grepl("colors", item) ~ "Colour",
    grepl("orientations", item) ~ "Orientation",
    TRUE ~ "Word"
  )) |>
  inner_join(distinct(model_data, id, complete_aphant), by = "id") |>
  mutate(group = if_else(complete_aphant == "floor",
                         "VVIQ floor", "Above floor")) |>
  distinct(id, group, feature, strategy)

group_sizes <-
  strategy_profile |>
  distinct(id, group) |>
  count(group, name = "participants")

strategy_table <-
  strategy_profile |>
  count(feature, strategy, group) |>
  complete(feature, strategy, group, fill = list(n = 0L)) |>
  left_join(group_sizes, by = "group") |>
  mutate(percent = 100 * n / participants,
         label = strategy_labels[strategy])

# rows ordered within each feature by the above-floor percentage, and made
# unique across features with a prefix the axis labels strip off
row_order <-
  strategy_table |>
  filter(group == "Above floor") |>
  arrange(feature, desc(percent)) |>
  mutate(row = paste0(feature, "|", label)) |>
  pull(row)

strategy_long <-
  strategy_table |>
  mutate(
    row = factor(paste0(feature, "|", label), levels = rev(row_order)),
    feature = factor(feature, levels = c("Word", "Orientation", "Colour")),
    group = factor(group, levels = c("Above floor", "VVIQ floor"))
  )

group_legend <-
  group_sizes |>
  mutate(text = sprintf("%s (n = %d)", group, participants))

legend_labels <- setNames(group_legend$text, group_legend$group)

t4 <-
  ggplot(strategy_long, aes(x = percent, y = row)) +
  geom_line(aes(group = row), colour = "grey70", linewidth = 0.5) +
  geom_point(aes(colour = group, shape = group), size = 2) +
  scale_colour_manual(
    values = c("Above floor" = above_colour, "VVIQ floor" = floor_colour),
    labels = legend_labels, name = NULL) +
  scale_shape_manual(
    values = c("Above floor" = 16, "VVIQ floor" = 17),
    labels = legend_labels, name = NULL) +
  scale_y_discrete(labels = \(x) sub("^.*\\|", "", x)) +
  scale_x_continuous(limits = c(0, 100), breaks = seq(0, 100, 25),
                     labels = \(x) paste0(x, "%")) +
  facet_grid(feature ~ ., scales = "free_y", space = "free_y") +
  labs(x = "Participants naming the strategy for that feature", y = NULL) +
  theme_pdf(
    base_theme = theme_bw,
    base_size = base,
    strip.text.y = element_text(angle = 0),
    panel.grid.major.x = element_line(colour = "grey92", linewidth = 0.2),
    legend.position = "top",
    strip.background.y = element_rect(fill = "white", color = "transparent"),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
  )

save_ggplot(
  fs::path(fig_dir, "t4-strategies-named.pdf"), t4,
  ncol = 2, height = 105)

# ------------------------------------------------------------------------- #
# t5. Behaviour against report: the convergence check ----
#
# New as a figure. Participants who said they tried to keep one feature for
# points against those who said two or three, on the verbal coordinate.
# Every engaged participant with a report enters, vividness score or not,
# which is why this runs on `reported` and not `model_data`: the number in
# the text (rho = -0.33, n = 76) comes from that frame.
# ------------------------------------------------------------------------- #
rule("t5: convergence with what participants reported")

prioritisation <-
  strategy_items |>
  select(id, starts_with("strats_cfa_q04")) |>
  pivot_longer(-id, names_to = "slot", values_to = "feature") |>
  filter(!is.na(feature)) |>
  summarise(kept = sum(feature != "none"), .by = id)

convergence <-
  inner_join(reported, prioritisation, by = "id") |>
  filter(kept > 0)

kept_test <- correlation_test(convergence$ilr1, convergence$kept)
cat(sprintf("Spearman rho = %.3f, p = %.4f, n = %d\n",
            kept_test$rho, kept_test$p, kept_test$n))

kept_summary <-
  convergence |>
  summarise(n = n(), mean = mean(ilr1), se = sd(ilr1) / sqrt(n()), .by = kept) |>
  mutate(lower = mean - qt(0.975, n - 1) * se,
         upper = mean + qt(0.975, n - 1) * se,
         kept = factor(kept))

kept_labels <-
  setNames(
    sprintf("%s feature%s\n(n = %d)", kept_summary$kept,
            ifelse(kept_summary$kept == "1", "", "s"), kept_summary$n),
    as.character(kept_summary$kept)
  )

t5 <-
  ggplot(convergence, aes(x = factor(kept), y = ilr1)) +
  geom_hline(yintercept = mean(convergence$ilr1), linetype = "dashed",
             linewidth = 0.25, colour = "grey65") +
  geom_jitter(width = 0.12, height = 0, size = 1.1, alpha = 0.45,
              colour = "grey35") +
  geom_pointrange(
    data = kept_summary,
    aes(x = kept, y = mean, ymin = lower, ymax = upper),
    colour = floor_colour, size = 0.4, linewidth = 0.5
  ) +
  annotate(
    "text",
    x = 3.45, y = max(convergence$ilr1),
    hjust = 1, vjust = 1,
    size = base * 0.3, colour = "grey30", family = "Montserrat",
    label = sprintf(
      "Spearman rho = %.2f\np = %.3f, n = %d",
      kept_test$rho, kept_test$p, kept_test$n)
  ) +
  scale_x_discrete(labels = kept_labels) +
  labs(
    x = "Features participants said they tried to keep for points",
    y = "Allocation to words (ilr1)") +
  theme_pdf(
    base_size = base,
    axis.title.x = element_text(margin = margin(t = 7))
    )

save_ggplot(fs::path(fig_dir, "t5-convergence.pdf"), t5, height = 75)

# ------------------------------------------------------------------------- #
# t6. Partial pooling: what an unusable individual-differences measure ----
#     looks like from the model's side
#
# From the performance page. Observed participant means against the
# correlated model's implied means; word collapses to one value.
# ------------------------------------------------------------------------- #
rule("t6: partial pooling")

correlated <- load_model("perf-c-prime")

perf_data <-
  v1 |>
  filter(id %in% engaged_ids(v1)) |>
  left_join(participant_info, by = "id") |>
  filter(!is.na(vviq)) |>
  mutate(
    complete_aphant = floor_factor(vviq),
    score_color = squeeze_boundaries(score_color, n = sum(responded_color))
  )
stopifnot(nrow(perf_data) == nrow(correlated$data))

feature_labels <- c(word = "Word", angle = "Orientation", color = "Colour")

observed_means <-
  compose_features(perf_data, id) |>
  select(id, starts_with("mean_")) |>
  pivot_longer(starts_with("mean_"), names_to = "feature",
               values_to = "observed", names_prefix = "mean_")

fitted_means <-
  purrr::map(
    names(feature_labels),
    \(feature) {
      responded <- perf_data[[paste0("responded_", feature)]]
      epred <- brms::posterior_epred(correlated, resp = paste0("score", feature))
      stopifnot(ncol(epred) == sum(responded))
      tibble(
        id = perf_data$id[responded],
        feature = feature,
        modelled = apply(epred, 2, mean)
        ) |>
        summarise(modelled = mean(modelled), .by = c(id, feature))
  }) |>
  purrr::list_rbind()

shrinkage <-
  inner_join(observed_means, fitted_means, by = c("id", "feature")) |>
  mutate(
    feature = factor(
      feature_labels[feature],
      levels = unname(feature_labels)))

t6 <-
  ggplot(shrinkage, aes(x = observed, y = modelled, colour = feature)) +
  geom_abline(
    slope = 1, intercept = 0,
    linetype = "dashed", linewidth = 0.3,
    colour = "grey60") +
  geom_point(size = 1.3, alpha = 0.75, show.legend = FALSE) +
  facet_wrap(~feature, nrow = 1) +
  scale_discrete_feature(aesthetics = "colour") +
  coord_equal() +
  labs(
    x = "Observed participant mean, responded items",
    y = "Model-implied mean") +
  theme_pdf(
    base_theme = theme_bw,
    base_size = base,
    strip.background.x = element_rect(fill = "white", color = "transparent"),
    axis.title.x = element_text(margin = margin(t = 7))
  )

save_ggplot(fs::path(fig_dir, "t6-partial-pooling.pdf"), t6,
            width = 170, height = 65)

rule("Done")
cat("Figures written to", fig_dir, "\n")
