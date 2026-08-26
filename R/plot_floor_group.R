#' Figure for a floor-group model
#'
#' @description
#' The visual form of the argument in `08-predictor-form.md`: imagery
#' vividness is not a smoothly continuous predictor, because a substantial
#' group sits at the scale floor with no variance among themselves. A model
#' fits a relationship among everyone above the floor and gives the floor
#' group a single offset. This figure shows the relationship, the floor
#' group, and the **gap between where the line predicts they would be and
#' where they are**, which is the quantity the model estimates.
#'
#' Ported from the design in the sibling package `aphantasiaEmotions`, with
#' one structural change. That version takes the model and reads the
#' outcome from `model$data[[1]]`, which works because all of its models are
#' univariate gaussian. The models here are not: one is bivariate gaussian,
#' one has three responses with three families behind a logit link, and one
#' has six responses mixing Bernoulli, Beta and zero-one-inflated Beta. So
#' this version takes **tidy frames**, extracted with `posterior_epred()`
#' next to the model, which also makes it testable without fitting anything.
#'
#' Four elements carry the argument, and each is separately controllable:
#'
#' * The above-floor points are coloured by vividness on a **continuous**
#'   scale rather than by imagery group, because the claim is that
#'   above-floor participants form one continuum and the floor group is not
#'   part of it.
#' * The fitted line is **solid within the observed range and dashed below
#'   it**, so the extrapolation to the scale floor is visible as one.
#' * The floor group appears as a **half violin** of its own observed
#'   values with those values jittered beside it, drawn against the
#'   `floor_x` axis in its own colour. A full violin centred on `floor_x`
#'   would imply vividness varies within the group, which is exactly what
#'   it does not do, and the density alone hides how few participants it
#'   summarises.
#' * A **two-headed arrow** spans the gap, with short ticks connecting each
#'   end to the point it refers to, since an arrow floating to the left of
#'   two features is ambiguous about which two.
#'
#' @param observed Data frame of above-floor participant values, with
#'   columns `x` and `y`.
#' @param fitted Data frame for the fitted relationship, with columns `x`,
#'   `estimate`, `lower`, `upper`. Should extend down to `floor_x` so the
#'   extrapolated stretch can be drawn.
#' @param floor_draws Posterior draws of the floor group's fitted value.
#' @param floor_observed The floor group's own observed values, for the half
#'   violin. Omitting it drops the violin.
#' @param floor_x The scale minimum, where the floor group sits.
#' @param effect_label Optional string placed beside the arrow, typically
#'   the offset and its interval. The caller formats it, so this function
#'   stays independent of any model class.
#' @param x_lab,y_lab,caption Labels.
#' @param base_size Passed to [theme_pdf()]. Scripts use the 7pt default,
#'   pkgdown pages use 16.
#' @param point_size,point_alpha Aesthetics for the observed points.
#' @param gradient Continuous colour scale for vividness, or `NULL` for
#'   plain points.
#' @param floor_fill,floor_colour Colours for the floor group, kept distinct
#'   from the gradient so the group reads as separate.
#' @param violin_width Width of the half violin, in x units.
#' @param violin_nudge How far left of `floor_x` to place the violin. The
#'   default clears `floor_jitter_width` so the density and the points it
#'   summarises do not overlap; if you widen the jitter, widen this too.
#' @param floor_jitter_width,floor_jitter_alpha Aesthetics for the floor
#'   group's own values, jittered at `floor_x`. A density built from twenty
#'   points can look smoother than the data warrants, so the points are
#'   shown next to it.
#' @param arrow_nudge How far left of `floor_x` to place the arrow.
#' @param show_sample_mean Whether to draw the sample mean as a reference.
#' @param label_size,label_colour Aesthetics for the in-panel annotations.
#' @param label_angle Rotation of the effect label. The default of 90 keeps
#'   it compact against the arrow rather than pushing the panel wider.
#' @param label_lineheight Line spacing within the effect label, for tuning
#'   the gap between the estimate and its interval.
#' @param left_expansion Fraction of the x range added on the left, for the
#'   violin and the arrow. Share it with [plot_vviq_histogram()] so stacked
#'   panels align.
#'
#' @returns A ggplot object.
#' @export
plot_floor_group <- function(
    observed,
    fitted,
    floor_draws,
    floor_observed = NULL,
    floor_x = 16,
    effect_label = NULL,
    x_lab = "VVIQ total score",
    y_lab = NULL,
    caption = NULL,
    base_size = 7,
    point_size = 1.2,
    point_alpha = 0.6,
    gradient = ggplot2::scale_colour_viridis_c(option = "viridis",
                                               guide = "none"),
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
    left_expansion = 0.09
) {
  rlang::check_installed("ggplot2", reason = "to draw figures.")

  observed_minimum <- min(observed$x, na.rm = TRUE)
  within_range <- fitted[fitted$x >= observed_minimum, , drop = FALSE]
  extrapolated <- fitted[fitted$x <= observed_minimum, , drop = FALSE]
  at_floor <- fitted[which.min(abs(fitted$x - floor_x)), ]

  floor_summary <- tibble::tibble(
    x = floor_x,
    estimate = stats::median(floor_draws),
    lower = unname(stats::quantile(floor_draws, 0.025)),
    upper = unname(stats::quantile(floor_draws, 0.975))
  )

  plot <- ggplot2::ggplot()

  if (show_sample_mean) {
    plot <- plot + ggplot2::geom_hline(
      yintercept = mean(c(observed$y, floor_observed), na.rm = TRUE),
      linetype = "dashed", linewidth = 0.2, colour = "grey65"
    )
  }

  plot <- plot +
    ggplot2::geom_ribbon(
      data = fitted,
      ggplot2::aes(x = .data$x, ymin = .data$lower, ymax = .data$upper),
      alpha = 0.12
    ) +
    ggplot2::geom_line(
      data = extrapolated,
      ggplot2::aes(x = .data$x, y = .data$estimate),
      linewidth = 0.4, linetype = "dashed"
    ) +
    ggplot2::geom_line(
      data = within_range,
      ggplot2::aes(x = .data$x, y = .data$estimate),
      linewidth = 0.4
    )

  if (!is.null(floor_observed) && length(stats::na.omit(floor_observed)) > 2) {
    # bounded by the observed range: an unbounded kernel puts density
    # where the group has no values, which reads as data
    values <- stats::na.omit(floor_observed)
    density <- stats::density(values, n = 200,
                              from = min(values), to = max(values))
    scaled <- density$y / max(density$y) * violin_width
    outline <- rbind(
      data.frame(x = floor_x - scaled + violin_nudge, y = density$x),
      data.frame(x = floor_x + violin_nudge, y = rev(range(density$x)))
    )
    plot <- plot + ggplot2::geom_polygon(
      data = outline, ggplot2::aes(x = .data$x, y = .data$y),
      fill = floor_fill, alpha = 0.5, colour = floor_colour, linewidth = 0.2
    )
  }

  if (!is.null(floor_observed)) {
    plot <- plot + ggplot2::geom_jitter(
      data = tibble::tibble(x = floor_x, y = stats::na.omit(floor_observed)),
      ggplot2::aes(x = .data$x, y = .data$y),
      width = floor_jitter_width, height = 0,
      size = point_size, alpha = floor_jitter_alpha, colour = floor_colour
    )
  }

  plot <- plot +
    ggplot2::geom_point(
      data = at_floor, ggplot2::aes(x = .data$x, y = .data$estimate),
      shape = 4, size = base_size * 0.28, stroke = 0.7
    ) +
    ggplot2::geom_pointrange(
      data = floor_summary,
      ggplot2::aes(x = .data$x, y = .data$estimate,
                   ymin = .data$lower, ymax = .data$upper),
      colour = floor_colour, size = base_size * 0.045, linewidth = 0.5
    )

  arrow_x <- floor_x + arrow_nudge
  plot <- plot +
    ggplot2::annotate(
      "segment", x = arrow_x, xend = floor_x,
      y = at_floor$estimate, yend = at_floor$estimate,
      linetype = "dotted", linewidth = 0.2, colour = label_colour
    ) +
    ggplot2::annotate(
      "segment", x = arrow_x, xend = floor_x,
      y = floor_summary$estimate, yend = floor_summary$estimate,
      linetype = "dotted", linewidth = 0.2, colour = label_colour
    ) +
    ggplot2::annotate(
      "segment", x = arrow_x, xend = arrow_x,
      y = at_floor$estimate, yend = floor_summary$estimate,
      linewidth = 0.35, colour = "grey25",
      arrow = ggplot2::arrow(ends = "both",
                             length = grid::unit(base_size * 0.35, "pt"))
    )

  if (!is.null(effect_label)) {
    plot <- plot + ggplot2::annotate(
      "text", x = arrow_x, hjust = 0.5, vjust = -0.4,
      y = mean(c(at_floor$estimate, floor_summary$estimate)),
      label = effect_label, size = label_size, colour = "grey25",
      angle = label_angle, lineheight = label_lineheight
    )
  }

  plot <- plot +
    ggplot2::geom_point(
      data = observed,
      ggplot2::aes(x = .data$x, y = .data$y, colour = .data$x),
      size = point_size, alpha = point_alpha
    )

  if (!is.null(gradient)) plot <- plot + gradient

  plot +
    scale_x_vviq(
      expand = ggplot2::expansion(mult = c(left_expansion, 0.02))) +
    ggplot2::labs(x = x_lab, y = y_lab, caption = caption) +
    theme_pdf(base_size = base_size)
}

#' Marginal histogram of imagery vividness
#'
#' @description
#' The piece of data that motivates the floor-group model on its own: the
#' vividness distribution is not smoothly continuous, but a sharp isolated
#' spike at the scale floor plus an irregular remainder above it. Ported
#' from `aphantasiaEmotions`, where it sits above the main panel.
#'
#' Stacked above [plot_floor_group()] with `patchwork`, sharing an x axis,
#' it makes the case for the model before the model is shown.
#'
#' @param vviq A numeric vector of vividness scores.
#' @param floor_x The scale minimum, coloured separately.
#' @param binwidth Histogram bin width. Defaults to 1 so the floor score
#'   occupies a bin of its own rather than sharing one with the score above
#'   it, which would colour part of the floor bar as above-floor.
#' @param fill,floor_fill Colours for the above-floor and floor bars.
#' @param base_size Passed to [theme_pdf()].
#'
#' @returns A ggplot object with the x axis stripped, for stacking.
#' @export
plot_vviq_histogram <- function(
    vviq,
    floor_x = 16,
    binwidth = 2,
    floor_fill = "#C44E52",
    floor_colour = "#8B3A3E",
    floor_alpha = 0.5,
    gradient = ggplot2::scale_fill_viridis_c(option = "viridis",
                                             guide = "none"),
    left_expansion = 0.09,
    base_size = 7
) {
  rlang::check_installed("ggplot2", reason = "to draw figures.")

  vviq <- vviq[!is.na(vviq)]
  above <- vviq[vviq > floor_x]

  # Binned by hand rather than through geom_histogram()'s fill aesthetic.
  # Mapping fill to a floor indicator stacks two groups inside whichever
  # bin straddles the boundary, which put a grey cap on the floor bar: with
  # a bin width of 2, the single participant at 17 shared a bin with the
  # 18 at 16.
  breaks <- seq(floor_x + 1, max(vviq) + binwidth, by = binwidth)
  counts <- graphics::hist(above, breaks = breaks, plot = FALSE)
  bins <- tibble::tibble(
    midpoint = counts$mids,
    count = counts$counts
  )

  ggplot2::ggplot() +
    ggplot2::geom_col(
      data = bins,
      ggplot2::aes(x = .data$midpoint, y = .data$count, fill = .data$midpoint),
      width = binwidth, show.legend = FALSE
    ) +
    gradient +
    ggplot2::geom_col(
      data = tibble::tibble(x = floor_x, count = sum(vviq <= floor_x)),
      ggplot2::aes(x = .data$x, y = .data$count),
      width = binwidth, fill = floor_fill, alpha = floor_alpha,
      colour = floor_colour, linewidth = 0.2
    ) +
    scale_x_vviq(
      expand = ggplot2::expansion(mult = c(left_expansion, 0.02))) +
    ggplot2::labs(x = NULL, y = "n") +
    theme_pdf(base_size = base_size) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_blank(),
      axis.ticks.x = ggplot2::element_blank(),
      axis.line.x = ggplot2::element_blank()
    )
}
