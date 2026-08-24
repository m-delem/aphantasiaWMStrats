# WM-FTT: version scope and pooling strategy

**Status:** plan settled at the level of principles and a decision
procedure. Amended 2026-08-20: §3 step 4 extended to require per-version
non-response reporting, after versions turned out to differ sharply in
engagement as well as in task mechanics. Otherwise unchanged; the actual numerical decision (pool or not, and how) is
deferred to implementation time, once real per-version sample sizes and
distributions are back in hand. This doc is a precondition for
`03-parity-engagement.md`, `06-task-validity.md`, and every future
performance/compositional/clustering doc — read it before those make any
version-dependent choice.

**Context:** raised directly in the handoff (§3–4) as a real, unresolved
constraint, not incidental background. Real numbers as of the handoff
(re-verify before use, v3 is explicitly still recruiting):

|     | v1  | v2  | v3  | Total |
| --- | --- | --- | --- | ----- |
| N   | 88  | 9   | 21  | 118   |

v3-only VVIQ group breakdown is heavily skewed (14 aphantasia, 3
hypophantasia, 2 typical, 2 hyperphantasia) — a v3-only group comparison is
underpowered on the comparison side almost by construction. The OSF wiki's
own stated conclusion (already written, considered, not to be re-derived):
_"v1 and v2 data are not directly comparable to v3 data as a single pooled
sample without accounting for these mechanic differences... any comparative
or pooled analysis across versions needs to treat version as a structural
feature of the design, not a nuisance covariate."_

This doc exists to turn that already-stated position into an actual
decision procedure usable across the four analytical strands (validity
checks, performance, compositional, clustering), rather than re-litigating
it separately in each one.

---

## 1. What "version as a structural feature, not a nuisance covariate" actually requires

This phrase from the wiki is doing real work and is easy to nod along to
without cashing out what it implies practically. Worth being explicit:

- **"Nuisance covariate"** would mean: include `version` as a control
  variable, absorb its main effect, and otherwise treat the pooled sample
  as homogeneous — implicitly assuming the _relationships_ between
  variables (e.g., group × feature effects) are the same across versions,
  and only the _overall level_ differs.
- **"Structural feature"** means the opposite assumption is more
  appropriate: the relationships themselves may differ by version, because
  the task mechanics genuinely differ (fixed vs. randomised response
  order; parity penalty absent/present; shared vs. independent
  pseudonymisation infrastructure — the last of these is an
  infrastructure difference, not obviously an effect on cognition, but the
  first two plausibly are). This means version needs to be allowed to
  **interact** with the effects of interest, not just shift their
  intercept, if pooling happens at all.

Concretely: pooling with `version` as a fixed effect but no version ×
predictor interactions is _not_ actually honoring the wiki's stated
position, even though it looks like "accounting for version." That would
still be treating version as a nuisance covariate, just a modeled one.
Genuinely treating it as structural means either (a) allowing interactions,
at real statistical cost given v2/v3's size, or (b) not pooling for the
specific question at hand, or (c) analysing within-version and only
comparing/triangulating findings qualitatively across versions rather than
statistically pooling.

## 2. This is not one decision — it's a per-question decision

Discussion so far (across the parity doc and this one) surfaced that
pooling isn't a single yes/no to settle once. Different analytical
questions can reasonably make different pooling choices:

- A question about **absolute prevalence or composition** (e.g., "what
  proportion of participants disengage from parity") may be reasonably
  described **per version**, without needing to pool at all — precisely
  because the base rate is expected to differ by version _by design_ (v1
  had no parity penalty; v2/v3 did), so a version difference here isn't
  evidence pooling is invalid, it's an expected design consequence, as
  already noted in `03-parity-engagement.md` §6.
- A question about a **specific v3-only design feature** (e.g., does
  response-order randomisation change anything) is by construction not
  poolable — v1/v2 don't have the randomised-order data to compare against.
- A question that needs **statistical power** the individual versions
  don't have alone (plausibly most of performance modelling, compositional
  modelling, and clustering, given v2=9 and v3=21) has a real tension:
  pooling is attractive for power, but honoring §1 means paying a
  complexity cost (interactions) that partially erodes the power gain
  pooling was meant to provide.

**Decided:** don't attempt one global pooling decision. Each analytical
doc (parity, performance, compositional, clustering) should state its own
pooling choice explicitly, using the decision procedure below, rather than
inheriting an unstated assumption from this doc or from each other.

## 3. Decision procedure for "should this specific analysis pool, and how"

Proposed as a checklist to apply per-analysis, not a single formula:

1. **Does the question require between-version comparison specifically?**
   (e.g., "did v3's randomisation fix anything") → not a pooling question
   at all, analyse the relevant versions separately by construction.
2. **Is the question primarily descriptive/compositional** (rates,
   breakdowns, sample characterisation)? → report per version by default;
   a pooled summary number can be secondary/supplementary, clearly labelled
   as collapsing across mechanically different designs.
3. **Does the question need pooling for power** (most model-based
   questions, given v2/v3 size)? → then:
   a. Check whether the specific effect of interest is one where task
   mechanics (response order, parity penalty) plausibly matter. If yes,
   version × effect interaction should be included if at all
   statistically feasible, not omitted for convenience.
   b. If an interaction can't be reliably estimated (likely, given v2=9),
   that's itself a finding to state plainly — "pooled model assumes
   the effect is consistent across versions; this assumption is largely
   untested given v2/v3 sample size" — rather than silently pooling and
   not mentioning the assumption.
   c. Consider v1-only as a parallel/primary analysis where v1 alone has
   sufficient power (N=88), with pooled v1+v2+v3 as a secondary/
   supplementary analysis, rather than only ever reporting the pooled
   version. This directly serves the poster/chapter distinction in §5
   below.
4. **Regardless of (1)–(3), report version composition alongside any
   pooled result** — a pooled effect size or estimate without the
   underlying version breakdown visible next to it invites exactly the
   "is this actually one effect or an artifact of unequal version mixing"
   question a reviewer would reasonably ask.

   **Extended 2026-08-20: report per-version non-response rates too, not
   just group composition.** Versions differ sharply in how often
   participants respond at all, which this doc did not anticipate —
   orientation non-response runs 13.6% / 32.5% / 37.0% across v1 / v2 /
   v3, colour 6.7% / 19.6% / 15.0%, word 8.0% / 14.1% / 17.0%
   (`04-response-propensity.md` §3.4). This is a version difference in
   *engagement* rather than in task mechanics, and since roughly half the
   between-participant variance in the score columns is reporting
   propensity rather than accuracy, pooling versions pools populations
   with materially different response behaviour. Whether the gradient
   reflects v3's randomised recall order, v3's deliberately
   aphantasia-heavy composition, or interface changes is not identifiable
   from these data, and the three differ in what they imply for pooling —
   which is precisely why the rates belong next to any pooled estimate.

## 3.5 Resolved 2026-08-20: v1 is the primary analysis sample

**The procedure above has now been run against real data and it resolves
to step 3c. v1 (N=88) is the primary analysis sample for the thesis
chapter; v2 (N=9) and v3 (N=21) are retained and reported descriptively
but do not enter the inferential analyses.**

Framed deliberately as "v1 is primary" rather than "v2 and v3 are
excluded" — the data is kept, described, and available, and the pipeline
built on v1 is explicitly a template to be re-applied when later versions
have the sample to support it.

**Why the procedure lands here:**

- **Group balance.** v1 is 31 aphantasia to 55 typical. v2 is 8 to 1 and
  v3 is 17 to 4. Group comparison is not merely underpowered in v2/v3, it
  is structurally impossible.
- **Pooling actively created a false result.** The apparent association
  between reporting propensity and imagery (~ρ −0.30 pooled) dissolves
  within version, because v3 is simultaneously aphantasia-heavy and the
  highest-non-response version (`04-response-propensity.md` §3.1). This is
  step 3b's warned-of assumption failing in practice, not in principle.
- **v1-only is cleaner, not just smaller.** Responders-only accuracy
  against VVIQ in v1: orientation ρ = +0.229 (p = 0.035), colour +0.173
  (p = 0.11), word −0.003. The pooled analysis was mixing strata; the
  stratum on its own is interpretable.
- **Standardisation stability.** v2's per-version z-scores move by a
  median of 0.13 SD and up to 0.945 SD when any single participant is
  removed (`02-score-computation.md` §3). It cannot carry its own scale.
- **Recruitment reality.** v3 will not grow before the thesis handoff, so
  waiting is not an option and freezing a partial v3 mid-recruitment would
  be worse than declaring it out of scope.

**One exception, and it is a real use rather than a hedge.** v1 has
**fixed** recall order (word, then orientation, then colour), so feature
differences in the primary analysis are confounded with output position.
v3 is the only version with randomised recall order and can estimate that
order effect directly (21 participants × 63 trials is ample for a main
effect). **v3 is used for exactly this and nothing else** — quantifying a
confound that sits inside the primary result. This is step 1 of the
procedure above, a genuinely between-version question, not pooling.

**Costs to state wherever they bite:**

- **v1 carries no parity penalty.** Verified directly: in all 1848 v1
  trials the trial score equals the sum of the three feature scores. So
  parity accuracy in v1 measures whether a participant bothered with a
  consequence-free secondary task — a motivation measure, not a
  working-memory-load measure (`03-parity-engagement.md`).
- **v1 has the lowest non-response** (8.0% / 13.6% / 6.7% for word /
  orientation / colour). Choosing v1 means choosing the version where
  `04`'s phenomenon is least visible, which confirms `04`'s role as
  design-facing rather than analytical.
- **The four-group VVIQ split is unusable** in v1 (hyperphantasia n = 3).
  Two-group or continuous VVIQ only.

**What this retires:** §3's steps 3a and 3b stop applying to this
chapter's analyses; `10-performance-modelling.md` §6's version layer and
`11-compositional-analysis.md` §6 become moot; `02-score-computation.md`
§3's small-N standardisation caution disappears with v2 out of scope; and
the participant appearing in both v1 and v3 (`02` §3) resolves
automatically, since only the v1 record is in scope.

## 4. Bayesian modelling makes step 3 more tractable than it would otherwise be

Worth naming directly, since the modelling approach is now fully Bayesian
(brms) rather than the old frequentist/Bayesian-in-parallel legacy code:
partial pooling / hierarchical structure is a natural fit for exactly this
problem. Rather than a binary choice between "fully pooled, version
ignored" and "fully separate per-version models," a hierarchical model
with version as a grouping factor can let version-level effects be
partially pooled toward a common estimate, shrinking v2's noisy
9-participant estimate toward the pooled pattern without fully assuming
it's identical to v1/v3. This doesn't make the sample-size problem
disappear, v2 will still contribute little independent information, but it
is a more principled middle ground than the all-or-nothing framing in §3
might otherwise suggest, and worth keeping in mind once the performance-
modelling doc is written (not designed in detail here, flagged for that
doc specifically).

## 5. Direct implication for the two deadlines

Stated plainly since it's a real scoping decision, not just a statistical
one:

- **Poster (~3 weeks):** almost certainly cannot support a fully-interacted
  version-structural model in the time available, and the audience likely
  doesn't need that level of nuance for one or two headline figures. Most
  likely scope: v1-only or pooled-with-a-clearly-stated-simplifying-
  assumption, explicitly chosen for the poster's purposes and stated as
  such, not silently. This is a scope decision to make explicitly when the
  poster content itself gets planned, not resolved here.
- **Thesis chapter (~4 weeks):** needs to actually engage with the version
  story (per the handoff's own framing, §1, "likely mirroring the
  narrative already written up in the OSF wiki's Version history page"),
  which means the chapter is a more natural home for the fuller
  per-version / structural treatment than the poster is. The chapter has
  more room to say "here's what v1 alone shows, here's what pooling adds
  and what it costs, here's what's still v3-only and provisional."

Neither of these is decided in detail here — flagged as the natural
consequence of §3's decision procedure once applied to each deadline's
actual content, to be resolved when poster/chapter scoping happens.

## 6. What this doc deliberately does not do

- Does not decide, for any specific analysis, whether to pool. That's
  intentionally left to each analytical doc, using §3's procedure.
- Does not design the hierarchical/partial-pooling model structure in
  detail (§4) — that belongs in the performance-modelling doc, not here.
- Does not resolve whether v2 (N=9) is large enough to be usefully included
  in _any_ pooled analysis versus being reported descriptively only and
  excluded from modelling — worth a concrete look at v2's data before
  deciding, not an abstract call.

## 7. Summary of decisions

| Decision                                             | Choice                                                                               | Status                                  |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------ | --------------------------------------- |
| Single global pooling decision for all analyses      | Rejected — decide per analysis                                                       | Settled                                 |
| "Structural, not nuisance" cashed out as             | Version × effect interactions where feasible, not just a version main effect         | Settled                                 |
| Decision procedure for individual analyses           | 4-step checklist (§3)                                                                | Settled                                 |
| Modelling approach for handling version              | Hierarchical/partial pooling (brms), not binary pool-vs-don't                        | Settled in principle, design deferred   |
| Report version composition alongside pooled results  | Always                                                                               | Settled                                 |
| Poster vs. chapter treatment                         | Likely simpler/stated-assumption for poster, fuller structural treatment for chapter | Flagged, to be resolved at scoping time |
| v2 (N=9) inclusion in modelling vs. descriptive-only | Not decided                                                                          | Open                                    |

## 8. Open questions, not resolved here

- Is v2 (N=9) worth including in modelled analyses at all, or should it be
  reported descriptively only? Needs a look at v2's actual data
  characteristics, not an abstract sample-size rule.
- How much can a hierarchical model with 3 version levels (one of which has
  N=9) actually estimate reliably? Worth a basic prior-predictive or
  simulation check before committing design effort, rather than assuming
  brms will "handle it" by virtue of being Bayesian.
- Where exactly the poster's simplifying assumption should land (v1-only?
  pooled-with-caveat?) — deferred to poster-scoping.

## 9. Next steps (not this doc)

- Apply §3's procedure explicitly in `03-parity-engagement.md`'s
  within-version-vs-pooled question (already flagged there as deferred to
  this doc).
- Apply §3 again when the performance-modelling doc is written — that doc
  should state its pooling choice using this procedure, not re-derive one.
- Same for compositional and clustering docs, once reached.
- Revisit v2 inclusion (§8) with actual data in hand before finalising any
  model structure.
