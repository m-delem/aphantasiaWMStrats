# Coefficient-wise priors for one response

Priors are set per coefficient rather than per class, because a VVIQ
slope acts over a 64-point range and a binary group offset does not, and
on the logit scale a single `class = "b"` prior would treat them as the
same quantity.

In a multivariate model, population-level coefficients belong to a
response, so `resp` is required: `class = "b"` alone matches no
parameter and recent brms versions reject it outright. Note that brms
strips non-alphanumeric characters from response names, so the argument
here is `"scoreword"`, not `"score_word"`.

## Usage

``` r
response_priors(response, terms = c("vviq", "complete_aphant", "parity_rate"))
```

## Arguments

- response:

  The brms response name, with separators stripped. Pass `NULL` for a
  univariate model, where coefficients belong to no response and `resp`
  must be omitted rather than empty.

- terms:

  Which coefficients the model contains. Priors are only set for terms
  that are present, since naming an absent coefficient makes brms reject
  the whole call.

## Value

A `brmsprior` object.
