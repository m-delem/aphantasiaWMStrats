library(osfr)

# ---------------------------------------------------------------------------
# Step 1: download the raw JATOS export for CFA-WM v3 from its own OSF
# component (not the general Data component: v3 is independent, see the
# CFA-WM component wiki's "Version history" page for why).
# ---------------------------------------------------------------------------

# osf_auth("ThIsIsNoTaReAlPATbUtYoUgEtIt")

v3_raw_dir <- here::here("inst/extdata/cfa_v3_raw")
if (dir.exists(v3_raw_dir)) unlink(v3_raw_dir, recursive = TRUE)
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

# vviq/osivq/nieq duplicates: matches aSD's gather_questionnaires()
# (arrange by desc(is_complete), already_passed, startDate, then
# fill(contains("data"), .direction = "downup") before taking the best
# row). Adapted here to v3's item/value parallel-array shape (aSD's shape
# is one named column per item, which fill() operates on directly; v3's
# raw JSON instead nests item names and values as two parallel lists under
# "{component}_data", so filling has to match by item name explicitly
# rather than by column name). Confirmed against real duplicate data
# (study_result_31785's OSIVQ: one 31-item incomplete attempt alongside
# two complete 34-item ones) and a synthetic case with genuinely
# complementary gaps across two incomplete attempts, to verify the fill
# logic itself, since no real case in the current data actually needs it
# (a complete attempt was always available when duplicates existed).
resolve_questionnaire <- function(entries) {
  if (length(entries) == 1) return(entries[[1]])

  wrapper_key <- paste0(entries[[1]]$component_name, "_data")
  wrappers <- purrr::map(entries, wrapper_key)

  is_complete <- purrr::map_lgl(wrappers, ~ isTRUE(.x$is_complete))
  already_passed <- purrr::map_lgl(wrappers, ~ isTRUE(.x$already_passed))

  # Sort: most complete first, then already_passed, mirroring aSD's
  # arrange(desc(is_complete), already_passed, startDate). startDate isn't
  # a usable tiebreaker here since all entries within one study_result
  # share the same study_result-level startDate (confirmed earlier this
  # session: no per-comp-result date exists), so it's omitted rather than
  # included as a no-op.
  ord <- order(!is_complete, !already_passed)
  entries_sorted <- entries[ord]
  wrappers_sorted <- wrappers[ord]

  best_wrapper <- wrappers_sorted[[1]]

  if (!is.null(best_wrapper$item) && !is.null(best_wrapper$value)) {
    best_items <- best_wrapper$item
    best_values <- best_wrapper$value

    for (i in seq_along(best_values)) {
      if (is.null(best_values[[i]]) || is.na(best_values[[i]])) {
        item_name <- best_items[[i]]
        for (w in wrappers_sorted[-1]) {
          if (is.null(w$item)) next
          match_idx <- which(unlist(w$item) == item_name)
          if (length(match_idx) == 1 &&
              !is.null(w$value[[match_idx]]) &&
              !is.na(w$value[[match_idx]])) {
            best_values[[i]] <- w$value[[match_idx]]
            break
          }
        }
      }
    }
    best_wrapper$value <- best_values
  }

  best <- entries_sorted[[1]]
  best[[wrapper_key]] <- best_wrapper
  best
}

# welcome_consent_id duplicates don't have the item/value questionnaire
# shape at all - they're a simple flat set of fields, and duplicates seen
# in real data look like reload stubs (an early, near-empty capture before
# the participant actually consented, alongside a real complete one), not
# a fill-worthy case. Resolved by keeping whichever entry has more
# non-null fields, which is a reasonable proxy for "the one that actually
# completed" without needing a component-specific is_complete flag (none
# exists for this component).
resolve_welcome_consent_id <- function(entries) {
  if (length(entries) == 1) return(entries[[1]])
  n_populated <- purrr::map_int(entries, ~ sum(!purrr::map_lgl(.x, is.null)))
  entries[[which.max(n_populated)]]
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

  # Capture incompleteness info here, before resolve_cfa_experiment()
  # discards the detail entirely (it only keeps entries with exactly 73
  # rows). This is the only point where the real trial count for a dropped
  # participant is still available - reconstructing it later from
  # all_results is impossible once resolve_cfa_experiment() has run, since
  # a dropped participant's cfa_experiment is just gone by then.
  cfa_experiment_entries <- by_component[["cfa_experiment"]]
  incompleteness_record <- if (!is.null(cfa_experiment_entries)) {
    n_trials <- purrr::map_int(cfa_experiment_entries, n_trials_completed)
    if (all(n_trials < 73L)) {
      list(study_result_id = study_result_id, n_trials = max(n_trials))
    } else NULL
  } else NULL

  resolved <- purrr::imap(by_component, function(entries, component) {
    # cfa_experiment always needs the 73-row completeness check, even with
    # only one entry - a lone incomplete attempt is the common case, not
    # just a duplicate-resolution edge case. This must come before the
    # length == 1 shortcut below, or single incomplete attempts silently
    # pass through unfiltered (a real bug caught by testing against real
    # data: a single-entry, 43-row cfa_experiment was passing through
    # untouched before this fix).
    if (component == "cfa_experiment") return(resolve_cfa_experiment(entries))
    if (length(entries) == 1) return(entries[[1]])
    if (component == "thanks_feedback") return(resolve_thanks_feedback(entries))
    if (component %in% c("vviq", "osivq", "nieq")) return(resolve_questionnaire(entries))
    if (component == "welcome_consent_id") return(resolve_welcome_consent_id(entries))
    warning(
      "Unexpected duplicate component '", component, "' in study_result ",
      study_result_id, ": keeping the first entry."
    )
    entries[[1]]
  })

  # cfa_experiment can now be NULL if every duplicate attempt was
  # incomplete - treat that the same as never having had the component.
  resolved <- purrr::compact(resolved)

  list(
    study_result_id = study_result_id,
    components = resolved,
    incomplete_cfa_experiment = incompleteness_record
  )
}

all_results <-
  purrr::map(study_result_dirs, extract_study_result) |>
  purrr::compact()

message(
  "Extracted ", length(all_results), " participants with at least one ",
  "relevant component (out of ", length(study_result_dirs),
  " study_result folders)."
)

# Two distinct populations end up with components$cfa_experiment == NULL,
# worth keeping separate rather than conflating into one "missing" bucket:
# never attempted cfa_experiment at all (no comp-result for it, ever), vs.
# attempted it but every attempt fell short of 73 rows (caught above via
# incomplete_cfa_experiment, which is only set when a cfa_experiment entry
# existed in the first place).
never_started <-
  all_results |>
  purrr::keep(
    ~ is.null(.x$components$cfa_experiment) &&
      is.null(.x$incomplete_cfa_experiment)) |>
  purrr::map_chr("study_result_id")

if (length(never_started) > 0) {
  message(
    length(never_started), " participant(s) never attempted cfa_experiment ",
    "at all (no comp-result found for it): ",
    paste(never_started, collapse = ", ")
  )
}

# excluded_incomplete_v3.csv: everyone dropped for cfa_experiment reasons,
# whether they never started it or started and fell short of 73 rows.
# Written here, not in 03_create_package_data.R, because this is the only
# point where the real trial count is still available -
# resolve_cfa_experiment() discards it for anything short of 73 rows, so by
# the time 03 runs, a dropped participant's cfa_experiment is just gone.
incomplete_records <-
  all_results |>
  purrr::map("incomplete_cfa_experiment") |>
  purrr::compact()

never_started_records <-
  purrr::map(never_started, ~ list(study_result_id = .x, n_trials = 0L))

all_excluded_records <- c(incomplete_records, never_started_records)

excluded_incomplete_v3 <-
  purrr::map(all_excluded_records, function(rec) {
    matching <-
      purrr::keep(
        all_results,
        ~ .x$study_result_id == rec$study_result_id)
    tibble::tibble(
      id = rec$study_result_id,
      n_trials = rec$n_trials
    )
  }) |>
  purrr::list_rbind()

fs::dir_create(here::here("data-raw/review"))
readr::write_csv(
  excluded_incomplete_v3,
  here::here("data-raw/review/excluded_incomplete_v3.csv")
)

saveRDS(all_results, here::here("inst/extdata/cfa_v3_raw_extracted.rds"))
