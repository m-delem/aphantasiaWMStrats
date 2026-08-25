test_that("spearman_brown behaves like a lengthening correction", {
  # A half-length test correlating at r implies a full test correlating
  # higher, and the correction is monotone with fixed points at 0 and 1.
  expect_equal(spearman_brown(0), 0)
  expect_equal(spearman_brown(1), 1)
  expect_equal(spearman_brown(0.5), 2 / 3)
  expect_gt(spearman_brown(0.4), 0.4)
  expect_true(all(diff(spearman_brown(seq(0, 0.9, 0.1))) > 0))
})

# Synthetic item-level data with a real per-participant signal, so the
# reliability machinery has something to recover.
fake_trials <- local({
  set.seed(11)
  participants <- paste0("p", 1:20)
  ability <- stats::setNames(stats::runif(20, 0.3, 0.9), participants)
  trials <- paste0("t", 1:20)
  grid <- expand.grid(id = participants, trial_uid = trials,
                      stringsAsFactors = FALSE)
  grid$score_angle <- pmin(pmax(
    ability[grid$id] + stats::rnorm(nrow(grid), 0, 0.15), 0.01), 0.99)
  grid$responded_angle <- TRUE
  grid$score_word <- grid$score_angle
  grid$responded_word <- TRUE
  grid$score_color <- grid$score_angle
  grid$responded_color <- TRUE
  grid
})

test_that("split_half_reliability returns one correlation per split", {
  set.seed(1)
  out <- split_half_reliability(fake_trials, "angle", n_splits = 25,
                                thresholds = c(angle = 1L))
  expect_length(out, 25)
  expect_true(all(out >= -1 & out <= 1, na.rm = TRUE))
})

test_that("split_half_reliability recovers a real between-person signal", {
  # Built with a wide ability spread and modest noise, so the halves should
  # agree substantially. A near-zero result would mean the split is not
  # pairing participants correctly.
  set.seed(2)
  out <- split_half_reliability(fake_trials, "angle", n_splits = 50,
                                thresholds = c(angle = 1L))
  expect_gt(stats::median(out, na.rm = TRUE), 0.5)
})

test_that("split_half_reliability applies the engagement threshold", {
  # A threshold no one clears leaves fewer than three participants to
  # correlate, which the function reports as NA rather than as a number
  # computed from two points.
  set.seed(3)
  out <- split_half_reliability(fake_trials, "angle", n_splits = 5,
                                thresholds = c(angle = 999L))
  expect_true(all(is.na(out)))
})

test_that("correlation_test matches cor.test and drops incomplete pairs", {
  x <- c(1, 2, 3, 4, 5, NA)
  y <- c(2, 1, 4, 3, 5, 1)
  out <- correlation_test(x, y)
  reference <- suppressWarnings(
    stats::cor.test(x[1:5], y[1:5], method = "spearman"))
  expect_equal(out$rho, unname(reference$estimate))
  expect_equal(out$p, reference$p.value)
  expect_equal(out$n, 5)
})

test_that("cronbach_alpha is 1 for identical items and low for noise", {
  identical_items <- data.frame(a = 1:10, b = 1:10, c = 1:10)
  expect_equal(cronbach_alpha(identical_items), 1)

  set.seed(4)
  noise <- as.data.frame(matrix(stats::rnorm(300), ncol = 3))
  expect_lt(cronbach_alpha(noise), 0.3)
})

test_that("cronbach_alpha matches the formula on a known case", {
  items <- data.frame(a = c(1, 2, 3, 4), b = c(1, 3, 2, 4), c = c(2, 2, 3, 5))
  k <- 3
  expected <- k / (k - 1) *
    (1 - sum(apply(items, 2, stats::var)) / stats::var(rowSums(items)))
  expect_equal(cronbach_alpha(items), expected)
})

test_that("mars_knots finds a knot that is there and none when it is not", {
  skip_if_not_installed("earth")
  set.seed(5)
  vviq <- seq(16, 80, length.out = 120)

  hinged <- data.frame(
    vviq = vviq,
    outcome = ifelse(vviq < 40, 0.2, 0.2 + 0.02 * (vviq - 40)) +
      stats::rnorm(120, 0, 0.01)
  )
  found <- mars_knots(hinged, "outcome")
  expect_gt(length(found$knots), 0)
  expect_lt(min(abs(found$knots - 40)), 8)

  # On pure noise MARS still retains hinge terms: pruning is by GCV, which
  # is not a significance test. What separates signal from noise is the
  # cross-validated fit, which is why the calling script gates on GRSq and
  # not on whether a knot exists.
  flat <- data.frame(vviq = vviq, outcome = stats::rnorm(120, 0, 0.01))
  noise_fit <- mars_knots(flat, "outcome")
  expect_lt(noise_fit$grsq, 0.1)
  expect_gt(found$grsq, 0.9)
})

test_that("mars_knots drops rows the outcome is missing on", {
  # earth() defaults to na.fail, so this has to happen inside the function
  # or every caller has to remember it.
  skip_if_not_installed("earth")
  data <- data.frame(vviq = c(16, 20, 40, 60, 80, 70),
                     outcome = c(1, NA, 3, 4, 5, NA))
  expect_no_error(out <- mars_knots(data, "outcome"))
  expect_equal(out$n, 4)
})

parts_fixture <- data.frame(
  part_word  = c(0.40, 0.30, 0.35, 0.38),
  part_angle = c(0.25, 0.35, 0.30, 0.29),
  part_color = c(0.35, 0.35, 0.35, 0.33),
  mean_word  = c(0.90, 0.60, 0.70, 0.80),
  mean_angle = c(0.55, 0.70, 0.60, 0.61),
  mean_color = c(0.79, 0.70, 0.70, 0.70)
)

test_that("composition_summary reports one row per part", {
  out <- composition_summary(parts_fixture, "sample A")
  expect_equal(nrow(out), 3)
  expect_true(all(out$sample == "sample A"))
  expect_equal(out$mean[out$part == "part_word"],
               mean(parts_fixture$part_word))
  expect_equal(out$max[out$part == "part_angle"], max(parts_fixture$part_angle))
})

test_that("centred_correlations uses the raw means, not the closed parts", {
  # Closing forces the deviations to sum to zero exactly, which pins the
  # correlations regardless of the data. The informative version is the one
  # computed on the unclosed means, so the function must read mean_* and
  # ignore part_*.
  out <- centred_correlations(parts_fixture)
  closed <- parts_fixture
  closed$mean_word <- parts_fixture$part_word
  closed$mean_angle <- parts_fixture$part_angle
  closed$mean_color <- parts_fixture$part_color
  expect_false(isTRUE(all.equal(out, centred_correlations(closed))))
  expect_setequal(colnames(out), c("word", "angle", "color"))
})

test_that("centred_correlations sits near the closure baseline", {
  # Residualising three variables on their own mean induces roughly -0.5
  # by construction, so that is the reference and not zero.
  set.seed(6)
  means <- data.frame(
    mean_word  = stats::runif(60, 0.6, 0.9),
    mean_angle = stats::runif(60, 0.6, 0.9),
    mean_color = stats::runif(60, 0.6, 0.9)
  )
  out <- centred_correlations(means)
  off_diagonal <- out[upper.tri(out)]
  expect_true(all(off_diagonal < 0))
  expect_lt(max(abs(off_diagonal - (-0.5))), 0.25)
})

test_that("centred_correlations relabels when asked", {
  out <- centred_correlations(
    parts_fixture, labels = c(word = "Word", angle = "Orientation",
                              color = "Colour"))
  expect_setequal(colnames(out), c("Word", "Orientation", "Colour"))
})

test_that("partition_variance leaves the total invariant", {
  # The property the whole partition argument rests on: any two-coordinate
  # ILR basis is a rotation of the same geometry, so only the split between
  # coordinates moves.
  set.seed(7)
  parts <- data.frame(
    part_word  = stats::runif(40, 0.30, 0.45),
    part_angle = stats::runif(40, 0.25, 0.35),
    part_color = stats::runif(40, 0.28, 0.40)
  )
  out <- partition_variance(parts, "sample")
  totals <- out$var_ilr1 + out$var_ilr2
  expect_equal(nrow(out), 3)
  expect_equal(max(totals) - min(totals), 0, tolerance = 1e-8)
  # and the split genuinely differs, so the test above is not vacuous
  expect_gt(diff(range(out$ilr1_share)), 0.01)
  expect_equal(out$ilr1_share, out$var_ilr1 / totals)
})
