# WM-FTT: computing analysis-relevant scores

**Status:** design settled, not yet implemented. Feeds performance modelling,
compositional analysis, and clustering — all three downstream strands need a
score that isn't the live-feedback column.

**Context:** the existing `score_word`/`score_angle`/`score_color` columns in
`all_data` are live-computed, threshold-based sums used only to give
participants in-task feedback (nudging them to maximise a points-per-feature
total). They discard continuous information (Levenshtein distance for words,
angular error for colour/orientation get binned into 1/0.5/0 at arbitrary
cutoffs) and are not on comparable scales across features. **They should not
be used as the dependent variable for any of the three analytical strands.**
A new score needs to be computed from the underlying raw distances.

---

## 1. Why the current columns don't work

Two separate problems:

1. **Thresholding** discards continuous information. A response 1 character
   off and a response 8 characters off both collapse to the same discrete
   bucket.
2. **Cross-feature incomparability.** Levenshtein distance (word) and angular
   error (colour, orientation) are different kinds of quantities — different
   units, different ranges, different distributional shape. Any downstream
   step that treats the three raw scores as interchangeable (proportions,
   clustering distances) is implicitly scale-weighting by whichever metric
   happens to have the largest raw range, not by anything meaningful about
   the participant.

"Comparable" is not one requirement — the three downstream strands need
different things from it (see §4).

## 1.5 Correction: `diff_word`/`diff_angle`/`diff_color` already exist — read this before §2

**Renamed `live_diff_*` in the implementation session's step 1; the old
names are kept in this section's prose where it describes the front end,
since that is what `utils.js` and the raw JATOS export still call them.**

**An earlier version of this doc's companion session-planning material
incorrectly stated that no intermediate metric columns exist in the
pipeline.** That was wrong — checked directly against the front-end
source (`js/jspsych/plugin-colored-rotated-label-feedback.js` and
`js/jspsych/utils.js` in the v3 front-end code) after the author pointed out
the miss. The intermediate values do exist, under a `diff_` prefix that
an earlier search for "levenshtein"/"distance"/"angle_diff" failed to
catch. Documented precisely here so this doesn't need re-discovering:

- **`diff_word`**: **not a valid edit distance — see the correction
  immediately below this list.** The plugin computes
  `diffWordList.push(1 - wordDiff)` where `wordDiff` is the output of
  `utils.js`'s `levenshteinDistance(str1, str2)`, which returns `1 -
  editDistance / max(len(str1), len(str2))` — i.e. it is written to
  return a **length-normalised similarity**, not a raw edit count,
  despite the function's name. So **`diff_word` = `editDistance /
  max(len(target), len(response))`**, a **dissimilarity** (0 = identical,
  larger = more different), *provided `editDistance` is what the function
  is meant to compute*. It is not. Both target and response strings are
  lowercased, whitespace-stripped, and diacritic-normalised
  (`.normalize("NFKD").replace(/[\u0300-\u036f]/g, "")`) before the
  distance is computed; that part is exactly as it appears. If either
  string is empty the plugin's `if (tword && uword)` guard leaves
  `wordDiff` at 0, so an unanswered word trial yields `diff_word = 1`.

  **Correction, 2026-08-20, from real data plus source
  re-read: `levenshteinDistance()` does not compute Levenshtein
  distance.** `utils.js` lines 20–22 read:

  ```js
  for (let i = 0; (i = 0); i--) {
    dp[i][0] = i;
  }
  ```

  The loop *condition* is an assignment, not a comparison. `i = 0`
  evaluates to `0`, which is falsy, so the body never executes and the
  first column of the dynamic-programming matrix is never initialised to
  `i` — it keeps its `Array.fill(0)` value, leaving `dp[i][0] = 0` for
  every `i`. Deleting a prefix of the target therefore costs nothing, and
  the function returns something closer to an **approximate-substring
  distance**, systematically lower than true Levenshtein and never
  higher. The paired `for (let j = 0; j <= n; j++)` loop on the next line
  is correct, so only one boundary is broken — which is why exact matches
  still score 0 and the error went unnoticed.

  **Verified against the data, not just read from source.** A faithful R
  port of the broken function, dead loop included, reproduces the stored
  `diff_word` for **8496 of 8496** non-tutorial rows once JavaScript's
  rounding convention is matched (`Math.round(x * 100) / 100` rounds half
  away from zero; R's `round()` uses banker's rounding, which alone
  accounts for 7 rows differing by exactly 0.01). Correct plain
  Levenshtein reproduces only 8177 of 8496. The 313 divergent rows are
  all cases where the response was non-empty and incorrect, and the
  stored value is lower than the true distance in 313 of 313 of them.
  Example: `target = "cadeau"`, `response = "tout"` — true Levenshtein
  6, broken version 3, stored `diff_word` 0.50.

  **Consequences.** The earlier statement here that "this uses plain
  Levenshtein distance, not Damerau-Levenshtein" was the right reading of
  a function that does not do what it says; it is withdrawn. `diff_word`
  should never be used as an analytical variable, and neither should
  `score_word`, which is thresholded from it (`>= 0.9` → 2 points,
  `>= 0.75` → 1). Both were renamed to `live_diff_word` and
  `feedback_score_word` in the implementation session's step 1, with the
  reason recorded in `R/data.R`. The live feedback participants saw was
  therefore more generous on word recall than intended, in a
  response-dependent way; this affects the in-task points display only,
  since no analysis uses these columns, and warrants one sentence in the
  methods writeup rather than a correction notice.
- **`diff_angle`**: `Math.abs(target_angle - user_angle) / 180` — a
  **linear**, not cosine-based, normalised absolute difference. Verified
  against the data: reproduces at stored precision for 99.94% of rows,
  the remainder being rounding. Note: `utils.js` also defines a
  `normalizeAngle()` function (clamps to ±90°, wraps at ±180°) which **is
  not called in this computation** — `diff_angle` is computed directly
  from the raw angle values via `Math.abs()`, with no circularity
  handling. It *is* called elsewhere, in `plugin-angle-wheel.js` line
  173, where it constrains the participant's response as they drag; that
  is why `response_angle` is bounded to [-90, 90]. The earlier wording
  here ("not called anywhere in this computation") was correct about
  `diff_angle` but read as a claim about the pipeline as a whole.
- **`diff_color`**: similar in spirit but with explicit circular wrapping
  logic before the `/180` normalisation: `colorDiff =
  Math.abs(target_color - user_color)`, then if `colorDiff > 360` it's
  set to 180, else if `colorDiff > 180` it's replaced with `360 -
  colorDiff` (this is the actual circular-wrap step). Result divided by
  180. So **colour's diff, unlike angle's, does account for circularity**,
  via explicit conditional wrapping rather than a cosine transform.
  Reproduces exactly against the data for 100% of rows.

  **The `> 360` branch, previously flagged here as "appears unreachable
  given colours are encoded as angles 0–360 ... worth checking rather
  than assumed intentional", is reachable and intentional.** It is the
  missing-response guard: 870 rows have `|target - response| > 360`, and
  all 870 are rows where `response_color_angle == 999`, the sentinel
  `plugin-color-wheel.js` emits when the participant never touches the
  wheel. The branch maps those onto maximal difference, and `diff_color`
  is exactly 1 for every one of them. See §2.5.

**All three `diff_*` values are dissimilarities in [0, 1]** (0 = perfect
match, 1 = maximally different), the **opposite direction** from the
"similarity" scores this doc's §2 specifies computing (where 1 = perfect
match). **Resolved 2026-08-20, previously flagged as undecided:** the two
conventions coexist, and the *names* carry the direction. The new columns
from §2 are similarities named `score_*`; the retained front-end columns
are dissimilarities renamed `live_diff_*`. Nothing is inverted to match
anything else, because nothing reuses them — see the last bullet below.
Anyone comparing the two must invert explicitly, and the roxygen block in
`R/data.R` says so at the point of use.

**What this changes concretely:**

- The word-scoring formula in §2 (Gonthier 2022 edit-distance scoring)
  is **not** what `diff_word` currently computes, and the gap is wider
  than a difference of variant and denominator. Gonthier's method uses
  Damerau-Levenshtein divided by `len(target)` alone, with the raw
  distance capped at `len(target)` before subtraction. `diff_word` uses
  a **broken** distance divided by `max(len(target), len(response))`.
  There is no sense in which the existing column is a preliminary or
  cruder version of the same quantity — it is not an edit distance at
  all. This doc's recommendation to use Gonthier's exact method (§2)
  stands, and is now the only defensible option rather than the better
  of two.
- The angle/colour cosine-similarity recommendation in §2 is also **not**
  what `diff_angle`/`diff_color` currently compute (linear, not cosine,
  for angle; a different circular-wrap mechanism, not cosine, for
  colour). This doc's cosine recommendation stands as the intended
  design for the new pipeline — worth being explicit in any writeup that
  this is a deliberate departure from the front-end's existing
  computation, not a continuation of it.
- **Whether to build the new `compute_scores()` from scratch off raw
  target/response values, or to reuse/transform the existing `diff_*`
  values, is settled: from scratch.** Previously framed here as "a
  genuine implementation choice ... both are possible given `diff_*`
  exists". Reuse is no longer possible for the word feature at any price,
  since `diff_word` does not encode an edit distance and cannot be
  transformed back into one — the information is destroyed, not merely
  differently scaled. For colour and orientation reuse would have been
  arithmetically viable, but mixing a from-scratch word score with
  transformed angle/colour scores would leave the function half-derived
  from front-end code for no gain.

  **The verification cross-check needs redefining too.** It was specified
  as: do the from-scratch values and the transformed `diff_*` values
  agree where the underlying method is the same. For angle and colour
  that still works and is worth doing — a linear-metric version of the
  new code should match `1 - live_diff_angle` / `1 - live_diff_color`.
  For word it does not, and treating disagreement there as a bug would
  fire on the 313 rows above and be misread as an R error. What replaces
  it for word: the faithful port described above already reproduces
  `live_diff_word` to the last row, which is the real assurance that the
  R-versus-JS pipeline is understood end to end. The new score should be
  compared against **correct** plain Levenshtein and Damerau-Levenshtein
  instead, which is what the session plan's step 4 question 1 already
  wanted for its own reasons.



## 2. Raw error → similarity: the per-feature formulas

<!-- Heading restored 2026-08-20. The doc referred to "§2" throughout but
had no `## 2.` heading — it appears to have been lost when §1.5 was
inserted above. Content unchanged apart from the revisions noted inline. -->

Goal: turn each feature's native error metric into a continuous, bounded,
higher-is-better similarity score, without thresholding.

- **Word (Damerau-Levenshtein distance):** normalise by target length,
  using the exact formula from Gonthier's edit-distance-scoring method
  (source: reference `R` implementation in the paper's OSF materials,
  `EDS()` function):

  ```
  DL_distance <- damerau_levenshtein(target, response)
  DL_distance <- min(DL_distance, nchar(target))   # cap before dividing
  word_similarity <- (nchar(target) - DL_distance) / nchar(target)
  ```

  Bounded [0, 1], floored at 0 by construction (the cap on `DL_distance`
  before the subtraction prevents a negative score). **Correction from the
  previous version of this doc:** the denominator is `nchar(target)` alone,
  not `max(len(target), len(response))` as originally written here from a
  search-snippet paraphrase — confirmed now against the author's own
  reference code rather than inferred. Also uses Damerau-Levenshtein
  (allows adjacent-character transpositions as a single edit), not plain
  Levenshtein. **Revised 2026-08-20 (§1.5): the existing front-end
  computation (`live_diff_word`, via `utils.js`'s
  `levenshteinDistance()`) does not compute an edit distance at all** —
  its DP matrix is left half-initialised by a loop whose condition is an
  assignment, so it returns a systematically-too-small
  approximate-substring distance. An earlier version of this doc stated
  the existing pipeline used plain Levenshtein with a `max(len(target),
  len(response))` denominator, and framed this formula as "a deliberate
  departure on both counts"; that framing understated it. There is no
  working edit distance in the existing pipeline to depart from. The
  choice of Damerau-Levenshtein over plain Levenshtein remains a real
  methodological decision, but it is now a decision made against
  *nothing*, not against a prior implementation. Whether it matters
  empirically for this data is still worth checking (session plan step 4,
  question 1).

  **Scope note:** Gonthier's method is developed and validated for
  _serial span_ tasks — a trial's target and response are each a sequence
  of several stimuli encoded as one string (e.g. `"2468AC"` for six
  spatial locations), and edit-distance scoring is compared against
  other _sequence_-scoring methods (partial-credit, all-or-nothing,
  longest-correct-sequence, etc. — see Supplemental Materials 1) in that
  context. WM-FTT's word-recall trials are different in structure: one
  target word compared to one recalled word per trial, not a sequence of
  several items per trial. The distance computation itself transfers
  directly (Damerau-Levenshtein between two strings, length-normalised,
  floored at 0), but WM-FTT's use is an adaptation of the technique to a
  single-item comparison, not the same task type the method was validated
  on. Worth stating this precisely in the EOR page / methods writeup
  rather than citing the paper as if it validated single-word scoring
  specifically — it validates the distance metric and normalisation
  approach, not this exact use case.

- **Colour / orientation (angular error):** convert angular error to a
  similarity score using cosine, which respects circularity properly (an
  error near 0° and an error near 360° both correctly register as small):

  ```
  angle_similarity = (cos(angular_error_radians) + 1) / 2
  ```

  Rescaled to [0, 1]. **Decision made 2026-08-04: cosine over linear
  rescaling** (`1 - error/180`), specifically because it respects
  circularity — the linear version would treat a large angular error near
  180° as maximally different from a large error near -180°, when they're
  actually close on the wheel.

This produces three [0, 1] similarity columns, comparable in _range_ but not
yet necessarily comparable in _meaning_ — see next section.

## 2.5 Which rows get scored, and what counts as a response

**New section, 2026-08-20.** Neither this doc nor the session plan said
anything about phase filtering or non-responses. Both turn out to be
load-bearing, and both were discovered against real data rather than
inferred from schema. Nothing in §2 can be implemented without settling
them.

### 2.5.1 Tutorial rows carry placeholders — exclude

There are 118 rows with `expe_phase == "tutorial"`, one per
participant-by-version. For every one of them all three `live_diff_*` are
exactly 1 and all `feedback_score_*` are exactly 0, regardless of what the
participant did — `target_word == response_word` in 79.7% of them, and
target and response angles are often within a few degrees. These are
hardcoded, not computed: `define-timeline.js` lines 336–345 push the
constants directly, with the comment "It's the tutorial, so we don't count
these points, we add zeroes". The tutorial's feedback plugin is never run on
the tutorial's own data.

**Settled: exclude `expe_phase == "tutorial"` from scoring.** If included
they would inject 118 rows of perfect word recall scored as total failure.

**Open: what to do with `training`.** 9 stimulus rows per participant
(3 trials), real values, genuinely computed. Arguments both ways —
they are real recall attempts and dropping them costs ~11% of the data;
but they precede the blocks by design and performance on them is not
expected to be comparable. **Settled 2026-08-20: compute scores for
training rows, exclude them from aggregates at analysis time**, i.e.
filter in each analysis script rather than inside `compute_scores()`.
That keeps the option open and makes the choice visible at each point of
use rather than buried in the scoring function.

### 2.5.2 Non-responses are sentinel-encoded, not `NA`

Three different per-feature encodings, which do **not** reliably co-occur —
these are per-feature non-responses, not a single skipped-trial marker:

| Feature | Encoding | Rows | Share |
|---|---|---|---|
| word | `response_word == ""` | 1077 | 12.5% |
| orientation | `response_angle == 90` | 1711 | 19.9% |
| colour | `response_color_angle == 999`, `response_color == "#AAAAAA"` | 871 | 10.1% |

Rates rise sharply by version (experimental blocks only): word 8.0 / 14.1 /
17.0%, orientation 13.6 / 32.5 / 37.0%, colour 6.7 / 19.6 / 15.0% for
v1 / v2 / v3. That gradient is itself worth explaining — it may reflect the
v3 randomised recall order making non-response easier or more tempting, and
it interacts directly with §3's version-as-structural-factor position.

**Colour and word are cleanly identifiable. Orientation is not.**
`plugin-color-wheel.js` initialises `selectedGray = true` and clears it only
on interaction, emitting `selected_angle: selectedGray ? 999 :
currentAngle` — so 999 means unambiguously "never touched the wheel". An
empty `response_word` is equally unambiguous. But `plugin-angle-wheel.js`
has no marker at all: `currentAngle` starts at `trial.initial_angle`, which
`define-timeline.js` sets to 90 for both the tutorial (line 263) and the
experimental blocks (line 575), and if the participant never drags,
that value is returned as though it were a response.

In practice the three are separable with high confidence: 90 occurs 1710
times in non-tutorial rows against 5 for the next most frequent single
value; `normalizeAngle()` bounds responses to [-90, 90] so 90 is the
boundary; target angles come from `range(-63, 63, 2)` in v3 (observed
overall range -72 to 71), so **a response of exactly 90 can never be
correct**; and the tutorial instructions explicitly tell participants they
may leave the rectangle vertical and validate to move on quickly. But
"high confidence" is not "certainty", and the ~1% of genuine near-vertical
responses that get swept up should be acknowledged rather than hidden.

**This matters more than it looks.** A cosine similarity computed on 999 is
meaningless. And scoring a non-response as similarity 0 makes it
indistinguishable from a confident, completely wrong answer — two events
that mean different things for a study about *strategy*, which is what
WM-FTT is. The front end made no distinction: `live_diff_angle` for an
untouched slider is computed from 90 as if it were a real response.

**Three options.**

1. **Score as 0.** Simplest, preserves complete cases, and is defensible if
   non-response is read as failure to encode. But it conflates omission with
   error, and at v3's 37% orientation rate it would put a large mass of
   pseudo-zeros into the distribution that §3 then standardises against.
2. **Set to `NA`.** Honest about what is unknown, but propagates missingness
   into every downstream model, and the compositional analysis (ILR) has no
   graceful way to handle a missing component.
3. **Score as 0 but carry companion `responded_word` / `responded_angle` /
   `responded_color` logicals.** Keeps complete cases for models that want
   them, lets any analysis condition on or exclude non-responses explicitly,
   and makes the omission rate itself an analysable quantity.

**Settled 2026-08-20: option 3, score 0 with companion `responded_*`
logicals.** The reasoning that decided it, recorded because the first pass
at this weighed it wrongly:

An earlier draft of this section warned that scoring 0 "biases
distributions" and treated that as the main risk, which pushed toward
option 2. That weighting was wrong. **Non-response here is almost
certainly not missing-at-random** — a participant skips colour because
they have no colour representation to report, which in a study about
mental-representation diversity is close to the most on-target signal in
the dataset. Setting those to `NA` means every model doing listwise
deletion silently drops precisely the aphantasia-relevant observations.
That is bias in the *inference*, invisible in the output. Scoring 0 gives
bias in the *shape* of the distribution, visible in any histogram. Prefer
the visible failure mode.

The flags carry the information either way, so the choice of default only
determines what an analyst who ignores them gets: with 0, a distorted but
inspectable distribution; with `NA`, silent deletion. 0 fails safe.

**A uniform rule is available, contrary to the first draft of this
section.** That draft worried that forcing 0 on orientation would corrupt
genuine near-vertical responses. It cannot: max `target_angle` in the
experimental blocks is 61°, and of the 1430 block rows with
`response_angle == 90`, **none** has a target within 20° — the minimum
error is 29°. A 90° response is never near-correct, so nothing is lost by
forcing it to 0, and all three features can take the same rule instead of
per-feature special-casing. Word reaches 0 by construction anyway under
§2's formula (the distance equals `nchar(target)`, is capped there, and
the subtraction yields 0); colour's 999 must be special-cased regardless,
since it is not an angle and would otherwise enter the cosine as 279°.

Note that for orientation, `responded_angle` is an *inference*
(`response_angle != 90`) rather than an observation, unlike word and
colour. That asymmetry belongs in the roxygen and in the codebook.

**Separate finding, for exclusion review rather than scoring:** one
participant has a 100% orientation non-response rate — never touched the
slider across all 21 block trials — and the 90th percentile across
participants is 0.80. Under this rule they would acquire a mean
orientation score of exactly 0, which reads as "maximally poor
orientation memory" when the truth is "no orientation data at all". They
should be raised in `data-raw/review/` rather than allowed to become a
silent zero.

## 3. Standardisation: same range isn't same meaning

Same numeric bounds don't guarantee equal difficulty or equal diagnosticity.
A 0.1-unit change in word similarity and a 0.1-unit change in colour
similarity could reflect very different empirical variances or difficulty
curves in the actual sample. To compare relative standing meaningfully,
**z-score each feature's similarity score across participants**, so
comparisons are relative to each feature's own empirical distribution rather
than raw similarity units.

**Decision made 2026-08-04: standardise per version (v1/v2/v3), not
pooled**, consistent with the OSF wiki's own position that version is a
structural factor of the design, not a nuisance covariate — task mechanics
(fixed vs. randomised response order, parity penalty present/absent) differ
enough by version that pooled standardisation could mix genuinely different
distributions.

**Resolved 2026-08-20 by scope rather than by method:** with v1 as the
primary analysis sample (`02-pooling-strategy.md` §3.5), there is only one
version in the inferential analyses, so per-version standardisation
reduces to standardising within v1 and the small-N problem below no longer
bites. The shrinkage fallback is not needed. Standardisation is still
required for cross-*feature* comparability, which is a separate matter
from cross-version comparability and is unaffected. The caution below is
retained as the record of why v2 could not have carried its own scale, and
becomes live again if later versions are ever analysed on their own.

**Original caution, now historical:** v2 (N=9) and v3 (N=21, still growing) are
small for per-version standardisation. A z-score computed on 9 people is
noisy, and outliers will have outsized influence on the resulting scale for
the whole version. Needs a concrete check once real data is in hand —
possibilities to weigh at implementation time (not decided here): shrinkage
toward the pooled distribution for small-N versions, flagging
version-specific standardisation as provisional until v3 grows further, or
reporting both pooled- and per-version-standardised results side by side for
the small versions. Don't resolve this in the abstract — look at the actual
v2/v3 distributions first.

**Second open issue, found 2026-08-20: one participant is in two
versions.** `all_data` has 117 unique `id` values but 118
`id`-by-`version` units — `ckmw15672323159356eazf` completed the task
twice, once in v1 and once in v3, with full data and different totals
(`feedback_total_score` 143.5 vs 110.5). No review CSV flags this, and the
duplicate-resolution logic in `data-raw/` did not catch a cross-version
repeat because it looks within versions.

Per-version standardisation currently treats him as two independent people,
which he is not: the v3 attempt is by someone who has already done the task.
At N=88 and N=21 the effect on the z-scales themselves is small, but the
non-independence is real and would also violate the exchangeability
assumption of any pooled model in `05`/`06`/`07`. Options: drop the v3
attempt (keeps the larger, earlier sample intact, costs 1 of 21 in the
smallest version), drop the v1 attempt, keep both and add a random effect
for `id` that spans versions, or keep both and note it.

**Settled 2026-08-20: keep both, document it, and run a leave-one-out
sensitivity check when the main analyses run.** Two reasons the other
options lose.

A random effect on `id` spanning versions is *unidentifiable* here. With
exactly one repeated id, no data informs the between-versus-within-id
variance component; the term would be carried by every downstream model
while being estimated from nothing.

And the practice-effect argument for dropping the v3 attempt is not
supported by his numbers. In v1 he was well above cohort on all three
features (mean `live_diff_word` 0.120 vs cohort 0.130, angle 0.134 vs
0.197, colour 0.147 vs 0.239 — lower is better). In v3 he fell to
slightly *below* cohort on word (0.258 vs 0.233) and his word
non-response rate rose from 6.3% to 17.5%. That is a second pass taken
with less effort, not one that benefited from familiarity, so dropping it
would cost 5% of the smallest version to remove a confound the data does
not show.

Revisit if v3 grows and further repeats appear — the pseudonymisation
mechanism is shared across the whole study ecosystem, so cross-study
repeats are plausible and worth checking for directly.

For clustering specifically, standard practice before any distance-based
clustering is to standardise inputs onto a common scale regardless — this
requirement would exist even independent of the cross-feature comparability
problem above.

## 4. What each downstream strand actually needs

The three strands don't need identical things from "comparable":

- **Performance modelling:** doesn't strictly require cross-feature
  comparability if modelled as a multivariate/multilevel outcome with
  feature-specific structure (feature as a fixed effect, feature × group
  interactions, each feature keeping its own natural error distribution).
  Comparability is a nice-to-have for interpretation here, not a modelling
  requirement. Natural-unit (non-standardised) scores are plausibly the
  right input.
- **Compositional analysis:** _requires_ comparability before normalising
  into proportions — proportions computed from raw values on mismatched
  scales are dominated by whichever feature has the larger raw range.
  Standardised scores are the right input.
- **Clustering:** also requires comparability, same reason — an unstandardised
  distance-based clustering is dominated by the highest-variance input
  feature. Standardised scores are the right input.

**Decision made 2026-08-04: keep both the raw [0,1] similarity columns and
the per-version-standardised columns**, rather than discarding the raw
scores after standardising. Performance modelling can use natural units;
compositional/clustering use standardised. Also useful for exploratory
plotting regardless of which model ends up used.

## 5. Mixture-model precision (bmm) — parked, not adopted for this pass

**Amendment 2026-08-20: the parking decision stands, its stated reason
needs correcting.** This section treats mixture modelling as an unrelated
parallel track. The relationship is closer than that. `bmm`'s
continuous-report models decompose a response into target recall, guessing
and swap errors — but each of those states **is a response**, with an
angular error to attribute. Abstention, which accounts for 9–19% of trials
(`08-response-propensity.md`), is a fourth state the mixture cannot
represent, because there is no report to decompose.

A hurdle gate is the natural place for it, and it **composes** with a
mixture rather than competing: gate on responding, then decompose the
responses that exist. `05-performance-modelling.md` §3.1 adopts exactly
this structure for the performance model, on independent grounds.

The obstacle this section parks `bmm` on — per-participant trial counts —
is unchanged by the gate, so the decision not to adopt it this pass is
unaffected. But "parked as unrelated" is no longer an accurate
description, and if the trial-count problem is ever revisited, the gate is
where abstention belongs rather than being dropped or treated as a guess.

Raised as an alternative to raw/cosine-similarity scoring for colour and
orientation: rather than a single error-derived number, fit a hierarchical
Bayesian mixture model (Zhang & Luck-style; implemented in the `bmm` R
package, built on `brms`) that decomposes the error distribution into a
**precision** parameter (SD of the memory-guided response component) and a
**guess-rate** parameter (proportion of trials that are effectively random).
This separates "imprecise every time" from "sometimes perfect, sometimes a
pure guess" — two different cognitive stories that a single mean-error
number conflates, and plausibly a more theoretically meaningful distinction
for a memory task where "did they retain anything at all" is itself an
aphantasia-relevant question.

**Why this isn't going into the current pipeline:**

- **Trial-count feasibility is unverified.** Mixture models need enough
  trials per participant per feature to estimate two (or three, with a
  swap-error component) parameters reliably. WM-FTT's per-participant trial
  count for colour/orientation hasn't been checked against this
  requirement. Hierarchical/partial-pooling estimation (which `bmm`
  supports, being brms-based) mitigates this by shrinking noisy individual
  estimates toward the group, but doesn't eliminate the need to check.
- **Modelling scope.** Fitting a full hierarchical mixture model with
  group-level structure is a meaningfully bigger undertaking than the
  cosine-similarity-then-standardise pipeline above — a second modelling
  project, not a drop-in scoring step, and one that would need its own
  design pass given N=118 pooled / N=21 for v3 alone.
- **Doesn't cover word recall.** Continuous-reproduction mixture models are
  built for circular/bounded continuous response spaces (colour wheel,
  orientation). A typed word isn't that kind of response. See §6.

**Not rejected, parked as a legitimate future/parallel track** — potentially
worth revisiting for the thesis chapter (less time pressure than the
poster) or a later paper, once (a) trial counts are checked against
feasibility and (b) the simpler pipeline's results are in hand as a
baseline to compare against.

## 6. Word-recall analog — searched twice, real leads, still no direct equivalent

Searched in two passes: (1) mixture-model / continuous-reproduction
literature directly, (2) signal-detection/diffusion approaches to recall,
and phoneme/orthographic confusability metrics. Findings, stated precisely.

**Mixture-model pass:**

- The `mixtur` package documentation states directly that mixture models
  "for recall tasks require participants to continuously estimate or
  reproduce a feature of the remembered stimuli, limiting this model to
  stimuli with reproducible features (e.g., colour and orientation)" — a
  stated boundary condition from within the field itself, not an inference
  on my part.
- One relevant precedent exists, but it changes what's being measured
  rather than transferring directly: a study modelling memory for word
  lists had participants reproduce a _continuous spatial location_ bound to
  each word (not the word identity itself), then used a mixture model to
  separate precision, binding failure, and guessing on that spatial
  response. Real methodological path, but it decomposes location-binding
  precision, not word-identity recall accuracy.

**Signal-detection/diffusion pass:** returned almost entirely recognition-
memory work (old/new judgments, ROC curves, ROC-based diffusion models) and
source-memory work, not free/cued recall of a specific target word. Not
directly transferable to WM-FTT's word-recall trials, where the response is
an open-ended typed word being compared to a known target, not a binary
old/new decision.

**Phoneme/orthographic confusability pass — two distinct, useful findings:**

- **Edit-distance scoring for span tasks (Gonthier, 2022, _Behavior
  Research Methods_, solo-authored — corrected here; previously misattributed
  to "Guitard et al." in this doc's earlier draft based on an unclear search
  snippet)** is directly relevant and now confirmed against the author's own
  reference materials (OSF archive supplied directly, including R/Python/
  Matlab/VBA implementations and two supplemental-materials PDFs), not just
  a search snippet. Rather than raw partial-credit scoring (which penalises
  positional shifts inconsistently), edit-distance scoring subtracts the
  edit distance from the sequence length, floored at zero. Supplemental
  Materials 1 compares this against six other scoring methods (partial-
  credit, all-or-nothing, lenient, longest-correct-sequence, relative-order,
  input-output-order-correspondence) across two large datasets and finds
  edit-distance scoring performs well across distribution shape, reliability,
  concurrent validity, and IRT information — among the strongest of the
  seven, alongside partial-credit and relative-order scoring. Full exact
  formula now pinned down (§2) rather than approximated. **Scope caveat
  (new):** the paper's own framing and validation is for _serial span_
  tasks (multi-item sequences per trial), not single-word recall trials —
  see the scope note in §2. The technique transfers; the specific
  validation evidence (correlations, reliability, IRT information) was
  established on a different task structure and shouldn't be cited as if it
  directly validates WM-FTT's use case.
- **Phoneme-similarity/confusability metrics** are a real and active area
  (weighting character or phoneme substitutions by perceptual/articulatory
  similarity rather than treating all substitutions as equally wrong), but
  this is a _different kind of tool_ than a mixture model — it refines what
  counts as a "small" vs. "large" edit within the edit-distance metric
  itself, not a decomposition into precision-vs-guessing components the way
  `bmm` separates memory-guided responses from pure guesses on the colour
  wheel. Useful to know exists; not a substitute for the bmm-style
  precision/guess-rate split raised in §5. Worth not conflating the two in
  the writeup — they answer different questions.

**Conclusion, revised after second pass and after direct access to the
Gonthier OSF materials: no mixture-model equivalent operating directly on
word-identity space was found** across two search passes, and the field's
own stated position (`mixtur` docs) is that this class of model doesn't
extend to word recall as constructed. What _did_ come out of this pass is a
confirmed, precisely-specified improvement to the §2 word-scoring approach:
the exact edit-distance-scoring formula (Gonthier, 2022), now pinned down
against the author's own reference code rather than a paraphrase, with an
explicit scope caveat that its validation evidence is for serial-span tasks
and WM-FTT's single-word-per-trial use is an adaptation, not a like-for-like
application. **Action: implement §2's word formula exactly as specified
above, cite Gonthier (2022) with the serial-span scope caveat stated
explicitly in the methods text, not glossed over.**

If mixture-model precision (§5) is revisited later for colour/orientation,
word recall would stay on the edit-distance-based scoring approach
regardless — an intentionally asymmetric pipeline across features, which is
a real interpretive cost worth naming explicitly if it happens, not
something to gloss over.

## 7. Summary of decisions

| Decision                          | Choice                                                                                    | Status                                |
| --------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------------------- |
| Word raw→similarity               | Edit-distance scoring (Gonthier, 2022), formula confirmed against author's reference code | Settled, cite source + scope caveat   |
| Colour/orientation raw→similarity | Cosine-based, respects circularity                                                        | Settled                               |
| Existing pipeline's Levenshtein variant (`live_diff_word`) | Not an edit distance — broken DP initialisation in `utils.js` (§1.5) | Resolved 2026-08-20, supersedes earlier "plain Levenshtein" finding |
| Compute from scratch vs. reuse/transform existing `diff_*` columns | From scratch; reuse impossible for word, pointless for colour/orientation (§1.5) | Settled 2026-08-20 |
| Direction convention (`score_*` vs `live_diff_*`) | Both kept, names carry the direction, nothing inverted (§1.5) | Settled 2026-08-20 |
| Live-feedback columns renamed `feedback_*` / `live_diff_*` | Done, with rationale in `R/data.R` | Implemented (session step 1) |
| Tutorial rows                     | Excluded — values are hardcoded placeholders (§2.5.1)                                     | Settled 2026-08-20                    |
| Training rows                     | Score them, filter at analysis time (recommended)                                         | **Open — needs the author's call**          |
| Non-response handling             | Score 0 + companion `responded_*` logicals (recommended, §2.5.2)                          | **Open — needs the author's call**          |
| Participant present in v1 and v3  | Four options weighed (§3)                                                                 | **Open — needs the author's call**          |
| Standardisation grouping          | Per version (v1/v2/v3)                                                                    | Settled, with small-N caution flagged |
| Keep raw similarity columns       | Yes, alongside standardised                                                               | Settled                               |
| Mixture-model precision (bmm)     | Parked as future/parallel track                                                           | Not adopted this pass                 |
| Word-recall mixture-model analog  | Open gap, no equivalent found                                                             | Unresolved                            |

## 8. Next steps (not this doc)

- Check WM-FTT's actual per-participant, per-feature trial counts against
  mixture-model feasibility, if/when §5 is revisited.
- Implement `compute_scores()` (or similar) in `aphantasiaWMStrats`:
  raw similarity columns (§2) + per-version-standardised columns (§3),
  keeping both (§4).
- `inst/scripts/` — small test script running the new function against
  real `all_data`, plus a distribution-plotting script (raw vs.
  standardised, by version, by feature) to sanity-check before anything
  downstream depends on it.
- Possible EOR page: this scoring design is plausibly substantial enough
  to warrant its own page in the aWMS EOR site (rationale, formulas,
  distribution plots, the parked bmm discussion) — flagged here, not
  decided; revisit once the EOR build itself is scoped.
