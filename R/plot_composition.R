#' Ternary diagram of the three-part WM-FTT composition
#'
#' @description
#' Visualises the raw composition, which is a different representation from
#' the ILR coordinates the models are fitted on, not a competing one
#' (`06-compositional-analysis.md` §1). The ternary plot is the intuitive
#' three-way picture; the inference happens on log-ratios.
#'
#' Built from `coda.plot`'s primitives (`ternary_frame()`, `ternary_plot()`,
#' `ternary_coords()`) rather than from `coda.plot::ternary_diagram()`. The
#' legacy `plot_wm_composition()` in the waiting-room used the all-in-one
#' function and then reached into `p$layers[[i]]$geom$default_aes` to restyle
#' it, which breaks silently whenever ggplot2 changes its internals. Drawing
#' the points here means the aesthetics are ours and go through the public
#' API.
#'
#' @param parts A data frame with `part_word`, `part_angle`, `part_color`.
#' @param group Optional vector of group labels, the same length as
#'   `nrow(parts)`, used for colour and shape.
#' @param center,scale Passed to `coda.plot::ternary_frame()`. Both default
#'   to `TRUE`: the composition varies over a very narrow range (parts have
#'   SDs near 0.025), so an uncentred ternary is a single dot in the middle
#'   of a large empty triangle. Centring and scaling zoom on the actual
#'   spread, and the caption says so.
#' @param labels Corner labels, in the column order word, orientation, colour.
#' @param point_size,point_alpha Point aesthetics.
#' @param base_size Base font size passed to [theme_pdf()].
#' @param ... Additional arguments passed to [theme_pdf()].
#'
#' @returns A ggplot object.
#' @export
plot_composition_ternary <- function(
    parts,
    group = NULL,
    center = TRUE,
    scale  = TRUE,
    labels = c("Words", "Orientations", "Colours"),
    point_size  = 1.2,
    point_alpha = 0.8,
    base_size = 7,
    ...
) {
  rlang::check_installed("coda.plot", reason = "to draw ternary diagrams.")
  rlang::check_installed("ggplot2", reason = "to draw ternary diagrams.")

  x <- as.data.frame(parts)[, c("part_word", "part_angle", "part_color")]
  names(x) <- labels

  frame  <- coda.plot::ternary_frame(x, center = center, scale = scale)
  coords <- coda.plot::ternary_coords(frame, x)

  if (!is.null(group)) coords$group <- group

  p <- coda.plot::ternary_plot(frame)

  p <-
    if (is.null(group)) {
      p + ggplot2::geom_point(
        data = coords,
        ggplot2::aes(x = .data$.x, y = .data$.y),
        size = point_size,
        alpha = point_alpha
      )
    } else {
      p + ggplot2::geom_point(
        data = coords,
        ggplot2::aes(
          x = .data$.x, y = .data$.y,
          colour = .data$group, shape = .data$group
        ),
        size = point_size,
        alpha = point_alpha
      )
    }

  p +
    # the corner labels sit outside the triangle and are clipped by the
    # default panel range, so the range is widened rather than the margin
    ggplot2::expand_limits(x = c(-0.12, 1.12)) +
    scale_shape_aphantasia() +
    scale_discrete_aphantasia(aesthetics = "colour") +
    theme_pdf(
      base_theme = ggplot2::theme_void,
      base_size  = base_size,
      legend.position = "bottom",
      ...
    )
}

#' Centred log-ratio biplot of the WM-FTT composition
#'
#' @description
#' The complement to the ternary diagram: shows how the three parts covary
#' rather than where each participant sits. Thin wrapper over
#' `coda.plot::clr_biplot()`, restyled through [theme_pdf()].
#'
#' @param parts A data frame with `part_word`, `part_angle`, `part_color`.
#' @param group Optional vector of group labels.
#' @param biplot_type Passed to `coda.plot::clr_biplot()`. `"form"` preserves
#'   distances between observations, `"covariance"` preserves relationships
#'   between parts.
#' @param labels Part labels, in the column order word, orientation, colour.
#' @param base_size Base font size passed to [theme_pdf()].
#' @param ... Additional arguments passed to [theme_pdf()].
#'
#' @returns A ggplot object.
#' @export
plot_composition_biplot <- function(
    parts,
    group = NULL,
    biplot_type = "form",
    labels = c("Words", "Orientations", "Colours"),
    base_size = 7,
    ...
) {
  rlang::check_installed("coda.plot", reason = "to draw CLR biplots.")

  x <- as.data.frame(parts)[, c("part_word", "part_angle", "part_color")]
  names(x) <- labels

  coda.plot::clr_biplot(
    x,
    group = group,
    shape_group = group,
    biplot_type = biplot_type
  ) +
    scale_shape_aphantasia() +
    scale_discrete_aphantasia(aesthetics = "colour") +
    theme_pdf(base_size = base_size, legend.position = "bottom", ...)
}
