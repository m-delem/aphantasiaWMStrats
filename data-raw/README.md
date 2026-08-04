# `data-raw/`

This folder holds the scripts that turn CFA-WM's raw data (three versions,
two different storage locations) into `all_data`, the single analysis-ready
tibble shipped with the package as `data/all_data.rda`. It follows the
standard `usethis`/`devtools` convention: everything here is source, nothing
here is loaded when someone does `library(aphantasiaWMStrats)` - only the
final `data/*.rda` objects are. If you're trying to *use* the package's data,
you want `?all_data`, not this folder. If you're trying to understand *how*
that data was built, re-run the pipeline, or add a new participant batch,
you're in the right place.

## Why this exists

CFA-WM is a working-memory task that went through three versions - v1
(original), v2 (added a parity-error penalty), v3 (added recall-order
randomisation, moved to its own dedicated OSF component). v1/v2 data was
already processed upstream by a sibling package, `aphantasiaStudiesData`
(aSD); v3 data arrives as raw JATOS export and needs its own parsing. The
scripts here converge both into one comparable shape, apply a documented,
auditable exclusion process, and produce one combined dataset.

## The pipeline, in order

Run these from the package root (`Rscript data-raw/01_import_v1v2_osf.R`,
etc.), always in numeric order - each script consumes files the previous
one wrote to `inst/extdata/`.

### `01_import_v1v2_osf.R`
Pulls aSD's already-processed v1/v2 data
(`expe_working_memory_data.rda`, `common_survey_data_full.rda`) from the
umbrella project's general OSF Data component. Requires OSF credentials
(`osfr` auth) to actually hit the network; the two `.rda` files it produces
are checked into `inst/extdata/` so the rest of the pipeline can run without
re-downloading every time.

### `02_import_v3_raw.R`
Downloads v3's raw JATOS zip from CFA-WM's own OSF component, unzips it,
and resolves per-participant duplicate component entries (caused by page
reloads during the experiment) using a different strategy per component
type; completeness-based for the main task, "yes wins" + concatenation
for feedback flags/free text, fill-gaps-from-other-attempts for
questionnaires, most-complete-wins for general data. Writes
`inst/extdata/cfa_v3_raw_extracted.rds` (still raw/JSON-shaped, one list
entry per participant) and `data-raw/review/excluded_incomplete_v3.csv`
(participants who never reached, or didn't finish, the main task; has to
happen here, not later, since the raw trial counts aren't recoverable once
script 3's completeness filter has run).

### `03_create_package_data.R`
The main conversion. Two parts:
- **Part A (v1/v2)**: joins in the extra columns aSD keeps separate,
  computes VVIQ groups and NIEQ dimension scores, nests raw questionnaire/
  strategy items into list-columns, filters to complete desktop-only
  attempts. Produces `df_v1v2_nested`.
- **Part B (v3)**: flattens each participant's raw nested JSON into one row
  per stimulus (`tidyr::hoist()` + `unnest_longer()`),
  scores questionnaires the same way as Part A, converts index-array
  response orders into readable strings. Produces `df_v3_nested`, with the
  same unnested column set as Part A.

Both `df_v1v2_nested` and `df_v3_nested` are saved to
`inst/extdata/df_*_nested.rds` for script 4 to pick up, and both parts write
a pair of review CSVs to `data-raw/review/` (see below).

### `04_apply_manual_review.R`
Reads the review CSVs from script 3, cross-references them against
`data-raw/review/manual_decisions.csv` (a small, hand-maintained,
checked-in file - see below), resolves a final include/exclude call per
flagged participant, applies it, combines `df_v1v2_nested` and
`df_v3_nested` into one tibble, trims the columns that were only needed for
cleaning, and saves the result as `all_data` via `usethis::use_data()`.
This is the package data build step: its output is what the package
actually ships.

### `05_export_data_and_doc_to_osf.R`
Not part of the package build (nothing here feeds back into `all_data` or
anything under `R/`), but a one-way export step for sharing `all_data`
outside the package. Two things happen here:

- **Data export.** Produces two datasets, each as `.csv` and `.xlsx`:
  `all_data_surveys` (one row per participant - trial/stimulus-level
  columns dropped, nested item list-columns unnested wide by name) and
  `all_data_full` (`all_data` at full stimulus-level granularity, nested
  list-columns dropped rather than unnested, to avoid repeating
  participant-level questionnaire items across every stimulus row).
- **Codebook generation.** Documents both of the datasets above - not
  `all_data` itself, since that's the package's internal object and isn't
  something an OSF visitor without the package can use directly (`all_data`
  gets its own, lighter documentation in `vignettes/articles/codebook.Rmd`
  on the EOR instead). Produces `codebook.md` (human-readable, every
  variable's description/type/range/levels, computed live from the actual
  data rather than typed by hand) and `dataset_description.json`
  ([Psych-DS](https://psych-ds.github.io/)-compliant, machine-readable).

`codebook.md` is **not** rendered to PDF by this script; it is meant to be
rendered and then upload the resulting `codebook.pdf` to OSF manually; it isn't 
part of the automated push below.

Files are written locally to `data-raw/exports/` (gitignored) and then
pushed to CFA-WM's OSF component (`3649s`), in a `v3 Data/Processed data`
sub-folder: the four data files plus `dataset_description.json`, five
files total. `codebook.pdf` is uploaded separately, by hand, once
rendered. Requires OSF write credentials for that component, not just
read.

## The review files, and why there are two kinds

`data-raw/review/` has two categories of file that behave very differently:

**Regenerated every run** (never hand-edit these - your edits will be
silently overwritten next time you run script 3):
- `excluded_incomplete_v3.csv` - v3 participants dropped for incompleteness
- `flagged_participants_v1v2.csv` / `flagged_participants_v3.csv` -
  participants who answered "yes" to a self-report flag
  (`used_external_support`, `gave_false_info`, `met_issues`), with a
  computed `default_decision` (`used_external_support == "yes"` defaults to
  exclude; the other two default to include, since a "yes" there doesn't
  always mean something exclusion-worthy happened - free-text context is
  attached so you can judge)
- `missing_flag_data_v1v2.csv` / `missing_flag_data_v3.csv` - participants
  who never reached these mandatory questions (closed the tab early),
  surfaced separately so a real missing answer isn't confused with a clean
  "no"
- `final_decisions.csv` - script 4's output: every flagged participant,
  their default decision, whether a manual override exists, and the
  resulting `final_decision`. This is a review artifact for you to audit,
  not an input to anything downstream.

**Hand-maintained, checked into git, survives every re-run:**
- `manual_decisions.csv` - this is the *only* file in this folder you
  should ever hand-edit. One row per participant you've actually reviewed
  and made a real call on, with columns `id`, `version`, `decision`
  (`include`/`exclude`), `note` (your reasoning), `decided_date`. Starts
  empty. A row here always overrides the corresponding `default_decision`;
  anyone flagged but not yet in this file just falls back to the default.
  Append to it as you review people - don't reorder or delete past entries
  without good reason, since it's meant to be an audit trail.

If script 4 finds an entry in `manual_decisions.csv` that no longer matches
anyone currently flagged (typo, or the participant dropped out after a data
re-pull), it warns rather than fails - check the warning message before
trusting `all_data`.

## Re-running the whole pipeline

```r
# from the package root
source(here::here("data-raw/01_import_v1v2_osf.R"))   # needs OSF credentials
source(here::here("data-raw/02_import_v3_raw.R"))     # needs OSF credentials
source(here::here("data-raw/03_create_package_data.R"))
source(here::here("data-raw/04_apply_manual_review.R"))
```

If you're only iterating on cleaning logic and already have
`inst/extdata/*.rda`/`.rds` from a previous run, you can skip 01/02 and
start from 03. `manual_decisions.csv` is untouched by any of this, so
re-running the whole thing from scratch does not lose review history.

Script 5 (`05_export_data_and_doc_to_osf.R`) is separate from the core
pipeline above - it doesn't touch `all_data` or anything the package
ships, it only reads the already-built `all_data` to produce OSF-facing
exports and their codebook. Run it on its own, after 01-04, whenever you
want to refresh what's shared on OSF:

```r
source(here::here("data-raw/05_export_data_and_doc_to_osf.R"))  # needs OSF write credentials
```

Note this needs *write* access to the CFA-WM OSF component, not just the
read access 01/02 use.
