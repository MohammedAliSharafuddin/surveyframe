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

Current version: **0.3.4, live on CRAN, published 2026-07-24** (submitted
2026-07-25 local time, tagged `v0.3.4`). Verified on the CRAN package
page and the check-results page on 2026-07-30: all 13 flavours Status OK,
no notes, no warnings. `main` is pushed to both `origin` and `public` and
matches the public repository exactly. The pkgdown site shows 0.3.4 and
carries no dev-only files. 0.3.4 shipped all plotting, interface,
statistics, and reporting work: visualisation breadth, 5 `plot()` S3
methods, 2 WCAG-checked palettes, the builder rework, date bounds, the 4
bootstrap CI helpers, Henseler HTMT, Little's MCAR via naniar, PDF
reporting via pagedown, the Interpretations canvas, and 2 WCAG 2.2 AA
passes. naniar and pagedown joined Suggests. The full history of that
release is in the v0.3.4 section of `revision_todo_0.3.md` and in
`mas_review_034.md`/`.qmd`, whose sign-off is complete.

0.3.3 (CRAN 2026-07-11) merged what was originally planned as 2 releases,
the real-world AIC-RSAM hardening and the ggplot2 visualisation
foundation. The JSS manuscript was resubmitted 2026-07-12 against it.

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

## Version numbering: local labels versus CRAN versions (read before any release work)

**Owner decision 2026-07-30: the local development labels and the CRAN
version numbers deliberately differ. Do not rename branches, worktrees, or
planning files to match CRAN.**

| Local label (keep as is) | CRAN version | Content |
|---|---|---|
| branch `v0.5-dev`, worktree `../surveyframe-v0.5-dev`, `todo_0.5.md` | **0.4.0** | MCDM plus small-sample plus the 5 bug fixes plus absorbed field validation |
| `todo_0.5.1.md` | **0.4.1** | Faculty demo proofing plus the device-dependent field items |
| the RMCDA method expansion | **0.4.2** onward | The roughly 41 extra MCDM methods |
| `todo_0.3.5.md` | never published | Absorbed into 0.4.0 and 0.4.1 |
| branch `v0.4-dev` | never published | Small-sample track, already merged into `v0.5-dev` |

**CRAN numbering runs 0.3.4 to 0.4.0 to 0.4.1 to 0.4.2.** There is no 0.3.5
and no 0.5.x on CRAN, and no 0.4 in the old small-sample-only sense either,
since that release merged into this one on 2026-07-25. Practical
consequences: DESCRIPTION must read `0.4.0` at submission even though the
branch is called `v0.5-dev`, NEWS.md must state plainly that 0.3.5 and 0.5
were planned and never released, and the strict patch-scope rule that
governed 0.3.5 no longer binds, because that work now rides a minor
release.

**`todo_master_0.4.md` is the single entry point for release work**, with
all 64 open tasks in 9 blocks, a model tier per task, and the priority
order. The per-release files hold the detail. The canonical schedule is
portfolio-planner `master_roadmap.md`, whose 0.4.0 date is TBC pending the
manuscript timeline and ICSRI feedback.

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
  small-sample helpers, which land in surveyframe core at v0.5 (originally
  planned as v0.4, merged 2026-07-25).
- **flairmi / flairmi-site**: the commercial umbrella at flairmi.com.

v1.0 of surveyframe is the gate for the public launch of Ethos, Ethos Pro, and
the complete edition of the ASRDA textbook.

---

## Repository and branch model

There is one local working tree with two GitHub remotes.

- `origin` points to the private **surveyframe-dev** repository.
- `public` points to the public **surveyframe** repository.

**Corrected 2026-08-04.** This section previously said the reverse, that
`origin` was public and a remote called `private` existed. Neither is true.
Check with `git remote -v` before pushing rather than trusting prose.

Two branches keep the public repository clean while the private repository keeps
the planning files.

- `main`: the clean package. Pushed to both `origin` and `private`. The dev-only
  files are gitignored here, so they never reach the public CRAN repository.
- `dev`: the planning superset. Pushed to `private` only. It force-adds the
  dev-only files on top of `main`.

Dev-only files (tracked on `dev` only):

- `CLAUDE.md` (this file)
- `roadmap.md`
- `revision_todo_0.3.md`
- `cran-comments.md`
- `todo.md`
- `dogfeed.todo.md`
- `todo_0.3.5.md`, `todo_0.4.md`, `todo_0.5.md`, `todo_0.5.1.md`,
  `todo_0.6.md` through `todo_1.0.md`, `todo_rstudio_addin.md`
- `mas_review_032.md` through `mas_review_034.md` and their `.qmd`/`.html`
  renders, `kimi_review_034.md`, `qwen_review_034.md`
- `mas_review_040.qmd` (deferred, superseded by `review_040/`)
- `review_040/` (the 0.4.0 review suite: 20 `.qmd` files, `_setup.R`, and
  `HANDOVER.md`). Its rendered `.html`, `.pdf`, `.csv`, and `.sframe`
  artefacts are gitignored on `dev` too, since the HTML alone runs to 15 MB
- `data-raw/` (holds `inline_static_template.R`, which regenerates the
  builder's inlined copy of the static survey template)

**Both hygiene gaps are closed as of 2026-08-03.** `.Rbuildignore` now names
`todo_0.5.1.md`, `kimi_review_034.md`, `qwen_review_034.md`, `review_040/`,
and `mas_review_040.qmd`. `main`'s `.gitignore` was extended twice, on
2026-08-02 for the newer planning files and on 2026-08-03 for the review
suite. That second one matters: `.Rbuildignore` protects the CRAN tarball but
has no effect on pkgdown, which reads straight off the working tree.

Routine work happens on `main`. When the planning files change, switch to `dev`,
merge `main`, update the files, and push `dev` to `private`. To resume planning
on a fresh device, clone surveyframe-dev and check out `dev`.

`.Rbuildignore` excludes all dev-only files and the `jss-paper`, `pkgdown`, and
version-archive directories so the CRAN build never sees them.

**Branch state, verified 2026-08-05.** All 5 branches are identical on local
and `origin`, and `main` is identical on `origin` and `public`.

| Branch | Ancestor of `main`? | Keep? |
|---|---|---|
| `main` | is `main` | yes, the release branch |
| `dev` | no, and never will be | yes, it carries the planning files |
| `v0.5-dev` | **yes, fully merged** | yes for now, every planning file names it |
| `v0.4-dev` | **yes, fully merged** | deletable, finished work |
| `feature/rstudio-addin` | **yes, fully merged** | deletable, finished work |

Tested with `git merge-base --is-ancestor`, so the 3 merged branches hold no
commit `main` lacks. No branch is checked out in a worktree: the `v0.4-dev`
and `v0.5-dev` worktrees sit at detached HEADs on those same commits, so
deleting the refs would not disturb them. **`v0.5-dev` being an ancestor
means release work now belongs on `main`**, whatever the older continuation
prompts say.

The public repo has 2 branches and both belong there: `main`, and `gh-pages`,
which `.github/workflows/pkgdown.yaml` writes on every push to `main`. The
site was last deployed from `b9d44c5` and carries no dev-only files, so the
`clean: true` fix is holding.

**Tags: `v0.3.3` and `v0.3.4`, on both remotes.** See the history-rewrite
section for why `v0.3.4` was created retrospectively and why a recorded SHA
is not a substitute for a tag.

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
devtools::test()              # run the test suite (721 at the 0.3.4 release,
                              # 1506 on main once 0.4.0 merged)
devtools::load_all()          # load for interactive work
rmarkdown::render("vignettes/surveyframe.Rmd", output_dir = tempdir())
```

```bash
R CMD build .                                        # build the source tarball
R CMD check --as-cran surveyframe_0.3.4.9000.tar.gz  # full CRAN check
```

**A green `devtools::test()` is not a green check.** Merging 0.4.0 to `main`
put it through `R CMD check --as-cran` for the first time and found an
undeclared `jmv` dependency and temp-directory detritus, neither of which
`devtools::test()` can see. Run the real check before believing a release is
ready.

A clean CRAN check is 0 errors, 0 warnings, and at most 1 NOTE (incoming
feasibility). The vignette builds offline because the data-collection step uses
`eval = FALSE` and the analysis runs on simulated or bundled demo data.

---

## Current status and immediate next steps

Status verified against the code, the branches, both remotes, CI, and CRAN on
2026-08-05.

**Read this first.** 0.4.0's engineering is complete and now sits on `main`,
installable from GitHub. The review suite is complete and found 8 defects
needing owner decisions. Git history was rewritten on 2026-08-04, so any
clone older than that is stale. The 2 CRAN blockers are unchanged: the MCDM
preprint DOI (D6) and the owner verifying the RStudio add-in (H2). Jump to
"0.4.0 is on `main`", "The review suite", and "Git history was rewritten".

### Shipped

**0.3.4 is live on CRAN (published 2026-07-24), all 13 check flavours OK,
no notes.** Nothing about that release is outstanding. The release commit is
tagged `v0.3.4` on both remotes, the pkgdown site shows 0.3.4 with no
dev-only files, and `mas_review_034` is signed off with every
human-judgement item explicitly moved to `dogfeed.todo.md` for the
field-validation round, which was labelled 0.3.5 at the time and is now
absorbed into 0.4.0 and 0.4.1, rather than left open. Earlier drafts of this file described 0.3.4 as
"in progress". That text was stale and has been removed.

### In flight

**0.4.0 is the merged small-sample plus MCDM release, on branch `v0.5-dev`
(worktree `../surveyframe-v0.5-dev`).** The branch label stays `v0.5-dev`
deliberately, see the version-numbering section above. 0.4 merged into it on
2026-07-25, so no separate 0.4 ships. What is built and committed there:

- The whole small-sample track: Hodges-Lehmann on Mann-Whitney,
  pseudomedian CI on paired Wilcoxon, exact odds-ratio CI on Fisher,
  Firth logistic regression with `logistf` in Suggests, the small-sample
  advisory on `assumption_report()` and `sample_size_plan()`, and
  `vignettes/small-sample.Rmd`.
- All 10 MCDM methods (TOPSIS, AHP, ANP, DEMATEL, VIKOR, MOORA, SMART,
  WASPAS, PROMETHEE, ELECTRE), each dispatching through
  `sframe_run_one_block()`, `sframe_analysis_roles()`, and
  `sframe_plot_for_result()`, with both JS UI registries listing all 10.
- `R/decision_data.R` (assembly, aggregation, collected weights, rated
  matrices, AHP consistency screening) and the 2 new item types at the R
  level, with 7 `test-decision-*.R` files.
- Static-survey rendering for `pairwise_comparison` and
  `criteria_weight`, including the `validatePage()` constant-sum check,
  the mobile `<select>` reflow, and the submit serialiser (commit
  d218786, verified through headless Chrome).
- RMCDA in Suggests as a test-time cross-check oracle. It caught a real
  bug: WASPAS was using SMART's normalisation.

**The field-validation work has no release of its own.** By owner decision
2026-07-30 it is absorbed into CRAN 0.4.0 and 0.4.1, so `todo_0.3.5.md` is
superseded. It is driven by ICSRI 2026 feedback (8 to 9 August 2026) and 3
to 5 short real surveys, and 12 items are already logged against it in
`dogfeed.todo.md`. Absorbing it puts the conference on 0.4.0's critical
path rather than beside it.

### Progress on 2026-07-30 (branch `v0.5-dev`, 4 commits)

The builder can now build MCDM surveys end to end, which it could not before.
19083e4 added the 2 decision item types to the Add-question menu and to
`varLevel()`, so all 10 methods offer role options instead of empty
dropdowns. 9fdeb0e fixed what the first pass missed: the Preview tab drew an
empty question body, and exporting a survey emitted "Unsupported item type"
because the builder's inlined copy of the static template predated the
renderers, which also closes the inline-template task. The inspector editor
for `comparison_items` and `comparison_scale` came with it. 266f2a1 raised
the Add-question menu's height cap, which had clipped the whole Decision
group out of view. 83ce595 added the scale-mismatch guards described below
and the sample-label cue.

Suite after all 4: 1124 passed, 0 failed, 3 skipped.

**Bug 6, found in a live builder session rather than by any suite.** A
decision plan could be built the wrong way round, because AHP's `pairwise`
role offered every `pairwise_comparison` item including a DEMATEL influence
item. The 2 comparison scales are not interchangeable: AHP and ANP read
reciprocal relative importance on the Saaty 1 to 9 ratio scale, while an
influence item collects directed 0 to 4 influence with a zero diagonal and no
reciprocity, so the pairing returns plausible weights from meaningless input
with no error. Guarded on 4 surfaces: `validate_sframe()` at design time,
`sframe_resolve_pairwise_matrix()` so the AHP and ANP runners error rather
than compute, the builder via a `pairwise_saaty`/`pairwise_influence` level
split, and `studio_level_meta()` in SurveyStudio, which had no branch for
either item type and so showed empty MCDM dropdowns.

**Verification discipline, learnt the hard way this session.** 3 of the
verification scripts written for this work were themselves wrong: a wrong
export placeholder, `openInsp()` where the UI calls `selItem()`, and reading
an `$errors` field that `validate_sframe()` does not return, which made 2
rounds of "0 validation errors" vacuous. `validate_sframe()` returns
`$problems`. Two rules now apply to this release: any UI claim needs a
click-path run with the screenshot read back, and any new rule needs a
mutation check, meaning revert the guard, confirm the test fails, restore it.
The scale guards were checked that way, 11 of 19 expectations failing with
them reverted.

### The 5 confirmed bugs from independent validation

Found 2026-07-26 by the sibling repo `surveyframe-statistical-validation`
and a headless chromote pass over the builder. All 5 re-verified as still
present on `v0.5-dev` on 2026-07-30. Each produces plausible output with
no error, so none of them would surface without cross-validation.

1. `item_report()` item-rest correlation uses `rowMeans()` where the
   standard needs the sum of the other items
   (`R/psychometrics.R:179`). Gives negative values on a scale with
   alpha 0.88.
2. `sframe_run_repeated_anova()` never coerces `.subject` to a factor
   (`R/statistics_reports.R:956`), so `aov()` uses the wrong error
   stratum. F comes out 0.94 where `jmv::anovaRM()` gives 22.64.
3. The builder cannot create either new decision item type: `qAdd()`'s
   fab menu has no button and `varLevel()` has no branch, so
   `roleOptions()` returns nothing even for an imported instrument. All
   10 MCDM methods are unbuildable in the GUI until this is fixed.
4. `known_vars` in `R/validate_sframe.R` lacks the `item__sub` and
   `item__option` expansion the builder and `read_responses()` already
   use, so a real builder export fails R-side validation.
5. Model-role dropdowns and `seminr_syntax()`/`sem_lavaan_syntax()` do
   not check `model$type`, so a CB-SEM model generates PLS-SEM syntax
   without complaint.

All 5 fixes land in CRAN 0.4.0 by owner decision 2026-07-30. 4 of them
shipped inside 0.3.4, so they are live on CRAN now.

### 0.4.0 engineering is complete (2026-08-02)

Blocks A, B, and C are closed, plus the RStudio add-in (H1, on branch
`feature/rstudio-addin`). Full suite 1473 on `v0.5-dev`, 1486 on the add-in
branch. Everything the earlier draft of this section listed as "not built"
now exists: `sensitivity_analysis()`, `sf_conjoint_design()`, the Shiny
renderer for both decision item types, the bundled hotel-supplier fixture,
`vignettes/mcdm-analysis.Rmd` (axe-core clean), and all 10 method citations.
B1's data-contract sign-off, the release's standing rework risk, was taken
on 2026-07-31.

**Two pre-existing defects were found and fixed on owner decision, both
breaking and both recorded in NEWS.** The Shiny collector emitted joined
columns for matrix, ranking, and multi-select (`mx = "4|5"` where the reader
expects `mx__r1`, `mx__r2`), so data collected that way could not be read
back by the package at all, silently, with no error at collection time. And
a freshly built instrument was not a serialisation fixed point: identical
content carried 2 different hashes depending on whether it had been through
a read, which undercuts the claim that the hash is the instrument's
identity. A test now asserts the 3 bundled instruments still hash to what
they store, because if that ever fails every stored `.sframe` moved with it.

**Two review tasks found defects that were not in the task list, and both
had the same shape: software returning something plausible instead of
saying it had no answer.** B11 found ELECTRE reporting an empty outranking
relation as "all 9 alternatives jointly best", with `sensitivity_analysis()`
then calling that result stable, which is the strongest robustness signal
the function has produced by the weakest input it can take. B13 found the
rated performance matrix unwirable in both GUIs, because neither gave matrix
items the level the `performance_items` role wanted, so a path the vignette
teaches could only be built by writing R. Worth carrying into the remaining
review: where a result looks clean, ask whether it is clean or merely quiet.

**Three planned tasks were not what they were written as.** B10's exemption
already existed by construction, and the real defect was next door, in
missingness reporting 0 percent for a respondent who skipped an entire
battery. B12 needed no engineering at all, only user-facing documentation.
C4's "8 machine-fixable" items were 7 judgement calls plus one partly
machine task, and 12 dogfeed entries were re-laned to 0.4.1 as a result.

**Verification discipline, reinforced.** Every fix is checked against an
independent oracle where one exists (`psych`, `jmv`, RMCDA) and
mutation-checked. Two lessons repeated often enough to record: a browser
reading of a Shiny widget is unreliable, because selectize.js hides the real
`<select>` and made a working dropdown look empty twice, so UI defects are
established in R first and the browser corroborates; and roughly 6 of my own
harness errors in this session initially looked like package bugs (invented
method and role names, an invented function argument, `as.data.frame()`
silently mangling column names), so a surprising failure is worth attributing
before it is reported.

### 0.4.0 is on `main` and installable from GitHub (2026-08-04)

`v0.5-dev` and `feature/rstudio-addin` merged into `main` on 2026-08-03, and
`main` is pushed to both remotes. The whole 0.4.0 engineering plus the
RStudio add-in is therefore installable for testing:

```r
remotes::install_github("MohammedAliSharafuddin/surveyframe")
# add build_vignettes = TRUE for the 3 vignettes, which install_github skips
```

Verified from a clean library on the public repo, not just locally:
`sensitivity_analysis()` and `sf_conjoint_design()` present, the add-in's
`inst/rstudio/addins.dcf` present, the MCDM fixture present, and a live
TOPSIS run returning Equator. `DESCRIPTION` reads **`0.3.4.9000`**, a
development marker so a GitHub build is distinguishable from CRAN 0.3.4.
Task E1 still sets `0.4.0` at release time.

**Merging to `main` put 0.4.0 through `R CMD check --as-cran` for the first
time and found 3 packaging problems that `devtools::test()` cannot see.** A
green local suite alongside a red check is the lesson to carry.

1. **WARNING, now fixed.** `test-repeated-anova-strata.R` used
   `jmv::anovaRM()` as the A3 oracle while `jmv` was in no DESCRIPTION field.
   `skip_if_not_installed()` does not help, because the check flags the `::`
   reference itself. `jmv` joined Suggests.
2. **NOTE, partly fixed.** `pagedown::chrome_print()` leaves Chrome's scratch
   directories in `tempdir()`. `sframe_clean_chrome_detritus()` in
   `R/reporting.R` sweeps them, fixed in `render_report()` rather than in the
   test so real users benefit. macOS now reports `Status: OK`. **Ubuntu still
   reports the NOTE**, most likely because Chrome exits asynchronously and
   the directories appear after the `on.exit()` sweep has run. It does not
   affect the CRAN submission, because both `chrome_print()` callers carry
   `skip_on_cran()` and CI only runs them because `r-lib/actions` sets
   `NOT_CRAN: true`. Note it in `cran-comments.md` rather than chasing it.
3. **Not fixed, and it will bite.** 36 `geom_errorbarh()` deprecation
   warnings from ggplot2 4.0.0 at `R/plots.R:1644` and `:1757`. Not a check
   failure yet. The fix is `geom_errorbar(orientation = "y")` with `height`
   becoming `width`.

`_pkgdown.yml` also had to gain a Decision analysis section: pkgdown refuses
to build when a documented topic is missing from the reference index, and
0.4.0 added 10 that were never indexed, so the site build had been failing
since the merge.

### The review suite, and the 8 defects it found (2026-08-04)

**`review_040/` replaces `mas_review_040.qmd`**, which was 120 chunks in 1
file and suited neither a reviewer working in sittings nor a first-time
user. It is deferred rather than deleted. Twenty files, each a complete
workflow that stands alone: questionnaire, pre-declared plan, static HTML
route, Shiny route, dummy data, and every reported number compared against
base R and a reference package. **566 checked numbers**, all reading `match`,
across 16 automated files. Files `18`, `19`, and `20` need a keyboard.
`review_040/HANDOVER.md` carries the file template, the verified result
field names for every method, and 16 reference-call traps.

**Eight defects, all logged in `dogfeed.todo.md`, none caught by any test
suite.** Four of the last 5 have the shape B11 and B13 had: software
returning something plausible instead of saying it has no answer.

| # | Finding | Lane |
|---|---|---|
| 1 | `item_report()` ignores `reverse = TRUE` while `score_scales()` and `reliability_report()` honour it | 0.4.0 |
| 2 | Correlation roles: `variables` works for Kendall, fails for Pearson and Spearman | 0.4.0 |
| 3 | `assumption_report()` reports checks that never ran | 0.4.1 |
| 4 | Display-only items get a Shiny response column, and it counts as missing | 0.4.0 |
| 5 | `sem_lavaan_syntax()` writes an indirect effect lavaan cannot parse | 0.4.0 |
| 6 | Conjoint `"balanced"` is rewarded for dropping a level | 0.4.0 |
| 7 | `render_results(citation_format = )` is validated then ignored | 0.4.0 |
| 8 | `codebook_report()` omits the item help text | 0.4.1 |

**5 and 6 are the ones to take first.** 5 is a hard error in the single case
a `cb_sem` model is most often declared for. 6 cannot be repaired after
collection, since a fielded design with an unseen level is partly
inestimable, and `"balanced"` is measurably worse than `"random"` at
avoiding it. **1 changes numbers the package has already printed for users**,
which is why it needs a decision rather than a quiet fix.

**Two ways the suite was wrong about itself, both producing a confident
`match` that meant nothing.** A field that does not exist compares equal to
itself: file `13`'s hash gate read `hotel$integrity$hash` twice, and there is
no `$integrity` element on an `sframe`, so it compared `NULL` to `NULL`. And
a mismatched reference looks exactly like a defect: an apparent ninth
finding about skewness was surveyframe reporting the b1 and b2 estimators,
which is `psych`'s own default. **Every new claim needs a mutation check.
Revert the thing being tested and confirm the test fails.** A check that
cannot fail is not a check.

### Git history was rewritten on 2026-08-04

Every `Co-Authored-By` trailer is gone from every branch and from the
`v0.3.3` tag, on both remotes. Verified by cloning the public repo fresh: 0
trailers, and the only authors are the 2 `MohamedaliS` and
`Mohammed Ali Sharafuddin` identities. GitHub's Contributors list no longer
shows a second name.

Consequences to know:

- **Every SHA from `274217f` (2026-06-15) onward changed.** Any clone made
  before 2026-08-04 is stale and needs
  `git fetch origin && git reset --hard origin/<branch>`.
- All 5 branches were realigned: `main`, `dev`, `v0.5-dev`, `v0.4-dev`, and
  `feature/rstudio-addin`. Shared commits rewrote to identical SHAs across
  the separate passes, so the branches did not fork.
- **The `v0.3.3` tag had 2 different objects with the same name**, the public
  one 2 commits behind the local one. The rewrite forced a choice and took
  the newer local target, preserving its message and tagger date. Both
  remotes now agree.

Local backup tags `backup/main-pre-rewrite`, `backup/dev-pre-rewrite`, and
`backup/dev-pre-rewrite2` hold the pre-rewrite tips and were deliberately
not pushed. They are the only record of the pre-rewrite history, so they
live on one machine and nowhere else.

**`v0.3.4` was tagged retrospectively on 2026-08-05, on both remotes.** The
CRAN release had no tag, only `v0.3.3` did, so the commit that shipped to
CRAN was findable only by reading `main`'s history. The rewrite had also
orphaned `6556f91`, the SHA this file recorded for it: that commit survives
only inside the 3 backup tags. Its counterpart on the rewritten `main` is
`19ada2c`, identified by an identical tree hash rather than by message or
date, and that is what `v0.3.4` points at. Tag each release as it ships from
now on, because a rewrite makes a recorded SHA worthless and a tag moves
with the history.

### Hard blocker, and the one human gate

**`inst/CITATION` needs the MCDM preprint DOI (task D6), and CRAN will not
accept a placeholder.** The small-sample paper moved to 0.4.1 on 2026-07-31,
so only the MCDM paper gates this release. Target journal: *Operations
Research and Decisions*, diamond OA.

**H2 is the other gate and cannot be automated.** Verifying the RStudio
add-in inside a real RStudio session needs the owner at a keyboard, the
add-in ships in 0.4.0, and `review_040/19_rstudio_addin.qmd` carries the click
path. Everything else outstanding in blocks D and E is mechanical release
paperwork.

### Also open, unrelated to a single release

The RStudio add-in exists only as a plan (`todo_rstudio_addin.md`). No
files, no branch, no `rstudioapi` in Suggests. Its "do not merge until
0.3.4 is accepted" condition is now satisfied, so it can be built and
merged at any time. Smaller carried items: the `.bib` reference carry-in
decision (leaning defer), the Codecov badge, guarding the Shiny launcher
`\donttest` examples, the keep-versus-deprecate call on the standalone
dashboard, an interactive pass over `R/survey_module.R`, and README's
Roadmap section, which still promises small-sample at 0.4 and MCDM at
0.5 on a public page.

**`todo_master_0.4.md` holds all 64 open tasks** in 9 blocks with a model
tier and a priority tier per task, plus the 3 open decisions. Read it
first for release work. Per-release detail stays in `todo_0.5.md` (the
0.4.0 engineering spec), `todo_0.5.1.md` (0.4.1), `todo_rstudio_addin.md`,
and `todo_0.6.md` through `todo_1.0.md`. `todo_0.4.md` is the small-sample
record, already built. `todo_0.3.5.md` is superseded, absorbed into 0.4.0
and 0.4.1.

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

### Resume release work (CRAN 0.4.0, local 0.5.0)

```
Read CLAUDE.md's version-numbering section and todo_master_0.4.md. The
0.4.0 engineering is complete and merged into main as of 2026-08-03, so
work on main rather than v0.5-dev, which is now an ancestor of it. Only 2
things stand between here and submission: D6's preprint DOI for
inst/CITATION (no placeholder accepted) and H2, the owner verifying the
add-in in RStudio. Blocks D and E are what remains, plus decisions on the
8 defects in dogfeed.todo.md.

DESCRIPTION reads 0.3.4.9000, a development marker. Set it to 0.4.0 only
at release time (task E1). Git history was rewritten on 2026-08-04, so
fetch and hard-reset before doing anything if your clone predates that.
Re-verify every file and line anchor before editing, they drift.
```

### Verify 0.4.0 before submitting (the human half)

```
Read CLAUDE.md, then work through review_040/ in RStudio, starting with
00_start_here.qmd. Files 01 to 17 run without you and should report
0 DIFFERS and 0 CHECK; if any file reports otherwise, that is the finding.
Files 18, 19, and 20 need a keyboard, and 19 is the release blocker, since
H2 cannot be automated. File 20 section 7 is where the decisions on the 8
open defects get recorded. Log new feedback in dogfeed.todo.md rather than
leaving it in a review file.

mas_review_040.qmd is deferred, not current. Do not work from it.
```

### Run the field-validation work (absorbed into 0.4.0 and 0.4.1)

```
Read CLAUDE.md, todo_master_0.4.md block C, and dogfeed.todo.md. There is
no 0.3.5 release: this work is absorbed into CRAN 0.4.0 and 0.4.1, so
patch-scope limits no longer bind. Start from the 8 machine-fixable items
already logged in the 0.3.5 lane of dogfeed.todo.md, then take the ICSRI
2026 and human-testing feedback as it arrives. Dogfeed protocol applies:
log first, fix only after an explicit "dogfeed is complete".
```

### Build the RStudio add-in

```
Read CLAUDE.md and todo_rstudio_addin.md. Nothing has been built yet: no
inst/rstudio/addins.dcf, no R/rstudio_addins.R, no branch, no rstudioapi
in Suggests. The "do not merge until 0.3.4 is accepted" condition is now
satisfied, since 0.3.4 is on CRAN. Cut feature/rstudio-addin from dev in
its own worktree, build the 4 agreed menu items and nothing more, and
keep the diff to new files plus one DESCRIPTION line.
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
