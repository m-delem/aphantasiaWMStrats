# Ternary diagram of the three-part WM-FTT composition

Visualises the raw composition, which is a different representation from
the ILR coordinates the models are fitted on, not a competing one. The
ternary plot is the intuitive three-way picture; the inference happens
on log-ratios, because a three-part composition has only two degrees of
freedom and correlating raw proportions is invalid.

Built from `coda.plot`'s primitives (`ternary_frame()`,
`ternary_plot()`, `ternary_coords()`) rather than from
[`coda.plot::ternary_diagram()`](https://rdrr.io/pkg/coda.plot/man/ternary_diagram.html).
The legacy `plot_wm_composition()` in the waiting-room used the
all-in-one function and then reached into
`p$layers[[i]]$geom$default_aes` to restyle it, which breaks silently
whenever ggplot2 changes its internals. Drawing the points here means
the aesthetics are ours and go through the public API.

## Usage

``` r
plot_composition_ternary(
  parts,
  group = NULL,
  center = TRUE,
  scale = TRUE,
  labels = c("Words", "Orientations", "Colours"),
  point_size = 1.2,
  point_alpha = 0.8,
  base_size = 7,
  ...
)
```

## Arguments

- parts:

  A data frame with `part_word`, `part_angle`, `part_color`.

- group:

  Optional vector of group labels, the same length as `nrow(parts)`,
  used for colour and shape.

- center, scale:

  Passed to
  [`coda.plot::ternary_frame()`](https://rdrr.io/pkg/coda.plot/man/ternary_frame.html).
  Both default to `TRUE`: the composition varies over a very narrow
  range (parts have SDs near 0.025), so an uncentred ternary is a single
  dot in the middle of a large empty triangle. Centring and scaling zoom
  on the actual spread, and the caption says so.

- labels:

  Corner labels, in the column order word, orientation, colour.

- point_size, point_alpha:

  Point aesthetics.

- base_size:

  Base font size passed to
  [`theme_pdf()`](https://m-delem.github.io/aphantasiaWMStrats/reference/theme_pdf.md).

- ...:

  Additional arguments passed to
  [`theme_pdf()`](https://m-delem.github.io/aphantasiaWMStrats/reference/theme_pdf.md).

## Value

A ggplot object.
