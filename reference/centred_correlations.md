# Correlations between features after removing each participant's level

Residualising each participant's feature means on their own mean, which
is what "do they trade off" asks. The reference is **not zero**:
residualising three variables on their own mean induces a correlation of
about -0.5 by construction, so only departures from that carry
information.

Computed on the raw means rather than on the closed parts. Closing
forces the deviations to sum to zero exactly, which pins the
correlations and makes the comparison uninformative.

## Usage

``` r
centred_correlations(means, labels = NULL)
```

## Arguments

- means:

  A data frame with `mean_*` columns, as returned by
  [`compose_features()`](https://m-delem.github.io/aphantasiaWMStrats/reference/compose_features.md).

- labels:

  Optional named vector for renaming the output.

## Value

A correlation matrix.
