# Get started

This page is a short, practical introduction to `aphantasiaWMStrats`:
how to load it, what the data looks like, and how the scores are
produced. It is not where the findings are; for those, start with the
[task
design](https://m-delem.github.io/aphantasiaWMStrats/articles/task-design.md)
page and continue through the Extended Online Report. This page is about
*using the package*.

``` r

library(aphantasiaWMStrats)
```

## The data

One built-in dataset, `all_data`, holds every version of the task in one
item-level table: one row per presented item, so three rows per trial.
An item is one word shown at one orientation in one colour; a trial is
one encode-distract-recall cycle, and there are 21 per participant.

``` r

dplyr::glimpse(all_data[, 1:12])
#> Rows: 8,614
#> Columns: 12
#> $ id                  <chr> "aacu64091390979054fksk", "aacu64091390979054fksk"…
#> $ version             <chr> "v1", "v1", "v1", "v1", "v1", "v1", "v1", "v1", "v…
#> $ language            <chr> "fr", "fr", "fr", "fr", "fr", "fr", "fr", "fr", "f…
#> $ age                 <int> 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41…
#> $ gender              <chr> "f", "f", "f", "f", "f", "f", "f", "f", "f", "f", …
#> $ vviq_total_score    <int> 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16…
#> $ vviq_group_2        <chr> "aphantasia", "aphantasia", "aphantasia", "aphanta…
#> $ vviq_group_4        <chr> "aphantasia", "aphantasia", "aphantasia", "aphanta…
#> $ nieq_mental_imagery <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ nieq_inner_voice    <dbl> 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95…
#> $ nieq_emotions       <dbl> 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85…
#> $ nieq_sensory_focus  <dbl> 55, 55, 55, 55, 55, 55, 55, 55, 55, 55, 55, 55, 55…
```

Columns worth knowing about before anything else.

**`version`** is v1, v2 or v3. These are not interchangeable: the parity
distractor carries a scoring penalty in v2 and v3 but not v1, and recall
order is fixed in v1/v2 and randomised in v3. **v1 (N = 88) is the
primary analysis sample**; v2 (N = 9) and v3 (N = 21) are described but
do not carry the inferential analyses. The [task
design](https://m-delem.github.io/aphantasiaWMStrats/articles/task-design.md)
page explains why.

**`expe_phase`** separates `tutorial`, `training` and the three
`expe_block_*` phases. Tutorial rows carry placeholder values in the
task’s own feedback columns and should always be filtered out.

**`score_word`, `score_angle`, `score_color`** are the recall scores, on
\[0, 1\] with 1 as a perfect match. Their `_z` counterparts are the same
values z-scored within version.

**`responded_word`, `responded_angle`, `responded_color`** say whether
the participant answered at all. These matter more than they look: the
task encodes non-response with sentinel values rather than missing
values, and non-responses are scored 0. An analysis of *accuracy* should
filter on these flags; one that does not is measuring a blend of
accuracy and willingness to answer.

**`live_diff_*` and `feedback_*`** are the scores the task computed in
the browser to show participants feedback. They are kept for provenance
and should never be analysed. One of them is derived from a defective
edit-distance implementation, which the
[scoring](https://m-delem.github.io/aphantasiaWMStrats/articles/scoring.md)
page demonstrates.

## A first look

Experimental blocks only, answered items only:

``` r

all_data |>
  dplyr::filter(grepl("^expe_block", expe_phase), version == "v1") |>
  dplyr::summarise(
    items = dplyr::n(),
    answered = sum(responded_word),
    mean_score_when_answered = mean(score_word[responded_word]),
    .by = expe_phase
  ) |>
  knitr::kable(digits = 3, caption = "Word recall by block, v1")
```

| expe_phase   | items | answered | mean_score_when_answered |
|:-------------|------:|---------:|-------------------------:|
| expe_block_1 |  1848 |     1662 |                    0.918 |
| expe_block_2 |  1848 |     1710 |                    0.937 |
| expe_block_3 |  1848 |     1728 |                    0.946 |

Word recall by block, v1 {.table}

## The scoring functions

The score columns are not read from the raw data; they are computed from
raw target and response values by
[`compute_scores()`](https://m-delem.github.io/aphantasiaWMStrats/reference/compute_scores.md),
which is exported so the pipeline can be re-run or inspected.

``` r

# Word recall: edit-distance scoring, 1 = exact match.
score_word(c("fenetre", "fenetre", "fenetre"), c("fenetre", "fenrete", "table"))
#> [1] 1.0000000 0.7142857 0.1428571

# Angular features: cosine of the error, on the right period for each.
# Colour is a 360-degree hue wheel; orientation is 180-degree symmetric.
score_angular(target = c(0, 0, 0), response = c(0, 45, 90), period = 180)
#> [1] 1.0 0.5 0.0
```

The period argument is not decoration. A rectangle tilted 90 degrees
from target is as wrong as an orientation can be, and only the
180-degree period scores that 0.

[`compute_scores()`](https://m-delem.github.io/aphantasiaWMStrats/reference/compute_scores.md)
takes a stimulus-level frame and appends the score columns, their
standardised counterparts, and the response flags:

``` r

all_data |>
  dplyr::filter(version == "v1") |>
  head(3) |>
  compute_scores() |>
  dplyr::select(
    target_word, response_word, score_word,
    responded_word, responded_angle, responded_color
  ) |>
  knitr::kable(digits = 3)
```

| target_word | response_word | score_word | responded_word | responded_angle | responded_color |
|:---|:---|---:|:---|:---|:---|
| panier | panier | 1.0 | TRUE | TRUE | TRUE |
| amour |  | 0.0 | FALSE | TRUE | TRUE |
| jouet | amour | 0.2 | TRUE | TRUE | TRUE |

Two lower-level functions are exported for the same reason,
[`normalise_word()`](https://m-delem.github.io/aphantasiaWMStrats/reference/normalise_word.md)
and
[`damerau_levenshtein()`](https://m-delem.github.io/aphantasiaWMStrats/reference/damerau_levenshtein.md).
The second is a local implementation rather than a dependency, partly so
it could be tested against known values: the task’s own edit distance
was wrong for three versions precisely because nothing tested it.

``` r

damerau_levenshtein("chien", "chein")  # one adjacent transposition
#> [1] 1
normalise_word("  Fen\u00eatre ")      # lowercase, strip spaces and accents
#> [1] "fenetre"
```

## Beyond scoring

The package also exports the machinery the analyses run on, so that a
script and a documentation page compute the same quantity with the same
code rather than two copies that drift apart.

**Building the composition.** Relative allocation across the three
features is a three-part composition, which cannot be analysed as three
proportions.
[`compose_features()`](https://m-delem.github.io/aphantasiaWMStrats/reference/compose_features.md)
builds the parts from responded items only, and
[`ilr_coords()`](https://m-delem.github.io/aphantasiaWMStrats/reference/ilr_coords.md)
moves them off the simplex.

``` r

v1 <- dplyr::filter(all_data, version == "v1", grepl("^expe_block", expe_phase))

parts <- compose_features(v1, id)
head(dplyr::select(parts, id, tidyselect::starts_with("part_")), 3) |>
  knitr::kable(digits = 3)
```

| id                      | part_word | part_angle | part_color |
|:------------------------|----------:|-----------:|-----------:|
| aacu64091390979054fksk  |     0.371 |      0.276 |      0.353 |
| akdu76317498757772sfnk  |     0.371 |      0.320 |      0.309 |
| aqcx646249376166603nhlj |     0.406 |      0.271 |      0.322 |

``` r


head(ilr_coords(parts[stats::complete.cases(parts), ]), 3) |>
  knitr::kable(digits = 3)
```

|  ilr1 |   ilr2 |
|------:|-------:|
| 0.141 |  0.174 |
| 0.136 | -0.026 |
| 0.259 |  0.121 |

The partition is an explicit argument rather than a hidden constant,
because which contrast the first coordinate names is a substantive
choice and not a statistical one.

**Reporting quantities.**
[`split_half_reliability()`](https://m-delem.github.io/aphantasiaWMStrats/reference/split_half_reliability.md),
[`spearman_brown()`](https://m-delem.github.io/aphantasiaWMStrats/reference/spearman_brown.md),
[`correlation_test()`](https://m-delem.github.io/aphantasiaWMStrats/reference/correlation_test.md),
[`mars_knots()`](https://m-delem.github.io/aphantasiaWMStrats/reference/mars_knots.md),
[`partition_variance()`](https://m-delem.github.io/aphantasiaWMStrats/reference/partition_variance.md)
and
[`centred_correlations()`](https://m-delem.github.io/aphantasiaWMStrats/reference/centred_correlations.md)
are the estimators behind the numbers on the documentation pages.

**Model specifications.** The formulas and priors are exported objects,
not code buried in a script:

``` r

joint_formula()
#> responded_word ~ vviq + complete_aphant + (1 | p | id) 
#> responded_angle ~ vviq + complete_aphant + (1 | p | id) 
#> responded_color ~ vviq + complete_aphant + (1 | p | id) 
#> score_word | subset(responded_word) ~ vviq + complete_aphant + parity_rate + (1 | p | id) 
#> score_angle | subset(responded_angle) ~ vviq + complete_aphant + parity_rate + (1 | p | id) 
#> score_color | subset(responded_color) ~ vviq + complete_aphant + parity_rate + (1 | p | id)
```

This matters for reproducibility rather than tidiness. Documentation
pages load fitted models with `file_refit = "never"`, and brms returns a
cached fit **without checking** that the formula it was handed matches
the one the model was fitted with. A page that re-typed its formula
could display something that is not what produced its numbers. Calling
the builder makes that impossible.

[`joint_priors()`](https://m-delem.github.io/aphantasiaWMStrats/reference/joint_priors.md),
[`performance_formula()`](https://m-delem.github.io/aphantasiaWMStrats/reference/performance_formula.md),
[`composition_formula()`](https://m-delem.github.io/aphantasiaWMStrats/reference/composition_formula.md)
and
[`fit_brms_model()`](https://m-delem.github.io/aphantasiaWMStrats/reference/fit_brms_model.md)
complete the set.

**Figures.**
[`theme_pdf()`](https://m-delem.github.io/aphantasiaWMStrats/reference/theme_pdf.md)
and the `scale_*_aphantasia()` scales are shared with the sibling
package `aphantasiaEmotions`, so imagery groups are the same colours
across both. Analysis scripts render vector PDFs at printed size; these
pages render the same figures at `base_size = 16`.

## Where to go next

The documentation is an [Extended Online
Report](https://m-delem.github.io/aphantasiaWMStrats/): pages ordered so
that no quantity appears before the page that defines it.

- [**Task
  design**](https://m-delem.github.io/aphantasiaWMStrats/articles/task-design.md)
  for what participants did and why the task changed twice.
- [**Scoring**](https://m-delem.github.io/aphantasiaWMStrats/articles/scoring.md)
  for how these numbers are made.
- [**Task
  engagement**](https://m-delem.github.io/aphantasiaWMStrats/articles/engagement.md)
  for the two ways participants declined to do the task, and why
  declining is itself informative.
- [**Versions**](https://m-delem.github.io/aphantasiaWMStrats/articles/version-scope.md)
  for which of the three task versions the analyses use.
- [**Task
  validity**](https://m-delem.github.io/aphantasiaWMStrats/articles/task-validity.md)
  for whether these scores are reliable enough to carry an
  individual-differences claim. One of the three features is not.
- [**Questionnaire
  psychometrics**](https://m-delem.github.io/aphantasiaWMStrats/articles/psychometrics.md)
  for the same question asked of the VVIQ, OSIVQ and NIEQ.
- [**Codebook**](https://m-delem.github.io/aphantasiaWMStrats/articles/codebook.md)
  for every column in `all_data`.

------------------------------------------------------------------------

    #> ─ Session info ───────────────────────────────────────────────────────────────
    #>  setting  value
    #>  version  R version 4.6.1 (2026-06-24)
    #>  os       Ubuntu 24.04.4 LTS
    #>  system   x86_64, linux-gnu
    #>  ui       X11
    #>  language en
    #>  collate  C.UTF-8
    #>  ctype    C.UTF-8
    #>  tz       UTC
    #>  date     2026-08-26
    #>  pandoc   3.8.3 @ /opt/hostedtoolcache/pandoc/3.8.3/x64/ (via rmarkdown)
    #>  quarto   NA
    #> 
    #> ─ Packages ───────────────────────────────────────────────────────────────────
    #>  ! package            * version  date (UTC) lib source
    #>    abind                1.4-8    2024-09-12 [2] CRAN (R 4.6.1)
    #>    aphantasiaWMStrats * 0.1      2026-08-26 [1] local
    #>    backports            1.5.1    2026-04-03 [2] CRAN (R 4.6.1)
    #>    bayesplot            1.16.0   2026-08-25 [2] CRAN (R 4.6.1)
    #>    bridgesampling       1.2-1    2025-11-19 [2] CRAN (R 4.6.1)
    #>    brms                 2.23.0   2025-09-09 [2] CRAN (R 4.6.1)
    #>    Brobdingnag          1.2-9    2022-10-19 [2] CRAN (R 4.6.1)
    #>    bslib                0.12.0   2026-08-04 [2] CRAN (R 4.6.1)
    #>    cachem               1.1.0    2024-05-16 [2] CRAN (R 4.6.1)
    #>    checkmate            2.3.4    2026-02-03 [2] CRAN (R 4.6.1)
    #>    cli                  3.6.6    2026-04-09 [2] CRAN (R 4.6.1)
    #>    coda                 0.19-4.1 2024-01-31 [2] CRAN (R 4.6.1)
    #>    crayon               1.5.3    2024-06-20 [2] CRAN (R 4.6.1)
    #>    desc                 1.4.3    2023-12-10 [2] CRAN (R 4.6.1)
    #>    digest               0.6.39   2025-11-19 [2] CRAN (R 4.6.1)
    #>    distributional       0.8.1    2026-06-27 [2] CRAN (R 4.6.1)
    #>    dplyr                1.2.1    2026-04-03 [2] CRAN (R 4.6.1)
    #>    emmeans              2.0.4    2026-07-15 [2] CRAN (R 4.6.1)
    #>    estimability         2.0.0    2026-06-26 [2] CRAN (R 4.6.1)
    #>    evaluate             1.0.5    2025-08-27 [2] CRAN (R 4.6.1)
    #>    farver               2.1.2    2024-05-13 [2] CRAN (R 4.6.1)
    #>    fastmap              1.2.0    2024-05-15 [2] CRAN (R 4.6.1)
    #>    fs                   2.1.0    2026-04-18 [2] CRAN (R 4.6.1)
    #>    generics             0.1.4    2025-05-09 [2] CRAN (R 4.6.1)
    #>    ggplot2              4.0.3    2026-04-22 [2] CRAN (R 4.6.1)
    #>    glue                 1.8.1    2026-04-17 [2] CRAN (R 4.6.1)
    #>    gtable               0.3.6    2024-10-25 [2] CRAN (R 4.6.1)
    #>    htmltools            0.5.9    2025-12-04 [2] CRAN (R 4.6.1)
    #>    jquerylib            0.1.4    2021-04-26 [2] CRAN (R 4.6.1)
    #>    jsonlite             2.0.0    2025-03-27 [2] CRAN (R 4.6.1)
    #>    knitr                1.51     2025-12-20 [2] CRAN (R 4.6.1)
    #>  P lattice              0.22-9   2026-02-09 [?] CRAN (R 4.6.1)
    #>    lifecycle            1.0.5    2026-01-08 [2] CRAN (R 4.6.1)
    #>    loo                  2.10.1   2026-07-24 [2] CRAN (R 4.6.1)
    #>    magrittr             2.0.5    2026-04-04 [2] CRAN (R 4.6.1)
    #>  P Matrix               1.7-5    2026-03-21 [?] CRAN (R 4.6.1)
    #>    matrixStats          1.5.0    2025-01-07 [2] CRAN (R 4.6.1)
    #>    mvtnorm              1.4-2    2026-07-12 [2] CRAN (R 4.6.1)
    #>  P nlme                 3.1-169  2026-03-27 [?] CRAN (R 4.6.1)
    #>    otel                 0.2.0    2025-08-29 [2] CRAN (R 4.6.1)
    #>    pillar               1.11.1   2025-09-17 [2] CRAN (R 4.6.1)
    #>    pkgconfig            2.0.3    2019-09-22 [2] CRAN (R 4.6.1)
    #>    pkgdown              2.2.1    2026-07-07 [2] any (@2.2.1)
    #>    posterior            1.7.0    2026-04-01 [2] CRAN (R 4.6.1)
    #>    purrr                1.2.2    2026-04-10 [2] CRAN (R 4.6.1)
    #>    R6                   2.6.1    2025-02-15 [2] CRAN (R 4.6.1)
    #>    ragg                 1.5.2    2026-03-23 [2] CRAN (R 4.6.1)
    #>    RColorBrewer         1.1-3    2022-04-03 [2] CRAN (R 4.6.1)
    #>    Rcpp                 1.1.2    2026-07-05 [2] CRAN (R 4.6.1)
    #>    RcppParallel         6.2.0    2026-07-30 [2] CRAN (R 4.6.1)
    #>    renv                 1.0.7    2024-04-11 [2] RSPM (R 4.6.1)
    #>    rlang                1.3.0    2026-07-05 [2] CRAN (R 4.6.1)
    #>    rmarkdown            2.31     2026-03-26 [2] CRAN (R 4.6.1)
    #>    rstantools           2.7.0    2026-07-26 [2] CRAN (R 4.6.1)
    #>    S7                   0.2.2    2026-04-22 [2] CRAN (R 4.6.1)
    #>    sass                 0.4.10   2025-04-11 [2] CRAN (R 4.6.1)
    #>    scales               1.4.0    2025-04-24 [2] CRAN (R 4.6.1)
    #>    sessioninfo          1.2.4    2026-06-04 [2] CRAN (R 4.6.1)
    #>    stringi              1.8.9    2026-08-04 [2] CRAN (R 4.6.1)
    #>    stringr              1.6.0    2025-11-04 [2] CRAN (R 4.6.1)
    #>    systemfonts          1.3.2    2026-03-05 [2] CRAN (R 4.6.1)
    #>    tensorA              0.36.2.1 2023-12-13 [2] CRAN (R 4.6.1)
    #>    textshaping          1.0.5    2026-03-06 [2] CRAN (R 4.6.1)
    #>    tibble               3.3.1    2026-01-11 [2] CRAN (R 4.6.1)
    #>    tidyr                1.3.2    2025-12-19 [2] CRAN (R 4.6.1)
    #>    tidyselect           1.2.1    2024-03-11 [2] CRAN (R 4.6.1)
    #>    vctrs                0.7.3    2026-04-11 [2] CRAN (R 4.6.1)
    #>    withr                3.0.3    2026-06-19 [2] CRAN (R 4.6.1)
    #>    xfun                 0.60     2026-07-09 [2] CRAN (R 4.6.1)
    #>    xtable               1.8-8    2026-02-22 [2] CRAN (R 4.6.1)
    #>    yaml                 2.3.12   2025-12-10 [2] CRAN (R 4.6.1)
    #> 
    #>  [1] /tmp/Rtmph67Pun/temp_libpath87a93012435a
    #>  [2] /home/runner/.cache/R/renv/library/aphantasiaWMStrats-f7ce8556/linux-ubuntu-noble/R-4.6/x86_64-pc-linux-gnu
    #>  [3] /home/runner/.cache/R/renv/sandbox/linux-ubuntu-noble/R-4.6/x86_64-pc-linux-gnu/e7c0fad7
    #> 
    #>  * ── Packages attached to the search path.
    #>  P ── Loaded and on-disk path mismatch.
    #> 
    #> ──────────────────────────────────────────────────────────────────────────────
