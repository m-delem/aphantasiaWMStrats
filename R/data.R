#' Working memory strategies experiment (CFA-WM) combined dataset (v1, v2, v3)
#'
#' Stimulus-level data from the CFA-WM working memory task (word/orientation/
#' colour recall under a parity-judgement distractor), combining all three
#' study versions into one tibble. One row per stimulus (three stimuli per
#' trial, plus one tutorial trial). Built from raw/processed data by the
#' scripts in `data-raw/` - see `data-raw/README.md` for the full pipeline,
#' and `data-raw/review/` for the exclusion decisions applied before this
#' object was created.
#'
#' Excluded already: participants who didn't complete the task, took it on
#' mobile, or were flagged and excluded during manual review (see
#' `data-raw/review/final_decisions.csv` for exactly who and why). Not
#' excluded: nothing beyond that, no participant- or trial-level
#' statistical outlier removal has been applied.
#'
#' @format A tibble with one row per stimulus and the following columns:
#'
#' **Identifiers and version**
#' \describe{
#'   \item{id}{Participant identifier.}
#'   \item{version}{Study version: `"v1"`, `"v2"`, or `"v3"`.}
#'   \item{language}{UI language of the experiment in the browser.}
#' }
#'
#' **Trial and stimulus structure**
#' \describe{
#'   \item{trial_number}{Trial index (1 tutorial + 3 training + 21 test
#'     trials per participant).}
#'   \item{response_order}{Order in which the three response modalities were
#'     collected for this trial, e.g. `"word_angle_color"`. Fixed in v1/v2
#'     (always word/angle/colour); randomised per trial in v3.}
#'   \item{item_number}{Stimulus index within the trial (1-3: word,
#'     orientation, colour).}
#'   \item{expe_phase}{Task phase, e.g. tutorial/training/test.}
#' }
#'
#' **Stimulus content and response**
#' \describe{
#'   \item{target_word, target_angle, target_color_angle, target_color}{
#'     The to-be-remembered stimulus for this item.}
#'   \item{response_word, response_angle, response_color_angle,
#'     response_color}{Participant's recall response.}
#'   \item{diff_word, diff_angle, diff_color}{Error/distance between target
#'     and response.}
#'   \item{rt_word, rt_angle, rt_color}{Response times.}
#'   \item{score_word, score_angle, score_color, trial_score}{Per-modality
#'     and combined trial scores.}
#'   \item{parity_1_stim, parity_1_resp, parity_1_acc, parity_1_rt,
#'     parity_2_stim, parity_2_resp, parity_2_acc, parity_2_rt}{The two
#'     parity-judgement distractor trials embedded in this trial: stimulus
#'     shown, response given, accuracy, response time. v2/v3 only carry a
#'     real parity-error penalty in the task design; the columns exist for
#'     v1 too but the penalty was not applied at recall.}
#' }
#'
#' **Questionnaire scores** (raw items are in the nested list-columns below,
#' not here)
#' \describe{
#'   \item{vviq_total_score}{VVIQ (Vividness of Visual Imagery
#'     Questionnaire) total score.}
#'   \item{vviq_group_2}{Aphantasia/typical-imager split at VVIQ = 32.}
#'   \item{vviq_group_4}{Four-level VVIQ grouping: `== 16` / `<= 32` /
#'     `33-74` / `>= 75`.}
#'   \item{nieq_mental_imagery, nieq_inner_voice, nieq_emotions,
#'     nieq_sensory_focus, nieq_unsymbolised}{NIEQ dimension scores, each
#'     the mean of that dimension's frequency and proportion items.}
#'   \item{object_mean, spatial_mean, verbal_mean}{OSIVQ subscale means.}
#' }
#'
#' **Demographics**
#' \describe{
#'   \item{age, gender, country, job, education, field, where_from}{
#'     Self-reported demographics.}
#'   \item{prognosis}{Self-reported aphantasia status/prognosis, where
#'     collected.}
#'   \item{treatment}{Self-reported relevant treatment. `NA` throughout for
#'     v3 (not asked in that version's demographics form).}
#'   \item{neuro_trouble}{Self-reported neurological condition. `NA`
#'     throughout for v3 (not asked in that version's demographics form).}
#' }
#'
#' **Nested item list-columns** (one list-column per participant/row-group;
#' unnest with [tidyr::unnest()] to get raw items - see Details)
#' \describe{
#'   \item{vviq_items}{Raw VVIQ item responses.}
#'   \item{osivq_items}{Raw OSIVQ item responses.}
#'   \item{nieq_items}{Raw NIEQ item responses (frequency and proportion
#'     items per dimension).}
#'   \item{strategy_items}{Raw free-text/categorical strategy-report
#'     answers.}
#'   \item{extra_demographics}{Additional demographic items not promoted to
#'     top-level columns (e.g. native/usual language).}
#' }
#'
#' @details
#' The nested list-columns hold version-specific raw item sets under shared
#' list-column names - v1/v2 and v3 don't ask exactly the same raw
#' questionnaire items (different item naming from different front-end
#' versions), so the raw items are kept nested rather than forced into a
#' common wide schema. The *scored* columns above the nested section
#' (`vviq_total_score`, `nieq_*`, `object_mean`/`spatial_mean`/
#' `verbal_mean`, etc.) are computed the same way across all three versions
#' and are directly comparable.
#'
#' A few columns used only for cleaning and exclusion review
#' (`is_complete`, `is_on_mobile`, `met_issues`, `issues`,
#' `used_external_support`, `what_external_support`, `gave_false_info`,
#' `what_false_info`) have already been applied and removed before this
#' object was built; see `data-raw/review/final_decisions.csv` for the
#' record of who was excluded and why.
#'
#' @source Built by the scripts in `data-raw/`, from CFA-WM v1/v2 data
#'   provided by `aphantasiaStudiesData` and CFA-WM v3 raw JATOS export.
#'   See `data-raw/README.md` for the full pipeline.
"all_data"
