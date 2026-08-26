# Package index

## Data

The pooled, stimulus-level CFA-WM working memory dataset (v1/v2/v3) and
its accessor.

- [`all_data`](https://m-delem.github.io/aphantasiaWMStrats/reference/all_data.md)
  : Working memory strategies experiment (CFA-WM) combined dataset (v1,
  v2, v3)
- [`get_data()`](https://m-delem.github.io/aphantasiaWMStrats/reference/get_data.md)
  : Get CFA-WM data, optionally filtered by version

## Data preparation

Functions used once to compute the final scores used for later analyses.

- [`compute_scores()`](https://m-delem.github.io/aphantasiaWMStrats/reference/compute_scores.md)
  : Compute WM-FTT recall scores
- [`score_angular()`](https://m-delem.github.io/aphantasiaWMStrats/reference/score_angular.md)
  : Angular similarity via cosine
- [`score_word()`](https://m-delem.github.io/aphantasiaWMStrats/reference/score_word.md)
  : Word-recall similarity (Gonthier 2022 edit-distance scoring)
- [`normalise_word()`](https://m-delem.github.io/aphantasiaWMStrats/reference/normalise_word.md)
  : Normalise a string for edit-distance comparison
- [`damerau_levenshtein()`](https://m-delem.github.io/aphantasiaWMStrats/reference/damerau_levenshtein.md)
  : Damerau-Levenshtein distance (optimal string alignment)

## Compositional analysis

Building the three-part relative-allocation composition and moving it
off the simplex into ILR coordinates.

- [`compose_features()`](https://m-delem.github.io/aphantasiaWMStrats/reference/compose_features.md)
  : Responders-only compositional parts
- [`ilr_coords()`](https://m-delem.github.io/aphantasiaWMStrats/reference/ilr_coords.md)
  : Isometric log-ratio coordinates for a three-part composition
- [`engaged_ids()`](https://m-delem.github.io/aphantasiaWMStrats/reference/engaged_ids.md)
  : Participants clearing the engagement thresholds
- [`wm_thresholds()`](https://m-delem.github.io/aphantasiaWMStrats/reference/wm_thresholds.md)
  : Minimum responded items per feature

## Modelling

Shared Bayesian fitting defaults and posterior reporting, matching the
`aphantasiaEmotions` package, plus the model specifications themselves.
Formulas and priors are exported so that a script and a vignette use the
same object: models are loaded with `file_refit = "never"`, and brms
does not check that the formula it is handed matches the one the cached
fit was built with.

- [`fit_brms_model()`](https://m-delem.github.io/aphantasiaWMStrats/reference/fit_brms_model.md)
  : Fit a Bayesian model using the brms package with default settings
- [`report_rope()`](https://m-delem.github.io/aphantasiaWMStrats/reference/report_rope.md)
  : Summarise posterior draws against a ROPE
- [`joint_formula()`](https://m-delem.github.io/aphantasiaWMStrats/reference/joint_formula.md)
  : The joint propensity and accuracy model
- [`joint_priors()`](https://m-delem.github.io/aphantasiaWMStrats/reference/joint_priors.md)
  : Priors for the joint model
- [`performance_formula()`](https://m-delem.github.io/aphantasiaWMStrats/reference/performance_formula.md)
  : The per-feature performance model
- [`composition_formula()`](https://m-delem.github.io/aphantasiaWMStrats/reference/composition_formula.md)
  : The compositional model
- [`composition_priors()`](https://m-delem.github.io/aphantasiaWMStrats/reference/composition_priors.md)
  : Priors for the compositional model
- [`response_priors()`](https://m-delem.github.io/aphantasiaWMStrats/reference/response_priors.md)
  : Coefficient-wise priors for one response
- [`feature_family()`](https://m-delem.github.io/aphantasiaWMStrats/reference/feature_family.md)
  : Response families used for each recall feature
- [`squeeze_boundaries()`](https://m-delem.github.io/aphantasiaWMStrats/reference/squeeze_boundaries.md)
  : Smithson-Verkuilen squeeze
- [`lkj_marginal()`](https://m-delem.github.io/aphantasiaWMStrats/reference/lkj_marginal.md)
  : Marginal prior on a single correlation under an LKJ prior

## Analysis helpers

Quantities computed identically by the working scripts and by the
vignettes that report them.

- [`split_half_reliability()`](https://m-delem.github.io/aphantasiaWMStrats/reference/split_half_reliability.md)
  : Split-half reliability of a per-feature score
- [`spearman_brown()`](https://m-delem.github.io/aphantasiaWMStrats/reference/spearman_brown.md)
  : Spearman-Brown correction
- [`correlation_test()`](https://m-delem.github.io/aphantasiaWMStrats/reference/correlation_test.md)
  : Spearman correlation with its sample size
- [`cronbach_alpha()`](https://m-delem.github.io/aphantasiaWMStrats/reference/cronbach_alpha.md)
  : Cronbach's alpha
- [`mars_knots()`](https://m-delem.github.io/aphantasiaWMStrats/reference/mars_knots.md)
  : MARS knot search, on participant means
- [`composition_summary()`](https://m-delem.github.io/aphantasiaWMStrats/reference/composition_summary.md)
  : Descriptive summary of the compositional parts
- [`centred_correlations()`](https://m-delem.github.io/aphantasiaWMStrats/reference/centred_correlations.md)
  : Correlations between features after removing each participant's
  level
- [`partition_variance()`](https://m-delem.github.io/aphantasiaWMStrats/reference/partition_variance.md)
  : Variance carried by each ILR coordinate, under each partition
- [`posterior_correlations()`](https://m-delem.github.io/aphantasiaWMStrats/reference/posterior_correlations.md)
  : Participant-level correlations from a multivariate model

## Questionnaire structure

The exploratory strand: preparing the questionnaire scales for
clustering, and checking that a clustering means what it appears to.

- [`questionnaire_scales()`](https://m-delem.github.io/aphantasiaWMStrats/reference/questionnaire_scales.md)
  : The questionnaire scales, in one participant-level frame
- [`standardise_scales()`](https://m-delem.github.io/aphantasiaWMStrats/reference/standardise_scales.md)
  : Scale scores, standardised for combining
- [`add_imagery_composite()`](https://m-delem.github.io/aphantasiaWMStrats/reference/add_imagery_composite.md)
  : Collapse the imagery scales into one composite
- [`cluster_stability()`](https://m-delem.github.io/aphantasiaWMStrats/reference/cluster_stability.md)
  : Is a clustering of the pooled sample the same clustering of v1?
- [`adjusted_rand_index()`](https://m-delem.github.io/aphantasiaWMStrats/reference/adjusted_rand_index.md)
  : Adjusted Rand index

## Figures

The plotting identity shared with `aphantasiaEmotions`, plus the
composition-specific figures.

- [`theme_pdf()`](https://m-delem.github.io/aphantasiaWMStrats/reference/theme_pdf.md)
  : Theme for elegant scientific vector figures
- [`save_ggplot()`](https://m-delem.github.io/aphantasiaWMStrats/reference/save_ggplot.md)
  : Custom ggsave wrapper set with Nature's formatting guidelines
  (width-locked)
- [`scale_x_vviq()`](https://m-delem.github.io/aphantasiaWMStrats/reference/scale_x_vviq.md)
  : Custom x-axis scale for VVIQ scores
- [`scale_discrete_feature()`](https://m-delem.github.io/aphantasiaWMStrats/reference/scale_discrete_feature.md)
  : Custom discrete scale for the three WM-FTT features
- [`scale_x_aphantasia()`](https://m-delem.github.io/aphantasiaWMStrats/reference/scale_x_aphantasia.md)
  : Custom x-axis scale for imagery groups
- [`scale_discrete_aphantasia()`](https://m-delem.github.io/aphantasiaWMStrats/reference/scale_discrete_aphantasia.md)
  : Custom discrete scale for imagery groups
- [`scale_shape_aphantasia()`](https://m-delem.github.io/aphantasiaWMStrats/reference/scale_shape_aphantasia.md)
  : Custom shape scale for imagery groups
- [`plot_composition_ternary()`](https://m-delem.github.io/aphantasiaWMStrats/reference/plot_composition_ternary.md)
  : Ternary diagram of the three-part WM-FTT composition
- [`plot_composition_biplot()`](https://m-delem.github.io/aphantasiaWMStrats/reference/plot_composition_biplot.md)
  : Centred log-ratio biplot of the WM-FTT composition
- [`plot_split_half()`](https://m-delem.github.io/aphantasiaWMStrats/reference/plot_split_half.md)
  : Split-half reliability, per feature
- [`plot_floor_group()`](https://m-delem.github.io/aphantasiaWMStrats/reference/plot_floor_group.md)
  : Figure for a floor-group model
- [`plot_vviq_histogram()`](https://m-delem.github.io/aphantasiaWMStrats/reference/plot_vviq_histogram.md)
  : Marginal histogram of imagery vividness
