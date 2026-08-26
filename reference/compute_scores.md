# Compute WM-FTT recall scores

Adds raw and per-version-standardised similarity scores for the three
recalled features, plus response indicators, to a stimulus-level frame
such as
[all_data](https://m-delem.github.io/aphantasiaWMStrats/reference/all_data.md).
Scores are computed from raw target/response values rather than derived
from the front end's `live_diff_*` columns, which are display-only and,
for the word feature, not a valid edit distance (see
[all_data](https://m-delem.github.io/aphantasiaWMStrats/reference/all_data.md)).

## Usage

``` r
compute_scores(
  data,
  orientation_period = 180,
  colour_period = 360,
  no_response_angle = 90,
  no_response_colour = 999
)
```

## Arguments

- data:

  A stimulus-level data frame, e.g.
  [all_data](https://m-delem.github.io/aphantasiaWMStrats/reference/all_data.md).

- orientation_period, colour_period:

  Angular periods in degrees. See
  [`score_angular()`](https://m-delem.github.io/aphantasiaWMStrats/reference/score_angular.md)
  for why they differ.

- no_response_angle:

  Sentinel marking an untouched orientation widget.

- no_response_colour:

  Sentinel marking an untouched colour wheel.

## Value

`data` with the columns above appended.

## Columns added

- `score_word`, `score_angle`, `score_color` — raw similarity in \[0,
  1\], higher is better. Note the direction is **opposite** to the
  `live_diff_*` columns, which are dissimilarities.

- `score_word_z`, `score_angle_z`, `score_color_z` — the above, z-scored
  within `version`. Both are kept: raw for anything needing absolute
  performance, standardised for cross-feature comparison and clustering.
  Note that standardised scores cannot be used for any log-ratio
  transform, since roughly half of them are negative.

- `responded_word`, `responded_angle`, `responded_color` — logical.

- `responded_parity_1`, `responded_parity_2` — logical, added when the
  `parity_*_resp` columns are present. The parity accuracy columns use
  the same score-a-non-response-as-zero convention as recall, and in v1
  92% of their zeros are unanswered probes rather than errors, so any
  analysis of parity needs these flags. See
  [`flag_parity_responses()`](https://m-delem.github.io/aphantasiaWMStrats/reference/flag_parity_responses.md).

## Non-responses

The task encodes non-response with per-feature sentinels rather than
`NA`: an empty `response_word`, a `response_color_angle` of 999, and a
`response_angle` of exactly 90 (the orientation widget's untouched
starting position). These are scored **0** and flagged, rather than set
to `NA`, because non-response here is very unlikely to be
missing-at-random — a participant who skips colour is plausibly
reporting the absence of a colour representation, and `NA` would let
listwise deletion silently drop exactly those observations. Scoring 0
produces a visible distortion in the distribution instead of an
invisible one in the inference.

`responded_angle` is an **inference** (`response_angle != 90`), not an
observation, unlike the other two. Max `target_angle` is 61°, and no
block item has a target within 20° of 90°, so a 90° response is never
near-correct — but a genuine deliberate 90° cannot be distinguished from
an untouched slider.

## Standardisation moments

Means and SDs are computed on **experimental-block rows only**
(`expe_phase` matching `^expe_block`) and then applied to every row, so
that tutorial and training rows are scored on the same scale without
contributing to it. Tutorial rows carry hardcoded placeholder values in
the front end's own columns; their target/response values are real, so
they are scored here, but they should be filtered before any aggregate.
