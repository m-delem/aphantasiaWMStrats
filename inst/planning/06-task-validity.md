# WM-FTT: task validity and reliability

**Status:** all five checks **implemented and run** on v1; results are
inline in each section. §2.1, §2.2 and §2.3 in
`inst/scripts/06a-reliability.R`; §2.4 and §2.5 in
`inst/scripts/06b-validity-checks.R`. Amended 2026-08-20 during
the score-computation implementation session: §2.1, §2.2 and §2.4 revised
for non-response handling, §2.5 added. See
`non-response-propagation-memo.md`. Sits upstream of performance
modelling, compositional analysis, and clustering — a shared precondition
for all three, not specific to one strand. Should run once, before those
three are built on top of the new scores from `02-score-computation.md`.

**Context:** the handoff (§10) flagged this as an open, unresolved question
("does WM-FTT actually measure anything specific or relevant, or is the
data just noise we're overinterpreting") without a concrete plan attached.
This doc is that plan. Depends on the scoring pipeline in
`02-score-computation.md` being implemented first (raw + standardised
similarity scores per feature).

---

## 1. Why this needs its own pass, not folded into the three analytical strands

"Validity" as raised in the handoff is bundling several distinct questions
that need different evidence and different checks. Untangled below. All
four are checkable, at least partially, from data already being collected
(no new data collection required), which is why this is scoped as a
dedicated pre-pass rather than an open-ended psychometric project.

If WM-FTT turns out to have a real reliability problem, that's important to
know *before* investing further design effort in performance, compositional,
or clustering models, all three would inherit the same weakness, and
knowing this early changes how much interpretive weight any of the three
can honestly bear in the poster/chapter.

## 2. The questions, and what each actually requires

*Four when this doc was written. §2.5 and §2.7 were added during
implementation, for reasons given in each. A floor-group model was briefly
added here as §2.6 and then moved out to `08-predictor-form.md`: it asks
whether complete aphantasia is qualitatively distinct, which is a claim
about people rather than about the instrument, and a null there would not
make anyone doubt the task. This doc is validity only.*

### 2.1 Reliability (precondition for everything else)

**Question:** does WM-FTT measure something *consistent*, trial-to-trial,
before asking whether it measures something *meaningful*?

**Check:** internal consistency, computed **separately per feature**
(word/colour/orientation shouldn't be pooled into one reliability estimate,
they're different metrics with potentially different noise properties).
Split-half reliability (correlate scores from odd vs. even trials, or a
matched split respecting any counterbalancing) is the natural choice given
WM-FTT's structure; Cronbach's alpha is a reasonable secondary check if
trials-as-items is a defensible framing here. Test-retest is not currently
possible (no repeat-session data), noted as a limitation, not something to
attempt now.

**Amendment 2026-08-20: compute on responded trials only, with a stated
minimum engagement.** The task encodes non-response with per-feature
sentinels, and `02-score-computation.md` §2.5.2 scores those as 0. A
participant who never touched the orientation widget therefore has a
perfectly consistent score of 0 across every trial, odd and even alike,
which inflates split-half reliability while measuring nothing about
memory. Seven of 118 participant-by-version units have ≥92% orientation
non-response, enough to distort a per-feature estimate at these sample
sizes.

Two consequences. Reliability must be computed from
`score_*[responded_*]`, not the default score columns. And participants
below some minimum number of responded trials per feature must be dropped
from that feature's estimate, because a split-half correlation on three
usable trials is not an estimate.

**Result 2026-08-20, and the threshold derivation produced a finding of
its own.** Requiring the standard error of a participant's mean to be at
most half the between-person SD gives, in v1: 22 responded trials of 63
for orientation, 29 for colour, and **93 for word, more than the 63 that
exist**. Word's between-person SD among responders is 0.046 against a
within-person trial SD of 0.219, so no achievable number of trials makes a
participant's word mean precise enough to rank against another's. A floor
of 32 responded trials was used for word instead, recorded explicitly as a
data-sufficiency rule and **not** a precision guarantee.

**Split-half reliability, 1000 random trial-level splits, Spearman-Brown
corrected, v1, responders only:**

| Feature | n | Reliability | 95% interval |
|---|---|---|---|
| Orientation | 82 | **0.822** | [0.760, 0.872] |
| Colour | 87 | **0.832** | [0.772, 0.882] |
| Word | 87 | **0.445** | [0.251, 0.605] |

Orientation and colour clear the 0.80 mark comfortably. **Word does not
clear the 0.70 floor**, and this is the same fact as the threshold failure
seen from the other side: a measure whose between-person variance is small
relative to trial noise cannot be reliable, and 0.445 is what that looks
like.

**Consequence, per §3's principle that a weak result is reportable rather
than a stop condition:** orientation and colour support
individual-differences claims; **word does not**, and no downstream model
should make one for it regardless of what its coefficients say. See
`10-performance-modelling.md` §3.4.

**The threshold must be set on measurement-adequacy grounds and fixed
before looking at how it interacts with VVIQ.** Non-response is
imagery-correlated (§2.5), so a threshold chosen after seeing its effect
on the VVIQ results is an outcome-dependent exclusion rule, and reporting
it transparently would make the bias visible rather than remove it. State
the rule, then apply it.

**What a bad result would mean:** if scores are near-noise trial-to-trial,
no downstream model, in *any* framing, will find real signal, and any
"the effect is small" finding downstream becomes indistinguishable from
"the measure is too noisy to detect anything." This would be a serious,
not cosmetic, finding, worth surfacing prominently rather than quietly
proceeding past it.

### 2.2 Construct validity of the compositional/preference framing specifically

**Question:** does the proportion-based "preference" score track something
stable about the *person* (a trait-like allocation strategy), or mostly
trial-level noise and stimulus idiosyncrasies (some words are harder, some
color positions easier to place)?

**Check:** split-half stability of the *relative proportions* themselves
(not just each feature's raw score, per §2.1, but the derived
prop_word/prop_color/prop_angle profile) — compute the composition
separately on odd and even trials per participant, compare. If a
participant's preference profile bounces around unpredictably between
random trial splits, the ternary/biplot visualisation is substantially
showing measurement error, not a trait, regardless of how principled the
compositional transform itself is (§1 of `02-score-computation.md`).
This is specifically about the *preference framing's* validity, separate
from whether each individual feature score is reliable — a profile could
combine two individually-reliable features and still be an unstable
composition if the two features' noise is correlated in the wrong way, so
this needs its own check rather than being assumed to follow from §2.1.

**Amendment 2026-08-20: build the composition from responded trials
only.** A composition computed with non-responses scored 0 does not
measure relative allocation — it partly measures which features the
participant declined to answer. Since non-response differs by imagery
group and does so unevenly across features (21.7% vs 7.7% on the
non-verbal features, against 12.9% vs 7.6% on word — see §2.5), a
composition built from zeros would encode response propensity along
almost exactly the verbal/non-verbal axis that
`11-compositional-analysis.md` §2 recommends as the first ILR coordinate.

This has a second consequence for the stability check itself: a
participant who declines a feature consistently will show a *highly
stable* profile between odd and even splits, for reasons that have nothing
to do with a trait-like allocation strategy. Split-half stability
computed on score-0 compositions would therefore look better than the
measure deserves, in the direction of the desired conclusion.

**Result 2026-08-20: the gate passes.** Composition built from
responders-only means for the 81 v1 participants clearing all three
engagement thresholds, 1000 random trial-level splits, Spearman-Brown
corrected:

| Coordinate | Stability | 95% interval |
|---|---|---|
| ilr1, word vs (colour + orientation) | 0.771 | [0.692, 0.837] |
| ilr2, colour vs orientation | 0.721 | [0.598, 0.804] |

Both are respectable, and better than the parts' small spread (SD ≈ 0.03)
would suggest. Profiles are reasonably stable across random trial halves,
so the compositional strand is not simply displaying measurement error.

**One tension to state rather than resolve:** ilr1 is the theoretically
motivated coordinate and rests partly on the word component, whose own
split-half reliability is 0.445 (§2.1). A composition can be more stable
than one of its parts — the ratio carries information the level does not —
but the verbal/non-verbal interpretation should not lean on word as if it
were a well-measured quantity.

### 2.3 Convergent validity: behavioural allocation vs. self-reported strategy

**Question:** does the compositional/behavioural preference measure relate
at all to the self-report strategy data already collected?

**Result 2026-08-20: near-total dissociation.** Self-reported scoring
priority in v1 splits 41 "words", 40 "multiple", 6 "none/other", 1
"orientations". Their behavioural compositions are almost identical:

| Self-reported priority | n | prop_word | prop_orientation | prop_colour |
|---|---|---|---|---|
| words | 39 | 0.378 | 0.295 | 0.327 |
| multiple | 36 | 0.361 | 0.296 | 0.343 |
| none/other | 5 | 0.362 | 0.298 | 0.340 |

Self-reported priority predicts essentially nothing about actual
allocation — 0.017 separates the "words" group from the "multiple" group
on word share. This is a cleaner instance of the dissociation already
documented for v1 than the original colour-versus-word one, and per the
framing below it is a finding rather than a failure. It does mean
"preference" language must be used carefully: behavioural composition and
self-report are not measuring the same thing.

**Check:** correlate/compare the behavioural composition (§2.2) against
the self-report strategy questionnaire data. Important framing point,
already flagged in the philosophy discussion and worth restating here
explicitly: the existing v1 finding (self-report favoured colour, but
engaged-participant performance data favoured word) is **not evidence the
measure is invalid** — it's a real, potentially interesting dissociation.
This check is not a pass/fail test where convergence = valid and
divergence = invalid. It's there to establish, honestly, whether
behavioural allocation and self-reported strategy are the same construct
or meaningfully different ones, so the writeup doesn't implicitly treat
them as interchangeable when they might not be. Either outcome is
reportable; the check exists so the relationship is *known and stated*,
not assumed.

### 2.4 Criterion/discriminant validity against VVIQ

**Question:** does anything in WM-FTT relate to VVIQ or imagery group in
the direction the broader literature would predict, even weakly?

**Check:** simple, direct correlations/group comparisons between raw
per-feature scores (§2.1's inputs, not yet the compositional or clustering
outputs) and VVIQ (continuous) / imagery group (categorical). Deliberately
kept simple and description-level here, not a full model, this is a
sensitivity check on the task itself, not the performance-modelling
strand's actual analysis (that comes later, in performance-modelling
planning, and will be far more careful about the mutual-dependency issue
already flagged in the philosophy discussion). If literally nothing in
WM-FTT tracks VVIQ at all, that's a finding worth knowing before
performance/compositional/clustering models get built on top of it,
independent of which framing is used, since it would suggest the task
itself may not be sensitive to the individual-difference dimension under
study.

**Amendment 2026-08-20: run this both ways, and report both. As written,
this check is circular.** Non-response scores 0
(`02-score-computation.md` §2.5.2) and non-response correlates with VVIQ
(§2.5), so the missing-data convention manufactures part of the very
relationship this check is testing for. Measured directly on the current
data:

* cor(orientation score, VVIQ), non-responses included as zeros: **0.405**
* cor(orientation score, VVIQ), responders only: **0.191**

More than half the apparent relationship is an artifact of the
convention. Run as written, §2.4 would report a correlation roughly twice
its actual size and it would look like clean confirmation of the
literature's prediction — the most dangerous possible failure mode for a
sensitivity check, because nothing about the output would look wrong.

**Result 2026-08-20, v1, participants clearing the §2.1 engagement
thresholds. Spearman correlation with continuous VVIQ:**

| Feature | n | Non-responses as zeros | Responded trials only |
|---|---|---|---|
| Word | 85 | -0.024 (p = .83) | -0.025 (p = .82) |
| Orientation | 80 | +0.255 (p = .022) | **+0.223 (p = .047)** |
| Colour | 85 | +0.353 (p = .0009) | +0.164 (p = .135) |

**Narrowed 2026-08-20 to a discriminant prediction.** "Does anything track
VVIQ" cannot fail informatively. The sharper question is *which* feature
should: VVIQ is an object-imagery instrument, asking about the vividness
of pictorial scenes, so it should relate to **colour more than to
orientation or word**. Orientation is spatial-schematic rather than
pictorial, and VVIQ is not a spatial instrument. All three features stay
in the table; the prediction is about their ordering.

**Two honesty problems, written here rather than around.** First, this
prediction was formalised *after* the correlations were computed, so it is
post-hoc pre-specification and must be described as such. Second, and more
usefully, **the prediction comes out backwards**: the VVIQ relationship
sits on orientation (+0.223, p = .047) and not on colour (+0.164,
p = .135). A task whose imagery relationship loads on the spatial feature
rather than the pictorial one is a **discriminant validity failure**, and
that is a more informative result than the original framing could have
produced. It is worth reporting precisely because it is inconvenient.

**See also `08-predictor-form.md`.** The orientation result is further
qualified there: once a floor-group term is added, the continuous VVIQ
slope collapses to zero, so this correlation reflects a contrast between
complete aphantasics and everyone else rather than a gradient.

**Orientation survives the correction; colour does not.** Colour's
apparent relationship with imagery vividness is essentially all
convention: significant at p < .001 with zeros in, null once they are
removed. Orientation loses a little and remains significant. Word has
nothing either way, consistent with its 0.45 reliability (§2.1).

Had this check been run as originally written, the headline would have
been "colour recall tracks imagery vividness, p < .001". That claim does
not survive contact with the `responded_*` flags.

By imagery group (two-group split; the four-group split is unusable in v1
with hyperphantasia n = 3), responded trials only, Wilcoxon rank-sum: word
p = .86, orientation p = .10, colour p = .22. Nothing significant.
Dichotomising a continuous predictor costs power, and the orientation
effect that survives as a correlation does not survive as a group
contrast. Report the continuous result as primary.

**Required procedure:** compute both, report both, and treat the gap
between them as a result rather than as a robustness footnote. The
responders-only figure answers "does recall accuracy track VVIQ". The
all-rows figure answers a blend of that and "does willingness to respond
track VVIQ", and the second is §2.5's question, which deserves asking
directly rather than through a contaminated proxy.

If the two disagree substantially — as they do here — the honest report
is that WM-FTT's relationship to VVIQ operates partly through engagement
rather than purely through memory accuracy. That is a more interesting
claim than either number alone, not a weaker one.

**Caution carried over from the philosophy/scoring discussions:** v3 alone
is heavily skewed (14 aphantasia, 3 hypophantasia, 2 typical, 2
hyperphantasia) — group-comparison checks on v3 alone are underpowered by
construction. This check should probably run on the pooled sample (with
version noted, not ignored) for anything resembling a group comparison,
and treat any v3-only result as descriptive/exploratory only. Consistent
with the version-as-structural-factor position already established.

### 2.5 Response propensity as an outcome in its own right

**New section, 2026-08-20.** Added because implementing
`02-score-computation.md` turned a data-cleaning question into a
measurement-model one. The four questions above were written assuming
every trial yields a response. Between 9% and 19% do not, and which ones
is not random.

**Question:** does *whether* a participant reports a feature — as distinct
from how accurately — relate to imagery, version, or feature type?

**What is already known** (block trials, 118 participant-by-version units,
computed while implementing the scoring pipeline, so descriptive rather
than pre-registered). **Read the caveat below the table before using these
numbers** — they are pooled across versions and largely do not survive
stratification:

| Feature | ρ with VVIQ | p | Aphantasia | Typical |
|---|---|---|---|---|
| Orientation | −0.291 | 0.0015 | 28.4% | 11.3% |
| Colour | −0.303 | 0.0009 | 15.0% | 4.0% |
| Word | −0.195 | 0.036 | 12.9% | 7.6% |

Lower VVIQ, more non-response, steepest on the two non-verbal features —
**but this is a pooled estimate and it does not hold within version.**
Within v1 (n = 88, the only version with a balanced group split) the
correlations are −0.091 (orientation, p = 0.41), −0.183 (colour, p = 0.09)
and −0.054 (word, p = 0.62). The pooled figure is substantially produced
by v3 being both aphantasia-heavy and the highest-non-response version.
See `04-response-propensity.md` §3.1. The check specified below is
therefore genuinely open, not a confirmation exercise.

**Result 2026-08-20, v1 only.** Two estimators, deliberately reported
together because they disagree.

A quasi-binomial GLM of responded trials out of 63 against centred VVIQ,
by feature, gives slopes on the log-odds of responding of +0.008
(word, p = .42), +0.016 (orientation, p = .042) and +0.031 (colour,
p = .006). The participant-level rank correlations are weaker: -0.054
(word, p = .62), -0.091 (orientation, p = .41), -0.183 (colour, p = .092).
Directions agree throughout: higher VVIQ, more responding.

**Neither estimator is authoritative, and the modelling route was chosen
against the data rather than in advance.** A mixed binomial with a
participant random intercept is the natural structure but is overdispersed
by a factor of 4.2; absorbing that with an observation-level random effect
produces a degenerate fit (dispersion 0.17, one feature's SE an order of
magnitude below the others, a non-positive-definite covariance matrix). It
is not identifiable at N = 86. The quasi-binomial scales its standard
errors by an estimated dispersion of 16.9 but does not model the
correlation among a participant's three rows, so its p-values are
optimistic. The rank correlation ignores trial counts, so it is
conservative.

**Reading: suggestive for colour, not established; nothing for word or
orientation.** This is consistent with `04-response-propensity.md` §3.1's
corrected position rather than a change to it.

**A symmetry worth noting across §2.4 and §2.5.** For colour, the imagery
relationship runs through *whether* participants answer, and its accuracy
correlation is an artifact of scoring non-responses as zero. For
orientation, the reverse: accuracy tracks VVIQ (+0.223, p = .047) while
propensity does not. The two features relate to imagery through different
channels, which is a more specific claim than either "WM-FTT tracks VVIQ"
or "it doesn't", and it is only visible because the two quantities were
separated.

**Check:** model the per-feature `responded_*` indicator directly — a
binomial or beta-binomial outcome against VVIQ (continuous and grouped),
feature, and version. This is the same three-part logic
`03-parity-engagement.md` §1 applies to parity engagement: quantify the
variable, decide separately whether a discrete split is useful, decide
separately again what it is used *for*. What does not transfer is the
variable itself — see below.

**This is not parity disengagement.** The natural assumption is that
feature non-response and parity disengagement are the same underlying
withdrawal of effort, in which case `03` would already cover it. The data
says otherwise: per-feature non-response correlates with parity accuracy
at ρ = +0.12 (orientation, p = 0.20), +0.09 (colour, p = 0.35), +0.23
(word, p = 0.011). Weak, mostly non-significant, and **positive**: the
opposite sign from a shared-disengagement account. Two distinct
constructs. (Separately worth flagging to `03`: parity accuracy itself
correlates with VVIQ at ρ = −0.334, which that doc does not anticipate.)

**Interpretation, held open deliberately.** An aphantasic declining to
report a colour may be reporting the absence of a representation, which
would make this among the most on-target signals in the dataset. It may
equally reflect a widget that is harder to use without imagery, or a
rational choice not to spend effort on a feature one expects to fail. The
three have different implications and this check cannot separate them.
Say so rather than picking the flattering reading.

**Status:** exploratory. The pattern was noticed while implementing the
scoring pipeline, not predicted in advance, and must be reported as such.
This does not weaken it as a finding; it constrains how it may be
described.

### 2.7 OSIVQ multitrait-multimethod check

**New section, 2026-08-20.** The strongest validity test available in this
dataset, and the one §2.4 cannot be: OSIVQ's three subscales map onto
WM-FTT's three features, so the prediction is a *pattern* rather than a
single correlation.

| OSIVQ subscale | WM-FTT feature | Rationale |
|---|---|---|
| object | colour | pictorial, surface-property imagery |
| spatial | orientation | schematic, spatial-relational |
| verbal | word | verbal-analytic |

**The prediction:** the matching diagonal exceeds the mismatched
off-diagonal. That is convergent and discriminant validity in one test,
and unlike §2.4 it can fail informatively: if the diagonal does not beat
the off-diagonal, WM-FTT's features are not measuring feature-specific
representation, whatever else they measure.

**Result: the prediction fails.** v1, responded trials only,
threshold-clearing participants, Spearman:

| | Colour | Orientation | Word |
|---|---|---|---|
| **object** | **0.022** | 0.168 | 0.018 |
| **spatial** | 0.088 | **0.145** | 0.080 |
| **verbal** | -0.024 | 0.040 | **-0.100** |

Diagonal in bold. Nothing reaches significance (smallest p = .14). The
diagonal mean |r| is 0.089 against an off-diagonal mean of 0.070, a
difference of no consequence. Disattenuating for the reliabilities of both
instruments gives 0.120 against 0.088, still nothing. The largest
correlation in the matrix is object-Orientation (0.168), which is
off-diagonal, and the verbal-Word cell, the one with the clearest
theoretical rationale, is *negative*.

**Reading.** WM-FTT's per-feature scores show no convergent validity with
the cognitive-style subscales they should track. Three readings are
available and this check cannot separate them: the features may not
measure feature-specific representation; OSIVQ may measure self-reported
style rather than capacity, in which case the dissociation echoes §2.3's
self-report-versus-behaviour finding; or a single-trial recall task may
simply be too noisy for cross-instrument correlations at N = 88.

The second reading has independent support: §2.3 found self-reported
scoring priority predicts essentially nothing about behavioural
allocation. A task that dissociates from *both* self-report instruments in
the same direction is more consistent with "self-report and behaviour are
different constructs" than with "the task is broken". That is a claim
worth making explicitly rather than reporting a null and moving on.

**Word's cell is the least interpretable.** Its reliability is 0.45
(§2.1), which bounds any correlation it can enter, and disattenuation
divides by that small number so aggressively that the corrected value
(-0.163) should not be trusted. Both raw and disattenuated are reported
above rather than the flattering one alone.

**Reliability note, with a data-quality finding attached.** OSIVQ subscale
alphas in v1, computed from the raw items rather than cited: object 0.951,
spatial 0.861, verbal 0.842. Computing them naively from `all_data`'s
`osivq_items` gives 0.25 for verbal, because **v1 and v2 store four
reverse-keyed items unreversed while v3 stores them reversed**
(`osivq_q02v`, `osivq_q09v`, `osivq_q41v`, `osivq_q42s`). The subscale
*means* are correct in both versions; only the nested raw items differ.
Anyone recomputing OSIVQ scores from the item columns would get wrong
answers for v1/v2 and correct ones for v3. Documented in `R/data.R` and
the codebooks.

## 3. What this pass deliberately does NOT do

- **Not a full psychometric validation study.** No new data collection,
  no formal scale-validation framework (e.g., no attempt at IRT modelling
  of WM-FTT itself, no factor analysis of the task). Scoped to what's
  checkable from data already being collected.
- **Not the performance-modelling analysis.** §2.4's VVIQ check is a
  simple sensitivity check, not the real performance model (fixed
  effects, group × feature interactions, handling the mutual-dependency
  structure). That's a separate, later planning doc.
- **Not a gate that blocks all further work if imperfect.** Psychological
  measures are rarely perfectly reliable or perfectly convergent; the goal
  is to know where WM-FTT stands on each of these four axes and report
  that honestly, not to require passing some threshold before proceeding.
  A weak-but-nonzero reliability finding, e.g., is itself a usable,
  reportable result (with appropriate caveats on what can and can't be
  concluded from the data), not necessarily a stop condition, that
  judgement call comes after seeing the actual numbers, not decided in
  the abstract here.

## 4. Proposed implementation shape

Not written as code here (per current planning-only phase), but scoped
enough to hand off directly to an implementation session:

- **Sample:** v1 only (N=88), per `05-version-scope.md` §3.5. All four
  checks run on v1; v2 and v3 are reported descriptively in the scoring
  vignette but do not enter these analyses. Note this lowers the cost of
  §2.1's engagement threshold considerably — 7 of 88 excluded rather than
  20 of 118 — because v1's non-response rates are the lowest of the three
  versions.
- **Inputs needed:** the new raw + standardised per-feature scores
  (`02-score-computation.md`), the `responded_word`/`responded_angle`/
  `responded_color` indicators from the same pipeline (added 2026-08-20,
  and required by §2.1, §2.2, §2.4 and §2.5 — the score columns alone are
  not sufficient for any of them), trial-level (not just
  participant-level aggregates) data, since split-half reliability
  requires trial-level granularity, and the existing self-report strategy
  questionnaire columns.
- **Suggested location:** `inst/scripts/` alongside the score-computation
  test/plotting scripts already planned in `02-score-computation.md` §8 —
  this is exploratory/diagnostic work, not exported package functionality,
  consistent with how `inst/scripts/` is already being used for this kind
  of check.
- **Rough sequence:**
  0. Response propensity (§2.5) — run first, not last. It determines
     which trials the other three checks may legitimately use, and its
     own result is independent of theirs.
  1. Split-half reliability per feature (§2.1), responded trials only,
     with the engagement threshold fixed in advance — a bad result here
     reframes what's worth doing next.
  2. Split-half stability of the compositional profile (§2.2) — depends
     on (1)'s scores and on the compositional pipeline design from the
     philosophy discussion.
  3. Behavioural-vs-self-report comparison (§2.3).
  4. VVIQ/group sensitivity check (§2.4), v1, both scorings reported.
  5. OSIVQ multitrait-multimethod pattern test (§2.7).
- **Output:** likely a short diagnostic report (numbers + a handful of
  plots — split-half scatter/correlation per feature, profile-stability
  visualisation, self-report-vs-behaviour comparison), not a polished
  document. Candidate for its own EOR page (flagged, not decided) given
  it's a methodologically substantial, reusable diagnostic that future
  WM-FTT work (and possibly reviewers) would want to see directly, similar
  to the scoring page flagged in `02-score-computation.md` §8.

## 5. Open questions, not resolved here

- ~~Exact split-half procedure~~ **Resolved 2026-08-20.** The check this
  item demanded found a within-trial primacy effect (word drops 0.098 from
  serial position 1 to 3, colour 0.059, orientation 0.046), and items
  within a trial share an encoding episode, so items are not exchangeable.
  **Splits are drawn over the 21 trials with each trial's three items kept
  together**, balancing serial position across halves by construction, and
  repeated 1000 times rather than relying on one arbitrary odd/even
  partition. The warning not to assume odd/even was well placed.
- Whether Cronbach's alpha is a meaningful secondary reliability check here
  depends on how "trials as items" maps onto WM-FTT's design — not
  obviously a standard multi-item-scale case, worth confirming rather than
  applying by default.
- The minimum-engagement threshold for §2.1 — fixed proportion of
  responded trials, or derived from the observed distribution. Must be
  settled on measurement-adequacy grounds and stated before its
  interaction with VVIQ is examined (§2.1).
- Whether §2.7's null should be read as a property of WM-FTT, a property
  of OSIVQ, or a power limitation. The three have different consequences
  and this check cannot separate them.
- Whether the same reverse-coding inconsistency found in `osivq_items`
  (§2.7) also affects `vviq_items` and `nieq_items`. Not checked. It
  should be, before `13` uses NIEQ as a clustering input.
- Whether §2.5's non-response signal warrants its own EOR page or belongs
  inside this one — it has outgrown a subsection of a validity doc.
- Whether this pass should run once on the current data and be treated as
  final, or whether it should be re-run as v3 continues recruiting (v3 is
  explicitly still growing) — not decided here.

## 6. Next steps (not this doc)

- Implement `02-score-computation.md`'s scoring pipeline first — this pass
  depends on it.
- Design and implement the four checks above as `inst/scripts/` diagnostics.
- Decide, once results are in hand, whether findings are strong enough to
  state plainly in the methods section, or weak enough to require
  explicit caveating of what performance/compositional/clustering results
  can and can't support.
- Revisit EOR-page status once the scoring EOR page (if built) sets a
  precedent for format.
