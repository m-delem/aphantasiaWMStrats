# Priors for the joint model

Companion to
[`joint_formula()`](https://m-delem.github.io/aphantasiaWMStrats/reference/joint_formula.md),
and must be built with the same arguments or brms will reject priors
naming coefficients the model does not contain.

`lkj(4)` rather than the `lkj(2)` used on smaller models here: 15
correlations estimated from 86 participants need more regularisation
than 3 do. It puts a marginal SD of about 0.28 on each correlation, so a
correlation has to be earned rather than assumed. The marginal prior on
any single correlation under `lkj(eta)` in `d` dimensions is
`Beta(a, a)` rescaled to (-1, 1) with `a = eta + (d - 2) / 2`
(Lewandowski, Kurowicka & Joe, 2009), which is what
[`lkj_marginal()`](https://m-delem.github.io/aphantasiaWMStrats/reference/lkj_marginal.md)
returns.

## Usage

``` r
joint_priors(
  parity = TRUE,
  lkj = 4,
  features = c("word", "angle", "color"),
  accuracy_features = features
)
```

## Arguments

- parity:

  Whether to include `parity_rate` on the accuracy arms.

- lkj:

  The LKJ shape parameter for the correlation matrix.

- features:

  Feature stems, in the order the responses should appear. Gates are
  built for all of them.

- accuracy_features:

  Which features get an accuracy arm. Defaults to all of them. Pass
  `character(0)` for the gates alone, which is the response-propensity
  model in its own right, or drop `"word"` to keep its gate without its
  accuracy: word's accuracy is excluded from individual-differences
  inference anyway, on reliability grounds.

## Value

A `brmsprior` object. Print it to see every prior.
