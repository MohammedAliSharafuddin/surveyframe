# surveyframe (development version)

# surveyframe 0.2.0

## SurveyBuilder and analysis planning

surveyframe 0.2.0 adds the first phase of the v0.2 workflow.

### New features

* `launch_builder()`: open the browser-based SurveyBuilder for instrument
  authoring, preview, and analysis-plan setup.
* New `sf_item()` types: `matrix`, `slider`, `ranking`, `rating`,
  `section_break`, and `text_block`.
* `run_analysis_plan()` and `render_results()`: execute and report
  research-question-driven analyses stored on the instrument.
* `export_google_sheet()` and `read_sheet_responses()`: generate a Google
  Sheets Apps Script collector and read responses back into the package.
* `render_report()` now accepts `output_path` and can include analysis-plan
  results in the Quarto report.

### Integration

* `.sframe` serialization now preserves `analysis_plan`.
* `render_survey()` now supports the richer v0.2 item set, welcome and
  thank-you flows, conversational mode, ranking and rating widgets, and
  CSV persistence.
* The bundled SurveyBuilder now writes a SHA-256 hash compatible with
  `read_sframe()`.

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
