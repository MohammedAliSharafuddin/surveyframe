# surveyframe 0.3.2 — Co-Review and Slide Table

**Purpose:** Two-column checklist for MAS and Claude co-review before CRAN submission.
Every row maps a review step to the source file(s) and classifies the review type in the
**Code / UI / UX** column. The slide cross-reference for the adoption deck
(`demo/surveyframe_user_demo.qmd`) is kept at the bottom of this file.

Review phases follow the order a full-stack R developer uses when preparing a submission:
build infrastructure first, then public API layer by layer from the bottom up, then
inst/ assets, vignettes, and tests last.

**Code / UI / UX column:** what kind of review the row needs.
*Code* = R source, data, build, docs. *UI* = visual presentation of a GUI.
*UX* = interaction and workflow of a GUI.

**Status column:**

- **PASS** — reviewed and verified (or fixed and verified) this round.
- **PARTIAL** — a code-level fix landed, but the full GUI UI/UX pass is still pending.
- **PENDING** — not yet reviewed.
- *(blank)* — not started.

---

## Phase 1 — Build infrastructure

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 1 | `DESCRIPTION` | Title case, no period; Description quotes 'Shiny', '.sframe'; Depends R >= 4.1.0; Imports exactly 3 (jsonlite, rlang, openssl); Suggests complete; Encoding UTF-8; Language en-GB; URL and BugReports reachable | Code | |
| 2 | `NAMESPACE` | All S3 methods registered; all exported functions present; importFrom lines match surveyframe-package.R; no stray exports | Code | |
| 3 | `.Rbuildignore` | Binary files (PDF, DOCX) excluded; dev scripts excluded; generated HTML excluded; vignette/tourism_report.html excluded | Code | PASS |
| 4 | `LICENSE` / `LICENSE.md` | MIT text present; LICENSE.md excluded from build | Code | |
| 5 | `NEWS.md` | 0.3.2 section present; changes accurate; no version or date claimed beyond 0.3.2 | Code | |
| 6 | `cran-comments.md` | Excluded from build by .Rbuildignore; will be updated after R CMD check | Code | |

---

## Phase 2 — Package entry points and documentation

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 7 | `R/surveyframe-package.R` | `@description` matches DESCRIPTION; workflow steps match exported functions; `importFrom` lines match NAMESPACE; `"_PACKAGE"` sentinel present | Code | |
| 8 | `README.md` | Install instructions correct; badges live; workflow steps correct; no broken links; UK spelling | Code | |

---

## Phase 3 — Core infrastructure

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 9 | `R/conditions.R` | `sframe_check_instrument()` used consistently by exported functions; typed condition classes present; `sframe_require_*()` guards use `rlang::check_installed()` | Code | |
| 10 | `R/utils.R` | `htmltools_escape()` escapes all four HTML characters; `sframe_as_data_frame()` correct; no stray exports | Code | |

---

## Phase 4 — Component constructors

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 11 | `R/sf_choices.R` | Constructor sets class `sf_choices`; all 3 named choice set helpers present; validation rejects invalid lengths; `@export` on public functions only | Code | |
| 12 | `R/sf_item.R` | All 11 item types accepted by `type` arg; `@export` on `sf_item()` only; required fields validated; `scale_id` / `choice_set` cross-references not yet validated here (that is validate_sframe's job) | Code | |
| 13 | `R/sf_scale.R` | `scoring` arg accepts `"mean"` and `"sum"`; `reverse` items validated as subset of `items`; class set correctly | Code | |
| 14 | `R/sf_branch.R` | Operator set complete (`==`, `!=`, `<`, `>`, `<=`, `>=`, `%in%`); class set correctly; exported; no hard-coded version pin in docs | Code | PASS |
| 15 | `R/sf_check.R` | Three check types: `attention`, `instructional`, `trap`; class set correctly; `pass_values` validation deferred to `quality_report()`; timing checks are timestamp-based, not a declared `sf_check` type | Code | |

---

## Phase 5 — S3 methods

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 16 | `R/sf_component_methods.R` | `print`, `format`, `summary` defined for `sf_choices`, `sf_item`, `sf_scale`, `sf_branch`, `sf_check`, `sf_model`; registered in NAMESPACE; output is human-readable; `@export` only on the generic methods | Code | |
| 17 | `R/sframe_methods.R` | `print.sframe`, `format.sframe`, `summary.sframe` defined; output shows item count, scale count, analysis plan count; registered in NAMESPACE | Code | |

---

## Phase 6 — Model layer

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 18 | `R/model_layer.R` | `sf_model()`, `sf_construct()`, `sf_path()`, `sf_covariance()`, `sf_indirect()` constructors; `validate_model()` checks; `cfa_lavaan_syntax()`, `sem_lavaan_syntax()`, `seminr_syntax()` generate strings only — no lavaan or seminr import; `cfa_syntax()` is backward-compatible wrapper; `add_model()` attaches to instrument | Code | |

---

## Phase 7 — Assembly and validation

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 19 | `R/sf_instrument.R` | `sf_instrument()` accepts all component types; class `sframe` set; components stored correctly; examples runnable without Shiny | Code | |
| 20 | `R/validate_sframe.R` | Validates item–choice cross-references; validates scale item membership; validates branch target item IDs; validates check item IDs; validates analysis-plan role references; validates model references; returns typed condition on failure | Code | |

---

## Phase 8 — Serialisation

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 21 | `R/read_write_sframe.R` | `write_sframe()` strips list names before JSON; SHA-256 hash written; `read_sframe()` verifies hash; hash mismatch gives typed error; round-trip test passes for Map-built instruments | Code | |

---

## Phase 9 — Deploy: static survey

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 22 | `R/render_survey.R` | `render_survey()` exported; all 11 item types rendered; branching logic applied; required-item validation present; multi-page logic; `open = FALSE` default for automated checks; Shiny guarded; donttest example assigned so `runApp()` does not block the check | Code | PASS |
| 23 | `R/export_static_survey.R` | `export_static_survey()` exported; standard and conversational modes; logo and institution from `render$header`; Google Sheets endpoint fallback from `render$google_sheets_endpoint`; `open = FALSE` default; output is valid HTML; builder in-browser export verified byte-parity with this function | Code | PASS |
| 24 | `inst/static_survey/template.html` | All 11 item types rendered client-side; branching logic in JS; required-field validation; progress bar; welcome and thank-you screens; CSV download on submit; JSON POST when `endpoint_url` set; mobile-responsive; SHA-256 JS fallback for file:// origins | UI / UX | PARTIAL — logo resize fixed; full UI/UX pass pending |

---

## Phase 10 — GUI builder

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 25 | `R/builder.R` | `launch_builder()` exported; `open = FALSE` default; standalone file opened via file:// with no injection; `launch_builder_demo()` injects demo JSON; `\donttest{}` on examples that open a browser | Code | PASS |
| 26 | `R/studio_builder.R` | `sframe_builder_state_from_instrument()`, `sframe_builder_validate_draft()` exported; used by SurveyStudio startup; no side effects on load | Code | |
| 27 | `R/launch_studio.R` | `launch_studio()` exported; preloaded instrument, responses, and CSV path accepted; `open = FALSE` / `launch.browser` control; `launch_studio_demo()` exported; Shiny guarded; blocking launcher example switched to `\dontrun{}` | Code | PARTIAL — code guard done; Studio UI/UX pending |
| 28 | `inst/builder/survey_builder.html` | Build, Preview, Analyse, Settings tabs functional; Plan/Run/Report tabs distinct with captions; plan cards render and reorder; Export survey and Generate collector buttons work client-side; logo resize; settings button visible; Sheets steps clear; no mojibake; SHA-256 hash matches R writer; JSON round-trips | UI / UX | PASS |
| 29 | `inst/shiny/app.R` | SurveyStudio: `requireNamespace("shiny")` check; explicit `shiny::` prefixes; Plan/Run/Report parity with builder; 36-plan demo; logo resize; upload handlers validate extension, size, content | UI / UX | PARTIAL — Run-stage filter fixed; full pass pending |

---

## Phase 11 — Shiny module and dashboard

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 30 | `R/survey_module.R` | `survey_module_ui()` and `survey_module_server()` exported; `digest::digest()` guarded with `rlang::check_installed("digest", ...)`; reactive return value `NULL` until submit; `on_submit` callback fires before reactive; blocking example switched to `\dontrun{}` | Code | PARTIAL — code guard done; module UI/UX pending |
| 31 | `R/dashboard.R` | `launch_dashboard()` exported; `launch_dashboard_demo()` exported; Shiny guarded; `outputOptions(suspendWhenHidden = FALSE)` on Items and Scales tabs; `dashboard_parse_date()` tries 6 format templates; all `shiny::` prefixed; blocking example switched to `\dontrun{}` | Code | PARTIAL — code guard done; dashboard UI/UX pending |
| 32 | `inst/shiny/dashboard/app.R` | `requireNamespace("shiny")` check; explicit `shiny::` prefixes; download button uses `sprintf` for theme colour; quality rows colour-coded by `flag_class`; date parsing delegates to `dashboard_parse_date()` | UI / UX | PENDING |

---

## Phase 12 — Collection

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 33 | `R/read_responses.R` | `read_responses()` exported; `strict = FALSE` allows partial column sets; meta columns (`respondent_id`, `started_at`, `submitted_at`) handled; display-only items (`section_break`, `text_block`) not required | Code | |
| 34 | `R/google_sheets.R` | `export_google_sheet()` exported; reads single-source `collector_template.gs`; Apps Script uses JSON-encoded literals (no code injection); rejects missing/over-large/non-object POST bodies; `read_sheet_responses()` exported; `started_at` declared as meta column; guarded with `rlang::check_installed("googlesheets4", ...)` | Code | PASS |

---

## Phase 13 — Quality

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 35 | `R/quality_report.R` | `quality_report()` exported; attention check pass/fail logic correct; timing thresholds applied; typed `sframe_quality_report` class returned; `print.sframe_quality_report` registered | Code | |

---

## Phase 14 — Scoring and psychometrics

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 36 | `R/score_scales.R` | `score_scales()` exported; mean and sum scoring correct; reverse coding applied before scoring; missing items warned with `sframe_warn_scoring()` | Code | |
| 37 | `R/psychometrics.R` | `reliability_report()` exported; psych guarded; McDonald's omega skipped silently for fewer than 3 items; `efa_report()`, `efa_solution()` exported; `validity_report()` exported; `item_report()` exported; typed return classes registered in NAMESPACE | Code | |

---

## Phase 15 — Analysis

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 38 | `R/analysis_plan.R` | `run_analysis_plan()` exported; all 22 methods in registry; `sample_size_plan()` exported; `assumption_report()` exported; `posthoc_report()` exported; each runner returns `method`, `result`, `summary`, `prompt`, `reference` fields | Code | |
| 39 | `R/statistics_reports.R` | Individual runners for each method; MASS and nnet guarded; effect sizes present for all tests; APA summary strings; no `set.seed()` at package level | Code | |

---

## Phase 16 — Reporting

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 40 | `R/reporting.R` | `codebook_report()`, `render_report()`, `render_results()` exported; HTML escaping applied to all user-supplied strings; APA table formatting (horizontal rules only); significance footnote auto-appended; Quarto render cleans temp dirs with `on.exit()`; no lavaan or seminr imports | Code | |
| 41 | `inst/templates/report.qmd` | Valid Quarto YAML; reads instrument and results RDS files from temp path; renders without internet; no hard-coded paths | Code | |

---

## Phase 17 — Demo data and helpers

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 42 | `R/demo_helpers.R` | `sframe_demo_data()`, `sframe_input_types_demo_data()` exported; return correct classes; `launch_builder_demo()`, `launch_studio_demo()`, `launch_dashboard_demo()` exported; all examples safe for `R CMD check` | Code | PASS |
| 43 | `inst/extdata/surveyframe_input_types_demo.sframe` | Valid JSON; hash verifies with `read_sframe()`; all 11 item types present; 36 analysis plans and 2 models; embedded brand logo; round-trips without error | Code | PASS |
| 44 | `inst/extdata/surveyframe_input_types_responses.csv` | Column names match item IDs in demo instrument; meta columns present; no PII | Code | |
| 45 | `inst/extdata/tourism_services_demo.sframe` | Valid JSON; hash verifies; all component types present; 34 analysis plans and 2 models; matches main vignette | Code | PASS |
| 46 | `inst/extdata/tourism_services_responses.csv` | Column names match tourism instrument; meta columns present | Code | |

---

## Phase 18 — Vignettes

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 47 | `vignettes/surveyframe.Rmd` | Builds offline; analysis runs on simulated/bundled data; `eval = FALSE` on data-collection step; no hard-coded paths; outputs match current 0.3.2 API | Code | |
| 48 | `vignettes/building-survey-instrument.Rmd` | All constructors used match current API; examples run without Shiny | Code | |
| 49 | `vignettes/analysing-survey-responses.Rmd` | Uses bundled data; all functions match current exports | Code | |
| 50 | `vignettes/scale-reliability-validity.Rmd` | psych guarded with `if (requireNamespace(...))` or `\donttest{}`; all functions present | Code | |
| 51 | `vignettes/efa-cfa-sem-pls-syntax.Rmd` | Syntax generation only; no lavaan/seminr execution; all syntax functions present | Code | |
| 52 | `vignettes/surveybuilder-gui-overview.Rmd` | `eval = FALSE` or `\donttest{}` on browser-launch calls; no Shiny execution in vignette | Code | |
| 52a | `vignettes/deploying-and-collecting.Rmd` | New deployment guide: GitHub Pages and Blogger hosting, Apps Script collector, endpoint linking, read-back; all deploy chunks `eval = FALSE`; knits offline | Code | PASS |

---

## Phase 19 — Tests

| # | File | What to check | Code / UI / UX | Status |
|---|------|---------------|----------------|--------|
| 53 | `tests/testthat/test-core.R` | Core constructors and round-trip tests; all 368 tests pass; no skipped blocks that mask failures | Code | PASS |
| 54 | `tests/testthat/test-component-methods.R` | `print`, `format`, `summary` output verified for all 6 component classes and `sframe`; Change 2 of 0.3.2 | Code | PASS |
| 55 | `tests/testthat/test-input-types-demo.R` | All 11 item types load and score correctly from bundled demo instrument | Code | PASS |
| 56 | `tests/testthat/test-v03-analysis-models.R` | All 22 analysis methods return correct structure; effect sizes present | Code | PASS |
| 57 | `tests/testthat/test-builder-analysis.R` | Builder state functions work; draft validation rejects invalid drafts | Code | PASS |
| 58 | `tests/testthat/test-0.3.1-fixes.R` | All 0.3.1 bug fixes verified: logo MIME type, round-trip hash, column names, meta columns | Code | PASS |

---

## Phase 20 — CRAN submission

| # | Step | What to check | Status |
|---|------|---------------|--------|
| 59 | `R CMD build .` | Clean tarball; no binary files; no dev scripts; no generated HTMLs; size under 5 MB | RE-RUN after GUI work |
| 60 | `R CMD check --as-cran` | 0 errors, 0 warnings, at most 1 NOTE | RE-RUN after GUI work |
| 61 | Win-builder R-release | Clean | |
| 62 | Win-builder R-devel | Clean | |
| 63 | `cran-comments.md` | Results from 60–62 recorded accurately | |
| 64 | CRAN submission form | Paste from cran-comments.md | |

---

## Co-review progress (updated 2026-06-15)

- **Done and signed off:** SurveyBuilder (row 28), static survey
  `template.html` (24), SurveyStudio `app.R` (29), and the HTML report
  (`reporting.R` 40, `report.qmd` 41). Plus the R functions they touch
  (22, 23, 25, 27, 34, 42, 43, 45). All 368 tests pass. Mojibake clean across
  inst/ and R/.
- **Pending before CRAN check:** light sanity check of the standalone dashboard
  app (32) — its views are now inline in the studio Dashboard, so it overlaps;
  keep for 0.3.2 (exported API). Survey module (30) had a code guard only.
- **Obsolete/redundant after changes:** the studio's old "Build Survey" screen
  was removed; `launch_dashboard()` / dashboard app (31, 32) now overlaps the
  studio's inline Dashboard tab (soft-deprecate later, keep for 0.3.2).
- **Next:** commit the uncommitted package changes; NEWS.md 0.3.2 entry; rebuild
  tarball and `R CMD check --as-cran` (59, 60); cran-comments (63); win-builder.

---

## Slide number cross-reference (deck order)

For the adoption PowerPoint, find any slide by its position in `surveyframe_user_demo.qmd`.

| Deck slide | Slide title | Review row(s) |
|------------|-------------|---------------|
| 1 | Title divider | — |
| 2 | The researcher's workflow problem | 7, 8 |
| 3 | surveyframe solves this in five steps | 7 |
| 4 | What you can do with surveyframe | 1, 7 |
| 5 | Chapter: Part 1 — Design | divider |
| 6 | The five building blocks | 11–15 |
| 7 | Chapter: Item types | divider |
| 8 | Item type 1 — Likert (5-point) | 11, 12 |
| 9 | Item type 1 — 7-point Likert | 11, 12 |
| 10 | Item type 2 — Single choice | 11, 12 |
| 11 | Item type 3 — Multiple choice | 11, 12 |
| 12 | Item type 4 — Numeric input | 12 |
| 13 | Item type 5 — Short text | 12 |
| 14 | Item type 6 — Long text (textarea) | 12 |
| 15 | Item type 7 — Date | 12 |
| 16 | Item type 8 — Slider | 12 |
| 17 | Item type 9 — Star rating | 12 |
| 18 | Item type 10 — Matrix / rating grid | 12 |
| 19 | Item type 11 — Rank order | 12 |
| 20 | Chapter: Choice sets | divider |
| 21 | Choice sets — 5-point agree-disagree | 11 |
| 22 | Choice sets — 7-point agree-disagree | 11 |
| 23 | Choice sets — frequency, satisfaction, quality | 11 |
| 24 | Chapter: Scales | divider |
| 25 | Scales — mean scoring | 13 |
| 26 | Scales — sum scoring and reverse coding | 13 |
| 27 | Chapter: Skip logic and quality checks | divider |
| 28 | Branch rules — conditional skip logic | 14 |
| 29 | Quality checks — attention item | 15 |
| 30 | Quality checks — timing | 15 |
| 31 | Chapter: Measurement model | divider |
| 32 | sf_model() — measurement model declaration | 18 |
| 33 | Assemble and validate the instrument | 19, 20 |
| 34 | Save and reload — SHA-256 integrity | 21 |
| 35 | (new) Print and summary — sframe object | 17 |
| 36 | (new) Print and summary — components | 16 |
| 37 | Chapter: Part 2 — The GUI Builder | divider |
| 38 | SurveyBuilder — Build tab | 25, 28 |
| 39 | SurveyBuilder — item inspector | 25, 28 |
| 40 | SurveyBuilder — Analyse tab | 26, 28 |
| 41 | SurveyBuilder — Settings | 25, 28 |
| 42 | Chapter: Part 3 — Deploy | divider |
| 43 | Export — Standard presentation mode | 23 |
| 44 | Export — Conversational presentation mode | 23 |
| 45 | The welcome screen | 24 |
| 46 | Question pages — Likert items | 22 |
| 47 | Respondent chooses an answer | 22 |
| 48 | Required item validation | 22 |
| 49 | Thank-you screen and CSV download | 24 |
| 50 | Mobile — welcome screen | 24 |
| 51 | Mobile — question page | 24 |
| 52 | (new) SurveyStudio launcher | 27, 29 |
| 53 | (new) Shiny survey module | 30 |
| 54 | (new) Google Sheets collection | 34 |
| 55 | Chapter: Part 4 — Collect | divider |
| 56 | Read responses | 33 |
| 57 | Quality report — attention and timing | 35 |
| 58 | Chapter: Part 5 — Analyse | divider |
| 59 | Score your scales | 36 |
| 60 | Reliability — Cronbach's alpha | 37 |
| 61 | EFA readiness | 37 |
| 62 | Construct validity | 37 |
| 63 | Chapter: Analysis plan methods | divider |
| 64 | Declare a research question | 38 |
| 65 | Pearson correlation | 38, 39 |
| 66 | Spearman correlation | 38, 39 |
| 67 | Kendall's tau correlation | 38, 39 |
| 68 | Independent samples t-test | 38, 39 |
| 69 | Paired t-test | 38, 39 |
| 70 | Mann-Whitney U | 38, 39 |
| 71 | One-way ANOVA | 38, 39 |
| 72 | Kruskal-Wallis | 38, 39 |
| 73 | Linear regression | 38, 39 |
| 74 | Logistic regression (binary) | 38, 39 |
| 75 | Chi-square test | 38, 39 |
| 76 | Chapter: CFA, SEM, and PLS-SEM syntax | divider |
| 77 | CFA syntax — lavaan | 18 |
| 78 | SEM syntax — lavaan with structural paths | 18 |
| 79 | PLS-SEM syntax — SEMinR | 18 |
| 80 | Chapter: Part 6 — Report | divider |
| 81 | Analysis results report | 40 |
| 82 | Full study report | 40, 41 |
| 83 | Instrument codebook | 40 |
| 84 | Interactive response dashboard | 31, 32 |
| 85 | Chapter: Get started | divider |
| 86 | Install and run the guided demo | 42–44 |
| 87 | Six vignettes | 47–52 |
| 88 | What makes surveyframe different | 7, 8 |
| 89 | Closing divider | — |

*New slides (35, 36, 52, 53, 54) do not yet exist in the deck. Add them before the PowerPoint build.*

---

*Generated 2026-06-14. Status updated 2026-06-14 after the SurveyBuilder GUI co-review.
Review order: Phase 1 to Phase 20. Tick Status column as you go.*
