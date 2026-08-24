# WM-FTT: clustering

**Status:** amended 2026-08-20 — §4.0 added, constraining which behavioural measures the held-out validation may use. Framing, scientific lineage (§0), and major risks identified;
prior published/pre-print methodology reviewed directly (source code
read, not inferred — `aphantasiaCognitiveClustering` and
`aphantasiaReasoningViie` R packages); algorithm/consensus-function/
resampling/k-selection choices for `diceR` analysed in full (§6);
clustering-input variable set settled at 9 raw variables with
behavioural/compositional/self-report-strategy data held out as
validation-only (§4); variable-reduction decision procedure settled,
outcome deferred to real data (§7). Remaining open items are narrower
and checkable (NIEQ reliability checks, exact validation-pipeline
implementation) rather than open design questions — see §10. This is the
doc explicitly flagged as needing the most collaborative design work
(per `00-framing.md` §10) — the standard here is
"genuinely convinced," not "technically defensible on paper," and the
doc is written to support that bar, including surfacing reasons to *not*
trust a clean-looking result.

**Context:** the fully hypothesis-generating strand of the three-strand
plan (`00-framing.md` §5) — deliberately ignores
researcher-defined groups (VVIQ category) and instead looks for latent
structure across the most relevant subjective and objective variables,
letting cognitive profiles emerge rather than assuming VVIQ group is the
right lens. Directly continuous with the author's own prior published work
(clustering paper) and Reeder et al.'s non-visual-strategy line of
research, both already cited as direct inspiration (per
`00-framing.md` §4).

---

## 0. The actual scientific lineage this analysis belongs to — stated directly, for the record

This context was given directly by the author during planning and is recorded
here because it changes what WM-FTT's clustering strand is actually for,
not just how it should be run. First time this reasoning has been written
down anywhere. **Corrected once already during this same planning
session** — the first version of this section characterised study 1's
design as circular; the author corrected this directly, and the distinction
matters enough to preserve both the correction and the reasoning behind
it, not just the final version.

**What study 1 actually did, precisely — corrected from an earlier draft
of this section**: study 1 clustered on both subjective (VVIQ, OSIVQ,
PsiQ, etc.) and behavioural/task variables together for the *clustering
step itself* (§6.1's `scale_reduce_vars()` review confirms the 7 reduced
variables mix questionnaire- and task-performance-derived scores) — but
**WCST and reading comprehension scores were deliberately held out of
the clustering variables specifically to serve as an independent,
non-circular external check**, testing whether the resulting clusters
showed real differences on those held-out measures. **That check found
no significant differences — a null result.** So study 1's design, at
the level of what was actually tested, was not circular: it ran a
genuine held-out validation attempt, in the same spirit as what study 2
and this WM-FTT analysis are doing, and that attempt simply didn't find
an effect at the time.

**Where the problem was**: not the design, but the **published framing**.
The manuscript text used language like "predictive" and "explanatory",
which claims more than a descriptive clustering result plus a null
held-out validation supports. The distinction matters here because it
is easy to repeat: the pressure on any clustering write-up is toward
language that makes an exploratory structure sound confirmed, and the
failure mode is rhetorical rather than statistical. **Study 1's honest
epistemic status: genuine hypothesis-generation via clustering, plus a
real but null attempt at held-out validation** — not confirmed, not
disconfirmed in a strong sense (a null result on two specific held-out
measures doesn't rule out the broader hypothesis), simply not yet
supported by that particular test.

**Study 2 as the point where a held-out validation attempt succeeded**:
study 2 clustered on **subjective variables only** (OSIVQ subscales,
§6.1), then checked whether the resulting profile structure showed real
behavioural differences in a **separate, unrelated task** (the
reasoning/VIIE paradigm) — the same held-out logic study 1 already
attempted, run again, and this time the check succeeded: the same
verbaliser/visualiser/spatialiser structure and its correspondence to
VVIQ group replicated, and cluster membership related to reasoning-task
behaviour. This is the first positive evidence for the "subjective
cognitive profiles relate to behaviour" hypothesis in this lineage — not
because study 1's design was flawed and study 2 fixed it, but because
study 2 is a second, independent attempt at the same honest test, and
this one happened to find something.

**What this makes WM-FTT's clustering strand**: a **third attempt at the
same held-out validation logic**, not a correction of a prior flaw —
continuing a methodologically consistent lineage (cluster on subjective
variables, hold out behavioural/task measures, check for real
differences) across three independent samples, now with two genuine
extensions beyond study 2: (1) NIEQ (inner experience) as an input
variable set neither prior study used, and (2) a different behavioural
domain (working memory feature-allocation strategy, not reasoning) as
the held-out validation target. **The decision in §4/§4.1 to hold
behavioural/compositional WM-FTT scores and self-report strategy out of
the clustering inputs is what keeps this attempt honestly comparable to
studies 1 and 2** — a third instance of the same clean test design, whichever
way the held-out check comes out. A null result here would not be a
failure of this analysis; it would be exactly the kind of honest,
reportable outcome study 1 already produced once, and one this thesis is
explicitly positioned to describe without the framing pressure that
affected study 1's published text.

---

## 1. The central risk, stated first because it should govern everything else

**Note added after §6:** this section's caution was written from general
literature alone, before the author's own prior clustering work had been
reviewed directly. §6.1–6.2 found that the author's own two prior studies, at a
sample size comparable to WM-FTT's, produced a cluster structure that
replicated across two independent samples and two different methods —
real, specific evidence that meaningfully offsets the general-literature
risk below for this particular case. The general risk is still real and
still worth designing against (that's what §6.4–6.6's a priori method
choices do), but it should be read alongside §6's positive track record,
not as an unanswered alarm.

Literature search surfaced a specific, well-documented failure mode that
maps precisely onto the doc's central worry, whether a clustering result
is real or merely produced:
unsupervised clustering in cognitive/psychological data is **prone to
finding clusters that don't exist**. The mechanism is specific, not vague
methodological pessimism: cognitive-science data typically combines
modest effect sizes, limited sample sizes, and **non-orthogonal
(correlated) indicators** — and this combination creates a real,
demonstrated risk of detecting spurious cluster structure. Concretely and
alarmingly: a simulation using clustering variables correlated at only
r = 0.30, with **no true underlying subpopulations built into the
simulation at all**, produced what looked like a clean, interpretable
multi-cluster solution. A systematic review of 191 published clustering
studies in this space (2016–2020) found a median sample size of 322 and
**not a single study concluding in favour of a one-cluster (no real
structure) solution** — a striking sign of publication bias in the
methodology's own literature, meaning most published precedent in this
space cannot be taken as reassurance that clustering "works" here; if
anything it's a warning that null results in this literature go
unpublished.

**What this means concretely for WM-FTT:** several of the candidate
clustering variables (OSIVQ subscales, VVIQ, WM-FTT's own performance/
compositional scores) are very plausibly correlated with each other
already, on substantive grounds, not just noise — that's close to the
whole point of studying them together. This is exactly the "non-orthogonal
indicators" condition flagged as high-risk. **A clean-looking cluster
solution from this data is not, by itself, evidence of real subgroup
structure**, and needs to be treated with real suspicion until checked
against this specific risk, not accepted because it "looks interpretable."

## 2. Sample size — a real, quantified constraint, not a vague concern

A dedicated power analysis for cluster analysis (not a general small-N
warning, a specific methodological paper on this exact question)
recommends: **N = 20–30 per expected subgroup**, clustering only attempted
when **large subgroup separation is genuinely expected** (not a
fishing expedition), and preference for **fuzzy clustering or mixture
modelling** (methods that allow partially-overlapping distributions) over
hard partitioning methods, which are less powerful and less parsimonious
for realistic, overlapping psychological subgroups.

**Applied directly to WM-FTT's numbers:** pooled N=118 could plausibly
support a 3–4 cluster solution under this guidance (roughly 30-39 per
cluster if evenly split, though real subgroups are unlikely to be evenly
sized). This is a real, load-bearing constraint on how many clusters
should even be considered as plausible outcomes, not an afterthought —
and it interacts directly with `05-version-scope.md`'s open v2
question: clustering is a place where v2's small N (9) genuinely can't
carry independent weight, reinforcing that doc's existing framing rather
than reopening it.

## 3. Method families and how they handle WM-FTT's likely mixed data

WM-FTT's candidate clustering variables are very plausibly a **mixed**
set — continuous (OSIVQ subscales, VVIQ, WM-FTT scores) and potentially
categorical (version, possibly VVIQ group if included as a supplementary
rather than defining variable). A benchmark comparison of clustering
approaches for exactly this kind of heterogeneous data found **model-based
methods (particularly the Kamila algorithm and latent class models) and
K-prototypes generally performed best**, ahead of purely
distance/dissimilarity-based approaches (e.g. Gower distance + hierarchical
clustering), across a range of simulated scenarios varying sample size,
cluster count, and variable relevance.

This converges with §2's recommendation toward model-based/mixture
approaches (as opposed to e.g. k-means or hard hierarchical clustering) on
two independent grounds: power-analysis guidance for cognitive data
generally, and mixed-data-type handling specifically. **Tentative
direction, not a final choice:** a model-based/mixture approach (e.g.
latent profile analysis, or a Kamila-style method if the final variable
set is genuinely mixed continuous/categorical) is the better-supported
starting point over hard partitioning methods like k-means, pending the
variable-set decision in §4 and pending comparison against the author's own
prior published method (§6).

## 4. Candidate variables — OSIVQ correctly relocated here

Per direct correction from the author: OSIVQ subscales (`object_mean`,
`spatial_mean`, `verbal_mean` — already present in `all_data` per the
original handoff §5.2) belong here as **candidate clustering variables**,
used continuously, the way they were used in the author's own prior published
clustering work — **not** as a categorical cognitive-style label via a
discrete classification rule. The earlier framing considered and
explicitly dropped: a competing-rules discrete classification
(`osivq_gazzo` vs `osivq_max`, assigning categorical labels like
"Visualiser"/"Verbaliser"/"Undecided") was about a different, now-
abandoned question entirely, not a preliminary step toward the continuous
clustering use — **this doc does not revisit or need that categorical
classification approach.**

**Full candidate variable set — inputs vs. validation, now resolved (§0):**

Per §0's lineage framing: clustering **inputs** are restricted to stable
subjective/trait questionnaire variables; behavioural, compositional, and
self-report-strategy data are **held out as validation/interpretation
variables**, checked against the resulting clusters rather than folded
in. This is not merely a variable-count-reduction convenience — it is
specifically what makes WM-FTT's clustering run comparable to study 2's
clean, non-circular design rather than a repeat of study 1's acknowledged
circularity (§0).

**Clustering inputs:**

- OSIVQ subscales (object, spatial, verbal) — continuous, per above.
- VVIQ — continuous. Note: VVIQ is also the basis of the researcher-
  defined groups that clustering is explicitly trying to look *beyond*
  (`00-framing.md` §5) — including it as a clustering input
  is not a contradiction (clustering can still reveal structure that
  cuts across VVIQ-based categories even with VVIQ itself as an input,
  per the cited precedent: <cite>characteristic strengths in spatial or
  verbal reasoning may appear in both aphantasic and typical-imagery
  individuals, suggesting traits distributed along continua rather than
  restricted to one diagnostic group</cite>) — but worth being deliberate
  about this choice and stating the rationale explicitly in the writeup,
  since a reader might reasonably ask why a "trans-categorical" analysis
  includes the categorising variable.
- **NIEQ — new relative to both prior studies, the genuine extension
  this run adds to the lineage (§0).** Confirmed directly against the
  source instrument (Heavey et al., 2019): NIEQ is 10 items (5
  Frequently + 5 Generally, one pair per dimension — mental imagery,
  inner speech, emotions, sensory awareness, unsymbolised thinking),
  each subscale scored as the pair's mean, matching what's already
  computed in `all_data` via `compute_nieq_scores()`
  (`inner_speech_mean`/`imagery_mean`/`unsymbolized_mean`/etc. or
  equivalent column names — confirm exact naming against `all_data`
  directly rather than assume). Two things to weigh before treating the
  5 dimensions as clean inputs:
  - **Sensory awareness is the empirically weakest dimension in the
    source instrument, on every metric reported**: markedly lower
    coefficient alpha (0.34, vs. 0.50–0.66 for the other four, N=260),
    did not emerge as a separate factor in exploratory factor analysis
    (loaded across multiple factors instead), and showed the highest
    between-subscale correlations of any dimension — a pattern
    independently replicated in a second, unpublished sample (N=60,
    Lapping-Carr, cited within Heavey et al.). This is a property of the
    instrument itself, not specific to WM-FTT's data, but worth checking
    WM-FTT's own sensory-awareness item correlations against this
    published baseline before treating it as an equally solid input
    alongside the other four dimensions.
  - **Frequency/proportion item-pair consistency** — the author's own planned
    check (are the two items per dimension, "how frequently" and "what
    proportion," measuring the same thing) — should run before NIEQ
    scores are used in clustering, not just as a side curiosity. This is
    the same "reliability before inference" logic already established in
    `06-task-validity.md` for WM-FTT's own scores, applied here to a
    second instrument. Source-paper precedent: Table 3 in Heavey et al.
    reports pair-wise item correlations for all five dimensions in their
    N=260 sample — useful as a comparison baseline once WM-FTT's own
    pair correlations are computed, not as a substitute for computing
    them.
  - the author's UT-aphantasia hypothesis (aphantasics scoring higher on
    unsymbolised thinking) is a genuine, testable, well-motivated
    question this data can speak to — flagged as a real analytical
    target, not just a variable-inclusion detail, worth surfacing
    explicitly wherever NIEQ results are eventually written up.

**Resulting input set: 9 raw continuous variables** (VVIQ ×1, OSIVQ ×3,
NIEQ ×5) — smaller than earlier drafts of this doc assumed, before the
behavioural-exclusion decision. Directly affects the variable-reduction
question (§7).

**Validation/interpretation variables (held out, not clustering
inputs):**

- **WM-FTT performance and/or compositional scores** (§1 of
  `02-score-computation.md`) — the primary held-out behavioural target,
  directly parallel to study 2's use of the reasoning task as its
  held-out target (§0). Checking whether trait-based clusters show real
  differences in WM-FTT behaviour is the actual hypothesis test this
  strand performs.
- **Self-report strategy data — resolved, decision and full data
  structure below.**

### 4.0 Amendment 2026-08-20: sample, and what the held-out behavioural measures must be

**Sample: v1 only (N=88)**, per `05-version-scope.md` §3.5. This is a
real constraint on this strand specifically — consensus clustering over 9
input variables at n = 88 is workable but not comfortable, and §7's
variable-reduction decision procedure becomes more load-bearing than it
was when the pooled N=118 was assumed.


Clustering *inputs* are the 9 subjective variables, so cluster formation
is insulated from the issue below. The **validation** step is not.

Per `04-response-propensity.md`, the per-feature score columns confound
two quantities — whether a participant reported a feature at all, and how
accurately they reported it. Including non-responses as zeros roughly
doubles the apparent association between score and VVIQ (§3.2 there), and
non-response rates differ sharply by version. Validating clusters against
those columns as they stand risks a validation that succeeds because the
clusters recovered *who declined to answer*, or which version someone was
in, which would look like exactly the result this strand wants and mean
something much weaker.

(Note that whether non-response itself relates to imagery is **not**
established — the pooled association dissolves within version, `04` §3.1.
That does not soften the requirement below: a contaminated validator is
contaminated regardless of what drives the contamination.)

**Two requirements follow:**

1. **Behavioural validation uses responded-only scores**
   (`score_*[responded_*]`), not the default score columns.
2. **Reporting propensity is available as a held-out measure in its own
   right**, separately from accuracy. Roughly half the
   between-participant variance in the raw score columns is propensity
   rather than accuracy (`04` §3.2), so it is a substantial signal in its
   own terms — but it is also strongly version-linked, so any cluster
   structure it validates must be checked against version before being
   read as cognitive.

This matters more here than elsewhere because of §0's own standard. Study
1's held-out validation was rhetorically oversold, and the bar this doc
sets is "genuinely convinced" rather than "technically defensible on
paper". A validation that succeeds on a contaminated measure is precisely
the clean-looking result §0 commits this doc to surfacing reasons to
distrust.

### 4.1 Self-report strategy — resolved as validation, structure now confirmed

Directly examined in the v3 front-end source (`json-strategies-cfa.js`,
`strategies-content.js`), correcting the earlier assumption of
heavy free-text/NLP-scale data:

- **Per-feature strategy questions** (one each for colours, orientations,
  words): multi-select checkbox, small fixed vocabulary per feature
  (`mental_image`, `repetition`, plus 1–2 feature-specific options —
  `spatial_wheel`/`semantic` for colour; `spatial_cardinal`/
  `spatial_body`/`semantic` for orientation; `spatial_body`/`semantic`
  for words), explicit "none" option, explicit "other" free-text
  fallback (exception path, not primary data).
- **Scoring-priority question** (separate, single checkbox item): which
  feature(s) the participant prioritised to maximise their score — a
  second, independent self-report of allocation, distinct from both the
  per-feature strategy checkboxes above and the behavioural compositional
  proportions (`02-score-computation.md`).
- **Note on an earlier error in this planning process**: a different
  set of Likert-style (`rating`) strategy items exist in the same source
  file, but belong to the reasoning study's task (`aphantasiaReasoningViie`),
  not WM-FTT — the two studies' front-end code shares a file, which
  caused an initial misreading during this session. WM-FTT's own
  strategy questions are checkbox-only, no Likert items.

**Decision: held out as a validation/interpretation variable, not a
clustering input** — same rationale as behavioural/compositional scores
(§0): self-report strategy is itself a form of task-related behaviour
(what the participant did, or believed they did, on this specific task),
not a stable subjective trait, so including it as a clustering input
would reintroduce a version of study 1's circularity concern for this
variable specifically, even though it's collected via questionnaire.

**Concrete operationalisation for validation use, several options, not
mutually exclusive:**

- **Presence/absence indicators**: per feature × strategy-option, a
  binary "selected/not selected" variable — direct, no information loss
  beyond what multi-select inherently has, no coding judgement required.
  Directly usable to characterise clusters after the fact (e.g. "does
  Cluster A select `mental_image` for colour more often than Cluster B").
- **Strategy count per feature**: how many strategies a participant
  selected (0 for "none" through the full option count) — a simple
  derived scalar, potentially interesting in its own right (does
  strategy diversity relate to cluster membership or to VVIQ).
- **Cross-feature strategy consistency**: does a participant selecting
  `mental_image` for one feature also select it for the others —
  checkable directly, substantively interesting (consistent-strategy
  participants vs. feature-specific-strategy participants may be a real
  distinction clusters could reveal).
- **Scoring-priority as a third preference measure**: directly extends
  the self-report-vs-behaviour convergent-validity question already
  flagged in `00-framing.md` §6 and `06-task-validity.md`
  §2.3 — now three comparable signals exist (self-reported priority,
  self-reported per-feature strategy, behavioural compositional
  allocation), checkable pairwise or jointly against cluster membership.
- **Free-text "other" responses** — the minority exception-path data.
  Given likely low volume (used only when fixed options don't fit),
  manual thematic coding (same spirit as the legacy `plot_strategies()`
  pattern-matching, done as a documented, principled step rather than
  inline plotting logic) is the pragmatic near-term approach. Full
  NLP/embeddings-based analysis is a legitimate but separate future-work
  angle — the author explicitly designed this field with future NLP-literate
  researchers in mind — flagged here as an acknowledged limitation/
  opportunity for the writeup, not attempted under the current deadline.

## 5. Validation, not just fitting — directly answering whether the clusters are real

Given §1's central risk, **fitting a clustering model and reporting the
result is not sufficient**. A specific validation plan is needed, treated
as equally important as the model-fitting itself, not an optional add-on:

- **Stability check**: does the cluster solution replicate under
  resampling (bootstrap, or split-half if sample size allows) rather than
  being an artifact of the specific sample fitted? Directly analogous in
  spirit to `06-task-validity.md`'s split-half approach for the
  compositional profile — the same "is this a stable trait-like signal or
  noise reshuffled" logic applies here.
- **Null/permutation comparison**: given §1's simulation finding (spurious
  clusters from correlated-but-structureless data), a meaningful check is
  whether the fitted solution's cluster separation exceeds what's produced
  by data with the same correlation structure but no true subgroup
  structure — i.e. actively trying to falsify the cluster solution, not
  just describing it.
- **One-cluster solution must be a genuinely live possibility**, not
  something the analysis is implicitly structured to rule out. Given the
  field's own apparent publication bias against null clustering results
  (§1), explicitly deciding in advance that "no meaningful subgroup
  structure" is an acceptable, reportable outcome — not a failure of the
  analysis — is itself a methodological safeguard worth stating up front,
  before results are seen.
- **External validation against WM-FTT performance**: once clusters are
  derived, checking whether they actually explain meaningful variance in
  WM-FTT task performance (directly analogous to the cited precedent
  approach: <cite>clusters characterized by visual, spatial, and verbal
  cognitive styles which were able to explain task performance</cite>) is
  a substantive check on whether the clusters are doing real explanatory
  work, not just a study of the input variables' own correlation
  structure. This connects clustering back to the performance-modelling
  strand (`10`) as a genuine cross-check between two independently-
  designed analyses, not just a shared-variable convenience.
- **Theory-vs-data k comparison (added, per §6.7's parallel two-arm
  design)**: a free-k, PAC-selected run compared against a theory-based
  fixed-k=3 run (the number both prior studies converged on), evaluated
  on stability metrics rather than just cluster content. This is a
  distinct check from the three above — it specifically tests whether
  the *number* of clusters, not just their presence, is well-supported
  by this sample versus imported as an assumption from prior work. Full
  design in §6.7.
  designed analyses, not just a shared-variable convenience.

## 6. Direct comparison to the author's own prior published methods — now done

Both prior R packages were provided directly and read in full
(`aphantasiaCognitiveClustering` — the original clustering study;
`aphantasiaReasoningViie` — the later study that reused and upgraded the
clustering approach). This section replaces the earlier "not yet done"
placeholder with what was actually found, and updates §3's tentative
method-family recommendation accordingly.

### 6.1 What the two prior studies actually did

**Study 1 (`aphantasiaCognitiveClustering`), N ≈ 96 (45 aphantasic + 51
control):**

- **Variable reduction** (`scale_reduce_vars()`): not PCA or factor-score
  extraction — a **theory-and-correlation-informed merge of scale-
  normalised raw scores**. Partial correlations (`correlate_vars()`,
  Pearson, Bonferroni-corrected) between 18 raw variables (VVIQ, OSIVQ,
  PsiQ subscales, Raven, spans, WCST, similarities, comprehension) were
  used to **decide which variables belonged in the same merge group**;
  the actual merge was then an item-count-weighted mean of the
  normalised scores (e.g. `visual_imagery` = (16×VVIQ + 15×OSIVQ-Object +
  3×PsiQ-Visual)/34), not a statistically-derived composite score. This
  produced 7 reduced variables from 18 raw ones.
- **Clustering**: single-algorithm `mclust::Mclust()` — Gaussian mixture
  model, `verbose = FALSE`, otherwise package defaults (BIC-based model
  and k selection). No consensus, no resampling, no explicit stability
  check beyond whatever `Mclust()` does internally.
- **Result**: a stable, publishable 3-cluster solution (named A/Aphant.,
  B/Mixed, C/Control) directly related to VVIQ group membership without
  being defined by it.

**Study 2 (`aphantasiaReasoningViie`), N ≈ 104, `cluster_osivq()`:**

- **Variable reduction**: none — narrowed directly to the 3 raw OSIVQ
  subscale means (object, spatial, verbal), no merging, **justified
  explicitly by study 1's own finding that OSIVQ was the most crucial
  set of variables for defining the clusters found there**.
- **Clustering**: `diceR::dice()`, consensus of `c("gmm", "pam",
  "cmeans")` (function default `c("gmm","pam","cmeans")`, matching what
  was actually called — no default/actual-value mismatch here, unlike
  the parity-threshold and skipper-threshold cases elsewhere in this
  project), consensus functions `c("kmodes", "majority", "CSPA")`,
  **`p.item = 1`** (resampling explicitly disabled — see §6.3), `nk = 3`
  fixed (not searched).
- **Result**: replicated study 1's cluster-group correspondence pattern
  closely (verbaliser cluster dominated by aphantasics/hypophantasics,
  visualiser cluster almost exclusively typical imagers, spatialiser
  cluster mixed) — stated directly in the manuscript as "very similar to
  that observed by [study 1]." Two independent samples, two different
  clustering methods (single GMM vs. three-algorithm consensus),
  converging on the same structure.

### 6.2 What this changes about §3's tentative recommendation

§3's general-literature-based lean toward model-based/mixture methods
over hard partitioning is **directly supported**, not contradicted, by
this review — `mclust` (GMM) is exactly a model-based method, and it's
what produced study 1's original, since-replicated result. This is
genuinely reassuring evidence, more specific and more relevant than the
general literature alone: **two independent samples, at a scale
comparable to WM-FTT's N=118, using two different methods, produced
convergent structure.** This directly and substantially updates the
earlier, more cautious framing in §1/§2 — the abstract risk of spurious
clustering at this sample size is real in general, but the author's own track
record at this scale is a specific, relevant counter-data-point that
should be weighted accordingly, not overridden by the general literature.

**What does NOT transfer directly:** study 1's variable-reduction method
(partial-correlation-informed weighted merging of 18 raw variables) was
solving a problem — 18 variables is a lot — that WM-FTT likely does not
have in the same form. WM-FTT's candidate set (VVIQ, OSIVQ ×3, NIEQ ×5,
WM-FTT behavioural/compositional scores) is closer in scale to study 2's
narrowed 3-variable set than to study 1's original 18. This means the
*decision* to reduce or not reduce needs its own reasoning for WM-FTT
(§7), not a default port of study 1's specific merge procedure — though
the general principle (correlation structure should inform, not
dictate, which variables are treated as redundant) carries over.

### 6.3 The `p.item = 1` choice, flagged directly

`diceR::dice()`'s own documented default is `p.item = 0.8, reps = 10`
(80% bootstrap subsamples, 10 replicates) — **resampling is the
package's default behaviour**, not an opt-in extra. Study 2's call used
`p.item = 1`, which **disables resampling entirely** (every run uses
100% of the sample, no subsample variation), a deliberate departure from
the package default toward a *less* robust configuration along that
specific axis. This is a third instance of the "documented default vs.
actually-used value" pattern already flagged twice elsewhere in this
project (`skipper_threshold` in the legacy plotting code; the parity
`analyse_parity(threshold=)` default) — worth naming as the same
recurring pattern, not a new, unrelated observation. No rationale for
`p.item = 1` was found in the code or manuscript. Full resampling
analysis and recommendation for WM-FTT in §6.5.

### 6.4 Full a priori review of `diceR`'s 12 base algorithms

Per the author's request: not limited to hierarchical methods, and not
selected by trial-and-error against WM-FTT's data. `consensus_cluster()`
offers 12 algorithms; the package's own documentation groups them by
underlying model family, which is used here as the organising structure,
each then assessed against WM-FTT's actual data properties (N≈118 for
clustering per §2's constraint, likely 4–8 continuous input variables
per §4/§7, no reason to expect non-Euclidean or manifold structure).

**Connectivity models — `hc` (hierarchical clustering), `diana`
(divisive analysis):**
Build clusters by successively joining or splitting based on
pairwise distance, no assumption of cluster shape. Known general
weaknesses directly relevant here: sensitive to the specific
linkage/distance choice (e.g. single linkage is prone to "chaining,"
stringing together a sequence of nearby points into one elongated
cluster rather than finding compact, separated groups); can perform
poorly relative to model-based methods specifically when true clusters
are roughly ellipsoidal/Gaussian-shaped, which is the plausible shape
for psychological trait data with no reason to expect non-convex
structure. **Assessment: keep as candidates, but not as the primary
basis for the consensus** — worth including for diversity (per §6.6's
logic on why algorithm diversity itself has value), but their known
shape-sensitivity is a real, citable, general reason (not a
WM-FTT-specific post-hoc exclusion) to weight them lightly relative to
model-based alternatives if consensus results disagree. This directly
answers the author's own prior instinct (hierarchical families gave
"uninformative" results before) with an actual mechanism, rather than
leaving that as an unexplained empirical observation to potentially
repeat without understanding why.

**Centroid models — `km` (k-means), `pam` (partition around medoids),
`ap` (affinity propagation), `cmeans` (fuzzy c-means):**
`km`/`pam` explicitly assume roughly spherical, similarly-sized
clusters — a real assumption, not automatically true for psychological
subgroups, but not obviously wrong for this data either, absent
evidence otherwise. `pam` is more robust to outliers than `km` (uses
actual data points as centroids rather than means). `ap` doesn't
require pre-specifying k, which is a genuine advantage for exploratory
work but a poor fit for this specific design, since `nk` is being
fixed/searched explicitly across the ensemble already (§6.7) — including
an algorithm with fundamentally different k-selection logic complicates
rather than strengthens the ensemble. `cmeans` (fuzzy c-means) is
**directly relevant and worth prioritising**: it allows partial/soft
cluster membership rather than hard assignment, which fits both the
general power-analysis guidance already in §2 (favouring methods that
tolerate overlapping distributions over hard partitioning) and the
substantive expectation from `00-framing.md` §5 that
cognitive profiles are more likely to overlap than form cleanly
separated groups. **Assessment: `km`, `pam`, `cmeans` all reasonable
candidates; `ap` excluded on principled grounds (k-selection logic
mismatch with the rest of the design), not a data-driven exclusion.**

**Distribution models — `gmm` (Gaussian mixture model):**
Assumes clusters are drawn from a mixture of Gaussian distributions —
the strongest assumption of any algorithm here, but also the most
directly matched to standard practice for continuous psychological
trait data, and the exact method (`mclust`, GMM) that produced study 1's
original, since-replicated result (§6.1–6.2). **Assessment: include,
weighted as a strong prior candidate given the direct track record, not
just the general-literature argument.**

**Density model — `hdbscan`:**
Assumes clusters are regions of high density separated by regions of
low density, and explicitly allows for noise points that belong to no
cluster. Built for and typically validated on much larger N (its
usual applications are large spatial/geospatial or high-dimensional
data mining tasks) and performs best when cluster density genuinely
varies or when a meaningful "noise" category is expected — neither
obviously true here (no a priori reason a participant's cognitive
profile should be classified as "noise" rather than belonging to some
profile). **Assessment: excluded, on a priori grounds (density-based
assumptions and typical-N mismatch with this data), not tested and
found wanting.**

**Matrix factorisation — `nmf` (non-negative matrix factorisation):**
Requires non-negative input data and produces a natural clustering as a
side effect of dimensionality reduction — a real technique, but built
for a different kind of data (its documentation example is gene
expression data) and requires a non-negativity constraint that would
need active checking/transformation for standardised psychological
scores (which are typically mean-zero after standardisation, i.e.
routinely negative) before it could even run correctly. **Assessment:
excluded — the non-negativity requirement is a poor structural fit for
standardised continuous psychological data, an a priori, mechanical
reason rather than a performance-based one.**

**Other — `sc` (spectral clustering), `som` (self-organising map with
hierarchical clustering), `block` (latent block co-clustering):**
`sc` is built for cases where clusters are non-convex/manifold-shaped
(its canonical use cases are things like image segmentation) — no
reason to expect that shape here. `som` and `block` are both typically
applied to larger, higher-dimensional data (SOMs are common in
large-scale unsupervised feature-mapping; `block` co-clustering
explicitly clusters rows and columns simultaneously, which presupposes
a benefit from clustering the *variables* jointly with participants, not
motivated by anything in this design). **Assessment: all three
excluded, a priori, as built for data shapes/scales not matched to
WM-FTT's variable set.**

**Resulting a priori candidate set: `gmm`, `pam`, `km`, `cmeans`, with
`hc`/`diana` included but down-weighted rather than excluded.** This is
close to, but not identical to, study 2's own selection
(`c("gmm","pam","cmeans")`) — the main difference is this analysis
explicitly considered and rejected `ap`, `hdbscan`, `nmf`, `sc`, `som`,
`block` on stated mechanical/structural grounds rather than leaving them
unconsidered, and explicitly discusses (rather than silently omits)
`hc`/`diana`. Worth the author confirming this reasoning holds rather than
accepting it uncritically — this is exactly the kind of judgment call
the doc's opening standard ("genuinely convinced, not reassured") applies
to.

### 6.5 Resampling (`p.item`, `reps`) — full analysis, not a default port

Per the author's request to look at what subsample size to bootstrap on,
rather than default to study 2's `p.item = 1` or to the package's
`p.item = 0.8` default without reasoning through it:

- **What resampling is actually for here**: repeatedly clustering random
  subsamples and checking whether the same structure keeps emerging is
  a direct, mechanical implementation of the stability check already
  required in §5 ("does the cluster solution replicate under
  resampling") — not a separate concern from validation, this *is* one
  of the concrete validation methods `diceR` can provide, provided it's
  switched on.
- **Why `p.item = 1` (study 2's choice) undermines this specific
  purpose**: with no subsampling, every one of the `reps` runs sees
  identical data — any variation in a given algorithm's output across
  reps at `p.item = 1` reflects only that algorithm's own
  initialisation randomness (e.g. `km`'s random starting centroids), not
  genuine sample-stability information. This doesn't make study 2's
  result wrong, but it means study 2's `diceR` call was functioning
  more as "multi-algorithm consensus at fixed N" than as "multi-
  algorithm consensus *and* resampling-based stability check" — worth
  being precise that these are two distinct sources of robustness, and
  study 2 only used one of them.
- **What subsample size is defensible for WM-FTT's N≈118**: the
  package's own default (`p.item = 0.8`) means each resample uses
  roughly 94 participants — comfortably above the ~20–30-per-cluster
  guidance from §2 even for a 3–4 cluster solution, so there's no
  N-driven reason to deviate from the package default toward a smaller
  subsample. **Recommendation: use `p.item = 0.8` (the package default),
  not `p.item = 1`** — this both restores the resampling-based stability
  information study 2's configuration discarded, and requires no
  special justification, since it's simply the documented default,
  applied rather than silently overridden.
- **`reps`**: package default is 10. No WM-FTT-specific reason found to
  deviate; more reps gives a more stable stability-estimate at
  reasonable computational cost, given the input variable count is
  small (§4/§7). **Recommendation: keep or modestly increase (e.g. 20–50)
  reps rather than the default 10**, purely for a more stable PAC/
  stability estimate, not because 10 is wrong — genuinely a "more is
  marginally better, cheaply" case rather than a principled minimum.

### 6.6 Consensus functions — full analysis, not restricted to study 2's three

`diceR` offers 5 consensus functions: `kmodes`, `majority` (majority
voting), `CSPA` (cluster-based similarity partitioning), `LCE` (link-
based cluster ensemble), `LCA` (latent class analysis). Study 2 used
three (`kmodes`, `majority`, `CSPA`); this reviews all five rather than
defaulting to that subset.

- **`majority` (majority voting)**: the simplest, most transparent
  method — assigns each point to whichever cluster label the most
  individual runs agreed on. Easy to interpret and explain (a real
  advantage for a thesis chapter audience), but can struggle with the
  **label-switching problem** inherent to unsupervised clustering
  (cluster "1" in one run isn't necessarily the same substantive group
  as cluster "1" in another run) unless labels are first aligned across
  runs — `diceR`'s internal relabelling (`relabel_class()`) is designed
  to handle this, so this isn't a disqualifying weakness, just worth
  knowing the mechanism it depends on.
- **`kmodes`**: treats each run's cluster assignments as categorical
  data and finds the modal partition — conceptually similar to majority
  voting but via a different mechanism (k-modes clustering applied to
  the label matrix itself). Reasonable, standard choice, no specific
  concern for this data.
- **`CSPA`**: builds a co-association (similarity) matrix from how often
  each pair of participants was placed in the same cluster across runs,
  then clusters *that* similarity matrix (via hierarchical clustering,
  per the package documentation). More information-preserving than
  majority/kmodes (uses pairwise co-occurrence, not just final labels),
  standard and well-established (original method: Strehl & Ghosh, 2002,
  a widely-cited ensemble-clustering paper, not an obscure or
  unvalidated technique).
- **`LCE`**: link-based cluster ensemble — another co-association-based
  method, conceptually similar in spirit to CSPA but using a different
  underlying linkage construction. Standard, established alternative;
  no specific reason found to prefer or exclude it over CSPA for this
  data specifically.
- **`LCA`**: latent class analysis applied to the ensemble of cluster
  labels — treats the consensus problem itself as a latent-class
  problem. Conceptually the most different from the other four (model-
  based rather than voting/co-association-based), which is actually a
  point in its favour for inclusion: if the goal is checking whether
  structure is robust across genuinely different consensus *mechanisms*,
  not just different base algorithms, `LCA` adds real diversity that
  `kmodes`/`majority`/`CSPA`/`LCE` (which share more family resemblance
  with each other) don't.

**Recommendation: use all five, not study 2's subset of three.** Unlike
the base-algorithm case (§6.4), where several algorithms were excluded
on genuine structural-mismatch grounds, no comparably strong a priori
reason was found to exclude any of the 5 consensus functions for this
data — they're all standard, established methods without a clear
structural mismatch to WM-FTT's data shape. Where §6.4 argues for
principled narrowing, this is closer to the author's original "why not use as
many as possible" instinct being the right call, precisely because nothing
comparable to hierarchical clustering's shape-sensitivity or NMF's
non-negativity requirement was found among the consensus functions.
Using all five and checking whether they converge is itself a stronger
robustness statement than picking three in advance, provided the choice
to use all five is made now, before results are seen, and not narrowed
after the fact if some give a "cleaner" answer — the same
researcher-degrees-of-freedom discipline applies to this axis as to
algorithm selection.

### 6.7 Summary of the three free-variable decisions

| Free variable | Study 2's choice | This doc's recommendation | Basis |
|---|---|---|---|
| Base algorithms | `gmm`, `pam`, `cmeans` | `gmm`, `pam`, `km`, `cmeans` primary; `hc`/`diana` included but down-weighted; `ap`/`hdbscan`/`nmf`/`sc`/`som`/`block` excluded | A priori, per-algorithm structural fit to data (§6.4) |
| Resampling (`p.item`) | 1 (disabled) | 0.8 (package default) | N=118 comfortably supports it; restores stability information study 2's choice discarded (§6.5) |
| `reps` | 10 (default, not overridden) | 10–50 | More reps cheaply improves stability estimate; no reason found to deviate from default besides marginal improvement (§6.5) |
| Consensus functions | `kmodes`, `majority`, `CSPA` | All five (`kmodes`, `majority`, `CSPA`, `LCE`, `LCA`) | No structural mismatch found for any; more consensus-mechanism diversity is itself informative (§6.6) |
| `nk` | Fixed at 3 | Parallel two-arm design: free k (PAC-selected, range ~2–5) vs. fixed k=3 (theory-based prior from studies 1–2), compared on stability metrics | Consistent with §2's power-analysis-based cluster-count guidance; tests the theoretical prior rather than assuming or discarding it (§6.7) |

**Important caveat on the `nk` row — resolved as a parallel two-arm design,
not a single choice.** Study 2 fixed `nk = 3` on theoretical grounds: both
prior studies found the 3-cluster structure meaningful and revealing of
what OSIVQ specifically can tell us about cognitive style — a real,
stated prior, not an arbitrary default. Rather than choosing between
"honour the prior" and "let the data decide," the author proposed running both
in parallel and comparing their solidity, which is adopted here as the
design:

- **Arm A — free k**: `dice(..., nk = 2:5, k.method = <PAC-based
  selection>)`, letting `diceR`'s own PAC-based method choose the best k
  within a range consistent with §2's N=20–30-per-cluster guidance at
  WM-FTT's N≈118 (roughly caps a defensible range at 4–5 clusters; exact
  upper bound worth confirming rather than treating 2:5 as final).
- **Arm B — fixed k=3**: `dice(..., nk = 3)`, directly testing the
  theory-based prior from studies 1–2 against WM-FTT's specific data.
- **Comparison, not just two separate results**: the two arms are
  compared on **stability metrics** (PAC, consensus-matrix clarity,
  resampling agreement per §6.5's configuration), not merely on whether
  cluster *content* looks similar. This directly extends §5's validation
  requirement rather than sitting apart from it — a genuine third check
  alongside the stability/resampling and null-comparison checks already
  scoped there.
- **What each outcome would mean, stated in advance (per §5's
  "one-cluster/unexpected-k must be a live outcome" principle, applied
  here specifically)**:
  - Free k converges on 3 independently → strongest possible result,
    theoretical prior and data-driven answer agree without being forced to.
  - Free k converges elsewhere (2, 4, or more) → does not automatically
    overturn the 3-cluster story, but must be reported honestly, not
    suppressed in favour of the expected number.
  - Fixed k=3 shows poor stability (low PAC, weak resampling agreement)
    while free k is more stable elsewhere → suggests the prior structure
    may fit WM-FTT's specific sample/population less well than it fit
    studies 1–2, itself a real and reportable finding given WM-FTT's
    different task and likely different population details.
  - Both arms agree and both are stable → the strongest outcome this
    design can produce, and the most straightforward to write up.

This resolves the earlier framing (§6.7's original caveat, written before
this exchange) that treated fixed-k=3 as simply "importing an assumption
without justification" — the theoretical justification exists and is
real, it's just being tested against, not substituted for, a free-k
comparison, consistent with the doc's overall standard of not accepting
a clean-looking result without checking it.

## 7. Variable reduction — plan for deciding, not a decision itself

With the input set corrected to 9 raw variables (VVIQ ×1, OSIVQ ×3, NIEQ
×5, per §4), the reduction question sits differently than either prior
study's precedent: smaller than study 1's original 18-variable problem
(which genuinely needed heavy reduction), larger than study 2's already-
narrowed 3-variable set (which had no reduction question left to ask).
Neither prior study directly answers this for WM-FTT — this section is a
plan for how to decide, not the decision itself, consistent with this
doc's general pattern of not pre-committing before real data is examined
(§3's response-family deferral, `10-performance-modelling.md`'s deferred
family choice, follow the same logic).

**What would actually justify reduction, stated as a testable condition
rather than a general worry**: not "9 is a large number," but specific,
substantively-expected redundancy between particular variables — e.g.
VVIQ and OSIVQ-Object are already expected (per the author's own stated prior,
in the original discussion of NIEQ) to correlate heavily, since both are
visual-imagery measures. If two or more of the 9 variables are strongly
correlated on grounds like this, treating them as independent dimensions
in clustering effectively double-counts the shared signal, over-
weighting whatever they're redundant about relative to the other,
non-redundant dimensions. That is the actual problem reduction solves —
not dimensionality for its own sake.

**Three-step plan, deferring the actual call to real data:**

1. **Compute the full 9×9 correlation matrix (and partial correlations,
   following study 1's own method — see §6.1) before deciding anything.**
   Cheap, directly answers whether real redundancy exists or whether the
   9 variables are meaningfully distinct, in which case reduction would
   solve a problem that doesn't exist. Partial, not just pairwise,
   correlations matter here for the same reason study 1 used them: a
   variable can appear correlated with another only because both share a
   third underlying driver, which pairwise correlation alone wouldn't
   distinguish from direct redundancy.
2. **If real redundancy is found, prefer study 1's actual method**
   (theory-and-correlation-informed merging into interpretable
   composites — e.g. a merged "visual imagery" variable from VVIQ +
   OSIVQ-Object, weighted by item count, following §6.1's documented
   procedure) **over blind statistical dimension reduction (PCA/factor
   scores).** Not continuity with prior work for its own sake — merged
   composites stay interpretable (a cluster describable as "high visual
   imagery," not "high on principal component 2"), which matters
   directly both for thesis-chapter interpretability and for later
   comparing cluster characteristics against the held-out validation
   variables (§4).
3. **If no strong redundancy is found, use the 9 raw variables
   directly** — closer to study 2's approach, and a genuinely defensible,
   clean outcome in its own right, not a fallback to be avoided.

**The "ethically clean" ordering constraint — the author's own framing, adopted
directly**: the correlation-based reduction decision (steps 1–2) must be
made **before looking at how any candidate reduction affects the
resulting clustering solution** — decide which variables are redundant
and how to merge them based on the correlation structure alone, commit
to that variable set, and only then run clustering. Checking multiple
candidate reduced variable sets against clustering outcomes and
preferring whichever gives a cleaner-looking result would be "p-hacking
in spirit" in exactly the same sense already named for algorithm
selection (§6.4) and the historical framing-pressure problem described in
§0 — the mechanism differs (variable definition vs. algorithm choice vs.
rhetorical framing) but the underlying discipline is the same throughout
this doc: **decisions that shape what a clustering result can show must
be locked in before that result is seen, not adjusted afterward to
produce a more convincing one.** Explicitly acknowledged as a real,
if narrower, use of "the data influencing analytical choices" (the
correlation structure informs which variables merge) — defensible here
specifically because it concerns *which variables represent redundant
information* (a data-quality/multicollinearity question, answerable
without reference to any clustering outcome), not *which choice produces
a more interpretable or expected cluster result* (which would not be
defensible). Worth stating this distinction explicitly in the eventual
methods writeup, not just applying it silently — the doc's standard of
"genuinely convinced, not reassured" (§0's opening framing) applies to
the author's own reasoning here as much as to any external technique.

**Note for other researchers, stated directly per the author's own framing**:
this reduction decision, once made, is WM-FTT's own committed choice —
not a claim that it's the only defensible variable set. Other
researchers working with this data are free to try different reductions
or the raw variable set; this doc documents the reasoning behind one
specific, principled choice, not an assertion of uniqueness.

## 8. What this doc deliberately does not do

- Does not finalise the full clustering variable set (§4) — NIEQ and
  self-report-strategy questions remain open.
- Does not design the validation procedures in implementation detail
  (§5) — scoped as required components, not yet written as executable
  steps (though §6.5's resampling recommendation directly feeds one of
  them).
- Does not revisit the discrete OSIVQ classification rule
  (`osivq_gazzo`/`osivq_max`) — confirmed dropped, not part of this
  strand at all.
- Does not run any of §6's recommendations against real WM-FTT data —
  the a priori algorithm/consensus/resampling analysis is complete, but
  untested against this specific dataset, which is the point (decided
  before results are seen, not adjusted after).

## 9. Summary of decisions

| Decision | Choice | Status |
|---|---|---|
| Central risk to design against | Spurious clusters from correlated, non-orthogonal indicators at modest N | Identified, governs rest of doc |
| Minimum viable subgroup size | N=20–30 per expected cluster (literature guidance) | Adopted as planning constraint |
| v2 role | Excluded from carrying independent weight, consistent with `05-version-scope.md` | Settled (inherited, not re-decided) |
| Comparison against the author's own prior published/pre-print methods | **Done** — both prior R packages read directly (§6.1) | Settled |
| Prior-method finding | Model-based (GMM) clustering at N≈96–104 produced a result that replicated across two independent samples and two methods | Strong positive evidence, revises earlier general-literature caution upward (§6.2) |
| Base clustering algorithms | `gmm`, `pam`, `km`, `cmeans` primary; `hc`/`diana` included but down-weighted; `ap`/`hdbscan`/`nmf`/`sc`/`som`/`block` excluded on a priori structural grounds | Settled (§6.4) |
| Resampling (`p.item`) | 0.8 (package default), not study 2's 1 | Settled (§6.5) |
| `reps` | 10–50 | Settled (§6.5) |
| Consensus functions | All five (`kmodes`, `majority`, `CSPA`, `LCE`, `LCA`), not study 2's subset of three | Settled (§6.6) |
| `nk` (number of clusters) | Search a small range (e.g. 2–5), PAC-informed, not fixed at 3 a priori | Settled (§6.7) |
| OSIVQ role | Continuous clustering variable, not discrete classification | Settled, corrected from earlier miscategorisation |
| NIEQ role | Candidate variable set, all 5 dimensions; sensory-awareness reliability and freq/prop item-pair consistency to be checked before use | Settled as plan, checks not yet run (§4) |
| VVIQ as clustering input | Included, with explicit stated rationale required in writeup | Settled |
| WM-FTT behavioural/compositional scores as clustering input | **Excluded from inputs — validation/interpretation variable only** | Settled (§0, §4) |
| Self-report strategy as clustering input vs. validation variable | **Excluded from inputs — validation/interpretation variable only**, same rationale as behavioural scores | Settled (§0, §4.1) |
| Clustering input set | 9 raw variables: VVIQ ×1, OSIVQ ×3, NIEQ ×5 | Settled (§4), pending §7's reduction analysis |
| Scientific framing of this strand | Third attempt at a consistent held-out validation logic across three independent samples (not a fix for a prior flaw — study 1 already attempted this honestly and got a null result); NIEQ and WM-FTT behaviour are this run's genuine extensions | Settled (§0) — highest-priority framing point for the eventual writeup |
| Validation requirement | Stability/resampling check (now concretely specified via §6.5), null-comparison check, one-cluster-solution treated as live outcome, external validation against task performance | Settled as required components |
| Variable-reduction decision procedure | Compute full correlation/partial-correlation matrix first; merge only where real redundancy found, via theory-informed weighted composites (study 1's method), not blind PCA; commit before seeing clustering results | Settled as procedure (§7); actual reduce-or-not outcome deferred to real data |

## 10. Open questions, not resolved here

- Final clustering variable set (§4) — NIEQ checks (sensory awareness
  reliability, freq/prop consistency) still need running before the
  9-variable input set is fully confirmed clean; the input/validation
  split itself is now settled (§0, §4).
- Whether the 9-variable input set actually gets reduced — the
  *procedure* for deciding is now settled (§7), but the outcome depends
  on real correlation data not yet examined.
- Exact stability/validation procedures as implementable steps (§5) —
  §6.5 specifies the resampling configuration, but the full validation
  pipeline (null-comparison, external validation against performance)
  isn't yet written as executable steps.
- Whether version should be a clustering input, a stratification variable,
  or excluded entirely — not addressed in this draft, worth raising
  explicitly given `05-version-scope.md`'s general stance on version
  as structural rather than nuisance.
- Concrete operationalisation choice(s) among §4.1's several options for
  self-report strategy validation use — several were listed as
  non-mutually-exclusive; which to actually implement isn't decided.

## 11. Next steps (not this doc)

- Resolve the NIEQ variable-inclusion checks (§4): sensory-awareness
  reliability against the published baseline, freq/prop item-pair
  consistency.
- Compute the 9×9 correlation/partial-correlation matrix (§7) — the
  concrete next step for the reduction question, to be done before any
  clustering is run, per §7's ordering constraint.
- Design the full validation pipeline (§5) as concrete, implementable
  steps, incorporating §6.5's resampling specification directly.
- Implement `02-score-computation.md`'s pipeline (shared dependency).
- Revisit v2/version questions here only if `05-version-scope.md`'s
  general resolution changes.
