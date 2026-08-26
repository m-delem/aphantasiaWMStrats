# The questionnaire scales, in one participant-level frame

Pulls the nine scale scores out of the stimulus-level data and returns
one row per participant.

**Pooled across task versions, deliberately.** Every argument in
`05-version-scope.md` for restricting to v1 is about task comparability:
group balance for a behavioural contrast, non-response rates differing
three-fold, per-version standardisation being unstable. None of it
touches a questionnaire score. The instruments are identical and were
administered identically in all three versions, so version is a property
of the task rather than of the scales, and pooling recovers roughly a
third more participants for the one analysis in this project that most
needs them.

What pooling does change is the *composition* of the sample: later
recruitment targeted aphantasics, so the pooled sample is about a third
floor-group where v1 is a quarter. Any clustering fitted on it should be
checked against a v1-only fit before its labels are used downstream. See
[`cluster_stability()`](https://m-delem.github.io/aphantasiaWMStrats/reference/cluster_stability.md).

## Usage

``` r
questionnaire_scales(data, complete_only = TRUE)
```

## Arguments

- data:

  Stimulus-level data, typically `all_data`.

- complete_only:

  Drop participants missing any scale. Clustering needs complete cases,
  so this defaults to `TRUE`.

## Value

A tibble with one row per participant.
