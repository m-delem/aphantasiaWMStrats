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
half negative and therefore impossible for any log-ratio transform (`06`
§7); a reported association between reporting propensity and imagery
dissolved once stratified by version (`08` §3.1); a variance asymmetry
that shaped a whole section turned out to rest on six low-engagement
participants (`06` §13.2). Publishing only the corrected version would
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
between documents in the past (`09` began as `03` §2.6). Citations in the
package code point at the numbering as of the commit that introduced them.

## Contents

| Doc | Subject |
| --- | --- |
| `INDEX.md` | Entry point: dependency graph, per-doc summaries, house rules |
| `00-analytical-philosophy.md` | Performance versus compositional framing, and the three-strand plan |
| `01-score-computation.md` | Turning raw responses into per-feature scores |
| `02-pooling-strategy.md` | Which task versions enter the analysis, and how |
| `03-validity-checks.md` | Reliability and construct validity, as preconditions |
| `04-parity-engagement.md` | The secondary task, and what it measures in each version |
| `05-performance-modelling.md` | Absolute per-feature performance |
| `06-compositional-analysis.md` | Relative allocation, ILR coordinates, and its implementation record |
| `07-clustering-analysis.md` | Unsupervised profiles, and the held-out validation logic |
| `08-response-propensity.md` | Non-response as its own quantity, not missing data |
| `09-floor-group.md` | Whether complete aphantasia behaves as a group or a scale end |
