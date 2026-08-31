# Versions: which one the analyses use, and why

The WM-FTT ran in three versions, and the [task
design](https://m-delem.github.io/aphantasiaWMStrats/articles/task-design.md)
page explains why each replaced the last; the
[participants](https://m-delem.github.io/aphantasiaWMStrats/articles/participants.md)
page describes who took part in each. This page answers a narrower
question with a consequence for everything after it: **which versions
enter the inferential analyses.**

As of 2026-09-03, the answer is **v1 only**. Every modelling page on
this site inherits that restriction, and that rule may change (e.g., if
v3 ever recruits a bigger sample) so the reasoning deserves its own page
that can be checked from anywhere. All versions are kept in `all_data`,
described in the package, and available to anyone. The pipeline built on
v1 is a template to be re-applied when the later versions have the
sample to support it.

``` r

block_trials <- all_data |>
  dplyr::filter(grepl("^expe_block", expe_phase))

by_participant <- block_trials |>
  dplyr::summarise(
    imagery_group = dplyr::first(vviq_group_2),
    vviq = dplyr::first(vviq_total_score),
    non_response_word = 1 - mean(responded_word),
    non_response_orientation = 1 - mean(responded_angle),
    non_response_colour = 1 - mean(responded_color),
    .by = c(id, version)
  )
```

## 1. The versions are not interchangeable samples

Pooling would be reasonable if the three versions were the same task run
three times. They are not: each changed the task in a way that could
plausibly change behaviour, and they recruited different populations.

``` r

by_participant |>
  dplyr::mutate(imagery_group = dplyr::coalesce(as.character(imagery_group),
                                                "no VVIQ")) |>
  dplyr::count(version, imagery_group) |>
  tidyr::pivot_wider(names_from = imagery_group, values_from = n,
                     values_fill = 0L) |>
  knitr::kable(caption = "Participants by version and imagery group")
```

| version | aphantasia | no VVIQ | typical |
|:--------|-----------:|--------:|--------:|
| v1      |         31 |       2 |      55 |
| v2      |          8 |       0 |       1 |
| v3      |         17 |       0 |       4 |

Participants by version and imagery group {.table}

**Group balance is the decisive number.** v1 is 31 aphantasic to 55
typical imagers. v2 is 8 to 1, and v3 is 17 to 4 (as of 2026-09-03). In
v2 and v3 a group comparison is not merely underpowered: with one and
four typical imagers respectively, it is structurally impossible. No
amount of modelling recovers a contrast that the recruitment never
sampled.

The later versions are also aphantasia-heavy *because* no recruitment in
the general population had been conducted yet, only targeted
communication in aphantasia communities.

## 2. Pooling can create spurious results

Non-response differs sharply by version.

``` r

by_participant |>
  dplyr::summarise(
    dplyr::across(tidyselect::starts_with("non_response_"), mean),
    .by = version
  ) |>
  dplyr::arrange(version) |>
  knitr::kable(digits = 3, caption = "Mean non-response rate by version")
```

| version | non_response_word | non_response_orientation | non_response_colour |
|:--------|------------------:|-------------------------:|--------------------:|
| v1      |             0.080 |                    0.136 |               0.067 |
| v2      |             0.141 |                    0.325 |               0.196 |
| v3      |             0.170 |                    0.370 |               0.150 |

Mean non-response rate by version {.table}

v3 has roughly three times v1’s orientation non-response. It is also
heavily aphantasic — 17 of its 21 participants, against 31 of 88 in v1.
Those two facts together are enough to create an association between
imagery and non-response in a pooled sample where none exists within any
version. (v2 is more aphantasic still in proportion, at 8 of 9, but with
nine participants it moves a pooled estimate very little; v3 has both
the composition and the weight.)

``` r

propensity <- by_participant |>
  dplyr::filter(!is.na(vviq))

dplyr::bind_rows(
  dplyr::mutate(
    correlation_test(propensity$non_response_orientation, propensity$vviq),
    sample = "Pooled"),
  propensity |>
    dplyr::group_split(version) |>
    purrr::map(\(d) dplyr::mutate(
      correlation_test(d$non_response_orientation, d$vviq),
      sample = dplyr::first(d$version))) |>
    purrr::list_rbind()
) |>
  dplyr::select(sample, n, rho, p) |>
  knitr::kable(digits = 3,
               caption = "Orientation non-response against VVIQ, pooled and within version")
```

| sample |   n |    rho |     p |
|:-------|----:|-------:|------:|
| Pooled | 116 | -0.291 | 0.002 |
| v1     |  86 | -0.091 | 0.406 |
| v2     |   9 | -0.124 | 0.750 |
| v3     |  21 | -0.672 | 0.001 |

Orientation non-response against VVIQ, pooled and within version
{.table}

Pooled, the association looks clear and significant. Within v1, which is
74% of the participants, it is absent. The pooled estimate is a mixture
of strata rather than an effect, and the version that drives it is the
one with 21 participants.

This is the concrete reason behind the scoping decision. Pooling here
produced a finding that stratification removed.

## 3. v1 is also the cleanest sample, not just the largest

``` r

v1 <- dplyr::filter(by_participant, version == "v1")

v1_scores <- block_trials |>
  dplyr::filter(version == "v1") |>
  compose_features(id) |>
  dplyr::left_join(dplyr::select(v1, id, vviq), by = "id")

dplyr::bind_rows(
  dplyr::mutate(correlation_test(v1_scores$mean_word, v1_scores$vviq),
                feature = "Word"),
  dplyr::mutate(correlation_test(v1_scores$mean_angle, v1_scores$vviq),
                feature = "Orientation"),
  dplyr::mutate(correlation_test(v1_scores$mean_color, v1_scores$vviq),
                feature = "Colour")
) |>
  dplyr::select(feature, n, rho, p) |>
  knitr::kable(digits = 3,
               caption = "v1 only: responders-only recall accuracy against VVIQ")
```

| feature     |   n |    rho |     p |
|:------------|----:|-------:|------:|
| Word        |  86 | -0.003 | 0.981 |
| Orientation |  85 |  0.229 | 0.035 |
| Colour      |  86 |  0.173 | 0.110 |

v1 only: responders-only recall accuracy against VVIQ {.table}

Orientation has one participant fewer than the other two features: one
person answered **zero** orientation items, so they have no
responders-only mean to correlate. They are not missing at random, and
the [joint
model](https://m-delem.github.io/aphantasiaWMStrats/articles/joint-model.md)
is the analysis that can see them.

Analysed on its own, v1 gives an interpretable pattern. The [task
validity](https://m-delem.github.io/aphantasiaWMStrats/articles/task-validity.md)
page covers what those associations do and do not support.

There is a second, quieter argument. Per-version standardisation needs
each version to be able to carry its own scale, and v2 cannot. Drop one
participant at a time, re-standardise, and see how far everyone else’s
z-score moves:

``` r

# How much does one participant's presence move everyone else's z-score?
leave_one_out_shift <- function(x) {
  x <- x[!is.na(x)]
  full <- as.numeric(scale(x))
  purrr::map_dbl(seq_along(x), function(i) {
    without <- as.numeric(scale(x[-i]))
    max(abs(without - full[-i]))
  })
}

block_trials |>
  compose_features(id, version) |>
  dplyr::filter(stats::complete.cases(dplyr::pick(tidyselect::starts_with("mean_")))) |>
  dplyr::summarise(
    participants = dplyr::n(),
    median_shift = stats::median(leave_one_out_shift(mean_angle)),
    max_shift = max(leave_one_out_shift(mean_angle)),
    .by = version
  ) |>
  dplyr::arrange(version) |>
  knitr::kable(digits = 3,
               caption = "Largest z-score shift caused by removing one participant, orientation")
```

| version | participants | median_shift | max_shift |
|:--------|-------------:|-------------:|----------:|
| v1      |           87 |        0.028 |     0.437 |
| v2      |            9 |        0.137 |     0.634 |
| v3      |           21 |        0.058 |     0.284 |

Largest z-score shift caused by removing one participant, orientation
{.table}

v2’s median shift is roughly five times v1’s: on nine participants, one
person’s presence routinely moves everyone else’s z-score by an
appreciable fraction of a standard deviation. That is not a scale, and
it is why standardising within version was abandoned.

## 4. What this means for every other page

- **All modelling pages are v1 only.** v1 has 88 participants; no model
  uses all of them, because each applies further filters for vividness,
  engagement or questionnaire completeness. [The
  analysis](https://m-delem.github.io/aphantasiaWMStrats/articles/analysis-strategy.html#strat-samples)
  lists every resulting sample in one table.
- **v2 and v3 are described, not modelled.** They appear in `all_data`,
  in the
  [codebook](https://m-delem.github.io/aphantasiaWMStrats/articles/codebook.md),
  and in descriptive comparisons.
- **Version is treated as a structural feature, not a nuisance
  covariate.** Adding a version term to a pooled model would assume the
  versions differ by an additive constant, which section 2 shows is
  exactly what they do not do.
- **The restriction is a sample size, not a methodological ceiling.**
  The same pipeline applies to v3 once it recruits, and it is written to
  be re-run rather than rewritten.

## 5. What the excluded versions are still for

v3 retains one job it uniquely enables. **v1 has a fixed recall order**,
word then orientation then colour, so feature differences there are
confounded with output position. v3 randomised the order, and it is the
only version that can estimate that effect. Any claim about differences
between features carries that caveat, and v3 is where it can be checked.

The choice of v1 has two costs. **v1 has no parity penalty**, so the
distractor there was free, which shapes what the [task
engagement](https://m-delem.github.io/aphantasiaWMStrats/articles/engagement.md)
page can conclude. And **v1 has the lowest non-response of the three
versions**, so it is the version where declining to report is least
common, which is worth remembering when reading how much weight that
behaviour carries.

------------------------------------------------------------------------

**Continuing through the Extended Online Report:** this page follows
[task
engagement](https://m-delem.github.io/aphantasiaWMStrats/articles/engagement.md).
To keep reading in order, continue to [task
validity](https://m-delem.github.io/aphantasiaWMStrats/articles/task-validity.md)
next. Or skip ahead to [the
analysis](https://m-delem.github.io/aphantasiaWMStrats/articles/analysis-strategy.md),
which explains what the modelling pages do and why.

------------------------------------------------------------------------

    #> ─ Session info ───────────────────────────────────────────────────────────────
    #>  setting  value
    #>  version  R version 4.6.1 (2026-06-24)
    #>  os       Ubuntu 22.04.5 LTS
    #>  system   x86_64, linux-gnu
    #>  ui       X11
    #>  language en
    #>  collate  C.UTF-8
    #>  ctype    C.UTF-8
    #>  tz       UTC
    #>  date     2026-08-31
    #>  pandoc   3.8.3 @ /opt/hostedtoolcache/pandoc/3.8.3/x64/ (via rmarkdown)
    #>  quarto   NA
    #> 
    #> ─ Packages ───────────────────────────────────────────────────────────────────
    #>  package            * version date (UTC) lib source
    #>  aphantasiaWMStrats * 0.1     2026-08-31 [1] local
    #>  bslib                0.12.0  2026-08-04 [2] CRAN (R 4.6.1)
    #>  cachem               1.1.0   2024-05-16 [2] CRAN (R 4.6.1)
    #>  cli                  3.6.6   2026-04-09 [2] CRAN (R 4.6.1)
    #>  crayon               1.5.3   2024-06-20 [2] CRAN (R 4.6.1)
    #>  curl                 8.0.0   2026-08-25 [2] CRAN (R 4.6.1)
    #>  desc                 1.4.3   2023-12-10 [2] CRAN (R 4.6.1)
    #>  digest               0.6.39  2025-11-19 [2] CRAN (R 4.6.1)
    #>  dplyr                1.2.1   2026-04-03 [2] CRAN (R 4.6.1)
    #>  evaluate             1.0.5   2025-08-27 [2] CRAN (R 4.6.1)
    #>  farver               2.1.2   2024-05-13 [2] CRAN (R 4.6.1)
    #>  fastmap              1.2.0   2024-05-15 [2] CRAN (R 4.6.1)
    #>  fs                   2.1.0   2026-04-18 [2] CRAN (R 4.6.1)
    #>  generics             0.1.4   2025-05-09 [2] CRAN (R 4.6.1)
    #>  ggplot2            * 4.0.3   2026-04-22 [2] CRAN (R 4.6.1)
    #>  glue                 1.8.1   2026-04-17 [2] CRAN (R 4.6.1)
    #>  gtable               0.3.6   2024-10-25 [2] CRAN (R 4.6.1)
    #>  htmltools            0.5.9   2025-12-04 [2] CRAN (R 4.6.1)
    #>  jquerylib            0.1.4   2021-04-26 [2] CRAN (R 4.6.1)
    #>  jsonlite             2.0.0   2025-03-27 [2] CRAN (R 4.6.1)
    #>  knitr                1.51    2025-12-20 [2] CRAN (R 4.6.1)
    #>  lifecycle            1.0.5   2026-01-08 [2] CRAN (R 4.6.1)
    #>  magrittr             2.0.5   2026-04-04 [2] CRAN (R 4.6.1)
    #>  otel                 0.2.0   2025-08-29 [2] CRAN (R 4.6.1)
    #>  pillar               1.11.1  2025-09-17 [2] CRAN (R 4.6.1)
    #>  pkgconfig            2.0.3   2019-09-22 [2] CRAN (R 4.6.1)
    #>  pkgdown              2.2.1   2026-07-07 [2] any (@2.2.1)
    #>  purrr                1.2.2   2026-04-10 [2] CRAN (R 4.6.1)
    #>  R6                   2.6.1   2025-02-15 [2] CRAN (R 4.6.1)
    #>  ragg                 1.5.2   2026-03-23 [2] CRAN (R 4.6.1)
    #>  RColorBrewer         1.1-3   2022-04-03 [2] CRAN (R 4.6.1)
    #>  renv                 1.0.7   2024-04-11 [2] RSPM (R 4.6.1)
    #>  rlang                1.3.0   2026-07-05 [2] CRAN (R 4.6.1)
    #>  rmarkdown            2.31    2026-03-26 [2] CRAN (R 4.6.1)
    #>  S7                   0.2.2   2026-04-22 [2] CRAN (R 4.6.1)
    #>  sass                 0.4.10  2025-04-11 [2] CRAN (R 4.6.1)
    #>  scales               1.4.0   2025-04-24 [2] CRAN (R 4.6.1)
    #>  sessioninfo          1.2.4   2026-06-04 [2] CRAN (R 4.6.1)
    #>  showtext             0.9-8   2026-03-21 [2] CRAN (R 4.6.1)
    #>  showtextdb           3.0     2020-06-04 [2] CRAN (R 4.6.1)
    #>  sysfonts             0.8.9   2024-03-02 [2] CRAN (R 4.6.1)
    #>  systemfonts          1.3.2   2026-03-05 [2] CRAN (R 4.6.1)
    #>  textshaping          1.0.5   2026-03-06 [2] CRAN (R 4.6.1)
    #>  tibble               3.3.1   2026-01-11 [2] CRAN (R 4.6.1)
    #>  tidyr                1.3.2   2025-12-19 [2] CRAN (R 4.6.1)
    #>  tidyselect           1.2.1   2024-03-11 [2] CRAN (R 4.6.1)
    #>  vctrs                0.7.3   2026-04-11 [2] CRAN (R 4.6.1)
    #>  withr                3.0.3   2026-06-19 [2] CRAN (R 4.6.1)
    #>  xfun                 0.60    2026-07-09 [2] CRAN (R 4.6.1)
    #>  yaml                 2.3.12  2025-12-10 [2] CRAN (R 4.6.1)
    #> 
    #>  [1] /tmp/RtmpTZJzeG/temp_libpath83f725132ca2
    #>  [2] /home/runner/.cache/R/renv/library/aphantasiaWMStrats-f7ce8556/linux-ubuntu-jammy/R-4.6/x86_64-pc-linux-gnu
    #>  [3] /home/runner/.cache/R/renv/sandbox/linux-ubuntu-jammy/R-4.6/x86_64-pc-linux-gnu/e7c0fad7
    #>  * ── Packages attached to the search path.
    #> 
    #> ──────────────────────────────────────────────────────────────────────────────
