# Planning changelog

Chronology only. Decisions and their reasoning live in the docs; this file
records **when** things changed and in what order, and points into them.

The reason it exists: doc numbers used to encode chronology, which meant
they had to move whenever the analysis was reordered. They now encode
analytic dependency, which is stable. Sequence lives here instead.

---

## 2026-08-26 — read of the built site, and three fixes

The full site was rebuilt and read. All seventeen pages reach their footer,
no chunk errored, and every table has rows except one.

### The one that did not: I wrote the bug this report documents

`composition` §8's usable-share table rendered **empty**, headers and no
rows:

```r
tibble::tibble(
  compositions = nrow(trial_parts),
  usable = nrow(usable),
  share = nrow(usable) / nrow(trial_parts)   # `usable` is now the count
)
```

`nrow()` of an integer returns `NULL`, `NULL / 1659` is `numeric(0)`, and a
zero-length column collapses the whole tibble to zero rows. No error, no
warning, an empty table on a published page.

This is exactly the hazard `implementation-notes` §8 sets out under
"Column masking inside `tibble()`", using almost the same example. It was
written into the page by the person who had just finished citing it.
Counts are now taken before the tibble. Every other chunk on every
vignette was swept for the same pattern; this was the only instance.

### Two more

- **`version-scope` §3.** The leave-one-out table supports a weaker claim
  than the sentence beneath it made. Computed: v2's median shift is 0.137
  against v1's 0.028, but v2's *maximum* is 0.634, not the 0.945 the old
  prose asserted, and v1's own maximum is 0.437. The argument now rests on
  the median comparison, which is what the table demonstrates, rather than
  on a maximum that does not separate the versions cleanly.
- **`vignettes/aphantasiaWMStrats.Rmd`.** The "trial" sweep missed the Get
  started vignette entirely, because it sits in `vignettes/` rather than
  `vignettes/articles/` and every grep was scoped to the latter. Four
  usages corrected, and the two units are now defined there too.

### Checked in the render and correct

Sample table 88 / 86 / 87 / 81 / 79 / 78. `composition` frames 87 / 81 / 79
/ 78, §7 levels 18 + 61, §6 convergence n = 76 with rho -0.325 at p = .004,
§5 offsets 0.097 [0.029, 0.164] against 0.093 [0.025, 0.161]. Reverse-keying
item-totals -0.27 / -0.29 / -0.32 in v1 against +0.51 / +0.58 / +0.56 in v3,
matching the review's independent check. Gate coefficients move by at most
0.027 without the accuracy arms. Home page rebuilt: link repointed, block
reordered, gradient wording live.

**One number the review had wrong.** The partial correlation of
unsymbolised thinking with the imagery composite is **-0.370**, not the
-0.42 the page used to assert. It is computed now.

---

## 2026-08-26 — cold review, phase 4 (the [C] items and the duplication register)

- **F19 / F85 / F90 / F95.** Owners assigned for the two quantities that
  appeared in three and five places.
  - The **two-way trade-off withdrawal** is owned by `lessons` §1, which
    carries both 3x3 matrices. `scoring` §7 now summarises it in a
    paragraph and links, instead of reproducing the same two tables. A side
    effect: §7 no longer borrows `compose_features()`,
    `centred_correlations()` or the engagement thresholds from later pages,
    so the forward-reference paragraph added for F18 was removed again in
    the same pass. Recorded rather than quietly dropped.
  - The **split-half reliabilities** are owned by `task-validity`, which
    computes them. `task-design` §8 (F15), the `codebook` and `lessons` §4
    now describe the finding without restating the three figures.
    `performance` §5 keeps its single mention of word's 0.45, because the
    number is the point of the paragraph it sits in.
  - Not consolidated: the family rationale (x4) and the sampler diagnostics
    (x2). Both are short, and both are wanted where they sit.
- **F27.** Orientation's n = 85 against 86 is the participant who answered
  zero orientation items. Stated.
- **F29.** `n_splits`, `trials_per_feature` and `feature_labels` moved out
  of the hidden setup chunk into a visible one, so "repeated 1000 times"
  and "of the 63 that exist" can be tied to code.
- **F30.** `pmin()` applies the floor of 32 as a cap on the requirement,
  not a minimum. Reworded (done with F28).
- **F31.** `task-validity` §2's priority table is cross-linked from
  `task-design` §3, now that F11's claim is stated correctly.
- **F36.** The local `spearman_brown()` is justified in a comment for the
  same reason as the local `cronbach_alpha()`: this page shows arithmetic,
  so both formulas are visible.
- **F56.** Resolved by the "trial" sweep.
- **F57.** `composition` §6 retitled. "Do participants know they are doing
  it?" presupposes the behaviour is the fact and the report the check,
  which the section body rejects.
- **F67.** The duplicated diagnostics table is kept, with one sentence
  saying why: a reader should not have to leave the page reporting a result
  to find out whether the model sampled properly.
- **F81.** The three models saved with `save_pars(group = FALSE)` are
  named: `joint-gates`, `perf-joint-orientation`, `comp-trial-multilevel`.
- **F82.** The MARS gate is stated: GRSq > 0.
- **F88.** `feedback_trial_score` now records that the parity deduction
  applies in v2/v3 only.
- **F89.** `prognosis` described accurately: free-text, never harmonised,
  unused.

---

## 2026-08-26 — cold review, phase 3 (second batch)

- **F15.** `task-design` §8 quoted split-half reliabilities six pages before
  `task-validity` computes them. The claim is now qualitative there (word
  barely discriminates) with the figures left to the page that derives
  them, which is the sequencing rule the report states for itself.
- **F18.** `scoring` §7 borrows `compose_features()`,
  `centred_correlations()` and the engagement thresholds from two later
  pages. It now says so in a short paragraph rather than using them
  silently: the withdrawal cannot be told without them, and a reader can
  take them on trust until those pages arrive.
- **F25.** The leave-one-out standardisation figures are computed and
  displayed per version rather than asserted, on orientation.
- **F28 / F30.** `task-validity` now states that the derivation on the page
  is a demonstration and the filter downstream reads the hard-coded
  `wm_thresholds()`, printed beside it; and that `pmin()` applies the floor
  of 32 as a **cap on the requirement**, not a minimum.
- **F34.** The cross-version reverse-keying claim is checked rather than
  asserted from a v1-only page: item-total correlations for the four items
  are negative in v1 and positive in v3.
- **F53.** The predictor-selection rule is applied in a displayed table —
  every scale's correlation with VVIQ, whether it clears 0.6, whether a
  hypothesis attaches, and whether it entered.
- **F54 / F94.** `composition` §6's two deferrals to
  `inst/scripts/14-strategy-convergence.R` are brought into the page: the
  words-versus-words-and-colours contrast on the parts, and prioritisation
  against imagery group. `analysis-strategy` §8's pointer to
  `inst/planning/` is now the only remaining deferral, and it is a
  legitimate one: what it defers is the **audit trail** for pre-declaration,
  not a result.

  **Correction to my own wording.** The review calls that a
  "pre-registration pointer" (F94) and I repeated the phrase here. There is
  no preregistration for this study and nothing on the site claims one. §8
  claims pre-**declaration**, recorded in the planning documents that ship
  with the package, which is a weaker and accurate claim. `06` §7 already
  makes the distinction explicitly ("descriptive rather than
  pre-registered"). Repeating a reviewer's term without checking it against
  the files is the failure the working agreement exists to prevent.

---

## 2026-08-26 — cold review, phase 3 (first batch of [B] items)

- **F66.** `joint-gates.rds` existed and the gates-only comparison was
  asserted in a sentence. Now displayed, with the call matched to
  `inst/scripts/09` (`accuracy_features = character(0)`, `save_pars`, and
  the 0.99/15 control arguments).
- **F69.** The `inner_voice` row is genuine and needed a clause, not a
  correction. `d` is a mean difference over a pooled SD; `p` is a
  Mann-Whitney test on ranks. A distribution can be shifted in its mean and
  near-identical in its ranks, which is what one heavy tail produces. Also
  states explicitly that it is not the `tibble()` masking bug, since it
  looks exactly like it.
- **F70.** The −0.42 partial correlation with the imagery *composite* was
  asserted where the §2 heatmap runs on individual scales, before the
  composite exists. Now computed and displayed against
  `add_imagery_composite()`.
- **F72.** `beyond-vividness` gives v3 twenty because
  `questionnaire_scales()` counts people, and the repeat participant is
  counted once under v1. Stated in prose, consistent with the person /
  person-session convention set on `participants`.
- **F86.** The `target_angle` range cell is computed over all rows while
  the `responded_angle` caveat is stated over experimental blocks. Both are
  true; the range cell now says what it is computed over.
- **F87.** `score_*_z` was documented as kept "for cross-feature
  comparison", which nothing performs. Now documented as retained for
  provenance, with the reason no analysis uses it.

### Declined

- **F71** asked for the adjusted Rand index to be put in displayed output.
  It is already live — `beyond-vividness` §4 computes it inline with
  `adjusted_rand_index()`, and §4's stability table displays a second one.
  Nothing to fix.

---

## 2026-08-26 — "trial" swept, and the codebook was wrong about `item_number`

The word meant two units. `task-design` used it for the 21 encode-distract-
recall cycles; every page downstream used it for the 63 rows. Both readings
were load-bearing, and they sat two paragraphs apart in `composition`
("63 trials of behaviour" in §6, "a mean over 21 trials" in §8).

**The convention, verified against the data rather than assumed:**

- A **trial** is one encode-distract-recall cycle. 21 per participant, in
  three blocks of seven.
- An **item** is one word shown at one orientation in one colour. Three per
  trial, 63 per participant, one row of `all_data` each.

`item` rather than `stimulus`, because the column is already called
`item_number` and `analysis_helpers.R` and `task-validity` were already
using it that way ("items within a trial share an encoding episode"). The
sweep propagates the project's own usage rather than imposing a new one.

### The codebook was wrong, and so was `R/data.R`

Both described `item_number` as *"Stimulus index within the trial (1-3:
word, orientation, colour)"*. Neither part is true:

- It runs **1-63**, not 1-3 — 1-21 in block 1, 22-42 in block 2, 43-63 in
  block 3, and 1-9 in training.
- It does **not** index the features. An item row carries `target_word`,
  `target_angle` and `target_color` together, which is what lets one row
  carry three responses with independent non-response.

This misdescribes the shape of the data, so it is the most consequential
thing in this pass. `trial_number` was also imprecise: the tutorial trial
is numbered 0, not counted as the first of a running index.

### Scope

Prose, captions, figure labels and roxygen. Column names inside chunks were
renamed only where the name itself asserted the wrong unit and every
reference sat in the same file: `trials_needed` → `items_needed` and
`trials_available` → `items_available` in `task-validity`; `trials_changed`
→ `items_changed`, `of_trials` → `of_items` and `responded_trials_only` →
`responded_items_only` in `scoring`.

Left alone: `block_trials`, `v1_trials`, `trials_by_feature`,
`trials_per_feature`. These are frame names spanning several chunks; the
gain is cosmetic and the risk of a half-finished rename is not.

Correct uses that were **not** touched, since the sweep is about the unit
and not the word: `trial_number`, `trial_uid`, `trial_c`, the trial-level
compositional model, "a mean over 21 trials", "points are traded across
features within a trial", "the trial score", "randomised per trial in v3",
and `task-validity`'s split logic, which already contrasted the two units
correctly.

`task-design` §5 now states both units once, in the paragraph that defines
the block structure, so every later page has something to point at.

---

## 2026-08-26 — parity_rate added to every accuracy model

Resolves the open item left by phase 2. `performance_formula(parity =
FALSE)` had no recorded justification and was the only accuracy
specification on the site without the covariate. **Decision: add it
everywhere rather than argue for the exception.**

The reason, which is better than the one phase 2 could reconstruct:
`joint-model` §6 compares C-prime's accuracy offsets against the joint
model's, and the joint model carries `parity_rate` on its accuracy arms.
The comparison was between models with different right-hand sides while
claiming to be a like-for-like robustness check. It now is one.

**The convention, stated once so it does not drift again: `parity_rate`
goes on every arm that models how well a feature was recalled, and on no
arm that models whether it was recalled at all.** That is what
`joint_formula()` already did; everything else now matches it. The
justification is in `03` §11.6 — it is the dual-task load a participant
incurred while recalling, and it does not predict non-response.

### Refitted

| Model | Change |
|---|---|
| `perf-c-prime` | `performance_formula()` instead of `parity = FALSE` |
| `perf-a-word`, `perf-a-angle`, `perf-a-color` | `+ parity_rate` on the default univariate rhs |
| `perf-form-null`, `perf-form-group`, `perf-form-linear` | `+ parity_rate`, so all four form candidates share a rhs |
| `perf-form-segmented` | `parity_rate` on the `a` nlpar |
| `perf-joint-orientation` | `parity_rate` on the accuracy arm, not the gate |
| `alloc-full`, `alloc-vividness` | `+ parity_rate`, so §5 is comparable with §4's `comp-floor` |

Option A had to move with C-prime: `performance` §2's whole argument is
that the independent and correlated fits give nearly the same floor-group
offsets, and that is not a comparison if the two carry different
predictors. The form candidates inherit from `perf-a-angle`, so they move
too. `comp-floor`, `comp-trial-multilevel` and `joint-full` already
carried it and are unchanged.

### Also fixed here, an F91 miss from phase 0

`joint-model` §6 loaded `perf-c-prime` and `perf-joint-orientation` with
`data = model_data` — that page's **86**-participant frame, where both were
fitted on the engaged 79 — and with no priors at all. The chunk now
rebuilds the engaged frame and passes the priors `inst/scripts/10` used,
including `save_pars(group = FALSE)` on the orientation model. This was
missed in phase 0's sweep, which covered `performance` and
`model-diagnostics` but not the two fits loaded from a third page.

### Left alone deliberately

- **The gates.** `responded_*` arms in `joint_formula()`, `10` §12 and
  `joint-model` §6 carry no parity, by the convention above.
- **The NIEQ models** (`beyond-vividness` §3, `13`). The outcome is a
  questionnaire scale, not task accuracy; a dual-task load incurred during
  the WM-FTT does not belong in it.
- **`08-floor-group.R`.** Exploratory predictor-form script, predates the
  corrected parity variable, and reports nothing on the site.

### Consequences to watch on refit

`performance` §2's "the coefficients barely move" and §3's correlation
table are both re-estimated. §4's form comparison is re-run on a shifted
set of candidates. `composition` §5's "the floor-group offset is 0.095
here against 0.093 in section 4" is a transcribed pair of numbers and will
need re-reading from the new fits.

---

## 2026-08-26 — cold review, phase 2 (the [A] items)

Wrong or contradictory sentences, in file order. Most are one-line
corrections and are not recorded individually; what follows is the subset
where a judgement was made, a claim was *removed* rather than fixed, or the
outside claim was wrong.

### Counting people and counting sessions

The review asked for `group_by(id, version)` in place of `distinct(id)` on
`participants`. **Applied wholesale that is wrong**: it double-counts the
repeat participant in the age, gender and education tables, where the unit
is a person. The page now carries both frames explicitly —
`participants` (117 people) and `sessions` (118 person-sessions) — and
states in prose that one participant completed both v1 and v3. Person
tables use the first; version tables use the second. That is the reason two
totals circulate on this site, and it is now documented rather than
inferable only from a code comment in `scoring` and `task-validity`.

**A second error, not in the review.** `participants` §3 read "v2 has nine
participants and v3 has twenty, with four and one typical imagers
respectively". The typical-imager counts are transposed (v2 has one, v3
has four) and twenty should be twenty-one. Replaced with a computed
column.

### Three groupings, two called "aphantasia"

`vviq_group_4$aphantasia` is VVIQ = 16 exactly; `vviq_group_2$aphantasia`
is ≤ 32; the models use a third split. `participants` §2 now tabulates all
three with their cutoffs, matching what `R/data.R` and the `codebook`
already document, and says plainly that the two columns share a level name
and do not share its members. @reederNonvisualSpatialStrategies2024 added
to `vignettes/references.bib` (Cognition, 251, 105907) as the source for
dividing the low end at the floor, matching `general_intro.tex` l. 70.

### Claims removed rather than corrected

- **"Strategy questionnaire responses skewed toward prioritising colour"**
  named the wrong feature *and* asserted a dissociation the data
  contradict. v1 first-named is words 78, none 6, colours 3, orientations
  1; words are also the highest-scoring feature (0.934 against 0.855 and
  0.754). The surviving claim is the one `task-validity` §2 supports:
  *which* feature someone named barely moves their composition, so the two
  measures agree in aggregate without being interchangeable per person.
- **"Roughly 70% of them ... stopped doing it properly"** has no support at
  any cut. 25 of 88 answered no probe, 39 of 88 fewer than half, and none
  answered all. The 70% is almost certainly the median parity response
  rate of 0.694 — a proportion of *probes*, read as a proportion of
  *participants*.
- **"Imagery-group differences ... are absent among those who kept doing
  it"** and **"among those who did engage, word recall was worse"**: no
  support anywhere on the site or in the scripts. Deleted rather than
  hedged.

### Restored: the `moved` column

`posterior_correlations()` computes it under `lkj(4)` and `joint-model`'s
three tables were dropping it in `select()` — on exactly the fifteen
correlations the `lkj(4)` argument exists for. Restored, with a paragraph
saying what it is. `implementation-notes` §3's claim that every correlation
carries the flag is now true.

### Left open, deliberately: the parity covariate

`inst/scripts/10` calls `performance_formula(parity = FALSE)` and **no
reason is recorded anywhere** — `10-performance-modelling.md` §11.9
discusses only the old, wrong parity variable. The composition carries
`parity_rate`; the joint model carries it on the accuracy arms; `03` §11.6
argues for it.

A rationale was drafted for the vignettes and then withdrawn, because it
was invented: "for comparability with the joint model" is not only
undocumented but backwards, since the joint model does carry it. Both
`engagement` §5 and `performance` §1 now state the divergence and label it
an open inconsistency rather than a decision. **This needs an analytic
answer** — either a reason from the modelling sessions that never reached
a planning file, or a refit of `perf-c-prime` with parity — not a sentence.

### The gradient, not the group

`beyond-vividness` §3 was headed as a group difference and argued itself
out of one two paragraphs later; `README.Rmd` stated the version the page
rejects. Retitled to the gradient reading, with the group contrast marked
as superseded by the models below it, and the README bullet rewritten. This
is the finding a thesis reader carries away, so the framing was worth more
than its severity rating suggested.

---

## 2026-08-26 — cold review, phases 0 and 1

An outside reader with no prior contact with the project read the rendered
site and produced a numbered fix list. What follows records the two
structural decisions taken in response, and the reasoning, so that neither
is silently re-opened. Findings that were checked and **rejected** are
recorded here too, because a wrong outside claim costs more if it is acted
on than if it is refused.

### The root cause: vignettes were fitting nothing

Pages load cached fits with `file_refit = "never"`, and brms returns the
cached object **without checking** that the `data`, `prior` or control
arguments it was handed match the ones the fit was built with.
`R/modelling_spec.R` diagnosed this for *formulas* and solved it by
exporting the builders. Nothing protected the other three arguments, and
all three had drifted:

| Page | Displayed | Fitted (`inst/scripts/`) |
|---|---|---|
| `composition` §4 | `data = model_data` (78 rows) | 79, pre-questionnaire-join (`11`) |
| `composition` §5 | scales z-scored on the pooled 114 | z-scored on the 78 that enter (`15`) |
| `composition` §6 | the 78-row frame | 81, not filtered on VVIQ (`14`) |
| `composition` §8 | participant-level frame, no `trial_c`, no prior | trial-level, `composition_priors()`, `save_pars` (`11`) |
| `performance` §2 | no `prior` | `c_prime_priors`, incl. `lkj(2)` (`10` l. 524) |
| `model-diagnostics` §1 | wrapper defaults | `adapt_delta = 0.99`, `max_treedepth = 15` (`09`) |

**Decision: make the calls true, and check them.** The alternative — a
visible line per page saying the call is illustrative — was rejected. The
report's whole claim is that its pages are executable, and a disclaimer
leaves wrong code on display on the four most load-bearing pages.

The check is one line per participant-level model:

```r
stopifnot(nrow(model_data) == nrow(composition_model$data))
```

This is the part that matters. Making a call true is a claim; the
`stopifnot()` is what turns it into something that fails loudly. It is
deliberately **not** applied to the joint model, where `subset()` makes
the stored model frame hard to predict without running it.

`composition`'s single reassigned `model_data` is replaced by three named
frames — `reported` (81), `model_data` (79), `style_data` (78) — plus a
table that counts all four live. One live count would have caught the
whole family.

**Two knock-ons that change reported numbers**, both flagged for the next
knit rather than assumed:

- §6's convergence result moves from n = 73 to n = 76, because `14`
  states in a comment that it is deliberately not filtered on VVIQ and the
  vignette was filtering. Spearman rho goes from about −0.30 to about
  −0.33; monotone and in the same direction either way.
- §7's raw-accuracy table moves from 18 + 60 to 18 + 61.

### The primary analysis: settled by looking it up, not by taste

The review found three answers on the site to "which analysis is primary".
It is not a judgement call: `EOR-OUTLINE.md` ("Reordered 2026-08-26") and
`09` §8.8 already settled it — **the composition is primary for
allocation**, the joint model is authoritative on selection and on
willingness to report. What survived on the site was pre-reorder text.

`analysis-strategy` §4 was headed "The primary analysis: allocation" and
showed `joint_formula()`, which made §5 list the joint model among the two
models sitting around itself. §4 now shows `composition_formula()`. §4's
four-family correlation table and its three-tier pre-specification
statement existed **nowhere else on the site**, so they were moved to
`joint-model` §1 rather than deleted.

`README.Rmd` already carries the corrected framing; `README.md` and
`docs/` are stale renders of the pre-reorder version. Re-knit and rebuild.

### Added: one canonical sample table

`analysis-strategy` §6, computed live, covering 88 / 86 / 87 / 81 / 79 /
78. Every modelling page links to it instead of restating a number. The
two facts most often got wrong are stated in words beside it: the joint
model uses *more* participants than the others, and the drop from 81 to 79
is the two participants with no VVIQ.

### Checked and rejected

- **"Repoint the broken sample link, reorder the confirmatory block,
  rewrite the joint-model description."** Already correct in `README.Rmd`.
  The defects are in the generated `README.md` and `docs/index.*`. No
  source edit; re-render.
- **"Replace 'skewed toward prioritising colour' with 'words'."** The
  feature is wrong — v1 first-named is words 78, colours 3 — but swapping
  the noun leaves a *false* claim standing. Words are also the
  highest-scoring feature (0.934 against 0.855 and 0.754), so
  "self-reported priority and measured performance disagreed" is
  contradicted by the data and collides with `composition` §6's "they
  converge". Deferred to phase 2 as a rewrite, not a substitution.

---

## 2026-08-24 — parity resolved, and it was not the variable we thought

`parity_*_acc` scores unanswered probes as 0, the same convention `02`
§2.5.2 applies to recall. In v1, 3046 of the 3315 zeros on `parity_1_acc`
are unanswered probes. The participant mean everyone had been using
correlates **0.989** with the proportion of probes answered and 0.215 with
accuracy among those answered.

`compute_scores()` now adds `responded_parity_1` and `responded_parity_2`.
Regenerate `all_data` with `data-raw/04_apply_manual_review.R`.

**The confound was tested and does not exist**: parity response rate is
0.505 at the VVIQ floor against 0.495 above it, p = 0.925, tested on all
three features. `09` §6's parity risk is withdrawn, and the joint model is
unblocked because parity is not load-bearing rather than because it was
settled in parity's favour.

**Two design findings.** 25 of 88 answered no parity probe at all, 23 of
whom clear the recall engagement thresholds, so abandoning parity is
strategy rather than disengagement under v1's incentives. And parity
predicts recall accuracy at p = .14 to .63, so it is not functioning as a
load manipulation in v1 at all.

---

## 2026-08-24 — restructure, and the joint model becomes primary

**Renumbered every planning doc by analytic dependency** rather than by
the order it was written. Old numbers had drifted far enough to be
actively misleading: the floor-group doc, which is the base of every
model, was `09`; response propensity, now one of the most interesting
variables in the study, was `08`; performance modelling, now a robustness
check, was `05`. Filenames changed, content did not, so all `§n.n`
citations remain valid.

Old to new: `00`→`00`, `01`→`02`, `02`→`05`, `03`→`06`, `04`→`03`,
`05`→`10`, `06`→`11`, `07`→`13`, `08`→`04`, `09`→`08`. Scripts follow the
same mapping, per INDEX §4's rule that `script-NN` implements `plan-NN`.

**Created three stubs** for gaps the new ordering exposed:
`01-task-design.md`, `07-questionnaire-psychometrics.md`,
`12-scale-structure.md`. Each has content that exists elsewhere or in
scattered findings, and no home.

**`09-joint-model.md` created** and designated primary. Both framings in
`00-framing.md` are now secondary to it.

**The separation test failed.** `10` §11.6's joint propensity/accuracy
model on orientation returned a correlation of 0.512 [0.257, 0.719], 99.9%
above the ROPE. The consequences were declared before the number was seen:
the joint model becomes primary, and `11` inherits a caveat because its
compositional analysis is responders-only.

**Sample split recorded.** The joint model runs on all 86 participants
with VVIQ; `11` stays on the engaged 79. Different models, different
samples, both stated.

---

## 2026-08-22 to 08-24 — performance modelling planned and run

`10` §11 written as a full implementation plan before any code. Primary
structure changed from long-format Option C to **Option C-prime**:
multivariate with a per-feature response family and correlated participant
random intercepts. Families fixed by what each boundary means. Word
retained but excluded from individual-differences inference.

**Results.** Orientation and colour correlate **+0.586 [0.349, 0.764]**
between participants: the trade-off the task imposes is a within-trial
constraint, not a between-person one, and `11` §13.3's negative partial
correlations were closure artifacts. The LOO comparison of VVIQ functional
forms is flat, as predicted in advance.

**Three interface bugs**, all in code that had never been executed: the
MARS check read `$cuts` instead of the pruned terms; the multivariate
prior lacked `resp`; `loo_compare()` was handed a list of fits instead of
loo objects. A fourth, in `compose_features()`, let a lookalike column
(`score_color_raw`) match as a second source for colour and silently
collapse every colour mean to NA.

---

## 2026-08-21 — compositional analysis implemented

`11` §13 records it. Sample decided at the engaged 79, not 87. Two numbers
in the doc were found to have been computed on a superseded pooled sample
and corrected: §2's variance-share table and §8.5's partial correlations.
The "two-way trade-off" reading was **withdrawn**, since it described six
low-engagement participants who carry roughly three quarters of the
compositional variance.

**Trial-level compositions found to exist** and to be 96.3% usable, which
rescued the multilevel rationale. The SBP was resolved on substantive
grounds (word first) and the VVIQ form on pre-declaration (floor-group
additive).

**Package infrastructure**: plotting layer ported from
`aphantasiaEmotions`, script figures moved from screen-size PNG to vector
PDF at printed size, planning docs moved into `inst/planning/`.

---

## 2026-08-20 — implementation session

`11` §7's input choice **reversed**: raw responders-only means, not
standardised scores, because z-scores are roughly half negative and no
log-ratio transform accepts negative parts.

`04` §3.1: a pooled association between propensity and imagery **did not
survive stratification** by version. Recorded as the session's main
lesson, later generalised: check which sample a recorded number was
computed on before building on it.
