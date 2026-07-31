# -----------------------------------------------------------------------
# 05_export_datasets_to_osf.R
#
# Produces two shareable, non-package-internal exports from `all_data`
# and pushes both to CFA-WM's own OSF component (3649s), in a
# "v3 Data/Processed data" subfolder (created if it doesn't exist yet).
# Each dataset is written as both .csv and .xlsx (openxlsx), so four
# files total are produced and uploaded.
#
# 1. all_data_surveys.{csv,xlsx}: one row per participant. All
#    trial/stimulus-level columns dropped (target/response/diff/rt/
#    score/parity/trial_number/item_number/expe_phase/response_order),
#    de-duplicated to one row per id/version. The nested item
#    list-columns (vviq_items, osivq_items, nieq_items, strategy_items,
#    extra_demographics) are unnested wide with tidyr::unnest_wider(),
#    which matches by name rather than position - required because
#    osivq_items' raw item order differs between v1/v2 and v3 (same 34
#    items, different order), so a position-based unnest would silently
#    misalign columns.
#
#    One expected artefact of the wide unnest: strategy_items has 12
#    raw items for v1/v2 (*_scoring_strat_{1,2,3}_1) but only 11 for v3
#    (*_scoring_strat_{1,2}, no third position). After unnesting, the
#    v1/v2-only column (strats_cfa_q04_scoring_strat_3_1) is NA for
#    every v3 row. Left as-is rather than dropped, since it's real data
#    for v1/v2 participants.
#
# 2. all_data_full.{csv,xlsx}: all_data at full stimulus-level
#    granularity (one row per stimulus), with the five nested
#    list-columns dropped entirely (not unnested: repeating ~113
#    participant-level questionnaire-item columns across every
#    stimulus row would bloat the file for no analytic benefit,
#    that data belongs in the one-line export above). Otherwise
#    all_data as shipped by the package, unmodified.
# -----------------------------------------------------------------------

library(osfr)

# osf_auth("ThIsIsNoTaReAlPATbUtYoUgEtIt")

# ---------------------------------------------------------------------
# 1. Build the one-line (participant-level) dataset
# ---------------------------------------------------------------------

trial_level_cols <- c(
  "expe_phase", "trial_number", "response_order", "item_number",
  "target_word", "target_angle", "target_color_angle", "target_color",
  "response_word", "response_angle", "response_color_angle",
  "response_color",
  "diff_word", "diff_angle", "diff_color",
  "rt_word", "rt_angle", "rt_color",
  "score_word", "score_angle", "score_color", "trial_score",
  "parity_1_stim", "parity_1_resp", "parity_1_acc", "parity_1_rt",
  "parity_2_stim", "parity_2_resp", "parity_2_acc", "parity_2_rt"
)

nested_cols <- c(
  "vviq_items", "osivq_items", "nieq_items", "strategy_items",
  "extra_demographics"
)

all_data_surveys <-
  aphantasiaWMStrats::all_data |>
  dplyr::select(!tidyselect::all_of(trial_level_cols)) |>
  dplyr::distinct(id, version, .keep_all = TRUE) |>
  tidyr::unnest_wider(vviq_items) |>
  tidyr::unnest_wider(osivq_items) |>
  tidyr::unnest_wider(nieq_items) |>
  tidyr::unnest_wider(strategy_items) |>
  tidyr::unnest_wider(extra_demographics)

# Sanity check: one row per id/version, no participant lost or
# duplicated relative to all_data's participant count.
stopifnot(
  nrow(all_data_surveys) ==
    nrow(dplyr::distinct(aphantasiaWMStrats::all_data, id, version))
)

# ---------------------------------------------------------------------
# 2. Build the full (stimulus-level) dataset
# ---------------------------------------------------------------------

all_data_full <-
  aphantasiaWMStrats::all_data |>
  dplyr::select(!tidyselect::all_of(nested_cols))

# ---------------------------------------------------------------------
# 3. Write local files (data-raw/exports/, gitignored - see .gitignore)
# ---------------------------------------------------------------------

export_dir <- here::here("data-raw/exports")
fs::dir_create(export_dir)

readr::write_csv(
  all_data_surveys, fs::path(export_dir, "all_data_surveys.csv")
)
readr::write_csv(
  all_data_full, fs::path(export_dir, "all_data_full.csv")
)

openxlsx::write.xlsx(
  all_data_surveys,
  fs::path(export_dir, "all_data_surveys.xlsx"),
  asTable    = TRUE,
  colNames   = TRUE,
  colWidths  = "auto",
  borders    = "all",
  tableStyle = "TableStyleMedium16"
)
openxlsx::write.xlsx(
  all_data_full,
  fs::path(export_dir, "all_data_full.xlsx"),
  asTable    = TRUE,
  colNames   = TRUE,
  colWidths  = "auto",
  borders    = "all",
  tableStyle = "TableStyleMedium16"
)

# ---------------------------------------------------------------------
# 4. Push to OSF: component 3649s, "v3 Data/Processed data" subfolder
# ---------------------------------------------------------------------
# Mirrors the download-direction osfr pattern used in
# 01_import_v1v2_osf.R/02_import_v3_raw.R, in reverse. Navigates to the
# existing "v3 Data" folder, then creates "Processed data" under it if
# it doesn't already exist (osf_mkdir is a safe create, if the
# folder is already there, we just navigate into it instead of trying
# to create a duplicate).

v3_data_folder <-
  osf_retrieve_node("3649s") |>
  osf_ls_files() |>
  dplyr::filter(stringr::str_detect(name, "v3 Data"))

existing_processed <-
  v3_data_folder |>
  osf_ls_files() |>
  dplyr::filter(name == "Processed data")

processed_data_folder <- if (nrow(existing_processed) > 0) {
  existing_processed
} else {
  osf_mkdir(v3_data_folder, path = "Processed data")
}

osf_upload(
  processed_data_folder,
  path = fs::dir_ls(export_dir, glob = "*.csv"),
  conflicts = "overwrite"
)
osf_upload(
  processed_data_folder,
  path = fs::dir_ls(export_dir, glob = "*.xlsx"),
  conflicts = "overwrite"
)

message(
  "Uploaded all_data_surveys.{csv,xlsx} and all_data_full.{csv,xlsx} ",
  "to component 3649s, v3 Data/Processed data."
)
