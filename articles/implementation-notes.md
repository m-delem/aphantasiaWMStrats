# Implementation notes

This page gathers the conventions behind every model on this site.

## 1. Fitting defaults

Every model is fitted through
[`fit_brms_model()`](https://m-delem.github.io/aphantasiaWMStrats/reference/fit_brms_model.md),
a thin wrapper over
[`brms::brm()`](https://paulbuerkner.com/brms/reference/brm.html) that
fixes the conventions below so they cannot drift between scripts.

Four chains, 2000 **post-warmup** draws each after 1000 warmup
iterations, so `brm()` receives `iter = 3000, warmup = 1000` and keeps
8000 draws in total. The argument below is named `iterations` instead of
`iter` for that reason: it is draws per chain, not a total, and reading
it as brms’ `iter` gives 4000. The joint model additionally uses
`adapt_delta = 0.99` and `max_treedepth = 15`, set from the start: a
model with fifteen correlated random intercepts from 86 participants is
expected to need them.

``` r

args(fit_brms_model)
#> function (..., chains = 4, iterations = 2000, warmup = 1000, 
#>     cores = chains, refresh = 500, backend = "rstan", file_refit = "on_change", 
#>     file_compress = "xz", sample_prior = FALSE, save_pars = NULL, 
#>     adapt_delta = 0.95, max_treedepth = 10, seed = 667) 
#> NULL
```

## 2. Models are objects, not code

Formulas and priors are **exported functions**, not written inline in
the scripts that fit them.

``` r

joint_formula()
#> responded_word ~ vviq + complete_aphant + (1 | p | id) 
#> responded_angle ~ vviq + complete_aphant + (1 | p | id) 
#> responded_color ~ vviq + complete_aphant + (1 | p | id) 
#> score_word | subset(responded_word) ~ vviq + complete_aphant + parity_rate + (1 | p | id) 
#> score_angle | subset(responded_angle) ~ vviq + complete_aphant + parity_rate + (1 | p | id) 
#> score_color | subset(responded_color) ~ vviq + complete_aphant + parity_rate + (1 | p | id)
```

Documentation pages load fitted models with `file_refit = "never"`, and
brms then returns the cached fit **without checking** that the formula
it was handed matches the one the model was fitted with. A page that
re-typed its formula could display something that is not what produced
its numbers, silently and permanently. Calling the same builder the
script called makes that impossible.

## 3. Priors are set per coefficient

``` r

response_priors("scoreangle")
#>            prior     class                 coef group       resp dpar nlpar
#>   normal(0, 1.5) Intercept                            scoreangle           
#>  normal(0, 0.05)         b                 vviq       scoreangle           
#>     normal(0, 1)         b complete_aphantfloor       scoreangle           
#>     normal(0, 1)         b          parity_rate       scoreangle           
#>    lb   ub tag source
#>  <NA> <NA>       user
#>  <NA> <NA>       user
#>  <NA> <NA>       user
#>  <NA> <NA>       user
```

… Not per class. On the logit scale a vividness slope acts over a
64-point range and a binary group offset does not, so a single
`class = "b"` prior would treat them as the same quantity. In a
multivariate model `resp` is required as well: `class = "b"` alone
matches no parameter, and recent brms versions reject it outright.

`lkj(4)` is used for the joint model’s correlation matrix, against
`lkj(2)` elsewhere, because fifteen correlations from 86 participants
need more regularisation than three do. How strong that is depends on
the dimension, which
[`lkj_marginal()`](https://m-delem.github.io/aphantasiaWMStrats/reference/lkj_marginal.md)
makes checkable:

``` r

tibble::tibble(
  eta = c(2, 4),
  `marginal SD on a 6x6 matrix` = vapply(
    c(2, 4), \(eta) stats::sd(lkj_marginal(1e5, eta, 6)), numeric(1))
) |>
  knitr::kable(digits = 3)
```

| eta | marginal SD on a 6x6 matrix |
|----:|----------------------------:|
|   2 |                       0.333 |
|   4 |                       0.278 |

Every correlation reported on the [joint
model](https://m-delem.github.io/aphantasiaWMStrats/articles/joint-model.md)
page carries a `moved` flag for whether its posterior is narrower than
that marginal. A correlation that did not move off its prior is not a
finding. The
[performance](https://m-delem.github.io/aphantasiaWMStrats/articles/performance.md)
page carries the same flag against the `lkj(2)` marginal.

## 4. ROPE conventions

A region of practical equivalence needs a scale. The convention here is
a tenth of the outcome’s own standard deviation, applied through
[`report_rope()`](https://m-delem.github.io/aphantasiaWMStrats/reference/report_rope.md),
so the region moves with the outcome rather than being a fixed number
that means different things on different scales.

That matters most on the compositional coordinates, whose standard
deviations are near 0.09: a ROPE specified in raw units would either
swallow every effect or none.

## 5. Response families, per feature

Three features, three families, each following from what the boundary of
that scale means rather than from convenience.

``` r

tibble::tribble(
  ~feature, ~family, ~why,
  "Word", "Zero-one-inflated Beta",
  "91% at exactly 1 and 3% at exactly 0 are real point masses",
  "Orientation", "Beta", "No boundary mass once non-responders are removed",
  "Colour", "Beta after a squeeze",
  "Boundary mass is pixel resolution on a continuous wheel, not behaviour"
) |>
  knitr::kable()
```

| feature | family | why |
|:---|:---|:---|
| Word | Zero-one-inflated Beta | 91% at exactly 1 and 3% at exactly 0 are real point masses |
| Orientation | Beta | No boundary mass once non-responders are removed |
| Colour | Beta after a squeeze | Boundary mass is pixel resolution on a continuous wheel, not behaviour |

The squeeze is Smithson and Verkuilen’s (2006), implemented in
[`squeeze_boundaries()`](https://m-delem.github.io/aphantasiaWMStrats/reference/squeeze_boundaries.md).
It moves every value by about one ten-thousandth at this sample size,
which is the point: enough to make a Beta likelihood defined, small
enough not to be a modelling decision in itself.

The [model
diagnostics](https://m-delem.github.io/aphantasiaWMStrats/articles/model-diagnostics.md)
page checks that all three describe the data.

## 6. The MARS knot pre-check

Before fitting any segmented model,
[`mars_knots()`](https://m-delem.github.io/aphantasiaWMStrats/reference/mars_knots.md)
asks whether a hinge is identifiable at all, so that a model which would
only report its own prior is not fitted.

Two things it has to get right:

**Knots come off the pruned model**, not off `$cuts`, which also holds
candidate terms the backward pass discarded. Reading `$cuts` whole
reported five knots where the fitted model had one.

**It runs on one row per participant.** The question is the shape of a
between-person relationship. Run on items, each participant contributes
about 63 rows carrying the same vividness value, which inflates the
sample 63-fold and places knots in trial-level noise while the
cross-validated fit stays near zero.

Its silence means no knot survives GCV pruning, not that the predictor
is unrelated to the outcome. Pruning is not a significance test, and on
pure noise MARS still retains hinge terms: what separates signal from
noise is the cross-validated fit. The gate is therefore **GRSq \> 0**: a
knot is only used to seed a segmented model if the generalised R-squared
is positive, since a knot with GRSq at or below zero describes a fit
that does not generalise beyond the sample it was found in.

## 7. What is saved, and what is not

Fitted models are cached to `inst/models/` and loaded by the pages.
Three of them are saved with `save_pars(group = FALSE)`, which discards
the per-participant random-effect draws: `joint-gates`
(`inst/scripts/09`), `perf-joint-orientation` (`10`) and
`comp-trial-multilevel` (`11`).

Those draws are about 89% of the parameters in a fitted model and
nothing on any page reads them: the pages report fixed effects, the
correlation matrix, and `posterior_epred()` at the population level. The
`sd` and `cor` hyperparameters that the correlations and the intraclass
correlation come from are hyperparameters, not group-level draws, and
they survive.

One model is deliberately excluded from that: the per-feature
performance model, because the shrinkage figure on the
[performance](https://m-delem.github.io/aphantasiaWMStrats/articles/performance.md)
page calls
[`brms::posterior_epred()`](https://mc-stan.org/rstantools/reference/posterior_epred.html)
on it at the default `re_formula`, which needs exactly the group-level
draws that would be discarded.

------------------------------------------------------------------------

**Continuing through the Extended Online Report:** this page follows
[model
diagnostics](https://m-delem.github.io/aphantasiaWMStrats/articles/model-diagnostics.md).
To keep reading in order, continue to [what was tried and
withdrawn](https://m-delem.github.io/aphantasiaWMStrats/articles/lessons.md)
next. Or return to [the
analysis](https://m-delem.github.io/aphantasiaWMStrats/articles/analysis-strategy.md)
for what the models were built to do.

------------------------------------------------------------------------

## References

Smithson, M., & Verkuilen, J. (2006). A better lemon squeezer?
Maximum-likelihood regression with beta-distributed dependent variables.
*Psychological Methods*, *11*, 54–71.
<https://doi.org/10.1037/1082-989X.11.1.54>

    #> ─ Session info ───────────────────────────────────────────────────────────────
    #>  setting  value
    #>  version  R version 4.6.1 (2026-06-24)
    #>  os       Ubuntu 22.04.5 LTS
    #>  system   x86_64, linux-gnu
    #>  ui       X11
    #>  language en
    #>  collate  C.UTF-8
    #>  ctype    C.UTF-8
    #>  tz       UTC
    #>  date     2026-08-31
    #>  pandoc   3.8.3 @ /opt/hostedtoolcache/pandoc/3.8.3/x64/ (via rmarkdown)
    #>  quarto   NA
    #> 
    #> ─ Packages ───────────────────────────────────────────────────────────────────
    #>  ! package            * version  date (UTC) lib source
    #>    abind                1.4-8    2024-09-12 [2] CRAN (R 4.6.1)
    #>    aphantasiaWMStrats * 0.1      2026-08-31 [1] local
    #>    backports            1.5.1    2026-04-03 [2] CRAN (R 4.6.1)
    #>    bayesplot            1.16.0   2026-08-25 [2] CRAN (R 4.6.1)
    #>    bridgesampling       1.2-1    2025-11-19 [2] CRAN (R 4.6.1)
    #>    brms                 2.23.0   2025-09-09 [2] CRAN (R 4.6.1)
    #>    Brobdingnag          1.2-9    2022-10-19 [2] CRAN (R 4.6.1)
    #>    bslib                0.12.0   2026-08-04 [2] CRAN (R 4.6.1)
    #>    cachem               1.1.0    2024-05-16 [2] CRAN (R 4.6.1)
    #>    checkmate            2.3.4    2026-02-03 [2] CRAN (R 4.6.1)
    #>    cli                  3.6.6    2026-04-09 [2] CRAN (R 4.6.1)
    #>    coda                 0.19-4.1 2024-01-31 [2] CRAN (R 4.6.1)
    #>    crayon               1.5.3    2024-06-20 [2] CRAN (R 4.6.1)
    #>    desc                 1.4.3    2023-12-10 [2] CRAN (R 4.6.1)
    #>    digest               0.6.39   2025-11-19 [2] CRAN (R 4.6.1)
    #>    distributional       0.8.1    2026-06-27 [2] CRAN (R 4.6.1)
    #>    dplyr                1.2.1    2026-04-03 [2] CRAN (R 4.6.1)
    #>    emmeans              2.0.4    2026-07-15 [2] CRAN (R 4.6.1)
    #>    estimability         2.0.0    2026-06-26 [2] CRAN (R 4.6.1)
    #>    evaluate             1.0.5    2025-08-27 [2] CRAN (R 4.6.1)
    #>    farver               2.1.2    2024-05-13 [2] CRAN (R 4.6.1)
    #>    fastmap              1.2.0    2024-05-15 [2] CRAN (R 4.6.1)
    #>    fs                   2.1.0    2026-04-18 [2] CRAN (R 4.6.1)
    #>    generics             0.1.4    2025-05-09 [2] CRAN (R 4.6.1)
    #>    ggplot2              4.0.3    2026-04-22 [2] CRAN (R 4.6.1)
    #>    glue                 1.8.1    2026-04-17 [2] CRAN (R 4.6.1)
    #>    gtable               0.3.6    2024-10-25 [2] CRAN (R 4.6.1)
    #>    htmltools            0.5.9    2025-12-04 [2] CRAN (R 4.6.1)
    #>    jquerylib            0.1.4    2021-04-26 [2] CRAN (R 4.6.1)
    #>    jsonlite             2.0.0    2025-03-27 [2] CRAN (R 4.6.1)
    #>    knitr                1.51     2025-12-20 [2] CRAN (R 4.6.1)
    #>  P lattice              0.22-9   2026-02-09 [?] CRAN (R 4.6.1)
    #>    lifecycle            1.0.5    2026-01-08 [2] CRAN (R 4.6.1)
    #>    loo                  2.10.1   2026-07-24 [2] CRAN (R 4.6.1)
    #>    magrittr             2.0.5    2026-04-04 [2] CRAN (R 4.6.1)
    #>  P Matrix               1.7-5    2026-03-21 [?] CRAN (R 4.6.1)
    #>    matrixStats          1.5.0    2025-01-07 [2] CRAN (R 4.6.1)
    #>    mvtnorm              1.4-2    2026-07-12 [2] CRAN (R 4.6.1)
    #>  P nlme                 3.1-169  2026-03-27 [?] CRAN (R 4.6.1)
    #>    otel                 0.2.0    2025-08-29 [2] CRAN (R 4.6.1)
    #>    pillar               1.11.1   2025-09-17 [2] CRAN (R 4.6.1)
    #>    pkgconfig            2.0.3    2019-09-22 [2] CRAN (R 4.6.1)
    #>    pkgdown              2.2.1    2026-07-07 [2] any (@2.2.1)
    #>    posterior            1.7.0    2026-04-01 [2] CRAN (R 4.6.1)
    #>    R6                   2.6.1    2025-02-15 [2] CRAN (R 4.6.1)
    #>    ragg                 1.5.2    2026-03-23 [2] CRAN (R 4.6.1)
    #>    RColorBrewer         1.1-3    2022-04-03 [2] CRAN (R 4.6.1)
    #>    Rcpp                 1.1.2    2026-07-05 [2] CRAN (R 4.6.1)
    #>    RcppParallel         6.2.1    2026-08-27 [2] CRAN (R 4.6.1)
    #>    renv                 1.0.7    2024-04-11 [2] RSPM (R 4.6.1)
    #>    rlang                1.3.0    2026-07-05 [2] CRAN (R 4.6.1)
    #>    rmarkdown            2.31     2026-03-26 [2] CRAN (R 4.6.1)
    #>    rstantools           2.7.1    2026-08-29 [2] CRAN (R 4.6.1)
    #>    S7                   0.2.2    2026-04-22 [2] CRAN (R 4.6.1)
    #>    sass                 0.4.10   2025-04-11 [2] CRAN (R 4.6.1)
    #>    scales               1.4.0    2025-04-24 [2] CRAN (R 4.6.1)
    #>    sessioninfo          1.2.4    2026-06-04 [2] CRAN (R 4.6.1)
    #>    stringi              1.8.9    2026-08-04 [2] CRAN (R 4.6.1)
    #>    stringr              1.6.0    2025-11-04 [2] CRAN (R 4.6.1)
    #>    systemfonts          1.3.2    2026-03-05 [2] CRAN (R 4.6.1)
    #>    tensorA              0.36.2.1 2023-12-13 [2] CRAN (R 4.6.1)
    #>    textshaping          1.0.5    2026-03-06 [2] CRAN (R 4.6.1)
    #>    tibble               3.3.1    2026-01-11 [2] CRAN (R 4.6.1)
    #>    tidyselect           1.2.1    2024-03-11 [2] CRAN (R 4.6.1)
    #>    vctrs                0.7.3    2026-04-11 [2] CRAN (R 4.6.1)
    #>    xfun                 0.60     2026-07-09 [2] CRAN (R 4.6.1)
    #>    xtable               1.8-8    2026-02-22 [2] CRAN (R 4.6.1)
    #>    yaml                 2.3.12   2025-12-10 [2] CRAN (R 4.6.1)
    #> 
    #>  [1] /tmp/RtmpjrXxde/temp_libpath83d0647deac5
    #>  [2] /home/runner/.cache/R/renv/library/aphantasiaWMStrats-f7ce8556/linux-ubuntu-jammy/R-4.6/x86_64-pc-linux-gnu
    #>  [3] /home/runner/.cache/R/renv/sandbox/linux-ubuntu-jammy/R-4.6/x86_64-pc-linux-gnu/e7c0fad7
    #> 
    #>  * ── Packages attached to the search path.
    #>  P ── Loaded and on-disk path mismatch.
    #> 
    #> ──────────────────────────────────────────────────────────────────────────────
