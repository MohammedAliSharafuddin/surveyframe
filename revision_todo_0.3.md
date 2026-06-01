# surveyframe revision notes and to-do

Excluded from the CRAN build (via .Rbuildignore) and from the public repo
(via .gitignore). Lives only in the dev workspace.

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

## Before submitting 0.3.1 to CRAN

The following must be completed before running R CMD check --as-cran and
uploading to https://cran.r-project.org/submit.html.

#### Blocking

- [ ] **Run R CMD check --as-cran on surveyframe_0.3.1.tar.gz** and confirm
      0 errors, 0 warnings. A fresh check is required because the serialisation
      fix and the onboarding fixes landed after the last full check attempt
      (which was interrupted). devtools::test() passes 368/368 and all six
      vignettes knit cleanly against the reinstalled package. Expected from the
      full check: 1 NOTE only (CRAN incoming feasibility, "Days since last
      update").
- [ ] **Win-builder test**: upload surveyframe_0.3.1.tar.gz to
      https://win-builder.r-project.org/ and confirm 0 errors, 0 warnings.
- [ ] **Update cran-comments.md** with actual check results from both
      platforms before uploading. File is at the repo root (gitignored).
- [ ] **Codecov badge**: confirm the repository is connected at
      https://app.codecov.io/gh/MohammedAliSharafuddin/surveyframe.
      If not active, remove the Codecov badge from README.md to avoid a
      broken badge on CRAN.

#### Non-blocking but recommended before submission

- [ ] **JSS paper institutional address**: fill in the \Address{} block
      in jss-paper/surveyframe.Rnw (marked with %% TODO) before submitting
      to the Journal of Statistical Software.
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
- JSS paper: manuscript is in jss-paper/surveyframe.Rnw. Needs institutional
  address filled in before submission.
- semScreenR: companion package for SEM data screening. Natural pipeline:
  cfa_syntax() output feeds into semScreenR before lavaan::cfa().
