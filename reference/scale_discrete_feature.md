# Custom discrete scale for the three WM-FTT features

Word, orientation and colour recur in nearly every figure in this
package, so they get fixed Okabe-Ito colours the same way the imagery
groups do. Deliberately avoids the two colours
[`scale_discrete_aphantasia()`](https://m-delem.github.io/aphantasiaWMStrats/reference/scale_discrete_aphantasia.md)
uses for aphantasia and typical imagers, so a figure can carry both
without collision.

Accepts either the display labels or the column stems used in the data,
so the same scale works before and after relabelling.

## Usage

``` r
scale_discrete_feature(aesthetics = c("color", "fill"), name = NULL, ...)
```

## Arguments

- aesthetics:

  Aesthetics to apply the scale to.

- name:

  Name of the scale.

- ...:

  Additional arguments passed to
  [`ggplot2::scale_discrete_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).

## Value

A ggplot2 scale object for discrete aesthetics.
