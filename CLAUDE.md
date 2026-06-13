# CLAUDE.md — surveyframe project guide

This file orients Claude Code for work on surveyframe across local machine, web,
and mobile. Read it first in any new session. It is tracked in the private
surveyframe-dev repository and excluded from the public CRAN repository.

---

## What surveyframe is

surveyframe is an R package on CRAN. It defines a survey instrument as a typed
`sframe` object that holds the questions, a pre-declared analysis plan, and a
measurement or structural model in one validated, integrity-checked object. The
workflow runs from instrument design through deployment, response collection,
quality checking, scoring, psychometric diagnostics, analysis-plan execution,
and reproducible reporting.

The core idea is a proactive workflow. The instrument is a methodological
contract declared before data collection. Analysis is the execution of that
pre-declared plan rather than a post-hoc search. This is the package's main
differentiator and the thesis of the JSS paper.

Current version: 0.3.1 on CRAN (2026-06-02). 0.3.2 implemented locally — all 7
changes committed and pushed to both remotes, 407/407 tests pass. Awaiting
MAS co-review (see mas_review_032.md in this folder) then R CMD check --as-cran,
win-builder, and CRAN submission.

After 0.3.2 comes 0.3.3 (real-world embedding and conference feedback from the
AIC-RSAM room-service study and the ICSRI 2026 presentation), then a
visualisation patch arc 0.3.4-0.3.9 (six ~21-day releases), then 0.4
(small-sample inference). 0.4.1 is the faculty demo proofing release. The
canonical schedule is portfolio-planner master_roadmap.md.

---

## Ecosystem and how the pieces fit

surveyframe is the source of truth for a wider product and publication set.

- **surveyframe** (public, CRAN): the package itself.
- **surveyframe-dev** (private): the full working repository. Tracks everything,
  including this file, the roadmap, the to-do notes, the JSS paper, and the
  brand sources. Open this repository when working across devices.
- **ethos** (private, JavaScript): a research-workflow product built on
  surveyframe. Calls surveyframe as the engine.
- **ethos-pro** (private, TypeScript): the institutional governance layer on top
  of Ethos. Also depends on surveyframe.
- **asrda-r** (private, R): a prototype provenance package. Deferred. Its
  versioning, review, pilot, and bundle modules are absorbed into surveyframe
  core at v0.8 and v0.9. It will not ship as a CRAN dependency.
- **ASRDA** (private, Quarto book): the methodological textbook, "From Constructs
  to Conclusions Using R." Released in stages that track surveyframe capability.
- **semScreenR** (private, R): a rule-based SEM data-screening package. The
  natural pipeline partner. surveyframe `cfa_syntax()` output feeds semScreenR
  before a lavaan fit. surveyframe gains a bridge to it at v0.6.
- **mcdm** (private, R): a Shiny app with all 10 MCDM methods on a registry
  architecture. The source to port from when MCDM lands in surveyframe core at
  v0.5.
- **small-sample-survey-framework** (public, R) and **smallsamplelab** (private):
  the simulation-validated decision framework for n below 30. The source for the
  small-sample helpers that land in surveyframe core at v0.4.
- **flairmi / flairmi-site**: the commercial umbrella at flairmi.com.

v1.0 of surveyframe is the gate for the public launch of Ethos, Ethos Pro, and
the complete edition of the ASRDA textbook.

---

## Repository and branch model

There is one local working tree with two GitHub remotes.

- `origin` points to the public **surveyframe** repository.
- `private` points to the private **surveyframe-dev** repository.

Two branches keep the public repository clean while the private repository keeps
the planning files.

- `main`: the clean package. Pushed to both `origin` and `private`. The dev-only
  files are gitignored here, so they never reach the public CRAN repository.
- `dev`: the planning superset. Pushed to `private` only. It force-adds the
  dev-only files on top of `main`.

Dev-only files (gitignored on `main`, tracked on `dev`):

- `CLAUDE.md` (this file)
- `roadmap.md`
- `revision_todo_0.3.md`
- `cran-comments.md`
- `todo.md`

Routine work happens on `main`. When the planning files change, switch to `dev`,
merge `main`, update the files, and push `dev` to `private`. To resume planning
on a fresh device, clone surveyframe-dev and check out `dev`.

`.Rbuildignore` excludes all dev-only files and the `jss-paper`, `pkgdown`, and
version-archive directories so the CRAN build never sees them.

---

## Conventions

### Writing style (strict)

- No em-dashes, en-dashes, semicolons, or ellipses in any prose.
- No "not X but Y" constructions.
- UK spellings throughout.
- Do not use these words: nuanced, delineates, culminates, delve, delves,
  delved, grounded, leverage, leveraging, aforementioned, seminal, pivotal,
  underscore, fostering, profound, advocacy.
- Replace "several" with a specific number.
- Plain, editorial, professional tone.

### Code

- Use R, not Python, for any scripting or data checks.
- Start every R source file with a comment giving its path and file name.
- Do not invent or cite unverified references.
- New methods land in surveyframe core, guarded with `rlang::check_installed()`
  when they need an optional package. Keep hard imports to jsonlite, rlang, and
  openssl.

### Git

- Commit or push only when asked. Branch first if on the default branch is not
  the intended target.
- Push package changes on `main` to both `origin` and `private`. Push planning
  changes on `dev` to `private` only.

---

## Build, test, and check

Run from the repository root.

```r
devtools::document()          # regenerate man/ and NAMESPACE
devtools::test()              # run the test suite (expect 407 passing at 0.3.2)
devtools::load_all()          # load for interactive work
rmarkdown::render("vignettes/surveyframe.Rmd", output_dir = tempdir())
```

```bash
R CMD build .                                   # build the source tarball
R CMD check --as-cran surveyframe_0.3.2.tar.gz  # full CRAN check
```

A clean CRAN check is 0 errors, 0 warnings, and at most 1 NOTE (incoming
feasibility). The vignette builds offline because the data-collection step uses
`eval = FALSE` and the analysis runs on simulated or bundled demo data.

---

## Current status and immediate next steps

0.3.1 is published on CRAN (2026-06-02). 0.3.2 is fully implemented (all 7
changes done, 407/407 tests pass, vignette knits, both remotes up to date).

**The immediate gate is the MAS co-review.** Read `mas_review_032.md` in this
folder and work through it step by step in RStudio before proceeding to R CMD
check. The review covers all code changes, the static survey UI in a browser,
the vignette output, and the replicate.R script.

After co-review sign-off:

1. `R CMD build .` on the 0.3.2 source.
2. `R CMD check --as-cran surveyframe_0.3.2.tar.gz` — must be 0 errors, 0 warnings.
3. Win-builder R-release and R-devel — both clean.
4. Update `cran-comments.md` with the verified results.
5. Submit to CRAN.

The JSS paper (OJS 6454, submitted 2026-06-02) was returned without full review.
Revised and resubmit invitation. The replicate.R and package changes it required
are now in 0.3.2. The manuscript revision (surveyframe.Rnw) has not yet been
started. That is the next step after 0.3.2 ships.

Open items (non-blocking for CRAN submission):

- Confirm or remove the Codecov badge in README.
- Trigger pkgdown build after 0.3.2 is accepted.
- Guard `launch_dashboard()` and similar Shiny launcher `\donttest` examples so a
  full check does not hang; this is a future patch, not a 0.3.2 blocker.

The full task list is in `revision_todo_0.3.md`. The version and growth plan is
in `roadmap.md`.

---

## Key file map

- `R/` package source. Largest files: `statistics_reports.R`, `analysis_plan.R`,
  `model_layer.R`, `render_survey.R`, `reporting.R`.
- `R/conditions.R` holds `sframe_check_instrument()` and the typed condition
  helpers. Use these for user-facing errors.
- `R/read_write_sframe.R` holds serialisation. Component lists are unnamed before
  serialisation so Map-built instruments round-trip without a hash mismatch.
- `vignettes/surveyframe.Rmd` is the lead worked example.
- `inst/static_survey/template.html` is the exported survey. It reads
  `R.render.header` for the logo and institution.
- `inst/builder/survey_builder.html` is the visual builder.
- `inst/shiny/app.R` is SurveyStudio. `inst/shiny/dashboard/app.R` is the
  dashboard.
- `tests/testthat/test-0.3.1-fixes.R` covers the 0.3.1 collection fixes.
- `jss-paper/surveyframe.Rnw` is the JSS manuscript.

---

## Continuation prompts (paste to resume a thread of work)

### Submit 0.3.2 to CRAN (after MAS co-review sign-off)

```
Read CLAUDE.md and mas_review_032.md. The MAS co-review is complete. Run
R CMD build . to produce surveyframe_0.3.2.tar.gz, then R CMD check --as-cran
on the tarball. The target is 0 errors, 0 warnings, at most 1 NOTE. If clean,
update cran-comments.md with the results and tell me what to paste on the CRAN
submission form.
```

### Start the v0.5 MCDM work

```
Read CLAUDE.md and roadmap.md. Begin surveyframe v0.5: bring MCDM and DEMATEL
into core. Port the method registry from the mcdm repo, register the runners in
run_analysis_plan() under a decision family, and add the pairwise-comparison and
criteria-weight item types. Stay within the analysis-plan contract. No new hard
dependencies. Propose the plan before writing code.
```

### Start the 0.3.3 real-world feedback release

```
Read CLAUDE.md and portfolio-planner/development_instructions/04_v032_v033_implementation.md.
We are preparing surveyframe 0.3.3: real-world embedding and conference feedback.
The two evidence sources are ai-room-service-prototype (local: AI_Room_service/)
and the ICSRI 2026 presentation. Read both repos, reproduce the AIC-RSAM instrument
as a dev-branch regression fixture, and triage the fixes needed. Strict patch scope:
no new analytical features.
```

### Start the v0.4 small-sample work

```
Read CLAUDE.md and roadmap.md. Begin surveyframe v0.4: small-sample inference.
Add exact, permutation, and bootstrap variants for the existing two-group and
association tests, plus effect-size confidence intervals, drawing on the
small-sample-survey-framework. Add a small-sample advisory to sample_size_plan()
and assumption_report(). Also add the RStudio add-in as an adoption add-on (a
thin wrapper over the launchers plus an insert-sframe-skeleton helper, rstudioapi
in Suggests). Do not write the dcf until the plan is agreed. Propose the plan
before writing code.
```

### Work on the JSS paper

```
Read CLAUDE.md. Open jss-paper/surveyframe.Rnw. Proofread it against the current
CRAN package, confirm every code chunk runs, compile the PDF, and list what I
still need to provide before submitting to the Journal of Statistical Software.
```

### Update planning files

```
Read CLAUDE.md. Switch to the dev branch, merge main, update roadmap.md and
revision_todo_0.3.md to reflect the latest work, then push dev to the private
remote only. Keep the public main branch clean of dev files.
```

### Onboarding or review pass

```
Read CLAUDE.md. Install the current tarball as a first-time user with limited
coding skills. Work through the README, the help files, and the main vignette.
Identify anything that weakens onboarding or adoption, within 0.3.x scope and
with no new features, then apply the fixes.
```

---

## Memory

Persistent memory lives under the Claude projects memory directory for this
workspace. It records the writing-style rules, the ecosystem source-of-truth
decision, the CRAN status, and project context. Recalled memories are background
context. Verify any file or function reference against the current code before
acting on it.
