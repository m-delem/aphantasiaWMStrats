#' Working memory strategies experiment (CFA-WM) combined dataset (v1, v2, v3)
#'
#' Stimulus-level data from the CFA-WM working memory task (word/orientation/
#' colour recall under a parity-judgement distractor), combining all three
#' study versions into one tibble. One row per **item**, where an item is one
#' word shown at one orientation in one colour. Three items make up a
#' **trial**, the encode-distract-recall cycle: 21 test trials and therefore
#' 63 items per participant, plus training and one tutorial trial. Built from raw/processed data by the
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
#' @format A tibble with one row per item and the following columns:
#'
#' **Identifiers and version**
#' \describe{
#'   \item{id}{Participant identifier.}
#'   \item{version}{Study version: `"v1"`, `"v2"`, or `"v3"`.}
#'   \item{language}{UI language of the experiment in the browser.}
#' }
#'
#' **Trial and item structure**
#' \describe{
#'   \item{trial_number}{Trial index. 21 test trials in three blocks of
#'     seven, numbered 1-21, preceded by 3 training trials numbered 1-3 and
#'     one tutorial trial numbered 0.}
#'   \item{response_order}{Order in which the three response modalities were
#'     collected for this trial, e.g. `"word_angle_color"`. Fixed in v1/v2
#'     (always word/angle/colour); randomised per trial in v3.}
#'   \item{item_number}{Item index, running 1-63 across the three test
#'     blocks (1-21, 22-42, 43-63) and 1-9 in training. Three items per
#'     trial; an item row carries all three features, not one of them.}
#'   \item{expe_phase}{Task phase, e.g. tutorial/training/test.}
#' }
#'
#' **Stimulus content and response**
#' \describe{
#'   \item{target_word, target_angle, target_color_angle, target_color}{
#'     The to-be-remembered stimulus for this item.}
#'   \item{response_word, response_angle, response_color_angle,
#'     response_color}{Participant's recall response.}
#'   \item{rt_word, rt_angle, rt_color}{Response times.}
#'   \item{parity_1_stim, parity_1_resp, parity_1_acc, parity_1_rt,
#'     parity_2_stim, parity_2_resp, parity_2_acc, parity_2_rt}{The two
#'     parity-judgement distractor probes embedded in this trial: stimulus
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
#'   \item{prognosis}{Free-text self-report on aphantasia status, never
#'     collected.}
#'   \item{treatment}{Self-reported relevant treatment. `NA` throughout for
#'     v3 (not asked in that version's demographics form).}
#'   \item{neuro_trouble}{Self-reported neurological condition. `NA`
#'     throughout for v3 (not asked in that version's demographics form).}
#' }
#'
#' **Live feedback from the task display - NOT analytical variables**
#' (see Details for why, and what to use instead)
#' \describe{
#'   \item{live_diff_word, live_diff_angle, live_diff_color}{Front-end
#'     dissimilarity between target and response, **0 = identical, 1 =
#'     maximally different**. Note this is the opposite direction from the
#'     `score_*` columns, which are similarities. Stimulus-level, rounded to
#'     2 decimals in the front end. `live_diff_word` is **not a valid edit
#'     distance** - see Details.}
#'   \item{feedback_score_word, feedback_score_angle,
#'     feedback_score_color}{Per-modality points shown on the feedback
#'     screen, thresholded from the corresponding `live_diff_*` value.
#'     Stimulus-level. Take values 0, 0.5, 1.}
#'   \item{feedback_trial_score}{Points shown for the whole trial: the sum of
#'     the three per-modality scores, minus 0.5 per incorrect parity
#'     judgement, floored at 0. Trial-level, i.e. constant across the three
#'     item rows of a trial. The parity penalty is applied in v2/v3 only.}
#'   \item{feedback_total_score_word, feedback_total_score_angle,
#'     feedback_total_score_color, feedback_total_score}{Cumulative points
#'     shown at the end of the task. Participant-level, i.e. constant across
#'     all of a participant's rows within a version.}
#' }
#'
#' **Nested item list-columns** (one list-column per participant/row-group;
#' unnest with [tidyr::unnest()] to get raw items - see Details)
#' \describe{
#'   \item{vviq_items}{Raw VVIQ item responses.}
#'   \item{osivq_items}{Raw OSIVQ item responses. **Reverse-keyed items
#'     are stored inconsistently across versions**: v1 and v2 store
#'     `osivq_q02v`, `osivq_q09v`, `osivq_q41v` and `osivq_q42s`
#'     *unreversed*, while v3 stores them already reversed. The
#'     `object_mean`/`spatial_mean`/`verbal_mean` columns are correct in
#'     both cases; only these nested items differ. Recomputing subscale
#'     scores or reliabilities from these items without reversing them for
#'     v1/v2 gives wrong answers - Cronbach's alpha for the verbal
#'     subscale comes out at 0.25 rather than 0.84.}
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
#' The `live_diff_*` and `feedback_*` columns exist only to drive the
#' in-task feedback screen participants saw between trials. They are kept for
#' provenance and reproducibility, not for analysis, and are placed last
#' among the atomic columns to make that visible. Three reasons not to use
#' them:
#'
#' 1. **`live_diff_word` is not an edit distance.** The front end's
#'    `levenshteinDistance()` (`js/jspsych/utils.js`) contains a defective
#'    loop - `for (let i = 0; (i = 0); i--)`, whose condition is an
#'    assignment and therefore always falsy - so the first column of its
#'    dynamic-programming matrix is never initialised. Deleting a prefix of
#'    the target costs nothing, and the function returns a value that is
#'    systematically lower than the true Levenshtein distance (in 313 of 8496
#'    non-tutorial rows it differs; it is never higher). `feedback_score_word`
#'    inherits this, since it is thresholded from `live_diff_word`.
#' 2. **They mix three granularities** under one prefix: item, trial and
#'    participant, as noted per column above.
#' 3. **Tutorial rows carry placeholders, not computed values.** For every
#'    `expe_phase == "tutorial"` row all three `live_diff_*` are exactly 1
#'    and all `feedback_score_*` are exactly 0, regardless of what the
#'    participant actually did - the front end hardcodes these because
#'    tutorial performance is not scored.
#'
#' Non-responses are also sentinel-encoded rather than `NA`: an empty
#' `response_word`, a `response_color_angle` of 999 (with `response_color`
#' `"#AAAAAA"`), and a `response_angle` of exactly 90, which is the
#' orientation widget's untouched starting position rather than an explicit
#' marker. The `live_diff_*` values treat all three as ordinary responses.
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
