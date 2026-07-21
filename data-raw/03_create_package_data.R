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

# vviq_group_2 / vviq_group_4 replace the old "Group" column
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
    dplyr::select(!Group)
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

# id ranges are the only reliable version signal for v1/v2 -- the JATOS
# batch field wasn't retained early on. Hardcoded, since v1/v2 are
# discontinued and their id ranges are fixed and already confirmed.
tag_version <- function(df) {
  df |>
    dplyr::mutate(
      version = dplyr::case_when(
        id >= 18057 & id <= 21544 ~ "v1",
        id >= 22109 & id <= 27246 ~ "v2",
        TRUE ~ NA_character_
      )
    )
}

df_v1v2_scored <-
  expe_working_memory_data |>
  tag_version() |>
  classify_vviq_groups() |>
  compute_nieq_scores()

# Nest raw items into list-columns: keeps them available without cluttering the
# main frame. VVIQ items, OSIVQ items, NIEQ items (freq/prop), and strategy
# report items each get their own nested column.
df_v1v2_nested <-
  df_v1v2_scored |>
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
      "language_native", "language_usual", "where_demographics"
    )
  )

# is_on_mobile is kept as a real filter for consistency with v3, even though
# for the current v3 snapshot every is_on_mobile == TRUE row also has 0
# completed trials (checked directly against the raw data) and would be
# dropped by the completeness filter regardless. Not assumed to always be
# redundant with completeness in future data.
df_v1v2_filtered <- df_v1v2_nested |> dplyr::filter(!is_on_mobile, is_complete)

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
  df_v1v2_filtered |>
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
  df_v1v2_filtered |>
  dplyr::filter(
    is.na(used_external_support) | is.na(gave_false_info) | is.na(met_issues)
  ) |>
  dplyr::distinct(id, version, used_external_support, gave_false_info, met_issues)

readr::write_csv(
  missing_flags_v1v2,
  here::here("data-raw/review/missing_flag_data_v1v2.csv")
)
