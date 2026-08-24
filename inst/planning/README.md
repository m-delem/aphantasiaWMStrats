# Planning documents

This folder holds the analysis plan for the WM-FTT study, as it was
actually arrived at: eleven working documents recording what was decided,
why, what was reversed, and what remains open.

**Start with [`INDEX.md`](INDEX.md).** It carries the dependency graph, a
one-paragraph summary of each doc, the cross-doc questions that recur, and
the house rules that apply to any session working on this pipeline.

## Why these are published

The package's pkgdown site is the public account of what the analysis
found. This folder is the public account of how the analysis was decided,
which is a different and usually invisible thing. Several decisions here
were made, tested against real data, and reversed: the compositional
input scores were specified as standardised and then found to be roughly
half negative and therefore impossible for any log-ratio transform (`11`
§7); a reported association between reporting propensity and imagery
dissolved once stratified by version (`04` §3.1); a variance asymmetry
that shaped a whole section turned out to rest on six low-engagement
participants (`11` §13.2). Publishing only the corrected version would
hide the part that was hardest to get right.

They are also the working context for the analysis itself. The scripts in
`inst/scripts/` cite these documents by number and section, so a reader
checking whether an exclusion rule was fixed before or after the result
was seen can follow the citation and find out.

## What they are not

They are working documents, not a manuscript. They argue with themselves,
they contain open questions that may never be closed, and they are written
in the register of notes to a collaborator rather than of a methods
section. Where a doc and the published analysis disagree, the published
analysis is what the study claims.

Section numbers are stable within a document but sections have moved
between documents in the past (`08` began as `06` §2.6). Citations in the
package code point at the numbering as of the commit that introduced them.

## Contents

Numbered by analytic dependency: what has to be settled before the next
thing can be. Chronology is in `CHANGELOG.md`.

| Doc | Subject |
| --- | --- |
| `INDEX.md` | Entry point: dependency graph, per-doc summaries, house rules |
| `CHANGELOG.md` | What changed when, and in what order |
| `00-framing.md` | Why the study is framed as it is |
| `01-task-design.md` | The paradigm, its incentive structure, version history |
| `02-score-computation.md` | Turning a response into a score |
| `03-parity-engagement.md` | The secondary task, and what it measures in each version |
| `04-response-propensity.md` | Abstention as a substantive variable, not missing data |
| `05-version-scope.md` | Which task versions enter the analysis |
| `06-task-validity.md` | Whether the task measures anything stable |
| `07-questionnaire-psychometrics.md` | Whether the instruments do |
| `08-predictor-form.md` | How imagery vividness enters any model |
| `09-joint-model.md` | **Primary.** Propensity and accuracy across three features |
| `10-performance-modelling.md` | Absolute per-feature performance, as a check |
| `11-compositional-analysis.md` | Relative allocation, as a complement |
| `12-scale-structure.md` | Relationships among the questionnaire scales |
| `13-clustering.md` | Unsupervised subgroups |

Docs `01`, `07` and `12` are stubs. They exist because the new ordering
made the gaps visible, and an empty numbered file is more honest than a
missing number.
