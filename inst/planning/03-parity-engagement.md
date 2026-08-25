# WM-FTT: parity engagement

**Status: resolved 2026-08-24, and §11 supersedes §§2, 4 and 8.** The
variable this doc chose as primary did not exist: `parity_*_acc` scores
unanswered probes as 0, and in v1 92% of its zeros are unanswered rather
than wrong. Read §11 before acting on anything above it.

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
(`04-response-propensity.md`). The natural assumption is that this is the
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
(`05-version-scope.md` §3.5), and v1 carries no parity penalty.**
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
  `05-version-scope.md`). Defensible only if disengagement genuinely
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

**Where this connects to `06-task-validity.md`:** the engaged/disengaged
moderation finding is arguably as much a validity question (does the task
work as intended, for whom) as it is a performance-modelling question.
Worth deciding at write-up time whether it's presented primarily as a
validity finding, a performance-modelling finding, or both — not decided
here, flagged for later.

## 6. Cross-version dependency — read alongside `05-version-scope.md`

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
   on `05-version-scope.md`.

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
| Within-version vs. pooled definition of "engaged" | Depends on `05-version-scope.md`                                                           | Deferred to that doc        |

## 9. Open questions, not resolved here

- Confirm chance-level accuracy for WM-FTT's actual parity judgement
  structure before interpreting the distribution check.
- Whether the moderator analysis (§5, §7 step 4) is feasible outside v1
  given v2/v3 sample sizes — depends on pooling strategy.
- Whether engagement composition should be reported as a standalone
  table/figure in the chapter, or folded into the validity-checks writeup —
  not decided, low stakes either way, revisit at writing time.

## 10. Next steps (not this doc)

- Read `05-version-scope.md` alongside this one before implementing
  anything version-dependent here.
- Implement the distribution check (§7 step 1) first — its result shapes
  whether steps 2–4 need a threshold decision at all.
- Fold the covariate (§7 step 3) into the performance-modelling plan once
  that doc exists.

# --- appended below ---

## 11. Resolution, 2026-08-24

**The variable this doc is about did not exist.** `03` §2 chose "continuous
parity accuracy" as the primary variable, and §8 recorded that as settled.
It was not answerable as written, because `parity_1_acc` and
`parity_2_acc` are not accuracy variables.

### 11.1 What the columns actually contain

They score an unanswered probe as 0, the same convention `02` §2.5.2
applies to recall and that `04` exists to unpick. Nobody unpicked it here.
In v1, of 3315 zeros on `parity_1_acc`, **3046 are probes where
`parity_1_resp` and `parity_1_rt` are both `NA`** and only 269 are
answered-and-wrong.

Split at participant level over 126 probes each:

| Variable | median | at exactly 0 |
|---|---|---|
| Parity response rate | 0.694 | **25 of 88** |
| Accuracy given a response | 0.908 | 0 |
| The raw column, as used until now | 0.591 | 25 |

The raw column correlates **0.989** with the response rate and **0.215**
with conditional accuracy. It is a propensity measure wearing an accuracy
label, and that is the entire explanation for the bimodality and the spike
at zero that `10` §11 flagged.

The two components are close to orthogonal, r = 0.043. Collapsing them
does not blur two related quantities, it discards one.

### 11.2 Fix

`compute_scores()` now adds `responded_parity_1` and `responded_parity_2`
alongside the recall flags, via `flag_parity_responses()`. Analyses derive
a response rate and a responders-only accuracy from them exactly as they
do for recall. Regenerate `all_data` by re-running
`data-raw/04_apply_manual_review.R`.

### 11.3 Abandoning parity is not disengagement

25 of 88 answered no parity probe at all. They are **not** disengaged on
the main task:

| | parity zero (n = 25) | everyone else |
|---|---|---|
| Word non-response | 0.066 | 0.086 |
| Orientation non-response | 0.149 | 0.132 |
| Colour non-response | 0.061 | 0.069 |

**23 of the 25 clear the recall engagement thresholds.** v1 carries no
parity penalty (`05` §3.5), so ignoring the secondary task is the
rational move, and abandoning it while keeping recall intact is arguably
the most strategically sophisticated behaviour in the dataset. The old
variable coded it as failure.

### 11.4 Parity is not functioning as a load manipulation in v1

Parity response rate against recall accuracy, engaged sample, participant
level:

| Outcome | Slope | p |
|---|---|---|
| Word | -0.015 (SE 0.013) | 0.233 |
| Orientation | -0.043 (SE 0.029) | 0.139 |
| Colour | -0.013 (SE 0.026) | 0.632 |

A quarter of the sample opted out of the secondary task and gained nothing
measurable. That is a finding about the design rather than about the
participants, and it belongs in the v4 recommendations alongside the word
ceiling: a secondary task that can be ignored costlessly is not imposing
load.

### 11.5 The confound was tested and does not exist

The hypothesis: lower imagery leads to greater compliance, compliance
costs recall accuracy, so the floor-group effects on colour and
orientation are really parity effects. Tested on all three features,
engaged sample.

Link 1, imagery to compliance: parity response rate is **0.505 at the VVIQ
floor against 0.495 above it, Wilcoxon p = 0.925**. Absent, and this is
decisive: with no link 1 there is nothing to mediate.

Link 2 is §11.4 above, and the floor offsets barely move when parity is
controlled:

| Feature | Floor offset alone | Parity controlled | Change |
|---|---|---|---|
| Word | +0.0337 (p .076) | +0.0319 (p .094) | -5.5% |
| Orientation | -0.0447 (p .286) | -0.0504 (p .228) | -12.8% |
| Colour | -0.0685 (p .068) | -0.0702 (p .064) | -2.5% |

Word matters most here, because it carries the one floor offset that
clears zero in `10` §11's C-prime fit, and because it has the largest raw
correlation with parity engagement of the three. It was tested explicitly
rather than by inheritance, and the answer is the same.

### 11.6 Decisions, superseding §8

| Decision | Was | Now |
|---|---|---|
| Primary variable | Continuous parity accuracy | **Parity response rate**, which is what the old variable measured anyway (§11.1) |
| Second variable | A binary split, for a narrower purpose | **Accuracy given a response**, reported here as a data-quality and effort measure, kept out of the models |
| Role in modelling | Covariate | **Covariate on the accuracy arms of `09`**, as the dual-task load actually incurred, which is a strategy variable and not a confound control (§11.5) |
| Binary threshold (§4) | Open | **Moot.** The response rate is the continuous version of the same thing |

### 11.7 A published-facing page states the opposite, on a pooled sample

`vignettes/articles/engagement.Rmd` §2 is titled "Parity engagement is not
independent of imagery" and concludes that this "is the finding that stops
parity accuracy being usable as a nuisance covariate". Three things are
wrong with it.

**Its sample is not what its caption says.** `by_participant` applies no
version filter, so the table captioned "Parity accuracy against VVIQ, v1"
is computed on all three versions.

| Sample | rho | p |
|---|---|---|
| Pooled, as computed | -0.333 | 0.0003 |
| v1 only, as captioned | **-0.154** | **0.157** |

**The association does not survive stratification**, which is the exact
failure mode §3.1 of `04-response-propensity.md` records and that INDEX
§6.5 carries forward as the project's standing lesson. It was written into
a public page anyway.

**The variable is the broken one** (§11.1), so even the pooled figure is a
statement about willingness to answer probes rather than about accuracy.

Corrected, the direction of the claim reverses: parity response rate is
0.505 at the VVIQ floor against 0.495 above it, p = 0.925 (§11.5). The
page needs rewriting before the EOR is published, and the rewrite should
say what the section now shows rather than deleting it, since a pooled
association that dissolves on stratification is worth showing.

One observation worth a sentence and not a parameter: among participants
who did both tasks, parity conditional accuracy correlates 0.310 with
colour recall accuracy, 0.116 with orientation and 0.000 with word. That
looks like a shared-resource signal, and it is the only interesting thing
conditional accuracy does.
