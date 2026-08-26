# MARS knot search, on participant means

Asks whether a hinge in the relationship between a feature and VVIQ is
identifiable before a segmented model is fitted, so that a model which
would only report its own prior is not fitted at all.

Two things it has to get right, both of which were got wrong first.
Knots come off the **pruned** model (`selected.terms`), not off `$cuts`,
which also carries candidate terms the backward pass discarded: reading
`$cuts` whole reported five knots where the fitted model had one. And it
runs on **one row per participant**, because the question is the shape
of a between-person relationship. Run on items, each participant
contributes about 63 rows carrying the same VVIQ value, which inflates
the sample 63-fold and places knots in item-level noise while the
cross-validated fit stays near zero.

Note what silence means: no knot survives GCV pruning, not that the
predictor is unrelated to the outcome. Pruning at this sample size is
conservative and will drop a weak linear term.

## Usage

``` r
mars_knots(data, outcome, predictor = "vviq")
```

## Arguments

- data:

  One row per participant.

- outcome:

  Name of the outcome column.

- predictor:

  Name of the predictor column.

## Value

A list with `knots`, `n_terms`, `n`, `rsq` and `grsq`.
