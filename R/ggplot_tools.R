#' Theme for elegant scientific vector figures
#'
#' @description
#' Ported from the `aphantasiaEmotions` package so that figures across the
#' two packages share one visual identity. Based on the guidelines from the
#' [Nature Branded Research Journals](https://www.nature.com/documents/NRJs-guide-to-preparing-final-artwork.pdf):
#' 7pt base text, everything else smaller, sized to look right at 88mm (one
#' column) or 180mm (two columns) rather than on screen. Custom Google Fonts
#' are built in, the default being "Montserrat"; if the font cannot be
#' fetched the theme silently falls back to the default sans font.
#'
#' Note the base size. `inst/scripts` figures are vector PDFs sized in mm,
#' so `base_size = 7` is correct there. Figures built for the pkgdown site
#' are raster and much larger on screen, and use `base_size = 16`.
#'
#' @param base_theme A ggplot2 theme function, without parentheses or quotes.
#' The default is `ggplot2::theme_classic`.
#' @param family A string with the name of the font family to be used in the
#' theme. If not found by `sysfonts::font_add_google()`, the font will reset to
#' the default "sans" font (close to Arial).
#' @param base_size A numeric value for the base font size in points. The
#' default is 7pt, as recommended by the NRJ.
#' @param base_line A numeric value for the base line size in points. The
#' default is 0.2pt to look good in small vector figures.
#' @param title_hjust A numeric value for the horizontal justification of the
#' plot title and subtitle. The default is 0.5, which centers the title.
#' @param axis_relative_size A numeric value for the relative size of the axis
#' text compared to the base size. The default is 0.85.
#' @param axis_relative_x,axis_relative_y A numeric value for the relative size
#' of the x/y-axis text compared to the axis text size. The defaults are 1.
#' @param legend_relative A numeric value for the relative size of the legend
#' text compared to the base size. The default is 1.
#' @param ... Additional arguments passed to [ggplot2::theme()] (which can
#' override the defaults set here).
#'
#' @returns A ggplot2 theme object with the specified settings.
#' @export
#'
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   ggplot2::ggplot(iris, ggplot2::aes(Sepal.Length, Sepal.Width)) +
#'     ggplot2::geom_point() +
#'     theme_pdf()
#' }
theme_pdf <- function(
    base_theme = ggplot2::theme_classic,
    family     = "Montserrat",
    base_size  = 7,
    base_line  = 0.2,
    title_hjust = 0.5,
    axis_relative_size = 0.85,
    axis_relative_x = 1,
    axis_relative_y = 1,
    legend_relative = 1,
    ...
) {
  rlang::check_installed("ggplot2", reason = "to use `theme_pdf()`.")
  rlang::check_installed("sysfonts", reason = "to use `theme_pdf()`.")
  rlang::check_installed("showtext", reason = "to use `theme_pdf()`.")

  try(sysfonts::font_add_google(family), silent = TRUE)
  showtext::showtext_auto()

  pdf_theme <-
    base_theme(
      base_size   = base_size,
      base_family = family,
      base_line_size = base_line,
      base_rect_size = base_line
    ) +
    ggplot2::theme(
      plot.title    = ggplot2::element_text(
        size  = ggplot2::rel(1.2),
        hjust = title_hjust,
        face  = "plain"
      ),
      plot.subtitle = ggplot2::element_text(
        size  = ggplot2::rel(1),
        hjust = title_hjust,
        face  = "italic"
      ),
      plot.tag      = ggplot2::element_text(
        size  = ggplot2::rel(1.2),
        hjust = 0.5,
        face  = "plain"
      ),
      plot.caption  = ggplot2::element_text(
        size  = ggplot2::rel(0.9),
        hjust = 1,
        vjust = 0,
        face  = "italic"
      ),

      axis.text =
        ggplot2::element_text(size = ggplot2::rel(axis_relative_size)),
      axis.text.x =
        ggplot2::element_text(size = ggplot2::rel(axis_relative_x)),
      axis.text.y =
        ggplot2::element_text(size = ggplot2::rel(axis_relative_y)),

      strip.text = ggplot2::element_text(
        size = ggplot2::rel(1),
        face = "bold"
      ),

      legend.title =
        ggplot2::element_text(size = ggplot2::rel(legend_relative)),
      legend.text = ggplot2::element_text(size = ggplot2::rel(legend_relative)),
      legend.position = "top",
      legend.margin = ggplot2::margin(0, 0, 0, 0),
      legend.box.spacing = grid::unit(base_size * 0.25, "pt"),
      legend.box = "vertical",
      legend.spacing.x     = grid::unit(base_size * 2, "pt"),
      legend.spacing.y     = grid::unit(base_size, "pt"),
      legend.key.height    = grid::unit(base_size * 0.5, "pt"),
      legend.key.width     = grid::unit(base_size * 0.5, "pt"),
      legend.key.spacing.x = grid::unit(base_size * 1.25, "pt"),
      legend.key.spacing.y = grid::unit(base_size * 0.5, "pt")
    ) +
    ggplot2::theme(...)

  return(pdf_theme)
}

#' Custom ggsave wrapper set with Nature's formatting guidelines (width-locked)
#'
#' @description
#' Ported from `aphantasiaEmotions`. A one-column figure is 88 mm wide and a
#' two-column figure is 180 mm wide. Widths are locked to those two values
#' unless `width` is given explicitly, since the whole point is that figures
#' are designed at their final printed size rather than scaled afterwards.
#'
#' @param path     A character string with the path to save the plot.
#' @param plot     The ggplot object to save, defaults to last plot displayed.
#' @param ncol     The number of columns for the plot. Either 1 (default) or 2.
#' @param width    Optional. The width of the plot in mm. If NULL (default), it
#'                 will be set to 88 mm for one-column figures and 180 mm for
#'                 two-column figures.
#' @param height   The height of the plot in mm. Default is 90 mm.
#' @param return   Logical. Whether to return the plot visibly or not.
#' @param verbose  Logical. Whether to print a message when saving is done.
#' @param units    The units for the width and height. Default is "mm".
#' @param dpi      The resolution of the plot. Default is 600 (irrelevant for
#'                 vector devices, kept so the same call works for PNG).
#' @param ...      Additional arguments passed to `ggsave()`.
#'
#' @returns The plot, invisibly. Called for the side effect of saving.
#' @export
save_ggplot <- function(
    path,
    plot     = ggplot2::get_last_plot(),
    ncol     = 1,
    width    = NULL,
    height   = 90,
    return   = FALSE,
    verbose  = TRUE,
    units    = "mm",
    dpi      = 600,
    ...
) {
  rlang::check_installed("here", reason = "to use `save_ggplot()`.")

  if (!is.null(width)) {
    colour <- "blue"
    shape  <- "Custom width"
  } else if (ncol == 1) {
    width  <- 88
    colour <- "green"
    shape  <- "One-column"
  } else if (ncol == 2) {
    width  <- 180
    colour <- "cyan"
    shape  <- "Two-column"
  } else stop(glue::glue_col("ncol must be {cyan 1} or {green 2}."))

  ggplot2::ggsave(
    filename = here::here(path),
    plot     = plot,
    width    = width,
    height   = height,
    units    = units,
    dpi      = dpi,
    ...
  )
  if (verbose) {
    message(glue::glue_col(
      "{magenta |-> {", colour, " {shape}} figure saved in {yellow {path}}.}"
    ))
  }
  if (return) return(plot)
  invisible(plot)
}

#' Custom x-axis scale for imagery groups
#'
#' @description
#' Ported from `aphantasiaEmotions`. The four-level mapping is kept even
#' though v1 of this study only supports the two-group split (it has three
#' hyperphantasic participants), so that the same scale serves
#' `vviq_group_2` and `vviq_group_4` and colours stay identical across both
#' packages.
#'
#' @param name Name of the x-axis.
#' @param mult Multiplier for [ggplot2::expansion()].
#' @param add Additive for [ggplot2::expansion()].
#' @param ... Additional arguments passed to `ggplot2::scale_x_discrete()`.
#'
#' @returns A ggplot2 scale object for the x-axis.
#' @export
scale_x_aphantasia <- function(
    name = NULL,
    mult = 0,
    add = c(0, 0.7),
    ...
) {
  ggplot2::scale_x_discrete(
    name = name,
    labels = c(
      "aphantasia"     = "Aphantasia",
      "hypophantasia"  = "Hypophantasia",
      "typical"        = "Typical",
      "hyperphantasia" = "Hyperphantasia"
    ),
    expand = ggplot2::expansion(mult = mult, add = add),
    ...
  )
}

#' Custom discrete scale for imagery groups
#'
#' @description
#' Ported from `aphantasiaEmotions`, unchanged, so that "aphantasia" and
#' "typical" are the same two Okabe-Ito colours in both packages.
#'
#' @param aesthetics Aesthetics to apply the scale to.
#' @param name Name of the scale.
#' @param ... Additional arguments passed to
#' `ggplot2::scale_discrete_manual()`.
#'
#' @returns A ggplot2 scale object for discrete aesthetics.
#' @export
scale_discrete_aphantasia <- function(
    aesthetics = c("color", "fill"),
    name = NULL,
    ...
) {
  ggplot2::scale_discrete_manual(
    aesthetics = aesthetics,
    name = name,
    values = c(
      "aphantasia"     = unname(palette.colors()[1]),
      "hypophantasia"  = unname(palette.colors()[2]),
      "typical"        = unname(palette.colors()[3]),
      "hyperphantasia" = unname(palette.colors()[4])
    ),
    labels = c(
      "aphantasia"     = "Aphantasia",
      "hypophantasia"  = "Hypophantasia",
      "typical"        = "Typical",
      "hyperphantasia" = "Hyperphantasia"
    ),
    ...
  )
}

#' Custom discrete scale for the three WM-FTT features
#'
#' @description
#' Word, orientation and colour recur in nearly every figure in this package,
#' so they get fixed Okabe-Ito colours the same way the imagery groups do.
#' Deliberately avoids the two colours [scale_discrete_aphantasia()] uses for
#' aphantasia and typical imagers, so a figure can carry both without
#' collision.
#'
#' Accepts either the display labels or the column stems used in the data, so
#' the same scale works before and after relabelling.
#'
#' @param aesthetics Aesthetics to apply the scale to.
#' @param name Name of the scale.
#' @param ... Additional arguments passed to
#'   `ggplot2::scale_discrete_manual()`.
#'
#' @returns A ggplot2 scale object for discrete aesthetics.
#' @export
scale_discrete_feature <- function(
    aesthetics = c("color", "fill"),
    name = NULL,
    ...
) {
  okabe <- palette.colors()
  values <- c(
    "Word" = unname(okabe[2]),
    "Orientation" = unname(okabe[4]),
    "Colour" = unname(okabe[8])
  )

  ggplot2::scale_discrete_manual(
    aesthetics = aesthetics,
    name = name,
    values = c(
      values,
      stats::setNames(unname(values), c("word", "angle", "color"))
    ),
    ...
  )
}

#' Custom shape scale for imagery groups
#'
#' @description
#' The shape counterpart to [scale_discrete_aphantasia()]. Uses the same
#' names and the same labels, which is what lets ggplot2 merge the colour and
#' shape guides into a single legend instead of drawing two.
#'
#' @param name Name of the scale.
#' @param ... Additional arguments passed to `ggplot2::scale_shape_manual()`.
#'
#' @returns A ggplot2 scale object for the shape aesthetic.
#' @export
scale_shape_aphantasia <- function(name = NULL, ...) {
  ggplot2::scale_shape_manual(
    name = name,
    values = c(
      "aphantasia"     = 16,
      "hypophantasia"  = 17,
      "typical"        = 15,
      "hyperphantasia" = 18
    ),
    labels = c(
      "aphantasia"     = "Aphantasia",
      "hypophantasia"  = "Hypophantasia",
      "typical"        = "Typical",
      "hyperphantasia" = "Hyperphantasia"
    ),
    ...
  )
}

#' Custom x-axis scale for VVIQ scores
#'
#' @description
#' Ported from `aphantasiaEmotions`.
#'
#' @param breaks Breaks for the x-axis. Default is `seq(16, 80, by = 8)`.
#' @param expand Expansion for the x-axis.
#' @param ... Additional arguments passed to `ggplot2::scale_x_continuous()`.
#'
#' @returns A list containing a ggplot2 scale object for the x-axis.
#' @export
scale_x_vviq <- function(
    breaks = seq(16, 80, by = 8),
    expand = ggplot2::expansion(mult = c(0.02, 0.02)),
    ...
) {
  list(
    ggplot2::scale_x_continuous(breaks = breaks, expand = expand, ...)
  )
}
