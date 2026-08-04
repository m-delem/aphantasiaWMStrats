# -----------------------------------------------------------------------
# 05_export_data_and_doc_to_osf.R
#
# Builds two shareable exports from `all_data` (all_data_surveys,
# all_data_full, see Part A) and a codebook describing both of them
# (Part B), then pushes the data files and machine-readable codebook to
# CFA-WM's OSF component (3649s), in a "v3 Data/Processed data" sub-folder
# (created if it doesn't exist yet) (Part C).
#
# NOT produced or pushed by this script: codebook.pdf. codebook.md is
# written to data-raw/ to render into a PDF by hand, and the PDF is uploaded
# separately via the OSF web UI once it exists. This script only pushes what
# it can build unattended.
#
# -----------------------------------------------------------------------
# Part A: build the two export datasets
# -----------------------------------------------------------------------
# all_data_surveys: one row per participant. All trial/stimulus-level
#   columns dropped, de-duplicated to one row per id/version. The nested
#   item list-columns (vviq_items, osivq_items, nieq_items,
#   strategy_items, extra_demographics) are unnested wide with
#   tidyr::unnest_wider(), which matches by name rather than position,
#   required because osivq_items' raw item order differs between v1/v2
#   and v3 (same 34 items, different order), so a position-based unnest would
#   silently misalign columns.
#
#   One expected artefact of the wide unnest: strategy_items has 12 raw
#   items for v1/v2 (*_scoring_strat_{1,2,3}_1) but only 11 for v3
#   (*_scoring_strat_{1,2}, no third position). After unnesting, the v1/v2-only
#   column (strats_cfa_q04_scoring_strat_3_1) is NA for every v3 row.
#
# all_data_full - all_data at full stimulus-level granularity (one row
#   per stimulus), with the five nested list-columns dropped entirely
#   (not unnested: repeating ~113 participant-level questionnaire-item
#   columns across every stimulus row would bloat the file for no
#   analytic benefit, that data belongs in all_data_surveys above).
#   Otherwise all_data as shipped by the package, unmodified.
# -----------------------------------------------------------------------
devtools::load_all()

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
  all_data |>
  dplyr::select(!tidyselect::all_of(trial_level_cols)) |>
  dplyr::distinct(id, version, .keep_all = TRUE) |>
  tidyr::unnest_wider(vviq_items) |>
  tidyr::unnest_wider(osivq_items) |>
  tidyr::unnest_wider(nieq_items) |>
  tidyr::unnest_wider(strategy_items) |>
  tidyr::unnest_wider(extra_demographics)

stopifnot(
  nrow(all_data_surveys) ==
    nrow(dplyr::distinct(all_data, id, version))
)

all_data_full <-
  all_data |>
  dplyr::select(!tidyselect::all_of(nested_cols))

# -----------------------------------------------------------------------
# Part B: codebook for all_data_surveys and all_data_full
# -----------------------------------------------------------------------
# Same two-format output: machine-readable Psych-DS dataset_description.json +
# human-readable codebook.md, but covering two datasets instead of one, since
# that's what's shared on OSF (all_data itself, stimulus-level with nested
# list-columns, isn't something OSF visitors without the package can use
# directly. Its own, lighter documentation lives in
# vignettes/articles/codebook.Rmd on the EOR instead).
# -----------------------------------------------------------------------

dataset_info <- list(
  name = "CFA-WM working memory strategies data (v1/v2/v3), participant- and stimulus-level exports",
  description = paste(
    "Data from the CFA-WM working memory task (word/orientation/colour",
    "recall under a parity-judgement distractor), pooled across three",
    "task versions (v1 original, v2 added a parity-error penalty, v3",
    "added recall-order randomisation). Two datasets are described here:",
    "all_data_surveys (one row per participant: demographics,",
    "questionnaire scores, and raw questionnaire/strategy items) and",
    "all_data_full (one row per stimulus: trial structure, targets,",
    "responses, timing, and per-trial scores; no questionnaire item",
    "detail, see all_data_surveys for that)."
  ),
  sources = c(
    "CFA-WM v1/v2/v3, Mael Delem, EMC Lab, Universite Lumiere Lyon 2"
  ),
  instrument_sources = c(
    "VVIQ item text: Marks, D. F. (1973). Visual imagery differences in the recall of pictures. British Journal of Psychology, 64(1), 17-24. https://doi.org/10.1111/j.2044-8295.1973.tb01322.x",
    "OSIVQ item text: Blazhenkova, O., & Kozhevnikov, M. (2009). The new object-spatial-verbal cognitive style model: Theory and measurement. Applied Cognitive Psychology, 23(5), 638-663. https://doi.org/10.1002/acp.1473",
    "NIEQ item text: Heavey, C. L., Moynihan, S. A., Brouwers, V. P., Lapping-Carr, L., Krumm, A. E., Kelsey, J. M., Turner, D. K., & Hurlburt, R. T. (2019). Measuring the frequency of inner-experience characteristics by self-report: The Nevada Inner Experience Questionnaire. Frontiers in Psychology, 9, 2615. https://doi.org/10.3389/fpsyg.2018.02615"
  ),
  copyright_note = paste(
    "VVIQ, OSIVQ, and NIEQ item wording is copyrighted by the original",
    "scale authors and is not reproduced here. Item columns below are",
    "identified by their official item number/dimension; consult the",
    "source publications above for exact wording."
  )
)

# -----------------------------------------------------------------------
# B1. all_data_surveys variables: core (non-item) columns
# -----------------------------------------------------------------------

surveys_core_variables <- list(

  list(
    name = "id",
    description = "Participant identifier, unique within a version.",
    dataType = "string"
  ),

  list(
    name = "version",
    description = "CFA-WM task version.",
    dataType = "string",
    levels = c(
      v1 = "Original task version",
      v2 = "Added a parity-error penalty to recall scoring",
      v3 = "Added recall-order randomisation; independent front-end infrastructure"
    ),
    levelsOrdered = TRUE
  ),

  list(
    name = "language",
    description = "UI language of the experiment in the browser.",
    dataType = "string",
    levels = c(en = "English", fr = "French"),
    levelsOrdered = FALSE
  ),

  list(
    name = "age",
    description = "Participant age in years, self-reported.",
    dataType = "integer",
    unitText = "years",
    minValue = 18,
    maxValue = 71
  ),

  list(
    name = "gender",
    description = "Gender, as freely typed by the participant.",
    dataType = "string",
    notes = paste(
      "Free text, not a controlled vocabulary; values include both short",
      "codes (\"f\", \"m\") and longer self-descriptions in French and",
      "English (e.g. \"Non-binaire\", \"female/agender\"). Left as-is",
      "rather than collapsed into fixed categories, since collapsing",
      "would lose information some participants specifically chose to",
      "add. No missing values in the current data."
    )
  ),

  list(
    name = "vviq_total_score",
    description = paste(
      "Total score on the Vividness of Visual Imagery Questionnaire",
      "(VVIQ; Marks, 1973), summed across all 16 items (see vviq_q01-",
      "vviq_q16 below). Lower scores indicate weaker/absent visual",
      "imagery."
    ),
    dataType = "integer",
    minValue = 16,
    maxValue = 80,
    notes = "Missing for 2 participants (of 116)."
  ),

  list(
    name = "vviq_group_2",
    description = "Categorical VVIQ group with 2 levels, based on standard VVIQ cutoff.",
    dataType = "string",
    levels = c(
      aphantasia = "VVIQ <= 32 (aphantasia and hypophantasia collapsed)",
      typical    = "VVIQ > 32 (typical and hyperphantasia collapsed)"
    ),
    levelsOrdered = TRUE
  ),

  list(
    name = "vviq_group_4",
    description = "Categorical VVIQ group with 4 levels, based on standard VVIQ cutoffs.",
    dataType = "string",
    levels = c(
      aphantasia     = "VVIQ = 16 (complete absence of visual imagery)",
      hypophantasia  = "VVIQ 17-32 (reduced visual imagery)",
      typical        = "VVIQ 33-74 (typical visual imagery)",
      hyperphantasia = "VVIQ 75-80 (extremely vivid visual imagery)"
    ),
    levelsOrdered = TRUE
  ),

  list(
    name = "nieq_mental_imagery",
    description = paste(
      "Nevada Inner Experience Questionnaire (NIEQ; Heavey et al., 2019)",
      "mental imagery dimension score: mean of the frequency and",
      "proportion items for this dimension (see nieq_freq_mental_imagery",
      "/ nieq_prop_mental_imagery in the nested item columns)."
    ),
    dataType = "float",
    minValue = 0,
    maxValue = 100,
    notes = "No missing values."
  ),

  list(
    name = "nieq_inner_voice",
    description = "NIEQ inner voice/speaking dimension score (mean of frequency and proportion items).",
    dataType = "float",
    minValue = 0,
    maxValue = 100,
    notes = "No missing values."
  ),

  list(
    name = "nieq_emotions",
    description = "NIEQ feelings/emotions dimension score (mean of frequency and proportion items).",
    dataType = "float",
    minValue = 0,
    maxValue = 100,
    notes = "No missing values."
  ),

  list(
    name = "nieq_sensory_focus",
    description = "NIEQ sensory awareness dimension score (mean of frequency and proportion items).",
    dataType = "float",
    minValue = 0,
    maxValue = 100,
    notes = "No missing values."
  ),

  list(
    name = "nieq_unsymbolised",
    description = "NIEQ unsymbolized thinking dimension score (mean of frequency and proportion items).",
    dataType = "float",
    minValue = 0,
    maxValue = 100,
    notes = "No missing values."
  ),

  list(
    name = "object_mean",
    description = "OSIVQ (Blazhenkova & Kozhevnikov, 2009) object-imagery subscale mean.",
    dataType = "float",
    minValue = 1,
    maxValue = 4.64,
    notes = "Missing for 2 participants (same 2 as vviq_total_score)."
  ),

  list(
    name = "spatial_mean",
    description = "OSIVQ spatial-imagery subscale mean.",
    dataType = "float",
    minValue = 1,
    maxValue = 5,
    notes = "Missing for 2 participants (same 2 as vviq_total_score)."
  ),

  list(
    name = "verbal_mean",
    description = "OSIVQ verbal cognitive-style subscale mean.",
    dataType = "float",
    minValue = 1,
    maxValue = 5,
    notes = "Missing for 2 participants (same 2 as vviq_total_score)."
  ),

  list(
    name = "total_score_word",
    description = "Participant's total word-recall score, summed across all trials.",
    dataType = "float",
    minValue = 6,
    maxValue = 70.5
  ),

  list(
    name = "total_score_angle",
    description = "Participant's total orientation-recall score, summed across all trials.",
    dataType = "float",
    minValue = 0,
    maxValue = 64.5
  ),

  list(
    name = "total_score_color",
    description = "Participant's total colour-recall score, summed across all trials.",
    dataType = "float",
    minValue = 5,
    maxValue = 64
  ),

  list(
    name = "total_score",
    description = "Participant's combined total recall score across all modalities and trials.",
    dataType = "float",
    minValue = 11.5,
    maxValue = 195.5
  ),

  list(
    name = "prognosis",
    description = "Self-reported aphantasia status/prognosis, where collected.",
    dataType = "string",
    levels = c(no = "No", yes = "Yes"),
    levelsOrdered = FALSE
  ),

  list(
    name = "neuro_trouble",
    description = "Self-reported neurological condition, freely typed.",
    dataType = "string",
    notes = paste(
      "Free text (French), not a controlled vocabulary, e.g. \"TDAH\",",
      "\"TSA\", \"depression suite a un burnout\". NA throughout for v3",
      "(not asked in that version's demographics form); collected for",
      "v1/v2 only."
    )
  ),

  list(
    name = "treatment",
    description = "Self-reported relevant treatment.",
    dataType = "string",
    levels = c(no = "No", yes = "Yes"),
    levelsOrdered = FALSE,
    notes = "NA throughout for v3 (not asked in that version's demographics form); collected for v1/v2 only."
  )
)

# -----------------------------------------------------------------------
# B2. all_data_surveys: VVIQ item columns (vviq_q01-vviq_q16)
# -----------------------------------------------------------------------

vviq_scenes <- c(
  "a relative or friend you often see",
  "the rising sun",
  "the front of a familiar shop",
  "a country scene with trees, mountains, and a lake"
)

surveys_vviq_items <- lapply(1:16, function(i) {
  scene_index <- ceiling(i / 4)
  list(
    name = sprintf("vviq_q%02d", i),
    description = paste0(
      "VVIQ item ", i, " of 16, from the scene \"", vviq_scenes[scene_index],
      "\" (items ", (scene_index - 1) * 4 + 1, "-", scene_index * 4,
      " share this scene). Item wording not reproduced; see Marks (1973)."
    ),
    dataType = "integer",
    minValue = 1,
    maxValue = 5,
    notes = paste(
      "1 = perfectly clear and as vivid as normal vision;",
      "5 = no image at all. Missing for 2 participants overall."
    )
  )
})

# -----------------------------------------------------------------------
# B3. all_data_surveys: OSIVQ item columns
# -----------------------------------------------------------------------
# Item order in the raw data differs between v1/v2 and v3: the columns
# below are named as they appear in all_data_surveys after unnest_wider(),
# which matches by name, not position, so v1/v2 and v3 responses to the
# same item land in the same column regardless of the order the raw front
# end presented them in.

osivq_scale_of <- function(item_name) {
  suffix <- substr(item_name, nchar(item_name), nchar(item_name))
  switch(suffix,
    o = "Object",
    s = "Spatial",
    v = "Verbal",
    stop("Unexpected OSIVQ item suffix: ", suffix)
  )
}

osivq_item_names <- c(
  "osivq_q01s", "osivq_q02v", "osivq_q04v", "osivq_q05s", "osivq_q06o",
  "osivq_q07s", "osivq_q08v", "osivq_q09v", "osivq_q11o", "osivq_q12o",
  "osivq_q13o", "osivq_q14s", "osivq_q16v", "osivq_q17s", "osivq_q18o",
  "osivq_q20o", "osivq_q23o", "osivq_q26o", "osivq_q27s", "osivq_q29o",
  "osivq_q30s", "osivq_q31s", "osivq_q32s", "osivq_q33o", "osivq_q34o",
  "osivq_q35v", "osivq_q37v", "osivq_q39v", "osivq_q40o", "osivq_q41v",
  "osivq_q42s", "osivq_q43o", "osivq_q44s", "osivq_q45o"
)

surveys_osivq_items <- lapply(osivq_item_names, function(nm) {
  list(
    name = nm,
    description = paste0(
      "OSIVQ item, ", osivq_scale_of(nm), " scale. Item wording not ",
      "reproduced; see Blazhenkova & Kozhevnikov (2009)."
    ),
    dataType = "integer",
    minValue = 1,
    maxValue = 5,
    notes = "1 = totally disagree; 5 = totally agree. Missing for 2 participants overall."
  )
})

surveys_osivq_scores <- list(
  list(
    name = "object_score",
    description = "OSIVQ object-imagery subscale sum (raw item sum; object_mean above is its mean).",
    dataType = "integer", minValue = 14, maxValue = 65,
    notes = "Missing for 2 participants overall."
  ),
  list(
    name = "spatial_score",
    description = "OSIVQ spatial-imagery subscale sum (raw item sum; spatial_mean above is its mean).",
    dataType = "integer", minValue = 11, maxValue = 55,
    notes = "Missing for 2 participants overall."
  ),
  list(
    name = "verbal_score",
    description = "OSIVQ verbal cognitive-style subscale sum (raw item sum; verbal_mean above is its mean).",
    dataType = "integer", minValue = 12, maxValue = 45,
    notes = "Missing for 2 participants overall."
  ),
  list(
    name = "o_count", description = "Number of object-scale items answered (out of 11).",
    dataType = "integer", notes = "Diagnostic/completion count, not a score."
  ),
  list(
    name = "s_count", description = "Number of spatial-scale items answered (out of 11).",
    dataType = "integer", notes = "Diagnostic/completion count, not a score."
  ),
  list(
    name = "v_count", description = "Number of verbal-scale items answered (out of 12).",
    dataType = "integer", notes = "Diagnostic/completion count, not a score."
  )
)

# -----------------------------------------------------------------------
# B4. all_data_surveys: NIEQ item columns
# -----------------------------------------------------------------------
# Each dimension has 2 raw items (frequency, proportion), both 0-100
# sliders; the dimension score above is their mean.

nieq_dimensions <- c(
  "mental_imagery" = "Mental imagery",
  "inner_voice"    = "Inner voice/speaking",
  "emotions"       = "Feelings/emotions",
  "sensory_focus"  = "Sensory awareness",
  "unsymbolised"   = "Unsymbolized thinking"
)

surveys_nieq_items <- unlist(lapply(names(nieq_dimensions), function(dim_key) {
  label <- nieq_dimensions[[dim_key]]
  list(
    list(
      name = paste0("nieq_freq_", dim_key),
      description = paste0(
        "NIEQ ", label, " dimension, frequency item (how often this ",
        "type of inner experience occurs). Item wording not ",
        "reproduced; see Heavey et al. (2019)."
      ),
      dataType = "integer", minValue = 0, maxValue = 100,
      notes = "0-100 slider. No missing values."
    ),
    list(
      name = paste0("nieq_prop_", dim_key),
      description = paste0(
        "NIEQ ", label, " dimension, proportion item (what proportion ",
        "of inner experience this type makes up). Item wording not ",
        "reproduced; see Heavey et al. (2019)."
      ),
      dataType = "integer", minValue = 0, maxValue = 100,
      notes = "0-100 slider. No missing values."
    )
  )
}), recursive = FALSE)

# -----------------------------------------------------------------------
# B5. all_data_surveys: strategy report columns
# -----------------------------------------------------------------------
# Mixed shape: q01/q02/q03 (v1/v2) hold
# free-text French strategy descriptions, of varying length and
# specificity; q04_scoring_strat_* (v3 only, plus a legacy v1/v2
# duplicate at _1_1/_2_1/_3_1) holds a controlled coded vocabulary.
# Coded columns list their vocabulary, free-text columns don't.

surveys_strategy_free_text <- list(
  list(
    name = "strats_cfa_q01_colors_1", dataType = "string",
    description = "Free-text (mostly French) self-reported strategy for remembering colours, first mention.",
    notes = "Free text, not a controlled vocabulary - collected in v1/v2 only. See strats_cfa_q04_scoring_strat_* below for v3's coded strategy report."
  ),
  list(
    name = "strats_cfa_q01_colors_2", dataType = "string",
    description = "Free-text self-reported strategy for remembering colours, second mention (optional follow-up).",
    notes = "Free text. Collected in v1/v2 only. Mostly missing (optional field)."
  ),
  list(
    name = "strats_cfa_q01_colors_3", dataType = "string",
    description = "Free-text self-reported strategy for remembering colours, third mention (optional follow-up).",
    notes = "Free text. Collected in v1/v2 only. Mostly missing (optional field)."
  ),
  list(
    name = "strats_cfa_q02_orientations_1", dataType = "string",
    description = "Free-text self-reported strategy for remembering orientations, first mention.",
    notes = "Free text, not a controlled vocabulary - collected in v1/v2 only."
  ),
  list(
    name = "strats_cfa_q02_orientations_2", dataType = "string",
    description = "Free-text self-reported strategy for remembering orientations, second mention (optional follow-up).",
    notes = "Free text. Collected in v1/v2 only. Mostly missing (optional field)."
  ),
  list(
    name = "strats_cfa_q02_orientations_3", dataType = "string",
    description = "Free-text self-reported strategy for remembering orientations, third mention (optional follow-up).",
    notes = "Free text. Collected in v1/v2 only. Mostly missing (optional field)."
  ),
  list(
    name = "strats_cfa_q03_words_1", dataType = "string",
    description = "Free-text self-reported strategy for remembering words, first mention.",
    notes = "Free text, not a controlled vocabulary - collected in v1/v2 only."
  ),
  list(
    name = "strats_cfa_q03_words_2", dataType = "string",
    description = "Free-text self-reported strategy for remembering words, second mention (optional follow-up).",
    notes = "Free text. Collected in v1/v2 only. Mostly missing (optional field)."
  ),
  list(
    name = "strats_cfa_q03_words_3", dataType = "string",
    description = "Free-text self-reported strategy for remembering words, third mention (optional follow-up).",
    notes = "Free text. Collected in v1/v2 only. Mostly missing (optional field)."
  )
)

strategy_coded_levels <- c(
  repetition       = "Repeated the stimulus (aloud or mentally)",
  semantic         = "Formed a semantic association or link",
  none             = "No particular strategy used",
  spatial_body     = "Used body movement/position as a memory aid",
  spatial_cardinal = "Used a cardinal/directional spatial strategy",
  words            = "Focused on the word component",
  colours          = "Focused on the colour component",
  orientations     = "Focused on the orientation component",
  mental_image     = "Formed a mental image"
)

surveys_strategy_coded <- list(
  list(
    name = "strats_cfa_q04_scoring_strat_1", dataType = "string",
    description = "Coded self-reported memorisation strategy, first choice.",
    levels = strategy_coded_levels, levelsOrdered = FALSE,
    notes = "Collected in v3 only (as strats_cfa_q04_scoring_strat_1; the _1_1 column below is a v1/v2 field with a different naming convention, not the same question re-asked)."
  ),
  list(
    name = "strats_cfa_q04_scoring_strat_2", dataType = "string",
    description = "Coded self-reported memorisation strategy, second choice.",
    levels = strategy_coded_levels, levelsOrdered = FALSE,
    notes = "Collected in v3 only."
  ),
  list(
    name = "strats_cfa_q04_scoring_strat_1_1", dataType = "string",
    description = "Coded self-reported memorisation strategy, v1/v2's equivalent first-choice field.",
    levels = strategy_coded_levels, levelsOrdered = FALSE,
    notes = "Collected in v1/v2 only (NA for all v3 rows)."
  ),
  list(
    name = "strats_cfa_q04_scoring_strat_2_1", dataType = "string",
    description = "Coded self-reported memorisation strategy, v1/v2's equivalent second-choice field.",
    levels = strategy_coded_levels, levelsOrdered = FALSE,
    notes = "Collected in v1/v2 only (NA for all v3 rows). Sparsely populated even within v1/v2 (optional field)."
  ),
  list(
    name = "strats_cfa_q04_scoring_strat_3_1", dataType = "string",
    description = "Coded self-reported memorisation strategy, v1/v2's equivalent third-choice field.",
    levels = strategy_coded_levels, levelsOrdered = FALSE,
    notes = paste(
      "Collected in v1/v2 only; v3 has no third slot for this field",
      "(NA for all v3 rows - this is a real structural difference, not",
      "missing data). Rarely populated even within v1/v2: non-missing",
      "for only 7 of 88 v1 participants and 0 of 9 v2 participants."
    )
  )
)

# -----------------------------------------------------------------------
# B6. all_data_surveys: extra demographics
# -----------------------------------------------------------------------

surveys_extra_demographics <- list(
  list(
    name = "country", dataType = "string",
    description = "Self-reported country of residence (free text/country code, not standardised)."
  ),
  list(
    name = "job", dataType = "string",
    description = "Self-reported occupation, using the ESEG occupational classification codes where applicable."
  ),
  list(
    name = "education", dataType = "string",
    description = "Self-reported education level, using ISCED classification codes where applicable."
  ),
  list(
    name = "field", dataType = "string",
    description = "Self-reported field of study or work, free text."
  ),
  list(
    name = "where_from", dataType = "string",
    description = "Self-reported source of how the participant heard about the study."
  ),
  list(
    name = "language_native", dataType = "string",
    description = "Participant's self-reported native language."
  ),
  list(
    name = "language_usual", dataType = "string",
    description = "Participant's self-reported language of everyday use, where different from native language."
  )
)

surveys_all_variables <- c(
  surveys_core_variables, surveys_vviq_items, surveys_osivq_items,
  surveys_osivq_scores, surveys_nieq_items, surveys_strategy_free_text,
  surveys_strategy_coded, surveys_extra_demographics
)

# -----------------------------------------------------------------------
# B7. all_data_full variables (trial/stimulus-level)
# -----------------------------------------------------------------------
# Documented at the same depth as all_data_surveys.
# id/version/language/age/gender/vviq_total_score/vviq_group_2/
# vviq_group_4/nieq_*/object_mean/spatial_mean/verbal_mean repeat from
# all_data_surveys above (same participant-level values, just repeated
# per stimulus row here), not redefined a second time; documented once
# with a pointer instead, to avoid the two variable lists silently
# drifting apart.

full_repeated_columns_note <- paste(
  "id, version, language, age, gender, vviq_total_score, vviq_group_2,",
  "vviq_group_4, nieq_mental_imagery, nieq_inner_voice, nieq_emotions,",
  "nieq_sensory_focus, nieq_unsymbolised, object_mean, spatial_mean,",
  "and verbal_mean are the same participant-level columns described in",
  "all_data_surveys above, repeated on every stimulus row for this",
  "participant. See all_data_surveys for their descriptions, ranges,",
  "and missingness."
)

full_variables <- list(

  list(
    name = "expe_phase", dataType = "string",
    description = "Task phase this stimulus belongs to.",
    levels = c(
      tutorial     = "Single practice trial with feedback",
      training     = "Practice trials, no feedback",
      expe_block_1 = "Test block 1",
      expe_block_2 = "Test block 2",
      expe_block_3 = "Test block 3"
    ),
    levelsOrdered = TRUE
  ),

  list(
    name = "trial_number", dataType = "integer",
    description = "Trial index (1 tutorial + 3 training + 21 test trials per participant)."
  ),

  list(
    name = "response_order", dataType = "string",
    description = "Order in which the three response modalities (word/angle/colour) were collected for this trial.",
    levels = c(
      word_angle_color = "Word, then angle, then colour",
      word_color_angle = "Word, then colour, then angle",
      angle_word_color = "Angle, then word, then colour",
      angle_color_word = "Angle, then colour, then word",
      color_word_angle = "Colour, then word, then angle",
      color_angle_word = "Colour, then angle, then word"
    ),
    levelsOrdered = FALSE,
    notes = "Fixed at word_angle_color in v1/v2 (always that order); randomised per trial in v3, so all 6 permutations appear."
  ),

  list(
    name = "item_number", dataType = "integer",
    description = "Stimulus index within the trial (1-3: word, orientation, colour)."
  ),

  list(
    name = "target_word", dataType = "string",
    description = "The to-be-remembered word for this stimulus."
  ),
  list(
    name = "target_angle", dataType = "integer",
    description = "The to-be-remembered rectangle orientation, in degrees."
  ),
  list(
    name = "target_color_angle", dataType = "float",
    description = "The to-be-remembered colour, as an angle on the colour wheel used for continuous colour report."
  ),
  list(
    name = "target_color", dataType = "string",
    description = "The to-be-remembered colour, as its nearest named colour."
  ),

  list(
    name = "response_word", dataType = "string",
    description = "Participant's recalled word."
  ),
  list(
    name = "response_angle", dataType = "float",
    description = "Participant's recalled rectangle orientation, in degrees."
  ),
  list(
    name = "response_color_angle", dataType = "integer",
    description = "Participant's recalled colour, as an angle on the colour wheel."
  ),
  list(
    name = "response_color", dataType = "string",
    description = "Participant's recalled colour, as its nearest named colour."
  ),

  list(
    name = "diff_word", dataType = "float",
    description = "Word recall error (string-distance based; 0 = exact match)."
  ),
  list(
    name = "diff_angle", dataType = "float",
    description = "Angular error between target and response orientation, in degrees."
  ),
  list(
    name = "diff_color", dataType = "float",
    description = "Angular error between target and response colour on the colour wheel."
  ),

  list(
    name = "rt_word", dataType = "integer", unitText = "ms",
    description = "Response time for the word recall response."
  ),
  list(
    name = "rt_angle", dataType = "float", unitText = "ms",
    description = "Response time for the orientation recall response."
  ),
  list(
    name = "rt_color", dataType = "float", unitText = "ms",
    description = "Response time for the colour recall response."
  ),

  list(
    name = "score_word", dataType = "float",
    description = "Per-modality recall score for the word response, derived from diff_word."
  ),
  list(
    name = "score_angle", dataType = "float",
    description = "Per-modality recall score for the orientation response, derived from diff_angle."
  ),
  list(
    name = "score_color", dataType = "float",
    description = "Per-modality recall score for the colour response, derived from diff_color."
  ),
  list(
    name = "trial_score", dataType = "float",
    description = "Combined recall score for this stimulus's trial, across all three modalities."
  ),

  list(
    name = "parity_1_stim", dataType = "integer",
    description = "First of the two parity-judgement distractor digits embedded in this trial."
  ),
  list(
    name = "parity_1_resp", dataType = "string",
    description = "Participant's parity judgement (odd/even) for parity_1_stim."
  ),
  list(
    name = "parity_1_acc", dataType = "integer",
    description = "Accuracy of the first parity judgement (1 = correct, 0 = incorrect)."
  ),
  list(
    name = "parity_1_rt", dataType = "integer", unitText = "ms",
    description = "Response time for the first parity judgement."
  ),
  list(
    name = "parity_2_stim", dataType = "integer",
    description = "Second of the two parity-judgement distractor digits embedded in this trial."
  ),
  list(
    name = "parity_2_resp", dataType = "string",
    description = "Participant's parity judgement (odd/even) for parity_2_stim."
  ),
  list(
    name = "parity_2_acc", dataType = "integer",
    description = "Accuracy of the second parity judgement (1 = correct, 0 = incorrect)."
  ),
  list(
    name = "parity_2_rt", dataType = "integer", unitText = "ms",
    description = "Response time for the second parity judgement."
  ),

  list(
    name = "total_score_word", dataType = "float",
    description = "Participant's total word-recall score, summed across all trials."
  ),
  list(
    name = "total_score_angle", dataType = "float",
    description = "Participant's total orientation-recall score, summed across all trials."
  ),
  list(
    name = "total_score_color", dataType = "float",
    description = "Participant's total colour-recall score, summed across all trials."
  ),
  list(
    name = "total_score", dataType = "float",
    description = "Participant's combined total recall score across all modalities and trials."
  ),

  list(
    name = "prognosis", dataType = "string",
    description = "Self-reported aphantasia status/prognosis, where collected.",
    levels = c(no = "No", yes = "Yes"), levelsOrdered = FALSE
  ),
  list(
    name = "neuro_trouble", dataType = "string",
    description = "Self-reported neurological condition, freely typed.",
    notes = "Free text (French), not a controlled vocabulary. NA throughout for v3."
  ),
  list(
    name = "treatment", dataType = "string",
    description = "Self-reported relevant treatment.",
    levels = c(no = "No", yes = "Yes"), levelsOrdered = FALSE,
    notes = "NA throughout for v3."
  )
)

# -----------------------------------------------------------------------
# B8. Render: Psych-DS dataset_description.json (both datasets)
# -----------------------------------------------------------------------

variable_to_property_value <- function(v) {
  pv <- list(
    `@type` = "PropertyValue",
    name = v$name,
    description = v$description
  )

  if (!is.null(v$dataType)) pv$dataType <- v$dataType
  if (!is.null(v$unitText)) pv$unitText <- v$unitText
  if (!is.null(v$minValue)) pv$minValue <- v$minValue
  if (!is.null(v$maxValue)) pv$maxValue <- v$maxValue

  if (!is.null(v$levels)) {
    pv$levels <- as.list(v$levels)
    pv$levelsOrdered <- isTRUE(v$levelsOrdered)
  }

  if (!is.null(v$notes)) pv$notes <- v$notes

  pv
}

write_json_codebook <- function(
    surveys_variables, full_variables, full_repeated_note,
    dataset_info, path
) {
  doc <- list(
    `@context` = "https://schema.org/",
    `@type` = "Dataset",
    name = dataset_info$name,
    description = dataset_info$description,
    schemaVersion = "Psych-DS 0.4.0",
    citation = as.list(dataset_info$sources),
    creditText = as.list(dataset_info$instrument_sources),
    usageInfo = dataset_info$copyright_note,
    hasPart = list(
      list(
        `@type` = "Dataset",
        name = "all_data_surveys",
        description = "One row per participant: demographics, questionnaire scores, and raw questionnaire/strategy items.",
        variableMeasured = lapply(surveys_variables, variable_to_property_value)
      ),
      list(
        `@type` = "Dataset",
        name = "all_data_full",
        description = paste(
          "One row per stimulus: trial structure, targets, responses,",
          "timing, and per-trial scores.", full_repeated_note
        ),
        variableMeasured = lapply(full_variables, variable_to_property_value)
      )
    )
  )

  json_text <- jsonlite::toJSON(doc, auto_unbox = TRUE, pretty = TRUE, null = "null")
  writeLines(json_text, path)
  invisible(json_text)
}

# -----------------------------------------------------------------------
# B9. Render: human-readable Markdown codebook (both datasets)
# -----------------------------------------------------------------------

md_escape <- function(x) {
  if (is.null(x)) return("")
  x <- gsub("\\|", "\\\\|", x)
  x <- gsub("\\r?\\n", " ", x)
  x
}

format_levels_md <- function(levels) {
  if (is.null(levels)) return("")
  paste(
    sprintf("`%s` = %s", names(levels), md_escape(unname(levels))),
    collapse = "; "
  )
}

format_range_md <- function(v) {
  if (!is.null(v$minValue) && !is.null(v$maxValue)) {
    unit <- if (!is.null(v$unitText)) paste0(" ", v$unitText) else ""
    return(sprintf("%s-%s%s", v$minValue, v$maxValue, unit))
  }
  ""
}

md_table_rows <- function(vars) {
  rows <- vapply(vars, function(v) {
    levels_txt <- format_levels_md(v$levels)
    range_txt <- format_range_md(v)
    notes_txt <- if (!is.null(v$notes)) md_escape(v$notes) else ""
    extra <- trimws(paste(
      c(levels_txt, notes_txt)[c(levels_txt, notes_txt) != ""],
      collapse = " -- "
    ))

    sprintf(
      "| `%s` | %s | %s | %s | %s |",
      v$name, md_escape(v$description), v$dataType, range_txt, extra
    )
  }, character(1))
  paste(rows, collapse = "\n")
}

write_markdown_codebook <- function(
    surveys_core, surveys_vviq, surveys_osivq, surveys_osivq_sc,
    surveys_nieq, surveys_strat_free, surveys_strat_coded, surveys_demo,
    full_vars, full_repeated_note, dataset_info, path
) {

  header <- c(
    paste0("# Codebook: ", dataset_info$name),
    "",
    dataset_info$description,
    "",
    "## Sources",
    "",
    paste0("- ", dataset_info$sources),
    "",
    "## Instrument references and copyright notice",
    "",
    dataset_info$copyright_note,
    "",
    paste0("- ", dataset_info$instrument_sources),
    "",
    "# Dataset 1: `all_data_surveys` (one row per participant)",
    "",
    "## Core variables",
    "",
    "| Variable | Description | Type | Range | Levels / notes |",
    "|---|---|---|---|---|",
    md_table_rows(surveys_core),
    "",
    "## VVIQ item-level responses (`vviq_q01`-`vviq_q16`)",
    "",
    paste(
      "The VVIQ has no subscales; its 16 items are grouped into 4",
      "scenes of 4 items each, each rated 1 (perfectly clear and",
      "vivid) to 5 (no image at all). Item wording is not reproduced",
      "here for copyright reasons -- see Marks (1973)."
    ),
    "",
    "| Variable | Description | Type | Range | Notes |",
    "|---|---|---|---|---|",
    md_table_rows(surveys_vviq),
    "",
    "## OSIVQ item-level responses",
    "",
    paste(
      "34 items rated 1 (totally disagree) to 5 (totally agree),",
      "across three scales (Object, Spatial, Verbal). Item order in",
      "the raw front-end data differs between v1/v2 and v3; the",
      "columns here are named consistently across both after",
      "unnesting by name (not position). Item wording is not",
      "reproduced here for copyright reasons -- see Blazhenkova &",
      "Kozhevnikov (2009)."
    ),
    "",
    "| Variable | Description | Type | Range | Notes |",
    "|---|---|---|---|---|",
    md_table_rows(surveys_osivq),
    "",
    "### OSIVQ subscale sums and item-completion counts",
    "",
    "| Variable | Description | Type | Range | Notes |",
    "|---|---|---|---|---|",
    md_table_rows(surveys_osivq_sc),
    "",
    "## NIEQ item-level responses",
    "",
    paste(
      "5 dimensions (mental imagery, inner voice/speaking,",
      "feelings/emotions, sensory awareness, unsymbolized thinking),",
      "each with 2 raw items (frequency, proportion), both 0-100",
      "sliders. Item wording is not reproduced here for copyright",
      "reasons -- see Heavey et al. (2019)."
    ),
    "",
    "| Variable | Description | Type | Range | Notes |",
    "|---|---|---|---|---|",
    md_table_rows(surveys_nieq),
    "",
    "## Strategy report, free text (`strats_cfa_q01`-`q03`)",
    "",
    paste(
      "Free-text self-reported memorisation strategies, mostly in",
      "French, collected in v1/v2 only. Not a controlled vocabulary --",
      "no level list is given, as one wouldn't meaningfully summarise",
      "free text."
    ),
    "",
    "| Variable | Description | Type | Range | Notes |",
    "|---|---|---|---|---|",
    md_table_rows(surveys_strat_free),
    "",
    "## Strategy report, coded (`strats_cfa_q04_scoring_strat_*`)",
    "",
    paste(
      "Controlled vocabulary, collected primarily in v3",
      "(`strats_cfa_q04_scoring_strat_1`/`_2`); v1/v2 has an",
      "equivalent field with a different naming convention",
      "(`_1_1`/`_2_1`/`_3_1`)."
    ),
    "",
    "| Variable | Description | Type | Range | Levels / notes |",
    "|---|---|---|---|---|",
    md_table_rows(surveys_strat_coded),
    "",
    "## Additional demographics",
    "",
    "| Variable | Description | Type | Range | Notes |",
    "|---|---|---|---|---|",
    md_table_rows(surveys_demo),
    "",
    "# Dataset 2: `all_data_full` (one row per stimulus)",
    "",
    full_repeated_note,
    "",
    "| Variable | Description | Type | Range | Levels / notes |",
    "|---|---|---|---|---|",
    md_table_rows(full_vars),
    ""
  )

  writeLines(header, path)
  invisible(header)
}

write_json_codebook(
  surveys_all_variables, full_variables, full_repeated_columns_note,
  dataset_info, "data-raw/dataset_description.json"
)
write_markdown_codebook(
  surveys_core_variables, surveys_vviq_items, surveys_osivq_items,
  surveys_osivq_scores, surveys_nieq_items, surveys_strategy_free_text,
  surveys_strategy_coded, surveys_extra_demographics,
  full_variables, full_repeated_columns_note,
  dataset_info, "data-raw/codebook.md"
)

cat("Wrote dataset_description.json and codebook.md\n")
cat("codebook.md is NOT rendered to PDF automatically: render it",
    "yourself, then upload codebook.pdf to OSF by hand.\n")

# -----------------------------------------------------------------------
# Part C: write local export files and push to OSF
# -----------------------------------------------------------------------

library(osfr)

# osf_auth("ThIsIsNoTaReAlPATbUtYoUgEtIt")

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

# json is written straight to data-raw/ above (B8); copy it into the
# export dir too, so a single osf_upload() glob covers everything
# pushed in this run.
fs::file_copy(
  here::here("data-raw/dataset_description.json"),
  fs::path(export_dir, "dataset_description.json"),
  overwrite = TRUE
)

# Mirrors the download-direction osfr pattern used in
# 01_import_v1v2_osf.R/02_import_v3_raw.R, in reverse. Navigates to the
# existing "v3 Data" folder, then creates "Processed data" under it if
# it doesn't already exist.

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
osf_upload(
  processed_data_folder,
  path = fs::path(export_dir, "dataset_description.json"),
  conflicts = "overwrite"
)

message(
  "Uploaded all_data_surveys.{csv,xlsx}, all_data_full.{csv,xlsx}, and ",
  "dataset_description.json to component 3649s, v3 Data/Processed ",
  "data. codebook.pdf NOT uploaded: render data-raw/codebook.md ",
  "yourself and upload it by hand via the OSF web UI."
)
