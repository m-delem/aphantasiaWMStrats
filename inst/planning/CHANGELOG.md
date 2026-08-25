# Planning changelog

Chronology only. Decisions and their reasoning live in the docs; this file
records **when** things changed and in what order, and points into them.

The reason it exists: doc numbers used to encode chronology, which meant
they had to move whenever the analysis was reordered. They now encode
analytic dependency, which is stable. Sequence lives here instead.

---

## 2026-08-24 — joint model specified and coded

`inst/scripts/09-joint-model.R` written. Reporting set hard-coded from
`09` §8.3 so it cannot drift with the fit. Staged: gates first, then all
six, with `INCLUDE_PARITY` and `INCLUDE_WORD_ACC` as the documented
fallback switches.

---

## 2026-08-24 — joint model specified

`09` §8 written before fitting and checked against brms without compiling,
so the parameter list is the model's own. 54 parameters, of which the 15
correlations are the point. The reporting set is fixed in three tiers in
§8.3, with §8.4 stating what each possible result would mean before it
exists.

Sample is all 86 with VVIQ; the engagement thresholds are deliberately not
applied, because the model forms no participant means. `10` and `11` stay
on 79, so every reported quantity has to name its sample.

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
