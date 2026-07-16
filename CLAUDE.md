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

Current version: 0.3.3, accepted by CRAN 2026-07-11 (auto-check confirmation
received same day the tarball was submitted: "package is on its way to
CRAN", Result: OK on r-devel-linux-x86_64-debian-gcc and
r-devel-windows-x86_64). 0.3.3 merges what was originally planned as two
releases: the real-world AIC-RSAM hardening (0.3.3) and the ggplot2
visualisation foundation (0.3.4), shipped together as a single 0.3.3 since
neither had reached CRAN yet. 543/543 tests pass. The MAS co-review
(`mas_review_033.md`/`.qmd`, modelled on the 0.3.2 review) is complete,
including a second live-feedback round covering multi-select export, mobile
matrix scrolling, SurveyBuilder control duplication, and the report
table/plot pairing, all resolved. The lead vignette and two supporting
vignettes were rewritten to describe the redesigned survey, the expanded
export columns, and `plots = TRUE`. Local `R CMD check --as-cran`,
win-builder R-release (4.6.1), and win-builder R-devel were all clean
(0/0/0) before submission. The CRAN package page confirmed 0.3.3 live, and
the JSS manuscript work in surveyframe-jss-paper was told it is clear to
resubmit (resubmitted 2026-07-12).

The pkgdown site is live at https://mohammedalisharafuddin.github.io/surveyframe/
(published 2026-07-12, built and deployed automatically by
`.github/workflows/pkgdown.yaml` on every push to `main`). Building it
surfaced and fixed two real problems, not just cosmetic ones: building
pkgdown from the `dev` branch renders dev-only planning files (CLAUDE.md,
dogfeed.todo.md, mas_review_03x.md, revision_todo_0.3.md) into public HTML,
since `.Rbuildignore` has no effect on pkgdown (only `R CMD build` respects
it) — pkgdown must always be built from `main`. Separately, a genuine live
leak was found and fixed: `revision_todo_0.3.md`/`.html`, `roadmap.md`/`.html`,
and `todo.md` had been sitting on the public `gh-pages` branch since some
earlier deploy, surviving every subsequent rebuild because the deploy
action used `clean: false` (only adds/updates files, never removes ones no
longer produced). Switched to `clean: true`; verified the live branch now
matches the build output exactly. A follow-up SEO/GEO pass also fixed a
duplicated browser-tab title, switched `og:image` from SVG (most social
crawlers do not render SVG previews) to PNG, added JSON-LD structured data,
added `robots.txt`, and gave the small-sample textbook reference in README a
full citation with its Zenodo DOI.

After 0.3.3 comes the remaining visualisation patch arc, consolidated on
2026-07-14 into two ~30-day releases: 0.3.4 (target 2026-08-15) ships all
plotting and UI work (visualisation breadth, plots into the report, dashboard,
and studio, the builder rework, the vignette WCAG pass), and 0.3.5 (target
2026-09-15) ships effect-size confidence intervals, psychometric depth, and
PDF reporting. Then 0.4 (small-sample inference, target 2026-11-20). 0.4.1 is
the faculty demo proofing release. The
canonical schedule is portfolio-planner master_roadmap.md.

---

## Ecosystem and how the pieces fit

surveyframe is the source of truth for a wider product and publication set.

- **surveyframe** (public, CRAN): the package itself.
- **surveyframe-dev** (private): the full working repository. Tracks everything,
  including this file, the roadmap, the to-do notes, and the brand sources.
  Open this repository when working across devices.
- **surveyframe-jss-paper** (private): the JSS manuscript, moved out of
  surveyframe-dev on 2026-07-10. Clone it beside this repository when working
  on the paper.
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
- `dogfeed.todo.md`

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

### Session efficiency

- Minimise token use automatically wherever possible, without being asked
  each time. Keep responses concise, avoid restating context already
  established in the conversation or in this file, don't re-read a file
  that was already read and hasn't changed, and prefer targeted reads/edits
  over dumping full-file contents when a smaller slice will do. This applies
  to every session working in this repository, not just one-off requests.

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
devtools::test()              # run the test suite (expect 543 passing at 0.3.3)
devtools::load_all()          # load for interactive work
rmarkdown::render("vignettes/surveyframe.Rmd", output_dir = tempdir())
```

```bash
R CMD build .                                   # build the source tarball
R CMD check --as-cran surveyframe_0.3.3.tar.gz  # full CRAN check
```

A clean CRAN check is 0 errors, 0 warnings, and at most 1 NOTE (incoming
feasibility). The vignette builds offline because the data-collection step uses
`eval = FALSE` and the analysis runs on simulated or bundled demo data.

---

## Current status and immediate next steps

**0.3.4 is in progress (target 2026-08-15, status 2026-07-16).** The work
sits UNCOMMITTED on the working tree, 562/562 tests pass. Done: the full
visualisation breadth in `R/plots.R` (all planned family plots plus
skewness/kurtosis, group-comparison, paired, and variable-distribution
charts), 2 WCAG-checked colour systems (web brand and print
black/grey/white) with a `plot_palette` chart-theme switcher threaded
through `run_analysis_plan()`, `render_report()` (both render paths), and
a SurveyStudio Export radio, `render_report()` plot embedding, 5 `plot()`
S3 methods, the complete builder rework (Add-question split, Theme B
preview, settings consolidation, Analyse sub-tab rework plus two-pane
layout), the preset choice-set library, the ID-regeneration and
`item__sub` variable-expansion fixes, and the thank-you download/redirect
repair. The full done/pending breakdown lives in the v0.3.4 section of
`revision_todo_0.3.md`. Largest pending blocks: the editable
interpretation step in the report flow (owner request 2026-07-16), the
studio Analyse plot area, date bounds, the vignette and builder WCAG
passes, and the whole release process (commit, version bump, NEWS, MAS
co-review, CRAN checks).

0.3.1 is published on CRAN (2026-06-02). 0.3.3 is fully implemented (543/543
tests pass, three vignettes rewritten and knit clean, tarball built, local
`R CMD check --as-cran` clean at 0/0/0).

**0.3.3 merges two originally separate releases.** It hardens the package
against its first real deployment (the AIC-RSAM room-service study and the
Google Sheets collector's CORS submission bug, found and fixed against the
live prototype) and ships the ggplot2 visualisation foundation originally
planned as 0.3.4 (`plots = TRUE` on `run_analysis_plan()`, `theme_surveyframe()`,
the Likert diverging chart, table+plot pairing in the report). Both were
merged into a single 0.3.3 since neither had reached CRAN when the decision
was made.

**The MAS co-review is complete (`mas_review_033.md`/`.qmd`, modelled on the
0.3.2 review), including a second live-feedback round** covering: multi-select
export as one 0/1 column per option, mobile-friendly matrix reflow below 600px,
SurveyBuilder's duplicate Add-question and Settings entry points (now single
entry points each), the report's table+plot pairing, and the Likert-specific
diverging chart. All six items resolved and verified headlessly via
`chromote`. The survey export also passed a full WCAG 2.2 AA pass (accessible
names, visible focus, announced errors, keyboard-operable ranking, 44px touch
targets).

DONE and signed off: **SurveyBuilder** (HTML), **static survey** template
(Theme B redesign, mobile reflow, WCAG 2.2 AA), **SurveyStudio**
(`inst/shiny/app.R`), and the **HTML/Quarto report**
(`R/reporting.R` + `inst/templates/report.qmd`, now pairing every result table
with its chart). The lead vignette (`surveyframe.Rmd`) and
`deploying-and-collecting.Rmd`/`analysing-survey-responses.Rmd` were rewritten
to describe the redesigned survey, the expanded ranking/multiple-choice/matrix
export columns, and `plots = TRUE`.

Status as of 2026-07-11:

1. `surveyframe_0.3.3.tar.gz` built. Local `R CMD check --as-cran`: Status OK,
   0 errors, 0 warnings, 0 notes.
2. Win-builder R-release (4.6.1) and R-devel both returned Status: OK.
   Submitted to CRAN 2026-07-11. **Accepted the same day**: CRAN's
   auto-check service confirmed "package is on its way to CRAN", Result: OK
   on r-devel-linux-x86_64-debian-gcc and r-devel-windows-x86_64.
3. NEWS.md proofread and corrected to read as a clean per-release changelog,
   with future-direction and internal-note content removed.
4. `main` pushed to both `origin` (private) and `public` (the CRAN-facing
   surveyframe repository) after the tarball verification confirmed the
   submitted tarball is byte-identical to the repo state for every source
   file it carries.

The JSS paper (OJS 6454, submitted 2026-06-02) was returned without full review.
Revised and resubmit invitation. The replicate.R and package changes it required
shipped in 0.3.2/0.3.3. The manuscript itself now lives in its own repository,
surveyframe-jss-paper (see that repo's own CLAUDE.md), and was updated
2026-07-11 for 0.3.3: version references bumped, the live SSR 6.0 DOI cited,
all six figures retaken against the redesigned survey and current
SurveyBuilder UI, and a previously unaddressed editor checklist item (a
non-interactive response-collection demonstration) finally closed.
**Resubmitted to JSS 2026-07-12** once the CRAN package page confirmed
0.3.3 live.

Open items (non-blocking for CRAN submission):

- Confirm or remove the Codecov badge in README.
- Guard `launch_dashboard()` and similar Shiny launcher `\donttest` examples so a
  full check does not hang; this is a future patch, not a 0.3.3 blocker.
- The pre-existing Quarto/pandoc `kable()` table-collapsing bug found during
  the 0.3.3 review (confirmed unrelated to this release's changes, not
  reproducible in isolated minimal tests) remains open for a future session.
- A vignette-specific WCAG 2.2 AA CSS pass is logged in roadmap.md under
  v0.3.4 (the pkgdown theme fixed the "dull" look, but contrast/heading
  structure has not been separately checked).

The full task list is in `revision_todo_0.3.md`. The version and growth plan is
in `roadmap.md`.

### Dogfeed log

`dogfeed.todo.md` is the running log of feedback from using surveyframe as a
real user (dogfeeding): bugs, rough edges, confusing copy, missing
affordances. Each item is logged with a status (`open`, `planned`, `fixed`,
`wontfix`) and, once triaged, a version target against `roadmap.md`. Check it
at the start of a dogfeed session and append new items as they come in rather
than losing them to conversation history.

**While a dogfeed session is open, do not edit any source file** (`R/`,
`inst/`, tests, vignettes, or any other package file). Log the feedback only.
Wait for an explicit "dogfeed is complete" (or equivalent) before triaging or
fixing anything.

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
- The JSS manuscript lives in the separate surveyframe-jss-paper repository
  (`../surveyframe-jss-paper/surveyframe.Rnw` when cloned beside this one).

---

## Continuation prompts (paste to resume a thread of work)

### Vignette WCAG 2.2 AA CSS pass (logged for v0.3.4)

```
Read CLAUDE.md and roadmap.md's v0.3.4 section. The pkgdown site (live at
https://mohammedalisharafuddin.github.io/surveyframe/) already fixed the
"dull default vignette" look by wrapping vignettes in the branded pkgdown
theme. What has not been checked is AA contrast and heading structure on
the vignette content itself. Do that pass: check contrast ratios on code
blocks, tables, and body text against the bslib theme colours, verify
heading order, and fix anything that fails, on main since docs/ and the
pkgdown build are unaffected.
```

### Trigger the pkgdown workflow after any future dev-only file addition

```
Read CLAUDE.md. Before adding any new dev-only planning file (following the
pattern of CLAUDE.md, roadmap.md, dogfeed.todo.md, mas_review_03x.md,
revision_todo_0.3.md, cran-comments.md), confirm it is excluded on main
(gitignored there) so a pkgdown build never has it in its working tree.
pkgdown must only ever be built from main, never dev: .Rbuildignore
protects the CRAN tarball but has no effect on pkgdown, which reads
straight off the working tree. If in doubt, rebuild locally on main first
(pkgdown::build_site(preview = FALSE)) and grep docs/ for the new file's
name before pushing.
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
Read CLAUDE.md. Open ../surveyframe-jss-paper/surveyframe.Rnw (its own private
repo since 2026-07-10). Proofread it against the current
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

### Resume a dogfeed session

```
Read CLAUDE.md and dogfeed.todo.md. Open a fresh dogfeed session: log every
piece of feedback I give as I use surveyframe as a real user, one item per
entry, status "open". Do not triage or fix anything unless I ask; just capture
it accurately so nothing is lost.
```

---

## Memory

Persistent memory lives under the Claude projects memory directory for this
workspace. It records the writing-style rules, the ecosystem source-of-truth
decision, the CRAN status, and project context. Recalled memories are background
context. Verify any file or function reference against the current code before
acting on it.
