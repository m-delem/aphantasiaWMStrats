# WM-FTT: parity engagement

**Status:** plan settled, not yet implemented. Amended 2026-08-20: §1 records a second, independent engagement signal (feature non-response) that does not reduce to parity, and flags that parity accuracy itself correlates with VVIQ. Touches validity checks,
performance modelling, and the sample-pooling decision (`02-pooling-
strategy.md`) — read that doc alongside this one, since how parity
engagement is analysed depends partly on how versions are pooled, and vice
versa.

**Context:** the handoff (§5.1) flags this as a real researcher-degrees-of-
freedom problem — the legacy `analyse_parity(threshold = 0.5, ...)` was
called with `threshold = 0.7` in the old exploratory vignette, with no
documented rationale for overriding the function's own default. The v1
finding already written up on the OSF wiki (§4 of the original handoff)
makes this more than a technical nuisance: ~70% of v1 participants
disengaged from the parity task once they realised it had no scoring
consequence, and the engaged and disengaged subgroups showed _different_
imagery-group effects. Parity engagement isn't just a filter to apply
before the real analysis, it's plausibly a real, theoretically meaningful
split in its own right.

---

## 1. Three separate decisions, not one

Discussion surfaced that "what to do about parity" was really three
stacked decisions, worth deciding independently rather than as one bundled
choice:

1. **How to quantify engagement** — continuous parity accuracy, or some
   derived measure.
2. **Whether/how to convert that into a discrete split** — threshold
   choice, and how to justify it.
3. **What the split (or continuous variable) is actually used for** —
   filter, covariate, or grouping/moderator variable. These are genuinely
   different analytical moves with different costs, not interchangeable
   options.

**Amendment 2026-08-20: a second, independent engagement signal exists,
and it does not reduce to parity.** Participants also decline to respond
to the recall features themselves, at rates of 9–19% of trials
(`08-response-propensity.md`). The natural assumption is that this is the
same withdrawal of effort this doc describes, in which case this doc would
cover both. It is not: per-feature non-response correlates with parity
accuracy at ρ = +0.12 (orientation, p = 0.20), +0.09 (colour, p = 0.35)
and +0.23 (word, p = 0.011) — weak, mostly non-significant, and
**positive**, meaning higher parity accuracy goes with *more* feature
non-response, the opposite sign from a shared-disengagement account.

The three-part structure in §1 above transfers to that variable directly
and is reused there; the variable itself does not. Two distinct
constructs, two docs.

**Separately worth flagging here: parity accuracy itself correlates with
VVIQ at ρ = −0.334**, which this doc does not anticipate anywhere. If
imagery group predicts parity engagement, then using parity accuracy as a
covariate (§2's decision) partially adjusts for imagery group, which is
not what a nuisance covariate is supposed to do. Not resolved here, but it
should be checked before parity accuracy enters any model as a covariate.

**Scope amendment 2026-08-20: v1 is the primary analysis sample
(`02-pooling-strategy.md` §3.5), and v1 carries no parity penalty.**
Verified directly: in all 1848 v1 trials the trial score equals the sum of
the three feature scores, with no deduction for incorrect parity
judgements. So in the version this doc's analyses will actually run on,
the parity task had **no scoring consequence at all**.

That is consistent with the ~70% disengagement already documented for v1,
and it sharpens what parity accuracy measures here: whether a participant
bothered with a task they had worked out was inconsequential. That is a
motivation or compliance measure, not a working-memory-load measure, and
Decision 1's use of it as a covariate should be described accordingly. A
model that treats it as an index of concurrent load would be
mis-specifying it for v1 data.

## 2. Decision 1: continuous accuracy as the primary variable

**Decided:** continuous parity accuracy (per-participant mean across the
two interleaved parity judgements, as the legacy `analyse_parity()` already
computed) is the primary variable, used directly wherever a model can
accept it — most importantly as a covariate/predictor in the performance
model. No threshold is needed for this use, and nothing is lost by keeping
it continuous there.

**Rationale:** avoids inventing a threshold for a purpose (modelling) that
doesn't require one. A continuous covariate lets the model itself show
whether parity engagement matters and how, rather than that being
predetermined by a cutoff decision made in advance.

## 3. Decision 2: a binary split is still separately useful, for a narrower purpose

**Decided:** a binary engaged/disengaged split is still worth constructing,
**not** as a substitute for the continuous variable, but because it answers
a different, genuinely descriptive question that a continuous covariate
doesn't directly answer: _who_ disengaged, and does that correlate with
version or VVIQ group. That's a composition question (a cross-tab: does
disengagement rate differ by version, by VVIQ group, by both), not a
modelling question, and it needs an actual categorical variable to produce.

**Scope check, worth remembering when implementing:** if the binary split's
only job ends up being a composition table, that's a narrow, low-stakes use
of it. If it later gets pulled into use as a moderator/grouping variable in
the performance model (§5 below), that's a bigger commitment and deserves
more scrutiny of the threshold choice than a descriptive table would.
Decide which use is actually happening before treating the threshold choice
as high-stakes or low-stakes.

## 4. Decision 2b: how to set the threshold, if a binary split is built

**Explicitly rejected:** hand-picking a single threshold (whether 0.5, 0.7,
or anything else) and defending it on intuition alone. This is the exact
problem already flagged in the legacy code (default vs. actually-used value,
undocumented), and picking a new number the same way just relocates the
problem rather than solving it.

**Decided approach, in order:**

1. **Look at the actual distribution first.** Plot parity accuracy across
   the pooled sample (histogram/density). If disengagement is a real,
   distinct behavioural mode, genuinely disengaged participants should
   cluster near chance-level accuracy for a binary parity judgement
   (~0.5), while engaged participants should cluster higher — this may
   produce a visible bimodality or inflection point that gives a
   data-driven threshold, rather than an asserted one. **This is the
   first concrete step of implementation** — cheap to produce, and its
   result determines whether steps 2–3 below are even necessary.
2. **If no clean bimodality:** report a small sensitivity range instead of
   committing to one number silently — show that the key downstream result
   (whichever analysis actually uses the binary split) holds across a
   plausible range (e.g., 0.5 / 0.6 / 0.7), rather than presenting one
   threshold as if it were uniquely correct.
3. **Document whichever choice is made, and why**, directly in the
   function/script — this is the one concrete process fix that directly
   addresses the handoff's original complaint (undocumented override of a
   default).

**Open, not resolved here:** what "chance-level" actually is for WM-FTT's
specific parity judgement needs to be confirmed against the true task
structure (binary parity judgement → chance = 0.5, assumed here but not yet
verified against the actual stimulus/response design) before the histogram
step above is interpreted.

## 5. Decision 3: what the variable(s) get used for

Three genuinely different uses, named separately because they carry
different costs and different justificatory burdens:

- **Filter** (exclude disengaged participants from the main analysis):
  the most destructive option — reduces effective sample size, which
  matters a great deal given v2/v3 are already small (see
  `02-pooling-strategy.md`). Defensible only if disengagement genuinely
  means the manipulation failed for that person in a way that invalidates
  their data for the specific question being asked, not just "engagement
  was imperfect." **Not the default choice** — needs an explicit
  justification each time it's proposed, not applied as a blanket
  exclusion rule.
- **Covariate** (continuous parity accuracy as a predictor): the least
  destructive, keeps all data, lets the model show whether/how much it
  matters. **Default choice for the performance model**, per Decision 1.
- **Grouping/moderator variable** (does the group × feature effect differ
  between engaged and disengaged subgroups): arguably the most
  theoretically interesting option, directly motivated by the v1 finding
  already on the wiki (engaged and disengaged subgroups showed _different_
  imagery-group effects — not a nuisance to control away, a real result
  about the task's validity conditions). This use case is why the binary
  split is worth building even though the continuous variable handles the
  covariate case.

**Where this connects to `03-validity-checks.md`:** the engaged/disengaged
moderation finding is arguably as much a validity question (does the task
work as intended, for whom) as it is a performance-modelling question.
Worth deciding at write-up time whether it's presented primarily as a
validity finding, a performance-modelling finding, or both — not decided
here, flagged for later.

## 6. Cross-version dependency — read alongside `02-pooling-strategy.md`

Parity engagement can't be fully scoped independent of the pooling
decision: whether "engaged" is defined and analysed **within each version
separately** or **pooled-then-split** depends on how versions are being
combined for power in the first place, and v1/v2/v3 differ in whether the
parity penalty existed at all (v1: no penalty, hence the ~70% disengagement
finding in the first place; v2/v3: penalty present, disengagement
presumably rarer or absent by design). This means the _base rate_ of
disengagement is expected to differ by version for design reasons, not
just as chance sampling variation, which has direct implications for the
composition-table use case in §3 (composition by version isn't just a
sanity check, a version effect on engagement rate is close to guaranteed
by design, and should be described as expected, not treated as a
surprising finding to explain).

## 7. Proposed implementation shape

Not written as code here (planning-only phase). Sequenced roughly as:

1. **Distribution check** (§4, step 1) — histogram of parity accuracy,
   pooled and by version. Cheap, informative, and determines whether a
   clean data-driven threshold exists at all.
2. **Composition table** — engagement (continuous summary + binary split,
   once/if defined) crossed with version and VVIQ group. Directly answers
   the "who disengaged" descriptive question from §3.
3. **Covariate integration** — continuous parity accuracy added to the
   performance-modelling plan (separate doc, not yet written) as a
   predictor.
4. **Moderator check** — engaged/disengaged as a grouping variable, testing
   whether v1's finding (different imagery-group effects between
   subgroups) replicates or is specific to v1's no-penalty design. This
   may only be meaningfully testable within v1 alone, given v2/v3's small
   samples and different task mechanics — flagged, not resolved, depends
   on `02-pooling-strategy.md`.

**Suggested location:** `inst/scripts/`, alongside the scoring and
validity-check diagnostics already planned, for the same reason — this is
exploratory/diagnostic work in its early stages (steps 1–2), only becoming
part of the "real" performance model at step 3.

## 8. Summary of decisions

| Decision                                          | Choice                                                                                        | Status                      |
| ------------------------------------------------- | --------------------------------------------------------------------------------------------- | --------------------------- |
| Primary engagement variable                       | Continuous parity accuracy                                                                    | Settled                     |
| Binary split — needed at all?                     | Yes, but for a narrow descriptive purpose (composition), not as covariate substitute          | Settled                     |
| Threshold-selection method                        | Data-driven (distribution check first), sensitivity range if no clean bimodality              | Settled                     |
| Threshold — single hand-picked value              | Explicitly rejected                                                                           | Settled                     |
| Default use in performance model                  | Covariate (continuous)                                                                        | Settled                     |
| Filter (exclusion) use                            | Not default, needs case-by-case justification                                                 | Settled                     |
| Moderator use                                     | Real candidate, motivated by v1's documented finding; feasibility depends on pooling decision | Flagged, not fully resolved |
| Within-version vs. pooled definition of "engaged" | Depends on `02-pooling-strategy.md`                                                           | Deferred to that doc        |

## 9. Open questions, not resolved here

- Confirm chance-level accuracy for WM-FTT's actual parity judgement
  structure before interpreting the distribution check.
- Whether the moderator analysis (§5, §7 step 4) is feasible outside v1
  given v2/v3 sample sizes — depends on pooling strategy.
- Whether engagement composition should be reported as a standalone
  table/figure in the chapter, or folded into the validity-checks writeup —
  not decided, low stakes either way, revisit at writing time.

## 10. Next steps (not this doc)

- Read `02-pooling-strategy.md` alongside this one before implementing
  anything version-dependent here.
- Implement the distribution check (§7 step 1) first — its result shapes
  whether steps 2–4 need a threshold decision at all.
- Fold the covariate (§7 step 3) into the performance-modelling plan once
  that doc exists.
