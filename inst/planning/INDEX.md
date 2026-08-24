# WM-FTT analysis pipeline: index and handoff for implementation sessions

*This is the entry point to `inst/planning/`. Read this file first.*

**What this document is.** Ten planning docs (`00` through `09`) define
the full WM-FTT analysis plan: philosophy, scoring, pooling strategy,
validity checks, parity engagement, performance modelling, compositional
analysis, clustering, response propensity, and the floor-group model. They were produced over an extended planning
conversation between the author Delem and Claude, with heavy use of literature
search, direct review of the author's own prior published/pre-print work, and
sustained pushback rather than agreement-by-default. This document is
the map: what each doc contains, what depends on what, what's still
genuinely open, and a starting prompt for a session picking up any one
piece.

**Updated 2026-08-20, after the score-computation implementation
session.** That session implemented `01`, ran all of `03`, and amended
every other doc in the set. Two docs are new (`08`, `09`). Several
"open questions" listed below closed and different ones opened. The
single most consequential change for anyone picking up a task:
**v1 (N = 88) is now the primary analysis sample and v2/v3 do not enter
the inferential analyses** (`02` §3.5). **Read this document first, then read only the specific planning
doc(s) relevant to your assigned task** — not all eight, unless your task
genuinely spans multiple strands.

**Two deadlines govern everything downstream of these docs**: a
conference poster (~3 weeks from when planning began) and a thesis
chapter handoff (~4 weeks). Poster scope and thesis chapter scope are
**not yet planned** — no doc in this set addresses them directly; see
§5. If your assigned task is poster- or chapter-specific, that scoping
needs to happen before or alongside your work, not be assumed settled.

---

## 1. Dependency graph

```
00-analytical-philosophy.md  (foundational — read for context on any task)
        │
        ▼
01-score-computation.md  (scoring pipeline — most other docs depend on this)
        │
        ├──────────────┬──────────────┬──────────────┐
        ▼              ▼              ▼              ▼
02-pooling-strategy  03-validity-   04-parity-     05-performance-
   .md (governs      checks.md     engagement.md   modelling.md
   version handling                                     │
   in all modelling                                     │
   docs — read                                          │
   before any doc                                       │
   that touches                                          │
   version/pooling)                                      │
        │                                                │
        ├────────────────────────────┬───────────────────┘
        ▼                            ▼
06-compositional-analysis.md   07-clustering-analysis.md
   (also depends on 04              (also depends on 00 §5-6,
   for parity-as-covariate)         03 for split-half logic,
                                     04/02 for version handling)

Added 2026-08-20, both cross-cutting rather than strand-specific:

08-response-propensity.md   defines the quantity that 01's scoring
                            convention folds into the score column.
                            Constrains 03, 05, 06 and 07: every one of
                            them must now say whether it analyses
                            recall accuracy or willingness to respond.

09-floor-group.md           how VVIQ enters any model, given that its
                            distribution is bimodal with 23% of v1 at
                            the scale floor. Read alongside 02 and 04,
                            which are the same kind of doc: one
                            variable, every model.
```

**Practical reading rule:** `00` is short and foundational enough to skim
regardless of task — it establishes the performance/compositional/
clustering three-strand structure everything else assumes. `01` is a hard
dependency for `05`, `06`, and `07` (all three need its scoring output).
`02` isn't a task in itself — it's a decision _procedure_ that `04`, `05`,
`06`, and `07` each apply to their own version-handling question; read it
whenever a task touches version/pooling, don't treat it as "someone
else's doc." As of 2026-08-20 that procedure has been **run**, and
resolves to v1-only (`02` §3.5), so most of what it governed is now
settled rather than pending.

`08` and `09` are the same shape as `02`: not tasks, but decisions that
every modelling doc has to apply. `08` in particular is not optional
reading for `05`, `06` or `07` — the score columns confound two
quantities, and a model that doesn't say which one it means is not
well-defined.

## 2. What each doc contains, one paragraph each

- **`00-analytical-philosophy.md`** — Resolves the core framing disagreement
  (performance framing vs. compositional/preference framing) as
  complementary, not competing; establishes performance/compositional/
  clustering as three distinct strands with different epistemic jobs;
  documents the self-report-vs-behaviour distinction that recurs
  throughout the other docs. Read this before touching any of the other
  seven — it's the shared vocabulary.
- **`01-score-computation.md`** — **Implemented 2026-08-20**; the scores
  are in `all_data` as `score_word`/`score_angle`/`score_color`, their
  `_z` counterparts, and `responded_*` flags, produced by
  `compute_scores()`. Word scoring via Gonthier (2022) edit-distance,
  colour via cosine on a 360-degree period, orientation via cosine on a
  **180-degree** period (a rectangle's tilt is symmetric under
  180-degree rotation; §2). Three things a reader of the old version
  would get wrong: the front end's own word metric is **not** Levenshtein
  but a defective implementation of it (§1.5), the small-N
  standardisation caution is moot now that v1 alone is analysed, and
  non-responses are scored 0 and flagged rather than dropped (§2.5.2).
  `bmm` remains parked, but §5's stated reason is corrected: it composes
  with a hurdle rather than being unrelated.
- **`02-pooling-strategy.md`** — Not a single pool/don't-pool answer — a
  four-step decision procedure applied per-analysis. Key point: "version
  as structural feature, not nuisance covariate" (the wiki's own stated
  position) requires version × effect _interactions_ where feasible, not
  just a version main effect — a distinction worth re-reading carefully,
  it's easy to think you're honouring this by adding `version` as a
  covariate when you're not.
- **`03-validity-checks.md`** — **All five checks run 2026-08-20**;
  results are inline in each section. Headline outcomes: split-half
  reliability 0.82 (orientation), 0.83 (colour) and **0.45 (word)**, so
  word does not support individual-differences claims; the compositional
  profile is stable (0.77 / 0.72), so `06` clears its gate; self-reported
  strategy predicts essentially nothing about behavioural allocation; the
  VVIQ relationship loads on orientation rather than colour, which is a
  discriminant failure; and the OSIVQ multitrait-multimethod pattern
  (§2.7) **fails**, with the diagonal no larger than the off-diagonal.
  Also contains a data-quality finding worth knowing before touching
  questionnaire items: v1/v2 store four reverse-keyed OSIVQ items
  unreversed while v3 stores them reversed (§2.7).
- **`04-parity-engagement.md`** — Continuous parity accuracy as the
  default covariate; binary engaged/disengaged split kept for descriptive
  composition purposes only, threshold chosen from the data distribution
  (not hand-picked); the engaged/disengaged moderation effect (documented
  in v1 data — different imagery-group effects between subgroups) is
  flagged as a real candidate finding, not just a nuisance to control.
- **`05-performance-modelling.md`** — A→C narrative arc: fit the naive
  three-independent-models version first (Option A), state explicitly why
  it's wrong, then fit the correct long-format multilevel model with
  correlated random slopes (Option C). Option B (`mvbind`/`rescor`) is
  documented and deliberately rejected — keep that reasoning, don't
  silently reintroduce it. Option D (separate total-performance model)
  fills a gap the compositional strand deliberately doesn't address.
  **Response family resolved 2026-08-20 and not as anticipated**: the
  zeros and the ones come from different generative processes, so a
  hurdle rather than a zero-one-inflated Beta (§3.1). A new problem opened
  in its place: no single family fits all three features, because word is
  90% at ceiling while orientation and colour are clean on (0, 1) given a
  response (§3.3). That needs deciding before Option C can be fitted.
- **`06-compositional-analysis.md`** — ILR (isometric log-ratio) transform
  is required for valid inference on the three-feature composition, not
  naive proportions. **The sequential binary partition (SBP) choice — which
  feature gets contrasted against the other two first — is not decided**
  and needs the author's direct input; three candidate partitions are laid out
  with their theoretical implications. `multilevelcoda` (a `brms`-native
  package) is the recommended implementation path. **Two changes
  2026-08-20**: §7's input choice is **reversed** to raw scores, because
  standardised scores are roughly half negative and no log-ratio
  transform accepts negative parts; and §2's recommended partition turns
  out to be the low-variance one (39% of ILR variance against 83% for an
  orientation-first partition), recorded as a limitation and explicitly
  **not** as grounds to switch.
- **`07-clustering-analysis.md`** — The most heavily developed doc, and
  explicitly framed (§0) as a **third attempt at a consistent held-out
  validation logic** across three of the author's studies, not a fresh
  exploratory exercise — read §0 before anything else in this doc, it
  changes what a null result would mean. Clustering inputs are 9 raw
  subjective variables (VVIQ, OSIVQ ×3, NIEQ ×5); behavioural/
  compositional scores and self-report strategy data are explicitly
  **excluded from inputs**, held out as validation/interpretation
  variables instead — this exclusion is the single most consequential
  methodological choice in the doc. Full a priori analysis of `diceR`'s
  algorithm/consensus-function/resampling/k-selection free variables is
  included (§6). This is thesis-only, not poster material (per the author's
  own decision during planning). **Amended 2026-08-20** (§4.0): the
  held-out behavioural validation must use responded-only scores, since
  the raw score columns partly encode who declined to answer. Note also
  that the sample is now v1 only, so consensus clustering runs at N = 88
  rather than 118, which makes §7's variable-reduction question more
  load-bearing than when it was written.

- **`08-response-propensity.md`** — **New 2026-08-20.** The score column
  is approximately the product of two quantities: whether a participant
  reported a feature at all, and how accurately they did so given that
  they tried. Between 8% and 14% of v1 trials are non-responses, scored 0
  by `01` §2.5.2, and including them roughly doubles the apparent
  correlation between score and VVIQ. Every modelling doc must now state
  which quantity it analyses. Read §3.1 before citing any effect size
  from this doc: its first draft reported a sample-wide
  propensity-by-imagery association that **dissolves within version**, and
  the correction is kept visible rather than quietly revised.
- **`09-floor-group.md`** — **New 2026-08-20.** VVIQ's distribution in v1
  is close to bimodal, with 23% at the scale floor. Carries the
  floor-group model from `aphantasiaEmotions` (`vviq + complete_aphant`)
  and reports that adding the floor term collapses the continuous VVIQ
  slope to zero. Cross-cutting like `02` and `04`: `05`, `06` and `08`
  each need to decide whether VVIQ enters continuously or with the floor
  term. Exploratory, and the doc says why.

## 3. Cross-doc open questions — check here before re-deciding these elsewhere

These recur across multiple docs. If your task touches one, **check
whether it's already been resolved in the owning doc before treating it
as open** — several of these were genuinely unresolved for a while during
planning and got settled later; don't rediscover and re-litigate.

- ~~**v2 (N=9) inclusion**~~ **RESOLVED 2026-08-20** (`02` §3.5): v1
  (N = 88) is the primary analysis sample; v2 and v3 are described but do
  not enter the inferential analyses. v3 keeps one job it uniquely
  enables, estimating the recall-order effect that v1's fixed order
  confounds. This resolution is the most consequential change in the set:
  version layers come out of `05` §6 and `06` §6, and `07` runs at
  N = 88.
- ~~**NIEQ reliability checks**~~ **RUN 2026-08-21**, and they found
  something `07` needs. Two-item subscale reliabilities (Spearman-Brown on
  the frequently/generally pair): mental imagery 0.91, inner voice 0.87,
  emotions 0.80, **unsymbolised thinking 0.73**, **sensory focus 0.49**.
  Sensory focus falls well below the 0.70 floor and should not carry equal
  weight as a clustering input. Unsymbolised thinking, the dimension with
  the clearest theoretical stake, is adequate. Reported on the
  Psychometrics page.
- ~~**Response family for Option C**~~ **RESOLVED 2026-08-20** (`05`
  §3.1): a hurdle, not a zero-one-inflated Beta. The version layer in
  `05` §6 is moot under v1-only. **A new question opened in its place**:
  no single family fits all three features (`05` §3.3), and word's
  ceiling may need handling at the measurement level rather than the model
  level (`05` §3.4). Needs deciding before Option C is fitted.
- **Which quantity each model analyses** — recall accuracy, or willingness
  to respond. Owned by `08-response-propensity.md` §1, and it applies to
  `03`, `05`, `06` and `07` alike. There is no default; a model that does
  not state this is under-specified.
- **Whether VVIQ enters models continuously or with a floor term** —
  owned by `09-floor-group.md` §4. **`05` adopted the same form on
  2026-08-21** (`05` §11.5), so this is now settled everywhere it
  applies. On current data the continuous term
  does no work once the floor term is present, except for colour
  propensity where it survives. **`06` resolved this for its own strand
  on 2026-08-21** (`06` §13.6): floor-group additive as the pre-declared
  primary, with a LOO comparison of the alternatives reported whatever it
  shows. `05` still has to decide for itself.
- **Word as an individual-differences measure** — `03` §2.1 gives its
  split-half reliability as 0.45, and the precision criterion asks for 93
  trials of the 63 that exist. `05` §3.4 treats this as settled (report
  with a caveat, exclude from individual-differences inference), but
  `06`'s first ILR coordinate still rests partly on word, so the tension
  is live rather than resolved.
- ~~**SBP/partition choice for compositional analysis**~~ **RESOLVED
  2026-08-21** (`06` §13.5): word vs (colour + orientation), on
  substantive grounds. Two things closed it. Any two-coordinate ILR basis
  is a rotation of the same geometry, so the omnibus test and total
  variance do not depend on the choice; and the variance asymmetry that
  made the choice look expensive was computed on a superseded sample and
  largely dissolves on the analysis sample (`06` §13.2).
- ~~**Legacy plotting code disposition**~~ **RESOLVED 2026-08-21.** None
  of it is in the package, only in the waiting-room archive, and
  `plot_wm_composition()` drives `coda.plot` by reaching into
  `p$layers[[i]]$geom$default_aes`, which breaks on ggplot2 updates. The
  package now has its own plotting layer in `R/ggplot_tools.R` and
  `R/plot_composition.R`, ported from `aphantasiaEmotions` so both
  packages share one visual identity. Figures in `inst/scripts` are vector
  PDFs at printed size; figures for the pkgdown site use
  `theme_pdf(base_size = 16)`.
- **Poster and thesis chapter scoping** — see §5, not resolved anywhere.

## 4. House rules — apply regardless of which doc you're implementing

These are established, consistent practice with the author across this entire
planning process, not stated once and possibly forgotten:

- **Numbering: `inst/scripts/NN-*.R` implements `inst/planning/NN-*.md`.**
  Adopted 2026-08-21, when the two sets had drifted far enough that the
  compositional script was numbered 05 against a plan numbered 06. Where
  one plan needs more than one script, use letter suffixes (`03a`, `03b`).
  Where a plan needs no script, its number is simply unused on the script
  side. In conversation, say **plan-NN** and **script-NN** rather than a
  bare number.

- **Verify against real data/files, never assert from memory.** Several
  points in this planning process were corrected specifically because an
  assertion was made without checking the actual file/data first (e.g. an
  early misattribution of a paper's authorship, an early misreading of
  which front-end file's questions belonged to which study). Read the
  actual file before proposing anything.
- **Targeted edits over full-file regeneration**, for quick fixes.
  **Confirm the plan before building anything complex** (multi-file work,
  extended analysis code) — don't just start generating.
- **Push back, flag uncertainty, don't validate by default.** This has been
  asked for explicitly and repeatedly. Where a design choice has
  real trade-offs, say so, don't pick one silently and present it as
  obviously correct.
- **Decisions get documented with their reasoning, not just their
  outcome.** Every planning doc in this set follows this pattern
  deliberately — continue it in implementation.
- **Researcher-degrees-of-freedom discipline**: this recurs constantly
  across the docs (parity threshold, algorithm selection in `07`,
  variable-reduction ordering in `07` §7). The general rule: decisions
  that shape what an analysis can show must be locked in **before** the
  result is seen, not adjusted afterward toward a cleaner-looking answer.
  If you find yourself wanting to try several versions of something and
  pick the one that "looks right," stop and flag it instead.
- **Once-closed scope questions stay closed** — e.g. the reasoning study's
  post-submission participants (explicitly out of scope), the OSIVQ
  Gazzo/max discrete classification rule (explicitly dropped, replaced by
  continuous subscale use in clustering). Don't re-raise these.
- **Language**: these docs and all code comments are in English.
- **Style**: NO em-dashes, strictly forbidden.
- **Output real files**, don't hold substantial content only in the
  conversation.

## 5. What's genuinely not planned yet — don't assume these are someone else's problem

- ~~**Poster and thesis chapter scope**~~ **DECIDED 2026-08-21.**
  **Thesis chapter: everything planned**, all ten docs. **Poster:
  everything except clustering** (`07`), with the most interesting
  subset selected by hand rather than by rule. Both need strong figures,
  designed alongside the analyses rather than retrofitted, so any session
  producing a result should produce a publishable figure of it at the
  same time (`base_size = 16`, consistent with the existing vignettes).
  What remains undecided is only _which_ results make the poster, and
  that is a judgement call to be made once `05`, `06` and `08` have run.
  Note `02` §5's point still stands: poster-scope pooling claims need a
  simpler, stated-assumption presentation than the chapter's.
- **Legacy plotting code** — see §3.
- **NLP/embeddings treatment of free-text "other" strategy responses**
  (`07` §4.1) — explicitly flagged as legitimate future work, not
  in scope for the current deadlines.
- **Mixture-model (`bmm`) precision scoring** (`01` §5) — parked as a
  future/parallel track for colour/orientation scoring, not adopted. Its
  relationship to the hurdle in `05` §3.2 is now documented: the two
  compose rather than compete.
- **A revised WM-FTT (a v4).** Added 2026-08-20 and arguably the most
  substantive output of the implementation session. Three concrete
  changes are specified across `01` §2 and `08` §6: make word harder so
  it enters the trade-off and discriminates (it is currently 90% at
  ceiling, reliability 0.45, and the task achieves a two-way trade-off
  rather than the intended three-way one); add an explicit "I don't know"
  control distinct from an untouched widget, plus a confidence rating, so
  abstention can be told apart from a default; and vary the points per
  feature, since strategic abstention should respond to incentive and
  representational absence should not. **No doc owns this.** If a v4 is
  ever built, these are the requirements.
- ~~**Whether `vviq_items` and `nieq_items` share the OSIVQ
  reverse-coding inconsistency**~~ **RESOLVED 2026-08-21.** Neither has
  reverse-keyed items, so the problem is confined to OSIVQ. VVIQ alpha is
  0.978 with no negative item-total correlations. NIEQ's five two-item
  subscales were checked for pair consistency instead, which is the right
  statistic for it: four are adequate, **sensory focus is not** at 0.49.
  All reported on the Psychometrics page of the pkgdown site.

## 6. Starting prompts, per likely implementation task

Use or adapt these as the opening message to a fresh Claude session
assigned to one piece of this pipeline. Each assumes the relevant
planning doc(s) and the WM-FTT package/data are attached.

**Scoring pipeline (`01`) and validity checks (`03`): DONE.** Both were
implemented on 2026-08-20. Do not re-run these as fresh tasks; read the
docs, which carry their results inline, and the scripts listed in §6.5.

**Performance modelling (`05`):**

> Implement the performance model in `05-performance-modelling.md`,
> following the A-to-C narrative arc. Two things must be settled before
> any model is fitted, and both are open: the per-feature response-family
> problem in §3.3 (word is 90% at ceiling, orientation and colour are
> clean on the open interval given a response, and no single family fits
> all three), and whether VVIQ enters continuously or with the floor term
> from `09-floor-group.md`. Read `08-response-propensity.md` §1 first and
> state explicitly whether the model analyses recall accuracy or
> willingness to respond. Sample is v1 only (`02` §3.5).

**Compositional analysis (`06`): DONE**, 2026-08-21, except for the
Bayesian fits themselves. Read `06` §13 rather than re-deriving anything;
the script is `inst/scripts/06-compositional-analysis.R`. What remains is
running it, starting with `TEST_RUN <- TRUE`.

**Response propensity (`08`):**

> Implement the propensity model in `08-response-propensity.md` §5.
> Read §3.1 first: the association this doc was written around does not
> survive stratification by version, and the doc's job is now largely
> methodological. `03` §2.5 has already fitted a quasi-binomial and found
> colour suggestive, orientation and word null; a Bayesian version with
> proper participant random effects is the natural next step, and note
> that the frequentist mixed model was not identifiable at N = 86.

**Parity engagement (`04`):**

> Implement the parity-engagement analysis in `04-parity-engagement.md`:
> start with the distribution check (§7 step 1) before any threshold
> decision. Read `02-pooling-strategy.md` alongside this, since the
> within-version-vs-pooled question for "engaged" is deferred there.

**Clustering (`07`):**

> Read `07-clustering-analysis.md` §0 first, in full, before anything
> else — it establishes that this analysis is a third attempt at a
> specific held-out-validation logic across the author's own prior work, which
> changes how a null result should be framed. Clustering inputs are the
> 9 raw subjective variables only (§4) — behavioural/compositional scores
> and self-report strategy are validation-only, never clustering inputs
> — this is the single most important constraint in the doc. Before
> running anything, compute the 9×9 correlation/partial-correlation
> matrix (§7) to inform the variable-reduction decision, and commit to a
> reduction choice before looking at any clustering output. This is
> thesis-only work, not poster material.

## 6.5 What the implementation sessions actually produced

For anyone reconstructing what changed on 2026-08-20:

| Artifact                                                                                           | Where                                                       |
| -------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| `compute_scores()`, `score_word()`, `score_angular()`, `damerau_levenshtein()`, `normalise_word()` | `R/compute_scores.R`, with tests in `tests/testthat/`       |
| Score distributions, orientation-period sensitivity, standardisation stability                     | `inst/scripts/01-score-distributions.R`                     |
| Split-half reliability, compositional stability, self-report convergence                           | `inst/scripts/03a-reliability.R`                             |
| VVIQ sensitivity, response propensity, OSIVQ multitrait-multimethod                                | `inst/scripts/03b-validity-checks.R`                         |
| Floor-group model                                                                                  | `inst/scripts/09-floor-group.R`                             |
| Public-facing narrative of the whole scoring pipeline                                              | `vignettes/articles/scoring.Rmd`                            |
| Questionnaire reliabilities, the OSIVQ reverse-coding trap, NIEQ pair consistency                  | `vignettes/articles/psychometrics.Rmd`                      |
| Parity disengagement and recall non-response, and the evidence they are separate behaviours        | `vignettes/articles/engagement.Rmd`                         |
| Column documentation, including the display-only block                                             | `vignettes/articles/codebook.Rmd`, `R/data.R`, OSF codebook |
| Record of why the non-response finding reached every doc                                           | `non-response-propagation-memo.md`                          |

Two errors made and corrected during that session are worth knowing
about, because both are easy to repeat. A pooled correlation was
reported as a finding before being stratified by version, and dissolved
when it was (`08` §3.1). And a pattern was read into seven participants
that a base-rate check showed was noise. Both were caught by looking
within strata rather than at the aggregate; that is the habit to carry
forward.

And what changed on 2026-08-21:

| Artifact | Where |
| --- | --- |
| `compose_features()`, `ilr_coords()`, `engaged_ids()`, `wm_thresholds()` | `R/composition.R` |
| `theme_pdf()`, `save_ggplot()`, the group/feature scales, ported from `aphantasiaEmotions` | `R/ggplot_tools.R` |
| `plot_composition_ternary()`, `plot_composition_biplot()` | `R/plot_composition.R` |
| `fit_brms_model()`, `report_rope()` | `R/modelling_tools.R` |
| Sample construction, composition descriptives, the SBP table, five candidate models, the trial-level multilevel model | `inst/scripts/06-compositional-analysis.R` |
| Figures moved from screen-size PNG to vector PDF at printed size | `inst/scripts/01`, `03a`, `03b`, figures in `inst/scripts/figures/` |
| These planning docs, moved into the package | `inst/planning/` |

Three doc-versus-data mismatches from that session are worth carrying
forward, because all three have the same shape. `06` §2's variance table,
`06` §8.5's partial correlations, and by extension the "the task achieved
a two-way trade-off" reading were all computed on a pooled, unfiltered
sample that `02` §3.5 had already retired, and all three change or
dissolve on the analysis sample (`06` §13.2, §13.3). Six low-engagement
participants carried roughly three quarters of the compositional
variance. The habit from 2026-08-20, look within strata rather than at
the aggregate, generalises: **check which sample a recorded number was
computed on before building on it.**

## 7. If something in these docs seems wrong or outdated

These docs reflect a planning conversation, not a static specification —
if real data reveals something a doc assumed was wrong (e.g. a column
doesn't exist under the assumed name, a distribution looks nothing like
expected), say so directly and flag it as a doc-vs-reality mismatch
rather than quietly working around it. Several corrections happened
during the original planning process itself (a paper misattribution, a
misread of shared front-end code, an initial mischaracterisation of a
prior study's design) — each was corrected explicitly and the reasoning
preserved in the relevant doc, not silently fixed. Continue that pattern.

The 2026-08-20 implementation session is the clearest example of why.
Six doc-versus-reality mismatches turned up in the first hour of looking
at real data, one of which (`01` §1.5) invalidated a metric the front end
had been computing for three versions of the task. None of them were
findable by reading the docs; all of them were findable by running code
against the data. If a doc and the data disagree, the data is right and
the doc gets amended with the evidence attached.
