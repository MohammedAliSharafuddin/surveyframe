# surveyframe revision notes and to-do

Excluded from the CRAN build (via .Rbuildignore) and from the public repo
(via .gitignore). Lives only in the dev workspace.

---

## v0.3.2 — Implemented and signed off (next: CRAN check and submission)

All changes committed. 368/368 tests pass. Vignettes knit clean. Both remotes
(public surveyframe and private surveyframe-dev) up to date. The MAS co-review
is complete and signed off (2026-06-17, all 184 checklist items, Parts A to U,
in mas_review_032.md). Late additions this arc: SurveyStudio disables its Export
buttons until an instrument is valid and reads responses from a deployed Google
Sheet on the Upload screen, and the vignettes present analysis output as branded
tables and plots. R CMD check --as-cran is now cleared to run.

Scope: the CITATION fix is still the trigger. The JSS editor review adds the
package changes below. No new features, no new exports.

### Blocking fix: stale `inst/CITATION`

The CITATION file was never updated when the title was corrected and the version
was bumped. As shipped in 0.3.0 and 0.3.1 it reads:

```
title = surveyframe: A Survey Instrument Workflow for R
note  = R package version 0.3.0
```

Two problems:

1. The title still carries the redundant "for R" the CRAN reviewer (Konstanze
   Lauseker) asked to drop during the 0.3.0 review. The DESCRIPTION Title was
   fixed to "Survey Instrument Workflows" at that time, but the CITATION was not
   brought into line.
2. The version note is hard-coded to 0.3.0, so it is already two releases stale.

`R CMD check` does not compare the CITATION title to the DESCRIPTION Title and
does not check the version note, so this passed silently through both 0.3.0 and
0.3.1. The CRAN package page citation is regenerated from the published tarball,
so the corrected citation only appears once a new version is on CRAN. It ships
with 0.3.2.

Planned change to `inst/CITATION` (apply during 0.3.2, then verify with
`utils::readCitationFile("inst/CITATION", meta = packageDescription("surveyframe"))`):

- title to "surveyframe: Survey Instrument Workflows" (drop "for R", match the
  corrected DESCRIPTION Title).
- Read the version from `meta$Version` (with a `utils::packageVersion()` fallback
  when `meta` is unavailable) so the note never goes stale on a future bump.
- Keep author, year (2026), and url.

### JSS editor review items (received 2026-06)

The JSS editor returned the submission without sending it to full review. The
invitation to revise and resubmit identified specific package defects that must
be corrected before resubmission. These ship with 0.3.2.

Full revision checklist is in `jss-paper/CLAUDE.md` (public repo). Package items:

#### S3 methods on sub-classes

The editor ran `methods(class = "sf_choices")` and received no output. All
sub-classes must have `print`, `format`, and `summary` methods. The `sframe`
class already has these in `R/sframe_methods.R`. The sub-classes have none.

File created: `R/sf_component_methods.R` (commit 80e4040). Classes covered:

- [x] `sf_choices`
- [x] `sf_item`
- [x] `sf_scale`
- [x] `sf_branch`
- [x] `sf_check`
- [x] `sf_model`

#### lavaan in Suggests

- [x] Add `lavaan` to `Suggests` in `DESCRIPTION`. Done (commit 80e4040).
- [x] Wrap all lavaan-dependent code in `requireNamespace()` guards. No executable
  `lavaan::` calls exist in `R/`; only string literals and `\dontrun` examples.
- [x] Confirm `psych` guards are already consistent. Confirmed.

#### Replication script (`replicate.R`)

- [x] Add `export_static_survey()` call, wrapped in `if (interactive()) { }`. Done
  (commit 519454b on dev branch). `render_results()` also added and guarded.
- [x] Audit every other interactive-only call and wrap accordingly. Done.
- [x] Remove any `str()` calls. No `str()` calls were present.

#### Static survey rendering

- [x] Attention check items render with a different answer layout than regular
  Likert items. Fixed in `inst/static_survey/template.html` (commit be2ed94):
  `checkItemIds` set from `SF.checks`; `renderItem()` forces Likert layout for
  any check item that has a choice set.

#### Response collection demo

- [ ] The end-to-end path (static survey submission to CSV download to
  `read_responses()`) must be demonstrable without interactive mode. Add a
  bundled one-row example CSV or show the path clearly in the replication script.

### Not a fix: the two remaining `\dontrun` blocks

The reviewer also asked to replace `\dontrun` with `\donttest`. This was already
addressed at 0.3.0: seven of nine examples were converted. The two that remain
(`read_sheet_responses` requires Google auth; the `cfa_syntax` block calls
`lavaan`, which is not a declared dependency) are the documented legitimate
exceptions (missing API keys / missing additional software). Converting them to
`\donttest` would make CRAN run them and fail. They stay `\dontrun`. No action.

Note: once `lavaan` is added to `Suggests` (JSS item above), the `cfa_syntax`
block can move to `\donttest`. Assess at that time.

### Other 0.3.2 candidates (low effort, no code risk)

- The deferred professor-review doc items (Prof-1 to Prof-5, Prof-9, Prof-10)
  listed under v0.3.1 below can fold into this doc pass if 0.3.2 goes ahead.

---

## v0.3.2 GUI co-review (in progress, 2026-06-14)

A UI and UX co-review of every graphical entry point, because 0.3.2 ships with
the JSS manuscript and a reviewer must not hit a broken or misleading GUI. The
row-by-row tracker is `demo/slides_review_table.md` (Status and Code/UI/UX
columns). Package changes are committed on `main` as 07d0608 (not yet pushed).
All 368 tests pass.

### SurveyBuilder — DONE (`inst/builder/survey_builder.html`)

- Plan/Run/Report tabs now differ: Run preview drops syntax-only methods, Report
  outline adds the models section, each tab carries a caption naming its R
  function. Tabs relabelled "Run preview" and "Report outline".
- Fixed a cardHtml crash on single-variable plans (jsonlite auto_unbox produced a
  scalar; added asArr() and trim guards).
- Added drag-reorder of plan cards on the Plan tab.
- Added two client-side exports that match the R functions byte for byte:
  "Export survey" (mirrors export_static_survey) and "Generate collector (.gs)"
  (mirrors export_google_sheet). Both templates are single-sourced from
  inst/static_survey/{template.html,collector_template.gs} and inlined by
  data-raw/inline_static_template.R. NOTE: data-raw is gitignored on main, so
  that dev script lives only in the local working tree. Re-run it after editing
  either template or the builder.
- Logo resize fixed across builder previews and the static survey header
  (height + width:auto + object-fit, not paired max-height/max-width).
- Embedded a brand logo in the input-types demo; added 36 analysis plans + 2
  models to the input-types demo and 34 plans + 2 models to the tourism demo.
- Enlarged the settings button, rewrote the Google Sheets steps for first-time
  users, and removed all mojibake from the file.
- Added vignettes/deploying-and-collecting.Rmd (GitHub Pages / Blogger + Sheets).

### Static survey — DONE (`inst/static_survey/template.html`)

- Logo resize fix; progress bar now shows "Page X of Y", respects show_progress,
  hidden on single-page surveys (was stuck at 100%).
- Demo split into 3 pages with Section 1/2/3 breaks aligned to pages;
  conversational mode still one item per screen.
- Wired the page-level required-error banner; added a mobile @media block.
- Added a "Built with surveyframe" footer (branding). Relabelled the demo header
  / title / progress so each architectural slot is distinct.

### SurveyStudio — DONE (`inst/shiny/app.R`)

- Removed the "Build Survey" screen (design lives in the builder); studio lands
  on Open Instrument, opening a .sframe goes to Preview. builder_meta() falls
  back to rv$builder$meta so opened instruments keep description/authors.
- render block now threads through the draft pipeline (state_from_instrument →
  compose → validate_draft → sf_instrument), so welcome/logo/thank-you survive.
- Preview screen renders the REAL static survey in an iframe via
  export_static_survey() (identical to the deployed/exported HTML).
- Export tab cleaned to .sframe + HTML report only (survey HTML / .gs / deploy
  belong to the builder).
- Dashboard tab integrated INLINE (Overview / Items / Scales / Data, base-R
  charts) wired to rv$instrument + rv$responses, ported from launch_dashboard().
- "Load sample survey and responses" button + "Download sample CSV" on Upload.
- Fixed empty Reliability / Analysis Plan / Export: custom-JS tab switching
  suspended hidden outputs; added suspendWhenHidden=FALSE to the screen content
  outputs. Quality Dashboard elaborated (clarified Flagged, added Clean,
  straight-lining, completion time, duplicates). Variable catalog excludes
  section_break/text_block. Stage labels aligned ("Run preview"/"Report outline").

### HTML report — DONE (`R/reporting.R`, `inst/templates/report.qmd`)

- Fixed the Quarto render: it was failing (output-dir vs report_files/libs
  mismatch broke embed-resources) and silently falling back to the plain
  internal HTML. Now renders with wd set to the render dir, then copies out.
- Tables formatted; added Response distributions plots (item bar charts, scale
  histograms) to both report.qmd and the no-Quarto fallback (base64 PNGs, base
  graphics + openssl, no new deps).
- TOC moved left; table cell padding; wide tables scroll (table display:block
  overflow-x). All numerics rounded to 2 decimals. Fixed chunks that emitted raw
  markdown (added #| output: asis to missing/descriptives/reliability).

### Still pending before CRAN check

- **Standalone dashboard** `inst/shiny/dashboard/app.R`: its views are now inline
  in the studio (overlap, see "Obsolete?" below). It is clean of mojibake and
  unchanged this arc. Decide keep-as-is vs deprecate; for 0.3.2 keep (exported
  API, removing breaks compat). A light sanity check is still worthwhile.
- **Shiny survey module** `R/survey_module.R`: code guard done, no interactive
  pass. Low priority (narrow surface).
- Commit the uncommitted package changes (reporting.R, studio_builder.R, app.R,
  template.html, report.qmd, survey_builder.html, input_types demo, the man page,
  the gui-overview vignette) on main; push when asked.
- `devtools::document()` is current (sframe_builder_validate_draft gained a
  render param). NEWS.md needs a 0.3.2 entry covering all the GUI/report work.
- Rebuild tarball, `R CMD check --as-cran` (0/0/<=1 NOTE), update cran-comments,
  win-builder. No new hard or Suggests deps were added.

### Done cross-cutting

- Mojibake sweep: clean across all of inst/ and R/ (grep "â" returns nothing).
- Code-only guards (earlier): launch_studio.R, dashboard.R, survey_module.R
  blocking examples to `\dontrun{}`; render_survey.R donttest assigned;
  sf_branch.R version pin removed.

### Deferred to v0.3.4+ (not 0.3.2)

- **Reference/citation system to a .bib file.** The APA citations are hardcoded
  in `.sframe_citations` (R/analysis_plan.R). Move them to a `.bib` pulled at
  render time so references update centrally. Clean path: Quarto-native
  (`bibliography:` + `@key` + an APA CSL) for `render_report` (the runners
  already carry citation keys); `render_results` and the HTML fallback need an
  R-side formatter (base `bibentry()`/`format(style = "text")`, or a guarded
  RefManageR). No native bib reader without a new dependency, so this is not a
  0.3.2 change. For 0.3.2 the citations are correct (current title, live version)
  and render as italics. Tracked in portfolio-planner
  `19_v034_v039_implementation.md`.

### Obsolete / redundant after changes

- The studio's old "Build Survey" screen: REMOVED.
- `launch_dashboard()` / `inst/shiny/dashboard/app.R` now overlaps the studio's
  integrated Dashboard tab. Not removed (exported since 0.3.1; removing is a
  breaking change). Candidate for soft-deprecation in a later release, or keep as
  the lightweight standalone read-only explorer. No action for 0.3.2.

---

## v0.3.0 — Published on CRAN (accepted 2026-05-21)

All work below this line is part of a separate v0.3.0 lifecycle and is
recorded here for reference only. The CRAN package at 0.3.0 is stable.

### What shipped in 0.3.0

- Core S3 system: sf_instrument(), sf_item(), sf_choices(), sf_scale(),
  sf_branch(), sf_check(), sf_model(), sf_construct(), sf_path(),
  sf_covariance(), sf_indirect(), add_model(), validate_model()
- SHA-256 serialisation: write_sframe(), read_sframe(), validate_sframe()
- Shiny survey rendering: render_survey(), survey_module_ui(),
  survey_module_server()
- Static HTML survey export: export_static_survey()
- Visual tools: launch_builder(), launch_studio(), launch_dashboard()
- Demo launchers: launch_builder_demo(), launch_studio_demo(),
  launch_dashboard_demo()
- Response pipeline: read_responses(), read_sheet_responses(),
  export_google_sheet()
- Analysis: score_scales(), descriptives_report(), missing_data_report(),
  quality_report(), outlier_report(), assumption_report(), posthoc_report(),
  reliability_report(), item_report(), efa_report(), efa_solution(),
  validity_report(), cfa_syntax(), cfa_lavaan_syntax(), efa_syntax(),
  sem_lavaan_syntax(), seminr_syntax(), run_analysis_plan(), sample_size_plan()
- Reporting: codebook_report(), render_report(), render_results(),
  model_report_template()
- Demo data: sframe_demo_data(), sframe_input_types_demo_data()
- 354 tests passing; 3 hard imports only (jsonlite, rlang, openssl)
- Six vignettes, 13 item types, full branching and quality pipeline

### CRAN submission history for 0.3.0

First submission 2026-05-16. Human reviewer requested three changes.
Resubmitted 2026-05-21 with:
1. Title "for R" removed.
2. sframe unquoted; 'Shiny' quoted in DESCRIPTION.
3. \dontrun{} replaced with \donttest{} across 9 functions; 2 kept
   (read_sheet_responses requires Google auth; cfa_syntax lavaan block
   requires lavaan which is not declared).
Accepted 2026-05-21.

---

## v0.3.1 — In development, not yet submitted to CRAN

### Completed

#### Bug fixes (Google Sheets round-trip)

All six fixes sit on the static survey to Google Sheets to R loop. Commit
6245143 (2026-05-31) covers A through F. Tests in
tests/testthat/test-0.3.1-fixes.R (14 tests, all passing).

| ID | File changed | What was fixed |
|----|--------------|----------------|
| A | inst/static_survey/template.html | Header region added. Logo (with correct MIME type) and institution name now render above the welcome screen in exported surveys. Previously absent. |
| B | R/export_static_survey.R | Falls back to instrument$render$google_sheets_endpoint when endpoint_url argument is NULL. Builder-configured endpoint now honoured on export without repeating it in R. |
| C | inst/static_survey/template.html | Submission row key renamed from response_id to respondent_id. Aligns the survey CSV, the Apps Script collector, and read_responses(). |
| C2 | R/google_sheets.R | export_google_sheet() expands matrix items to one column header per sub-item (item_id__sub). Matrix answers now reach the Sheet. |
| D | R/google_sheets.R | read_sheet_responses() passes meta_cols = "started_at". Warning on every read is gone. |
| E/F | inst/builder/survey_builder.html, R/render_survey.R, inst/static_survey/template.html | logo_media_type stored alongside logo_base64 when a logo is uploaded. JPEG and GIF logos now display with the correct MIME type in all three render paths. |

#### Serialisation bug fix (uncommitted at last review, now applied)

R/read_write_sframe.R: sframe_serialization_payload() now wraps the items,
choices, scales, branching, checks, and models collections in unname() before
serialisation. Without this, an instrument whose component lists carry names
(for example, items built with Map() that attach the item ID as the list name,
as the rewritten main vignette does) serialised those collections as keyed JSON
objects instead of arrays. On read_sframe() the recomputed hash did not match
the stored hash, raising an integrity error. Verified with a Map()-built
round-trip test. This is why the main vignette failed to knit before the fix.

#### Version and changelog

- DESCRIPTION: Version bumped to 0.3.1.
- NEWS.md: 0.3.1 section rewritten to cover the six collection fixes, the
  serialisation fix, the user-experience fixes, and the documentation rewrite.

#### Documentation rewrite

Main vignette (vignettes/surveyframe.Rmd) rewritten (commits 221eb3e, dc894bb):
- Questionnaire and concept adopted from Sharafuddin, Madhavan & Wangtueai
  (2024), Administrative Sciences, 14(11), 273, doi:10.3390/admsci14110273.
  Citation block added to the vignette and to the instrument description.
- Destination-specific wording removed (no "Thailand"). Generic "tourism
  services" naming so the example transfers to any context.
- Item wording adopted from the published questionnaire: 46 rated items across
  9 constructs (DMRE 5, DMAU 5, DMEU 5, DMPV 5, DSQA 4, DSQT 5, DSUQ 11, TS 3,
  BI 3) plus 9 demographic items.
- Analysis plan declares 5 research questions (RQ1-RQ5: two correlations, two
  regressions, one Mann-Whitney group comparison).
- Builds the sframe, exports the static survey and Google Sheets script,
  generates 60 simulated responses with set.seed(2024) for offline demo,
  runs quality checks, scoring, reliability, analysis plan, and renders
  the report.
- read_sheet_responses() live workflow shown with eval=FALSE so the vignette
  builds on CRAN without a network connection.
- Demonstrates Fix B (endpoint stored on instrument) and Fix D
  (meta_cols = "started_at") in working code.

README.md updated: CRAN badge added, install.packages("surveyframe") leads
installation section, "already have data" CSV path and browseVignettes()
pointer added.

#### Brand system (commit fd073bd)

Full brand set from surveyframe_brand_system_final placed and applied.
Source files remain in surveyframe_v_0.3.1/Patch_Files/ (gitignored, dev only).

Palette: Navy #0B3A78 (primary), Teal #16B3B1 (secondary/accent),
Dark text #13325B, Light accent #EAF4F7.

Files placed:

| Location | Contents | Used by |
|---|---|---|
| man/figures/logo.png and logo.svg | Package logo | pkgdown (auto-detected), CRAN |
| man/figures/readme-logo.png and readme-logo.svg | Wordmark + tagline | README.md |
| man/figures/hexsticker.png and hexsticker.svg | Hex sticker | Community, conferences |
| man/figures/pkgdown-wordmark*.png/svg | Wordmark variants | Future pkgdown hero |
| pkgdown/favicons/ | favicon.svg, 32/64/180/512px PNGs | pkgdown site tab |
| inst/shiny/www/ | Square icon and lockup | SurveyStudio |
| inst/shiny/dashboard/www/ | Square icon and lockup | Dashboard |
| .github/surveyframe-github-social.png/svg | Social preview | GitHub repository |

Applied in code:
- inst/shiny/app.R: square icon in SurveyStudio sidebar; colour #5b8dee
  updated to brand teal #16B3B1.
- inst/shiny/dashboard/app.R: square icon in dashboard header bar.
- _pkgdown.yml: primary #0B3A78, secondary #16B3B1.
- README.md: readme-logo.png added aligned right at top.

#### Build exclusions

.Rbuildignore updated to exclude:
- jss-paper/ (manuscript, not package code; was causing a top-level NOTE)
- pkgdown/ (website assets, not needed in installed package)
- man/figures/brand-preview.png (internal reference image)

#### JSS manuscript

surveyframe.Rnw and companion files in jss-paper/. Proofread against the
published CRAN package. All code errors corrected (psychometrics() replaced
with efa_report(), read_responses() argument fixed, render_report() signature
corrected). Author info and address block added. Forward references to
unpublished material removed. PDF compiled and committed (jss-paper/surveyframe.pdf).
One item still requires the author: institutional affiliation in \Address{}.

#### CRAN task view submissions

- **Psychometrics** PR #50: MERGED. surveyframe is now listed in the
  Classical Test Theory section of the Psychometrics task view.
  https://github.com/cran-task-views/Psychometrics/pull/50

- **OfficialStatistics** PR #44: CLOSED (rejected). Maintainer feedback:
  the package sits in the questionnaire-instrument-design and psychometrics
  space (scale reliability, EFA/CFA/SEM syntax, response collection) and
  does not cover complex sampling designs, design weights, calibration, or
  design-based variance estimation, which is the focus of that view.
  Maintainer suggested psychometrics or social-science survey-research
  context as a better fit. PR #44 closed; no action needed.
  https://github.com/cran-task-views/OfficialStatistics/pull/44

  Note: if v0.4 adds complex-survey design weighting (already in the roadmap),
  re-submit to OfficialStatistics at that point with a clear use case.

#### Repository restructure

Private development repo created: https://github.com/MohammedAliSharafuddin/surveyframe-dev
Public repo (surveyframe) stripped to installable package files only.
Dev-only files (version archives, cran-comments, roadmap, data-raw) are
gitignored from the public repo.

---

### Onboarding audit — applied fixes (commit c33d5cb)

Issue 1 (HIGH): stopifnot error messages replaced with sframe_check_instrument()
helper in conditions.R. Applied across 18 source files. New message tells user
to call sf_instrument() or read_sframe().

Issue 2 (HIGH): psych::alpha() and psych::omega() diagnostic output suppressed
with suppressMessages(suppressWarnings(capture.output(...))). Omega skipped
silently for scales with fewer than 3 items.

Issue 3 (FALSE POSITIVE): run_analysis_plan() is correctly silent during
assignment. Output seen in audit came from an unassigned tryCatch() call
at the top level of the test script.

Issue 4 (MEDIUM): README secondary install line updated to "To get unreleased
changes from the development version".

Issue 5 (LOW-MED): vignette write_sframe block changed from eval=FALSE to
eval=TRUE with tempfile() path.

Issue 6 (LOW): names(mr) added before mr$item_missing access in vignette.

Issue 7 (MED): sf_instrument() @examples now includes a complete analysis_plan
block with id, research_question, method, and roles.

Issue 8 (LOW): "Version 0.3 adds..." removed from package-level help page.

Issue 9 (LOW-MED): "Already have data?" section added to README with a
three-step path from CSV to scored analysis.

Issue 10 (MED): browseVignettes("surveyframe") added to README.

## Professor-level review — applied fixes (commit c33d5cb+)

Issues identified by review as professor of quantitative methods, survey
research, and psychology. All within v0.3.1 scope (no new features).

Applied (commit c33d5cb and the follow-up working set):
- Prof-6: Quality report flagging note added to simulate section in vignette.
- Prof-7: mr$apa shown after item_missing access.
- Prof-8: $prompt field shown in results loop.
- Prof-11: Alpha 0.70 threshold sentence added after print(rr).
- Prof-13: run_analysis_plan error message de-coupled from SurveyBuilder
  (R/analysis_plan.R, points at instrument$analysis_plan first).
- Prof-12: parallel analysis suggested_nfactors documented in efa_report
  @description (R/psychometrics.R, man/efa_report.Rd regenerated).

Deferred to a later 0.3.x doc pass (not yet applied, low effort, no code risk):
- Prof-1: Add assumption_report() between scoring and analysis plan in vignette.
- Prof-2: Expand alpha interpretation note to include omega preference.
- Prof-3: Add efa_report() call to main vignette workflow.
- Prof-4: Document scored= interaction with pre-scored data.
- Prof-5: Demonstrate validity_report() in main vignette.
- Prof-9: Show file.size(output) after render_results() in vignette.
- Prof-10: Format scale means as a table in vignette.

Test suite: 368 tests passing (was 354 at 0.3.0; the 14 new tests are in
tests/testthat/test-0.3.1-fixes.R covering fixes A through F).

## 0.3.1 SUBMITTED to CRAN on 2026-06-02

Submitted. Awaiting CRAN's decision email. Status of the pre-submission checks:

#### Blocking (all cleared)

- [x] **R CMD check --as-cran on surveyframe_0.3.1.tar.gz**: 0 errors, 0
      warnings, 1 NOTE on local Ubuntu (R 4.6.0). The NOTE is the incoming
      feasibility short-update-interval note. 368 tests pass, all vignettes
      knit. One local quirk: a full check that runs donttest examples hangs on
      the launch_dashboard() Shiny launcher, so the clean local check was run
      with _R_CHECK_DONTTEST_EXAMPLES_=FALSE, matching win-builder and CRAN
      incoming. The launcher donttest examples are a future-patch cleanup, not a
      blocker (0.3.0 shipped them identically).
- [x] **Win-builder**: R-release and R-devel, both 0 errors, 0 warnings, 1 NOTE.
- [x] **cran-comments.md** updated with the verified results and the
      update-interval justification. Pasted a focused version into the CRAN
      comment field.
- [ ] **Codecov badge**: still to confirm or remove. Not a submission blocker.

#### Non-blocking but recommended before submission

- [x] **JSS paper ready**: \Address{} filled with both authors (Sharafuddin and
      Madhavan), affiliations, and ORCID. orcidlink icons in the author block.
      Software-comparison prose humanised. Compiled to 17 pages, 0 LaTeX errors,
      checked against the JSS author and style guides. Submission package is the
      PDF, the surveyframe_0.3.1 tarball, and replicate.R. Pending the author's
      upload to jstatsoft.org.
- [ ] **GitHub social preview**: manually upload
      .github/surveyframe-github-social.png via GitHub Settings >
      Social preview on the repository page.
- [ ] **pkgdown site**: trigger pkgdown build after 0.3.1 is accepted on
      CRAN so the site reflects the new logo, brand colours, and vignettes.

#### Submission comment to paste on the CRAN form

```
This is a patch release fixing six defects on the static-survey to
Google Sheets to R round-trip:

1. export_static_survey() now renders the header logo and institution
   name from render$header.
2. export_static_survey() now falls back to the instrument's stored
   render$google_sheets_endpoint when endpoint_url is not supplied.
3. The static survey now posts the respondent identifier as
   respondent_id, matching the Apps Script collector and read_responses().
4. export_google_sheet() now includes matrix sub-item columns in the
   Apps Script header row.
5. read_sheet_responses() now declares started_at as a meta column and
   no longer warns on every read.
6. Survey logos now keep their original MIME type so JPEG and GIF logos
   display correctly in the builder, Shiny renderer, and static export.

Documentation: main vignette rewritten as a complete four-stage workflow.
All other vignettes updated. No new exported functions or statistical
methods. No new bundled datasets.
```

---

## Brand system outstanding tasks

### For v0.3.1 (can be applied before or after submission, no CRAN impact)

- [ ] Upload `.github/surveyframe-github-social.png` via GitHub Settings >
      Social preview.
- [ ] Run pkgdown::build_site() after 0.3.1 CRAN acceptance to publish the
      updated documentation with new logo and brand colours.

### Deferred to v0.4

- **SurveyBuilder HTML topbar** (`inst/builder/survey_builder.html`, line 483):
  `<header class="topbar">` currently contains only text. Replace with the
  Shiny lockup PNG or SVG. Deferred because the builder HTML is a single
  large file and the change carries regression risk.
- **pkgdown hero section**: `man/figures/pkgdown-wordmark-tagline.png` is
  placed but not yet wired into a pkgdown layout. Add a custom hero block
  via `pkgdown/extra.css` or a Bootstrap 5 layout override.
- **Static survey template header styling**: the header region added in Fix A
  reads from the instrument. Consider adding a thin branded top bar in the CSS
  using the brand palette for surveys that have no logo set.

---

## v0.4 scope (not for 0.3.x)

No new features in 0.3.x. All of the following wait for v0.4.

- MCDM input fields, AHP pairwise-comparison matrices.
- DEMATEL direct-influence matrices, thresholding, causal diagram export.
- TOPSIS, VIKOR, PROMETHEE, ELECTRE planning.
- Higher-order constructs and multi-group SEM planning.
- Measurement invariance testing.
- Diagram-based model builder.
- Complex-survey design weighting.
- JASP and jamovi export helpers.
- Advanced SEM and PLS-SEM execution (PLS-SEM execution is on the roadmap;
  seminr syntax generation is already available in v0.3.0).
- pkgdown hero section with wordmark-tagline layout.
- SurveyBuilder HTML topbar branding.

---

## Ecosystem notes

- surveyframe is the source of truth for both Ethos and Ethos Pro.
  asrda-r is deferred indefinitely.
- ASRDA textbook: early draft. Will be written after the JSS paper is
  accepted so the book can cite a published reference.
- JSS paper: submitted 2026-06-02 (OJS 6454). Editor returned without full
  review 2026-06; invited to revise and resubmit. Manuscript and package changes
  required. See jss-paper/CLAUDE.md (public repo) for the full revision checklist.
  The package changes ship with 0.3.2 (v0.3.2 section above).
- semScreenR: companion package for SEM data screening. Natural pipeline:
  cfa_syntax() output feeds into semScreenR before lavaan::cfa()
