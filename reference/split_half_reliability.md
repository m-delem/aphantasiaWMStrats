# Split-half reliability of a per-feature score

Splits at the **trial** level rather than by odd and even items, because
items within a trial share a memory load: an odd-even split would
correlate two halves of the same trial and overstate reliability.

Participants are included per feature, on their own responded-item
count, since someone can be measurable on colour and not on orientation.

## Usage

``` r
split_half_reliability(
  data,
  feature,
  n_splits = 1000,
  thresholds = wm_thresholds(),
  trial_col = "trial_uid"
)
```

## Arguments

- data:

  Item-level data for one version, test blocks only.

- feature:

  One of `"word"`, `"angle"`, `"color"`.

- n_splits:

  Number of random splits.

- thresholds:

  Minimum responded items per feature, defaulting to
  [`wm_thresholds()`](https://m-delem.github.io/aphantasiaWMStrats/reference/wm_thresholds.md).

- trial_col:

  Name of the column identifying a trial.

## Value

A numeric vector of `n_splits` half-test correlations, on the raw scale.
Apply
[`spearman_brown()`](https://m-delem.github.io/aphantasiaWMStrats/reference/spearman_brown.md)
to get full-test reliability.
