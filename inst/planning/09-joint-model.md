# WM-FTT: the joint propensity and accuracy model

**Status: fitted 2026-08-25.** The script is `inst/scripts/09-joint-model.R`, the results are in §8.4b, and the public account is `vignettes/articles/joint-model.Rmd`.
This doc will hold the primary model of the study. §8 is the specification: the
formula, every parameter it yields, which of them are of interest and why,
the priors, and the fitting plan. It was written before fitting and
checked against brms without compiling, so the parameter names and counts
are the model's own.

## 1. Why this model exists

Two results forced it.

**The separation test failed.** `10-performance-modelling.md` §11.6 fitted
a joint propensity/accuracy model on orientation as a test of whether
analysing responders only was legitimate. The participant-level
correlation between response propensity and conditional accuracy is
**0.512 [0.257, 0.719]**, with 99.9% of the posterior above the ROPE. The
rule declared in advance of seeing that number says the joint model
becomes primary and that `11-compositional-analysis.md` inherits a
caveat.

**Abstention is itself an allocation decision.** Under a
points-per-feature incentive, declining to report a feature is the most
direct strategic act the task records. A model that filters abstention out
before analysis is describing less than the data contains. This is the
sense in which `00-framing.md`'s two framings are now secondary.

A third argument is structural rather than empirical: this is the only
analysis in the study that can use participants the others cannot. One
participant answered zero orientation trials and six more fall below the
engagement thresholds. They are invisible to every responders-only model
and highly informative about propensity.

## 2. Structure

Six responses: three response gates (Bernoulli) and three bounded
accuracies, with a 6x6 correlated participant random-intercept matrix and
`rescor` off.

Families follow `10-performance-modelling.md` §11.3: zero-one-inflated
Beta for word, Beta for orientation, Beta for colour after a
Smithson-Verkuilen squeeze.

Accuracy arms use `subset()` on the corresponding gate, so a participant
contributes to a gate whether or not they ever responded.

## 3. Sample: all 86 with VVIQ

**Changed from the engaged 79**, deliberately, and this is the doc that
owns the decision.

Propensity variance lives disproportionately in the participants the
engagement thresholds remove. Orientation non-response has SD 0.258 across
all 86 and 0.143 across the engaged 79; the maximum falls from 1.000 to
0.571. The thresholds exist to stop imprecise participant means being
treated as measurements, and a multilevel model with partial pooling and
an explicit gate handles that natively.

`11-compositional-analysis.md` stays on 79. The two samples are different
because the models are, and both must say so.

## 4. The correlations, which are the point

Fifteen correlations in four families:

| Family | n | Question |
|---|---|---|
| Propensity-accuracy, within feature | 3 | Selection: is conditioning on responding legitimate, and is it feature-specific or a general engagement trait? |
| Accuracy-accuracy, across features | 3 | Trade-off: does doing well on one feature cost another between people? |
| Propensity-propensity, across features | 3 | Do people who skip one feature skip others? |
| Cross terms | 6 | Everything else |

The orientation propensity-accuracy correlation of 0.512 was estimated
with only that feature in the model, so it cannot distinguish a
feature-specific effect from a general engagement trait. Six responses
can, and that distinction is what `04-response-propensity.md` §6's
mechanism question needs.

## 5. Decided in advance

- **Pre-specify the model and every parameter it yields, before fitting.**
- **Pre-specify which parameters are of interest and why**, so that
  choosing among fifteen correlations after seeing them is not possible.
- **On disagreement with the simpler models, this model wins**, provided
  it converged cleanly, because it conditions on less.
- **The simpler models are robustness and convergence checks, not
  corroboration.** They are the same data through a simpler lens, so
  agreement is not independent evidence.

## 6. Known risks, recorded before fitting

- **Convergence.** Fifteen correlations from 86 clusters. Build in stages:
  three gates alone, then all six. Settings: `adapt_delta = 0.99`,
  `max_treedepth = 15`, `lkj(4)` to regularise. Random intercepts only.
  If word's ZOIB arm is what breaks it, drop word's accuracy and keep its
  gate.
- **Prior-dominated parameters.** Word propensity has little variance to
  work with. Check which correlations moved off their prior rather than
  reporting all fifteen as findings.
- **Shrinkage artifacts.** Participants who rarely respond contribute few
  accuracy trials, so their accuracy intercept is weakly identified. The
  propensity-accuracy correlations deserve a sensitivity check excluding
  the most extreme abstainers.
- **Misspecification is now load-bearing.** Making the gate primary means
  the accuracy estimates are conditional on the gate being right.
  Responders-only is transparent about what it conditions on; this model
  is more principled if correct and more fragile if not.
- ~~**Interpretation depends on `03-parity-engagement.md`.**~~ **Resolved
  2026-08-24, and not in parity's favour.** The claim was that propensity
  conflates strategic abstention with disengagement and that parity
  discriminates them. It does not. Parity response rate is 0.505 at the
  VVIQ floor against 0.495 above it (p = 0.925), it predicts recall
  accuracy at p = .14 to .63 across the three features, and controlling
  for it moves the floor offsets by -2.5% to -12.8% in the direction of
  larger rather than smaller. See `03` §11.5.

  Two things follow. The joint model is unblocked, but because parity
  turned out not to be load-bearing rather than because the question was
  settled in its favour. And **parity enters as a covariate on the
  accuracy arms anyway**, in its corrected form (response rate, not the
  broken accuracy column), because it is the dual-task load a participant
  actually incurred and therefore a strategy variable in its own right.
  That is a correction to what `03` §5 and `10` §11 already specified, not
  a new addition.

## 7. Next steps

- ~~Specify the model and its full parameter list.~~ Done, §8.
- ~~Fix the reporting set in writing.~~ Done, §8.3.
- ~~Settle `03-parity-engagement.md`'s covariate form.~~ Done, `03` §11.6.
- ~~Write `inst/scripts/09-joint-model.R`.~~ Done.
- Fit it, stage 1 first, with `TEST_RUN <- TRUE`.

## 8. Specification, 2026-08-24

Written before fitting. Everything below has been checked against brms
with `get_prior()` and `make_standata()`, which run without compiling, so
the parameter names and counts are the model's own rather than asserted.

### 8.1 The formula

```r
gate <- function(f) {
  bf(as.formula(paste0("responded_", f, " ~ vviq + complete_aphant + (1 | p | id)")),
     family = bernoulli())
}
acc <- function(f, family) {
  bf(as.formula(paste0("score_", f, " | subset(responded_", f, ") ~ ",
                       "vviq + complete_aphant + parity_rate + (1 | p | id)")),
     family = family)
}

gate("word") + gate("angle") + gate("color") +
  acc("word",  zero_one_inflated_beta()) +
  acc("angle", Beta()) +
  acc("color", Beta()) +
  set_rescor(FALSE)
```

`subset()` is what lets one row carry six responses with independent
non-response, and what lets a participant contribute to a gate whether or
not they ever answered that feature. Confirmed by `make_standata()`: the
three gates each see all 5418 items, the accuracy arms see 4981, 4662 and
5048.

Families follow `10` §11.3, and `parity_rate` is the corrected variable
from `03` §11.6, not the accuracy column that preceded it. It sits on the
accuracy arms only: it is the dual-task load a participant incurred, and
it does not predict recall non-response (r between -0.10 and +0.09), so
there is no reason to put it on the gates.

### 8.2 Every parameter the model yields

54 parameters, in six groups.

| Group | n | What they are |
|---|---|---|
| `Intercept` | 6 | one per response, plus 1 more for ZOIB's `zoi`/`coi` block |
| `b` | 15 | `vviq` and `complete_aphantfloor` on all six responses; `parity_rate` on the three accuracy arms |
| `sd` | 6 | participant SD of each response's random intercept |
| `cor` | **15** | the 6x6 correlation matrix, off-diagonal |
| `phi` | 3 | Beta precision, one per accuracy arm |
| `zoi`, `coi` | 2 | word's inflation components |

Response names are `respondedword`, `respondedangle`, `respondedcolor`,
`scoreword`, `scoreangle`, `scorecolor`, **in that order**. brms strips the
underscores, so priors and draw columns use those forms and not the column
names.

The order matters and is not cosmetic. It determines the Stan code, so a
formula built in a different order is a different model as far as brms's
caching is concerned. The first version of the script appended word's
accuracy arm last, an artifact of a conditional block, and the fit from it
was discarded on 2026-08-25 in favour of this order. Both the script and
any vignette build the formula with `joint_formula()` for that reason:
with `file_refit = "never"` a vignette would otherwise display a formula
that is not the one behind its numbers.

### 8.3 What is of interest, fixed in advance

The 15 correlations are the reason the model exists, and they are not all
equally interesting. Three tiers, declared here so that choosing among
them after seeing them is not possible.

**Tier 1, foregrounded, 6 parameters.**

| Parameter | Question |
|---|---|
| `cor(respondedword, scoreword)` | Selection, word |
| `cor(respondedangle, scoreangle)` | Selection, orientation |
| `cor(respondedcolor, scorecolor)` | Selection, colour |
| `cor(scoreword, scoreangle)` | Trade-off or shared ability |
| `cor(scoreword, scorecolor)` | Trade-off or shared ability |
| `cor(scoreangle, scorecolor)` | Trade-off or shared ability |

The first three answer whether conditioning on responding was legitimate,
and whether the 0.512 found on orientation alone (`10` §11.6) is
feature-specific or a general engagement trait. Only a model carrying all
three can tell those apart, and that distinction is what `04` §6's
mechanism question needs. The second three test the trade-off reading
directly: `10` §11 found orientation and colour at **+0.586 [0.349,
0.764]**, so the prediction is positive, and a positive value means the
trade-off the task imposes is a within-trial constraint rather than a
between-person one.

**Tier 2, reported in a table with intervals, 9 parameters.** The three
propensity-propensity correlations (do people who skip one feature skip
others) and the six cross terms. Interesting if large, not the reason for
fitting.

**Tier 3, the fixed effects.** The six `complete_aphantfloor` offsets are
the confirmatory quantities and are reported for all six responses. The
six `vviq` slopes are reported and expected to be null, per `08` and the
flat comparison in `10` §11. The three `parity_rate` coefficients are
reported and expected to be near zero, per `03` §11.4.

**Word's accuracy coefficients remain excluded from individual-differences
inference** (`10` §11.4). Its gate coefficients are not: whether someone
answers is not a low-reliability quantity.

### 8.4 What each result would mean, before it exists

- **Selection correlations near zero**: the responders-only analyses in
  `10` and `11` were legitimate after all, and the orientation result was
  feature-specific. Report both, keep both.
- **Selection correlations positive and large across all three**: a
  general engagement trait, `11` inherits its caveat, and the joint model
  is the only defensible view of accuracy.
- **Accuracy correlations positive**: shared ability dominates between
  people, and `11` §13.3's negative partial correlations were closure
  artifacts. This is the expected outcome given `10`.
- **Accuracy correlations negative**: a genuine between-person trade-off,
  which would be a surprise and would need `11` re-read in its light.
- **Floor offsets in the gates**: complete aphantasics differ in what they
  are willing to report, which is a different and arguably more direct
  claim about strategy than any accuracy difference.

### 8.4b Outcome, 2026-08-25: the dichotomy was too coarse

Fitted cleanly (max R-hat 1.004, no divergences, no treedepth saturation,
minimum bulk ESS ratio 0.13 over 8000 draws). Recorded here as a **third
case §8.4 did not anticipate**, rather than filed under whichever branch
it most resembles.

**Selection is feature-specific.**

| Pair | median | 95% | PD |
|---|---|---|---|
| Word gate and accuracy | 0.131 | [-0.249, 0.481] | 0.76 |
| **Orientation gate and accuracy** | **0.557** | **[0.327, 0.729]** | **1.00** |
| Colour gate and accuracy | 0.012 | [-0.240, 0.252] | 0.54 |

Neither "near zero" nor "large across all three". What follows is narrower
and more useful than either branch: **responders-only analysis is sound
for word and colour, and conditions on something real for orientation.**
Pages mixing all three features inherit a weakened, feature-specific
caveat rather than a blanket one. `11`'s caveat is narrowed accordingly.

Two things make the orientation result credible rather than suspect. It
replicates the value from the orientation-only model, 0.52 there against
0.56 here, so it is not an artifact of the smaller specification. And
orientation is the one feature whose gate is **inferred** rather than
observed: an untouched widget returns 90 degrees, so genuine 90-degree
responses are miscoded as non-responses. That miscoding removes
guaranteed-wrong trials from the accuracy of exactly the participants with
low measured response rates, which pushes the correlation **negative**.
Finding it positive despite that makes it conservative.

**Accuracy correlations are positive**, as `10` predicted: orientation and
colour 0.456 [0.210, 0.654], PD 1.00. The trade-off the task imposes is a
within-trial constraint, not a between-person one, and `11` §13.3's
negative partial correlations were closure artifacts. Confirmed.

**The gate floor offsets are not a null, they are no result.** On the
probability scale the orientation gate's interval runs from about 0.84 to
0.99, consistent with a large difference and with none. Non-response is
7 to 14% of trials and the floor group is 20 people. This was billed as
the claim no earlier analysis could make, and the model does not have the
precision to make it. That belongs in the v4 recommendations: **to measure
abstention you need a task in which abstention is common.**

**The largest correlations in the model were not in the reporting set.**
The three gate-to-gate pairs are 0.447, 0.586 and 0.752, all with PD 1.00.
Willingness to report is a strong participant-level trait, far more
coherent across features than accuracy is, and the two connect only on
orientation. Exploratory by §8.8, labelled as such wherever it appears,
and the clearest available evidence that abstention deserved modelling
rather than filtering.

### 8.5 Priors

Gates and accuracy arms are both on the logit scale, so priors go per
coefficient rather than per class: a `vviq` slope acts over a 64-point
range, a binary offset does not.

```r
prior(normal(0, 1.5), class = "Intercept", resp = <each>)
prior(normal(0, 0.05), class = "b", coef = "vviq", resp = <each>)
prior(normal(0, 1),    class = "b", coef = "complete_aphantfloor", resp = <each>)
prior(normal(0, 1),    class = "b", coef = "parity_rate", resp = <accuracy arms>)
prior(lkj(4),          class = "cor")
```

`lkj(4)` rather than the `lkj(2)` used in `10`, because 15 correlations
from 86 clusters need more regularisation than 3 do. It concentrates mass
near the identity, so a correlation has to be earned. **Check which
correlations moved off the prior** rather than reporting all 15 as
findings: the ones involving word's gate are the likeliest to be
prior-dominated, since word non-response has an SD of only 0.088.

### 8.6 Fitting plan

Two models, and the first is not a warm-up.

1. **The three gates alone.** This is `04-response-propensity.md`'s own
   model, and without it that strand has no fitted model at all. It is
   also the only place the three propensity correlations are estimated
   without the accuracy arms pulling on them, which makes the comparison
   in the script's §8 a real diagnostic rather than a formality.
2. **All six.** The full model.

**Confirmed 2026-08-25: the full model samples**, so the staging is no
longer a convergence strategy. The fallback switches are gone from the
script; the fallback order below stands as a manual edit if it is ever
needed.

`adapt_delta = 0.99`, `max_treedepth = 15`, 4 chains. Random intercepts
only, no slopes. Expect this to be slow.

Sanity checks against models already fitted: gate coefficients from stage
1 should resemble `04`'s descriptive rates; the accuracy floor offsets
should resemble `10` §11's C-prime fit (word +0.587, orientation -0.109,
colour -0.238, all on 79 rather than 86); and
`cor(respondedangle, scoreangle)` should resemble 0.512.

**If it will not converge**, in order of what is given up: drop
`parity_rate` (it is expected null anyway), then drop word's accuracy arm
while keeping its gate, then fall back to the staged models and report
them as primary with this attempt documented as a failure.

### 8.7 Sample and its consequences

All 86 participants with VVIQ, per §3. This is 7 more than `10` and `11`
use, and one of them answered zero orientation trials.

The engagement thresholds of `06` §2.1 are **not** applied. That rule
exists to stop imprecise participant means being treated as measurements,
and this model does not form participant means: partial pooling handles
unequal precision and the gates model the abstention directly. Recorded as
a decision rather than an omission.

Every reported quantity must say which sample it came from. `11` stays on
79, `10` stays on 79, this stays on 86, and the comparison in §8.6 is
therefore approximate by construction.

### 8.8 Pre-declared, and repeated here because it matters

- ~~On disagreement with `10` or `11`, **this model wins**, provided it
  converged cleanly, because it conditions on less.~~ **Amended
  2026-08-26.** That rule was written when this model was primary, and it
  is too broad now that it is not. It reads:

  > The **composition** (`11`) is primary for allocation, which is what
  > the study was designed to measure and what the thesis's Chapter 2.III
  > prediction is about. **This model** is authoritative on selection and
  > on willingness to report, which `11` cannot see at all. Where this
  > model bears on allocation, it speaks to whether the composition was
  > **computable**, not to what it found.

  The reasoning: this model appears in no design-time hypothesis. It was
  built mid-analysis because `10` §11.6 found that conditioning on
  responding might not be innocent, which makes it a check on a result
  rather than the result. It conditioning on less remains true, and is why
  it is the right instrument for the question it was built for.
- `10` and `11` are **robustness and convergence checks, not
  corroboration**. Same data, simpler lens; agreement is not independent
  evidence.
- The reporting set in §8.3 is fixed. Anything outside it that turns out
  to be interesting is **exploratory** and is labelled as such.
