# Analysis plan: what is modelled, and why

The preceding pages establish who took part, what was measured, on which
sample, and whether it measures anything. This page says what is done
with it, and in what order. It reports no findings (every result on this
site belongs to a later page) and it is deliberately written so that it
could have been written before any model was fitted. Two numbers do
appear, both because a decision on this page turns on them: the
selection correlation in section 2, which is why the joint model exists
at all, and the outcome of the functional-form comparison in section 3,
which is why the floor-group form survived being pre-declared.

Everything it describes runs on **task version v1**, for the reasons the
[version
scope](https://m-delem.github.io/aphantasiaWMStrats/articles/version-scope.md)
page sets out. The one exception is the exploratory strand, which pools
all three versions because it uses questionnaires rather than task
behaviour.

## 1. The question the models have to answer

Aphantasic participants perform about as well as typical imagers on
visual working memory tasks, and report doing so using verbal or spatial
strategies. A strategy is, by definition, what someone takes themselves
to be doing, so no performance pattern can outrank their own account of
it. What a behavioural measure can add is **convergence**: a dependent
variable that, if it tracks the same distinctions participants report,
corroborates the subjective category rather than replacing it.

The WM-FTT was built to provide one. Three features per stimulus,
partial credit for each, and instructions to maximise the score, so that
a participant who divides effort unevenly leaves a trace in the scores
themselves.

“Where does effort go” then has two possible readings, and the
difference between them shaped everything here.

- **Absolute performance.** Are aphantasic participants worse at some
  features than typical imagers?
- **Relative allocation.** Independently of overall ability, do they
  divide effort differently across the three features?

These framings are complementary and are the main confirmatory models
reported, but both miss a piece of the puzzle that only a more complex
model can capture.

## 2. The added complexity: abstention is a behaviour

Recall of each feature is optional, and participants used that. The
[task
engagement](https://m-delem.github.io/aphantasiaWMStrats/articles/engagement.md)
page shows that declining to report a feature is not missing data: under
a points-per-feature incentive, **choosing not to report is itself an
allocation decision**, and arguably the most direct one the task
records. A participant who abandons orientation entirely to protect
colour has made a clearer strategic statement than one whose orientation
score is slightly lower.

Both framings in section 1 filter that behaviour out before analysing
what remains. That is a decision about which quantity is interesting
that is not neutral and excludes real, possibly meaningful data.

There is also a statistical problem with filtering it out. Analysing
only responded items conditions on a selected sub-sample. If the
participants who abstain more also perform differently when they do
answer, the conditional estimates are biased in a way **no
responders-only analysis can detect**, because the information needed to
detect it has been removed.

That was tested. Fitting response and accuracy jointly on orientation
(in a bivariate model of that feature alone) gives a participant-level
correlation between the two of 0.52, with 95% of the posterior in
\[0.268, 0.721\] (that figure is a posterior **mean**; the [joint
model](https://m-delem.github.io/aphantasiaWMStrats/articles/joint-model.md)
page reports the same parameter as a median, which is why the two differ
in the second digit).

The rule for what that would mean was written down before the number
existed: conditioning on responding was not innocent, so a model that
does not condition on it is needed. What it is needed *for* is to settle
whether the composition was computable, not what the composition found.

## 3. How imagery enters every model

Before any model, one decision applies to all of them: **what shape does
imagery vividness take as a predictor?**

Not a smooth one. VVIQ scores in this sample are a sharp, isolated spike
at the scale minimum (VVIQ = 16) plus an irregular remainder above it,
so a single slope fitted through everything would describe neither part.
Participants at the floor also have **no vividness variance among
themselves**: a slope cannot be estimated for them, while an offset can.

Every model on this site therefore takes the same form:

- a **slope** across participants above the floor, and
- a single **offset** for the group at it.

Rather than assume that form, several were compared, with this one
pre-declared as primary in the case that it fit as well as others. Two
comparisons were run: four candidates on orientation accuracy
([performance](https://m-delem.github.io/aphantasiaWMStrats/articles/performance.md)
§4) and five on the first compositional coordinate
([composition](https://m-delem.github.io/aphantasiaWMStrats/articles/composition.md)
§8). Neither separates the candidates.

**This decision is the spine of the models’ structure.** The floor-group
offset is what every result on this site reports: the compositional
shift, the per-feature accuracies, and the joint model’s six responses
all estimate it in the same way, which is what makes them comparable.

### The caution that comes with it

The offset is the distance between where the floor group sits and
**where a relationship fitted on everyone else predicts they would
sit**. Above the floor, participants cluster at the top of the vividness
range with only a handful below 40, so that relationship is anchored by
a dense group at 50 to 80 plus a scatter, and extending it down to 16
rests on a linearity assumption this sample barely constrains. The
previous study that showed the relevance of the floor-group structure,
[`aphantasiaEmotions`](https://m-delem.github.io/aphantasiaEmotions/index.html),
makes the same move with 1478 participants across five studies; there
are at most 86 here: every v1 participant with a vividness score, and
fewer on the pages that also require an engaged composition. On every
figure, that stretch of the line is drawn **dashed** to mark it as
extrapolation rather than fit.

## 4. The primary analysis: allocation

Divide each participant’s three feature scores by their sum and what
remains is a **composition**: three parts summing to one, carrying only
relative information. Overall ability is gone; only where the effort
went survives.

Three parts summing to a constant cannot vary independently, so the
composition is moved off the simplex into two unconstrained isometric
log-ratio coordinates before anything is modelled: `ilr1` contrasts
words against the geometric mean of the two non-verbal features, `ilr2`
contrasts colour against orientation. Which contrast comes first is a
substantive choice rather than a statistical one, and the
[composition](https://m-delem.github.io/aphantasiaWMStrats/articles/composition.md)
page shows that the omnibus test does not depend on it.

``` r

composition_formula("vviq + complete_aphant + parity_rate")
#> ilr1 ~ vviq + complete_aphant + parity_rate 
#> ilr2 ~ vviq + complete_aphant + parity_rate
```

Both coordinates are modelled together with the residual correlation
between them estimated, because the invariance above holds for a genuine
multivariate model: two separate univariate fits would lose it.

This is the analysis the study was **designed** around. The study’s
prediction is about allocation; it is the coordinate on which vividness,
inner experience and participants’ own accounts of what they were doing
all bear; and it is the result that clears its pre-declared threshold.

## 5. The other models, and what they are for

Two models sit around it, both using the form set out in section 3.

- [**Performance**](https://m-delem.github.io/aphantasiaWMStrats/articles/performance.md)**.**
  Absolute per-feature accuracy, with a response family chosen per
  feature. The same data read as *how much* rather than *where*, which
  is section 1’s first reading.
- [**The joint
  model**](https://m-delem.github.io/aphantasiaWMStrats/articles/joint-model.md)**.**
  Six responses: whether each feature was reported at all, and how well
  it was reported when it was, with the correlations between those six
  quantities as objects of interest.

The joint model is not a bigger version of the composition. It exists
because the composition is computed from **responded items only**, and
whether that conditioning was innocent cannot be checked from inside a
responders-only analysis. The joint model checks it.

So the precedence between them is specific rather than general. **On
allocation, the composition is primary.** On selection and on
willingness to report, the joint model is authoritative and the
composition is silent. Where the joint model bears on allocation, it
speaks to whether the composition was *computable*, not to what it
found.

## 6. The samples, once

Six numbers circulate on the modelling pages and they are easy to
conflate, so they are computed here in one place and referred to rather
than restated. Every one of them is a filter on v1, applied for a reason
given on an earlier page.

``` r

v1 <- get_data("v1") |>
  dplyr::filter(grepl("^expe_block", expe_phase))

vividness <- dplyr::summarise(
  v1, vviq = dplyr::first(vviq_total_score), .by = id
)

parts <- compose_features(v1, id) |>
  dplyr::filter(stats::complete.cases(dplyr::pick(tidyselect::everything())))

engaged <- dplyr::filter(parts, id %in% engaged_ids(v1))

with_vviq <- engaged |>
  dplyr::left_join(vividness, by = "id") |>
  dplyr::filter(!is.na(vviq))

with_scales <- dplyr::filter(
  with_vviq, id %in% questionnaire_scales(all_data)$id
)

tibble::tibble(
  sample = c(
    "v1 participants",
    "With a vividness score",
    "All three compositional parts present",
    "Also clearing the engagement thresholds",
    "Also with a vividness score",
    "Also with every questionnaire scale"
  ),
  n = c(
    dplyr::n_distinct(v1$id),
    sum(!is.na(vividness$vviq)),
    nrow(parts), nrow(engaged), nrow(with_vviq), nrow(with_scales)
  ),
  used_by = c(
    "Descriptives",
    "The joint model",
    "Composition §2",
    "Composition §§2, 3, 6",
    "Composition §§4, 7, 8; performance",
    "Composition §5"
  )
) |>
  knitr::kable(caption = "Every modelling sample on this site")
```

| sample | n | used_by |
|:---|---:|:---|
| v1 participants | 88 | Descriptives |
| With a vividness score | 86 | The joint model |
| All three compositional parts present | 87 | Composition §2 |
| Also clearing the engagement thresholds | 81 | Composition §§2, 3, 6 |
| Also with a vividness score | 79 | Composition §§4, 7, 8; performance |
| Also with every questionnaire scale | 78 | Composition §5 |

Every modelling sample on this site {.table}

Two things follow from the table:

The **joint model uses more participants than anything else**. The
engagement thresholds exist to stop imprecise participant *means* being
treated as measurements; the joint model forms no participant means, so
it does not need them, and the participants they exclude are precisely
the ones with the most to say about abstention.

The **modelling sample is smaller than the engaged sample**, by the two
participants with no VVIQ score. Every model on this site reports a
floor-group offset, and a participant with no vividness score cannot be
placed on either side of the floor.

## 7. Confirmatory and exploratory

Everything above uses groups defined by imagery vividness, **fixed
before any model was fitted**. That is the confirmatory strand.

A second strand asks whether the sample contains structure that
vividness does not capture: how the questionnaire scales relate to each
other, and whether participants cluster into groups the vividness split
does not recover. That is exploratory and built to generate hypotheses
rather than test them.

The interesting outcome there would be clusters that **split** the group
of complete aphantasics, since that is a distinction the confirmatory
strand cannot make at all. Clusters that merely recover the vividness
grouping would be a reportable null.

------------------------------------------------------------------------

**Continuing through the Extended Online Report:** this page follows
[questionnaire
psychometrics](https://m-delem.github.io/aphantasiaWMStrats/articles/psychometrics.md).
To keep reading in order, continue to
[composition](https://m-delem.github.io/aphantasiaWMStrats/articles/composition.md)
next. Or see [model
diagnostics](https://m-delem.github.io/aphantasiaWMStrats/articles/model-diagnostics.md)
and [implementation
notes](https://m-delem.github.io/aphantasiaWMStrats/articles/implementation-notes.md)
for the technical detail behind these models.

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
    #>  ! package            * version  date (UTC) lib source
    #>    abind                1.4-8    2024-09-12 [2] CRAN (R 4.6.1)
    #>    aphantasiaWMStrats * 0.1      2026-08-31 [1] local
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
    #>    RcppParallel         6.2.1    2026-08-27 [2] CRAN (R 4.6.1)
    #>    renv                 1.0.7    2024-04-11 [2] RSPM (R 4.6.1)
    #>    rlang                1.3.0    2026-07-05 [2] CRAN (R 4.6.1)
    #>    rmarkdown            2.31     2026-03-26 [2] CRAN (R 4.6.1)
    #>    rstantools           2.7.1    2026-08-29 [2] CRAN (R 4.6.1)
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
    #>  [1] /tmp/RtmpjrXxde/temp_libpath83d0647deac5
    #>  [2] /home/runner/.cache/R/renv/library/aphantasiaWMStrats-f7ce8556/linux-ubuntu-jammy/R-4.6/x86_64-pc-linux-gnu
    #>  [3] /home/runner/.cache/R/renv/sandbox/linux-ubuntu-jammy/R-4.6/x86_64-pc-linux-gnu/e7c0fad7
    #> 
    #>  * ── Packages attached to the search path.
    #>  P ── Loaded and on-disk path mismatch.
    #> 
    #> ──────────────────────────────────────────────────────────────────────────────
