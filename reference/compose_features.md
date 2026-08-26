# Responders-only compositional parts

Builds the three-part composition (word, orientation, colour) from
**responded items only**. Scores of 0 recorded for non-responses do not
measure allocation, they measure which features a participant declined.
That is a separate quantity, and mixing the two would make the
composition partly an index of who answered what. Non-response rates
differ by feature and, in the pooled data, by imagery group.

Grouping is left to the caller through `...`, which is what lets the
same function build participant-level compositions (`id`) and
trial-level ones (`id`, `trial_uid`).

## Usage

``` r
compose_features(data, ..., features = c("word", "angle", "color"))
```

## Arguments

- data:

  Item-level data.

- ...:

  Grouping columns, tidy-evaluated (e.g. `id`, or `id, trial_uid`).

- features:

  Feature stems, in the canonical order used throughout the package.

## Value

A tibble with the grouping columns, `n_word`/`n_angle`/`n_color`
(responded items contributing to each part), the raw responders-only
means `mean_*`, and the closed parts `part_*` summing to 1. Groups
missing a part entirely are returned with `NA` parts rather than
dropped, so the caller decides what to do with them.
