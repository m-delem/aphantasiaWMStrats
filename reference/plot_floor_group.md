# Figure for a floor-group model

The visual form of the argument in `08-predictor-form.md`: imagery
vividness is not a smoothly continuous predictor, because a substantial
group sits at the scale floor with no variance among themselves. A model
fits a relationship among everyone above the floor and gives the floor
group a single offset. This figure shows the relationship, the floor
group, and the **gap between where the line predicts they would be and
where they are**, which is the quantity the model estimates.

Ported from the design in the sibling package `aphantasiaEmotions`, with
one structural change. That version takes the model and reads the
outcome from `model$data[[1]]`, which works because all of its models
are univariate gaussian. The models here are not: one is bivariate
gaussian, one has three responses with three families behind a logit
link, and one has six responses mixing Bernoulli, Beta and
zero-one-inflated Beta. So this version takes **tidy frames**, extracted
with `posterior_epred()` next to the model, which also makes it testable
without fitting anything.

Four elements carry the argument, and each is separately controllable:

- The above-floor points are coloured by vividness on a **continuous**
  scale rather than by imagery group, because the claim is that
  above-floor participants form one continuum and the floor group is not
  part of it.

- The fitted line is **solid within the observed range and dashed below
  it**, so the extrapolation to the scale floor is visible as one.

- The floor group appears as a **half violin** of its own observed
  values with those values jittered beside it, drawn against the
  `floor_x` axis in its own colour. A full violin centred on `floor_x`
  would imply vividness varies within the group, which is exactly what
  it does not do, and the density alone hides how few participants it
  summarises.

- A **two-headed arrow** spans the gap, with short ticks connecting each
  end to the point it refers to, since an arrow floating to the left of
  two features is ambiguous about which two.

## Usage

``` r
plot_floor_group(
  observed,
  fitted,
  floor_draws,
  floor_observed = NULL,
  floor_x = 16,
  effect_label = NULL,
  x_lab = "VVIQ score",
  y_lab = NULL,
  caption = NULL,
  point_size = 1.2,
  point_alpha = 0.6,
  gradient = ggplot2::scale_colour_viridis_c(option = "viridis", guide = "none"),
  floor_fill = "#C44E52",
  floor_colour = "#8B3A3E",
  violin_width = 2.4,
  violin_nudge = -1.2,
  floor_jitter_width = 0.4,
  floor_jitter_alpha = 0.55,
  arrow_nudge = -4,
  show_sample_mean = TRUE,
  label_size = base_size * 0.32,
  label_colour = "grey45",
  label_angle = 90,
  label_lineheight = 0.9,
  left_expansion = 0.09,
  base_size = 7,
  ...
)
```

## Arguments

- observed:

  Data frame of above-floor participant values, with columns `x` and
  `y`.

- fitted:

  Data frame for the fitted relationship, with columns `x`, `estimate`,
  `lower`, `upper`. Should extend down to `floor_x` so the extrapolated
  stretch can be drawn.

- floor_draws:

  Posterior draws of the floor group's fitted value.

- floor_observed:

  The floor group's own observed values, for the half violin. Omitting
  it drops the violin.

- floor_x:

  The scale minimum, where the floor group sits.

- effect_label:

  Optional string placed beside the arrow, typically the offset and its
  interval. The caller formats it, so this function stays independent of
  any model class.

- x_lab, y_lab, caption:

  Labels.

- point_size, point_alpha:

  Aesthetics for the observed points.

- gradient:

  Continuous colour scale for vividness, or `NULL` for plain points.

- floor_fill, floor_colour:

  Colours for the floor group, kept distinct from the gradient so the
  group reads as separate.

- violin_width:

  Width of the half violin, in x units.

- violin_nudge:

  How far left of `floor_x` to place the violin. The default clears
  `floor_jitter_width` so the density and the points it summarises do
  not overlap; if you widen the jitter, widen this too.

- floor_jitter_width, floor_jitter_alpha:

  Aesthetics for the floor group's own values, jittered at `floor_x`. A
  density built from twenty points can look smoother than the data
  warrants, so the points are shown next to it.

- arrow_nudge:

  How far left of `floor_x` to place the arrow.

- show_sample_mean:

  Whether to draw the sample mean as a reference.

- label_size, label_colour:

  Aesthetics for the in-panel annotations.

- label_angle:

  Rotation of the effect label. The default of 90 keeps it compact
  against the arrow rather than pushing the panel wider.

- label_lineheight:

  Line spacing within the effect label, for tuning the gap between the
  estimate and its interval.

- left_expansion:

  Fraction of the x range added on the left, for the violin and the
  arrow. Share it with
  [`plot_vviq_histogram()`](https://m-delem.github.io/aphantasiaWMStrats/reference/plot_vviq_histogram.md)
  so stacked panels align.

- base_size:

  Passed to
  [`theme_pdf()`](https://m-delem.github.io/aphantasiaWMStrats/reference/theme_pdf.md).
  Scripts use the 7pt default, pkgdown pages use 16.

- ...:

  Additional arguments passed to the
  [`theme_pdf()`](https://m-delem.github.io/aphantasiaWMStrats/reference/theme_pdf.md)
  function for further customization of the plot theme.

## Value

A ggplot object.
