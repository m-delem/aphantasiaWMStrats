test_that("squeeze_boundaries moves values off the boundary and nowhere else", {
  x <- c(0, 0.5, 1)
  y <- squeeze_boundaries(x, n = 1000)
  expect_gt(min(y), 0)
  expect_lt(max(y), 1)
  # a monotone affine transform, so ordering is preserved exactly
  expect_identical(order(x), order(y))
  # and the displacement shrinks as n grows
  expect_lt(max(abs(squeeze_boundaries(x, n = 1e5) - x)),
            max(abs(squeeze_boundaries(x, n = 1e2) - x)))
})

test_that("lkj_marginal matches its analytic SD", {
  set.seed(1)
  # Beta(a, a) rescaled to (-1, 1) has variance 1 / (2a + 1)
  for (eta in c(2, 4)) {
    a <- eta + (6 - 2) / 2
    expect_equal(stats::sd(lkj_marginal(2e5, eta, 6)),
                 sqrt(1 / (2 * a + 1)), tolerance = 0.02)
  }
  # a larger eta regularises harder
  expect_lt(stats::sd(lkj_marginal(2e5, 8, 6)),
            stats::sd(lkj_marginal(2e5, 2, 6)))
})

test_that("feature_family gives word an inflated family and the others plain Beta", {
  skip_if_not_installed("brms")
  expect_equal(feature_family("word")$family, "zero_one_inflated_beta")
  expect_equal(feature_family("angle")$family, "beta")
  expect_equal(feature_family("color")$family, "beta")
})

test_that("response_priors only names coefficients the model contains", {
  # A prior naming an absent coefficient makes brms reject the whole call,
  # which is how the intercept-only candidates failed the first time.
  skip_if_not_installed("brms")
  full <- response_priors("scoreangle")
  lean <- response_priors("scoreangle", terms = "vviq")
  expect_true("parity_rate" %in% full$coef)
  expect_false("parity_rate" %in% lean$coef)
  expect_false("complete_aphantfloor" %in% lean$coef)
  # resp is required in a multivariate model: class = "b" alone matches
  # no parameter
  expect_true(all(full$resp == "scoreangle"))
})

test_that("joint_formula carries six responses, or three for the gates alone", {
  skip_if_not_installed("brms")
  expect_length(joint_formula()$forms, 6)
  expect_length(joint_formula(accuracy_features = character(0))$forms, 3)
  expect_length(joint_formula(accuracy_features = c("angle", "color"))$forms, 5)
  # brms strips separators from response names, so these are the keys
  responses <- names(joint_formula(accuracy_features = c("angle", "color"))$forms)
  expect_true("respondedword" %in% responses)
  expect_false("scoreword" %in% responses)
})

test_that("joint_formula puts parity on the accuracy arms only", {
  skip_if_not_installed("brms")
  forms <- joint_formula()$forms
  gate <- deparse1(forms[["respondedangle"]]$formula)
  accuracy <- deparse1(forms[["scoreangle"]]$formula)
  expect_false(grepl("parity_rate", gate))
  expect_true(grepl("parity_rate", accuracy))
  expect_false(grepl("parity_rate",
                     deparse1(joint_formula(parity = FALSE)$forms[["scoreangle"]]$formula)))
})

test_that("joint_priors matches joint_formula in every configuration", {
  # The pair has to be built with the same arguments or brms rejects
  # priors naming coefficients the model does not contain. This is the
  # invariant the two functions exist to protect.
  skip_if_not_installed("brms")
  data <- data.frame(
    id = rep(letters[1:6], each = 4),
    vviq = rep(c(16, 40, 60, 16, 55, 70), each = 4),
    parity_rate = rep(seq(0, 1, length.out = 6), each = 4),
    complete_aphant = factor(rep(c("floor", "above_floor"), each = 12),
                             levels = c("above_floor", "floor")),
    score_word = runif(24, .2, .9), score_angle = runif(24, .2, .9),
    score_color = runif(24, .2, .9),
    responded_word = TRUE, responded_angle = TRUE, responded_color = TRUE
  )
  configurations <- list(
    c("word", "angle", "color"), c("angle", "color"), character(0)
  )
  for (parity in c(TRUE, FALSE)) {
    for (accuracy in configurations) {
      expect_no_error(
        brms::validate_prior(
          joint_priors(parity = parity, accuracy_features = accuracy),
          formula = joint_formula(parity = parity, accuracy_features = accuracy),
          data = data
        )
      )
    }
  }
})

test_that("composition_formula estimates residual correlation", {
  skip_if_not_installed("brms")
  # rescor is what makes the omnibus test invariant to the partition; two
  # separate univariate fits would lose that
  formula <- composition_formula("vviq + complete_aphant")
  expect_true(formula$rescor)
  expect_length(formula$forms, 2)
})

test_that("composition_priors covers both coordinates", {
  skip_if_not_installed("brms")
  priors <- composition_priors()
  expect_setequal(priors$resp, c("ilr1", "ilr2"))
  expect_true(all(priors$class == "b"))
})

test_that("composition_priors matches composition_formula", {
  skip_if_not_installed("brms")
  data <- data.frame(
    ilr1 = stats::rnorm(20), ilr2 = stats::rnorm(20),
    vviq = stats::rnorm(20, 40, 10),
    complete_aphant = factor(rep(c("above_floor", "floor"), 10),
                             levels = c("above_floor", "floor"))
  )
  expect_no_error(
    brms::validate_prior(
      composition_priors(),
      formula = composition_formula("vviq + complete_aphant"),
      data = data
    )
  )
})

test_that("performance_formula gives each feature its own family", {
  skip_if_not_installed("brms")
  formula <- performance_formula()
  expect_length(formula$forms, 3)
  # word's ceiling is a real point mass; the other two are not
  expect_equal(formula$forms[["scoreword"]]$family$family,
               "zero_one_inflated_beta")
  expect_equal(formula$forms[["scoreangle"]]$family$family, "beta")
  expect_equal(formula$forms[["scorecolor"]]$family$family, "beta")
  # rescor is off: it is only defined for gaussian and student responses,
  # and the dependency here lives in the random effects instead
  expect_false(formula$rescor)
})

test_that("performance_formula respects the parity switch", {
  skip_if_not_installed("brms")
  with_parity <- deparse1(performance_formula()$forms[["scoreangle"]]$formula)
  without <- deparse1(
    performance_formula(parity = FALSE)$forms[["scoreangle"]]$formula)
  expect_true(grepl("parity_rate", with_parity))
  expect_false(grepl("parity_rate", without))
  # both keep the subset(), which is what lets a row carry three responses
  # with independent non-response
  expect_true(grepl("subset\\(responded_angle\\)", without))
})
