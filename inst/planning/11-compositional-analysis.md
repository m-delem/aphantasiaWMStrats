# WM-FTT: compositional analysis

**Status: implemented 2026-08-21** (`inst/scripts/11-compositional-analysis.R`).
**Secondary as of 2026-08-24**, and under an open caveat: see the box below.

> **This analysis is responders-only, and whether that was legitimate is
> currently being tested elsewhere.** Every composition here is built from
> trials a participant chose to answer. `10` §11.6 found that willingness
> to report and accuracy when reporting correlate at 0.512 [0.257, 0.719]
> on orientation, which is 99.9% above its ROPE. If `09-joint-model.md`'s
> selection correlations confirm that across features, this strand
> inherits an explicit caveat: its estimates condition on a selected
> subsample in a way no responders-only analysis can detect or correct.
> `09` §8.4 states what each outcome means, and it was written before the
> numbers existed. Nothing here should be written up as final until that
> model has run.
§13 is the implementation record and supersedes several earlier sections:
the sample is 81 rather than 87, §2's variance-share table and §8.5's
partial correlations were computed on a superseded sample and are
corrected there, and both open decisions (the SBP in §2, the VVIQ form)
are resolved. Read §13 before acting on §§1-12.

Earlier status, retained: amended 2026-08-20, §7's input choice
**reversed** (raw, not standardised), §2 gained two findings about the
real data, and §8.5 recorded how little the composition varies. Depends on
`02-score-computation.md`, directly implements
`00-framing.md` §2's stated obligation ("adopting the
compositional framing is a commitment to doing the transform properly,
not naive proportions") and addresses §6's flagged weakness (overall
performance level being discarded).

**Context:** this is the confirmatory/hypothesis-testing strand of the
three-strand plan (see `00-framing.md` §5) — builds a
per-participant relative-allocation profile and tests it against
researcher-defined groups (VVIQ group, continuous VVIQ), as distinct from
clustering's fully unsupervised, group-agnostic approach (separate,
not-yet-written doc).

---

## 1. The core technical requirement, confirmed against the literature

`00-framing.md` §2 already flagged that naive proportions
(sum-to-one values correlated or regressed directly) are statistically
invalid for a composition — the fixed-sum constraint induces forced
negative correlation between components, and a 3-part composition only
has 2 real degrees of freedom. This is now confirmed precisely, not just
in principle: the standard solution is a **log-ratio transform** moving
the composition off the constrained simplex into unconstrained Euclidean
space before any regression, correlation, or multilevel model is applied.
Three transform families exist (ALR, CLR, ILR); **ILR (isometric
log-ratio) is the right choice here**, because CLR produces a
rank-deficient (singular) covariance matrix that causes problems for
methods requiring matrix inversion (regression, MANOVA, most multilevel
model machinery), while ILR is full-rank by construction and designed
specifically for these downstream uses.

**Practical upshot:** the compositional pipeline is not "compute
proportions, then ternary-plot and correlate them directly" — it's
"compute proportions, then ILR-transform them into two coordinates, then
model those coordinates." The ternary plot remains a legitimate and
useful *visualisation* of the raw composition (three-way, intuitive,
doesn't require the audience to understand log-ratios), but the actual
inferential model (VVIQ-group comparison, regression against continuous
VVIQ) operates on ILR coordinates, not raw proportions. Worth being
explicit that these are two different representations serving different
purposes, not competing choices.

## 2. The one decision that must not be automated: which SBP

ILR transformation requires a **sequential binary partition (SBP)** — a
choice of which components get contrasted against which, at each step, to
build the two orthonormal coordinates from the three-part composition.
For a three-part composition there are exactly **three possible
partition structures** (small, fully enumerable, not a large search
space), but the literature is explicit and specific on a point directly
relevant here: an automated choice (e.g., an algorithm that picks
whichever partition maximises statistical contrast between groups) can
select a split the researcher has no actual substantive interest in —
the example given in the literature (choosing to contrast "spirits" vs.
"beer & wine" purely because that split shows the most between-group
variance, when the researcher actually cares about "spirits & beer" vs.
"wine") makes the failure mode concrete. **The choice must be made by the
practitioner, based on the substantive question, not by a default or an
automatic optimality criterion.**

**This is not decided in this doc.** It needs the author's direct input, framed
as a genuine substantive question about WM-FTT's three features, not a
statistical detail. Concretely, the three candidate partition structures
correspond to three different "first contrasts":

- **Word vs. (colour + orientation), then colour vs. orientation within
  the remainder** — treats word (verbal) as categorically distinct from
  the two more perceptual/spatial features, contrasted as a group. This
  has a plausible theoretical rationale (phonological-loop / verbal vs.
  visuospatial distinction, directly consistent with the existing
  parity-interference story already documented in the wiki's v1 findings —
  §4 of the original handoff, phonological-loop interference from the
  parity task specifically affecting word recall).
- **Colour vs. (word + orientation), then word vs. orientation within
  the remainder** — treats colour as categorically distinct, less
  obviously theoretically motivated given WM-FTT's design, unless there's
  a reason colour specifically should be treated as the odd one out.
- **Orientation vs. (word + colour), then word vs. colour within the
  remainder** — treats orientation (spatial) as categorically distinct;
  plausible if the theoretical interest is specifically spatial vs.
  non-spatial representation.

**Recommendation, offered as a starting point for discussion, not a
decision:** the word-vs-(colour+orientation) partition has the clearest
existing theoretical grounding in WM-FTT's own prior findings (the
verbal/phonological-interference story already written up on the wiki),
which would make the compositional analysis's first coordinate directly
interpretable as "verbal vs. non-verbal allocation" — a natural fit with
aphantasia's own theoretical framing (absence of *visual* imagery
specifically, verbal/semantic strategies as the documented compensatory
route per the literature search from the philosophy discussion). But this
is the author's call, not a default to accept without discussion — flagged
explicitly as the one open design decision this doc does not resolve.

**Amendment 2026-08-20: the recommendation stands, and two things now
known about the real data make it harder rather than easier.**

**The recommended contrast is the low-variance one.** Computing all three
partitions on the current data (responders-only participant means, 117
usable units), the share of total ILR variance carried by the first
coordinate is:

| First contrast | var(ilr1) | var(ilr2) | ilr1 share |
|---|---|---|---|
| Word vs (colour + orientation) | 0.0228 | 0.0364 | 39% |
| Colour vs (word + orientation) | 0.0168 | 0.0424 | 28% |
| **Orientation vs (word + colour)** | 0.0491 | 0.0101 | **83%** |

The theoretically motivated partition puts most of the variance in the
*second*, less interpretable coordinate. The orientation-first partition
concentrates it in the first.

**This is not a reason to switch, and switching on this basis would be
exactly the error this section warns against.** §2's whole argument is
that an automated or contrast-maximising choice can select a split the
researcher has no substantive interest in, with the spirits/beer/wine
example given precisely to make that failure mode concrete. Choosing
orientation-first *because* it carries 83% of the variance is that
example, performed deliberately. The variance split is a **limitation to
state in the writeup** — the verbal/non-verbal coordinate is the weaker
one in this sample — not a criterion to optimise against.

**The recommended contrast is also the axis most contaminated by
non-response.** Per-group non-response rates:

| | Aphantasia | Typical | Ratio |
|---|---|---|---|
| Word | 12.9% | 7.6% | 1.7 |
| Colour + orientation | 21.7% | 7.7% | 2.8 |

If the composition were built from score-0 values, the first ILR
coordinate under the recommended partition would partly encode *which
features participants declined to answer* — and since the group gap is
much wider on the non-verbal pair, that contamination falls almost
entirely on the verbal/non-verbal contrast. §7's responded-only
requirement is what prevents this, and it is load-bearing for the
verbal/non-verbal interpretation specifically, not a general hygiene note.

**Note on what the group gap does and does not show.** These rates are
pooled across versions, and the underlying association between
non-response and imagery does not survive stratification — within v1 it is
null except marginally for colour (`04-response-propensity.md` §3.1).
That weakens the substantive claim about aphantasics but **not** the
methodological one here: the composition would still be contaminated by
whatever drives the differential non-response, version composition
included, and the fix is the same either way.

## 3. Model structure: `brms`-native compositional multilevel modelling exists as real, working infrastructure

Directly relevant to the fully-Bayesian `brms` workflow already adopted:
`multilevelcoda` is a real, actively maintained R package implementing
exactly "Bayesian multilevel models for compositional data," built as a
`brms` wrapper (not a separate modelling framework to learn from scratch).
Mechanics, confirmed via package documentation:

- `complr()` computes the ILR coordinates from raw compositional parts,
  given an SBP specification (§2's decision feeds directly into this
  call).
- `brmcoda()` wraps `brm()`, fitting the ILR coordinates as a **multivariate
  outcome** via `mvbind()` (same underlying `brms` mechanism flagged in
  `10-performance-modelling.md` for Option B) — e.g.
  `mvbind(ilr1, ilr2) ~ predictors + (1 | ID)`.
- Supports multilevel structure natively (random effects, e.g. `(1|ID)`,
  extendable to richer structures) and post-hoc tools for interpreting
  results back in compositional terms (not just raw ILR-coordinate
  output, which isn't directly interpretable on its own).

**Why this is a better fit here than hand-rolling the ILR transform and
feeding coordinates into a bare `brms` call:** `multilevelcoda` handles
the coordinate construction, the back-transformation for interpretation,
and documented post-hoc functions for group comparisons — exactly the
kind of "make the results explicit and interpretable" tooling commitment
already made for the performance model's Option C
(`10-performance-modelling.md` §4). Worth treating this as the default
implementation path rather than reimplementing ILR machinery from
scratch, unless a specific limitation is found once real data is in hand.

**Difference from `10`'s Option B, worth being precise about:** `10`
rejected `mvbind()`/`rescor` specifically because forcing a Gaussian
family onto bounded [0,1] *raw* similarity scores was a distributional
mismatch. Here, the multivariate outcome is **ILR coordinates**, which
live in unconstrained Euclidean space by construction (that's the whole
point of the transform) — a Gaussian-family multivariate model is
actually the *appropriate* choice for ILR coordinates, not a mismatch.
This is not an inconsistency with `10`'s reasoning; it's the same
reasoning correctly applied to a different (already-transformed) outcome
space.

## 4. Retaining overall performance level — direct fix for a named weakness

`00-framing.md` §6 flagged directly: pure compositional
analysis discards overall performance level by construction (two
participants with identical relative-allocation profiles but very
different absolute totals look identical). **Decided:** this is not
solved *within* the compositional model itself — trying to smuggle a
"total" dimension into the ILR coordinates would undermine the
compositional transform's own logic (it's specifically designed to
represent relative allocation, independent of scale). Instead, this is
explicitly the job of **Option D in `10-performance-modelling.md`**
(the total-performance model) — the two are complementary by design, not
competing solutions to the same gap. Worth stating this connection
explicitly in the eventual writeup so a reader doesn't wonder why the
compositional analysis "ignores" overall level — it doesn't ignore it, it
deliberately hands that question to a different, purpose-built model.

## 5. VVIQ group comparison and continuous regression — both in scope

Per `00-framing.md` §5's framing (compositional = broad,
exploratory-but-confirmatory hypothesis testing against researcher-defined
groups): the compositional model should support both

- **Group comparison**: do ILR-coordinate compositions differ between
  VVIQ groups (aphantasia / hypophantasia / typical / hyperphantasia,
  per the categorical grouping already used elsewhere in the project)?
- **Continuous regression**: does composition relate to continuous VVIQ
  score, not just categorical group?

`multilevelcoda`'s `brmcoda()` formula syntax supports both directly
(predictor can be categorical or continuous on the right-hand side of the
`mvbind()` formula) — no separate modelling approach needed for the two
questions, they're the same model structure with a different predictor
specification.

## 6. Version/pooling integration — resolved, v1 only

**Resolved 2026-08-20 (`05-version-scope.md` §3.5): v1 (N=88) only, so
no version grouping factor and no pooled-versus-per-version question.**
Note this does not rescue §8.5's concern: the composition varies just as
little within v1 (SD 0.030 / 0.039 / 0.028 on the three parts) as it does
pooled, so the stability gate stands unchanged.

### 6.1 Original version/pooling reasoning, now superseded

Same status as `10-performance-modelling.md` §6: falls under
`05-version-scope.md`'s "needs pooling for power" case. Given the ILR
transform itself doesn't change the sample-size problem (still N=118
pooled / N=21 for v3 alone), the same considerations apply directly:
version as a potential multilevel grouping factor, kept as an option
rather than committed by default, deferred to empirical estimability
checks once real data is available — not re-litigated in detail here,
`05-version-scope.md`'s decision procedure governs this doc the same
way it governs `10`.

## 7. Standardised vs. raw scores as compositional input

**Reversed 2026-08-20. The answer is raw, not standardised.** §7 as
originally written assigned the standardised (per-version z-scored) scores
per `02-score-computation.md` §4, and asked implementers to "confirm this
is still the intended input at implementation time". That check has now
fired.

**Standardised scores cannot be used at all.** Every log-ratio transform,
ILR included, requires strictly positive parts. Of 22302 standardised
score values in the current data, **6321 are negative** — z-scores are
mean-zero by construction, so roughly half of every feature sits below
zero. There is no zero-replacement strategy for this; it is not a
sparse-zeros problem, it is the wrong number line.

**And the reason for preferring them does not hold.** §7's stated
rationale was that "proportions computed from raw values on mismatched
difficulty/variance scales would be dominated by whichever feature happens
to have the larger raw range or variance". That was written before the
scores existed. Both of `02` §2's transforms — Gonthier edit-distance for
word, cosine for colour and orientation — produce values on **[0, 1] by
construction**. The ranges are identical, so the domination problem the
standardisation was meant to solve does not arise for this composition.

Note this does not overturn `02` §4's general logic, which correctly says
different strands need different things from "comparable". It overturns
one application of it, made before the scores were built.

**Additional constraint: the composition must be built from responded
trials only.** Per `04-response-propensity.md`, non-responses are scored 0
and non-response rates differ by imagery group and by feature. A
composition computed from those zeros does not measure relative
allocation — it partly measures which features the participant declined
to answer, which is a separate quantity with its own doc. Use
`score_*[responded_*]` participant means as the compositional parts.

**Participants with no responded trials on a feature** have a structural
missing part, not a zero, and must be dropped from the composition
entirely, since a composition requires all three parts. One unit of 118 is
affected at present, leaving 117 usable.

## 8. Parity engagement's place in this strand

Per `03-parity-engagement.md` §5, parity accuracy's default use is as a
continuous covariate in modelling. For the compositional model
specifically, this means parity accuracy as an additional predictor
alongside VVIQ group/continuous VVIQ in the `brmcoda()` formula, not a
filter — consistent with `06`'s stated default (covariate over filter)
and avoiding yet another silent sample-size reduction on top of the
v2/v3 constraints already in play.

## 8.5 How much the composition actually varies — a limitation to state

**New, 2026-08-20.** Computed on responders-only participant means, the
composition is close to an even split for almost everyone:

| Part | Mean | SD | Range |
|---|---|---|---|
| Word | 0.368 | 0.034 | 0.188 – 0.528 |
| Orientation | 0.291 | 0.038 | 0.034 – 0.398 |
| Colour | 0.341 | 0.027 | 0.269 – 0.439 |

Two things follow.

**The task did not achieve the three-way trade-off it was designed for.**
Word recall is too easy: median responders-only word score is 0.934, with
87 of 118 units above 0.90. Participants can max the verbal feature
cheaply and then divide remaining effort between the other two. Partial
correlations between participant means, controlling overall level, are
−0.634 (orientation–colour), −0.462 (word–orientation) and −0.275
(word–colour). Read these against the roughly −0.5 that residualising
three variables on their own mean induces by construction: orientation and
colour trade off **more** than closure alone predicts, word and colour
**less**. The real competition is between the two non-verbal features,
with word largely free. This is a task-design finding worth recording
explicitly for any future WM-FTT version — longer words, more items per
trial, or shorter exposure would be the levers.

**Whether the composition is interpretable at all is an empirical question
with an existing gate.** With parts varying by an SD of roughly 0.03, much
of the observed spread could be measurement error rather than trait-like
allocation. `06-task-validity.md` §2.2 already specifies the right test:
split-half stability of the composition itself, computed on odd versus
even trials per participant. **Result 2026-08-20: the gate passes.** Split-half stability of the
composition, 1000 random trial-level splits on the 81 v1 participants
clearing all engagement thresholds, Spearman-Brown corrected: ilr1 = 0.771
[0.692, 0.837], ilr2 = 0.721 [0.598, 0.804]. Profiles are reasonably
stable despite the parts' small spread, so this strand proceeds as a
result rather than as a documented attempt.

**But note the tension with §2.1's reliability result:** word's own
split-half reliability is 0.445, below the conventional floor. ilr1 — the
theoretically motivated coordinate — rests partly on word. A ratio can
carry information a level does not, so this is not a contradiction, but
the verbal/non-verbal interpretation must not lean on word as a
well-measured quantity, and the writeup should say so.

**Original decision, retained: run §2.2 before interpreting any
compositional result, and treat it as a gate rather than a diagnostic.**
If profiles are not stable across random trial splits, the ternary plot is
displaying noise and this strand should be reported as attempted and
inconclusive rather than presented as a result. Note that §2.2 must itself
be run on responded-only compositions, since a participant who
consistently declines a feature will show a spuriously *stable* profile.

## 9. What this doc deliberately does not do

- Does not decide the SBP/partition choice (§2) — explicitly left open,
  needs the author's direct input.
- Does not re-design the version/pooling question — governed by
  `05-version-scope.md`, referenced not repeated.
- Does not attempt to fold "overall performance level" into the
  compositional model itself — that's `10`'s Option D, by design (§4).
- Does not design the ternary-plot visualisation in detail — flagged as a
  legitimate complementary output (§1) but not scoped here; likely belongs
  with the broader plotting/legacy-code disposition question, not yet
  addressed in any doc.

## 10. Summary of decisions

| Decision | Choice | Status |
|---|---|---|
| Naive proportions as model input | Rejected — statistically invalid for inference | Settled |
| Transform family | ILR (not ALR/CLR) — full-rank, designed for regression/multilevel use | Settled |
| SBP / partition choice | **Word vs (colour + orientation)**, on substantive grounds (§13.5) | Resolved 2026-08-21 |
| Modelling infrastructure | Hand-rolled ILR plus `brms`, not `multilevelcoda` (§13.7) | Changed 2026-08-21 |
| Ternary plots | Kept as visualisation only, not the inferential model | Settled |
| Overall-level gap | Not solved here — explicitly handed to `10`'s Option D | Settled |
| Group comparison vs. continuous VVIQ regression | Both in scope, same model structure | Settled |
| Version/pooling | Governed by `05-version-scope.md`, not re-decided | Settled (deferred) |
| Input scores | **Raw**, responders-only participant means — standardised scores are ~50% negative and unusable for any log-ratio transform (§7) | Reversed 2026-08-20 |
| Analysis sample | 81 clearing the engagement thresholds, 79 with VVIQ (§13.1) | Changed 2026-08-21 |
| SBP choice given the variance split | Recommendation unchanged; variance split recorded as a limitation, explicitly not used as a criterion (§2) | Settled 2026-08-20 |
| Interpretability of the composition | Gated on `06` §2.2's split-half stability check, run before any interpretation (§8.5) | Settled 2026-08-20 |
| Parity engagement | Continuous covariate, per `03-parity-engagement.md` §5, but see §13.7's flag | Settled, flagged |
| VVIQ functional form | Floor-group additive, pre-declared primary, with a five-model LOO comparison (§13.6) | Resolved 2026-08-21 |
| Multilevel structure | Trial-level compositions exist and are modelled (§13.4) | Added 2026-08-21 |

## 11. Open questions, not resolved here

- ~~**SBP/partition choice (§2)**~~ **RESOLVED 2026-08-21** (§13.5):
  word vs (colour + orientation), on substantive grounds. The variance
  argument that made this look expensive was itself an artifact (§13.2).
- ~~Whether this strand survives `06` §2.2's stability gate~~ **RESOLVED
  2026-08-20**: it passes (§8.5). This is a result, not a documented
  attempt.
- Whether `multilevelcoda`'s post-hoc/interpretation functions cover
  everything needed for the "make results explicit and interpretable"
  goal, or whether custom `tidybayes`/`bayesplot` work (as scoped for
  performance modelling's Option C) is also needed here — check once the
  package is actually used against real data.
- ~~Ternary-plot implementation specifics~~ **RESOLVED 2026-08-21**:
  `plot_composition_ternary()`, built on `coda.plot`'s primitives (§13.7).

## 12. Next steps (not this doc)

All of §12's original next steps are done or superseded by §13. What
remains:

- Run the Bayesian fits. Everything up to §13.6 has been executed; no
  `brms` model in the script has been.
- Decide the parity covariate's form properly in
  `03-parity-engagement.md` (§13.7).
- Write the EOR vignette page for this strand once the fits have run.

## 13. Implementation record, 2026-08-21

Written during the session that implemented this doc as
`inst/scripts/11-compositional-analysis.R`, with helpers in
`R/composition.R`, `R/ggplot_tools.R`, `R/plot_composition.R` and
`R/modelling_tools.R`. Records four doc-versus-data mismatches, resolves
the two decisions §§2 and 5 left open, and documents one departure from
§3's tooling choice. Everything through §13.5 has been executed against
the real data; the Bayesian fits have not, and §13.7 says what that means.

### 13.1 Sample: 81, not 87

`11` §7 asks only that units with a structurally missing part be dropped,
which in v1 removes one participant of 88 and leaves 87. `06` §2.2's
stability gate, the result that licenses this whole strand, was computed on
the 81 participants clearing the engagement thresholds of `06` §2.1. The
two docs specify different samples for the same object.

**Decided: the threshold-clearing sample, n = 81, and n = 79 once VVIQ is
required.** Two reasons, in order of weight. The gate applies to B and not
to A, so running the models on A would mean interpreting a composition
whose stability has not been established. And the six units the thresholds
remove are not marginal cases:

| id (prefix) | word | orientation | colour | responded trials (w/o/c) |
|---|---|---|---|---|
| ccaz3247 | 0.410 | 0.225 | 0.365 | 53 / 8 / 55 |
| dnjl8459 | 0.394 | 0.234 | 0.372 | 57 / 9 / 37 |
| **dzvq2885** | 0.528 | **0.034** | 0.439 | 59 / **1** / 22 |
| ihaz8589 | 0.375 | 0.250 | 0.375 | 29 / 32 / 29 |
| kfot8386 | 0.355 | 0.264 | 0.381 | 42 / 5 / 40 |
| nfro6721 | 0.389 | 0.235 | 0.376 | 47 / 10 / 52 |

Five answered between 1 and 10 of the 63 orientation trials. One answered
a single trial. A composition resting on one responded trial is not an
allocation profile.

**This is a decision, and the writeup should present it as one.** Both
samples are reported side by side in §2 and §3 of the script so a reader
can see what the choice does rather than take it on trust.

### 13.2 The variance split in §2's amendment is an artifact of those six units

`11` §2's amendment records the share of ILR variance carried by the first
coordinate as 39% / 28% / 83% for the three candidate first contrasts, and
treats the gap as the awkward fact that makes the theoretically motivated
partition expensive. Those figures were computed on 117 pooled units with
no engagement filter, a sample `05` §3.5 has since retired.

Recomputed on v1:

| First contrast | A (n = 87) | B (n = 81) |
|---|---|---|
| Word vs (colour + orientation) | 31% | **44%** |
| Colour vs (word + orientation) | 30% | 48% |
| Orientation vs (word + colour) | 89% | **58%** |
| Total ILR variance | 0.0665 | 0.0179 |

The six units carry roughly three quarters of the total compositional
variance. On the analysis sample the three partitions are close to
comparable and the tension `11` §2 describes largely dissolves.

**This must not be presented as the reason for the partition choice.** It
is a correction to a number computed on a superseded sample, and the
sample rule was fixed in `06` §2.1 before any contact with VVIQ, so it was
not selected to produce this. Recording the sequence matters: the
correction happens to favour the option already preferred on theoretical
grounds, and a reader is entitled to check that the preference did not
drive the correction.

### 13.3 §8.5's two-way trade-off does not survive the engagement filter

`11` §8.5 reports partial correlations between participant means,
controlling overall level, of -0.634 (orientation/colour), -0.462
(word/orientation) and -0.275 (word/colour), and reads them against the
roughly -0.5 that residualising three variables on their own mean induces
by construction. The conclusion drawn is that orientation and colour trade
off more than closure predicts while word is largely free, so the task
achieves a two-way rather than a three-way trade-off.

On v1:

| Pair | A (n = 87) | B (n = 81) |
|---|---|---|
| Orientation / colour | -0.644 | -0.552 |
| Word / orientation | -0.612 | -0.457 |
| Word / colour | -0.211 | -0.489 |

On B all three sit near the closure baseline. **The two-way trade-off
reading describes the same six low-engagement units and should be
withdrawn**, or restated as a property of participants who largely declined
one feature, which is `04`'s quantity rather than this one.

What is untouched: word is 90% at ceiling with a split-half reliability of
0.445 and a precision criterion asking for 93 of 63 trials. The v4
recommendation to make word harder (`INDEX` §5) stands on those grounds.
Only its "the task achieved a two-way trade-off" justification goes.

### 13.4 Each trial is a composition, so §3's multilevel rationale is right

`11` §3 argues for `multilevelcoda` partly because it "supports multilevel
structure natively". The participant-level analysis has one composition per
person, where a participant random effect is unidentifiable. But each trial
is a composition of three feature scores in its own right, and that
structure does exist. Whether it survives a log-ratio transform is an
empirical question about zeros, and it does:

| | count | share |
|---|---|---|
| Trial-level compositions (79 x 21) | 1659 | |
| Missing a part (no responded item for that feature) | 57 | 3.4% |
| Containing an exact zero part (all on word) | 6 | 0.4% |
| **Usable with no zero replacement** | **1596** | **96.2%** |

Orientation and colour never score exactly zero, because cosine similarity
on a continuous wheel essentially never returns 0, and word survives
because each trial's part averages up to three items. The 63 unusable rows
are dropped rather than imputed: there is no zero-replacement strategy
worth defending for 0.4% of rows, and an unbalanced multilevel model
handles the loss natively.

**Added to the plan: a trial-level multilevel model, as the secondary
analysis, reported regardless of what it shows.** It contributes three
things the participant-level model cannot: the between-person composition
estimated with within-person noise separated out rather than averaged in,
which is the right treatment of the word-reliability problem rather than a
caveat about it; an ICC per ILR coordinate, a model-based reliability that
complements `06` §2.2's split-half 0.771 / 0.721 and comes from the same
fit as the effects; and independence from the engagement threshold, which
currently doubles as a fix for unequal trial counts.

**One thing the writeup must not do.** The ILR of a mean is not the mean of
the ILRs. The participant-level outcome and the multilevel model's
between-person quantity are different quantities, not one estimated better
than the other, and presenting them as a single result reported twice would
be wrong.

### 13.5 The SBP is resolved: word first

**Decided: word vs (colour + orientation), then colour vs orientation.**
On substantive grounds, per `11` §2: the verbal versus non-verbal contrast
is what the thesis argues about, and the compensatory-verbal-strategy
framing is the reason this study exists.

Three things make the choice cheaper than `11` §2 feared.

**Any two-coordinate ILR basis is a rotation of the same geometry.** Fitted
as a genuine multivariate model with residual correlation estimated, the
omnibus test, the Aitchison distances, the total variance and the model fit
do not depend on the partition. What depends on it is which
single-coordinate claim can be stated. The choice is a reporting basis, not
a constraint on what the data can show. Two conditions: both coordinates go
in one model with `rescor` estimated, not two separate fits, and priors stay
symmetric across coordinates. Both are enforced in the script.

**The gate is partition-specific.** `06` §2.2's 0.771 / 0.721 were computed
for this partition. Switching would leave the strand without a cleared gate
until `06a-reliability.R` is re-run, which is a concrete cost of switching
that `11` §2 did not have in view.

**The variance argument for switching has shrunk**, per §13.2 above.

**Reporting commitment, pre-declared:** the omnibus effect is the headline,
both word-first coordinates carry the interpretation, and the
orientation-first rotation goes in the EOR as a completeness appendix. Fixing
that now makes the appendix a full presentation rather than a second attempt
at significance.

**The reliability tension stands and is not resolved by any of this.** ilr1
rests partly on word, whose own split-half reliability is 0.445. A ratio can
be stable where a level is not, and the gate says it is, but no claim may
treat word as a well-measured quantity. Switching partitions would not fix
this, it would move word into ilr2.

### 13.6 VVIQ is resolved: floor-group form, with a comparison

**Decided: `vviq + complete_aphant` is the pre-declared primary**, per
`08-predictor-form.md`. It matches `aphantasiaEmotions` and
`inst/scripts/08-floor-group.R`, the v1 VVIQ distribution is close to
bimodal (18 of 79 at exactly 16) so a pure linear term is mis-specified,
and it nests `11` §5's group and continuous questions in one structure.

`08` §4's finding that the continuous term does no work once the floor term
is present was established on per-feature accuracy, not on ILR coordinates,
so it is not imported. It is tested.

**Model space, following the `aphantasiaEmotions` comparison arc but much
smaller:** intercept only, two-group split, linear VVIQ, floor-group
additive, and floor-group without the parity covariate. Compared by LOO.

Two of aphEmo's six candidates are unavailable or ill-conditioned here.
The four-group categorical is out by `05` §3.5 (hyperphantasia n = 3). A
GAM would be smoothing a spike at one x value plus a sparse tail.

**The segmented model is in, after a correction.** The MARS pre-check was
written to skip it if no interior knot appeared, on the reasoning that
only 6 of 79 participants lie between VVIQ 17 and 25, so there might be
nothing in the region a knot would occupy. The check as first written read
`earth::earth()$cuts` whole, which carries the candidate terms the
backward pass discards as well as the ones it keeps, and reported five
knots where the fitted model has one. Read off the pruned model instead:

| Coordinate | Terms retained | Knots | RSq | GRSq |
|---|---|---|---|---|
| ilr1 | 2 of 7 | **25** | 0.116 | 0.068 |
| ilr2 | 1 of 7 | none | 0.000 | 0.000 |

A single interior knot at VVIQ 25, close to aphEmo's MARS seed of 24 and
to its estimated knot of 19.5. The segmented model is therefore fitted,
seeded from that value, and the gate is left in the script so that a
future change in the data fails loudly rather than silently.

**The comparison runs on ilr1 only, and the correction is why.** MARS
reduces ilr2 to an intercept: there is no shape there to choose a
functional form for, and fitting four nonlinear parameters to it would be
fitting noise. Univariate elpd values are comparable within the
comparison table; they are not comparable with the multivariate fits used
for inference, and the two tables are kept apart for that reason. The
multivariate floor-group model, with `rescor` estimated, remains the
model the compositional claims rest on.

That MARS explains 11.6% of ilr1's variance and 0% of ilr2's is itself
worth noting, cautiously: it is a flexible fit on 79 points with no
uncertainty attached, but it points at the verbal/non-verbal coordinate
rather than at colour versus orientation.

### 13.7 Departures, flags and what has not been run

**Departure from `11` §3: the ILR transform is hand-rolled, not
`multilevelcoda`.** The transform is eleven lines, it already exists in
`06a-reliability.R`, and writing it out keeps the SBP visible in the code
rather than buried in a `complr()` argument. `multilevelcoda`'s
between-within decomposition is the one thing it genuinely adds, and it is
reproducible by hand from the same fit. Revisit if the trial-level model
turns out to need substitution analyses.

**Flag: parity accuracy is not a smooth covariate.** `11` §8 specifies it as
a continuous predictor. In v1 a quarter of the sample sits at exactly 0.00,
because v1 carries no parity penalty (`05` §3.5) and the measure is
therefore motivational. It is kept continuous, because that is the stated
default, and the primary model is also fitted without it so the choice can
be inspected. `03-parity-engagement.md` should decide the form properly.

**Flag: two of the 87 units have no VVIQ**, so the modelling sample is 79
rather than 81.

**Two bugs found when the script was first run, both worth recording
because both produced plausible-looking output rather than an error.** The
MARS pre-check read the wrong field and reported five knots instead of one
(§13.6); had nobody looked, the conclusion drawn would have been that no
single breakpoint exists, which is the opposite of what the fit says. And
the prior was specified as `class = "b"` with no `resp`, which matches no
parameter in a multivariate model: older brms versions silently accept it
as a global default, recent ones reject it outright. The fix is one prior
per response.

A third surfaced on the first run that reached the comparison:
`loo_compare()` dispatches on its first argument, so handing it a list of
fits sends it to loo's default method, which wants loo objects. Attach the
criterion to each fit and compare the extracted loo objects instead, which
is what brms does internally. None of the three was a modelling error;
all three were interface errors in code that had never been executed.

**Resolved in passing:** `INDEX` §3's legacy-plotting-code question and
`11` §9's deferred ternary design. There is no `plot_wm_composition()` in
the current package, only in the waiting-room, and it drives `coda.plot`
through `p$layers[[i]]$geom$default_aes`, which breaks silently on ggplot2
updates. The new `plot_composition_ternary()` uses the same `coda.plot`
engine through its public primitives instead.

**What has been run:** sample construction, descriptives, the partition
table, both composition figures, and the restyled figures from scripts 01
to 03. **What has not:** every `brms` fit, and therefore figures c3, c4 and
c5. Set `TEST_RUN <- TRUE` at the top of the script for a fast pass that
checks the pipeline executes end to end before committing to full sampling;
it fits two chains of 100 iterations on six trials per participant and
caches under a `test-` prefix, so a smoke test cannot overwrite a real fit.

### 13.8 Where the decisions now live

§10's summary table has been updated in place rather than duplicated here,
so it remains the single authoritative list of this doc's decisions.
