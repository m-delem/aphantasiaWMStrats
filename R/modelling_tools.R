#' Fit a Bayesian model using the brms package with default settings
#'
#' @description
#' Ported from `aphantasiaEmotions` so both packages fit models the same way.
#' `iterations` is post-warmup draws **per chain**, not a total.
#'
#' @param ... Arguments passed to `brms::brm()`, such as formula, data,
#'   family, priors, file.
#' @param chains Number of MCMC chains. Default 4.
#' @param iterations Post-warmup iterations per chain. Default 2000.
#' @param warmup Warmup iterations per chain. Default 1000.
#' @param cores Cores for parallel processing. Default `chains`.
#' @param refresh Frequency of progress updates. Default 500.
#' @param backend Backend for fitting. Default "rstan" (cmdstanr conflicts
#'   with pkgdown).
#' @param file_refit Condition for refitting a cached model. Default
#'   "on_change".
#' @param file_compress Compression for the saved model. Default "xz".
#' @param sample_prior Whether to draw prior samples. Default FALSE.
#' @param save_pars Parameters to save. Default NULL.
#' @param adapt_delta Target acceptance rate. Default 0.95.
#' @param max_treedepth Maximum treedepth. Default 10.
#' @param seed Random seed. Default 667.
#'
#' @returns A fitted brms model object.
#' @export
fit_brms_model <- function(
    ...,
    chains = 4,
    iterations = 2000,
    warmup = 1000,
    cores = chains,
    refresh = 500,
    backend = "rstan",
    file_refit = "on_change",
    file_compress = "xz",
    sample_prior = FALSE,
    save_pars = NULL,
    adapt_delta = 0.95,
    max_treedepth = 10,
    seed = 667
) {
  rlang::check_installed("brms", reason = "to fit Bayesian models.")

  brms::brm(
    ...,
    chains = chains,
    cores = cores,
    iter = iterations + warmup,
    warmup = warmup,
    refresh = refresh,
    backend = backend,
    file_refit = file_refit,
    file_compress = file_compress,
    sample_prior = sample_prior,
    save_pars = save_pars,
    control = list(adapt_delta = adapt_delta, max_treedepth = max_treedepth),
    seed = seed
  )
}

#' Summarise posterior draws against a ROPE
#'
#' @description
#' A lighter relative of `aphantasiaEmotions::report_rope()`, taking posterior
#' draws directly rather than a `marginaleffects` object, so it works on the
#' multivariate ILR models here without pulling in another dependency.
#'
#' The ROPE is expressed in units of the outcome's own SD, following
#' Kruschke's 0.1 SD convention, which is what `bayestestR::rope_range()`
#' applies to a Gaussian model. Stating "no effect established" through the
#' proportion of the posterior inside a region of practical equivalence is
#' more informative than a non-significant p-value, and matters here because
#' several of this study's models are fitted at sample sizes where that is
#' the likely outcome.
#'
#' @param draws A numeric vector of posterior draws for one parameter.
#' @param outcome_sd The SD of the outcome the parameter is expressed in.
#' @param rope_factor Half-width of the ROPE in outcome SD units. Default 0.1.
#' @param digits Rounding for the returned summary.
#'
#' @returns A one-row tibble with the estimate, 95% credible interval,
#'   standardised effect size, probability of direction, and the proportion of
#'   the posterior below, inside and above the ROPE.
#' @export
report_rope <- function(draws, outcome_sd, rope_factor = 0.1, digits = 3) {
  rope <- c(-1, 1) * rope_factor * outcome_sd

  tibble::tibble(
    Estimate = round(mean(draws), digits),
    "95% CrI" = paste0(
      "[", round(stats::quantile(draws, 0.025), digits), ", ",
      round(stats::quantile(draws, 0.975), digits), "]"
    ),
    d = round(abs(mean(draws)) / outcome_sd, 2),
    PD = round(max(mean(draws > 0), mean(draws < 0)), digits),
    "Below ROPE" = round(mean(draws < rope[1]), digits),
    "Inside ROPE" = round(mean(draws >= rope[1] & draws <= rope[2]), digits),
    "Above ROPE" = round(mean(draws > rope[2]), digits)
  )
}
