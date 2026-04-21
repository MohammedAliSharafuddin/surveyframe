# Changelog

## surveyframe 0.2.0

### SurveyBuilder

- Added
  [`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md)
  for browser-based instrument authoring, preview, and analysis-plan
  setup.
- Bundled the production SurveyBuilder HTML with autosave, undo/redo,
  drag-to-reorder, inspector editing, and SHA-256 hashing for `.sframe`
  exports.

### Extended item types

- Added `matrix`, `slider`, `ranking`, `rating`, `section_break`, and
  `text_block` item types to
  [`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md).
- Preserved v0.2 item fields through `.sframe` write and read
  roundtrips.

### Shiny renderer

- Extended
  [`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md)
  to support the richer v0.2 item set.
- Added welcome and thank-you flows, conversational mode, ranking and
  rating widgets, and CSV persistence hooks.

### Analysis plan execution

- Added
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
  to execute research-question-driven analyses stored on the instrument.
- Added
  [`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md)
  to generate HTML summaries of analysis-plan output.
- Preserved `analysis_plan` in the instrument object and `.sframe`
  serialisation.

### Unified reporting

- [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
  now accepts `output_path`, includes analysis-plan content, and falls
  back to an internal HTML renderer when Quarto is unavailable.
- Report rendering now handles sparse-data reliability failures more
  cleanly.

### Google Sheets

- Added
  [`export_google_sheet()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_google_sheet.md)
  to generate an Apps Script collector.
- Added
  [`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md)
  to load collected responses back into surveyframe.

### Documentation

- Added and updated vignettes for the end-to-end workflow and studio
  usage.
- Refreshed README and pkgdown configuration for the v0.2 feature set.

### Tests

- Expanded automated coverage for SurveyBuilder, v0.2 item types,
  analysis-plan execution, `.sframe` roundtrips, reporting, and Google
  Sheets helpers.

### Breaking changes

- None.

## surveyframe 0.1.0

### First release

surveyframe 0.1.0 introduces the complete v0.1 workflow.

#### New features

- [`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md),
  [`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md),
  [`sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_choices.md),
  [`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md),
  [`sf_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_branch.md),
  [`sf_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_check.md):
  constructor family for building typed instrument objects.
- [`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md):
  full structural validation with eight distinct checks and custom
  condition classes.
- [`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
  and
  [`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md):
  save and load instruments as UTF-8 JSON with SHA-256 integrity
  hashing.
- [`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md):
  deploy any instrument as a Shiny survey with branching logic.
- [`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md):
  open SurveyStudio, a six-screen Shiny interface for the full pipeline.
- [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md):
  load CSV or data frame responses with column contract validation
  against the instrument.
- [`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md):
  attention check evaluation, straight-lining detection, item and
  respondent missingness, and duplicate ID checking.
- [`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md):
  composite scoring with reverse coding, minimum valid item thresholds,
  and mean or sum methods.
- [`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md):
  Cronbach’s alpha and McDonald’s omega per scale.
- [`item_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/item_report.md):
  item-total correlations, floor and ceiling proportions, and
  descriptive statistics per scale.
- [`efa_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_report.md):
  KMO adequacy, Bartlett’s test, and parallel analysis diagnostics. Does
  not fit an EFA solution.
- [`cfa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_syntax.md):
  generate `lavaan` CFA model syntax from the instrument’s scale
  structure.
- [`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md):
  structured codebook as a tibble-based object.
- [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md):
  parameterised Quarto HTML report covering codebook, quality, and
  reliability sections.

#### Architecture

- The `sframe` S3 class with `print`, `summary`, and `format` methods.
- Custom condition classes: `sframe_validation_error`,
  `sframe_import_error`, `sframe_branching_error`,
  `sframe_quality_warning`, `sframe_missing_data_warning`,
  `sframe_scoring_warning`.
- Test coverage across the exported workflow, including report
  rendering.

#### Phase 1 hardening

- [`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md)
  now enforces required visible items, honours help text and rendering
  hints, and can append submitted responses to CSV with `started_at` and
  `submitted_at` metadata.
- [`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md)
  now computes timing diagnostics when start and submit timestamps are
  available, including threshold-based speed checks.
- [`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md)
  now supports weighted mean and weighted sum composites.
- [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
  now accepts ordinary output paths, renders a working Quarto report
  through the installed template, and includes the instrument SHA-256
  hash in the reproducibility note.
