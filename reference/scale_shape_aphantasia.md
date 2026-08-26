# Custom shape scale for imagery groups

The shape counterpart to
[`scale_discrete_aphantasia()`](https://m-delem.github.io/aphantasiaWMStrats/reference/scale_discrete_aphantasia.md).
Uses the same names and the same labels, which is what lets ggplot2
merge the colour and shape guides into a single legend instead of
drawing two.

## Usage

``` r
scale_shape_aphantasia(name = NULL, ...)
```

## Arguments

- name:

  Name of the scale.

- ...:

  Additional arguments passed to
  [`ggplot2::scale_shape_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).

## Value

A ggplot2 scale object for the shape aesthetic.
