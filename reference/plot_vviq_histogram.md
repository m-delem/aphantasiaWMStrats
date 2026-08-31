# Marginal histogram of imagery vividness

The piece of data that motivates the floor-group model on its own: the
vividness distribution is not smoothly continuous, but a sharp isolated
spike at the scale floor plus an irregular remainder above it. Ported
from `aphantasiaEmotions`, where it sits above the main panel.

Stacked above
[`plot_floor_group()`](https://m-delem.github.io/aphantasiaWMStrats/reference/plot_floor_group.md)
with `patchwork`, sharing an x axis, it makes the case for the model
before the model is shown.

Bins are computed directly and drawn as two `geom_col()` layers rather
than by `geom_histogram()` with a fill aesthetic. Mapping fill to a
floor indicator stacks two groups inside whichever bin straddles the
boundary, which colours part of the floor bar as above-floor.

## Usage

``` r
plot_vviq_histogram(
  vviq,
  floor_x = 16,
  binwidth = 2,
  floor_fill = "#C44E52",
  floor_colour = "#8B3A3E",
  floor_alpha = 0.5,
  gradient = ggplot2::scale_fill_viridis_c(option = "viridis", guide = "none"),
  left_expansion = 0.09,
  y_lab = "n",
  ...
)
```

## Arguments

- vviq:

  A numeric vector of vividness scores.

- floor_x:

  The scale minimum, drawn as its own bar.

- binwidth:

  Histogram bin width for the above-floor bars. The floor bar is drawn
  separately and is not affected by it.

- floor_fill, floor_colour, floor_alpha:

  Fill, outline and opacity of the floor bar. Match them to
  [`plot_floor_group()`](https://m-delem.github.io/aphantasiaWMStrats/reference/plot_floor_group.md)'s
  violin so stacked panels read as one figure.

- gradient:

  Continuous fill scale for the above-floor bars, coloured by bin
  midpoint, or `NULL` for a plain fill.

- left_expansion:

  Fraction of the x range added on the left. Share it with
  [`plot_floor_group()`](https://m-delem.github.io/aphantasiaWMStrats/reference/plot_floor_group.md)
  so stacked panels align.

- y_lab:

  Label for the y axis.

- ...:

  Additional arguments passed to the
  [`theme_pdf()`](https://m-delem.github.io/aphantasiaWMStrats/reference/theme_pdf.md)
  function for further customization of the plot theme.

## Value

A ggplot object with the x axis stripped, for stacking.
