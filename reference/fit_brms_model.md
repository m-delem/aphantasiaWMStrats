# Fit a Bayesian model using the brms package with default settings

Ported from `aphantasiaEmotions` so both packages fit models the same
way. `iterations` is post-warmup draws **per chain**, not a total.

## Usage

``` r
fit_brms_model(
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
)
```

## Arguments

- ...:

  Arguments passed to
  [`brms::brm()`](https://paulbuerkner.com/brms/reference/brm.html),
  such as formula, data, family, priors, file.

- chains:

  Number of MCMC chains. Default 4.

- iterations:

  Post-warmup iterations per chain. Default 2000.

- warmup:

  Warmup iterations per chain. Default 1000.

- cores:

  Cores for parallel processing. Default `chains`.

- refresh:

  Frequency of progress updates. Default 500.

- backend:

  Backend for fitting. Default "rstan" (cmdstanr conflicts with
  pkgdown).

- file_refit:

  Condition for refitting a cached model. Default "on_change".

- file_compress:

  Compression for the saved model. Default "xz".

- sample_prior:

  Whether to draw prior samples. Default FALSE.

- save_pars:

  Parameters to save. Default NULL.

- adapt_delta:

  Target acceptance rate. Default 0.95.

- max_treedepth:

  Maximum treedepth. Default 10.

- seed:

  Random seed. Default 667.

## Value

A fitted brms model object.
