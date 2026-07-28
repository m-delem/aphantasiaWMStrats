# get_data() takes an internal `data` argument (defaulting to `all_data`,
# the real package data) specifically so it can be tested against a small
# synthetic stand-in instead - these tests check get_data()'s
# filtering/validation logic, not the real data's contents, and don't
# depend on however many participants happen to be in `all_data`.

fake_all_data <- tibble::tibble(
  id = c("p1", "p2", "p3", "p4", "p5"),
  version = c("v1", "v1", "v2", "v3", "v3"),
  trial_number = c(1L, 2L, 1L, 1L, 2L)
)

test_that("default (no argument) returns all versions", {
  out <- get_data(data = fake_all_data)
  expect_equal(sort(unique(out$version)), c("v1", "v2", "v3"))
  expect_equal(nrow(out), nrow(fake_all_data))
})

test_that("version = \"all\" returns all versions", {
  out <- get_data(version = "all", data = fake_all_data)
  expect_equal(sort(unique(out$version)), c("v1", "v2", "v3"))
  expect_equal(nrow(out), nrow(fake_all_data))
})

test_that("a single version filters correctly", {
  out <- get_data(version = "v3", data = fake_all_data)
  expect_equal(unique(out$version), "v3")
  expect_equal(nrow(out), 2)
  expect_setequal(out$id, c("p4", "p5"))
})

test_that("multiple specific versions filter correctly", {
  out <- get_data(version = c("v1", "v2"), data = fake_all_data)
  expect_setequal(unique(out$version), c("v1", "v2"))
  expect_equal(nrow(out), 3)
  expect_setequal(out$id, c("p1", "p2", "p3"))
})

test_that("version order in the argument doesn't affect the result", {
  out_asc <- get_data(version = c("v1", "v3"), data = fake_all_data)
  out_desc <- get_data(version = c("v3", "v1"), data = fake_all_data)
  expect_setequal(out_asc$id, out_desc$id)
})

test_that("duplicate versions in the argument don't duplicate rows", {
  out <- get_data(version = c("v1", "v1"), data = fake_all_data)
  expect_equal(nrow(out), 2)
  expect_setequal(out$id, c("p1", "p2"))
})

test_that("returned columns match the source data", {
  out <- get_data(data = fake_all_data)
  expect_named(out, names(fake_all_data))
})

test_that("\"all\" combined with a specific version errors", {
  expect_error(
    get_data(version = c("all", "v1"), data = fake_all_data),
    "cannot be combined"
  )
})

test_that("a single unknown version errors, naming it", {
  expect_error(
    get_data(version = "v4", data = fake_all_data),
    "Unrecognised version"
  )
  expect_error(
    get_data(version = "v4", data = fake_all_data),
    "\"v4\""
  )
})

test_that("multiple unknown versions error with pluralised message", {
  expect_error(
    get_data(version = c("v4", "v5"), data = fake_all_data),
    "Unrecognised versions"
  )
})

test_that("a mix of valid and unknown versions errors", {
  expect_error(
    get_data(version = c("v1", "v9"), data = fake_all_data),
    "Unrecognised version"
  )
})

test_that("non-character input errors", {
  expect_error(
    get_data(version = 1, data = fake_all_data), "must be a character vector"
  )
  expect_error(
    get_data(version = TRUE, data = fake_all_data),
    "must be a character vector"
  )
  expect_error(
    get_data(version = NULL, data = fake_all_data),
    "must be a character vector"
  )
})

test_that("empty character vector errors", {
  expect_error(
    get_data(version = character(0), data = fake_all_data),
    "must be a character vector"
  )
})

test_that("NA in version is treated as unrecognised, not a crash", {
  expect_error(
    get_data(version = NA_character_, data = fake_all_data),
    "Unrecognised version"
  )
})

test_that("get_data() works against the real all_data with its own default", {
  # Sanity check that the `data` argument's default (all_data) is wired up
  # correctly - this uses the real package data, so it only checks shape,
  # not specific values or row counts.
  out <- get_data()
  expect_true(all(unique(out$version) %in% c("v1", "v2", "v3")))
  expect_true(nrow(out) > 0)
})

