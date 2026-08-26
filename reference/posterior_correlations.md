# Participant-level correlations from a multivariate model

Pulls the group-level correlation parameters out of a fitted model and
returns them tidily, with the response names recovered from the
parameter names rather than assumed. brms names these
`cor_<group>__<a>_Intercept__<b>_Intercept`, and the order of `a` and
`b` follows the order the responses appear in the formula, so a caller
asking for a specific pair cannot know in advance which way round it is.

Also reports whether each posterior is narrower than the marginal prior
on a single correlation under `lkj(eta)` (see
[`lkj_marginal()`](https://m-delem.github.io/aphantasiaWMStrats/reference/lkj_marginal.md)).
With fifteen correlations estimated from fewer than a hundred
participants, some will not have moved, and a correlation that did not
move is not a finding.

## Usage

``` r
posterior_correlations(draws, group = "id", lkj = 4, dimension = NULL)
```

## Arguments

- draws:

  A `draws_df`, or anything with the correlation columns, typically
  `brms::as_draws_df(model)`.

- group:

  The grouping factor name used in the model.

- lkj:

  The LKJ shape parameter the model was fitted with, used for the
  `moved` column. `NULL` skips that column.

- dimension:

  Size of the correlation matrix, for the same purpose.

## Value

A tibble with one row per correlation: the two responses, the median, a
95% interval, the probability of direction, and `moved`.
