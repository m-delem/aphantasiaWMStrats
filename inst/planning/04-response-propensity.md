# WM-FTT: response propensity

**Status:** new doc, 2026-08-20, **corrected the same day** — see §3.1.
The first draft treated the π-by-imagery association as established on
pooled data; stratifying by version, as `05-version-scope.md` requires,
dissolves most of it. The doc is retained because the quantity it defines
(§1) and the convention problem it identifies (§3.2) are unaffected, and
because the error is worth keeping visible. Written during the
score-computation implementation session, from findings that emerged while
implementing `02-score-computation.md` §2.5.2 rather than from prior
planning. The
quantity it describes is not anticipated anywhere in `00`–`13`. Evidence
is descriptive and post hoc; the modelling design here is a plan, not yet
implemented. Depends on `02-score-computation.md`'s `responded_*`
indicators. Amends or constrains `05`, `06`, `03`, `10`, `11` and `13` —
see `non-response-propagation-memo.md` for the full map.

**Context:** WM-FTT encodes non-response with per-feature sentinels rather
than `NA`, and `02` §2.5.2 scores those as 0. Between 9% and 19% of block
trials are non-responses, the rate differs by feature and by version, and
it correlates with VVIQ. That last fact turns a missing-data convention
into a measurement-model problem, because the convention manufactures part
of the relationship the rest of the plan set exists to test. This doc
defines the quantity properly, states what is known about it, and sets out
how to analyse it in its own right.

---

## 1. The quantity: what the score column is actually made of

For each participant × feature there are two distinct parameters, not one:

- **π, reporting propensity** — the probability the participant provides a
  response at all on a given trial for that feature.
- **μ, conditional accuracy** — the expected similarity score *given* that
  they responded.

Under `02` §2.5.2's rule the score column is approximately **π · μ**. It is
a product of two quantities with different meanings, which is why it
behaves ambiguously: a mean score of 0.6 is equally consistent with
"responded every trial, moderately accurate" and with "responded on
two-thirds of trials, near-perfect when they did".

**Every analysis in the plan set must state which of the two it is asking
about.** Score-0 answers "both at once, weighted by how often the person
declined", which is not a quantity anyone intends to estimate.

**This is not a defect of the scoring rule.** `02` §2.5.2 considered
`NA` and rejected it, on the grounds that non-response here is very
unlikely to be missing-at-random and `NA` would let listwise deletion
silently drop exactly the aphantasia-relevant observations. That reasoning
holds. The `responded_*` indicators exist precisely so that π and μ can be
separated at the point of analysis. What was missing was any instruction
to actually separate them, which is what this doc supplies.

## 2. Why π is a substantive variable, not a nuisance

`00-framing.md` §1 establishes, from the task's own
documentation, that WM-FTT is a resource-allocation task by design:
partial credit per feature, participants told to maximise total score,
scoring built "to elicit a genuine strategic trade-off between feature
types, rather than uniform effort across all three."

If that is what the task is for, then **declining to respond is the most
direct expression of allocation the task can produce.** It is not a
degraded observation of accuracy; it is an unambiguous statement that the
participant allocated nothing to that feature on that trial.

This inverts the current framing. `11-compositional-analysis.md` infers
relative allocation *indirectly*, from proportions of accuracy scores,
while `02` §2.5.2 folds the direct expression of allocation into those same
scores as failure. The compositional strand is reconstructing from a noisy
proxy something the data records explicitly.

**Decision: π is treated as a substantive outcome in its own right, not as
a filter, a covariate, or a data-quality threshold.** This mirrors
`03-parity-engagement.md` §1's structure for parity engagement — quantify
the variable, decide separately whether a discrete split is useful, decide
separately again what it is used *for* — and reaches the same conclusion
for the same reason: an engagement signal that differs systematically
between the groups under study is a finding, not a preprocessing step.

## 3. What is known, from real data

All figures from experimental blocks only (63 trials per feature per
participant), 118 participant-by-version units, computed while
implementing the scoring pipeline.

### 3.1 π and imagery: a pooled association that does not survive stratification

**Corrected 2026-08-20, after this doc was first drafted.** The initial
draft reported a sample-wide association between π and VVIQ and treated it
as established. It is not. The pooled figures are real but largely
attributable to version confounding, and the correction is recorded here
in full rather than quietly revised, because the error is instructive.

**Pooled across all 118 units:**

| Feature | Spearman ρ with VVIQ | p | Aphantasia | Typical |
|---|---|---|---|---|
| Orientation | −0.291 | 0.0015 | 28.4% | 11.3% |
| Colour | −0.303 | 0.0009 | 15.0% | 4.0% |
| Word | −0.195 | 0.036 | 12.9% | 7.6% |

**Within version, which is what `05-version-scope.md` requires before
any pooled estimate is believed:**

| Version | n | Aph / Typ | Orientation | Colour | Word |
|---|---|---|---|---|---|
| v1 | 88 | 31 / 55 | −0.091 (p = 0.41) | −0.183 (p = 0.09) | −0.054 (p = 0.62) |
| v2 | 9 | 8 / 1 | −0.124 | −0.300 | −0.704 |
| v3 | 21 | 17 / 4 | −0.672 | −0.598 | −0.243 |

**In v1 — the largest version and the only one with a balanced group
split — nothing reaches significance.** Colour is marginal at p = 0.09 and
in the predicted direction; orientation and word are noise.

The pooled association is substantially produced by v3 being *both*
deliberately aphantasia-heavy *and* the version with by far the highest
non-response (§3.4). Pooling those strata manufactures an
imagery-by-propensity association out of a version-by-both association.
This is the failure mode `05` was written to prevent, committed in the
first draft of this very doc.

**What can honestly be said:** π may relate to imagery, most plausibly for
colour, and the current data cannot establish it. v3's within-version
correlations are large but rest on 21 participants with a 17-to-4 group
split. v1 says little. The question is open, not answered.

**Modelled directly (`06-task-validity.md` §2.5, run 2026-08-20), this
holds.** A quasi-binomial GLM on v1 gives log-odds slopes of +0.008
(word, p = .42), +0.016 (orientation, p = .042) and +0.031 (colour,
p = .006); the conservative rank correlations are -0.054 (p = .62),
-0.091 (p = .41) and -0.183 (p = .092). The two estimators disagree on
strength and agree on direction. A mixed binomial that would arbitrate
between them is not identifiable at N = 86 given a dispersion of 4.2.
Colour is the only feature with any support, and it is suggestive rather
than established.

**Counterpart finding worth carrying together with this one.** Where π
shows its clearest signal (colour), *accuracy* shows none once
non-responses are excluded: colour's accuracy-VVIQ correlation falls from
+0.353 to +0.164 (p = .135). Where accuracy shows a signal (orientation,
+0.223, p = .047), π does not. The two features appear to relate to
imagery through different channels. That is a sharper hypothesis than this
doc started with, and a better target for the task revision in §6 than a
general propensity effect.

### 3.1b It is not fatigue

Worth recording because it is the most obvious deflationary explanation
and it is ruled out. Non-response is flat across the three experimental
blocks (orientation 19.4% / 19.8% / 18.6%; colour 9.3% / 9.0% / 9.1%;
word 12.6% / 9.7% / 8.0% — if anything word *improves*), and the
between-group gap is stable from the first block onward (orientation,
aphantasia 28.7% / 28.7% / 27.7% versus typical 11.3% / 12.1% / 10.6%).

Whatever drives abstention is present immediately and does not accumulate
over the session. That is consistent with a stable individual propensity
rather than progressive disengagement — it simply does not establish that
the propensity is about imagery.

### 3.2 The convention inflates WM-FTT's VVIQ signal, whatever causes π

Spearman ρ between participant mean score and VVIQ, computed both ways:

| Feature | Non-responses scored 0 | Responders only |
|---|---|---|
| Orientation | +0.394 | +0.191 |
| Colour | +0.395 | **+0.099** |
| Word | +0.141 | +0.090 |

Colour's entire apparent relationship with VVIQ is reporting propensity.
Orientation retains about half. Word never had one.

Relatedly, roughly half the between-participant variance in the score
columns is π rather than μ: the ratio of responders-only SD to all-rows SD
is 0.57 (word), 0.49 (orientation), 0.57 (colour).

**This part is robust to §3.1's correction.** The inflation is a fact
about the score column: including zeros roughly doubles the apparent
score-VVIQ correlation, whether the underlying non-response is driven by
imagery, by version composition, or by something else entirely. The
methodological consequence — never compute a VVIQ relationship on the
score-0 columns — holds regardless.

**What is *not* robust is the causal reading.** An earlier draft stated
that "WM-FTT's relationship to imagery is substantially a relationship
with willingness to report". Given §3.1, the accurate statement is that
the pooled score-VVIQ correlation is substantially carried by
non-response, and that the non-response is itself substantially carried by
version composition. The chain runs through version, not demonstrably
through imagery.

### 3.3 π accounts for essentially all boundary mass at zero

Proportion of block trials at each boundary, all rows versus responders
only:

| Feature | at 0, all | at 0, responders | at 1, responders |
|---|---|---|---|
| Word | 0.133 | 0.036 | 0.899 |
| Orientation | 0.192 | **0.000** | 0.000 |
| Colour | 0.091 | **0.000** | 0.005 |

Once non-responders are removed, orientation and colour have no mass at
either boundary. This is the evidence behind `10-performance-modelling.md`
§3's revised response-family answer (§5 below).

### 3.4 π differs sharply by version

Non-response rate, experimental blocks, by version:

| Feature | v1 | v2 | v3 |
|---|---|---|---|
| Orientation | 13.6% | 32.5% | 37.0% |
| Colour | 6.7% | 19.6% | 15.0% |
| Word | 8.0% | 14.1% | 17.0% |

`05-version-scope.md` treats version as a structural factor reflecting
task mechanics. This is a version difference in *engagement*, which that
doc does not anticipate, and it is large — orientation non-response
roughly triples from v1 to v3. Whether it reflects the randomised recall
order in v3, sample composition (v3 is heavily aphantasic by design), or
something else is not identifiable from these data alone, and the three
have different implications for pooling.

## 4. What π is not

**Not parity disengagement.** The natural assumption is that feature
non-response and parity disengagement are the same withdrawal of effort,
in which case `03-parity-engagement.md` would already cover it. It does
not: per-feature non-response correlates with parity accuracy at ρ = +0.12
(orientation, p = 0.20), +0.09 (colour, p = 0.35), +0.23 (word,
p = 0.011). Weak, mostly non-significant, and **positive** — higher parity
accuracy goes with *more* feature non-response, the opposite sign from a
shared-disengagement account. Two distinct constructs; `03`'s framework
transfers, its variable does not.

Worth flagging back to `03` separately: parity accuracy itself correlates
with VVIQ at ρ = −0.334, which that doc does not anticipate.

**Not a data-quality problem to be excluded away.** Removing the seven
high-non-response units would not remove an association running through
all 118.

**Not a threshold decision.** Minimum-engagement thresholds are still
needed for μ-based analyses (`06-task-validity.md` §2.1), but they are a
precision requirement on a different quantity, not a treatment of this
one. Participants excluded from μ analyses for low π are retained here,
where they are the most informative part of the distribution.

## 5. Model structure

**Primary:** π modelled directly as a binomial or beta-binomial outcome —
responded trials out of 63 per feature — against VVIQ (continuous and
grouped), feature, and version, with participant-level random effects.
Beta-binomial if overdispersion is present, which is likely given the
bimodality visible in the marginal rates.

**Feature must enter with sum-to-zero contrasts**, for the same reason
`10-performance-modelling.md` §2 requires it of the performance model:
the scientific question concerns relative propensity across three features
of equal status, and dummy coding would entangle every contrast with an
arbitrary reference feature.

**Relationship to `10`'s performance model.** π and μ can be fitted as one
**hurdle** model — a Bernoulli component for responding and a bounded
component for accuracy given response — or as two separate models. The
hurdle is the more principled object and is what `10` §3's deferred
response-family question should resolve to (§3.3 above is the evidence).
But two separate models are easier to interpret, easier to diagnose, and
sufficient for the questions in this doc. **Decision: fit π separately
first, here; treat the joint hurdle as `10`'s problem, informed by this
doc's results.** Not a permanent split — a sequencing choice, so that a
convergence failure in a joint model does not take the π results down with
it.

**Relationship to `bmm` (`02-score-computation.md` §5).** The connection is
closer than that doc's parked status suggests. `bmm`'s continuous-report
models decompose a response into target recall, guessing, and swap errors —
but each of those states *is a response*, with an angular error to
attribute. Abstention is a fourth state the mixture cannot represent,
because there is no report to decompose. A hurdle gate is the natural
place for it, and it **composes** with a mixture rather than competing:
gate on responding, then decompose the responses that exist. The obstacle
`02` §5 parked `bmm` on was per-participant trial counts, which the gate
does not change — but "parked as unrelated" is no longer an accurate
description of the relationship.

## 6. Interpretation: three mechanisms, one now ruled out

An aphantasic declining to report a colour is consistent with at least
three readings, which have materially different implications:

1. **Absence of a representation to report.** The participant has nothing
   to place on the wheel. If this is right, π is among the most on-target
   measures in the whole project — a direct behavioural index of
   representational absence rather than a self-report proxy.
2. **Metacognitive abstention.** The participant has a weak or uncertain
   representation and declines rather than guesses. This makes π a measure
   of confidence calibration, related to but distinct from (1).
3. **Rational allocation or interface friction.** The task rewards points;
   skipping a feature one expects to fail is strategically sensible, and
   separately the response widgets may be harder to use without imagery.

**Response times narrow this, and were checked rather than left as a
proposal.** RTs are recorded on every trial including abstained ones (0%
missing), so the check was available immediately. Median RT in ms,
responded versus abstained:

| Feature | Responded | Abstained | Ratio |
|---|---|---|---|
| Orientation | 3478 | 1175 | 0.34 |
| Colour | 2943 | 926 | 0.31 |
| Word | 3274 | 2004 | 0.61 |

**Abstention is fast** — roughly a third of the time a response takes, and
under a second for the two non-verbal features. That is barely enough to
read the prompt and submit.

This **rules out mechanism (2)**: metacognitive abstention following an
effortful but unsuccessful search would be slow, and it is not. It does
**not** separate (1) from (3), both of which predict fast abstention —
absence of a representation is detected immediately, and strategic
skipping is immediate by definition.

It also mildly complicates the richer reading of (1). Sub-second
abstention looks more like clicking through than like consulting an empty
representational space and reporting the result. That is an argument for
caution in how (1) is worded, not evidence against it.

By imagery group, abstained-trial RTs differ little and in the direction
of aphantasics abstaining slightly *faster* (orientation 1117 vs 1394 ms;
colour 906 vs 1008 ms). Not obviously interpretable, and not to be
over-read at these sample sizes.

**What would separate (1) from (3)** is not available in the current data:
a confidence rating, an explicit "I don't know" control distinct from an
untouched widget, or a manipulation of the point value of each feature —
if abstention is strategic it should respond to incentive, and if it
reflects representational absence it should not. This belongs in the
recommendations for a future task version, alongside the word-difficulty
problem (`02-score-computation.md` §2, word's 90% ceiling).

## 7. Version and pooling

Governed by `05-version-scope.md`'s decision procedure, with one
addition: because §3.4 shows π differs sharply by version, this doc's
models should carry version explicitly rather than pooling silently, and
`05` §3 step 4's version-composition-reporting requirement should be
extended to report non-response rates per version alongside group
composition. Not re-litigated here beyond that.

## 8. Epistemic status and how this may be described

**Exploratory, and weaker than the first draft of this doc claimed.** The
pattern was noticed while implementing the scoring pipeline, not predicted
in advance, and it does not survive stratification by version (§3.1).

**What may be stated as established:**

- The score column confounds two quantities, and analyses must say which
  they mean (§1).
- Including non-responses as zeros roughly doubles the apparent
  score-VVIQ correlation (§3.2). This is a fact about the column.
- Non-response rates differ sharply and systematically by version (§3.4).
- Abstention is fast, roughly a third of a response's duration (§6), and
  flat across blocks rather than accumulating (§3.1b).

**What may be stated only as a possibility warranting further work:**

- That π relates to imagery. Marginal for colour in v1 (p = 0.09), strong
  in v3 but on 21 participants with a 17-to-4 group split, and confounded
  with version throughout.

**The honest summary sentence**, replacing the stronger one drafted
earlier: *Whether a participant reports a feature at all varies
systematically across task versions and accounts for much of the apparent
association between WM-FTT scores and imagery vividness; whether reporting
propensity is itself related to imagery cannot be determined from the
current sample, and a version designed to test it directly is the natural
next step.*

**This should not become the chapter's headline claim.** A post hoc
finding that dissolves within the largest version cannot carry a thesis
section, and a reviewer running the stratified check would find the
problem quickly. Its proper role is methodological — it reorganises how
every other strand handles the score column — plus motivation for a future
task version (§6).

## 9. What this doc deliberately does not do

- Does not decide the minimum-engagement threshold for μ-based analyses —
  that is `06-task-validity.md` §2.1's, and is a precision requirement
  on a different quantity.
- Does not design the joint hurdle model — deferred to
  `10-performance-modelling.md` §3, informed by this doc's results (§5).
- Does not re-open `02-score-computation.md` §2.5.2's score-0 decision.
  That decision is correct for the default column; this doc supplies the
  missing instruction to separate π from μ at analysis time.
- Does not attempt to adjudicate §6's three mechanisms, beyond flagging
  the response-time check as the cheapest available evidence.
- Does not decide whether π belongs in the poster. Deadline-dependent, and
  it is a harder story to tell in three minutes than a group difference.

## 10. Summary of decisions

| Decision | Choice | Status |
|---|---|---|
| Is π a nuisance or an outcome? | Outcome, on `00` §1's own grounds — abstention is the direct expression of allocation | Settled |
| Relationship to parity engagement | Distinct construct; weak, positive, mostly non-significant correlation | Settled, evidence-based |
| Primary model | Binomial / beta-binomial on responded-trial counts, feature and version as factors | Settled |
| Feature contrast coding | Sum-to-zero, per `10` §2's reasoning | Settled |
| Joint hurdle with μ | Deferred to `10` §3; π fitted separately first | Settled as sequencing |
| `bmm` relationship | Composes with a mixture via a hurdle gate, not an alternative to it | Settled in principle |
| Interpretation | Three mechanisms stated; metacognitive abstention ruled out by RT, other two remain live | Settled on current evidence |
| Response-time check on abstained trials | Run — abstention is ~3x faster than responding (§6) | Done |
| **Does π relate to imagery?** | **Not established.** Pooled association dissolves within version. Modelled directly on v1: colour suggestive (p = .006 quasi-binomial, p = .092 rank), orientation and word null (§3.1) | Open |
| Is π's role headline or methodological? | Methodological, plus motivation for a v4 — not the chapter's main claim (§8) | Settled |
| Is abstention fatigue? | No — flat across blocks, group gap stable from block 1 (§3.1b) | Settled, evidence-based |
| Epistemic status | Exploratory, post hoc, weaker than this doc's first draft claimed | Settled |

## 11. Open questions, not resolved here

- **Whether π relates to imagery at all**, once version is properly
  accounted for (§3.1). The single most important open question in this
  doc, and the one the first draft wrongly treated as answered. Now
  narrowed to colour specifically, and to a suggestive rather than an
  established effect. Needs
  either a balanced sample within a single version, or v3 grown enough to
  support a within-version test with a less extreme group split.
- Whether the version gradient in §3.4 reflects v3's randomised recall
  order, v3's sample composition, or interface changes — not identifiable
  from these data, and the three differ in what they imply for pooling.
  Note this is now entangled with the question above: the same confound
  blocks both.
- Whether representational absence (§6.1) or strategic skipping (§6.3)
  drives abstention. Response times rule out the metacognitive account but
  cannot separate these two; doing so needs a task change (§6).
- Whether π should be modelled per feature or as a multivariate outcome
  across the three features, given they are plainly correlated within
  participant.
- Whether this doc's findings change the poster's framing, given the
  deadline. Deliberately not decided here.

## 12. Next steps (not this doc)

- Fit the primary model (§5) against the current data.
- Carry §6's task-design recommendations (confidence rating, explicit
  "don't know" control, incentive manipulation) into whatever record is
  kept for a future WM-FTT version, alongside the word-ceiling problem.
- Apply the amendments this doc implies elsewhere: `11` §7 and §2, `10`
  §3, `05` §3, `13` §4, `03` §1, `02` §5, and `00` §3's framing, which
  currently accounts for two quantities where there are three. See
  `non-response-propagation-memo.md` §5 for the order.
