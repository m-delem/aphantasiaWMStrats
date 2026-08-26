# Custom x-axis scale for imagery groups

Ported from `aphantasiaEmotions`. The four-level mapping is kept even
though v1 of this study only supports the two-group split (it has three
hyperphantasic participants), so that the same scale serves
`vviq_group_2` and `vviq_group_4` and colours stay identical across both
packages.

## Usage

``` r
scale_x_aphantasia(name = NULL, mult = 0, add = c(0, 0.7), ...)
```

## Arguments

- name:

  Name of the x-axis.

- mult:

  Multiplier for
  [`ggplot2::expansion()`](https://ggplot2.tidyverse.org/reference/expansion.html).

- add:

  Additive for
  [`ggplot2::expansion()`](https://ggplot2.tidyverse.org/reference/expansion.html).

- ...:

  Additional arguments passed to
  [`ggplot2::scale_x_discrete()`](https://ggplot2.tidyverse.org/reference/scale_discrete.html).

## Value

A ggplot2 scale object for the x-axis.
