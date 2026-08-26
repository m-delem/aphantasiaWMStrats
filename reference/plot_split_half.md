# Split-half reliability, per feature

The distribution of Spearman-Brown corrected split-half correlations
across repeated random splits, with the conventional 0.70 floor marked.

Repeated splits rather than one arbitrary odd-even partition, and splits
drawn over trials rather than items, because items within a trial share
an encoding episode. See
[`split_half_reliability()`](https://m-delem.github.io/aphantasiaWMStrats/reference/split_half_reliability.md).

## Usage

``` r
plot_split_half(
  reliability,
  threshold = 0.7,
  labels = c(word = "Word", angle = "Orientation", color = "Colour"),
  base_size = 7
)
```

## Arguments

- reliability:

  A named list or data frame of corrected correlations, one element or
  column per feature. Names should be the feature stems (`word`,
  `angle`, `color`) or their display labels.

- threshold:

  Where to draw the reference line. 0.70 is the conventional floor for
  group-level use, 0.80 for individual-level.

- labels:

  Named vector mapping feature stems to display labels.

- base_size:

  Passed to
  [`theme_pdf()`](https://m-delem.github.io/aphantasiaWMStrats/reference/theme_pdf.md).
  Scripts use the 7pt default; pkgdown pages use 16.

## Value

A ggplot object.
