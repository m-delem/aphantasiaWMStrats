# WM-FTT: task design and history

**Status: stub, created 2026-08-24 during the restructure.** The content
exists but has never been a planning doc: it lives in
`vignettes/articles/task-design.Rmd` and in the version timeline figures.
This file marks the gap rather than hiding it.

Everything downstream depends on facts recorded here, and several of them
have already been rediscovered mid-analysis rather than looked up, which
is the argument for writing it properly.

## What belongs here

- **The paradigm.** Three features (word, orientation, colour) memorised
  per trial under a points-per-feature incentive, with recall of each
  feature optional. The incentive structure is why abstention is an
  allocation decision rather than missing data, which is the premise
  `04-response-propensity.md` §2 rests on.
- **The secondary task.** Parity judgements, their role, and the fact that
  they carry a penalty in v2 and v3 but not in v1. See
  `03-parity-engagement.md`.
- **Version history**, in enough detail to explain why three versions
  exist and what changed between them. `05-version-scope.md` decides what
  to do about it; this doc should say what happened.
- **Trial structure**: 21 test trials of 3 items, recall order, and the
  fixed-order property of v1 that v3 randomised.
- **Known defects.** The edit-distance implementation in the task's
  JavaScript front end has a loop condition that is an assignment, leaving
  the DP matrix half-initialised. Recorded in `02-score-computation.md`;
  the historical account of how it got there belongs here.

## Why it matters analytically

The incentive structure is the reason the study has a compositional
question at all, and the reason non-response is interpretable. A reader
who does not understand the points-per-feature trade-off cannot evaluate
any of the modelling docs.
