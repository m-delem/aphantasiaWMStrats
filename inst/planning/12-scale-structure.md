# WM-FTT: structure among the questionnaire scales

**Status: planned, not implemented.** Exploratory strand, and the first
step of the unplanned-groups arc that `13-clustering.md` continues. This
doc is written to be picked up by a session that has not seen the rest,
so it states its own rationale rather than pointing elsewhere.

## 1. Why this comes before clustering

`13` clusters participants on subjective measures and holds behavioural
data back as validation. That design has a hole in it that this doc is
meant to close: **which subjective measures, and why those.**

Feeding every available scale into a clustering algorithm has two failure
modes. Redundant scales silently get extra weight, because two instruments
measuring the same construct contribute twice to the distance metric. And
a scale that fails its own reliability check contributes noise that the
algorithm will happily find structure in. `07-questionnaire-psychometrics.md`
records that NIEQ sensory focus sits at 0.49 and that the VVIQ/OSIVQ
pattern test fails, so both failure modes are live here rather than
hypothetical.

The deliverable is therefore not "a correlation figure". It is **a
defensible feature set for `13`, decided before `13` runs**, with the
reasoning written down.

## 2. What is available

- **VVIQ**: imagery vividness. **In the feature set, not held out.**
  Holding it out answers "do the other scales predict imagery", which is a
  different and less interesting question than "is there structure beyond
  imagery". To see whether clusters add anything to VVIQ, VVIQ has to be
  in the space they are found in.
- **OSIVQ**: object, spatial and verbal subscales. The verbal subscale is
  of direct interest given the verbal-compensation hypothesis, and the
  reverse-keying inconsistency across versions has to be resolved before
  it is used.
- **NIEQ**: five dimensions, including unsymbolised thinking, hypothesised
  higher in aphantasics. Sensory awareness is the weak one.
- **TAS-20**: DIF, DDF and EOT subscales. Alexithymia, and the link to
  imagery is the subject of the sibling package `aphantasiaEmotions`, so
  there is prior work to be consistent with.

## 3. What to actually do

**Build the imagery composite first.** Three instruments measure imagery
vividness here, in three formats, and they converge hard:

| Spearman | VVIQ | OSIVQ-object | NIEQ imagery |
|---|---|---|---|
| VVIQ | 1.00 | **0.86** | **0.87** |
| OSIVQ-object | 0.86 | 1.00 | **0.86** |
| NIEQ imagery | 0.87 | 0.86 | 1.00 |

Alpha 0.97 on 114 participants, against discriminant correlations of 0.15
to 0.38 for OSIVQ spatial and verbal. That is one construct measured three
ways, and it is a composite whether or not one is built: left as three
features it triple-weights imagery in any distance metric. The precedent
is the first published clustering study, which merged VVIQ with
OSIVQ-object.

**NIEQ unsymbolised and inner voice are where "beyond VVIQ" would live.**
They sit at -0.40 and -0.37 against the imagery scales: clearly related,
clearly not the same thing, and negative in the direction the hypothesis
predicts.

**Partial correlations next, not raw ones.** Raw correlations among
overlapping instruments are close to unreadable: everything correlates
with everything because everything shares a general factor. The partial
structure is what says whether NIEQ unsymbolised thinking carries anything
OSIVQ verbal does not.

**Then a decision about redundancy**, made explicitly. Two scales
correlating at 0.8 are one feature, and which one survives is a
substantive choice about which construct the study is about, not a
statistical one.

**Dimension reduction only if the partial structure justifies it.** If the
scales are largely independent, reduction destroys the very distinctions
the clustering is supposed to find. If they collapse onto two or three
components, that is worth knowing and worth clustering on instead of the
raw scales. Decide from the structure; do not run a PCA by default.

**A held-out statement.** Name, in this doc, which variables `13` may use
and which are reserved for validation. Behavioural data is the held-out
set; the questionnaires are the feature set. That is what makes `13`'s
validation logic non-circular, and `13`'s own §6 records that this is the
third attempt at getting that logic right.

**A criterion for "the clusters add something", fixed before `13` runs.**
With imagery in the feature set, clustering could simply recover the VVIQ
grouping. Cross-tabulate clusters against VVIQ groups and report the
agreement. High agreement is a reportable null: the structure is imagery,
and nothing else. The interesting outcome is **clusters that split the
floor group**, for instance complete aphantasics high versus low on
unsymbolised thinking, because that is a distinction the confirmatory
strand cannot make at all. Naming it now is what stops the eventual result
being described as whatever it turns out to be.

## 4. Sample

Same question as everywhere else: v1 only, or all participants with
questionnaire data? Unlike the modelling docs, this strand does not touch
task behaviour, so version is not obviously a constraint and the larger
sample is available. **Not decided.** It should be, before anything is
run, and the argument in `05-version-scope.md` §3.5 does not automatically
transfer because it is about task comparability rather than questionnaire
comparability.

## 5. What would make this worth a section in the EOR

An honest possible outcome is "the scales are moderately correlated,
nothing surprising, here is the feature set for the next page". That is a
perfectly good result and should be reported in a paragraph rather than
inflated.

The outcome that would be genuinely interesting: **unsymbolised thinking
carrying variance that neither OSIVQ verbal nor VVIQ explains.** That
would be direct evidence for the verbal-compensation account being about
something other than verbal imagery, which is a claim the confirmatory
strand cannot make from task data alone.

## 6. Standing constraint

Exploratory throughout, and every page and paragraph says so. The
confirmatory strand uses VVIQ-defined groups fixed in advance. Nothing
found here licenses a confirmatory claim, and `13` §1 records what
happened last time an exploratory clustering result was written up in
confirmatory language.
