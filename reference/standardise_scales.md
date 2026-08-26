# Scale scores, standardised for combining

The scales are on incompatible ranges: VVIQ runs 16 to 80, OSIVQ
subscales 1 to 5, NIEQ dimensions 0 to 100. Anything that combines them,
or measures distance across them, needs them on one scale first.

Standardising rather than weighting by item count, which is what the
earlier clustering study did. Item-count weights assume items are
interchangeable units across instruments with different response formats
and reliabilities, which is a stronger assumption than it looks and one
nobody can check from outside. With scales that converge as hard as
these do the weighting barely changes the result, so the version that is
easier to defend wins.

## Usage

``` r
standardise_scales(scales)
```

## Arguments

- scales:

  A frame from
  [`questionnaire_scales()`](https://m-delem.github.io/aphantasiaWMStrats/reference/questionnaire_scales.md).

## Value

The same frame with the scale columns z-scored.
