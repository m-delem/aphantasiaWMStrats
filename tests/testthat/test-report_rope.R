# report_rope() takes posterior draws as a numeric vector, so it needs no
# model fit and is tested here rather than with the fitting wrapper.

test_that("report_rope's three proportions partition the posterior", {
  set.seed(9)
  draws <- stats::rnorm(4000, 0.02, 0.1)
  out <- report_rope(draws, outcome_sd = 1)
  expect_equal(out$`Below ROPE` + out$`Inside ROPE` + out$`Above ROPE`, 1,
               tolerance = 1e-8)
})

test_that("report_rope scales the region with the outcome's own SD", {
  # The same draws are practically equivalent to zero against a wide
  # outcome and clearly non-zero against a narrow one. Getting this
  # backwards would invert every conclusion drawn from it.
  draws <- stats::rnorm(4000, 0.05, 0.01)
  expect_equal(report_rope(draws, outcome_sd = 10)$`Inside ROPE`, 1)
  expect_equal(report_rope(draws, outcome_sd = 0.01)$`Inside ROPE`, 0)
})

test_that("report_rope's probability of direction is bounded below by a half", {
  # PD is the mass on the more likely side, so anything under 0.5 would
  # mean the sign convention had been flipped.
  set.seed(10)
  for (mu in c(-1, 0, 1)) {
    expect_gte(report_rope(stats::rnorm(2000, mu, 1), outcome_sd = 1)$PD, 0.5)
  }
})

test_that("report_rope's interval brackets its estimate", {
  set.seed(12)
  out <- report_rope(stats::rnorm(2000, -0.3, 0.2), outcome_sd = 0.2)
  bounds <- as.numeric(strsplit(gsub("\\[|\\]", "", out$`95% CrI`), ", ")[[1]])
  expect_lt(bounds[1], out$Estimate)
  expect_gt(bounds[2], out$Estimate)
})

test_that("report_rope reports the standardised effect", {
  draws <- rep(0.5, 100)
  expect_equal(report_rope(draws, outcome_sd = 0.25)$d, 2)
  # d is unsigned, so a mirrored effect gives the same magnitude
  expect_equal(report_rope(-draws, outcome_sd = 0.25)$d, 2)
})

test_that("report_rope widens its region when asked", {
  set.seed(13)
  draws <- stats::rnorm(4000, 0.15, 0.1)
  narrow <- report_rope(draws, outcome_sd = 1, rope_factor = 0.1)
  wide <- report_rope(draws, outcome_sd = 1, rope_factor = 0.5)
  expect_gt(wide$`Inside ROPE`, narrow$`Inside ROPE`)
})
