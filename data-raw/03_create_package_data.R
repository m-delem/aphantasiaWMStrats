load(here::here("inst/extdata/expe_working_memory_data.rda"))
load(here::here("inst/extdata/common_survey_data_full.rda"))

# ---------------------------------------------------------------------------
# Part A: v1/v2
# ---------------------------------------------------------------------------
# working_memory_data is already stimulus-level (one row per stimulus, not
# per trial) and already carries Group, vviq_total_score, object_mean /
# spatial_mean / verbal_mean, and nieq_freq_* / nieq_prop_* - aSD has
# already merged the common survey data in upstream for scores, but not for
# everything: gave_false_info lives only in common_survey_data_full
# (personal, not experiment-specific, so aSD keeps it out of
# working_memory_data), and so do the raw VVIQ/OSIVQ items and some
# demographic columns worth keeping for later use. Joined in below.

common_survey_extra <-
  common_survey_data_full |>
  dplyr::select(
    id,
    country, language_native, language_usual, where_demographics,
    job, education, field, treatment, where_from,
    tidyselect::starts_with("vviq_q"),
    tidyselect::starts_with("osivq_q"),
    object_score, spatial_score, verbal_score, o_count, s_count, v_count,
    gave_false_info, what_false_info
  )

expe_working_memory_data <-
  expe_working_memory_data |>
  dplyr::left_join(common_survey_extra, by = "id")

# vviq_group_2 / vviq_group_4 replace the old "Group" column. Shared by
# both v1/v2 and v3 below - v3 never had a "Group" column at all (it's
# classified straight from vviq_total_score without going through aSD).
classify_vviq_groups <- function(df) {
  df |>
    dplyr::mutate(
      vviq_group_2 = dplyr::case_when(
        vviq_total_score <= 32 ~ "aphantasia",
        vviq_total_score > 32  ~ "typical"
      ),
      vviq_group_4 = dplyr::case_when(
        vviq_total_score == 16                          ~ "aphantasia",
        vviq_total_score > 16  & vviq_total_score <= 32  ~ "hypophantasia",
        vviq_total_score >= 33 & vviq_total_score <= 74  ~ "typical",
        vviq_total_score >= 75                           ~ "hyperphantasia"
      )
    ) |>
    dplyr::select(!tidyselect::any_of("Group"))
}

# NIEQ has 2 items per dimension (frequency, proportion), both 0-100
# sliders. The dimension score is their mean. nieq_freq_* / nieq_prop_* are
# the raw items, not two separate scores.
compute_nieq_scores <- function(df) {
  df |>
    dplyr::rowwise() |>
    dplyr::mutate(
      nieq_mental_imagery =
        mean(c(nieq_freq_mental_imagery, nieq_prop_mental_imagery)),
      nieq_inner_voice    =
        mean(c(nieq_freq_inner_voice, nieq_prop_inner_voice)),
      nieq_emotions       =
        mean(c(nieq_freq_emotions, nieq_prop_emotions)),
      nieq_sensory_focus  =
        mean(c(nieq_freq_sensory_focus, nieq_prop_sensory_focus)),
      nieq_unsymbolised   =
        mean(c(nieq_freq_unsymbolised, nieq_prop_unsymbolised))
    ) |>
    dplyr::ungroup()
}

# id ranges are the only reliable version signal for v1/v2 - the JATOS
# batch field wasn't retained early on. Hardcoded, since v1/v2 are
# discontinued and their id ranges are fixed and already confirmed.
tag_version <- function(df) {
  df |>
    dplyr::mutate(
      version = dplyr::case_when(
        session_id >= 18057 & session_id <= 21544 ~ "v1",
        session_id >= 22109 & session_id <= 27246 ~ "v2",
        session_id > 27246 ~ "v3",
        TRUE ~ NA_character_
      )
    )
}

df_v1v2_nested <-
  expe_working_memory_data |>
  tag_version() |>
  # Questionnaire scoring: VVIQ groups and OSIVQ/NIEQ sub-scale sums
  classify_vviq_groups() |>
  compute_nieq_scores() |>
  # Nest raw items into list-columns: keeps them available without cluttering the
  # main frame. VVIQ items, OSIVQ items, NIEQ items (freq/prop), and strategy
  # report items each get their own nested column.
  tidyr::nest(
    vviq_items = tidyselect::starts_with("vviq_q"),
    osivq_items = c(
      tidyselect::starts_with("osivq_q"),
      object_score, spatial_score, verbal_score, o_count, s_count, v_count
    ),
    nieq_items = c(
      tidyselect::starts_with("nieq_freq"),
      tidyselect::starts_with("nieq_prop")),
    strategy_items = tidyselect::starts_with("strats_cfa"),
    extra_demographics = c(
      "country", "job", "education", "field", "where_from",
      "language_native", "language_usual"
    )
  ) |>
  # is_on_mobile is kept as a real filter for consistency with v3, even though
  # for the current v3 snapshot every is_on_mobile == TRUE row also has 0
  # completed trials (checked directly against the raw data) and would be
  # dropped by the completeness filter regardless. Not assumed to always be
  # redundant with completeness in future data.
  dplyr::filter(!is_on_mobile, is_complete) |>
  # Useless context columns to remove right away before merging them
  dplyr::select(!c(
    "fullscreen", "already_passed", "is_skipped", "component_name",
    "session_id", "result_id", "startDate", "compo_duration", "compo_state",
    "size", "viewport_width", "viewport_height", "browser_info",
    "where_demographics"
  )) |>
  # Adding the response order manually, which was always fixed in v1/v2
  dplyr::mutate(response_order = "word_angle_color")

# ---------------------------------------------------------------------------
# Exclusion review artifacts (v1/v2 side). We do a case-by-case judgment
# for gave_false_info and met_issues, not an automatic filter, so these are
# surfaced as reviewable tables rather than applied silently.
# used_external_support defaults to exclude; gave_false_info and
# met_issues default to include (people sometimes say yes to something that
# turns out to be harmless). See 04_apply_manual_review.R for how manual
# overrides feed back into the pipeline.
# ---------------------------------------------------------------------------

flagged_v1v2 <-
  df_v1v2_nested |>
  dplyr::filter(
    used_external_support == "yes" |
      gave_false_info == "yes" |
      met_issues == "yes"
  ) |>
  dplyr::distinct(
    id, version,
    used_external_support, what_external_support,
    gave_false_info, what_false_info,
    met_issues, issues
  ) |>
  dplyr::mutate(
    default_decision = dplyr::case_when(
      used_external_support == "yes" ~ "exclude",
      TRUE ~ "include"
    )
  )

fs::dir_create(here::here("data-raw/review"))
readr::write_csv(
  flagged_v1v2,
  here::here("data-raw/review/flagged_participants_v1v2.csv")
)

# These questions were mandatory, but someone closing the tab before
# reaching them leaves real NAs, not "no" answers -- worth its own report
# rather than silently reading the same as a clean "no" in flagged_v1v2
# above (NA == "yes" evaluates to NA there, so these rows are already
# correctly excluded from flagged_v1v2, just not visibly explained).
missing_flags_v1v2 <-
  df_v1v2_nested |>
  dplyr::filter(
    is.na(used_external_support) | is.na(gave_false_info) | is.na(met_issues)
  ) |>
  dplyr::distinct(
    id, version, used_external_support, gave_false_info, met_issues)

readr::write_csv(
  missing_flags_v1v2,
  here::here("data-raw/review/missing_flag_data_v1v2.csv")
)

# ---------------------------------------------------------------------------
# Part B: v3
# ---------------------------------------------------------------------------
# cfa_v3_raw_extracted.rds (02_import_v3_raw.R) holds one list entry per
# participant, each with resolved-but-still-raw-JSON components. Flattened
# here into the same shape as df_v1v2_filtered above: one row per stimulus,
# same score/group/version columns, same nested item list-columns.

v3_raw <- readRDS(here::here("inst/extdata/cfa_v3_raw_extracted.rds"))

# vviq_data$total_score and osivq_data's object_mean/spatial_mean/verbal_mean
# are already computed by the front end - no scoring needed, unlike NIEQ. NIEQ
# is scored the same way as Part A: mean of the freq and proportion item for
# each dimension.
score_nieq_v3 <- function(nieq_component) {
  get_pair <- function(dim) {
    freq <- nieq_component[[paste0("nieq_q_freq_", dim, "_data")]]
    prop <- nieq_component[[paste0("nieq_q_proportion_", dim, "_data")]]
    mean(c(freq %||% NA_real_, prop %||% NA_real_))
  }
  tibble::tibble(
    nieq_mental_imagery = get_pair("mental_imagery"),
    nieq_inner_voice    = get_pair("inner_voice"),
    nieq_emotions       = get_pair("emotions"),
    nieq_sensory_focus  = get_pair("sensory_focus"),
    nieq_unsymbolised   = get_pair("unsymbolised")
  )
}

# strats_cfa answers come back as a list per question in raw v3 JSON
# (e.g. list("words", "colours")), not already split into _1/_2/_3
# positional columns like v1/v2. Confirmed against real v1/v2 data that the
# _1/_2/_3 suffix is exactly list position, not a semantic remapping, so
# splitting by position reproduces the same shape.
split_strategy_positions <- function(
    strategies_component,
    question,
    max_positions = 3
) {
  values <- strategies_component[[paste0(question, "_data")]]
  values <- if (is.null(values)) list() else values
  out <- vector("list", max_positions)
  names(out) <- paste0(question, "_", seq_len(max_positions))
  for (i in seq_len(max_positions)) {
    out[[i]] <- if (i <= length(values)) values[[i]] else NA_character_
  }
  tibble::as_tibble(out)
}

# Stimulus-level array fields to unnest from cfa_experiment. Includes
# response_order, v3-only (one 3-element vector per stimulus, no v1/v2
# equivalent) - stays a true list-column through unnest_longer(), not
# flattened.
stim_fields <- c(
  "trial_number", "item_number", "expe_phase",
  "target_word", "target_angle", "target_color_angle", "target_color",
  "response_word", "response_angle", "response_color_angle", "response_color",
  "diff_word", "diff_angle", "diff_color",
  "rt_word", "rt_angle", "rt_color",
  "score_word", "score_angle", "score_color", "trial_score",
  "parity_1_stim", "parity_1_resp", "parity_1_acc", "parity_1_rt",
  "parity_2_stim", "parity_2_resp", "parity_2_acc", "parity_2_rt",
  "response_order"
)

# One row per participant, then unnested to one row per stimulus below.
# Uses hoist() + unnest_longer() on all stim_fields together (index-aligned)
# rather than unlist() per column - unlist() silently drops NULL elements
# instead of keeping them as NA, which corrupts row alignment whenever a
# jsPsych field has a real missing value partway through (this caused a
# length-73-vs-58 mismatch for one participant before the fix). hoist()/
# unnest_longer() are the same underlying tidyr mechanism aSD's own
# unnest_experiment() relies on.
flatten_v3_participant <- function(entry) {
  comps <- entry$components
  expe <- comps$cfa_experiment
  if (is.null(expe)) return(NULL)

  n_stim <- length(expe$trial_number)
  if (is.null(n_stim) || n_stim == 0) return(NULL)

  vviq <- comps$vviq
  osivq <- comps$osivq
  nieq <- comps$nieq
  demo <- comps$demographics
  strat <- comps$cfa_strategies
  feedback <- comps$thanks_feedback

  stim_df <-
    tibble::tibble(data = list(expe)) |>
    tidyr::hoist(data, !!!stats::setNames(as.list(stim_fields), stim_fields)) |>
    dplyr::select(!data) |>
    tidyr::unnest_longer(tidyselect::all_of(stim_fields)) |>
    dplyr::mutate(
      id = comps$welcome_consent_id$subject_id_data,
      language = comps$welcome_consent_id$language,
      .before = 1
    )

  nieq_scored <- if (!is.null(nieq)) score_nieq_v3(nieq) else NULL

  strategy_row <- if (!is.null(strat)) {
    dplyr::bind_cols(
      split_strategy_positions(strat, "strats_cfa_q01_colors"),
      split_strategy_positions(strat, "strats_cfa_q02_orientations"),
      split_strategy_positions(strat, "strats_cfa_q03_words"),
      split_strategy_positions(
        strat, "strats_cfa_q04_scoring_strat", max_positions = 2)
    )
  } else NULL

  vviq_items_row <- if (!is.null(vviq)) {
    pages <- list(
      vviq$vviq_qp1_data,
      vviq$vviq_qp2_data,
      vviq$vviq_qp3_data,
      vviq$vviq_qp4_data)
    items <- purrr::list_flatten(purrr::compact(pages))
    names(items) <- stringr::str_remove(names(items), "_data$")
    tibble::as_tibble(items)
  } else NULL

  osivq_items_row <- if (!is.null(osivq)) {
    tibble::as_tibble(
      stats::setNames(
        as.list(osivq$osivq_data$value),
        osivq$osivq_data$item)
    )
  } else NULL

  participant_level <- tibble::tibble(
    total_score_word = expe$total_score_word %||% NA,
    total_score_angle = expe$total_score_angle %||% NA,
    total_score_color = expe$total_score_color %||% NA,
    total_score = expe$total_score %||% NA,
    is_complete = expe$is_complete %||% NA,
    is_on_mobile = expe$is_on_mobile %||% NA,
    age = demo$age_data %||% NA,
    gender = demo$gender_data %||% NA,
    country = demo$country_data %||% NA,
    language_native = demo$language_native_data %||% NA,
    language_usual = demo$language_usual_data %||% NA,
    job = demo$job_data %||% NA,
    education = demo$education_data %||% NA,
    field = demo$field_data %||% NA,
    where_from = demo$where_from_data %||% NA,
    prognosis = demo$prognosis_data %||% NA,
    # treatment and neuro_trouble were not collected in v3's demographics
    # form (confirmed absent from real v3 data, not a parsing gap) - NA for
    # every v3 participant until/unless the front end is updated to ask.
    treatment = NA,
    neuro_trouble = NA,
    vviq_total_score = vviq$vviq_data$total_score %||% NA,
    object_mean = osivq$osivq_data$object_mean %||% NA,
    spatial_mean = osivq$osivq_data$spatial_mean %||% NA,
    verbal_mean = osivq$osivq_data$verbal_mean %||% NA,
    object_score = osivq$osivq_data$object_score %||% NA,
    spatial_score = osivq$osivq_data$spatial_score %||% NA,
    verbal_score = osivq$osivq_data$verbal_score %||% NA,
    o_count = osivq$osivq_data$o_count %||% NA,
    s_count = osivq$osivq_data$s_count %||% NA,
    v_count = osivq$osivq_data$v_count %||% NA,
    used_external_support = feedback$used_external_support_data %||% NA,
    # v3's thanks_feedback has no free-text field paralleling
    # what_external_support/what_false_info (confirmed against real data:
    # only yes/no fields plus feedback_data/issues_data exist) - NA
    # throughout for v3, not a parsing gap.
    what_external_support = NA,
    gave_false_info = feedback$gave_false_info_data %||% NA,
    what_false_info = NA,
    met_issues = feedback$met_issues_data %||% NA,
    issues = feedback$issues_data %||% NA
  )

  if (!is.null(nieq_scored)) participant_level <-
    dplyr::bind_cols(participant_level, nieq_scored)

  if (!is.null(vviq_items_row)) participant_level <-
    dplyr::bind_cols(participant_level, vviq_items_row)

  if (!is.null(osivq_items_row)) participant_level <-
    dplyr::bind_cols(participant_level, osivq_items_row)

  if (!is.null(strategy_row)) participant_level <-
    dplyr::bind_cols(participant_level, strategy_row)

  flat_df <-
    dplyr::bind_cols(
      stim_df,
      participant_level[rep(1, nrow(stim_df)), ]
    ) |>
    dplyr::rowwise() |>
    dplyr::mutate(
      response_order =
        stringr::str_flatten(
          response_order |>
            stringr::str_replace("0", "word") |>
            stringr::str_replace("1", "angle") |>
            stringr::str_replace("2", "color"),
          collapse = "_"
        )
    ) |>
    dplyr::ungroup()

  return(flat_df)
}

df_v3_nested <-
  purrr::map(v3_raw, flatten_v3_participant) |>
  purrr::compact() |>
  purrr::list_rbind() |>
  dplyr::mutate(version = "v3") |>
  classify_vviq_groups() |>
  dplyr::filter(!is_on_mobile, is_complete) |>
  tidyr::nest(
    vviq_items = tidyselect::starts_with("vviq_q"),
    osivq_items = c(
      tidyselect::starts_with("osivq_q"),
      object_score, spatial_score, verbal_score, o_count, s_count, v_count
    ),
    nieq_items = tidyselect::starts_with("nieq_q_"),
    strategy_items = tidyselect::starts_with("strats_cfa"),
    extra_demographics = c(
      "country", "job", "education", "field", "where_from",
      "language_native", "language_usual"
    )
  )

# ---------------------------------------------------------------------------
# Exclusion review artifacts (v3 side), mirroring Part A. what_external_support
# and what_false_info are not collected as free text in v3's thanks_feedback
# (only yes/no fields exist there, confirmed against real raw data) so
# those two columns are NA throughout for v3 - flagged here rather than
# silently absent from the review table.
# ---------------------------------------------------------------------------

flagged_v3 <-
  df_v3_nested |>
  dplyr::filter(
    used_external_support == "yes" |
      gave_false_info == "yes" |
      met_issues == "yes"
  ) |>
  dplyr::distinct(
    id, version,
    used_external_support, what_external_support,
    gave_false_info, what_false_info,
    met_issues, issues
  ) |>
  dplyr::mutate(
    default_decision = dplyr::case_when(
      used_external_support == "yes" ~ "exclude",
      TRUE ~ "include"
    )
  )

readr::write_csv(
  flagged_v3,
  here::here("data-raw/review/flagged_participants_v3.csv")
)

missing_flags_v3 <-
  df_v3_nested |>
  dplyr::filter(
    is.na(used_external_support) | is.na(gave_false_info) | is.na(met_issues)
  ) |>
  dplyr::distinct(
    id, version, used_external_support, gave_false_info, met_issues)

readr::write_csv(
  missing_flags_v3,
  here::here("data-raw/review/missing_flag_data_v3.csv")
)
