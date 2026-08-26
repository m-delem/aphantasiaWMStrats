# Custom discrete scale for imagery groups

Ported from `aphantasiaEmotions`, unchanged, so that "aphantasia" and
"typical" are the same two Okabe-Ito colours in both packages.

## Usage

``` r
scale_discrete_aphantasia(aesthetics = c("color", "fill"), name = NULL, ...)
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
