test_that("damerau_levenshtein matches known values", {
  # Textbook cases
  expect_equal(damerau_levenshtein("kitten", "sitting"), 3L)
  expect_equal(damerau_levenshtein("saturday", "sunday"), 3L)
  expect_equal(damerau_levenshtein("flaw", "lawn"), 2L)
  # Identity and empties
  expect_equal(damerau_levenshtein("mot", "mot"), 0L)
  expect_equal(damerau_levenshtein("", "abc"), 3L)
  expect_equal(damerau_levenshtein("abc", ""), 3L)
  expect_equal(damerau_levenshtein("", ""), 0L)
  # Symmetry
  expect_equal(damerau_levenshtein("navire", "angoisse"),
               damerau_levenshtein("angoisse", "navire"))
  expect_true(is.na(damerau_levenshtein(NA_character_, "a")))
})

test_that("damerau_levenshtein counts an adjacent transposition as one edit", {
  # This is the whole point of DL over plain Levenshtein.
  expect_equal(damerau_levenshtein("ca", "ac"), 1L)
  expect_equal(damerau_levenshtein("chien", "chein"), 1L)
  # Plain Levenshtein would give 2 for both; adist() is plain, so:
  expect_equal(as.integer(utils::adist("ca", "ac")), 2L)
})

test_that("damerau_levenshtein initialises both matrix boundaries", {
  # Regression guard for the front-end bug: a half-initialised DP matrix
  # makes prefix deletion free, so
  # unrelated words come out far too similar. Distance must equal the
  # target length when the two share no characters.
  expect_equal(damerau_levenshtein("cadeau", "tout"), 6L)
  expect_equal(damerau_levenshtein("piano", "xxxxx"), 5L)
  # Distance can never exceed the longer string.
  for (p in list(c("salle", "vide"), c("seconde", "trace"), c("drap", "navire"))) {
    expect_lte(damerau_levenshtein(p[1], p[2]), max(nchar(p)))
  }
})

test_that("normalise_word strips case, whitespace and diacritics", {
  expect_equal(normalise_word("Fen\u00eatre"), "fenetre")
  expect_equal(normalise_word("  MOT  "), "mot")
  expect_equal(normalise_word("\u00e9l\u00e8ve"), "eleve")
  expect_true(is.na(normalise_word(NA_character_)))
})

test_that("score_word is bounded, floored at 0, and 1 on an exact match", {
  expect_equal(score_word("table", "table"), 1)
  expect_equal(score_word("table", "TABLE "), 1)
  expect_equal(score_word("amour", ""), 0)
  # Response much longer than target: capped, so floored at 0 not negative.
  expect_equal(score_word("mot", "incomprehensible"), 0)
  s <- score_word(c("chien", "salle"), c("chein", "vide"))
  expect_true(all(s >= 0 & s <= 1))
  expect_equal(s[1], 4 / 5)  # one transposition over a 5-letter target
})

test_that("score_word is vectorised and length-preserving", {
  t <- c("un", "deux", "trois")
  r <- c("un", "", "trois")
  expect_length(score_word(t, r), 3)
  expect_equal(score_word(t, r), c(1, 0, 1))
})

test_that("score_angular respects the period it is given", {
  # Perfect match scores 1 under any period.
  expect_equal(score_angular(30, 30, period = 360), 1)
  expect_equal(score_angular(30, 30, period = 180), 1)
  # Half a period away is maximally wrong.
  expect_equal(score_angular(0, 180, period = 360), 0)
  expect_equal(score_angular(0, 90, period = 180), 0)
  # Quarter of a period sits at 0.5.
  expect_equal(score_angular(0, 90, period = 360), 0.5)
  expect_equal(score_angular(0, 45, period = 180), 0.5)
})

test_that("score_angular wraps rather than treating the seam as distant", {
  # Hue: 5 deg and 355 deg are 10 deg apart, not 350.
  expect_equal(score_angular(5, 355, period = 360),
               score_angular(5, 15, period = 360))
  # Orientation: +80 and -80 are 20 deg apart as rectangle tilts.
  expect_equal(score_angular(80, -80, period = 180),
               score_angular(0, 20, period = 180))
  expect_true(all(score_angular(c(0, 45, 90), c(200, -170, 12),
                                period = 360) %in% c(0, 1) == FALSE))
})

test_that("compute_scores adds the documented columns and errors informatively", {
  df <- data.frame(
    version = rep(c("v1", "v3"), each = 4),
    expe_phase = rep("expe_block_1", 8),
    target_word = c("table", "chien", "salle", "vide",
                    "amour", "jouet", "piano", "drap"),
    response_word = c("table", "chein", "", "vide",
                      "amour", "", "piano", "drap"),
    target_angle = c(10, -20, 30, 0, 45, -45, 12, -12),
    response_angle = c(10, -25, 90, 5, 45, -40, 90, -12),
    target_color_angle = c(100, 200, 300, 50, 10, 20, 30, 40),
    response_color_angle = c(105, 999, 300, 60, 10, 999, 35, 45),
    stringsAsFactors = FALSE
  )
  out <- compute_scores(df)

  added <- c("score_word", "score_angle", "score_color",
             "score_word_z", "score_angle_z", "score_color_z",
             "responded_word", "responded_angle", "responded_color")
  expect_true(all(added %in% names(out)))
  expect_equal(nrow(out), nrow(df))

  expect_equal(out$responded_word, df$response_word != "")
  expect_equal(out$responded_angle, df$response_angle != 90)
  expect_equal(out$responded_color, df$response_color_angle != 999)

  # Non-responses forced to 0, never to a spurious value from the sentinel.
  expect_true(all(out$score_angle[!out$responded_angle] == 0))
  expect_true(all(out$score_color[!out$responded_color] == 0))
  expect_true(all(out$score_word[!out$responded_word] == 0))

  raw <- c("score_word", "score_angle", "score_color")
  expect_true(all(vapply(out[raw], function(x) all(x >= 0 & x <= 1), logical(1))))

  expect_error(compute_scores(df[, c("version", "expe_phase")]),
               "missing column")
})

test_that("standardisation is within version and ignores non-block rows", {
  df <- data.frame(
    version = rep(c("v1", "v3"), each = 6),
    expe_phase = rep(c("expe_block_1", "expe_block_1", "expe_block_1",
                       "expe_block_1", "training", "tutorial"), 2),
    target_word = "table",
    response_word = c("table", "tale", "te", "t", "table", "table"),
    target_angle = c(0, 10, 20, 30, 0, 0),
    response_angle = c(0, 12, 25, 40, 0, 0),
    target_color_angle = c(0, 10, 20, 30, 0, 0),
    response_color_angle = c(0, 12, 25, 40, 0, 0),
    stringsAsFactors = FALSE
  )
  out <- compute_scores(df)

  # Block rows within a version should be centred on their own mean.
  for (v in c("v1", "v3")) {
    blk <- out$version == v & grepl("^expe_block", out$expe_phase)
    expect_equal(mean(out$score_word_z[blk]), 0, tolerance = 1e-8)
    expect_equal(stats::sd(out$score_word_z[blk]), 1, tolerance = 1e-8)
  }
  # Non-block rows are scored on that scale but excluded from the moments.
  expect_false(any(is.na(out$score_word_z)))
})

