# surveyframe 0.2.0

## SurveyBuilder

* Added `launch_builder()` for browser-based instrument authoring, preview,
  and analysis-plan setup.
* Bundled the production SurveyBuilder HTML with autosave, undo/redo,
  drag-to-reorder, inspector editing, and SHA-256 hashing for `.sframe`
  exports.

## Extended item types

* Added `matrix`, `slider`, `ranking`, `rating`, `section_break`, and
  `text_block` item types to `sf_item()`.
* Preserved v0.2 item fields through `.sframe` write and read roundtrips.

## Shiny renderer

* Extended `render_survey()` to support the richer v0.2 item set.
* Added welcome and thank-you flows, conversational mode, ranking and rating
  widgets, and CSV persistence hooks.

## Analysis plan execution

* Added `run_analysis_plan()` to execute research-question-driven analyses
  stored on the instrument.
* Added `render_results()` to generate HTML summaries of analysis-plan output.
* Preserved `analysis_plan` in the instrument object and `.sframe`
  serialisation.

## Unified reporting

* `render_report()` now accepts `output_path`, includes analysis-plan content,
  and falls back to an internal HTML renderer when Quarto is unavailable.
* Report rendering now handles sparse-data reliability failures more cleanly.

## Google Sheets

* Added `export_google_sheet()` to generate an Apps Script collector.
* Added `read_sheet_responses()` to load collected responses back into
  surveyframe.

## Documentation

* Added and updated vignettes for the end-to-end workflow and studio usage.
* Refreshed README and pkgdown configuration for the v0.2 feature set.

## Tests

* Expanded automated coverage for SurveyBuilder, v0.2 item types,
  analysis-plan execution, `.sframe` roundtrips, reporting, and Google Sheets
  helpers.

## Breaking changes

* None.

# surveyframe 0.1.0

## First release

surveyframe 0.1.0 introduces the complete v0.1 workflow.

### New features

* `sf_instrument()`, `sf_item()`, `sf_choices()`, `sf_scale()`,
  `sf_branch()`, `sf_check()`: constructor family for building typed
  instrument objects.
* `validate_sframe()`: full structural validation with eight distinct checks
  and custom condition classes.
* `write_sframe()` and `read_sframe()`: save and load instruments as UTF-8
  JSON with SHA-256 integrity hashing.
* `render_survey()`: deploy any instrument as a Shiny survey with branching
  logic.
* `launch_studio()`: open SurveyStudio, a six-screen Shiny interface for the
  full pipeline.
* `read_responses()`: load CSV or data frame responses with column contract
  validation against the instrument.
* `quality_report()`: attention check evaluation, straight-lining detection,
  item and respondent missingness, and duplicate ID checking.
* `score_scales()`: composite scoring with reverse coding, minimum valid
  item thresholds, and mean or sum methods.
* `reliability_report()`: Cronbach's alpha and McDonald's omega per scale.
* `item_report()`: item-total correlations, floor and ceiling proportions,
  and descriptive statistics per scale.
* `efa_report()`: KMO adequacy, Bartlett's test, and parallel analysis
  diagnostics. Does not fit an EFA solution.
* `cfa_syntax()`: generate `lavaan` CFA model syntax from the instrument's
  scale structure.
* `codebook_report()`: structured codebook as a tibble-based object.
* `render_report()`: parameterised Quarto HTML report covering codebook,
  quality, and reliability sections.

### Architecture

* The `sframe` S3 class with `print`, `summary`, and `format` methods.
* Custom condition classes: `sframe_validation_error`, `sframe_import_error`,
  `sframe_branching_error`, `sframe_quality_warning`,
  `sframe_missing_data_warning`, `sframe_scoring_warning`.
* Test coverage across the exported workflow, including report rendering.

### Phase 1 hardening

* `render_survey()` now enforces required visible items, honours help text and
  rendering hints, and can append submitted responses to CSV with
  `started_at` and `submitted_at` metadata.
* `quality_report()` now computes timing diagnostics when start and submit
  timestamps are available, including threshold-based speed checks.
* `score_scales()` now supports weighted mean and weighted sum composites.
* `render_report()` now accepts ordinary output paths, renders a working
  Quarto report through the installed template, and includes the instrument
  SHA-256 hash in the reproducibility note.
