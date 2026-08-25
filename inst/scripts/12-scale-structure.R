# ------------------------------------------------------------------------- #
# 12-scale-structure.R ----
#
# Implements 12-scale-structure.md.
#
# Doc references below are to the planning set in `inst/planning/`.
#
# EXPLORATORY. Everything downstream of here generates hypotheses rather
# than testing them, and every page reporting it says so.
#
# The deliverable is NOT a correlation figure. It is a defensible feature
# set for 13-clustering.md, decided and written down BEFORE the clustering
# runs, together with a statement of what is held out. That ordering is
# what makes 13's validation logic non-circular, and 13 §6 records that
# this is the third attempt at getting it right.
#
# Sample: pooled across task versions, which is legitimate here and
# nowhere else in this project. See §1.
# ------------------------------------------------------------------------- #

devtools::load_all()
library(ggplot2)

# Run configuration ----
set.seed(20260825)

fig_dir    <- here::here("inst/scripts/figures")
result_dir <- here::here("inst/results")
fs::dir_create(c(fig_dir, result_dir))

rule <- function(txt) cat("\n", strrep("-", 70), "\n", txt, "\n", sep = "")

# ------------------------------------------------------------------------- #
# 1. Sample: pooled across versions, and why that is allowed here ----
# ------------------------------------------------------------------------- #
rule("1. Sample")

scales <- questionnaire_scales(get_data())

cat("\nparticipants with complete questionnaire data:", nrow(scales), "\n\n")
print(as.data.frame(dplyr::count(scales, version)), row.names = FALSE)

cat("\nEvery argument in 05 §3.5 for restricting to v1 is about TASK\n")
cat("comparability: group balance for a behavioural contrast, non-response\n")
cat("rates differing three-fold, per-version standardisation being\n")
cat("unstable. None of it touches a questionnaire score. The instruments\n")
cat("are identical and were administered identically in all three\n")
cat("versions, so version is a property of the task rather than of the\n")
cat("scales.\n")

cat("\nWhat pooling changes is the COMPOSITION of the sample:\n\n")
composition <- scales |>
  dplyr::summarise(
    n = dplyr::n(),
    at_floor = sum(.data$vviq == 16),
    pct_floor = round(100 * mean(.data$vviq == 16)),
    .by = "version"
  ) |>
  dplyr::arrange(.data$version)
print(as.data.frame(composition), row.names = FALSE)

cat("\nLater recruitment targeted aphantasics, so the pooled sample is",
    round(100 * mean(scales$vviq == 16)), "%\n")
cat("floor-group where v1 alone is",
    round(100 * mean(scales$vviq[scales$version == "v1"] == 16)), "%. Cluster",
    "centroids are fitted to\n")
cat("whatever sample they are given, so v1 participants' labels would be\n")
cat("partly determined by participants who enter no other analysis. §5\n")
cat("tests whether that matters rather than assuming it does not.\n")

cat("\nDo the scales themselves differ by version?\n\n")
version_tests <-
  purrr::map(
    setdiff(names(scales), c("id", "version", "vviq")),
    function(scale) {
      test <- stats::kruskal.test(scales[[scale]] ~ factor(scales$version))
      tibble::tibble(scale = scale, p = test$p.value)
    }
  ) |>
  purrr::list_rbind() |>
  dplyr::arrange(.data$p)
print(as.data.frame(version_tests), row.names = FALSE, digits = 3)

cat("\nImagery differs, which is the recruitment difference above and is\n")
cat("expected. If the non-imagery scales also differed, pooling would be\n")
cat("moving the scales and not just the density along one of them.\n")

# ------------------------------------------------------------------------- #
# 2. Partial correlations, not raw ones ----
# ------------------------------------------------------------------------- #
rule("2. Structure among the scales")

cat("\nRaw correlations among overlapping instruments are close to\n")
cat("unreadable: everything correlates with everything because everything\n")
cat("shares a general factor. The partial structure is what says whether a\n")
cat("scale carries anything the others do not.\n")

standardised <- standardise_scales(scales)
scale_only <- dplyr::select(standardised, -"id", -"version")

partial <- correlation::correlation(
  scale_only, partial = TRUE, p_adjust = "bonferroni"
)
cat("\n")
print(as.data.frame(partial)[, c("Parameter1", "Parameter2", "r", "p")],
      row.names = FALSE, digits = 3)

saveRDS(partial, fs::path(result_dir, "scale-partial-correlations.rds"))

# ------------------------------------------------------------------------- #
# 3. The imagery scales are one construct ----
# ------------------------------------------------------------------------- #
rule("3. Redundancy: the imagery scales")

imagery_components <- c("vviq", "osivq_object", "nieq_imagery")

cat("\nRaw correlations among the three imagery measures:\n\n")
print(round(stats::cor(scale_only[, imagery_components],
                       method = "spearman"), 3))

cat("\nAgainst the other OSIVQ subscales, for contrast:\n\n")
print(round(stats::cor(scale_only[, imagery_components],
                       scale_only[, c("osivq_spatial", "osivq_verbal")],
                       method = "spearman"), 3))

cat("\nCronbach's alpha of the three:",
    round(cronbach_alpha(scale_only[, imagery_components]), 3), "\n")

cat("\nThree instruments, three response formats, one construct. Left\n")
cat("separate they would TRIPLE-WEIGHT imagery in any distance metric, so\n")
cat("a clustering would recover imagery groups by construction and this\n")
cat("strand could say nothing the confirmatory strand did not. They are\n")
cat("collapsed into one standardised composite.\n")

features <- standardised |> add_imagery_composite(imagery_components)

feature_names <- setdiff(names(features), c("id", "version"))
cat("\nFeature set (", length(feature_names), "):\n  ",
    paste(feature_names, collapse = "\n  "), "\n", sep = "")

# ------------------------------------------------------------------------- #
# 4. What the remaining scales carry ----
# ------------------------------------------------------------------------- #
rule("4. Where structure beyond imagery could live")

beyond <- setdiff(feature_names, "imagery")
cat("\nPartial correlation of each remaining feature with the composite:\n\n")

against_imagery <-
  purrr::map(
    beyond,
    function(scale) {
      values <- correlation::correlation(
        features[, c("imagery", scale)], partial = FALSE)
      tibble::tibble(scale = scale, r = values$r, p = values$p)
    }
  ) |>
  purrr::list_rbind() |>
  dplyr::arrange(.data$r)
print(as.data.frame(against_imagery), row.names = FALSE, digits = 3)

cat("\nA feature correlating near zero with the composite is where\n")
cat("'structure beyond vividness' could live. A feature correlating\n")
cat("strongly with it is close to a fourth imagery measure and adds little.\n")

cat("\nRELIABILITY CONSTRAINT (07-questionnaire-psychometrics.md): NIEQ\n")
cat("sensory focus has pair-consistency 0.49, below threshold, and was\n")
cat("already the weakest dimension in the published validation. It stays\n")
cat("in the feature set here but any cluster distinguished only by it\n")
cat("should be treated as an artifact until shown otherwise.\n")

# ---- Figure: the partial correlation structure ----
correlation_data <-
  as.data.frame(partial) |>
  dplyr::select("Parameter1", "Parameter2", "r", "p") |>
  dplyr::mutate(
    significant = .data$p < 0.05,
    label = ifelse(.data$significant, sprintf("%.2f", .data$r), "")
  )

p_structure <-
  correlation_data |>
  # a lower triangle: the matrix is symmetric, so drawing both halves
  # doubles the ink and halves the cell size
  ggplot(aes(x = .data$Parameter1, y = .data$Parameter2, fill = .data$r)) +
  geom_tile(colour = "white", linewidth = 0.4) +
  geom_text(aes(label = .data$label), size = 2) +
  scale_fill_gradient2(
    limits = c(-1, 1), name = "Partial r",
    guide = guide_colourbar(barwidth = 8, barheight = 0.5)
  ) +
  labs(
    x = NULL, y = NULL,
    caption = paste(
      "Bonferroni corrected; values shown where p < .05.\n",
      "Pooled across versions, n =", nrow(scales)
    )
  ) +
  coord_fixed() +
  theme_pdf(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "top"
  )

save_ggplot("inst/scripts/figures/s1-scale-structure.pdf",
            p_structure, ncol = 1, height = 100, return = TRUE)

# ------------------------------------------------------------------------- #
# 5. Does pooling change the partition? ----
# ------------------------------------------------------------------------- #
rule("5. Stability check, deferred to 13")

cat("\nThe check this doc owes 13: fit the clustering on all",
    nrow(features), "participants\n")
cat("and again on v1's", sum(features$version == "v1"), "alone, then",
    "cross-tabulate the v1 labels.\n")
cat("cluster_stability() and adjusted_rand_index() are in R/ for that.\n")
cat("\nSubstantial agreement means the pooling is innocent and the larger\n")
cat("sample is kept. Disagreement means the pooled solution describes the\n")
cat("versions excluded from everything else, and it is dropped.\n")

cat("\nAlso owed: cluster occupancy WITHIN v1. A cluster with four v1\n")
cat("members cannot validate anything downstream however real it is, and\n")
cat("that may decide whether the validation step is possible at all.\n")

# ------------------------------------------------------------------------- #
# 6. The feature set, written down before clustering runs ----
# ------------------------------------------------------------------------- #
rule("6. Decisions")

decisions <- tibble::tribble(
  ~decision, ~choice,
  "Sample", paste(nrow(features), "participants, pooled across versions"),
  "Imagery scales", "Collapsed into one standardised composite",
  "Standardisation", "z-scored, not weighted by item count",
  "Feature set", paste(length(feature_names), "features"),
  "Held out", "All task behaviour: accuracy, response propensity, composition",
  "Validation", "Refit 09's joint model on the cluster labels",
  "Success criterion", "Clusters that SPLIT the floor group",
  "Null result", "Clusters that recover the vividness grouping"
)
print(as.data.frame(decisions), row.names = FALSE)

saveRDS(features, fs::path(result_dir, "cluster-features.rds"))

cat("\nThe success criterion is fixed here, before any clustering, so that\n")
cat("the result cannot be described as whatever it turns out to be. A\n")
cat("solution recovering the vividness split is a REPORTABLE NULL: the\n")
cat("structure is imagery and there is nothing else. A solution splitting\n")
cat("the floor group is the interesting outcome, because that is a\n")
cat("distinction the confirmatory strand cannot make at all.\n")

rule("Done. Features in inst/results/cluster-features.rds.")
