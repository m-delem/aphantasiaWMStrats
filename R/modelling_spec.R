# Model specifications, exported so that a script and a vignette use the
# same object rather than two hand-written copies of it.
#
# This matters more than it looks. Vignettes load fitted models with
# `file_refit = "never"`, and brms then returns the cached fit WITHOUT
# checking that the formula and priors it was given match the ones the
# model was fitted with. A vignette that re-specifies a formula inline can
# therefore display something that is not what produced the numbers, with
# nothing to signal the drift. Calling a builder is what prevents that.

#' Response families used for each recall feature
#'
#' @description
#' The three features need three different families, and each choice
#' follows from what the boundary of that feature's scale means rather
#' than from convenience.
#'
#' * **Word: zero-one-inflated Beta.** About 91% of responded word trials
#'   score exactly 1, because a recalled word either matches the target or
#'   does not. That is a genuine point mass and earns an inflation
#'   component, as do the 3% scoring exactly 0.
#' * **Orientation: Beta.** No boundary mass at all once non-responders are
#'   removed.
#' * **Colour: Beta.** Boundary mass exists but is negligible and is an
#'   artifact: colour score is cosine similarity on a continuous wheel, so
#'   an exact 1 is an error of exactly zero degrees, which is pixel
#'   resolution rather than a behaviour. Handle it with
#'   [squeeze_boundaries()] rather than an inflation component.
#'
#' @param feature One of `"word"`, `"angle"`, `"color"`.
#'
#' @returns A brms family object.
#' @export
feature_family <- function(feature = c("word", "angle", "color")) {
  feature <- match.arg(feature)
  rlang::check_installed("brms", reason = "to build model families.")
  if (feature == "word") brms::zero_one_inflated_beta() else brms::Beta()
}

#' Smithson-Verkuilen squeeze
#'
#' @description
#' Beta has zero density at exactly 0 and 1, so a single boundary value
#' gives the likelihood a zero and the fit errors rather than degrades.
#' Smithson and Verkuilen (2006) pull the whole variable a hair inside the
#' open interval:
#'
#' \deqn{y' = \frac{y(n-1) + 0.5}{n}}
#'
#' Monotone, order-preserving, and on this data it moves every value by
#' about one ten-thousandth. Use it where the boundary mass is a
#' measurement artifact; use an inflation component where it is real.
#'
#' @param x A numeric vector on \[0, 1\].
#' @param n The sample size to scale by. Defaults to the number of
#'   non-missing values in `x`, which is the usual choice.
#'
#' @returns `x`, squeezed into the open interval.
#' @export
#'
#' @references
#' Smithson, M., & Verkuilen, J. (2006). A better lemon squeezer?
#' Maximum-likelihood regression with beta-distributed dependent variables.
#' *Psychological Methods*, 11(1), 54-71.
squeeze_boundaries <- function(x, n = sum(!is.na(x))) {
  (x * (n - 1) + 0.5) / n
}

#' Coefficient-wise priors for one response
#'
#' @description
#' Priors are set per coefficient rather than per class, because a VVIQ
#' slope acts over a 64-point range and a binary group offset does not,
#' and on the logit scale a single `class = "b"` prior would treat them as
#' the same quantity.
#'
#' In a multivariate model, population-level coefficients belong to a
#' response, so `resp` is required: `class = "b"` alone matches no
#' parameter and recent brms versions reject it outright. Note that brms
#' strips non-alphanumeric characters from response names, so the argument
#' here is `"scoreword"`, not `"score_word"`.
#'
#' @param response The brms response name, with separators stripped. Pass
#'   `NULL` for a univariate model, where coefficients belong to no
#'   response and `resp` must be omitted rather than empty.
#' @param terms Which coefficients the model contains. Priors are only set
#'   for terms that are present, since naming an absent coefficient makes
#'   brms reject the whole call.
#'
#' @returns A `brmsprior` object.
#' @export
response_priors <- function(
    response,
    terms = c("vviq", "complete_aphant", "parity_rate")
) {
  rlang::check_installed("brms", reason = "to build priors.")

  # a univariate model has no resp, and passing one that does not exist is
  # the same failure as omitting one that does
  resp <- if (is.null(response)) "" else response

  priors <- brms::prior_string("normal(0, 1.5)", class = "Intercept",
                               resp = resp)
  if ("vviq" %in% terms) {
    priors <- c(priors, brms::prior_string("normal(0, 0.05)", class = "b",
                                           coef = "vviq", resp = resp))
  }
  if ("complete_aphant" %in% terms) {
    priors <- c(priors,
                brms::prior_string("normal(0, 1)", class = "b",
                                   coef = "complete_aphantfloor",
                                   resp = resp))
  }
  if ("imagery_group" %in% terms) {
    priors <- c(priors,
                brms::prior_string("normal(0, 1)", class = "b",
                                   coef = "imagery_grouptypical",
                                   resp = resp))
  }
  if ("parity_rate" %in% terms) {
    priors <- c(priors,
                brms::prior_string("normal(0, 1)", class = "b",
                                   coef = "parity_rate", resp = resp))
  }
  priors
}

#' The joint propensity and accuracy model
#'
#' @description
#' Six responses: three Bernoulli gates for whether a feature was reported
#' at all, three bounded accuracies for how well it was reported when it
#' was, sharing a 6x6 correlated participant random-intercept matrix.
#'
#' The 15 correlations are the reason the model exists. They fall into four
#' families: propensity against accuracy within a feature (whether
#' conditioning on responding is legitimate), accuracy against accuracy
#' across features (whether doing well on one costs another), propensity
#' against propensity (whether people who skip one feature skip others),
#' and the six cross terms.
#'
#' `subset()` on each accuracy arm is what lets one row carry six responses
#' with independent non-response, and what lets a participant contribute to
#' a gate whether or not they ever answered that feature. Participants who
#' never answered a feature are invisible to any responders-only analysis
#' and highly informative here.
#'
#' `parity_rate` belongs on the accuracy arms only. It is the dual-task
#' load a participant actually incurred, and it does not predict recall
#' non-response, so there is no reason to put it on the gates. It must be
#' the proportion of parity probes answered, computed from
#' `responded_parity_*`, not a mean of `parity_*_acc`, which scores an
#' unanswered probe as 0 and is a response rate wearing an accuracy name.
#'
#' @param parity Whether to include `parity_rate` on the accuracy arms.
#' @param features Feature stems, in the order the responses should appear.
#'   Gates are built for all of them.
#' @param accuracy_features Which features get an accuracy arm. Defaults to
#'   all of them. Pass `character(0)` for the gates alone, which is the
#'   response-propensity model in its own right, or drop `"word"` to keep
#'   its gate without its accuracy: word's accuracy is excluded from
#'   individual-differences inference anyway, on reliability grounds.
#'
#' @returns A `brmsformula` object. Print it to see every response.
#' @export
#'
#' @seealso [joint_priors()], which must be built with matching arguments.
joint_formula <- function(
    parity = TRUE,
    features = c("word", "angle", "color"),
    accuracy_features = features
) {
  rlang::check_installed("brms", reason = "to build model formulas.")

  gate <- function(feature) {
    brms::bf(
      stats::as.formula(paste0(
        "responded_", feature, " ~ vviq + complete_aphant + (1 | p | id)"
      )),
      family = brms::bernoulli()
    )
  }
  accuracy <- function(feature) {
    terms <- c("vviq", "complete_aphant", if (parity) "parity_rate")
    brms::bf(
      stats::as.formula(paste0(
        "score_", feature, " | subset(responded_", feature, ") ~ ",
        paste(terms, collapse = " + "), " + (1 | p | id)"
      )),
      family = feature_family(feature)
    )
  }

  formula <- Reduce(`+`, lapply(features, gate))
  if (length(accuracy_features)) {
    formula <- Reduce(`+`, lapply(accuracy_features, accuracy), init = formula)
  }
  formula + brms::set_rescor(FALSE)
}

#' Priors for the joint model
#'
#' @description
#' Companion to [joint_formula()], and must be built with the same
#' arguments or brms will reject priors naming coefficients the model does
#' not contain.
#'
#' `lkj(4)` rather than the `lkj(2)` used on smaller models here: 15
#' correlations estimated from 86 participants need more regularisation
#' than 3 do. It puts a marginal SD of about 0.28 on each correlation, so a
#' correlation has to be earned rather than assumed. The marginal prior on
#' any single correlation under `lkj(eta)` in `d` dimensions is
#' `Beta(a, a)` rescaled to (-1, 1) with `a = eta + (d - 2) / 2`
#' (Lewandowski, Kurowicka & Joe, 2009), which is what
#' [lkj_marginal()] returns.
#'
#' @inheritParams joint_formula
#' @param lkj The LKJ shape parameter for the correlation matrix.
#'
#' @returns A `brmsprior` object. Print it to see every prior.
#' @export
joint_priors <- function(
    parity = TRUE,
    lkj = 4,
    features = c("word", "angle", "color"),
    accuracy_features = features
) {
  rlang::check_installed("brms", reason = "to build priors.")

  accuracy_terms <- c("vviq", "complete_aphant", if (parity) "parity_rate")

  priors <- do.call(c, lapply(paste0("responded", features), response_priors,
                              terms = c("vviq", "complete_aphant")))
  if (length(accuracy_features)) {
    priors <- c(priors,
                do.call(c, lapply(paste0("score", accuracy_features),
                                  response_priors, terms = accuracy_terms)))
  }
  c(priors, brms::prior_string(paste0("lkj(", lkj, ")"), class = "cor"))
}

#' Marginal prior on a single correlation under an LKJ prior
#'
#' @description
#' `lkj(eta)` is a prior on a whole correlation matrix, so "how strong is
#' it" is not answerable without fixing the dimension. The marginal on any
#' one off-diagonal element is `Beta(a, a)` rescaled to (-1, 1), with
#' `a = eta + (d - 2) / 2`.
#'
#' Use it to check which correlations actually moved off their prior. A
#' posterior no narrower than this is not a finding, and with 15
#' correlations some of them will not be.
#'
#' @param n Number of draws.
#' @param eta The LKJ shape parameter.
#' @param dimension The size of the correlation matrix.
#'
#' @returns A numeric vector of draws on (-1, 1).
#' @export
#'
#' @references
#' Lewandowski, D., Kurowicka, D., & Joe, H. (2009). Generating random
#' correlation matrices based on vines and extended onion method.
#' *Journal of Multivariate Analysis*, 100(9), 1989-2001.
#'
#' @examples
#' stats::sd(lkj_marginal(1e4, eta = 4, dimension = 6))
lkj_marginal <- function(n, eta, dimension) {
  shape <- eta + (dimension - 2) / 2
  2 * stats::rbeta(n, shape, shape) - 1
}

#' The per-feature performance model
#'
#' @description
#' Three accuracy responses with a per-feature family and correlated
#' participant random intercepts, fitted on responded trials only. The
#' `(1 | p | id)` term carries the cross-feature dependency, delivered as
#' three named pairwise correlations rather than random slopes read
#' relative to whichever feature happens to be the reference.
#'
#' This is the joint model with the gates removed, and it is a robustness
#' check on it rather than corroboration: same data through a simpler lens,
#' so agreement is not independent evidence.
#'
#' @inheritParams joint_formula
#' @param rhs Right-hand side terms, excluding the random effect. The
#'   default is the pre-declared floor-group form.
#'
#' @returns A `brmsformula` object.
#' @export
performance_formula <- function(
    rhs = c("vviq", "complete_aphant"),
    parity = TRUE,
    features = c("word", "angle", "color")
) {
  rlang::check_installed("brms", reason = "to build model formulas.")

  terms <- c(rhs, if (parity) "parity_rate")
  arm <- function(feature) {
    brms::bf(
      stats::as.formula(paste0(
        "score_", feature, " | subset(responded_", feature, ") ~ ",
        paste(terms, collapse = " + "), " + (1 | p | id)"
      )),
      family = feature_family(feature)
    )
  }
  Reduce(`+`, lapply(features, arm)) + brms::set_rescor(FALSE)
}

#' The compositional model
#'
#' @description
#' Both ILR coordinates in one model with residual correlation estimated.
#' That is not cosmetic: any two-coordinate ILR basis is a rotation of the
#' same geometry, and the omnibus test and total variance are invariant to
#' the choice of partition only when the coordinates are fitted jointly
#' with `rescor` on. Two separate univariate fits lose that.
#'
#' Given as two `bf()` calls rather than through `mvbind()`, which has to
#' be resolved from inside the formula and is fragile when the formula is
#' built from a string and brms is not attached.
#'
#' @param rhs Right-hand side terms as a single string, for example
#'   `"vviq + complete_aphant + parity_rate"`.
#'
#' @returns A `brmsformula` object.
#' @export
composition_formula <- function(rhs) {
  rlang::check_installed("brms", reason = "to build model formulas.")

  # gaussian() is set explicitly rather than left to brm()'s default, so
  # the object is self-contained: it prints its own families, and
  # make_standata() can resolve rescor without being told the family
  # separately.
  brms::bf(stats::as.formula(paste("ilr1 ~", rhs)), family = stats::gaussian()) +
    brms::bf(stats::as.formula(paste("ilr2 ~", rhs)), family = stats::gaussian()) +
    brms::set_rescor(TRUE)
}

#' Priors for the compositional model
#'
#' @description
#' The ILR coordinates have SDs near 0.09 and 0.10, so `normal(0, 0.15)` on
#' the coefficients is weakly informative at roughly 1.7 times the outcome
#' SD, the same ratio used in the sibling package `aphantasiaEmotions`.
#'
#' @param responses The response names, with separators stripped.
#'
#' @returns A `brmsprior` object.
#' @export
composition_priors <- function(responses = c("ilr1", "ilr2")) {
  rlang::check_installed("brms", reason = "to build priors.")

  do.call(c, lapply(
    responses,
    \(r) brms::prior_string("normal(0, 0.15)", class = "b", resp = r)
  ))
}
