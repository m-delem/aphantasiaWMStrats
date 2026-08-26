# Summarise posterior draws against a ROPE

A lighter relative of `aphantasiaEmotions::report_rope()`, taking
posterior draws directly rather than a `marginaleffects` object, so it
works on the multivariate ILR models here without pulling in another
dependency.

The ROPE is expressed in units of the outcome's own SD, following
Kruschke's 0.1 SD convention, which is what
[`bayestestR::rope_range()`](https://easystats.github.io/bayestestR/reference/rope_range.html)
applies to a Gaussian model. Stating "no effect established" through the
proportion of the posterior inside a region of practical equivalence is
more honest than a non-significant p-value, and matters here because
several of this study's models are fitted at sample sizes where that is
the likely outcome.

## Usage

``` r
report_rope(draws, outcome_sd, rope_factor = 0.1, digits = 3)
```

## Arguments

- draws:

  A numeric vector of posterior draws for one parameter.

- outcome_sd:

  The SD of the outcome the parameter is expressed in.

- rope_factor:

  Half-width of the ROPE in outcome SD units. Default 0.1.

- digits:

  Rounding for the returned summary.

## Value

A one-row tibble with the estimate, 95% credible interval, standardised
effect size, probability of direction, and the proportion of the
posterior below, inside and above the ROPE.
