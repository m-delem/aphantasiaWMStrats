# Figure builders, exported so that a script and a documentation page draw
# the same figure rather than two versions of it.
#
# The two callers render it differently on purpose. Analysis scripts save
# vector PDFs at printed size for the thesis and the poster, where
# `theme_pdf()`'s 7pt default is correct. The pkgdown pages render raster
# at `base_size = 16`, which is what reads well on screen. That is the only
# thing that should differ between them, so `base_size` is an argument and
# everything else is not.

#' Split-half reliability, per feature
#'
#' @description
#' The distribution of Spearman-Brown corrected split-half correlations
#' across repeated random splits, with the conventional 0.70 floor marked.
#'
#' Repeated splits rather than one arbitrary odd-even partition, and splits
#' drawn over trials rather than items, because items within a trial share
#' an encoding episode. See [split_half_reliability()].
#'
#' @param reliability A named list or data frame of corrected correlations,
#'   one element or column per feature. Names should be the feature stems
#'   (`word`, `angle`, `color`) or their display labels.
#' @param threshold Where to draw the reference line. 0.70 is the
#'   conventional floor for group-level use, 0.80 for individual-level.
#' @param labels Named vector mapping feature stems to display labels.
#' @param base_size Passed to [theme_pdf()]. Scripts use the 7pt default;
#'   pkgdown pages use 16.
#'
#' @returns A ggplot object.
#' @export
plot_split_half <- function(
    reliability,
    threshold = 0.7,
    labels = c(word = "Word", angle = "Orientation", color = "Colour"),
    base_size = 7
) {
  rlang::check_installed("ggplot2", reason = "to draw figures.")

  long <-
    tibble::tibble(
      feature = rep(names(reliability), lengths(reliability)),
      r = unlist(reliability, use.names = FALSE)
    ) |>
    dplyr::filter(!is.na(.data$r)) |>
    dplyr::mutate(
      feature = factor(
        dplyr::coalesce(labels[.data$feature], .data$feature),
        levels = unname(labels)
      )
    )

  ggplot2::ggplot(long, ggplot2::aes(x = .data$r, fill = .data$feature)) +
    ggplot2::geom_histogram(bins = 40, show.legend = FALSE) +
    ggplot2::geom_vline(xintercept = threshold, linetype = "dashed",
                        linewidth = 0.2) +
    ggplot2::facet_wrap(~feature) +
    scale_discrete_feature(aesthetics = "fill") +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(0)) +
    ggplot2::labs(
      x = "Split-half reliability (Spearman-Brown corrected)",
      y = paste("Count of", max(lengths(reliability)), "splits"),
      caption = paste0("Dashed line marks ", threshold,
                       ", the conventional floor for group-level use.")
    ) +
    theme_pdf(base_size = base_size)
}
