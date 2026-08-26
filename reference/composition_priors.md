# Priors for the compositional model

The ILR coordinates have SDs near 0.09 and 0.10, so `normal(0, 0.15)` on
the coefficients is weakly informative at roughly 1.7 times the outcome
SD, the same ratio used in the sibling package `aphantasiaEmotions`.

## Usage

``` r
composition_priors(responses = c("ilr1", "ilr2"))
```

## Arguments

- responses:

  The response names, with separators stripped.

## Value

A `brmsprior` object.
