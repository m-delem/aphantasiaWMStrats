# WM-FTT: compositional analysis

**Status:** amended 2026-08-20 — §7's input choice is **reversed** (raw, not standardised), §2 gains two findings about the real data, and §8.5 records how little the composition varies. Technical approach and tooling identified; one substantive
design decision (sequential binary partition / feature pairing) explicitly
left for Maël rather than picked automatically, since the literature itself
says this shouldn't be an automated choice. Depends on
`01-score-computation.md` (standardised per-feature scores), directly
implements `00-analytical-philosophy.md` §2's stated obligation
("adopting the compositional framing is a commitment to doing the
transform properly, not naive proportions") and addresses §6's flagged
weakness (overall performance level being discarded).

**Context:** this is the confirmatory/hypothesis-testing strand of the
three-strand plan (see `00-analytical-philosophy.md` §5) — builds a
per-participant relative-allocation profile and tests it against
researcher-defined groups (VVIQ group, continuous VVIQ), as distinct from
clustering's fully unsupervised, group-agnostic approach (separate,
not-yet-written doc).

---

## 1. The core technical requirement, confirmed against the literature

`00-analytical-philosophy.md` §2 already flagged that naive proportions
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

**This is not decided in this doc.** It needs Maël's direct input, framed
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
is Maël's call, not a default to accept without discussion — flagged
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
null except marginally for colour (`08-response-propensity.md` §3.1).
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
  `05-performance-modelling.md` for Option B) — e.g.
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
(`05-performance-modelling.md` §4). Worth treating this as the default
implementation path rather than reimplementing ILR machinery from
scratch, unless a specific limitation is found once real data is in hand.

**Difference from `05`'s Option B, worth being precise about:** `05`
rejected `mvbind()`/`rescor` specifically because forcing a Gaussian
family onto bounded [0,1] *raw* similarity scores was a distributional
mismatch. Here, the multivariate outcome is **ILR coordinates**, which
live in unconstrained Euclidean space by construction (that's the whole
point of the transform) — a Gaussian-family multivariate model is
actually the *appropriate* choice for ILR coordinates, not a mismatch.
This is not an inconsistency with `05`'s reasoning; it's the same
reasoning correctly applied to a different (already-transformed) outcome
space.

## 4. Retaining overall performance level — direct fix for a named weakness

`00-analytical-philosophy.md` §6 flagged directly: pure compositional
analysis discards overall performance level by construction (two
participants with identical relative-allocation profiles but very
different absolute totals look identical). **Decided:** this is not
solved *within* the compositional model itself — trying to smuggle a
"total" dimension into the ILR coordinates would undermine the
compositional transform's own logic (it's specifically designed to
represent relative allocation, independent of scale). Instead, this is
explicitly the job of **Option D in `05-performance-modelling.md`**
(the total-performance model) — the two are complementary by design, not
competing solutions to the same gap. Worth stating this connection
explicitly in the eventual writeup so a reader doesn't wonder why the
compositional analysis "ignores" overall level — it doesn't ignore it, it
deliberately hands that question to a different, purpose-built model.

## 5. VVIQ group comparison and continuous regression — both in scope

Per `00-analytical-philosophy.md` §5's framing (compositional = broad,
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

**Resolved 2026-08-20 (`02-pooling-strategy.md` §3.5): v1 (N=88) only, so
no version grouping factor and no pooled-versus-per-version question.**
Note this does not rescue §8.5's concern: the composition varies just as
little within v1 (SD 0.030 / 0.039 / 0.028 on the three parts) as it does
pooled, so the stability gate stands unchanged.

### 6.1 Original version/pooling reasoning, now superseded

Same status as `05-performance-modelling.md` §6: falls under
`04-pooling-strategy.md`'s "needs pooling for power" case. Given the ILR
transform itself doesn't change the sample-size problem (still N=118
pooled / N=21 for v3 alone), the same considerations apply directly:
version as a potential multilevel grouping factor, kept as an option
rather than committed by default, deferred to empirical estimability
checks once real data is available — not re-litigated in detail here,
`04-pooling-strategy.md`'s decision procedure governs this doc the same
way it governs `05`.

## 7. Standardised vs. raw scores as compositional input

**Reversed 2026-08-20. The answer is raw, not standardised.** §7 as
originally written assigned the standardised (per-version z-scored) scores
per `01-score-computation.md` §4, and asked implementers to "confirm this
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
scores existed. Both of `01` §2's transforms — Gonthier edit-distance for
word, cosine for colour and orientation — produce values on **[0, 1] by
construction**. The ranges are identical, so the domination problem the
standardisation was meant to solve does not arise for this composition.

Note this does not overturn `01` §4's general logic, which correctly says
different strands need different things from "comparable". It overturns
one application of it, made before the scores were built.

**Additional constraint: the composition must be built from responded
trials only.** Per `08-response-propensity.md`, non-responses are scored 0
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
filter — consistent with `03`'s stated default (covariate over filter)
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
allocation. `03-validity-checks.md` §2.2 already specifies the right test:
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
  needs Maël's direct input.
- Does not re-design the version/pooling question — governed by
  `04-pooling-strategy.md`, referenced not repeated.
- Does not attempt to fold "overall performance level" into the
  compositional model itself — that's `05`'s Option D, by design (§4).
- Does not design the ternary-plot visualisation in detail — flagged as a
  legitimate complementary output (§1) but not scoped here; likely belongs
  with the broader plotting/legacy-code disposition question, not yet
  addressed in any doc.

## 10. Summary of decisions

| Decision | Choice | Status |
|---|---|---|
| Naive proportions as model input | Rejected — statistically invalid for inference | Settled |
| Transform family | ILR (not ALR/CLR) — full-rank, designed for regression/multilevel use | Settled |
| SBP / partition choice | **Not decided — needs Maël's direct input**, three candidates outlined (§2) | Open, flagged as decision-needed |
| Modelling infrastructure | `multilevelcoda` (`brms`-native), not hand-rolled ILR + bare `brms` | Settled as default path |
| Ternary plots | Kept as visualisation only, not the inferential model | Settled |
| Overall-level gap | Not solved here — explicitly handed to `05`'s Option D | Settled |
| Group comparison vs. continuous VVIQ regression | Both in scope, same model structure | Settled |
| Version/pooling | Governed by `04-pooling-strategy.md`, not re-decided | Settled (deferred) |
| Input scores | **Raw**, responders-only participant means — standardised scores are ~50% negative and unusable for any log-ratio transform (§7) | Reversed 2026-08-20 |
| Units with no responded trials on a feature | Dropped from the composition (needs all three parts); 1 of 118 | Settled 2026-08-20 |
| SBP choice given the variance split | Recommendation unchanged; variance split recorded as a limitation, explicitly not used as a criterion (§2) | Settled 2026-08-20 |
| Interpretability of the composition | Gated on `03` §2.2's split-half stability check, run before any interpretation (§8.5) | Settled 2026-08-20 |
| Parity engagement | Continuous covariate, per `03-parity-engagement.md` §5 | Settled |

## 11. Open questions, not resolved here

- **SBP/partition choice (§2)** — the one item that needs a real
  conversation before implementation can start, not a technical detail to
  default past. Now carries the added weight that the recommended
  partition is the low-variance one (§2).
- Whether this strand survives `03` §2.2's stability gate at all (§8.5) —
  genuinely open, and the answer determines whether the compositional
  analysis is a result or a documented attempt.
- Whether `multilevelcoda`'s post-hoc/interpretation functions cover
  everything needed for the "make results explicit and interpretable"
  goal, or whether custom `tidybayes`/`bayesplot` work (as scoped for
  performance modelling's Option C) is also needed here — check once the
  package is actually used against real data.
- Ternary-plot implementation specifics — deferred, likely belongs with
  the legacy-plotting-code disposition question (not yet addressed in any
  doc).

## 12. Next steps (not this doc)

- **Resolve §2 directly with Maël** before any implementation — this
  should probably happen as its own focused conversation, not be decided
  inside a coding session.
- Implement `01-score-computation.md`'s pipeline (dependency, shared with
  `05`).
- Once §2 is resolved and real data is available: fit the `complr()` +
  `brmcoda()` pipeline, check version-layer estimability per
  `04-pooling-strategy.md`.
- Revisit ternary-plot and legacy-plotting-code disposition once the
  plotting-code question is addressed generally (currently unscoped
  across all docs, not specific to this one).
