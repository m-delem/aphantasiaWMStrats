# Synthetic item-level data, shaped like the real thing but small enough to
# reason about by hand. Two participants, two trials each, two items per
# trial. Participant "b" never responds on orientation, which is the case
# that separates "scored 0" from "did not answer".
fake_items <- tibble::tibble(
  id = rep(c("a", "b"), each = 4),
  trial_uid = rep(c("t1", "t1", "t2", "t2"), times = 2),
  score_word   = c(1.0, 0.5, 0.5, 0.0,   0.8, 0.8, 0.4, 0.4),
  score_angle  = c(0.5, 0.5, 0.5, 0.5,   0.0, 0.0, 0.0, 0.0),
  score_color  = c(0.4, 0.6, 0.6, 0.4,   0.5, 0.5, 0.5, 0.5),
  responded_word  = c(TRUE, TRUE, TRUE, FALSE,  TRUE, TRUE, TRUE, TRUE),
  responded_angle = rep(TRUE, 8),
  responded_color = rep(TRUE, 8)
)
fake_items$responded_angle[5:8] <- FALSE

test_that("wm_thresholds returns the documented values", {
  # Regression guard. These are a fixed a priori rule, not something to be
  # recomputed on whatever sample is at hand, so a silent change here would
  # be a serious problem.
  expect_identical(wm_thresholds(), c(word = 32L, angle = 22L, color = 29L))
})

test_that("engaged_ids keeps only participants clearing every threshold", {
  # "a" responds 3/4 word, 4/4 orientation, 4/4 colour; "b" responds 4/4
  # word, 0/4 orientation, 4/4 colour.
  low <- c(word = 3L, angle = 1L, color = 1L)
  expect_setequal(engaged_ids(fake_items, low), c("a", "b")[1])
  expect_setequal(engaged_ids(fake_items, c(word = 3L, angle = 0L, color = 1L)),
                  c("a", "b"))
  expect_length(engaged_ids(fake_items, c(word = 99L, angle = 1L, color = 1L)), 0)
})

test_that("compose_features closes the parts to 1", {
  parts <- compose_features(fake_items, id)
  totals <- rowSums(parts[c("part_word", "part_angle", "part_color")])
  expect_equal(totals[!is.na(totals)], 1, ignore_attr = TRUE)
})

test_that("compose_features uses responded trials only", {
  parts <- compose_features(fake_items, id)
  a <- parts[parts$id == "a", ]
  # "a" has word scores 1.0, 0.5, 0.5 responded and one non-responded 0.0.
  # The mean over responded items is 2/3, not the 0.5 a naive mean gives.
  expect_equal(a$mean_word, 2 / 3)
  expect_false(isTRUE(all.equal(a$mean_word, 0.5)))
  expect_equal(a$n_word, 3L)
})

test_that("compose_features returns NA parts when a feature has no responses", {
  # "b" never touched the orientation widget. That is a structurally missing
  # part, not a part of size zero, and a log-ratio transform cannot take it.
  # The caller decides what to do, so it must survive as NA rather than be
  # dropped here or silently become 0.
  parts <- compose_features(fake_items, id)
  b <- parts[parts$id == "b", ]
  expect_true(is.na(b$mean_angle))
  expect_true(is.na(b$part_angle))
  expect_equal(b$n_angle, 0L)
})

test_that("compose_features groups by whatever it is given", {
  by_person <- compose_features(fake_items, id)
  by_trial  <- compose_features(fake_items, id, trial_uid)
  expect_equal(nrow(by_person), 2)
  expect_equal(nrow(by_trial), 4)
  expect_true(all(c("id", "trial_uid") %in% names(by_trial)))
})

test_that("compose_features ignores lookalike score columns", {
  # `score_color_raw` is a real column in the performance script, which
  # keeps the untransformed colour scores next to the squeezed ones. An
  # unanchored selector matched it as a second source for colour and
  # collapsed every colour mean to NA, silently.
  with_raw <- fake_items
  with_raw$score_color_raw <- 0.1
  with_raw$score_word_extra <- 0.1
  expect_equal(
    compose_features(with_raw, id)$mean_color,
    compose_features(fake_items, id)$mean_color
  )
  expect_equal(
    compose_features(with_raw, id)$part_word,
    compose_features(fake_items, id)$part_word
  )
})

test_that("compose_features ignores the standardised score columns", {
  # The z-scored columns are roughly half negative and must never reach a
  # log-ratio transform. Selecting them here would be silent and fatal.
  with_z <- fake_items
  with_z$score_word_z  <- -1
  with_z$score_angle_z <- -1
  with_z$score_color_z <- -1
  expect_equal(
    compose_features(with_z, id)$part_word,
    compose_features(fake_items, id)$part_word
  )
})

# ---- ilr_coords -------------------------------------------------------

even <- data.frame(part_word = 1 / 3, part_angle = 1 / 3, part_color = 1 / 3)

test_that("ilr_coords puts an even composition at the origin", {
  z <- ilr_coords(even)
  expect_equal(z$ilr1, 0)
  expect_equal(z$ilr2, 0)
})

test_that("ilr_coords matches the balanced ILR formula", {
  p <- data.frame(part_word = 0.5, part_angle = 0.2, part_color = 0.3)
  z <- ilr_coords(p)
  expect_equal(z$ilr1, sqrt(2 / 3) * log(0.5 / sqrt(0.3 * 0.2)))
  expect_equal(z$ilr2, sqrt(1 / 2) * log(0.3 / 0.2))
})

test_that("ilr_coords is scale invariant", {
  # A composition carries only relative information, so multiplying a row
  # by a constant must leave the coordinates untouched. This is what makes
  # it safe to pass unclosed means.
  p <- data.frame(part_word = 0.5, part_angle = 0.2, part_color = 0.3)
  expect_equal(ilr_coords(p * 7), ilr_coords(p), ignore_attr = TRUE)
})

test_that("total ILR variance does not depend on the partition", {
  # The claim the SBP decision rests on: any two-coordinate ILR basis is a
  # rotation of the same geometry, so the total variance, and with it the
  # omnibus test, is invariant. Only the split between coordinates moves.
  set.seed(1)
  p <- data.frame(
    part_word  = runif(50, 0.30, 0.45),
    part_angle = runif(50, 0.25, 0.35),
    part_color = runif(50, 0.28, 0.40)
  )
  p <- p / rowSums(p)
  totals <- vapply(
    c("word", "color", "angle"),
    function(first) sum(apply(ilr_coords(p, first = first), 2, stats::var)),
    numeric(1)
  )
  expect_equal(totals[["color"]], totals[["word"]])
  expect_equal(totals[["angle"]], totals[["word"]])
  # and the split between coordinates genuinely does move, so the test
  # above is not passing trivially
  shares <- vapply(
    c("word", "color", "angle"),
    function(first) {
      v <- apply(ilr_coords(p, first = first), 2, stats::var)
      v[[1]] / sum(v)
    },
    numeric(1)
  )
  expect_false(isTRUE(all.equal(shares[["word"]], shares[["angle"]])))
})

test_that("distances between compositions do not depend on the partition", {
  p <- data.frame(
    part_word  = c(0.40, 0.30),
    part_angle = c(0.25, 0.35),
    part_color = c(0.35, 0.35)
  )
  distances <- vapply(
    c("word", "color", "angle"),
    function(first) stats::dist(as.matrix(ilr_coords(p, first = first)))[[1]],
    numeric(1)
  )
  expect_equal(distances[["color"]], distances[["word"]])
  expect_equal(distances[["angle"]], distances[["word"]])
})

test_that("ilr_coords accepts bare part names as well as the part_ prefix", {
  bare <- data.frame(word = 0.5, angle = 0.2, color = 0.3)
  expect_equal(ilr_coords(bare), ilr_coords(
    data.frame(part_word = 0.5, part_angle = 0.2, part_color = 0.3)
  ))
})

test_that("ilr_coords records which partition produced the coordinates", {
  z <- ilr_coords(even, first = "angle")
  expect_identical(attr(z, "first"), "angle")
  expect_identical(
    unname(attr(z, "balance")),
    c("angle vs (word + color)", "word vs color")
  )
})

test_that("ilr_coords refuses zero and negative parts", {
  # No log-ratio transform accepts these. Failing loudly is the point: a
  # zero part silently becoming -Inf would propagate into a model fit.
  zero <- data.frame(part_word = 0, part_angle = 0.5, part_color = 0.5)
  negative <- data.frame(part_word = -0.1, part_angle = 0.6, part_color = 0.5)
  expect_error(ilr_coords(zero), "strictly positive")
  expect_error(ilr_coords(negative), "strictly positive")
})

test_that("ilr_coords refuses an incomplete composition", {
  expect_error(
    ilr_coords(data.frame(part_word = 0.5, part_angle = 0.5)),
    "three parts"
  )
})

test_that("ilr_coords only accepts a known partition", {
  expect_error(ilr_coords(even, first = "parity"))
})
