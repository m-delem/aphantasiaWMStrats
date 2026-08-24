# WM-FTT: framing

**Status: superseded in emphasis, 2026-08-24, and retained as the record of how the framing got there.** This doc argues that the performance and compositional framings are complementary rather than competing (§3). That conclusion still holds, but both are now **secondary**. §5.5 already recorded a third quantity, reporting propensity, that the three-strand framing does not account for; the joint model in `09-joint-model.md` makes that quantity central and models propensity and accuracy together across all three features. Abstention is itself an allocation decision, and arguably the most direct one the task records, so a model that treats it as a nuisance or a filter is describing less than the data contains. Read §3 as a settled sub-question rather than as the project's organising question.

Earlier status, retained: discussion concluded, positions and open items summarised. Amended 2026-08-20: §5.5 added, recording a third quantity (reporting propensity) that the three-strand framing does not account for, and which bears directly on §3's framing disagreement. This is the earliest, most foundational doc in the WM-FTT planning set. Written retrospectively, after the discussion, as a record to reuse rather than re-derive.

**Context:** a live disagreement within the project about how to frame the analysis. One position is a performance framing (are aphantasic participants simply better or worse at recalling one feature type than another); the other, developed by the author, is a compositional/relative "preference" framing (ternary plots, biplots, relative proportions across the three features), on the grounds that it's more faithful to what WM-FTT can say about individual differences in mental representation, not just impairment-or-not. This was the author's own analytical instinct, developed through prior solitary testing and reflection, not a snap take — treated accordingly in the discussion.

---

## 1. The task's own design is evidence, not just two equally-valid tastes

The OSF wiki's task description states the scoring is deliberately built to force a trade-off: partial credit per feature, participants explicitly told to maximise total score, described directly as meant "to elicit a genuine strategic trade-off between feature types, rather than uniform effort across all three." This is load-bearing for the whole debate: it means the task is a resource-allocation task by design, not incidentally.

**Conclusion:** modelling the three feature scores as if independent absolute performance measures is arguably a mismatch with the task's own logic, not just a different analytical preference. A participant scoring higher on word than colour hasn't necessarily "performed worse at colour," they may have deliberately allocated less effort there. Performance-only models can't distinguish "worse at X" from "chose to prioritise Y over X." This is a genuine construct-validity argument in favour of the compositional framing, not merely an aesthetic one.

## 2. The compositional instinct is methodologically real, not idiosyncratic — but comes with real technical commitments

This class of problem has a name and literature: ipsative/compositional data (values that sum to a constant, inducing forced negative correlation between components). The field-level position (compositional data analysis, Aitchison geometry) is that this is a legitimate and well-studied data type, not a fringe move — but it comes with real technical obligations if used for actual inference (not just visualisation): standard correlation/regression on raw proportions is invalid without an appropriate transform (e.g. log-ratio transforms), because a 3-part composition only has 2 degrees of freedom. **This means adopting the compositional framing isn't just a stylistic commitment, it's a commitment to doing the transform properly** — flagged here, detailed design deferred to the compositional-analysis doc (not yet written).

## 3. The two framings are not mutually exclusive, and should not be presented as either/or

**Conclusion, explicitly stated during discussion and holding since:** raw per-feature performance and compositional/relative preference are different analytical objects doing different, complementary jobs, not competing answers to the same question. Practical implication when the two are presented together: give raw performance as a required baseline (keeps WM-FTT comparable to how the rest of the field currently reports feature-specific WM data, and answers the direct question most readers will have) and compositional analysis as the additional theoretical contribution — not a concession, a acknowledgement that they answer different questions.

**Follow-on, from later discussion (see `03-parity-engagement.md` §5 for one concrete instance):** "solving the mutual-dependency flaw" in the performance framing was identified as a real, well-posed statistical task in its own right — i.e., even the performance strand shouldn't be three independent univariate models pretending the features are unrelated, it should be a multivariate/multilevel structure that respects the features' non-independence. This is a direct consequence of accepting §1's argument: if the task forces trade-offs, _any_ framing of the results, performance included, needs to represent that dependency somehow, not just the compositional one.

## 4. A third framing exists, independently relevant, with an important provenance correction

Literature search during this discussion surfaced recent work (2024–2026) framing the relevant individual-difference signal in aphantasia and working memory as one of **strategy/cognitive-profile clustering** (unsupervised, unsupervised discovery of profiles across verbal/spatial/visual strategy use) rather than either raw performance or continuous compositional preference.

**Important correction, made directly by the author after this was first raised:** this was not independent field precedent Claude was introducing — the clustering-profile paper is the author's own published work, and the non-visual-strategy line of research it built on (Reeder et al.) has been a direct inspiration for the author's thinking for some time. Claude had presented it as "here's a thing you might not know about" when the correct framing was "this is your own prior methodology, cited back at you." Worth remembering going forward: when searches surface the author's own prior work, it should be flagged as such immediately, not treated as independent validation.

**What this means for scope, decided directly:** the compositional approach and the clustering approach are both worth pursuing, and are **not redundant with each other** despite both addressing "how does a person distribute representational effort across features" — see §5.

## 5. Compositional vs. clustering: different purposes, not competing methods

Clarified directly by the author, this is the operative distinction going forward:

- **Compositional analysis** builds a per-participant preference profile and uses it for **hypothesis-testing, group-comparison-style analysis** — e.g., do compositions differ between VVIQ groups, or regress composition against continuous VVIQ. Broad, exploratory hypothesis, but still confirmatory in structure: it uses researcher-defined groups (VVIQ-based) as the comparison of interest.
- **Clustering** deliberately **ignores** the researcher-defined groups and instead uses the most relevant subjective and objective variables to find similarity structure among participants **unsupervised** — fully hypothesis-_generating_, not hypothesis-testing. The goal is to let cognitive profiles emerge from the data rather than assume VVIQ group is the right lens for individual differences in representation.

**Conclusion:** no redundancy, these are doing genuinely different epistemic work, both worth keeping in scope. Their inputs likely overlap (both plausibly draw on the same standardised per-feature scores, see `02-score-computation.md`), but the compositional strand is confirmatory- exploratory against known groups, the clustering strand is fully exploratory and group-agnostic.

## 5.5 Amendment 2026-08-20: a third quantity the three-strand framing does not account for

The three strands above divide the analytical space by *method* —
performance, compositional, clustering — while assuming a single
underlying observable: how accurately a participant recalled each feature.
Implementation revealed that the score columns actually confound two
quantities (`04-response-propensity.md` §1): **reporting propensity**, the
probability of responding at all, and **conditional accuracy**, how close
the response was given that one was made. The score is roughly their
product.

This is not a fourth method. It is a second *outcome*, and each of the
three strands must now say which one it is analysing.

**Why it belongs in this doc rather than only in a technical one.** §1
argues, from the task's own documentation, that WM-FTT is a
resource-allocation task by design and that this gives the compositional
framing genuine construct-validity grounding rather than mere stylistic
preference. If that argument holds, then **declining to respond is the
most direct expression of allocation the task can produce** — an
unambiguous statement that the participant allocated nothing to that
feature on that trial. The compositional strand currently infers
allocation *indirectly*, from proportions of accuracy scores, while the
scoring pipeline folds the direct expression of it into those same scores
as failure. §1's own logic points at the propensity measure more
straightforwardly than at the composition.

**Why it bears on the framing disagreement — with an important limit.** Once
the two quantities are separated, the accuracy-versus-VVIQ correlations
fall to +0.19 (orientation) and +0.10 (colour) from +0.39 and +0.40. So
the performance framing is weaker than the raw score columns suggest, and
that much is robust.

**But the propensity side is not established.** The pooled
propensity-versus-VVIQ correlations of roughly −0.29 to −0.30 dissolve
when stratified by version: within v1 (n = 88, the only balanced version)
nothing is significant and only colour is marginal. Most of the pooled
association comes from v3 being both deliberately aphantasia-heavy and the
version with the highest non-response (`04` §3.1). Reporting propensity is
therefore **not** a third substantive answer to §3's disagreement on
current evidence.

What it *is*, and this is enough to warrant a section here: a demonstration
that the three strands were built on an observable that silently combines
two quantities, and that the apparent strength of the performance framing
depends on which of them is being measured. §3's "complementary, not
either/or" conclusion still covers two objects; it now has to say which
quantity each one analyses.

**Status:** exploratory, post hoc, and confounded with version. Not a
headline claim, not omissible either — it changes the methods, and it
motivates the task revision described in `04` §6.

## 6. Where the compositional framing is genuinely weaker, stated plainly rather than glossed over

Raised directly during discussion, not resolved away:

- **Compositional/proportional scores discard overall performance level.** Two participants with identical relative-allocation profiles but very different absolute totals (one near ceiling, one near floor) look identical in a ternary plot. If overall ability varies by VVIQ group too, proportions alone would discard a real group difference. Not fatal, but means proportions alone are insufficient — total/overall performance needs to be retained as a covariate or separate outcome alongside the compositional analysis, not discarded in favour of it.
- **Communicability cost.** Compositional framing is harder to explain to a non-specialist audience (poster viewers, non-specialist thesis committee members) than "aphantasics recalled fewer words." Not a reason to abandon it, but a real cost given the 3-week poster deadline specifically — ternary plots are visually compelling but need a beat of explanation a bar chart doesn't.
- **Self-report vs. behavioural allocation are not the same construct, and shouldn't be treated as interchangeable.** The already-documented v1 finding (self-reported strategy favoured colour; engaged-participant performance data favoured word) is direct evidence these can dissociate. This isn't evidence against the compositional approach, but it means "preference" language needs to be used carefully — behaviourally- inferred allocation (the proportions) and self-reported strategy (separate questionnaire data) are related but distinct constructs, and conflating them in the writeup would be a real weakness. (This concern became one direct motivation for `06-task-validity.md` §2.3's convergent-validity check.)

## 7. Downstream consequences of this discussion, for the record

Several later planning decisions trace directly back to positions established here:

- **`02-score-computation.md`** exists because both the compositional and clustering strands need genuinely comparable per-feature scores before either can be built — a direct consequence of §2's "the compositional commitment requires doing the transform properly" point.
- **`06-task-validity.md`** exists partly because §6's self-report-vs- behaviour distinction raised a concrete, checkable question (do the two measures converge or diverge, and is that itself informative) rather than an assumption to leave unexamined.
- **`03-parity-engagement.md` / `05-version-scope.md`** are not direct outputs of the philosophy discussion, but the "solve the mutual- dependency flaw properly, don't just default to independence" standard from §3 applies to those analyses too, once reached.

## 8. Summary of settled positions

| Question                                                           | Position                                                                                                       | Status                                |
| ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------- | ------------------------------------- |
| Is the compositional framing merely a stylistic preference?        | No — task design (points-per-feature, explicit trade-off framing) gives it real construct-validity grounding   | Settled                               |
| Compositional vs. performance — either/or?                         | No — complementary, both needed; performance as baseline, compositional as theoretical contribution            | Settled                               |
| Does adopting compositional framing carry technical obligations?   | Yes — log-ratio-style transforms needed for valid inference, not naive proportions                             | Settled in principle, design deferred |
| Compositional vs. clustering — redundant?                          | No — confirmatory/group-comparison vs. fully unsupervised/hypothesis-generating                                | Settled                               |
| Clustering literature precedent                                    | the author's own prior published work + direct inspiration (Reeder et al.), not independent field validation         | Corrected, settled                    |
| Does the performance framing need fixing too?                      | Yes — must respect feature non-independence (multivariate/multilevel), not three independent univariate models | Settled                               |
| Self-report strategy vs. behavioural allocation — same construct?  | Not necessarily — real dissociation already observed in v1 data; treat as related but distinct                 | Settled                               |
| Overall performance level discarded by pure compositional approach | Real weakness — needs retention as covariate/separate outcome                                                  | Settled                               |
| Is "accuracy" the only observable the three strands share?          | No — the score confounds reporting propensity with conditional accuracy; each strand must state which it analyses (§5.5) | Added 2026-08-20                      |

## 9. Open items carried forward

- Whether §3's "complementary, not either/or" position extends cleanly to three objects rather than two, now that reporting propensity is separated out (§5.5) — and how that is presented, given the performance framing weakens once the two quantities are separated.
- Exact log-ratio transform choice for the compositional pipeline — not yet designed (belongs in a future `0X-compositional-analysis.md`).
- How to operationalise clustering for WM-FTT's specific data shape — explicitly flagged by the author as needing real help, not yet designed (belongs in a future `0X-clustering-analysis.md`).
- How much of the legacy plotting/exploratory code is worth reviving for either strand — deferred, not addressed in this discussion.
- Exact structure of the multivariate/multilevel performance model (§3, §7) — belongs in the not-yet-written performance-modelling doc.

## 10. Next steps (not this doc)

- Write the performance-modelling doc, applying §3's "respect the dependency" standard and `05-version-scope.md`'s decision procedure.
- Write the compositional-analysis doc, addressing §2's transform obligation and §6's overall-level-retention point directly in the design.
- Write the clustering-analysis doc — flagged by the author as the one requiring the most collaborative design work, given past clustering work was solitary and its principledness is something the author wants to be fully convinced of, not just reassured about.
