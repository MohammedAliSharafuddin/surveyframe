# surveyframe v0.2 TODO

This checklist reflects the repository state verified on April 21, 2026.

## Completed in this pass

- [x] Move the v0.2 package code into the main repository root
- [x] Add `launch_builder()` and bundle the HTML SurveyBuilder
- [x] Preserve `analysis_plan` in `sf_instrument()`, `.sframe` writing, and
      `.sframe` reading
- [x] Make the builder-generated SHA-256 hash compatible with `read_sframe()`
- [x] Upgrade `sf_item()` to the v0.2 item set
- [x] Upgrade `render_survey()` to the richer v0.2 renderer
- [x] Add `run_analysis_plan()`, `render_results()`,
      `export_google_sheet()`, and `read_sheet_responses()`
- [x] Extend `render_report()` and the Quarto template for analysis-plan
      reporting
- [x] Add v0.2 tests in the root package
- [x] Run the full local test suite: `235` passing, `0` failures, `0` warnings
- [x] Run full local `devtools::check()`: `0 errors`, `0 warnings`, `0 notes`
- [x] Verify the roundtrip:
      builder-style `.sframe` -> `read_sframe()` -> `render_survey()` ->
      `render_report()`

## Remaining work to complete v0.2

### 1. Builder and renderer parity

- [ ] Decide whether the builder preview should reuse the Shiny renderer or
      remain a separate browser renderer
- [ ] Make preview behavior match `render_survey()` for:
      required items, branching, matrix items, ranking, rating, and page flow
- [ ] Add regression tests for any preview/generator differences found during
      manual review
- [ ] Review the builder inspector and settings flow for UI friction and reduce
      the highest-friction interactions

### 2. Browser-level verification

- [ ] Add browser automation for the HTML SurveyBuilder
- [ ] Add at least one end-to-end browser test that:
      builds or loads an instrument, exports `.sframe`, loads it in R, and
      completes a rendered survey path
- [ ] Capture screenshots for the builder and rendered survey at desktop and
      mobile widths

### 3. SurveyStudio relationship

- [ ] Decide whether SurveyStudio remains a separate shell or becomes a host
      for the HTML SurveyBuilder
- [ ] Remove duplicated build paths or make their responsibilities explicit
- [ ] Align SurveyStudio wording and navigation with the v0.2 workflow

### 4. Google Sheets collection path

- [ ] Decide the supported contract:
      helper-only collector export, or direct survey submission to Apps Script
- [ ] If direct submission stays in scope, wire the survey generator to
      `render$google_sheets_endpoint`
- [ ] Add tests for the chosen Google Sheets path
- [ ] Narrow the builder UI copy if direct submission is deferred

### 5. Static deployment decision

- [ ] Decide whether static HTML survey deployment remains a v0.2 deliverable
- [ ] If yes, define the generator/export format and implement it
- [ ] If no, remove or defer the UI affordances and roadmap language that imply
      it is already available

### 6. Documentation

- [ ] Rewrite `README.md` around the v0.2 workflow
- [ ] Add the builder entry point to the vignette and pkgdown site
- [ ] Document the difference between:
      `launch_builder()`, `launch_studio()`, and `render_survey()`
- [ ] Document the analysis-plan workflow from design to report
- [ ] Document the Google Sheets helper flow clearly

### 7. Release finish

- [ ] Push the verified v0.2 baseline to `main`
- [ ] Review fresh GitHub Actions runs after the push
- [ ] Fix any CI regressions that appear on macOS, Windows, or Linux
- [ ] Draft a v0.2 release note and release checklist

## Definition of done for v0.2

- [ ] The builder, `.sframe` loader, and survey generator work as one coherent
      workflow
- [ ] The preview and generated survey behavior are aligned or intentionally
      separated and documented
- [ ] The Google Sheets path is either fully wired or clearly scoped down
- [ ] Browser-level UI verification exists
- [ ] Local checks pass and GitHub Actions are green on the final branch
