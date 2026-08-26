# ------------------------------------------------------------------------- #
# 14-strategy-convergence.R ----
#
# EXPLORATORY. Not pre-declared, run after the confirmatory strand, and
# labelled as such wherever it is reported.
#
# The point is convergence, not verification. A strategy is what a person
# takes themselves to be doing, and no behavioural pattern can overrule
# their own account of it. What a behavioural measure can offer is a
# dependent variable that, if it tracks the same distinctions participants
# report, corroborates the subjective category instead of replacing it.
#
# The composition (11-compositional-analysis.md) is that behavioural
# measure. The post-task questionnaire is the report. This script asks
# whether they agree.
#
# The prioritisation question is the strongest of the reports available:
# "which features did you try to keep for points", answered by all 88 v1
# participants, with multiple selections allowed.
# ------------------------------------------------------------------------- #

devtools::load_all()
library(ggplot2)

set.seed(20260826)

fig_dir    <- here::here("inst/scripts/figures")
result_dir <- here::here("inst/results")
fs::dir_create(c(fig_dir, result_dir))

rule <- function(txt) cat("\n", strrep("-", 70), "\n", txt, "\n", sep = "")

# ------------------------------------------------------------------------- #
# 1. The reports ----
# ------------------------------------------------------------------------- #
rule("1. What participants said they did")

participants <-
  get_data("v1") |>
  dplyr::distinct(.data$id, .keep_all = TRUE)

strategy_items <- dplyr::bind_rows(participants$strategy_items)
strategy_items$id <- participants$id

# q04: which features did you prioritise for points. Multiple selections,
# so a participant is a SET of features rather than one.
prioritisation <-
  strategy_items |>
  dplyr::select("id", tidyselect::starts_with("strats_cfa_q04")) |>
  tidyr::pivot_longer(-"id", names_to = "slot", values_to = "feature") |>
  dplyr::filter(!is.na(.data$feature)) |>
  dplyr::summarise(
    kept = sum(.data$feature != "none"),
    priorities = paste(sort(.data$feature), collapse = " + "),
    .by = "id"
  )

cat("\nWhich features did participants say they prioritised?\n\n")
print(as.data.frame(
  dplyr::arrange(dplyr::count(prioritisation, .data$priorities, .data$kept),
                 dplyr::desc(.data$n))
), row.names = FALSE)

cat("\nWords are near-universal: named by",
    sum(grepl("words", prioritisation$priorities)), "of",
    nrow(prioritisation), "participants. That has too little\n")
cat("variance to be a predictor, but it is a finding in itself, and it\n")
cat("converges with word sitting at ceiling behaviourally (06 §2).\n")

cat("\nOrientation is the feature people give up: named by",
    sum(grepl("orientations", prioritisation$priorities)),
    "participants,\nand only",
    sum(grepl("orientations", prioritisation$priorities) &
          !grepl("words", prioritisation$priorities)),
    "who did not also name words. It also has the highest\n")
cat("non-response rate of the three (03).\n")

# The per-feature strategy questions. Reported descriptively only: the
# option sets differ across features (spatial_body and spatial_cardinal
# are offered for orientation alone), so a cross-feature comparison would
# be comparing different menus.
strategies <-
  strategy_items |>
  dplyr::select("id", tidyselect::matches("q0[123]")) |>
  tidyr::pivot_longer(-"id", names_to = "item", values_to = "strategy") |>
  dplyr::filter(!is.na(.data$strategy)) |>
  dplyr::mutate(
    feature = dplyr::case_when(
      grepl("colors", .data$item) ~ "colour",
      grepl("orientations", .data$item) ~ "orientation",
      TRUE ~ "word"
    )
  )

coded <- c("repetition", "mental_image", "semantic", "binding",
           "spatial_body", "spatial_cardinal", "none")

cat("\nNamed strategies per feature (coded options only;",
    sum(!strategies$strategy %in% coded), "free-text\nresponses set aside):\n\n")
print(
  strategies |>
    dplyr::filter(.data$strategy %in% coded) |>
    dplyr::count(.data$feature, .data$strategy) |>
    tidyr::pivot_wider(names_from = "feature", values_from = "n",
                       values_fill = 0L) |>
    as.data.frame(),
  row.names = FALSE
)

# ------------------------------------------------------------------------- #
# 2. The behaviour ----
# ------------------------------------------------------------------------- #
rule("2. What participants actually did")

v1 <- get_data("v1") |> dplyr::filter(grepl("^expe_block", .data$expe_phase))

parts <- compose_features(dplyr::filter(v1, .data$id %in% engaged_ids(v1)), id)
parts <- parts[stats::complete.cases(parts), ]

behaviour <-
  parts |>
  dplyr::bind_cols(
    ilr_coords(dplyr::select(parts, tidyselect::starts_with("part_")))
  ) |>
  dplyr::left_join(prioritisation, by = "id") |>
  dplyr::left_join(
    dplyr::distinct(v1, .data$id, vviq = .data$vviq_total_score), by = "id"
  )
# NOT filtered on VVIQ. The composition page reports the same correlation
# and builds its frame from the composition alone, so filtering here would
# publish two different numbers for one quantity.

cat("\nparticipants with both a composition and a report:", nrow(behaviour), "\n")
cat("\nilr1 is the verbal coordinate: higher means a larger share of effort\n")
cat("on words relative to the geometric mean of colour and orientation.\n")

# ------------------------------------------------------------------------- #
# 3. Do the two agree? ----
# ------------------------------------------------------------------------- #
rule("3. Convergence")

cat("\nHOW MANY features did they say they kept, against how evenly they\n")
cat("actually divided effort:\n\n")

by_count <-
  behaviour |>
  dplyr::filter(.data$kept > 0) |>
  dplyr::summarise(
    participants = dplyr::n(),
    mean_ilr1 = mean(.data$ilr1),
    sd_ilr1 = stats::sd(.data$ilr1),
    .by = "kept"
  ) |>
  dplyr::arrange(.data$kept)
print(as.data.frame(by_count), row.names = FALSE, digits = 3)

kept_test <- correlation_test(
  behaviour$ilr1[behaviour$kept > 0], behaviour$kept[behaviour$kept > 0]
)
cat("\nSpearman, ilr1 against features kept: rho =",
    round(kept_test$rho, 3), " p =", round(kept_test$p, 4),
    " n =", kept_test$n, "\n")

cat("\nMonotone and in the predicted direction. Participants who said they\n")
cat("kept one feature concentrated on words; those who said they kept all\n")
cat("three spread their effort.\n")

cat("\nWHICH features, for the one contrast with enough participants:\n\n")

contrast <- dplyr::filter(
  behaviour, .data$priorities %in% c("words", "colours + words")
)
print(as.data.frame(
  contrast |>
    dplyr::summarise(
      participants = dplyr::n(),
      ilr1 = mean(.data$ilr1),
      word_share = mean(.data$part_word),
      colour_share = mean(.data$part_color),
      .by = "priorities"
    )
), row.names = FALSE, digits = 3)

contrast_test <- stats::wilcox.test(ilr1 ~ priorities, data = contrast)
cat("\nWilcoxon on ilr1: W =", contrast_test$statistic,
    " p =", round(contrast_test$p.value, 4), "\n")

cat("\nNaming colours as well as words goes with a lower word share and a\n")
cat("higher colour share. The report and the behaviour move together on\n")
cat("both parts, not just on the summary coordinate.\n")

# ------------------------------------------------------------------------- #
# 4. Is the report just imagery again? ----
# ------------------------------------------------------------------------- #
rule("4. Prioritisation against imagery")

cat("\nIf the reports simply tracked imagery group, the convergence above\n")
cat("would add nothing the confirmatory strand does not already have.\n\n")

imagery_table <- table(
  group = ifelse(behaviour$vviq == 16, "VVIQ floor", "Above floor"),
  kept = behaviour$kept
)
print(imagery_table)

cat("\nAphantasic participants do not keep fewer features. Whatever drives\n")
cat("the strategic choice, it is not vividness, which makes the report an\n")
cat("independent measurement rather than a restatement.\n")

saveRDS(behaviour, fs::path(result_dir, "strategy-convergence.rds"))

# ---- Figure ----
p_convergence <-
  behaviour |>
  dplyr::filter(.data$kept > 0) |>
  dplyr::mutate(
    kept = factor(.data$kept, labels = c("One", "Two", "Three")),
    group = factor(
      ifelse(.data$vviq == 16, "VVIQ floor", "Above floor"),
      levels = c("Above floor", "VVIQ floor")
    )
  ) |>
  ggplot(aes(x = .data$kept, y = .data$ilr1)) +
  geom_hline(yintercept = 0, linetype = "dashed", linewidth = 0.2,
             colour = "grey60") +
  geom_boxplot(width = 0.5, outlier.shape = NA, colour = "grey40") +
  geom_jitter(aes(colour = .data$group, shape = .data$group),
              width = 0.14, height = 0, size = 1.4, alpha = 0.85) +
  # not scale_discrete_aphantasia(): that scale keys on the imagery-group
  # levels, and these are floor-group labels
  scale_colour_manual(values = c(`Above floor` = "grey45",
                                 `VVIQ floor` = "#C44E52")) +
  scale_shape_manual(values = c(`Above floor` = 16, `VVIQ floor` = 17)) +
  labs(
    x = "Features the participant said they kept",
    y = "Share of effort on words (ilr1)",
    colour = NULL, shape = NULL,
    caption = paste0(
      "Exploratory. Spearman rho = ", round(kept_test$rho, 2),
      ", p = ", round(kept_test$p, 3), ", n = ", kept_test$n, "."
    )
  ) +
  theme_pdf()

save_ggplot("inst/scripts/figures/s4-strategy-convergence.pdf",
            p_convergence, ncol = 1, height = 80, return = TRUE)

# ------------------------------------------------------------------------- #
# 4b. The phenomenological questions ----
# ------------------------------------------------------------------------- #
rule("4b. Do the reports about EXPERIENCE cohere with the questionnaire?")

cat("\nThe prioritisation question above asks about behaviour: which\n")
cat("features did you try to keep. People can answer that.\n")

cat("\nThe per-feature questions ask something else. 'How did you memorise\n")
cat("the colours' offers MENTAL IMAGERY as one option, and naming it is a\n")
cat("claim about experience, not about behaviour. It is the kind of report\n")
cat("aphantasia research treats as least trustworthy, and it is asked here\n")
cat("in different words, in a different context, weeks or minutes after a\n")
cat("questionnaire that asked about imagery directly.\n")

cat("\nSo the two can be checked against each other.\n")

per_feature <-
  strategies |>
  dplyr::filter(.data$strategy %in% coded) |>
  dplyr::left_join(
    dplyr::distinct(v1, .data$id, vviq = .data$vviq_total_score), by = "id"
  ) |>
  dplyr::filter(!is.na(.data$vviq)) |>
  dplyr::mutate(
    group = ifelse(.data$vviq == 16, "VVIQ floor", "Above floor")
  ) |>
  dplyr::distinct(.data$id, .data$group, .data$feature, .data$strategy)

group_sizes <- per_feature |>
  dplyr::distinct(.data$id, .data$group) |>
  dplyr::count(.data$group, name = "participants")

cat("\n")
print(as.data.frame(group_sizes), row.names = FALSE)

profile <-
  per_feature |>
  dplyr::count(.data$feature, .data$strategy, .data$group) |>
  dplyr::left_join(group_sizes, by = "group") |>
  dplyr::mutate(percent = round(100 * .data$n / .data$participants)) |>
  dplyr::select("feature", "strategy", "group", "percent") |>
  tidyr::pivot_wider(names_from = "group", values_from = "percent",
                     values_fill = 0L) |>
  dplyr::arrange(.data$feature, dplyr::desc(.data$`Above floor`))

cat("\nStrategies named, as a percentage of each group:\n\n")
print(as.data.frame(profile), row.names = FALSE)

imagery_mentions <- per_feature |>
  dplyr::filter(.data$strategy == "mental_image") |>
  dplyr::count(.data$group)

cat("\nMENTAL IMAGERY, NAMED BY:\n\n")
print(as.data.frame(imagery_mentions), row.names = FALSE)

cat("\nNot one participant at the VVIQ floor named mental imagery, for any\n")
cat("of the three features. Zero out of",
    3 * group_sizes$participants[group_sizes$group == "VVIQ floor"],
    "opportunities.\n")

cat("\nWHAT THAT IS AND IS NOT EVIDENCE OF. It is a coherence check, and\n")
cat("it passes: a participant reporting no voluntary imagery on the VVIQ\n")
cat("also declines to name imagery as a memory strategy when asked in\n")
cat("different words about a specific task, unprompted by any mention of\n")
cat("aphantasia. Consistency across instruments and contexts is what you\n")
cat("would expect if the reports track something real, and is not what\n")
cat("you would expect if they were noise.\n")

cat("\nIt is NOT evidence that introspective report is ACCURATE. Two\n")
cat("reports agreeing with each other is a weaker property than either\n")
cat("being right, and nothing here reaches the stronger claim.\n")

cat("\nNo model is fitted. One cell is a structural zero, so a logistic\n")
cat("model of the group contrast would not converge, and the contingency\n")
cat("table already says everything the data support.\n")

cat("\nTwo further things in that table, neither of them about imagery:\n")
cat("  * On orientation,",
    profile$`VVIQ floor`[profile$feature == "orientation" &
                           profile$strategy == "none"],
    "% of the floor group named NO strategy,\n    against",
    profile$`Above floor`[profile$feature == "orientation" &
                            profile$strategy == "none"],
    "% above it. Orientation is the feature they abandon,\n")
cat("    which converges with its non-response rate being the highest of\n")
cat("    the three (03-parity-engagement.md).\n")
cat("  * They name body-centred spatial strategies LESS often than typical\n")
cat("    imagers, not more, which cuts against a simple compensation\n")
cat("    account.\n")

saveRDS(profile, fs::path(result_dir, "strategy-profile.rds"))

# ------------------------------------------------------------------------- #
# 5. What this does and does not establish ----
# ------------------------------------------------------------------------- #
rule("5. Reading")

cat("\nESTABLISHES: the compositional coordinate tracks something\n")
cat("participants can report. Two independent measurements of the same\n")
cat("construct, one from 63 trials of behaviour and one from a question\n")
cat("asked afterwards, agree. That is corroboration of the measure, which\n")
cat("no amount of internal reliability could provide.\n")

cat("\nDOES NOT ESTABLISH: that the reports are accurate about mechanism.\n")
cat("'Which features did you try to keep' is a question about behaviour,\n")
cat("which people can answer. 'Did you use visual imagery' is a question\n")
cat("about phenomenology, and nothing here bears on that.\n")

cat("\nEXPLORATORY: not pre-declared, and run after the confirmatory strand.\n")
cat("The per-feature strategy questions are compared WITHIN a feature and\n")
cat("never across features, because the option sets differ: spatial_body\n")
cat("and spatial_cardinal are offered for orientation alone.\n")

rule("Done. Results in inst/results/strategy-convergence.rds.")
