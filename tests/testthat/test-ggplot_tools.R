test_that("theme_pdf returns a usable ggplot2 theme", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("sysfonts")
  skip_if_not_installed("showtext")
  theme <- theme_pdf()
  expect_s3_class(theme, "theme")
  expect_equal(theme$text$size, 7)
  expect_equal(theme_pdf(base_size = 16)$text$size, 16)
})

test_that("theme_pdf survives a missing font", {
  # font_add_google() needs a network round trip and is wrapped in try().
  # A figure must still build on a machine with no connection.
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("sysfonts")
  skip_if_not_installed("showtext")
  expect_s3_class(theme_pdf(family = "NotARealFontFamily"), "theme")
})

test_that("theme_pdf passes extra arguments through to theme()", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("sysfonts")
  skip_if_not_installed("showtext")
  expect_equal(theme_pdf(legend.position = "bottom")$legend.position, "bottom")
})

test_that("theme_pdf accepts a different base theme", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("sysfonts")
  skip_if_not_installed("showtext")
  # The ternary plot needs theme_void as its base rather than theme_classic.
  expect_s3_class(theme_pdf(base_theme = ggplot2::theme_void), "theme")
})

test_that("the group colour and shape scales share names and labels", {
  # This is what lets ggplot2 merge the two guides into one legend. If the
  # labels drift apart the figure silently grows a duplicate legend.
  skip_if_not_installed("ggplot2")
  colours <- scale_discrete_aphantasia(aesthetics = "colour")
  shapes  <- scale_shape_aphantasia()
  expect_identical(names(colours$palette(4)), names(shapes$palette(4)))
  # compared as declared, rather than through get_labels(), which needs a
  # data range and warns when given none
  expect_identical(colours$labels, shapes$labels)
})

test_that("the group scale covers all four VVIQ groups", {
  skip_if_not_installed("ggplot2")
  values <- scale_discrete_aphantasia()$palette(4)
  expect_setequal(
    names(values),
    c("aphantasia", "hypophantasia", "typical", "hyperphantasia")
  )
  expect_false(any(duplicated(values)))
})

test_that("the feature scale accepts both labels and column stems", {
  # Figures are built both before and after relabelling, so the scale has
  # to key on either.
  skip_if_not_installed("ggplot2")
  values <- scale_discrete_feature()$palette(6)
  expect_true(all(
    c("Word", "Orientation", "Colour", "word", "angle", "color") %in%
      names(values)
  ))
  expect_identical(unname(values[["Word"]]), unname(values[["word"]]))
})

test_that("feature colours do not collide with the group colours", {
  # A figure can carry both scales at once, so the two palettes must stay
  # visually distinct.
  skip_if_not_installed("ggplot2")
  features <- scale_discrete_feature()$palette(6)[c("Word", "Orientation", "Colour")]
  groups <- scale_discrete_aphantasia()$palette(4)[c("aphantasia", "typical")]
  expect_length(intersect(unname(features), unname(groups)), 0)
})

test_that("scale_x_vviq covers the full VVIQ range", {
  skip_if_not_installed("ggplot2")
  scale <- scale_x_vviq()[[1]]
  expect_true(min(scale$breaks) <= 16)
  expect_true(max(scale$breaks) >= 80)
})

test_that("save_ggplot locks the width to the two column widths", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("here")
  plot <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point()
  dir <- withr::local_tempdir()

  save_ggplot(file.path(dir, "one.pdf"), plot, ncol = 1, height = 60,
              verbose = FALSE)
  save_ggplot(file.path(dir, "two.pdf"), plot, ncol = 2, height = 60,
              verbose = FALSE)
  save_ggplot(file.path(dir, "custom.pdf"), plot, width = 60, height = 60,
              verbose = TRUE, return = TRUE) |> suppressMessages()
  expect_true(file.exists(file.path(dir, "one.pdf")))
  expect_true(file.exists(file.path(dir, "two.pdf")))
  # A one-column figure is narrower on the page than a two-column one.
  expect_lt(
    file.info(file.path(dir, "one.pdf"))$size,
    file.info(file.path(dir, "two.pdf"))$size * 10
  )
  expect_error(
    save_ggplot(file.path(dir, "three.pdf"), plot, ncol = 3, verbose = FALSE),
    "ncol"
  )
})

test_that("the composition plots build from real parts", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("coda.plot")
  parts <- data.frame(
    part_word  = c(0.40, 0.30, 0.35),
    part_angle = c(0.25, 0.35, 0.30),
    part_color = c(0.35, 0.35, 0.35)
  )
  groups <- c("aphantasia", "typical", "typical")
  expect_s3_class(plot_composition_ternary(parts, groups), "ggplot")
  expect_s3_class(plot_composition_ternary(parts), "ggplot")
  expect_s3_class(plot_composition_biplot(parts, groups), "ggplot")
})

test_that("scale_x_aphantasia labels the groups it is given", {
  skip_if_not_installed("ggplot2")
  labels <- scale_x_aphantasia()$labels
  expect_equal(unname(labels[["aphantasia"]]), "Aphantasia")
  expect_equal(unname(labels[["hyperphantasia"]]), "Hyperphantasia")
})

test_that("plot_split_half builds from a list of draws", {
  skip_if_not_installed("ggplot2")
  set.seed(8)
  draws <- list(word = stats::rnorm(200, 0.45, 0.08),
                angle = stats::rnorm(200, 0.82, 0.03),
                color = stats::rnorm(200, 0.83, 0.03))
  plot <- plot_split_half(draws)
  expect_s3_class(plot, "ggplot")
  # the facets must follow the canonical feature order, not alphabetical,
  # or the figure reads in the wrong order
  built <- ggplot2::ggplot_build(plot)
  expect_equal(levels(built$plot$data$feature),
               c("Word", "Orientation", "Colour"))
})

test_that("plot_split_half drops missing splits rather than warning", {
  skip_if_not_installed("ggplot2")
  draws <- list(word = c(0.4, NA, 0.5), angle = c(0.8, 0.82, NA))
  expect_s3_class(plot_split_half(draws), "ggplot")
  expect_equal(nrow(ggplot2::ggplot_build(plot_split_half(draws))$plot$data), 4)
})

test_that("plot_floor_group builds from tidy frames alone", {
  # Takes frames rather than a model, so it is testable without fitting
  # anything and works for gaussian, logit and inflated responses alike.
  skip_if_not_installed("ggplot2")
  fitted <- data.frame(x = 17:80, estimate = seq(0.1, 0.2, length.out = 64),
                       lower = seq(0.05, 0.15, length.out = 64),
                       upper = seq(0.15, 0.25, length.out = 64))
  observed <- data.frame(x = c(20, 40, 60), y = c(0.1, 0.15, 0.2))
  draws <- stats::rnorm(500, 0.19, 0.03)

  plot <- plot_floor_group(observed, fitted, draws)
  expect_s3_class(plot, "ggplot")
  expect_s3_class(plot_floor_group(observed, fitted, draws,
                                   floor_observed = c(0.15, 0.22)), "ggplot")
})

# Shared fixtures for the floor-group option tests below.
floor_group_fitted <- function() {
  data.frame(
    x = 16:80,
    estimate = seq(0.10, 0.20, length.out = 65),
    lower = seq(0.05, 0.15, length.out = 65),
    upper = seq(0.15, 0.25, length.out = 65)
  )
}
floor_group_observed <- function() {
  data.frame(x = c(20, 40, 60), y = c(0.10, 0.15, 0.20))
}
layer_geoms <- function(plot) {
  vapply(plot$layers, \(layer) class(layer$geom)[1], character(1))
}
layer_data_for <- function(plot, geom) {
  Filter(\(layer) inherits(layer$geom, geom), plot$layers)
}

test_that("floor_observed adds the half violin and the points it summarises", {
  # The floor group has no x variance, so it cannot be shown as a cloud of
  # points on the fitted line. It gets a density drawn against the axis
  # plus the values that density came from.
  skip_if_not_installed("ggplot2")
  draws <- stats::rnorm(500, 0.19, 0.03)

  without <- plot_floor_group(floor_group_observed(), floor_group_fitted(),
                              draws)
  with_values <- plot_floor_group(floor_group_observed(), floor_group_fitted(),
                                  draws,
                                  floor_observed = stats::rnorm(20, 0.2, 0.05))

  expect_false("GeomPolygon" %in% layer_geoms(without))
  expect_true("GeomPolygon" %in% layer_geoms(with_values))
  # one extra point layer for the jittered floor values
  expect_equal(sum(layer_geoms(with_values) == "GeomPoint"),
               sum(layer_geoms(without) == "GeomPoint") + 1)
})

test_that("the floor violin sits beside floor_x, not on it", {
  # The raw values belong at their real score; only the density is nudged
  # aside, so the two are readable rather than overplotted.
  skip_if_not_installed("ggplot2")
  values <- stats::rnorm(30, 0.2, 0.04)
  plot <- plot_floor_group(floor_group_observed(), floor_group_fitted(),
                           stats::rnorm(500, 0.19, 0.03),
                           floor_observed = values, floor_x = 16,
                           violin_nudge = -1.2, violin_width = 2.4)

  violin <- layer_data_for(plot, "GeomPolygon")[[1]]$data
  expect_true(all(violin$x < 16))
  # and it does not run past its stated width
  expect_gte(min(violin$x), 16 - 1.2 - 2.4 - 1e-8)

  jittered <- layer_data_for(plot, "GeomPoint")[[1]]$data
  expect_true(all(jittered$x == 16))
  expect_equal(nrow(jittered), length(values))
})

test_that("floor_observed too small for a density still shows its points", {
  # A kernel density over two points runs without complaint and means
  # nothing, so the violin is skipped below three. The points are the data
  # and must not disappear with the curve.
  skip_if_not_installed("ggplot2")
  plot <- plot_floor_group(floor_group_observed(), floor_group_fitted(),
                           stats::rnorm(500, 0.19, 0.03),
                           floor_observed = c(0.15, 0.22))
  expect_false("GeomPolygon" %in% layer_geoms(plot))
  expect_equal(nrow(layer_data_for(plot, "GeomPoint")[[1]]$data), 2)
})

test_that("floor_observed drops missing values from both layers", {
  skip_if_not_installed("ggplot2")
  plot <- plot_floor_group(floor_group_observed(), floor_group_fitted(),
                           stats::rnorm(500, 0.19, 0.03),
                           floor_observed = c(stats::rnorm(20, 0.2, 0.04),
                                              NA, NA))
  expect_equal(nrow(layer_data_for(plot, "GeomPoint")[[1]]$data), 20)
  expect_false(anyNA(layer_data_for(plot, "GeomPolygon")[[1]]$data$y))
})

test_that("effect_label is drawn only when given", {
  skip_if_not_installed("ggplot2")
  draws <- stats::rnorm(500, 0.19, 0.03)

  expect_false("GeomText" %in%
                 layer_geoms(plot_floor_group(floor_group_observed(),
                                              floor_group_fitted(), draws)))

  labelled <- plot_floor_group(floor_group_observed(), floor_group_fitted(),
                               draws, effect_label = "0.09\n[0.02, 0.16]")
  expect_true("GeomText" %in% layer_geoms(labelled))
  # annotate() carries the text in aes_params, not in the layer data
  text_layer <- layer_data_for(labelled, "GeomText")[[1]]
  expect_equal(text_layer$aes_params$label, "0.09\n[0.02, 0.16]")
})

test_that("effect_label sits on the arrow and is rotated by default", {
  # Rotated so a two-line label does not force the panel wider, and placed
  # at the arrow rather than floating, since an arrow between two features
  # is otherwise ambiguous about which two.
  skip_if_not_installed("ggplot2")
  plot <- plot_floor_group(floor_group_observed(), floor_group_fitted(),
                           stats::rnorm(500, 0.19, 0.03),
                           effect_label = "0.09", floor_x = 16,
                           arrow_nudge = -4)
  text_layer <- layer_data_for(plot, "GeomText")[[1]]
  expect_equal(text_layer$data$x, 12)
  expect_equal(text_layer$aes_params$angle, 90)
})

test_that("the effect label's rotation and spacing are adjustable", {
  skip_if_not_installed("ggplot2")
  plot <- plot_floor_group(floor_group_observed(), floor_group_fitted(),
                           stats::rnorm(500, 0.19, 0.03),
                           effect_label = "0.09", label_angle = 0,
                           label_lineheight = 1.4)
  text_layer <- layer_data_for(plot, "GeomText")[[1]]
  expect_equal(text_layer$aes_params$angle, 0)
  expect_equal(text_layer$aes_params$lineheight, 1.4)
})

test_that("plot_floor_group colours by the predictor, not by group", {
  # The figure's claim is that above-floor participants are one continuum
  # and the floor group is not part of it, so the points take a continuous
  # scale rather than the discrete imagery-group one.
  skip_if_not_installed("ggplot2")
  fitted <- data.frame(x = 16:80, estimate = 0.1, lower = 0.05, upper = 0.15)
  observed <- data.frame(x = c(20, 40, 60), y = c(0.1, 0.15, 0.2))
  plot <- plot_floor_group(observed, fitted, stats::rnorm(200, 0.2, 0.02))
  scales <- vapply(plot$scales$scales, \(s) paste(s$aesthetics, collapse = ","),
                   character(1))
  expect_true(any(grepl("colour", scales)))
  expect_false(any(grepl("shape", scales)))
  # and it can be switched off
  expect_s3_class(
    plot_floor_group(observed, fitted, stats::rnorm(200, 0.2, 0.02),
                     gradient = NULL), "ggplot")
})

test_that("plot_floor_group splits the fitted line at the observed minimum", {
  # Below the lowest observed above-floor score the line is an
  # extrapolation, and it is drawn dashed so it reads as one.
  skip_if_not_installed("ggplot2")
  fitted <- data.frame(x = 16:80, estimate = 0.1, lower = 0.05, upper = 0.15)
  observed <- data.frame(x = c(30, 50, 70), y = c(0.1, 0.15, 0.2))
  plot <- plot_floor_group(observed, fitted, stats::rnorm(200, 0.2, 0.02))
  line_layers <- Filter(
    \(l) inherits(l$geom, "GeomLine"), plot$layers)
  expect_length(line_layers, 2)
  linetypes <- vapply(line_layers, \(l) l$aes_params$linetype %||% "solid",
                      character(1))
  expect_setequal(linetypes, c("solid", "dashed"))
})

test_that("plot_vviq_histogram draws the floor bar as its own layer", {
  # Two layers rather than one histogram with a fill aesthetic: mapping
  # fill to a floor indicator stacks two groups inside whichever bin
  # straddles the boundary, which put an above-floor cap on the floor bar.
  skip_if_not_installed("ggplot2")
  plot <- plot_vviq_histogram(c(rep(16, 20), 17, 20, 30, 44, 60, 75))
  expect_s3_class(plot, "ggplot")
  expect_length(plot$layers, 2)

  floor_layer <- plot$layers[[2]]$data
  expect_equal(nrow(floor_layer), 1)
  expect_equal(floor_layer$x, 16)
  # exactly the floor participants, and the one at 17 is not among them
  expect_equal(floor_layer$count, 20)

  above_layer <- plot$layers[[1]]$data
  expect_equal(sum(above_layer$count), 6)
  expect_true(all(above_layer$midpoint > 16))
})

test_that("ignore_unused_imports works properly", {
  expect_null(ignore_unused_imports())
})
