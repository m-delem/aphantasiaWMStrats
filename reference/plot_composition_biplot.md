# Centred log-ratio biplot of the WM-FTT composition

The complement to the ternary diagram: shows how the three parts covary
rather than where each participant sits. Thin wrapper over
[`coda.plot::clr_biplot()`](https://rdrr.io/pkg/coda.plot/man/clr_biplot.html),
restyled through
[`theme_pdf()`](https://m-delem.github.io/aphantasiaWMStrats/reference/theme_pdf.md).

## Usage

``` r
plot_composition_biplot(
  parts,
  group = NULL,
  biplot_type = "form",
  labels = c("Words", "Orientations", "Colours"),
  base_size = 7,
  ...
)
```

## Arguments

- parts:

  A data frame with `part_word`, `part_angle`, `part_color`.

- group:

  Optional vector of group labels.

- biplot_type:

  Passed to
  [`coda.plot::clr_biplot()`](https://rdrr.io/pkg/coda.plot/man/clr_biplot.html).
  `"form"` preserves distances between observations, `"covariance"`
  preserves relationships between parts.

- labels:

  Part labels, in the column order word, orientation, colour.

- base_size:

  Base font size passed to
  [`theme_pdf()`](https://m-delem.github.io/aphantasiaWMStrats/reference/theme_pdf.md).

- ...:

  Additional arguments passed to
  [`theme_pdf()`](https://m-delem.github.io/aphantasiaWMStrats/reference/theme_pdf.md).

## Value

A ggplot object.
