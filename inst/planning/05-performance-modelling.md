# WM-FTT: performance modelling

**Status: planned in full 2026-08-21.** §11 is the implementation plan
and supersedes parts of §§2, 3 and 8: the primary structure is now
Option C-prime (multivariate, per-feature families, correlated random
intercepts), the family question is resolved per feature, word's status
is decided, and §3.1's hurdle is deferred by its own sequencing rule.
Read §11 before acting on §§1-10.

Earlier status, retained: structure and narrative arc settled. Amended
2026-08-20: §3's response-family question is resolved against real
distributions (hurdle, not ZOIB), §3.3 raises a new problem for Option C,
and §5's Option D is constrained. Depends on scoring
(`01-score-computation.md`), pooling strategy (`02-pooling-strategy.md`), and
directly implements the standard set by the philosophy discussion
(`00-analytical-philosophy.md` §3, §6) that performance modelling must
respect feature non-independence rather than treat the three features as
unrelated outcomes.

**Context:** this is the "performance" strand of the three-strand analytical
plan (performance / compositional / clustering — see
`00-analytical-philosophy.md` §5 for how the three relate). The performance framing's
preferred framing (are aphantasic participants simply better/worse at one
feature) lives here, but per the philosophy discussion, this strand is not
exempt from respecting the task's forced-trade-off structure — three
independent per-feature models would just relocate the flaw the
compositional critique was aimed at.

---

## 1. Narrative structure for the vignette: simple-and-wrong → complex-and-correct

**Decided approach**, chosen specifically because it fits the EOR
philosophy (executable, living companion — this is much more convincing
shown side-by-side than described in prose) and because writing it forces
an explicit, stated justification for the more complex model rather than
building it on autopilot:

1. Fit the naive model first (§3, Option A below).
2. State explicitly, in writing, why it's the wrong tool for this task —
   not just "we chose something more complex," but the specific mechanism
   (features aren't independent by task design; a naive per-feature model
   can't distinguish "worse at X" from "chose to prioritise Y over X" —
   directly recalling `00-analytical-philosophy.md` §1).
3. Fit the correct model (§3, Option C below), same data, and show the
   contrast directly — ideally the vignette shows both fits' output next
   to each other, not just describes the difference.

This means Option A is not being discarded, it has a real, deliberate role
in the vignette as the stated-wrong baseline, distinct from its other role
as an accessible/poster-friendly secondary result (§6).

## 2. Four structural options considered, three kept

Four options were laid out; one (B) is being dropped from the active plan
but kept on record rather than silently discarded, since understanding why
it was rejected is itself useful and may be asked about later (by a collaborator,
a reviewer, or a future returning-to-this session).

### Option A — three independent univariate models

`brm(score_word ~ group * ...)`, repeated separately for colour and
orientation.

- Simplest, easiest to explain, no family-compatibility constraints, no
  convergence complexity.
- Exactly the framing the philosophy discussion argued against as a
  primary analysis: blind to whether a participant's pattern *across*
  features is what actually differs, throws away power a shared structure
  could recover.
- **Role in the plan:** the deliberate "wrong" first step in the narrative
  (§1), and separately, a legitimate accessible/secondary result (§6) —
  not used as the primary/sole analysis.

### Option B — multivariate Gaussian model via `mvbind()` + `rescor` — dropped, kept for the record

`brm(mvbind(score_word, score_color, score_angle) ~ group * feature + (1|participant), set_rescor(TRUE))`
(or equivalent `bf()` + `+` syntax).

- Directly, natively estimates a residual correlation between the three
  features at the person level — "does trading off word for colour
  happen" as a single named, directly-interpretable parameter. Standard,
  well-documented `brms` machinery (`mvbind`/`mvbrmsformula`), not exotic.
- **Why dropped:** `rescor` is only available for Gaussian/Student-t
  response families (confirmed against `brms` documentation directly, not
  assumed). If scores end up bounded [0,1] (plausible, per
  `01-score-computation.md`'s similarity-score design) and especially if
  floor/ceiling effects put real mass near the boundaries (realistic for a
  WM task, not hypothetical), forcing a Gaussian family to get `rescor`
  "for free" is a real distributional mismatch, particularly damaging near
  the boundaries. Judged inferior to Option C **while serving the same
  underlying purpose** (representing cross-feature dependency) — C
  achieves a comparable result (dependency captured via correlated
  random slopes rather than residual correlation) while allowing the
  correct response family for bounded data.
- **Status: abandoned concept, kept on record.** Not being built. Worth
  keeping this section rather than deleting it — if asked "why not just
  use `rescor`," the answer is here rather than needing to be re-derived.

### Option C — long-format multilevel model, feature as within-participant factor — **primary model**

Reshape to one row per participant × feature (× trial, where trial-level
granularity is being retained, consistent with `03-validity-checks.md`'s
need for trial-level data):

```
brm(score ~ group * feature + (1 + feature | participant),
    family = <bounded family, TBD — Beta / zero-one-inflated Beta / other>)
```

- Allows the response family to actually match the data (Beta or similar
  for bounded, potentially boundary-inflated scores), while still
  respecting non-independence — not via an explicit residual correlation
  parameter, but via the participant-level random slopes for `feature`,
  which the model estimates as correlated by construction (a covariance
  matrix over the random effects). This captures "if this participant is
  high on word, are they low on colour" at the random-effects level.
- **Trade-off, accepted explicitly rather than treated as disqualifying:**
  loses the single named `rescor`-style parameter Option B would have
  given "for free" — the correlation is implicit in the random-effect
  covariance matrix and needs deliberate extraction/visualisation work to
  make legible (§4). **Decided: this complexity cost is justified by the
  quality of the resulting model, not a reason to prefer B or to avoid C.**
  The tooling work required (§4) is treated as a real, worthwhile build
  task, not an afterthought.
- **Feature coding — decided, not left to default:** `feature` must enter
  the model with **sum-to-zero (or equivalent symmetric) contrasts**, not
  treatment/dummy coding. With dummy coding, the correlation structure
  gets interpreted relative to an arbitrary reference feature (whichever
  is the intercept), entangling "does word correlate with colour" with
  "...relative to orientation." Sum coding keeps the three features
  symmetric, matching the actual scientific question (relative allocation
  among three interchangeable-in-status features). This must be set
  explicitly at implementation time, not left to `brms`'s default
  treatment coding.

### Option D — total-performance model, separate purpose — **own section, see §5**

Not a competing structural option to A/B/C — a different question
entirely (see §5).

## 3. Response family and full random-effects structure

**Resolved 2026-08-20 for the family question, against real score
distributions — and the answer is not the one this section anticipated.**
The random-effects question below remains open as designed.

### 3.1 The family question, answered

This section originally asked whether scores would look "cleanly
Beta-distributed, or show real mass at 0/1, pushing toward
zero-one-inflated Beta or an ordinal treatment". They show real mass at
both boundaries — but **the two boundaries come from different generative
processes**, which a ZOIB cannot represent, since it treats both as
inflation of one underlying process.

Proportion of block trials at each boundary, all rows versus responders
only:

| Feature | at 0, all | at 0, responders | at 1, responders |
|---|---|---|---|
| Word | 0.133 | 0.036 | **0.899** |
| Orientation | 0.192 | **0.000** | 0.000 |
| Colour | 0.091 | **0.000** | 0.005 |

Once non-responders are removed, orientation and colour have **no mass at
either boundary**. Every zero was a non-response, scored 0 by
`01-score-computation.md` §2.5.2. The mass at 1, by contrast, is genuine
ceiling performance and survives.

**Decided: a hurdle structure, not a ZOIB.** A Bernoulli (or
beta-binomial) component for whether the participant responded, and a
bounded component for accuracy conditional on responding. The zeros belong
to the first component and the ceiling to the second. This is not a
complication added to the model — it *is* this section's answer, and it
implements the separation of reporting propensity from conditional
accuracy set out in `08-response-propensity.md` §1.

**Sequencing, per `08` §5:** fit the propensity component separately
first, in `08`'s own analysis, and treat the joint hurdle as this doc's
problem informed by those results. A convergence failure in a joint model
should not take the propensity findings down with it.

### 3.2 The `bmm` connection is closer than `01` §5 records

`01-score-computation.md` §5 parks mixture modelling as an unrelated
future track. That framing is now wrong in one respect worth correcting:
`bmm`'s continuous-report models decompose a response into target recall,
guessing and swap errors, but every one of those states **is a response**,
with an angular error to attribute. Abstention is a fourth state the
mixture cannot represent. A hurdle gate is the natural place for it, and
it **composes** with a mixture rather than competing — gate on responding,
then decompose the responses that exist. The obstacle `01` §5 parked it on
was per-participant trial counts, which the gate does not change, so the
parking decision stands; the stated reason for it should not say the two
are unrelated.

### 3.3 One family will not fit all three features — a problem for Option C

Option C's form is a single `score ~ group * feature` model with one
response family. Conditional on responding, orientation and colour are
clean on the open interval (0, 1) with no boundary mass — good Beta
candidates. Word is **89.9% at exactly 1** pooled, 90.7% in v1 alone.
No single family fits both
situations well.

Three ways out, none free, **not decided here**:

- **Per-feature families via a multivariate specification.** Most
  faithful, most complex, and reintroduces some of the machinery Option B
  was dropped to avoid.
- **Model word separately** from orientation and colour, accepting that
  the cross-feature dependency structure Option C exists to capture then
  only covers two of the three features.
- **Treat word's ceiling at the measurement level** rather than the model
  level — see §3.4.

This does not overturn Option C; it means Option C needs a decision it was
not written to anticipate. §3's original instruction not to commit to a
family before seeing real distributions was correct — the distributions
simply say the problem is harder than a single family choice.

### 3.4 Word's ceiling is a task property, not a scoring artifact

Median responders-only word score is 0.934; 87 of 118 participant-by-
version units score above 0.90 and 48 above 0.95. Real spread exists only
in the bottom decile. Gonthier's metric is working exactly as designed —
single-word recall is simply easy at this exposure duration.

**Stronger than a ceiling: word fails as an individual-differences
measure in v1.** Requiring a participant's mean to have a standard error
of at most half the between-person SD needs **93 trials of the 63 that
exist** — between-person SD is 0.046 against a within-person trial SD of
0.219. Correspondingly, split-half reliability is **0.445** [0.251,
0.605], against 0.822 for orientation and 0.832 for colour
(`03-validity-checks.md` §2.1). **No individual-differences claim about
word is supported by the measurement, whatever a model's coefficients
say.** That resolves the open question below in one direction: word is
reported with an explicit measurement caveat and excluded from
individual-differences inference, not merely caveated.

Consequences beyond the family question: word contributes little
between-participant variance to any model, and
`06-compositional-analysis.md` §8.5 shows the same ceiling means the task
achieves a two-way trade-off (colour versus orientation) rather than the
three-way one it was designed for. Whether word is retained as a full
outcome, demoted to a control or anchor, or reported with an explicit
ceiling caveat is **open**, and interacts with §3.3's choice.

### 3.5 Still deferred, as originally designed

Whether the full `(1 + feature | participant)` random-slope structure is
estimable given sample sizes (v2 = 9 is a real constraint) still needs
checking against real fits, and may need simplification to random
intercepts as a fallback. Unchanged by the above, except that the hurdle
structure adds parameters and therefore makes the estimability question
harder, not easier.

## 4. Making C's dependency structure explicit and interpretable — scoped as real build work

Directly per the author's framing: the complexity of C is justified by the
quality of the idea, and that justification is realised specifically
through building tooling that makes the correlation structure legible,
not just technically present in a `summary()` output nobody reads
closely. Scoped here as concrete, separate build tasks (not yet
implemented, this is a planning doc):

1. **Extraction:** pull the relevant random-slope correlation terms
   (word-colour, word-angle, colour-angle) out of the posterior draws
   directly (not just `VarCorr()` point estimates) — needed for proper
   posterior visualisation, not just a table of point estimates.
2. **Posterior visualisation of the correlations themselves:** density or
   interval plots of each pairwise random-slope correlation, zero marked,
   so "is there evidence of a trade-off between these two features" is a
   single readable plot, not something inferred by squinting at a
   covariance matrix.
3. **Per-participant shrinkage plots:** each participant's raw per-feature
   means vs. their model-implied (partially pooled) random effects — the
   standard way to make partial pooling itself visible, and directly
   useful for explaining to a non-specialist audience (poster, thesis
   committee) why a participant's modelled estimate differs from their raw
   trial average.
4. **Contrast display for the A→C narrative (§1):** some way of showing
   Option A's and Option C's fits side-by-side on the same data — exact
   form (table, combined plot) not decided here, but flagged as needed for
   the narrative structure to actually land as intended.

This is `tidybayes`/`bayesplot`-based work, building on `brms` output —
consistent with the fully-Bayesian workflow already adopted, no
frequentist/parallel-Bayesian legacy wrapper involvement (per handoff's
own note that the old `custom_model_*()` wrappers are not relevant going
forward).

## 5. Option D: total-performance model — separate section, own purpose

**Purpose, distinct from A/B/C:** closes a real, currently-unaddressed gap
flagged directly in `00-analytical-philosophy.md` §6 — the compositional
strand (by design) discards overall performance level in favour of
relative allocation, and nothing in the current plan otherwise looks at
"how good was this person overall." D exists specifically to fill that
gap, not to do trade-off work (that's C's job, and arguably also partly
the compositional strand's job per the discussion that led here).

**Structure:** total score (sum or mean across the three features, per
trial or per participant — exact aggregation TBD at implementation)
as outcome; `group`/VVIQ and plausibly parity engagement
(`04-parity-engagement.md`, continuous covariate per that doc's Decision
1) as predictors; standard multilevel structure, not required to carry
C's complexity budget.

**Amendment 2026-08-20: a total score built from non-responses scored 0
conflates "attempted and failed" with "declined", and the conflation is
imagery-correlated.** Per `08-response-propensity.md` §3.2, roughly half
the between-participant variance in the score columns is reporting
propensity rather than accuracy (SD ratio responders-only to all-rows:
0.57 word, 0.49 orientation, 0.57 colour), and the association between
score and VVIQ drops from +0.394 to +0.191 for orientation and from
+0.395 to **+0.099** for colour once non-responses are excluded. A
"how good overall" model summing zeros would substantially be modelling
how often the participant declined.

**Decided: D's total is computed from responded trials only**, with
reporting propensity handled as its own outcome in `08`. If a
non-response-inclusive total is also of interest — as a measure of "points
actually accumulated", which is what participants were told to maximise —
it should be run and reported as a **separate, explicitly labelled
quantity**, not as the overall-performance measure. The two answer
different questions and the difference is large.

**Input scores — decided as a sensitivity check, not a single choice:**
run D with **both raw and per-version-standardised** scores from
`01-score-computation.md`, rather than committing to one. Rationale
carried over from that doc's own logic (§4 there: different downstream
uses need different things from "comparable") — raw natural-unit scores
are the more face-valid choice for "how good overall" in an absolute
sense, but running the standardised version alongside is a cheap,
worthwhile check on whether the choice actually changes the substantive
result. If it doesn't matter, worth knowing that explicitly rather than
assuming it doesn't; if it does matter, that's an important finding about
how sensitive this specific result is to the scoring pipeline's
standardisation choice.

## 6. Version/pooling integration — resolved, v1 only

**Resolved 2026-08-20 (`02-pooling-strategy.md` §3.5): v1 (N=88) is the
primary analysis sample, so this section's version layer is moot.** No
`(1 | version)` term, no nesting of participant within version, and none
of the estimability worry below about carrying a version layer on top of
`(1 + feature | participant)`. The v2 = 9 constraint that drove that worry
is out of scope entirely, which also makes §3.5's random-slope
estimability question easier than it was written to be — n = 88 in a
single design.

Two things this does not remove. v1 has **fixed** recall order, so feature
effects are confounded with output position; v3 is used separately to
estimate that order effect (`02` §3.5). And v1 carries **no parity
penalty**, so parity accuracy as a covariate here measures motivation on a
consequence-free task rather than working-memory load.

The original section is retained below as the record of the reasoning, and
becomes live again if later versions are ever pooled.

### 6.1 Original version/pooling reasoning, now superseded

Per `02-pooling-strategy.md`'s decision procedure (that doc's §3), this
doc's models fall under "needs pooling for power" (step 3 there) — v2=9
and v3=21 alone are almost certainly underpowered for C's full structure
independently.

**Decided:** keep a `version`-level partial-pooling layer (e.g.
`(1 | version)`, or nesting participant within version) **as an option,
not committed to by default**, given the concern, raised directly, that
adding another varying-effects layer on top of C's existing
`(1 + feature | participant)` structure may simply be too much for the
available sample size, especially with v2 at N=9. This is the same
empirical-not-assumed stance as §3's deferred random-effects decision —
whether the model can actually support a version layer alongside the
feature layer needs checking once real data is in hand, not decided by
principle alone. If it can't be supported jointly, the fallback (not yet
decided in detail) is likely either: analyse v1 alone as primary (per
`02-pooling-strategy.md` §3c) with pooled v1+v2+v3 as secondary, or drop
the version varying effect and rely on `02-pooling-strategy.md`'s
version-composition-reporting requirement (that doc's §3, step 4) to keep
the pooling assumption visible rather than hidden.

## 7. What this doc deliberately does not do

- Does not commit to a response family for C — deferred to real data (§3).
- Does not decide the exact aggregation method for D's total score (sum vs.
  mean, per-trial vs. per-participant) — implementation-time detail.
- Does not design the compositional or clustering models — separate docs,
  not yet written.
- Does not resolve whether the full `(1+feature|participant)` +
  `(1|version)` structure is jointly estimable — explicitly deferred to
  real data, per §6.

## 8. Summary of decisions

| Decision | Choice | Status |
|---|---|---|
| Narrative structure | A (naive, stated wrong) → C (correct), shown side-by-side | Settled |
| Option A's role | Deliberate wrong-baseline in narrative + accessible secondary result | Settled |
| Option B (`mvbind`/`rescor`) | Dropped from active plan, kept as documented abandoned concept | Settled |
| Primary model structure | Option C: long-format, feature as within-participant factor, correlated random slopes | Settled |
| Feature contrast coding | Sum-to-zero, not dummy/treatment | Settled |
| Response family for C | **Hurdle** (Bernoulli response gate + bounded accuracy component), not ZOIB — the two boundaries have different generative processes (§3.1) | Resolved 2026-08-20 |
| One family across all three features | Not viable — word is ~90% at ceiling, orientation/colour clean on (0,1) given response (§3.3) | Open, three options outlined |
| Word's status as an outcome | Ceiling is a task property, not a scoring artifact; retain / demote / caveat undecided (§3.4) | Open |
| D's total score | Responded trials only; a points-accumulated total is a separate labelled quantity (§5) | Settled 2026-08-20 |
| Full random-effects structure for C | Deferred — depends on estimability with real data | Open, by design |
| Correlation-structure tooling (§4) | Real, scoped build task, not an afterthought | Settled |
| Option D | Separate section/purpose — total performance, not trade-off | Settled |
| D's input scores | Both raw and standardised, as a sensitivity check | Settled |
| Version pooling in C | Kept as an option (`(1|version)` or nesting), not committed by default given sample-size concern | Settled as "optional, empirically decided" |

## 9. Open questions, not resolved here

- How to handle word's ceiling alongside orientation and colour (§3.3,
  §3.4) — per-feature families, a separate word model, or a measurement-
  level fix. Interacts with `06`'s SBP interpretation.
- Whether `(1+feature|participant)` is estimable at all with current N,
  and whether adding `(1|version)` on top is feasible (§6) — resolve
  empirically, likely via a first fit-and-diagnose pass rather than
  guessed in advance.
- Exact form of the A-vs-C contrast display for the vignette (§4, item 4).
- D's exact aggregation method (§5).

## 10. Next steps (not this doc)

- Implement `01-score-computation.md`'s scoring pipeline — both this doc's
  primary model (C) and Option D depend on it.
- Once real score distributions are available: resolve response family
  (§3), attempt the full C structure, check estimability, decide on the
  version layer (§6) empirically.
- Build the correlation-visualisation tooling (§4) alongside the model
  itself, not as a separate later pass.
- Fit Option A first regardless (cheap, and needed as the narrative's
  starting point per §1), then C.
- Fit Option D separately, with the raw/standardised sensitivity check
  (§5), once scoring pipeline is available.

## 11. Implementation plan, 2026-08-21

Written before any code, in the shape of `06-compositional-analysis.md`
§13. Resolves §9's first open question, changes the primary structure in
§8's table, and defers §3.1's hurdle by §3.1's own sequencing rule.
Implemented as `inst/scripts/05-performance-modelling.R`.

### 11.1 What the v1 distributions force

Boundary mass on responded trials, v1 only:

| Feature | n responded | at 0 | at 1 |
|---|---|---|---|
| Word | 5100 | 3.2% | **90.7%** |
| Orientation | 4788 | 0.00% | 0.00% |
| Colour | 5174 | 0.00% | 0.48% |

Two corrections to §3.1. Its claim that every zero is a non-response
holds for orientation and colour but **not for word**: 3.2% of responded
word trials score exactly 0, and those are real wrong answers, not
abstentions. And colour has 25 trials at exactly 1, which is not a
rounding annoyance but a hard obstacle, since Beta has zero density at
the boundary and the fit errors rather than degrades.

### 11.2 Primary structure: Option C-prime

**Decided: a multivariate model with per-feature families and correlated
random intercepts**, which is §3.3's first escape route, the one that
section called the most faithful and the most complex.

```r
bf(score_word  ~ vviq + complete_aphant + (1 | p | id), family = zero_one_inflated_beta) +
bf(score_angle ~ vviq + complete_aphant + (1 | p | id), family = Beta) +
bf(score_color ~ vviq + complete_aphant + (1 | p | id), family = Beta)
```

Fitted on responded trials only.

**Why this rather than long-format Option C.** It dissolves §3.3's
trilemma instead of choosing a horn of it: each feature gets the family
its distribution demands, which a single `score ~ group * feature` model
cannot do. It keeps what Option C existed to provide, since `(1 | p | id)`
estimates a correlated random-intercept matrix across responses, which is
the same "is this participant high on word and low on colour" question,
delivered as three named pairwise correlations instead of random slopes
read relative to whichever feature is the reference. That also makes
§2's sum-to-zero contrast decision unnecessary: the features are
symmetric by construction, so there is no reference level to be relative
to. Estimability is better than long-format random slopes, being three
intercepts across 79 participants with about 63 trials each. And it is
the structure already built and debugged in
`06-compositional-analysis.md` §13, so the machinery is tested.

**What it costs, stated plainly.** No single `rescor` parameter, and
`mvbind()` is unavailable because the families differ. Neither matters,
because §4 already scoped making the dependency structure legible as real
build work, and three named correlations are more legible than a
covariance matrix over random slopes.

**Option B is not thereby revived.** B was dropped because a Gaussian
`rescor` model misrepresents bounded scores. C-prime is multivariate in
syntax only; the dependency is at the random-effect level, exactly as
Option C intended.

### 11.3 Families, chosen by what each boundary means

**Orientation: Beta.** No boundary mass at all once non-responders are
removed. Nothing to accommodate.

**Colour: Beta after a Smithson-Verkuilen squeeze.** The transform
(Smithson & Verkuilen, 2006) is

$$y' = \frac{y(n-1) + 0.5}{n}$$

With n = 5174 responded colour trials, exact ones become 0.99990 and
every other value moves by about one ten-thousandth. It is monotone,
order-preserving, standard and citable.

Preferred over one-inflation **because of what the boundary means**.
Colour score is cosine similarity on a continuous wheel, so a score of
exactly 1 is an error of exactly zero degrees, which is pixel resolution
rather than a distinct behaviour. Modelling it as an inflation component
would estimate a process parameter for a rounding effect, on 25
observations.

**Word: zero-one-inflated Beta.** The opposite case, and the asymmetry is
the entire argument: 90.7% at exactly 1 is a genuine mass, because a
recalled word either matches or does not. That earns an inflation
component, and the 3.2% at zero earns the other one.

**Flag on word, recorded rather than solved:** its score is
`1 - distance / nchar(target)`, so it takes only discrete values. Any
continuous family is an approximation there. This is one more reason its
coefficients are not for inference (§11.4), not a reason to prefer a
different continuous family.

### 11.4 Word's status: retained, but not for inference

**Decided, resolving §3.4's open question.** Word stays in the model as a
third response, and **no individual-differences claim is drawn from its
coefficients**. Its split-half reliability of 0.445 is reported alongside
them every time they appear.

Retained rather than dropped because deleting an outcome for being noisy
is itself a bias, and because the model is a claim about how three
features relate; removing one would answer a different question.

**This sits deliberately alongside `06`, and the two must be read
together or they look inconsistent.** Word is unusable as a *level* for
individual differences (reliability 0.445) and stable as part of a
*ratio* (ilr1 stability 0.771). Both statements are true, they are about
different quantities, and each doc must say so explicitly rather than
leaving a reader to reconcile them.

### 11.5 VVIQ enters as the floor-group form

Pre-declared primary, mirroring `06` §13.6 and `09`. A MARS pre-check
runs first, reading knots off the **pruned** model (`selected.terms`),
not off `$cuts`, per the bug recorded in `06` §13.6. The LOO comparison
of functional forms runs on **orientation**, which is the best-measured
feature (split-half 0.822) and the one `03` §2.4 already associates with
VVIQ. Candidates as in `06`: intercept only, two-group, linear,
floor-group additive, segmented if a knot is identifiable.

### 11.6 The hurdle, staged

§3.1 decided a hurdle and its own sequencing rule says fit propensity
separately first, in `08`. `08`'s Bayesian model does not exist yet.

**Decided: `05` models accuracy conditional on responding, as `06` did,
and the joint model is fitted afterwards with a specific and narrow
job.** That job is not "the fuller picture". It is **the test of whether
separating the two quantities was legitimate at all.**

The argument for it is informative missingness. Every responders-only
analysis conditions on a selected subsample, and if people who abstain
more also perform differently when they do answer, the conditional
estimates are biased in a way no separate analysis can detect. A joint
model with random effects shared across the two parts estimates exactly
one quantity neither separate model gives: the person-level correlation
between response propensity and conditional accuracy.

The argument that the two are near-duplicates does not survive the
existing evidence. `09` §2 examined both on colour: propensity keeps a
continuous above-floor VVIQ slope (p = .002) with no floor offset, while
conditional accuracy shows a floor offset (p = .054) with no continuous
slope. Same feature, opposite structure.

Structure, statically validated against brms:

```r
bf(responded ~ vviq + complete_aphant + (1 | p | id), family = bernoulli) +
bf(score | subset(responded) ~ vviq + complete_aphant + (1 | p | id), family = Beta)
```

**Fitted on orientation alone first**, which has the highest non-response
and the cleanest Beta, so it is where the problem would surface first.
Not all three features jointly at the outset: six responses sharing a
random-effect matrix is a large model, and a convergence failure there
teaches nothing, which is the failure `08` §5's rule exists to prevent.

**What the result decides.** A correlation near zero vindicates the
separation, and `05` keeps accuracy while `08` keeps propensity. A
credibly non-zero correlation makes the joint model primary for
orientation and colour, and **`06` inherits an explicit caveat**, since
its entire compositional analysis is responders-only. The stakes are
wider than this doc.

### 11.7 Still open, deliberately

- **Option D's aggregation** (§5) is untouched here. It remains a
  separate model with a separate purpose.
- **D's raw-and-standardised sensitivity check** (§8) needs a flag: the
  standardised scores are z-scores and roughly half are negative, so they
  cannot enter a Beta. A standardised D is a Gaussian model, which makes
  it a different model rather than a sensitivity check on the same one.
- **§4's tooling** (posterior correlation plots, shrinkage plots, the
  A-versus-C contrast display) is built alongside the model, per §10.
- **Option A** is still fitted first as the narrative's deliberate wrong
  baseline (§1), and is cheap.

### 11.8 Changes to §8's decision table

| Decision | Was | Now |
|---|---|---|
| Primary model structure | Option C, long-format, random slopes | **Option C-prime**, multivariate, per-feature families, correlated random intercepts (§11.2) |
| Feature contrast coding | Sum-to-zero | **Not applicable** under C-prime; features are symmetric by construction (§11.2) |
| One family across all three | Open, three options outlined | **Resolved**: per-feature families (§11.3) |
| Word's status | Open | **Retained, excluded from individual-differences inference** (§11.4) |
| Response family for C | Hurdle | **Deferred by §3.1's own sequencing**; conditional accuracy now, joint model as an assumption test (§11.6) |
| Full random-effects structure | Deferred, estimability unknown | Correlated random intercepts across three responses; slopes not attempted (§11.2) |
