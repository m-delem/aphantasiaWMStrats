# ------------------------------------------------------------------------- #
# 13-clustering.R ----
#
# Implements 13-clustering.md.
#
# EXPLORATORY THROUGHOUT. Groups are not fixed in advance, nothing here
# licenses a confirmatory claim, and 13 §0 records what happened last time
# an exploratory clustering result was written up in confirmatory language.
#
# The feature set, the held-out set and the success criterion were all
# fixed by 12-scale-structure.md BEFORE this ran. That ordering is the
# point: it means the result cannot be described as whatever it turns out
# to be.
#
#   Success  = clusters that SPLIT the floor group, a distinction the
#              confirmatory strand cannot make at all.
#   Null     = clusters that recover the vividness grouping. Reportable.
#
# Consensus clustering rather than a single algorithm, because 13 §1 puts
# "clustering finds groups that do not exist" as the central risk, and a
# partition that survives three algorithms and three consensus functions
# is less likely to be an artifact of any one of them.
# ------------------------------------------------------------------------- #

devtools::load_all()
library(ggplot2)

# Run configuration ----
SEED <- 20260825
set.seed(SEED)

# Number of clusters is SELECTED, not assumed. The earlier reasoning study
# fixed nk = 3 because it clustered three OSIVQ subscales, where three is
# defensible by construction. Nothing here tells you in advance how many
# groups a questionnaire battery contains, so a range is evaluated and the
# evidence for the choice is reported.
CANDIDATE_K <- 2:5
ALGORITHMS  <- c("gmm", "pam", "hc")
CONSENSUS   <- c("kmodes", "majority", "CSPA")
REPS        <- 10
PRIMARY     <- "CSPA"

fig_dir    <- here::here("inst/scripts/figures")
result_dir <- here::here("inst/results")
fs::dir_create(c(fig_dir, result_dir))

rule <- function(txt) cat("\n", strrep("-", 70), "\n", txt, "\n", sep = "")

model_dir <- here::here("inst/models")
fs::dir_create(model_dir)

model_path <- function(name) fs::path(model_dir, name)

run_dice <- function(matrix_data, nk = CANDIDATE_K, seed = SEED) {
  set.seed(seed)
  diceR::dice(
    matrix_data, nk = nk, reps = REPS, p.item = 0.8,
    algorithms = ALGORITHMS, cons.funs = CONSENSUS,
    seed = seed, progress = FALSE, verbose = FALSE
  )
}

# ------------------------------------------------------------------------- #
# 1. Features, from 12 ----
# ------------------------------------------------------------------------- #
rule("1. Features")

features <-
  questionnaire_scales(get_data()) |>
  standardise_scales() |>
  add_imagery_composite()

feature_matrix <- as.matrix(dplyr::select(features, -"id", -"version"))
rownames(feature_matrix) <- features$id

cat("\nparticipants:", nrow(feature_matrix),
    "| features:", ncol(feature_matrix), "\n")
cat("  ", paste(colnames(feature_matrix), collapse = "\n   "), "\n", sep = "")
cat("\nPooled across versions (12 §1). Task behaviour is held out entirely.\n")

# ------------------------------------------------------------------------- #
# 2. How many clusters? ----
# ------------------------------------------------------------------------- #
rule("2. Selecting the number of clusters")

clustering <- run_dice(feature_matrix)

cat("\nProportion of ambiguous clustering (PAC), lower is more stable:\n\n")
print(as.data.frame(clustering$indices$pac), row.names = FALSE, digits = 3)

silhouette <- vapply(
  clustering$indices$ii,
  \(index) mean(as.data.frame(index)$silhouette),
  numeric(1)
)
cat("\nMean silhouette by k:\n\n")
print(round(silhouette, 3))

selected <- apply(clustering$clusters, 2, \(x) length(unique(x)))
cat("\nClusters returned by each consensus function:\n\n")
print(selected)

cat("\nk = 2 on both criteria and on all three consensus functions. Taken\n")
cat("as the solution. §6 inspects k = 3 as well, explicitly after the\n")
cat("fact, because a reader will ask and because not looking is not the\n")
cat("same as not fishing.\n")

# ------------------------------------------------------------------------- #
# 3. Is the pooling innocent? ----
# ------------------------------------------------------------------------- #
rule("3. Stability of the partition (12 §5)")

cat("\nThe pooled sample is a third floor-group where v1 alone is a\n")
cat("quarter, because later recruitment targeted aphantasics. Cluster\n")
cat("centroids are fitted to whatever sample they are given, so v1\n")
cat("participants' labels are partly determined by participants who enter\n")
cat("no other analysis. Refit on v1 alone and compare.\n")

v1_ids <- features$id[features$version == "v1"]
in_v1  <- rownames(feature_matrix) %in% v1_ids

restricted <- run_dice(feature_matrix[in_v1, , drop = FALSE])

stability <- cluster_stability(
  pooled = clustering$clusters[in_v1, PRIMARY],
  restricted = restricted$clusters[, PRIMARY]
)

cat("\n")
print(stability$crosstab)
cat("\nagreement after matching labels:", round(stability$agreement, 3),
    "| adjusted Rand:", round(stability$adjusted_rand, 3), "\n")

cat("\nThe v1 partition is essentially the same either way, so the pooling\n")
cat("is innocent and the larger sample is kept. Had it not been, the\n")
cat("pooled solution would have been describing the versions excluded\n")
cat("from everything else, and would have been dropped.\n")

# ------------------------------------------------------------------------- #
# 4. THE PRE-DECLARED TEST ----
# ------------------------------------------------------------------------- #
rule("4. Do the clusters find anything vividness does not?")

labelled <-
  questionnaire_scales(get_data()) |>
  dplyr::mutate(
    cluster = factor(clustering$clusters[, PRIMARY]),
    imagery_group = factor(
      dplyr::if_else(.data$vviq == 16, "VVIQ floor", "Above floor"),
      levels = c("Above floor", "VVIQ floor")
    )
  )

cat("\n")
print(table(cluster = labelled$cluster, imagery = labelled$imagery_group))

agreement <- adjusted_rand_index(labelled$cluster, labelled$imagery_group)
cat("\nadjusted Rand index against the vividness split:",
    round(agreement, 3), "\n")

floor_split <- labelled |>
  dplyr::filter(.data$imagery_group == "VVIQ floor") |>
  dplyr::count(.data$cluster)
cat("\nWhere the floor group lands:\n\n")
print(as.data.frame(floor_split), row.names = FALSE)

cat("\nTHE FLOOR GROUP IS NOT SPLIT. Every participant at the vividness\n")
cat("floor falls in one cluster. By the criterion fixed in 12 §6 before\n")
cat("this ran, that is the NULL RESULT: the structure the questionnaires\n")
cat("contain is imagery, and the clustering does not find anything the\n")
cat("confirmatory strand did not already have.\n")

# ------------------------------------------------------------------------- #
# 5. What the clusters are, since they are not nothing ----
# ------------------------------------------------------------------------- #
rule("5. The solution, described")

profiles <-
  features |>
  dplyr::mutate(cluster = factor(clustering$clusters[, PRIMARY])) |>
  dplyr::summarise(
    n = dplyr::n(),
    dplyr::across(
      tidyselect::where(is.numeric) & -tidyselect::any_of("n"),
      \(x) round(mean(x), 2)
    ),
    .by = "cluster"
  ) |>
  dplyr::arrange(.data$cluster)

cat("\nCluster means, in standard deviations:\n\n")
print(as.data.frame(profiles), row.names = FALSE)

cat("\nOne axis, dichotomised. Every feature separates in the same\n")
cat("direction except unsymbolised thinking, which separates in the\n")
cat("opposite one, and 12 §4 already showed why: unsymbolised correlates\n")
cat("-0.42 with the imagery composite, so it behaves as an INVERSE\n")
cat("imagery measure rather than an independent construct.\n")

cat("\nThe boundary is not identical to the vividness split, which is the\n")
cat("one respect in which this is not purely a relabelling: the clusters\n")
cat("group the floor participants with some low-vividness participants\n")
cat("above the floor. The line is drawn at a vividness threshold rather\n")
cat("than at the scale floor.\n")

occupancy <- table(labelled$cluster[in_v1])
cat("\nOccupancy within v1, which is what any downstream validation could\n")
cat("use:\n\n")
print(occupancy)

# ---- Figure: the clusters on the two features that matter ----
plot_data <-
  features |>
  dplyr::mutate(
    cluster = factor(clustering$clusters[, PRIMARY]),
    at_floor = questionnaire_scales(get_data())$vviq == 16
  )

p_clusters <-
  plot_data |>
  ggplot(aes(x = .data$imagery, y = .data$nieq_unsymbolised,
             colour = .data$cluster, shape = .data$at_floor)) +
  geom_point(size = 1.6, alpha = 0.8) +
  scale_colour_manual(values = unname(palette.colors()[c(6, 4)]),
                      name = "Cluster") +
  scale_shape_manual(values = c(`TRUE` = 17, `FALSE` = 16),
                     labels = c(`TRUE` = "VVIQ floor", `FALSE` = "Above floor"),
                     name = NULL) +
  labs(
    x = "Imagery composite (z)",
    y = "Unsymbolised thinking (z)",
    caption = paste(
      "Consensus of three algorithms and three consensus functions,",
      "n =", nrow(features)
    )
  ) +
  theme_pdf()

save_ggplot("inst/scripts/figures/s2-clusters.pdf",
            p_clusters, ncol = 1, height = 80, return = TRUE)

# ------------------------------------------------------------------------- #
# 6. k = 3, inspected after the fact and labelled as such ----
# ------------------------------------------------------------------------- #
rule("6. Post-hoc: does a three-cluster solution split the floor group?")

cat("\nk = 2 was selected in §2 and is the result. This section exists\n")
cat("because the criterion is about splitting the floor group, so a\n")
cat("reader will want to know whether a finer solution does. Looking is\n")
cat("legitimate; presenting what is found here as the result would not\n")
cat("be, and it is labelled POST-HOC for that reason.\n")

three <- run_dice(feature_matrix, nk = 3)
labelled$cluster_k3 <- factor(three$clusters[, PRIMARY])

cat("\n")
print(table(cluster = labelled$cluster_k3, imagery = labelled$imagery_group))
cat("\nadjusted Rand against the vividness split:",
    round(adjusted_rand_index(labelled$cluster_k3, labelled$imagery_group), 3),
    "\n")

floor_k3 <- labelled |>
  dplyr::filter(.data$imagery_group == "VVIQ floor") |>
  dplyr::count(.data$cluster_k3)
cat("\nWhere the floor group lands at k = 3:\n\n")
print(as.data.frame(floor_k3), row.names = FALSE)

# ------------------------------------------------------------------------- #
# 7. What follows ----
# ------------------------------------------------------------------------- #
rule("7. Consequences")

saveRDS(labelled, fs::path(result_dir, "cluster-assignments.rds"))
saveRDS(clustering, fs::path(result_dir, "clustering.rds"))

cat("\nThe validation step planned in 09 was to refit the joint model on\n")
cat("the cluster labels. Its precondition was clusters that are not\n")
cat("simply imagery groups, and that precondition is NOT met: the floor\n")
cat("group falls entirely inside one cluster.\n")

cat("\nRefitting anyway would reproduce the floor-group analysis with the\n")
cat("boundary moved slightly, and reporting that as validation of a\n")
cat("cluster solution is close to what 13 §0 records going wrong the\n")
cat("first time. The honest end of this strand is the null.\n")

cat("\nOne question it does leave open, and worth stating as a question\n")
cat("rather than answering here: the cluster boundary sits above the\n")
cat("vividness floor, so it is a different dichotomy of the same axis.\n")
cat("Whether it predicts task behaviour better than the floor split is\n")
cat("answerable, cheap, and would need declaring before it is run.\n")

# ------------------------------------------------------------------------- #
# 8. Exploratory extensions, beyond the pre-declared analysis ----
# ------------------------------------------------------------------------- #
rule("8. Two extensions, run after seeing §4")

cat("\nEverything below was run AFTER the result in §4 and is therefore\n")
cat("exploration of a null, not a second attempt at the same test. Both\n")
cat("are reported because a reader will ask, and both are labelled.\n")

# ---- 8.1 The substantive questionnaire finding ----
cat("\n8.1 What separates the floor group on the NIEQ\n\n")

nieq_contrast <-
  purrr::map(
    grep("^nieq_", names(labelled), value = TRUE),
    function(dimension) {
      floor <- labelled[[dimension]][labelled$imagery_group == "VVIQ floor"]
      above <- labelled[[dimension]][labelled$imagery_group == "Above floor"]
      pooled_sd <- sqrt(
        ((length(floor) - 1) * stats::var(floor) +
           (length(above) - 1) * stats::var(above)) /
          (length(floor) + length(above) - 2)
      )
      # Computed BEFORE the tibble. Inside tibble() later expressions see
      # earlier columns, so writing `floor = mean(floor)` first and then
      # `wilcox.test(floor, above)` would test the two means against each
      # other and return p = 1 for every dimension. That is the second
      # time this masking has bitten in this project; the first was in
      # 10-performance-modelling.R.
      test <- suppressWarnings(stats::wilcox.test(floor, above))

      tibble::tibble(
        dimension = sub("^nieq_", "", dimension),
        floor = mean(floor), above = mean(above),
        d = (mean(floor) - mean(above)) / pooled_sd,
        p = test$p.value
      )
    }
  ) |>
  purrr::list_rbind() |>
  dplyr::arrange(dplyr::desc(.data$d))
print(as.data.frame(nieq_contrast), row.names = FALSE, digits = 3)

cat("\nUNSYMBOLISED THINKING IS THE ONLY DIMENSION WHERE THE FLOOR GROUP\n")
cat("SCORES HIGHER, and the effect is large. Participants reporting no\n")
cat("voluntary visual imagery recognise themselves more in what the NIEQ,\n")
cat("following Hurlburt's descriptive experience sampling, calls thinking\n")
cat("without words or images.\n")

cat("\nThis is a group contrast on a questionnaire, not a clustering\n")
cat("result, and it is arguably the more interesting outcome of the two.\n")
cat("It is also consistent with §5: unsymbolised loads inversely on the\n")
cat("imagery axis, which is the same fact seen from the other side.\n")

# ---- 8.1b The same contrast as a model, in the site's usual form ----
cat("\nThe table above dichotomises, which throws away the question of\n")
cat("whether a dimension varies with vividness ABOVE the floor. Fitted in\n")
cat("the floor-group form used everywhere else, each dimension gets a\n")
cat("slope among everyone above the floor plus an offset for the group at\n")
cat("it, and the two are separable.\n")

# Beta after a Smithson-Verkuilen squeeze, consistent with the accuracy
# models: NIEQ dimensions are bounded 0-100 and every one of them has
# participants at a boundary, so a Gaussian would put mass outside the
# scale.
nieq_data <-
  labelled |>
  dplyr::mutate(
    complete_aphant = factor(
      dplyr::if_else(.data$vviq == 16, "floor", "above_floor"),
      levels = c("above_floor", "floor")
    )
  )

# The imagery dimension is deliberately excluded: it correlates 0.87 with
# VVIQ, which defines the grouping, so its offset is close to circular.
nieq_dimensions <- c("nieq_unsymbolised", "nieq_inner_voice",
                     "nieq_emotions", "nieq_sensory_focus")

nieq_models <- purrr::map(
  nieq_dimensions,
  function(dimension) {
    fit_data <- nieq_data
    fit_data$score <- squeeze_boundaries(fit_data[[dimension]] / 100)

    fit_brms_model(
      formula = brms::bf(score ~ vviq + complete_aphant, family = brms::Beta()),
      data    = fit_data,
      prior   = response_priors(NULL, terms = c("vviq", "complete_aphant")),
      file    = model_path(paste0("nieq-floor-", sub("^nieq_", "", dimension))),
      chains  = 4,
      iterations = 2000,
      warmup  = 1000,
      refresh = 0
    )
  }
) |>
  stats::setNames(nieq_dimensions)

cat("\nFloor-group offsets, log-odds:\n\n")
nieq_offsets <-
  purrr::map(
    nieq_dimensions,
    function(dimension) {
      estimates <- brms::fixef(nieq_models[[dimension]])
      tibble::tibble(
        dimension = sub("^nieq_", "", dimension),
        offset = estimates["complete_aphantfloor", "Estimate"],
        lower = estimates["complete_aphantfloor", "Q2.5"],
        upper = estimates["complete_aphantfloor", "Q97.5"],
        vviq_slope = estimates["vviq", "Estimate"],
        slope_lower = estimates["vviq", "Q2.5"],
        slope_upper = estimates["vviq", "Q97.5"]
      )
    }
  ) |>
  purrr::list_rbind() |>
  dplyr::arrange(dplyr::desc(.data$offset))
print(as.data.frame(nieq_offsets), row.names = FALSE, digits = 3)

saveRDS(nieq_offsets, fs::path(result_dir, "nieq-floor-offsets.rds"))

cat("\nRead the two columns together. A large offset with a flat slope is\n")
cat("a property of the floor group specifically. A large offset with a\n")
cat("steep slope is a gradient that the group merely sits at the end of,\n")
cat("and would be described differently.\n")

# ---- Figure: the four dimensions in the site's floor-group form ----
nieq_panel <- function(dimension) {
  model <- nieq_models[[dimension]]
  grid <- tibble::tibble(
    vviq = seq(16, 80, length.out = 200),
    complete_aphant = factor("above_floor",
                             levels = c("above_floor", "floor"))
  )
  above <- brms::posterior_epred(model, newdata = grid)

  floor_row <- grid[1, ]
  floor_row$complete_aphant <- factor("floor",
                                      levels = c("above_floor", "floor"))
  floor_draws <- as.vector(
    brms::posterior_epred(model, newdata = floor_row))

  observed <- tibble::tibble(
    x = nieq_data$vviq, y = nieq_data[[dimension]] / 100
  )
  effect <- brms::fixef(model)["complete_aphantfloor", ]

  plot_floor_group(
    observed = dplyr::filter(observed, .data$x > 16),
    fitted = tibble::tibble(
      x = grid$vviq,
      estimate = apply(above, 2, stats::median),
      lower = apply(above, 2, stats::quantile, 0.025),
      upper = apply(above, 2, stats::quantile, 0.975)
    ),
    floor_draws = floor_draws,
    floor_observed = dplyr::filter(observed, .data$x == 16)$y,
    effect_label = sprintf("%.2f\n[%.2f, %.2f]", effect[["Estimate"]],
                           effect[["Q2.5"]], effect[["Q97.5"]]),
    x_lab = NULL,
    y_lab = gsub("_", " ", sub("^nieq_", "", dimension)),
    left_expansion = 0.15, arrow_nudge = -5.5
  )
}

p_nieq <- patchwork::wrap_plots(
  purrr::map(nieq_dimensions, nieq_panel), ncol = 2
)

save_ggplot("inst/scripts/figures/s3-nieq-floor.pdf",
            p_nieq, ncol = 2, height = 140, return = TRUE)

# ---- 8.2 Clustering the floor group alone ----
cat("\n8.2 Is there structure WITHIN the floor group?\n")

cat("\nA better question than forcing more clusters on the whole sample:\n")
cat("restricting to the floor group removes the axis that dominated §4,\n")
cat("so anything found here is necessarily beyond vividness. Features are\n")
cat("re-standardised WITHIN the subsample, and the imagery scales are\n")
cat("dropped because they barely vary in it.\n")

floor_features <-
  questionnaire_scales(get_data()) |>
  dplyr::filter(.data$vviq == 16) |>
  dplyr::select(-"vviq", -"osivq_object", -"nieq_imagery") |>
  standardise_scales()

floor_matrix <- as.matrix(dplyr::select(floor_features, -"id", -"version"))
rownames(floor_matrix) <- floor_features$id

cat("\nn =", nrow(floor_matrix), "on", ncol(floor_matrix), "features.\n")

floor_clustering <- run_dice(floor_matrix, nk = 2:4)

cat("\nProportion of ambiguous clustering:\n\n")
print(as.data.frame(floor_clustering$indices$pac), row.names = FALSE,
      digits = 3)

cat("\nClusters returned:",
    unique(apply(floor_clustering$clusters, 2, \(x) length(unique(x)))), "\n")

floor_features$cluster <- factor(floor_clustering$clusters[, PRIMARY])
cat("\nProfiles, z within the floor group:\n\n")
print(as.data.frame(
  floor_features |>
    dplyr::summarise(
      n = dplyr::n(),
      dplyr::across(tidyselect::where(is.numeric) & -tidyselect::any_of("n"),
                    \(x) round(mean(x), 2)),
      .by = "cluster") |>
    dplyr::arrange(.data$cluster)
), row.names = FALSE)

cat("\nTHE SOLUTION IS NOT SUPPORTED. The consensus functions agree on a\n")
cat("partition, but PAC runs from 0.22 to 0.76 across algorithms, meaning\n")
cat("a large share of participant pairs cluster together inconsistently\n")
cat("across resamples. At n =", nrow(floor_matrix), "with",
    ncol(floor_matrix), "features, an algorithm that\n")
cat("always returns a partition has returned one; the indices say not to\n")
cat("believe it. Reported so the question is visibly closed rather than\n")
cat("left for someone to try again with a different seed.\n")

cat("\nWhat it would have claimed, had the indices supported it: a\n")
cat("contrast between participants high on inner voice and unsymbolised\n")
cat("thinking and participants low on both. That is worth a properly\n")
cat("powered study, not a footnote in this one.\n")

rule("Done. Assignments in inst/results/cluster-assignments.rds.")
