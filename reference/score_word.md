# Word-recall similarity (Gonthier 2022 edit-distance scoring)

`similarity = (nchar(target) - min(DL, nchar(target))) / nchar(target)`,
where `DL` is the Damerau-Levenshtein distance between the normalised
target and response. Bounded \[0, 1\] and floored at 0 by construction:
the cap on `DL` before subtraction prevents a negative score when the
response is longer than the target.

## Usage

``` r
score_word(target, response)
```

## Arguments

- target, response:

  Character vectors of equal length.

## Value

Numeric vector in \[0, 1\].

## Details

Two deliberate departures from the task's live feedback: the denominator
is `nchar(target)` alone rather than
`max(nchar(target), nchar(response))`, and the metric is
Damerau-Levenshtein rather than plain Levenshtein. Note that the
live-feedback column `live_diff_word` is not a valid edit distance at
all, so this is not a refinement of it — see
[all_data](https://m-delem.github.io/aphantasiaWMStrats/reference/all_data.md).

**Scope caveat.** Gonthier's method is developed and validated for
serial span tasks, where a trial's target and response are each a
sequence of several stimuli encoded as one string. WM-FTT compares one
target word to one recalled word. The distance computation transfers
directly; the validation does not cover this exact use.

An empty response scores 0 by construction, which is why non-responses
need no special case for this feature (unlike colour — see
[`compute_scores()`](https://m-delem.github.io/aphantasiaWMStrats/reference/compute_scores.md)).
