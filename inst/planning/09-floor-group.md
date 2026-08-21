# WM-FTT: the floor-group model

**Status:** implemented and run on v1 (`inst/scripts/04-floor-group.R`);
results below. Exploratory, and explicitly so, for reasons given in §3.

**Context:** this began as §2.6 of `03-validity-checks.md` and was moved
out. It asks whether complete aphantasia behaves as a distinct group
rather than as the low end of a continuum. That is a claim about people,
not about whether the instrument works, and a null result here would not
make anyone doubt WM-FTT. It is analysis, and `03` is validity only.

It sits alongside `02-pooling-strategy.md` and `04-parity-engagement.md`
as a **cross-cutting decision about how one variable enters every model**,
rather than belonging to any single analytical strand. VVIQ is a predictor
in the performance model (`05`), the compositional model (`06`) and the
propensity analysis (`08`); if its floor group behaves differently, all
three need to know, and burying that in one of them would mean the other
two either duplicate it or silently ignore it.

**Precedent:** `aphantasiaEmotions` fits the same model to a pooled
five-study sample (N = 1478), on the same grounds. Using one idiom across
the thesis has value beyond this chapter, and the differences in what the
two samples can support are set out in §3.

---

## 1. The model, and why it is asymmetric

The idiom already exists in this project:
`aphantasiaEmotions` fits a *floor-group model* to the pooled five-study
sample, on the grounds that VVIQ's distribution is not smoothly continuous
and complete aphantasics pile at the scale floor. The same question
applies here, and using the same modelling idiom across the thesis has
value beyond this chapter.

## 2. Results

**The premise holds, and more strongly than in the pooled sample.** v1's
VVIQ distribution is close to bimodal:

| VVIQ band | n |
|---|---|
| 16 (floor) | 20 |
| 17-25 | 7 |
| 26-40 | 7 |
| 41-60 | 27 |
| 61-80 | 25 |

Twenty-three percent sit at exactly 16, the middle of the range is nearly
empty, and 52 of 86 sit above 40. A floor group treated as its own
quantity is better justified here than a smooth gradient would be.

**Structure.** As in `aphantasiaEmotions`: `outcome ~ vviq +
complete_aphant`, where `complete_aphant` marks VVIQ = 16. The asymmetry
is deliberate and is the point: the floor group has no VVIQ variance among
themselves, so no group-specific slope is identifiable, but a single
offset is. The study-level random effects from the original are dropped,
since there is one study here.

**Result, accuracy (responded trials only, threshold-clearing):**

| Feature | Above-floor slope | Floor offset | 95% CI | p |
|---|---|---|---|---|
| Word | +0.0004 (p = .24) | +0.032 | [-0.003, +0.066] | .069 |
| Orientation | +0.0002 (p = **.79**) | -0.052 | [-0.134, +0.031] | .216 |
| Colour | -0.0002 (p = .74) | **-0.069** | [-0.139, +0.001] | **.054** |

**This changes how §2.4's orientation result should be described.** Adding
the floor term collapses orientation's continuous VVIQ slope to
essentially zero (p = .79). The association reported in §2.4
(rho = +0.223, p = .047) is therefore not evidence of a gradient in
imagery vividness; whatever signal exists is a contrast between the floor
group and everyone else. And the offset itself does not reach
significance (p = .216), because splitting a modest effect into two
components leaves neither individually detectable at n = 19 against 61.
The honest statement is weaker than §2.4 alone implies, and §2.4 has been
annotated accordingly.

**Colour is where this adds something.** Its floor offset is -0.069
(p = .054): complete aphantasics score below where the above-floor line
predicts. This is on *responders-only* accuracy, so it is not the artifact
§2.4 identified. Meanwhile colour's reporting propensity stays continuous
(above-floor VVIQ slope p = .002) with no floor offset (p = .33). The two
quantities have different structure on the same feature.

## 3. Caveats, in order of weight

**The extrapolation is fragile.** Above-floor median VVIQ is 56 and only 14
of 66 sit below 40, so "the relationship fit on everyone else" is a line
anchored by a cluster at 50-80 plus a scatter of points. Extending it down
to 16 rests on a linearity assumption this sample barely constrains.
`aphantasiaEmotions` had N = 1478 across five studies to support the same
move; here there are 86 participants.

**Power.** The confidence intervals comfortably contain both nothing and a
moderate effect.

**Provenance.** This model was fitted **after** seeing §2.4's result. That is
a legitimate thing to do and an illegitimate thing to describe as
pre-specified. It is exploratory, and the writeup must say so.

**Not applicable to v2 or v3.** The model needs both a floor group and a
populated above-floor continuum. v3 is 17 aphantasia to 4 typical and v2 is
8 to 1; neither can support an above-floor line at all. This is a v1-only
check by construction, not merely by the scope decision in
`02-pooling-strategy.md` §3.5.

**Reading:** the floor group may differ on colour recall accuracy, in a
sample too small to establish it; and §2.4's orientation effect is a
group difference rather than a continuous one. Both belong in the writeup
as exploratory observations that motivate a better-powered test, not as
findings.

## 4. Consequences for the other docs

- **`03-validity-checks.md` §2.4** is annotated to point here, since its
  orientation result is a group contrast rather than a gradient.
- **`05-performance-modelling.md`** should decide whether VVIQ enters its
  models as a continuous predictor alone or with the floor term. On these
  data the continuous term does no work once the floor term is present.
- **`06-compositional-analysis.md`** §5 regresses composition against
  continuous VVIQ. Same question applies.
- **`08-response-propensity.md`** is the one place the continuous form
  survives: colour propensity keeps its above-floor VVIQ slope
  (p = .002) with no floor offset (p = .33).

## 5. Open questions

- Whether to refit in `brms` with the ROPE-based reporting
  `aphantasiaEmotions` uses. The frequentist `lm` is adequate for an
  exploratory check, but "no effect established" is a claim Bayesian
  intervals state more honestly than a non-significant p-value does, and
  it would match the published idiom.
- Whether the floor term belongs in the downstream models by default or
  only as a sensitivity check (§4).
- Whether a better-powered test is possible at all without a sample built
  for it, given the fragility described in §3.
