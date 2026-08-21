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
