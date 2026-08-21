
<!-- README.md is generated from README.Rmd. Please edit that file -->

# aphantasiaWMStrats

<!-- badges: start -->

<a href="https://osf.io/3649s/" target="_blank"><img src="https://img.shields.io/badge/OSF-https://osf.io/3649s/-337AB7?logo=osf" alt="OSF badge"/></a>
<a href="https://m-delem.github.io/aphantasiaWMStrats/" target="_blank"><img alt="Docs badge" src="https://img.shields.io/badge/Documentation-website-009e73?style=flat&logo=Google%20Docs&logoColor=009e73&logoSize=auto"/></a>
<!-- badges: end -->

aphantasiaWMStrats is a data analysis project and an *Extended Online
Report* (see below) wrapped in an R package for reproducibility[^1]. It
contains the data and code for the **Working Memory Feature Trade-off
Task (WM-FTT)**, an original paradigm built to ask which kind of mental
representation people actually rely on when remembering, rather than
asking them to report it. The project is archived on the Open Science
Framework <a href="https://osf.io/3649s/" target="_blank">here</a>.

## The question, and the task built to answer it

Aphantasic individuals perform about as well as typical imagers on
visual working memory tasks despite reporting no voluntary visual
imagery, and they say they compensate with verbal or spatial strategies
instead. That self-report is exactly the thing under suspicion. WM-FTT
was designed to surface the trade-off *behaviourally*: every stimulus
carries three features at once, a **word**, an **orientation** and a
**colour**, scoring gives partial credit per feature, and participants
are told to maximise their score. If effort has to be divided, where it
goes is a measurement rather than a claim.

<img src="man/figures/cfa_wm_trial_overview_v3.png" alt="Diagram of one WM-FTT trial, from encoding through recall to feedback." width="100%" />

The task ran in three versions, and the differences between them are not
incidental. Each version exists because the previous one’s own data
showed a specific way the design was undermining its own validity. That
story is told in full on the [task
design](https://m-delem.github.io/aphantasiaWMStrats/articles/task-design.html)
page.

## What is in this package

The package ships the pooled dataset as a built-in table, `all_data`:
one row per presented stimulus across all three task versions, with
recall responses, scores, questionnaire scores and raw questionnaire
items. It also contains the scoring functions that produce those scores
from the raw responses, and the scripts and vignettes that document how
every number was arrived at.

Beyond any eventual article, this project is documented as an **Extended
Online Report (EOR)**: a structure of interlinked, executable pages that
go past what a Methods section can carry, including the reasoning behind
each measurement choice and the problems found along the way. It is
organised as follows.

**Paradigm characteristics**

- [**Task
  design**](https://m-delem.github.io/aphantasiaWMStrats/articles/task-design.html):
  what participants actually did, screen by screen, and why the task
  changed twice.
- [**Psychometrics**](https://m-delem.github.io/aphantasiaWMStrats/articles/psychometrics.html):
  how the VVIQ, OSIVQ and NIEQ behave in this sample, including one
  scale that does not hold together and one scoring inconsistency worth
  knowing about.
- [**Task
  engagement**](https://m-delem.github.io/aphantasiaWMStrats/articles/engagement.html):
  the two independent ways participants withdrew effort, and why neither
  can be treated as a nuisance to control away.
- [**Scoring**](https://m-delem.github.io/aphantasiaWMStrats/articles/scoring.html):
  how raw responses become the scores in `all_data`, why the task’s own
  in-browser scores are not used, what the resulting measures will and
  will not support, and a comparison of the three versions.

**Technical details**

- [**Codebook**](https://m-delem.github.io/aphantasiaWMStrats/articles/codebook.html):
  every column in `all_data`, with its type, range and meaning.

If you would rather get straight to using the package, the [**Get
started**](https://m-delem.github.io/aphantasiaWMStrats/articles/aphantasiaWMStrats.html)
page is a short, practical introduction to the data and the scoring
functions.

The source of every page above is in the `vignettes/` folder of this
repository.

## Installation

You can install the development version of aphantasiaWMStrats from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("m-delem/aphantasiaWMStrats")
```

Alternatively, clone the repository, open the `aphantasiaWMStrats.Rproj`
file in RStudio, and run:

``` r
devtools::load_all()
```

which will load the package and make its functions and data available in
your R session.

## A note on names

The task is called **WM-FTT** in writing. Its internal name during data
collection was **CFA-WM**, and that name survives in column prefixes,
OSF component names, file paths and the front-end code. Those
identifiers are deliberately unchanged so that exports stay comparable
with earlier ones and with the raw data on the lab server. The two names
refer to the same task.

## Citation

This repository is archived in the OSF project, which assigns a
permanent DOI to the code and data. If you use them in your research,
please cite:

> Delem, M. (2026, August 21). *Working memory representational
> strategies in aphantasia (WM-FTT)*.
> <https://doi.org/10.17605/OSF.IO/3649S>

[^1]: The R package structure was chosen to facilitate the sharing of
    the code and data with the scientific community, and to make it easy
    to reproduce the analyses. It is not intended to be a
    general-purpose package, but rather a collection of functions and
    data specific to this study. The package development workflow (see
    <a href="https://r-pkgs.org/" target="_blank">this reference
    book</a>) is also a good way to ensure that the code is
    well-documented and tested, which matters for reproducibility in
    scientific research.
