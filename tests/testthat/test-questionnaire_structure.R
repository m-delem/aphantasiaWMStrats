fake_scales <- data.frame(
  id = paste0("p", 1:6),
  version = rep(c("v1", "v3"), each = 3),
  vviq = c(16, 20, 40, 60, 80, 16),
  osivq_object = c(1, 2, 3, 4, 5, 1),
  osivq_spatial = c(3, 2, 4, 3, 5, 2),
  osivq_verbal = c(4, 3, 3, 2, 4, 5),
  nieq_imagery = c(0, 10, 40, 70, 95, 5),
  nieq_inner_voice = c(80, 70, 60, 50, 40, 90),
  nieq_emotions = c(50, 60, 70, 55, 65, 45),
  nieq_sensory_focus = c(40, 50, 60, 45, 55, 35),
  nieq_unsymbolised = c(90, 70, 40, 20, 5, 85)
)

test_that("standardise_scales leaves the identifiers alone", {
  out <- standardise_scales(fake_scales)
  expect_identical(out$id, fake_scales$id)
  expect_identical(out$version, fake_scales$version)
  expect_equal(mean(out$vviq), 0)
  expect_equal(stats::sd(out$vviq), 1)
})

test_that("standardise_scales leaves non-numeric columns alone", {
  # Callers attach group factors and cluster labels before standardising,
  # and scale() on a factor errors inside across(). Regression test: an
  # earlier version selected by name rather than by type and broke the
  # exploratory vignette.
  with_factor <- fake_scales
  with_factor$imagery_group <- factor(
    rep(c("Above floor", "VVIQ floor"), 3))
  with_factor$cluster <- factor(rep(1:2, 3))

  expect_no_error(out <- standardise_scales(with_factor))
  expect_s3_class(out$imagery_group, "factor")
  expect_identical(out$imagery_group, with_factor$imagery_group)
  expect_identical(out$cluster, with_factor$cluster)
  # and the numeric columns are still standardised
  expect_equal(mean(out$vviq), 0)
})

test_that("add_imagery_composite replaces its components", {
  # Left separate the three imagery measures would triple-weight imagery
  # in any distance metric, so the composite has to remove them, not sit
  # alongside them.
  out <- standardise_scales(fake_scales) |> add_imagery_composite()
  expect_true("imagery" %in% names(out))
  expect_false(any(c("vviq", "osivq_object", "nieq_imagery") %in% names(out)))
  expect_equal(mean(out$imagery), 0)
  expect_length(setdiff(names(out), c("id", "version")), 7)
})

test_that("add_imagery_composite averages its components", {
  standardised <- standardise_scales(fake_scales)
  expected <- rowMeans(
    standardised[, c("vviq", "osivq_object", "nieq_imagery")])
  out <- add_imagery_composite(standardised)
  # composite is itself standardised, so compare after scaling
  expect_equal(out$imagery, as.numeric(scale(expected)))
})

test_that("adjusted_rand_index is invariant to relabelling", {
  # Cluster labels are arbitrary, so an index that changed when they were
  # permuted would be measuring the labels rather than the partition.
  expect_equal(adjusted_rand_index(c(1, 1, 2, 2), c(1, 1, 2, 2)), 1)
  expect_equal(adjusted_rand_index(c(1, 1, 2, 2), c(2, 2, 1, 1)), 1)
  expect_equal(adjusted_rand_index(c(1, 1, 2, 2), c("a", "a", "b", "b")), 1)
})

test_that("adjusted_rand_index is near zero for unrelated partitions", {
  set.seed(1)
  a <- sample(1:3, 200, replace = TRUE)
  b <- sample(1:3, 200, replace = TRUE)
  expect_lt(abs(adjusted_rand_index(a, b)), 0.1)
  # and a partition that splits one group of another scores between
  expect_gt(adjusted_rand_index(c(1, 1, 1, 2, 2, 2), c(1, 1, 2, 3, 3, 3)), 0)
})

test_that("cluster_stability reports agreement after matching labels", {
  # Perfect agreement under a permutation of labels, which is what
  # comparing two fits of the same algorithm will normally produce.
  out <- cluster_stability(c(1, 1, 2, 2, 3, 3), c(2, 2, 3, 3, 1, 1))
  expect_equal(out$agreement, 1)
  expect_equal(out$adjusted_rand, 1)
  expect_equal(dim(out$crosstab), c(3L, 3L))

  # and less than perfect when one participant moves
  moved <- cluster_stability(c(1, 1, 2, 2, 3, 3), c(2, 2, 3, 1, 1, 1))
  expect_lt(moved$agreement, 1)
})

test_that("questionnaire_scales returns one row per participant", {
  skip_if_not(exists("all_data"))
  scales <- questionnaire_scales(all_data)
  expect_equal(nrow(scales), dplyr::n_distinct(scales$id))
  expect_false(anyNA(scales))
  # nine scales, plus the two identifiers
  expect_length(names(scales), 11)
})
