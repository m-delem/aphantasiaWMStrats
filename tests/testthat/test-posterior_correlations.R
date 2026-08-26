# posterior_correlations() takes a draws data frame, not a fitted model, so
# it needs no sampling: a frame with the right column names is enough.

fake_draws <- function(n = 2000, seed = 1) {
  set.seed(seed)
  tibble::tibble(
    # brms names these cor_<group>__<a>_Intercept__<b>_Intercept, and the
    # order of a and b follows the order the responses appear in the
    # formula, not any order the caller chooses.
    cor_id__respondedangle_Intercept__scoreangle_Intercept =
      stats::rnorm(n, 0.55, 0.10),
    cor_id__scoreangle_Intercept__scorecolor_Intercept =
      stats::rnorm(n, 0.45, 0.11),
    cor_id__respondedangle_Intercept__scorecolor_Intercept =
      stats::rnorm(n, -0.02, 0.12),
    b_scoreangle_vviq = stats::rnorm(n),
    sd_id__scoreangle_Intercept = stats::rgamma(n, 2)
  )
}

test_that("posterior_correlations finds every correlation and nothing else", {
  out <- posterior_correlations(fake_draws(), dimension = 3)
  expect_equal(nrow(out), 3)
  expect_setequal(
    names(out),
    c("response_a", "response_b", "median", "lower", "upper", "pd", "moved")
  )
  # the b_ and sd_ columns must not be picked up
  expect_false(any(grepl("^b_|^sd_", c(out$response_a, out$response_b))))
})

test_that("posterior_correlations recovers response names from the parameter", {
  out <- posterior_correlations(fake_draws(), dimension = 3)
  pairs <- paste(out$response_a, out$response_b)
  expect_true("respondedangle scoreangle" %in% pairs)
  expect_true("scoreangle scorecolor" %in% pairs)
  # names must not keep the _Intercept suffix or the cor_id__ prefix
  expect_false(any(grepl("Intercept|cor_id", c(out$response_a, out$response_b))))
})

test_that("posterior_correlations summarises the draws correctly", {
  draws <- fake_draws()
  values <- draws$cor_id__respondedangle_Intercept__scoreangle_Intercept
  out <- posterior_correlations(draws, dimension = 3)
  row <- out[out$response_a == "respondedangle" &
               out$response_b == "scoreangle", ]

  expect_equal(row$median, stats::median(values))
  expect_equal(row$lower, unname(stats::quantile(values, 0.025)))
  expect_equal(row$upper, unname(stats::quantile(values, 0.975)))
  expect_equal(row$pd, max(mean(values > 0), mean(values < 0)))
})

test_that("probability of direction is never below a half", {
  # PD is the mass on the more likely side. Below 0.5 would mean the sign
  # convention had been inverted.
  out <- posterior_correlations(fake_draws(seed = 7), dimension = 3)
  expect_true(all(out$pd >= 0.5))
})

test_that("`moved` compares the posterior against the LKJ marginal", {
  # A correlation whose posterior is no narrower than its prior has not
  # been informed by the data, and reporting it as a finding would be
  # reporting the prior.
  draws <- fake_draws()
  # a posterior far wider than the lkj(4) marginal on a 3x3 (SD ~ 0.45)
  draws$cor_id__scoreword_Intercept__scoreangle_Intercept <-
    stats::runif(nrow(draws), -1, 1)

  out <- posterior_correlations(draws, lkj = 4, dimension = 3)
  wide <- out[out$response_b == "scoreangle" & out$response_a == "scoreword", ]
  narrow <- out[out$response_a == "respondedangle" &
                  out$response_b == "scoreangle", ]
  expect_false(wide$moved)
  expect_true(narrow$moved)
})

test_that("lkj = NULL skips the prior comparison", {
  out <- posterior_correlations(fake_draws(), lkj = NULL)
  expect_true(all(is.na(out$moved)))
})

test_that("the matrix dimension is inferred from the number of correlations", {
  # A d-dimensional matrix has d(d-1)/2 off-diagonal elements, so the
  # dimension is recoverable and the caller should not have to supply it.
  # Getting it wrong would use the wrong prior width in `moved`.
  three <- posterior_correlations(fake_draws())
  expect_equal(nrow(three), 3)
  expect_equal(
    three$moved,
    posterior_correlations(fake_draws(), dimension = 3)$moved
  )
})

test_that("posterior_correlations fails loudly on a group that is not there", {
  # Silently returning nothing would leave a page with an empty table and
  # no indication why.
  expect_error(
    posterior_correlations(fake_draws(), group = "participant"),
    "No correlation parameters"
  )
})
