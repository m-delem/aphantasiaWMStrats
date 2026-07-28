# -----------------------------------------------------------------------
# 04_apply_manual_review.R
#
# Cross-references the flagged-participant review files produced by
# 03_create_package_data.R (flagged_participants_v1v2.csv,
# flagged_participants_v3.csv, each carrying a `default_decision`) with
# data-raw/review/manual_decisions.csv, a small, checked-in, append-only
# file where we record actual inclusion/exclusion calls. A manual
# decision always overrides the default; anyone flagged but not yet
# manually reviewed falls back to `default_decision`.
#
# manual_decisions.csv is never written to by 03, so it survives pipeline
# re-runs. The flagged_participants_*.csv files, by contrast, are fully
# regenerated every time 03 runs and must not be hand-edited.
#
# This script both (a) writes a review artifact (final_decisions.csv) and
# (b) applies the resulting exclusions to df_v1v2_nested / df_v3_nested,
# combines both versions into one analysis-ready tibble (their unnested
# columns match; nested item list-columns keep version-specific raw items
# under shared list-column names), and saves it as the package's
# `all_data` object via usethis::use_data().
# -----------------------------------------------------------------------

# ---------------------------------------------------------------------
# 1. Load inputs
# ---------------------------------------------------------------------

df_v1v2_nested <- readRDS(here::here("inst/extdata/df_v1v2_nested.rds"))
df_v3_nested   <- readRDS(here::here("inst/extdata/df_v3_nested.rds"))

flagged_v1v2 <- readr::read_csv(
  here::here("data-raw/review/flagged_participants_v1v2.csv"),
  show_col_types = FALSE
)
flagged_v3 <- readr::read_csv(
  here::here("data-raw/review/flagged_participants_v3.csv"),
  show_col_types = FALSE
)

manual_decisions_path <- here::here("data-raw/review/manual_decisions.csv")

# If manual_decisions.csv is ever accidentally deleted, this recreates it
# empty rather than erroring, so the script keeps running off defaults
# alone - but this is meant as a safety net, not a substitute for the
# file being checked into version control.
if (!fs::file_exists(manual_decisions_path)) {
  readr::write_csv(
    tibble::tibble(
      id = character(), version = character(), decision = character(),
      note = character(), decided_date = character()
    ),
    manual_decisions_path
  )
}

manual_decisions <- readr::read_csv(
  manual_decisions_path,
  show_col_types = FALSE
)

# ---------------------------------------------------------------------
# 2. Cross-reference: manual decision wins, default_decision is fallback
# ---------------------------------------------------------------------

resolve_decisions <- function(flagged_df) {
  flagged_df |>
    dplyr::left_join(
      manual_decisions |>
        dplyr::select(id, version, manual_decision = decision, note,
                       decided_date),
      by = c("id", "version")
    ) |>
    dplyr::mutate(
      final_decision = dplyr::coalesce(manual_decision, default_decision),
      reviewed = !is.na(manual_decision)
    )
}

final_v1v2 <- resolve_decisions(flagged_v1v2)
final_v3   <- resolve_decisions(flagged_v3)

final_decisions <- dplyr::bind_rows(final_v1v2, final_v3)

# Flag any manual decision that no longer matches a currently-flagged
# participant. This catches typos in id/version, and cases where someone
# manually reviewed is no longer flagged after a re-run of 03 (e.g. underlying
# data changed).
stale_manual <-
  dplyr::anti_join(
    manual_decisions,
    final_decisions,
    by = c("id", "version")
  )

if (nrow(stale_manual) > 0) {
  warning(
    "manual_decisions.csv contains ", nrow(stale_manual),
    " entr", if (nrow(stale_manual) == 1) "y" else "ies",
    " that no longer match a currently-flagged participant ",
    "(check for typos, or a participant no longer flagged after a ",
    "re-run of 03_create_package_data.R): ",
    paste(paste(stale_manual$id, stale_manual$version, sep = "/"),
          collapse = ", ")
  )
}

fs::dir_create(here::here("data-raw/review"))
readr::write_csv(
  final_decisions,
  here::here("data-raw/review/final_decisions.csv")
)

# ---------------------------------------------------------------------
# 3. Apply exclusions and combine versions
# ---------------------------------------------------------------------

excluded_ids <-
  final_decisions |>
  dplyr::filter(final_decision == "exclude") |>
  dplyr::distinct(id, version)

apply_exclusions <- function(df, excluded_ids) {
  df |> dplyr::anti_join(excluded_ids, by = c("id", "version"))
}

df_v1v2_final <- apply_exclusions(df_v1v2_nested, excluded_ids)
df_v3_final   <- apply_exclusions(df_v3_nested, excluded_ids)

# v1/v2 and v3's unnested columns match and can be stacked
all_data <- dplyr::bind_rows(df_v1v2_final, df_v3_final) |>
  # Several columns used for data cleaning in the data-raw/ numbered scripts
  # can now be removed
  dplyr::select(!c(
    "is_complete", "is_on_mobile", "met_issues", "issues",
    "used_external_support", "what_external_support", "gave_false_info",
    "what_false_info"
  )) |>
  dplyr::relocate(c(
    "vviq_group_2", "vviq_group_4",
    "nieq_mental_imagery":"nieq_unsymbolised"),
    .after = "vviq_total_score"
  ) |>
  dplyr::relocate(c("version", "language"), .after = "id") |>
  dplyr::relocate("response_order", .after = "trial_number")

# ---------------------------------------------------------------------
# 4. Save as package data
# ---------------------------------------------------------------------

usethis::use_data(all_data, overwrite = TRUE)
