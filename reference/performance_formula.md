# The per-feature performance model

Three accuracy responses with a per-feature family and correlated
participant random intercepts, fitted on responded items only. The
`(1 | p | id)` term carries the cross-feature dependency, delivered as
three named pairwise correlations rather than random slopes read
relative to whichever feature happens to be the reference.

This is the joint model with the gates removed, and it is a robustness
check on it rather than corroboration: same data through a simpler lens,
so agreement is not independent evidence.

## Usage

``` r
performance_formula(
  rhs = c("vviq", "complete_aphant"),
  parity = TRUE,
  features = c("word", "angle", "color")
)
```

## Arguments

- rhs:

  Right-hand side terms, excluding the random effect. The default is the
  pre-declared floor-group form.

- parity:

  Whether to include `parity_rate` on the accuracy arms.

- features:

  Feature stems, in the order the responses should appear. Gates are
  built for all of them.

## Value

A `brmsformula` object.
