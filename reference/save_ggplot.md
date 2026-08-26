# Custom ggsave wrapper set with Nature's formatting guidelines (width-locked)

Ported from `aphantasiaEmotions`. A one-column figure is 88 mm wide and
a two-column figure is 180 mm wide. Widths are locked to those two
values unless `width` is given explicitly, since the whole point is that
figures are designed at their final printed size rather than scaled
afterwards.

## Usage

``` r
save_ggplot(
  path,
  plot = ggplot2::get_last_plot(),
  ncol = 1,
  width = NULL,
  height = 90,
  return = FALSE,
  verbose = TRUE,
  units = "mm",
  dpi = 600,
  ...
)
```

## Arguments

- path:

  A character string with the path to save the plot.

- plot:

  The ggplot object to save, defaults to last plot displayed.

- ncol:

  The number of columns for the plot. Either 1 (default) or 2.

- width:

  Optional. The width of the plot in mm. If NULL (default), it will be
  set to 88 mm for one-column figures and 180 mm for two-column figures.

- height:

  The height of the plot in mm. Default is 90 mm.

- return:

  Logical. Whether to return the plot visibly or not.

- verbose:

  Logical. Whether to print a message when saving is done.

- units:

  The units for the width and height. Default is "mm".

- dpi:

  The resolution of the plot. Default is 600 (irrelevant for vector
  devices, kept so the same call works for PNG).

- ...:

  Additional arguments passed to `ggsave()`.

## Value

The plot, invisibly. Called for the side effect of saving.
