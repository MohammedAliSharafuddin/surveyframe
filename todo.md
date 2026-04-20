# surveyframe v0.2 TODO

This checklist reflects the repository state verified on April 21, 2026.

## Completed in this pass

Move the v0.2 package code into the main repository root

Add
[`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md)
and bundle the HTML SurveyBuilder

Preserve `analysis_plan` in
[`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md),
`.sframe` writing, and `.sframe` reading

Make the builder-generated SHA-256 hash compatible with
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)

Upgrade
[`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md)
to the v0.2 item set

Upgrade
[`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md)
to the richer v0.2 renderer

Add
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md),
[`export_google_sheet()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_google_sheet.md),
and
[`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md)

Extend
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
and the Quarto template for analysis-plan reporting

Add v0.2 tests in the root package

Run the full local test suite: `235` passing, `0` failures, `0` warnings

Run full local `devtools::check()`: `0 errors`, `0 warnings`, `0 notes`

Verify the roundtrip: builder-style `.sframe` -\>
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)
-\>
[`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md)
-\>
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)

## Remaining work to complete v0.2

### 1. Builder and renderer parity

Decide whether the builder preview should reuse the Shiny renderer or
remain a separate browser renderer

Make preview behavior match
[`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md)
for: required items, branching, matrix items, ranking, rating, and page
flow

Add regression tests for any preview/generator differences found during
manual review

Review the builder inspector and settings flow for UI friction and
reduce the highest-friction interactions

### 2. Browser-level verification

Add browser automation for the HTML SurveyBuilder

Add at least one end-to-end browser test that: builds or loads an
instrument, exports `.sframe`, loads it in R, and completes a rendered
survey path

Capture screenshots for the builder and rendered survey at desktop and
mobile widths

### 3. SurveyStudio relationship

Decide whether SurveyStudio remains a separate shell or becomes a host
for the HTML SurveyBuilder

Remove duplicated build paths or make their responsibilities explicit

Align SurveyStudio wording and navigation with the v0.2 workflow

### 4. Google Sheets collection path

Decide the supported contract: helper-only collector export, or direct
survey submission to Apps Script

If direct submission stays in scope, wire the survey generator to
`render$google_sheets_endpoint`

Add tests for the chosen Google Sheets path

Narrow the builder UI copy if direct submission is deferred

### 5. Static deployment decision

Decide whether static HTML survey deployment remains a v0.2 deliverable

If yes, define the generator/export format and implement it

If no, remove or defer the UI affordances and roadmap language that
imply it is already available

### 6. Documentation

Rewrite `README.md` around the v0.2 workflow

Add the builder entry point to the vignette and pkgdown site

Document the difference between:
[`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md),
[`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md),
and
[`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md)

Document the analysis-plan workflow from design to report

Document the Google Sheets helper flow clearly

### 7. Release finish

Push the verified v0.2 baseline to `main`

Review fresh GitHub Actions runs after the push

Fix any CI regressions that appear on macOS, Windows, or Linux

Draft a v0.2 release note and release checklist

## Definition of done for v0.2

The builder, `.sframe` loader, and survey generator work as one coherent
workflow

The preview and generated survey behavior are aligned or intentionally
separated and documented

The Google Sheets path is either fully wired or clearly scoped down

Browser-level UI verification exists

Local checks pass and GitHub Actions are green on the final branch
