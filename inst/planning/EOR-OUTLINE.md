# EOR outline: what the public product looks like

**Created 2026-08-25.** The planning docs are numbered by analytic
dependency (INDEX §4). This file maps that onto the **public** product:
the pkgdown site, its page order, and which doc, script and figures feed
each page. They are not the same thing and should not be forced to be.
Planning docs are a working record with reversals in them; vignettes are
the account a reader is given.

Ordering principle: **a reader should never meet a quantity before the
page that defines it.** Everything from Part C onward is conditional on
Part B's answer, so it is all v1 only, and each page says so.

---

## Part A. What was measured

### A1. Task design and history
*Exists: `vignettes/articles/task-design.Rmd`. Plan: `01` (stub).*

The paradigm, the points-per-feature incentive, the version history and
what each version changed. Load-bearing for everything after it, because
the incentive structure is why declining to report is an allocation
decision rather than missing data. The planning doc is a stub while the
vignette is written, which is backwards and should be fixed.

### A2. Scoring
*Exists: `vignettes/articles/scoring.Rmd`. Plan: `02`. Script: `02`.
Figures: q1, q2, q3.*

What a response becomes, the three metrics, and why the task's own
feedback columns are not the analysis scores. Currently also carries
"Which sample" and "Distributions", which belong in A4 and B; see
**Known problems**.

### A3. Engagement: the two ways participants withdrew
*Exists: `vignettes/articles/engagement.Rmd`. Plans: `03`, `04`.*

Parity and non-response. This page has to do two jobs and should say so:
define both variables, and establish that **abstention is a substantive
behaviour rather than missing data**. That second claim is the premise the
primary model rests on, so this page is where a sceptical reader is either
won or lost. **Currently wrong, see Known problems.**

---

## Part B. Scope

### B1. Versions, and which one the analyses use
*Missing. Plan: `05`.*

Why three versions exist, why v2 and v3 cannot carry the inferential
analyses, and the decision to run on v1 (N = 88). Currently implicit
across several pages. It needs its own page because every result after it
inherits the restriction, and because the version differences are
themselves informative.

---

## Part C. Does anything here measure anything?

### C1. Task validity and reliability
*Missing as its own page. Plan: `06`. Script: `06a`, `06b`.
Figures: r1, v1-vviq-accuracy, v1-propensity-vviq.*

Split-half reliability per feature, the ILR stability gate, construct
validity against VVIQ. Includes the finding that **word fails as an
individual-differences measure** (0.445), which constrains how every later
result may be read.

### C2. Questionnaire psychometrics
*Exists: `vignettes/articles/psychometrics.Rmd`. Plan: `07` (stub).*

VVIQ, OSIVQ, NIEQ, TAS-20. Distinct from C1: that page asks whether the
task measures anything, this one asks whether the instruments do.

---

## Part D. Confirmatory modelling

VVIQ-defined groups, fixed in advance.

### D1. How imagery enters a model
*Missing. Plan: `08`. Script: `08`. Figure: none yet.*

The floor-group form, why VVIQ is not a smooth predictor here, and the
model-space comparison. Short, and it comes first because D2 to D4 all
assume it.

### D2. The joint model
*Missing. Plan: `09`. Script: `09`. Figures: j1, j2, j3.*

**The centre of the EOR.** Six responses, fifteen correlations, three
tiers of reporting fixed in advance. Likely several sub-sections rather
than one page: selection, trade-off, and what complete aphantasia changes
about willingness to report.

### D3. Performance, as a check
*Missing. Plan: `10`. Script: `10`. Figures: p1 to p6.*

Absolute per-feature accuracy. Must be framed as a robustness check on D2
and **not as corroboration**: same data, simpler lens.

### D4. Composition, as a complement
*Missing. Plan: `11`. Script: `11`. Figures: c1 to c5.*

Relative allocation, ILR coordinates, the ternary picture. Different
geometry from D2 rather than a weaker version of it, and carrying its own
caveat until D2's selection correlations are known.

---

## Part E. Exploratory modelling

Unplanned groups. Every page here says "exploratory" in its first
paragraph.

### E1. Structure among the questionnaires
*Missing. Plan: `12` (stub).*

### E2. Clustering
*Missing. Plan: `13`.*

### E3. The joint model, refitted on clusters
*Missing. Depends on E2 finding anything worth refitting on.*

---

## Reference

### R1. Codebook
*Exists: `vignettes/articles/codebook.Rmd`.*

### R2. Get started
*Exists: `vignettes/aphantasiaWMStrats.Rmd`.*

---

## Known problems, 2026-08-25

**`engagement.Rmd` §2 is wrong and is public-facing.** It reports a
parity/VVIQ association in a table captioned "v1" that is computed on all
three versions: pooled rho = -0.333, p = 0.0003; v1 only, rho = -0.154,
p = 0.157. It then builds "this is the finding that stops parity accuracy
being usable as a nuisance covariate" on top of it. The variable is also
the broken one (`03` §11.1). Corrected, the claim reverses. Full account
in `03` §11.7. **Fix before anything else on this list**, and rewrite the
section rather than deleting it: a pooled association that dissolves on
stratification is worth showing, and this project has the receipts.

**`scoring.Rmd` mixes in scope and validity.** Its "Which sample" belongs
in B1 and its "Distributions" partly in C1. Splitting is cheap now and
expensive after the modelling pages cite into it by section.

**Nine of fifteen pages do not exist**, and all of Part D is among them.
That is expected at this stage, but it means the site currently reads as a
methods appendix with no results, and the order above is what stops the
results being written into the wrong places.

**Figures are not shared between the two.** The 17 PDFs in
`inst/scripts/figures/` are print-size artifacts for the thesis and the
poster, and no vignette references them. Vignette figures are **recreated**
at `base_size = 16`, not linked. What is shared is the code that builds
them, which is why the plotting layer belongs in `R/`.

**The shared function layer now exists** (2026-08-25). Model formulas and
priors are exported (`joint_formula()`, `joint_priors()`,
`performance_formula()`, `composition_formula()`), as are the analysis
helpers each page reports (`split_half_reliability()`, `mars_knots()`,
`partition_variance()`, `centred_correlations()`, and the rest). Two
consequences for the pages below. A vignette computes a number with the
same code the script used, rather than a second copy that drifts. And a
vignette can **print the formula and prior objects** for a reader who wants
them, which matters because models are loaded with `file_refit = "never"`
and brms does not check that a hand-written formula matches the cached fit.

Still missing from that layer: the **plot builders**. Script figures are
inline ggplot, so a vignette cannot yet rebuild them at a different base
size. That is the next piece, and it should land before the Part D pages
are written.

## What this file is not

Not a commitment to page granularity. D2 may be three pages or one. It is
a commitment to **order**, and to each result having exactly one home.
