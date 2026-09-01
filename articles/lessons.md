# What was tried and withdrawn

Several findings on this site were reported at some point and are no
longer claimed. This page says what they were and what removed them.

Three of them were caught by the same move: **check whether a pooled
result holds within each version before reporting it.**

## 1. A two-way trade-off between colour and orientation

**Claimed:** the task was designed to force a three-way trade-off but
achieves a two-way one, because word is easy enough that participants
can max it and then divide effort between colour and orientation.
Supported by correlations between features after removing each
participant’s overall level.

**Withdrawn** when the same correlations were computed on participants
who clear the engagement thresholds:

``` r

v1 <- get_data("v1") |>
  dplyr::filter(grepl("^expe_block", expe_phase))

all_parts <- compose_features(v1, id)
all_parts <- all_parts[stats::complete.cases(all_parts), ]
engaged_parts <- dplyr::filter(all_parts, id %in% engaged_ids(v1))

feature_labels <- c(word = "Word", angle = "Orientation", color = "Colour")

knitr::kable(
  centred_correlations(all_parts, labels = feature_labels), digits = 3,
  caption = paste0("All participants with three parts (n = ",
                   nrow(all_parts), ")"))
```

|             |   Word | Orientation | Colour |
|:------------|-------:|------------:|-------:|
| Word        |  1.000 |      -0.612 | -0.211 |
| Orientation | -0.612 |       1.000 | -0.644 |
| Colour      | -0.211 |      -0.644 |  1.000 |

All participants with three parts (n = 87) {.table}

``` r


knitr::kable(
  centred_correlations(engaged_parts, labels = feature_labels), digits = 3,
  caption = paste0("Clearing the engagement thresholds (n = ",
                   nrow(engaged_parts), ")"))
```

|             |   Word | Orientation | Colour |
|:------------|-------:|------------:|-------:|
| Word        |  1.000 |      -0.457 | -0.489 |
| Orientation | -0.457 |       1.000 | -0.552 |
| Colour      | -0.489 |      -0.552 |  1.000 |

Clearing the engagement thresholds (n = 81) {.table}

Residualising three parts on their own mean induces a correlation near
-0.5 by construction, so that is the reference and not zero. On the
first table orientation and colour appear to trade off more strongly
than either does against word. On the second all three pairs sit close
to the closure baseline.

**The difference between the two tables is six participants**, all of
whom answered very few orientation items. The apparent trade-off
described them, not the task.

The [joint
model](https://m-delem.github.io/aphantasiaWMStrats/articles/joint-model.md)
later settled the question from the other direction: between people,
orientation and colour accuracy correlate **positively**. There is no
between-person trade-off for closure to have been hiding.

## 2. Reporting propensity is related to imagery vividness

**Claimed:** participants with lower imagery vividness decline to report
features more often, with a pooled correlation around -0.30.

**Withdrawn** when stratified by task version:

``` r

by_participant <- get_data() |>
  dplyr::filter(grepl("^expe_block", expe_phase)) |>
  dplyr::summarise(
    non_response = 1 - mean(responded_angle),
    vviq = dplyr::first(vviq_total_score),
    .by = c(id, version)
  ) |>
  dplyr::filter(!is.na(vviq))

dplyr::bind_rows(
  dplyr::mutate(
    correlation_test(by_participant$non_response, by_participant$vviq),
    sample = "Pooled"),
  by_participant |>
    dplyr::group_split(version) |>
    purrr::map(\(data) dplyr::mutate(
      correlation_test(data$non_response, data$vviq),
      sample = dplyr::first(data$version))) |>
    purrr::list_rbind()
) |>
  dplyr::select(sample, n, rho, p) |>
  knitr::kable(digits = 3,
               caption = "Orientation non-response against vividness")
```

| sample |   n |    rho |     p |
|:-------|----:|-------:|------:|
| Pooled | 116 | -0.291 | 0.002 |
| v1     |  86 | -0.091 | 0.406 |
| v2     |   9 | -0.124 | 0.750 |
| v3     |  21 | -0.672 | 0.001 |

Orientation non-response against vividness {.table}

v1 is 74% of the participants with a vividness score and shows nothing.
The pooled estimate is driven by v3, which is both heavily aphantasic —
17 of its 21 participants — and by far the highest in non-response, so
pooling manufactured an association that neither version contains.

## 3. Parity accuracy predicts imagery vividness

**Claimed**, on an earlier version of the [task
engagement](https://m-delem.github.io/aphantasiaWMStrats/articles/engagement.md)
page: parity engagement is not independent of imagery, and this is what
stops parity accuracy being usable as a nuisance covariate.

**Withdrawn** for two reasons at once. The correlation was rho = -0.154
at p = .157, reported as a finding when the interval comfortably
contains zero. And the variable was not what its name said:
`parity_*_acc` scores an unanswered probe as 0, and 92% of its zeros in
v1 are unanswered rather than wrong, so a participant mean of it
correlates 0.99 with the proportion of probes answered and 0.22 with
accuracy among those answered.

Corrected, parity engagement does not differ by imagery group at all (p
= .93). The fix added `responded_parity_1` and `responded_parity_2` to
the data, and the engagement page now shows the conflation rather than
inheriting it.

## 4. Word recall as an individual-differences measure

Not withdrawn so much as **demoted**, and it constrains every page that
reports a word coefficient.

Word’s split-half reliability is far below the other two features’,
which the [task
validity](https://m-delem.github.io/aphantasiaWMStrats/articles/task-validity.md)
page computes. The metric is not at fault: single-word recall at this
exposure is simply too easy to discriminate between people. The
[performance](https://m-delem.github.io/aphantasiaWMStrats/articles/performance.md)
page shows what that looks like from the model’s side, with every
participant’s estimate collapsing to nearly the same value.

Word’s coefficients are still reported, because a group contrast is a
different estimand and measurement error widens intervals rather than
biasing them. But no strong individual-differences claim about word
should be made, whatever its coefficients say.

------------------------------------------------------------------------

**Continuing through the Extended Online Report:** this page follows
[implementation
notes](https://m-delem.github.io/aphantasiaWMStrats/articles/implementation-notes.md).
That is the end of the ordered sequence; the
[codebook](https://m-delem.github.io/aphantasiaWMStrats/articles/codebook.md)
documents every column in the data. Or return to [the
analysis](https://m-delem.github.io/aphantasiaWMStrats/articles/analysis-strategy.md)
for what the models were built to do.

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
    #>  desc                 1.4.3   2023-12-10 [2] CRAN (R 4.6.1)
    #>  digest               0.6.39  2025-11-19 [2] CRAN (R 4.6.1)
    #>  dplyr                1.2.1   2026-04-03 [2] CRAN (R 4.6.1)
    #>  evaluate             1.0.5   2025-08-27 [2] CRAN (R 4.6.1)
    #>  fastmap              1.2.0   2024-05-15 [2] CRAN (R 4.6.1)
    #>  fs                   2.1.0   2026-04-18 [2] CRAN (R 4.6.1)
    #>  generics             0.1.4   2025-05-09 [2] CRAN (R 4.6.1)
    #>  glue                 1.8.1   2026-04-17 [2] CRAN (R 4.6.1)
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
    #>  renv                 1.0.7   2024-04-11 [2] RSPM (R 4.6.1)
    #>  rlang                1.3.0   2026-07-05 [2] CRAN (R 4.6.1)
    #>  rmarkdown            2.31    2026-03-26 [2] CRAN (R 4.6.1)
    #>  sass                 0.4.10  2025-04-11 [2] CRAN (R 4.6.1)
    #>  sessioninfo          1.2.4   2026-06-04 [2] CRAN (R 4.6.1)
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
    #>  [1] /tmp/RtmpBySS6f/temp_libpath83f676124fdd
    #>  [2] /home/runner/.cache/R/renv/library/aphantasiaWMStrats-f7ce8556/linux-ubuntu-jammy/R-4.6/x86_64-pc-linux-gnu
    #>  [3] /home/runner/.cache/R/renv/sandbox/linux-ubuntu-jammy/R-4.6/x86_64-pc-linux-gnu/e7c0fad7
    #>  * ── Packages attached to the search path.
    #> 
    #> ──────────────────────────────────────────────────────────────────────────────
