# todo_0.3.5.md — surveyframe v0.3.5: Field validation

Dev-only planning file, tracked on `dev` only. Its name is in `.gitignore`
and `.Rbuildignore`. Companion to `CLAUDE.md`, `dogfeed.todo.md`, and
`../portfolio-planner/development_instructions/19_v034_v035_implementation.md`.

Last updated: 2026-07-25. Target CRAN submission: 2026-09-15. Redefined
2026-07-17 when the statistics scope moved into 0.3.4: **strict patch
scope, no planned new features.** Fixes and polish only, driven by what
the field surfaces. Starts once 0.3.4 is accepted by CRAN.

---

## The two feedback streams

1. **ICSRI 2026 audience feedback** (Villa College, 8-9 August 2026,
   AIC-RSAM presentation). Owner captures feedback at the conference;
   every item lands in `dogfeed.todo.md`, one entry each, status
   `open`, before any triage.
2. **Human testing rounds**: design, deploy, answer, and analyse 3 to 5
   short real surveys end to end (owner plus recruited testers),
   covering the surfaces that changed most in 0.3.4: the builder
   rework, the Interpretations canvas, PDF report output, and the
   date-bounds path. Findings into `dogfeed.todo.md` as they come in.

## Process rules (binding)

- **Dogfeed protocol applies:** while a feedback session is open, no
  source file is edited. Log only. Triage starts on explicit
  "dogfeed is complete".
- Triage every item to: fix here (patch scope), version-target against
  `roadmap.md` (out of patch scope), or wontfix with a reason. Patch
  scope means: no new exports, no new dependencies, no changed
  function signatures, existing tests unmodified (additions fine).
- Anything statistical or structural that feedback surfaces gets logged
  against 0.4+ — the 0.4 file already exists (`todo_0.4.md`); append a
  "field-sourced" subsection there rather than expanding this release.
- Each fix follows the mas_review pattern established in 0.3.3/0.3.4:
  reproduce first (chromote for UI items), fix, verify headlessly,
  record in the review file (`mas_review_035.md` when the round
  starts, modelled on `mas_review_034.md`).

## Release process

Tarball rebuild, `mas_review_035.md` rounds, `devtools::document()`,
full suite, `R CMD check --as-cran` 0/0/<=1 NOTE, win-builder release
and devel, `cran-comments.md`, NEWS.md as a clean per-release
changelog, CRAN submission by 2026-09-15. Mind CRAN's 1-2 month
release-spacing preference relative to the 0.3.4 acceptance date; if
the gap would be under a month, hold the submission, not the fixes.

## Delegation and token budget

Small release, small crew: the lead triages and fixes; one Haiku agent
runs verification sweeps (tests, document, knit, axe-core re-runs on
touched surfaces); one Sonnet agent at most for a batch of independent
low-risk fixes, briefed per item from the dogfeed entries. Token rules
from `todo_0.4.md` apply. No parallel fan-out: patch fixes conflict on
the same files too often to be worth it.
