# WM-FTT: the joint propensity and accuracy model

**Status: agreed in principle 2026-08-24, not yet specified in full.**
This doc will hold the primary model of the study. What is recorded below
is what has been decided, so that the specification session starts from
the decisions rather than re-deriving them. The full parameter
pre-specification, the reporting set and the fitting plan are the next
task.

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

- Specify the model and its full parameter list.
- Fix the reporting set in writing.
- ~~Settle `03-parity-engagement.md`'s covariate form.~~ Done, `03` §11.6.
- Then `inst/scripts/09-joint-model.R`.
