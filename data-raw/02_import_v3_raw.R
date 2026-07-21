library(osfr)

# ---------------------------------------------------------------------------
# Step 1: download the raw JATOS export for CFA-WM v3 from its own OSF
# component (not the general Data component: v3 is independent, see the
# CFA-WM component wiki's "Version history" page for why).
# ---------------------------------------------------------------------------

# osf_auth("ThIsIsNoTaReAlPATbUtYoUgEtIt")

v3_raw_dir <- here::here("inst/extdata/cfa_v3_raw")
fs::dir_create(v3_raw_dir)

osf_retrieve_node("3649s") |>
  osf_ls_files() |>
  dplyr::filter(stringr::str_detect(name, "v3 Data")) |>
  osf_ls_files() |>
  dplyr::filter(stringr::str_detect(name, "JATOS")) |>
  osf_ls_files() |>
  dplyr::filter(stringr::str_detect(name, "\\.zip$")) |>
  osf_download(path = v3_raw_dir, conflicts = "overwrite")

zip_file <- fs::dir_ls(v3_raw_dir, glob = "*.zip")[1]
unzip(zip_file, exdir = v3_raw_dir)

# Sanity check: fail loudly if the expected structure isn't there, rather
# than silently proceeding on an empty or malformed extraction.
study_result_dirs <-
  fs::dir_ls(v3_raw_dir, recurse = FALSE, type = "directory") |>
  purrr::keep(~ stringr::str_detect(basename(.x), "^study_result_"))

if (length(study_result_dirs) == 0) {
  stop(
    "No study_result_* folders found after unzipping ", zip_file,
    ". Check the zip's internal structure -- it may be nested inside an ",
    "extra top-level folder, in which case exdir needs adjusting."
  )
}

message("Found ", length(study_result_dirs), " study_result folders.")

# metadata.json has study-result-level fields not in any data.txt: startDate
# and batchTitle. Needed below to resolve cfa_experiment duplicates.
metadata_path <- fs::path(v3_raw_dir, "metadata.json")
if (!fs::file_exists(metadata_path)) {
  stop("metadata.json not found in ", v3_raw_dir)
}

metadata <- jsonlite::fromJSON(metadata_path, simplifyVector = FALSE)
study_results_meta <- metadata$data[[1]]$studyResults

unexpected_batch <-
  purrr::keep(study_results_meta, ~ .x$batchTitle != "Version_3")

if (length(unexpected_batch) > 0) {
  warning(
    length(unexpected_batch), " study_result(s) have a batchTitle other ",
    "than \"Version_3\": ",
    paste(purrr::map_chr(unexpected_batch, "batchTitle"), collapse = ", ")
  )
}

# ---------------------------------------------------------------------------
# Step 2: for each study_result, read every comp-result's data.txt and keep
# one row per relevant component_name. Components may repeat within a
# study_result because of page reloads. Resolution differs by component:
# cfa_experiment and thanks_feedback each have their own logic below; any
# other component repeating is unexpected and handled with a warning.
# ---------------------------------------------------------------------------

relevant_components <- c(
  "welcome_consent_id", "demographics", "vviq", "nieq", "osivq",
  "cfa_experiment", "cfa_strategies", "thanks_feedback"
)
# thanks_feedback carries participant-level self-reports worth keeping for
# exclusion/data-quality decisions - gave_false_info_data,
# used_external_support_data, and met_issues_data - plus free-text
# feedback_data, kept for context even though it isn't itself an exclusion
# criterion.

read_comp_result <- function(path) {
  d <- tryCatch(
    jsonlite::fromJSON(path, simplifyVector = FALSE),
    error = function(e) NULL)
  if (is.null(d)) return(NULL)
  d
}

n_trials_completed <- function(d) {
  tn <- d$trial_number
  if (is.null(tn)) 0L else length(tn)
}

# Matches aSD's unnest_experiment() (max_trials <- 73 for CFA): a complete
# run has 73 stimulus-level rows (3 training + 24 trials x 3 stimuli, minus
# 2 for how the first training stimulus is logged). Anything short of 73 is
# dropped outright, not kept as a best-available partial - there's no
# principled way to analyse a truncated run, and this is robust to
# is_complete being unreliable since it checks actual row count instead.
resolve_cfa_experiment <- function(entries) {
  n_trials <- purrr::map_int(entries, n_trials_completed)
  complete <- entries[n_trials == 73L]
  if (length(complete) == 0) return(NULL)
  complete[[1]]
}

# thanks_feedback duplicates are not reload-abandoned attempts the way
# cfa_experiment duplicates are: both entries can carry genuine, different
# content (confirmed case: a participant added detail to their free-text
# feedback on a second submission rather than replacing it). Resolved
# differently from cfa_experiment: self-report flags use "yes wins" (a
# single self-reported issue anywhere counts, even if a later resubmission
# said otherwise), and free-text fields are concatenated rather than
# picking one.
# Uses base R's %||% operator
yes_wins <- function(values) {
  values <- unlist(values)
  if (any(values == "yes", na.rm = TRUE)) "yes" else values[[1]]
}

resolve_thanks_feedback <- function(entries) {
  if (length(entries) == 1) return(entries[[1]])
  base <- entries[[1]]
  base$gave_false_info_data <-
    yes_wins(purrr::map(entries, "gave_false_info_data"))
  base$used_external_support_data <-
    yes_wins(purrr::map(entries, "used_external_support_data"))
  base$met_issues_data <-
    yes_wins(purrr::map(entries, "met_issues_data"))
  base$feedback_data <-
    purrr::map_chr(entries, ~ .x$feedback_data %||% "") |>
    purrr::discard(~ .x == "") |>
    paste(collapse = " || ")
  base$issues_data <-
    purrr::map_chr(entries, ~ .x$issues_data %||% "") |>
    purrr::discard(~ .x == "") |>
    paste(collapse = " || ")
  return(base)
}

extract_study_result <- function(sr_dir) {
  study_result_id <- stringr::str_remove(basename(sr_dir), "^study_result_")

  comp_files <- fs::dir_ls(sr_dir, recurse = TRUE, glob = "*/data.txt")
  parsed <- purrr::map(comp_files, read_comp_result) |> purrr::compact()

  parsed_relevant <-
    purrr::keep(
      parsed,
      ~ !is.null(.x$component_name) &&
        .x$component_name %in% relevant_components)

  if (length(parsed_relevant) == 0) return(NULL)

  # Group by component_name, resolve duplicates within each group
  by_component <- split(
    parsed_relevant,
    purrr::map_chr(parsed_relevant, "component_name"))

  resolved <- purrr::imap(by_component, function(entries, component) {
    if (length(entries) == 1) return(entries[[1]])
    if (component == "thanks_feedback") return(resolve_thanks_feedback(entries))
    if (component == "cfa_experiment") return(resolve_cfa_experiment(entries))
    warning(
      "Unexpected duplicate component '", component, "' in study_result ",
      study_result_id, ": keeping the first entry."
    )
    entries[[1]]
  })

  # cfa_experiment can now be NULL if every duplicate attempt was
  # incomplete - treat that the same as never having had the component.
  resolved <- purrr::compact(resolved)

  list(study_result_id = study_result_id, components = resolved)
}

all_results <-
  purrr::map(study_result_dirs, extract_study_result) |>
  purrr::compact()

message(
  "Extracted ", length(all_results), " participants with at least one ",
  "relevant component (out of ", length(study_result_dirs),
  " study_result folders)."
)

# Flag, don't silently drop: participants missing cfa_experiment entirely
# (e.g. dropped out before starting the task) are worth knowing about before
# they disappear from anything downstream.
missing_experiment <-
  all_results |>
  purrr::keep(~ is.null(.x$components$cfa_experiment)) |>
  purrr::map_chr("study_result_id")

if (length(missing_experiment) > 0) {
  message(
    length(missing_experiment), " participant(s) have no cfa_experiment ",
    "component at all and will be dropped in the next script: ",
    paste(missing_experiment, collapse = ", ")
  )
}

saveRDS(all_results, here::here("inst/extdata/cfa_v3_raw_extracted.rds"))
