# surveyframe Roadmap

## Scope

`surveyframe` is a workflow package for academic survey research in R. Its core
object is the `sframe` instrument, which carries item definitions, reusable
choice sets, scale structure, reverse-coding rules, branching logic,
design-time checks, analysis-plan metadata, and rendering settings through the
research workflow.

The package defines the instrument, validates it, serializes it, renders it,
reads response data back in, checks quality, scores scales, prepares
psychometric diagnostics, runs pre-planned analyses, and generates
reproducible outputs. Specialist analysis packages and external collection
platforms remain downstream tools.

### Included in the current v0.2 line

- Typed constructors for items, choice sets, scales, branching rules, checks,
  and the top-level `sframe` object
- `.sframe` JSON serialization with SHA-256 integrity hashing
- A browser-based HTML SurveyBuilder launched with `launch_builder()`
- A Shiny survey generator launched through `render_survey()`
- SurveyStudio as the Shiny workflow shell
- Response loading from CSV/data frames and Google Sheets
- Quality reporting, scale scoring, reliability diagnostics, item diagnostics,
  EFA readiness checks, and CFA syntax generation
- Analysis-plan execution with `run_analysis_plan()` and results rendering with
  `render_results()`
- Codebook generation and Quarto report rendering

### Outside the current v0.2 line

- Static HTML survey deployment from the builder
- Full parity between the SurveyBuilder preview and the Shiny survey renderer
- Direct Google Sheets submission from `render_survey()`
- SurveyStudio and SurveyBuilder as one unified authoring surface
- External platform import/export such as Qualtrics or REDCap
- Multilingual authoring workflows beyond basic metadata
- Multi-condition branching trees
- IRT and decision-science method engines
- AI-assisted survey authoring

## Current Status

Status below reflects the repository state verified on April 21, 2026.

### Verified and working

- The main repository now contains the v0.2 package code. The nested
  `surveyframe_v0.2/` folder was treated as source input and is ignored from
  the package build.
- `launch_builder()` is present in the root package and points to the bundled
  HTML SurveyBuilder in `inst/builder/survey_builder.html`.
- The bundled SurveyBuilder now computes a SHA-256 hash compatible with
  `read_sframe()`. Builder-style `.sframe` payloads round-trip through the R
  loader.
- `sf_item()` supports the v0.2 item set: `matrix`, `slider`, `ranking`,
  `rating`, `section_break`, and `text_block`.
- `sf_instrument()` and `.sframe` serialization now preserve `analysis_plan`.
- `render_survey()` has been upgraded to the richer v0.2 renderer with
  welcome and thank-you flows, conversational mode, ranking, rating, matrix
  inputs, CSV persistence, and required-field enforcement.
- `render_report()` accepts `output_path`, includes analysis-plan sections,
  and uses the stable Quarto rendering path already fixed on `main`.
- The Quarto template now tolerates small datasets that cannot support
  reliability estimation.
- `run_analysis_plan()`, `render_results()`, `export_google_sheet()`, and
  `read_sheet_responses()` are integrated into the root package.

### Verification results

- Local automated test suite: `235` passing, `0` failures, `0` warnings
- Full local `devtools::check()`: `0 errors`, `0 warnings`, `0 notes`
- Explicit roundtrip verified:
  - builder-style `.sframe` payload
  - `read_sframe()`
  - `render_survey()`
  - `render_report()`

### Gaps that still define the remaining v0.2 work

- The SurveyBuilder preview is a browser-side approximation. It does not reuse
  the Shiny renderer directly.
- SurveyStudio and SurveyBuilder remain separate UIs with overlapping purpose.
- The builder stores Google Sheets metadata, but `render_survey()` does not
  post responses to a Google Apps Script endpoint.
- The package still lacks browser-level automated tests for the HTML builder
  and the rendered survey UX.
- Static HTML survey deployment is still absent.

## Development Roadmap

### Phase 2A: Stabilize the integrated v0.2 baseline

Priority: immediate.

- Keep the root package green after the v0.2 merge.
- Add regression tests for builder-generated `.sframe` files and new item
  types.
- Review any remaining edge cases in report rendering, especially with sparse
  or malformed response data.
- Keep the package metadata, docs, and exports aligned with the integrated
  codebase.

### Phase 2B: Complete builder and generator parity

Priority: next.

- Decide whether the SurveyBuilder preview should become a thin wrapper around
  the Shiny renderer or whether a separate browser renderer will be maintained
  deliberately.
- Make the builder preview and `render_survey()` agree on required behavior,
  branching, paging, ranking, rating, matrix handling, and welcome/thank-you
  flows.
- Add browser-level UI tests for the SurveyBuilder and at least one end-to-end
  survey completion path.
- Review the UI density of the builder and simplify high-friction panels where
  needed.

### Phase 2C: Complete the collection integrations

Priority: after parity work starts.

- Decide the Google Sheets collection contract clearly:
  external collector helper only, or direct submission from the survey
  generator.
- If direct submission stays in scope, wire `render_survey()` or a static
  deployment target to the Apps Script endpoint stored in render metadata.
- Add validation and tests for the Google Sheets submission path.
- Define the static HTML deployment path if it remains part of the v0.2 goal.

### Phase 2D: Unify the user-facing workflow

Priority: before calling v0.2 complete.

- Decide the long-term relationship between SurveyStudio and SurveyBuilder.
- Either integrate the HTML builder into SurveyStudio or narrow the purpose of
  SurveyStudio so the package has one clear authoring story.
- Update the package docs so a first-time user understands when to use:
  `launch_builder()`, `launch_studio()`, and `render_survey()`.

### Phase 2E: Documentation and release finish

Priority: before tagging a v0.2 release.

- Rewrite the README and vignette around the v0.2 workflow.
- Update pkgdown navigation to surface the builder, analysis-plan functions,
  and Google Sheets helpers clearly.
- Add a v0.2 release checklist and release notes.
- Re-run full local checks and GitHub Actions on the final release candidate.

## Guardrails

- The `sframe` object remains the single source of truth.
- The package stays focused on survey workflow rather than becoming a general
  statistics environment.
- UI additions must strengthen the instrument-centered workflow.
- Any feature that cannot be exercised and verified end to end should be
  described narrowly and documented as incomplete until it is finished.
