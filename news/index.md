# Changelog

## surveyframe 0.3.3

CRAN release: 2026-07-11

This release adds an opt-in plotting layer, fixes bugs surfaced by the
package’s first field deployment, and redesigns the survey-taking
experience. ggplot2 joins Suggests; hard dependencies are unchanged.

### Analysis and plotting

- New `plots` argument on
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
  (default `FALSE`). When `TRUE`, supported analysis blocks return a
  ggplot object in `$plot`: bar charts for frequency and chi-square
  blocks, and scatter plots with a regression overlay for correlation
  and regression blocks.
- New exported
  [`theme_surveyframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/theme_surveyframe.md),
  a publication-oriented ggplot2 theme with an accessible fixed-order
  series palette. All plots use it.
- Inferential runners return a `$table` data frame ready for
  [`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html); the HTML
  report shows these tables automatically.
- Frequency and cross-tab runners treat empty strings as missing values,
  so partially completed responses no longer form a blank category.
- Ranking items now export one column per option holding its rank
  (`item__option = 1` for the top choice), so ranks are directly
  analysable. Multiple-choice items likewise export one 0/1 column per
  option instead of a single comma-joined column.
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
  accepts the expanded columns for ranking, matrix, and multiple-choice
  items without warnings.
- [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
  now attaches each analysis block’s chart directly under its result
  table, in both the Quarto and internal HTML report paths, instead of
  tables and plots appearing in separate places.
- Likert items in the report’s response-distributions section get a
  diverging stacked bar chart (darkest at each pole, lightest next to
  neutral) instead of a plain frequency bar, so the direction and
  strength of opinion is visible at a glance.

### Survey experience

- A full redesign of the exported survey: larger serif question
  typography, bordered option cards with selection ticks, numbered
  Likert squares, restyled matrix, slider, and ranking blocks, and a
  slim top progress bar. Every colour derives from the instrument’s
  single theme colour, so one colour choice re-skins the whole survey.
  Touch targets meet a 44 pixel minimum on phones.
- Branching rules on one question now combine with AND, and hiding a
  controlling question also hides everything that depends on it, so
  screening logic behaves as declared even when answers change.
- Single-page surveys show answered-questions progress (for example “12
  of 44 answered”); numeric questions respect declared minimum and
  maximum bounds.
- Branching rules can now show and hide section breaks and text blocks,
  so a branched text block works as a screen-out message (“Sorry, you
  are not eligible”) and section headings disappear with their
  questions.
- A matrix question reflows into stacked, labelled row-cards below 600
  pixels instead of a table that needs horizontal scrolling to complete.
- The exported survey meets WCAG 2.2 AA on an instrumented audit: every
  input carries an accessible name, keyboard focus is visible on option
  cards, errors are announced to assistive technology, required
  questions are marked beyond colour, ranking items gain keyboard
  reorder buttons, headings are real headings, and all touch targets and
  text contrast meet the standard.

### Data collection

- Fixed a bug that silently blocked submissions from hosted surveys: the
  Google Apps Script POST now avoids the CORS preflight that Apps Script
  never answers. Collectors no longer emit columns for section breaks or
  text blocks.
- [`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md)
  gains a `meta_cols` argument for extra sheet columns a host
  application appends, and SurveyStudio’s dashboard now computes
  completion times from imported sheet responses.

### Model syntax

- [`sem_lavaan_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sem_lavaan_syntax.md)
  turns free-text path labels into valid lavaan parameter names (a label
  starting “H1:” becomes the parameter `H1`).
- [`seminr_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/seminr_syntax.md)
  output loads seminr and uses
  [`summary()`](https://rdrr.io/r/base/summary.html) accessors, so the
  generated code runs as pasted.
- [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
  accepts `pls_sem` as an alias for `seminr_syntax`.

### SurveyBuilder and report

- Opening a `.sframe` verifies and reports its SHA-256 integrity status.
- New choice questions start with a fresh option set, and editing shared
  options forks the set first, so options never leak between questions.
- The analysis-plan modal blocks using one variable in two roles, and
  the test suggester handles Likert items and multi-group comparisons
  sensibly.
- Reports print generated model syntax in code blocks and show
  reliability results as a table.
- “+ Add question” now opens the question-type picker instead of
  silently adding a Likert item, and the redundant icon-only button next
  to it is gone. Survey settings live only in the sidebar; the top bar
  no longer duplicates that entry point.

## surveyframe 0.3.2

CRAN release: 2026-06-17

This release corrects the package citation, completes the S3 method
surface for the component classes, and improves the graphical tools and
the HTML report. It adds no new exported functions, no new statistical
methods, and no new bundled datasets.

### Citation and methods

- `inst/CITATION` now reports the correct package title and reads the
  version dynamically from the package metadata, so the citation no
  longer pins an old version or an outdated title.
- Added [`print()`](https://rdrr.io/r/base/print.html),
  [`format()`](https://rdrr.io/r/base/format.html), and
  [`summary()`](https://rdrr.io/r/base/summary.html) methods for the
  component classes `sf_choices`, `sf_item`, `sf_scale`, `sf_branch`,
  `sf_check`, and `sf_model`, so each class now has a visible,
  documented S3 surface.
- `lavaan` is declared in `Suggests`. It is used only to fit the syntax
  produced by
  [`cfa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_syntax.md).
  The package itself generates syntax and never requires `lavaan` to be
  installed.

### Graphical tools

- SurveyBuilder exports a deployable survey in the browser through a new
  Export survey button, and generates the Google Sheets Apps Script
  collector through a Generate collector button. Both reuse the same
  templates the R functions use, so the output matches
  [`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md)
  and
  [`export_google_sheet()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_google_sheet.md).
- The builder Analyse tab shows three distinct stages: Plan, Run preview
  (the methods that need response data), and Report outline (analyses
  plus measurement models). Analysis plans can be reordered by dragging.
- The exported survey carries a “Built with surveyframe” footer, sizes a
  header logo consistently across aspect ratios, shows a page progress
  indicator only on multi-page surveys, and gains a mobile layout.
- SurveyStudio opens an instrument designed in the builder, previews the
  exact deployable survey in a frame, and analyses uploaded responses.
  The response dashboard, with an overview, item and scale
  distributions, and a raw-data table, is now built into the studio. A
  button loads the bundled sample survey and 120 responses. Survey
  design moved entirely to the builder.

### HTML report

- [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
  renders reliably through Quarto when it is installed. A path defect
  that made the Quarto render fail and fall back to the plain internal
  output is fixed.
- Reports include a response distributions section, with one chart per
  item and one per scale, in both the Quarto output and the built-in
  HTML fallback.
- Tables are formatted, wide tables scroll within the page, the table of
  contents sits on the left, and numeric values are rounded to two
  decimal places.

### Documentation

- Added the “Deploying a survey and collecting responses on free
  hosting” vignette, covering the Apps Script collector, GitHub Pages
  and Blogger hosting, and reading the responses back into R.

## surveyframe 0.3.1

CRAN release: 2026-06-02

This is a patch release. It fixes the static-survey to Google Sheets to
R collection loop, repairs a serialisation defect, and improves the
first-time user experience. There are no new exported functions, no new
statistical methods, and no new bundled datasets.

### Bug fixes

#### Data collection round-trip

- [`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md)
  now renders the header logo and institution name from `render$header`,
  so exported surveys match the Shiny renderer and the builder preview.
- [`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md)
  now falls back to the instrument’s `render$google_sheets_endpoint`
  when `endpoint_url` is not supplied, so a Google Sheets endpoint set
  in the builder is honoured on export.
- The static survey now posts the respondent identifier under the column
  name `respondent_id`, matching the Google Apps Script collector and
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md).
  The collection round-trip now preserves the identifier.
- [`export_google_sheet()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_google_sheet.md)
  now includes matrix sub-item columns (`item_id__sub`) in the Apps
  Script header row, so matrix answers are stored in the Sheet.
- [`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md)
  now declares `started_at` as a meta column and no longer raises a
  warning on every read.
- Survey logos now keep their original MIME type (`image/png`,
  `image/jpeg`, `image/gif`), so JPEG and GIF logos display correctly in
  the builder, the Shiny renderer, and the static export.

#### Serialisation

- [`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
  now strips list-level names from the item, choice, scale, branching,
  check, and model collections before serialisation. Instruments built
  with [`Map()`](https://rdrr.io/r/base/funprog.html) or other helpers
  that attach element names (for example, using item IDs as names)
  previously serialised those collections as keyed JSON objects rather
  than arrays. This produced a hash mismatch and an integrity error on
  [`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md).
  Saved instruments now round-trip correctly regardless of how the
  component lists were constructed.

### User experience

- Every exported function that takes an instrument now reports a clear,
  actionable message when passed something that is not an `sframe`
  object. The message points the user to
  [`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md)
  and
  [`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)
  instead of showing a raw
  [`inherits()`](https://rdrr.io/r/base/class.html) assertion failure.
- [`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md)
  no longer prints `psych` internal warnings to the console. McDonald’s
  omega is skipped silently for scales with fewer than three items,
  where the statistic is not meaningful.
- The error message from
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
  when no analysis plan is present now describes both the programmatic
  route (`instrument$analysis_plan`) and the visual SurveyBuilder route.

### Documentation

- Rewrote the main vignette (`surveyframe.Rmd`) as an end-to-end worked
  example: design the questionnaire, export it as a hosted survey with a
  Google Sheets backend, collect responses, score them, run the analysis
  plan, and render a report. The results section uses simulated
  responses so the vignette builds offline; a single
  [`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md)
  call connects the same workflow to live responses. The questionnaire
  and concept are adopted from Sharafuddin, Madhavan, and Wangtueai
  (2024, *Administrative Sciences*, 14(11), 273,
  <doi:10.3390/admsci14110273>), with generic destination wording so the
  example transfers to any tourism services context.
- Updated the supporting vignettes to reflect the research-design-first
  workflow where the instrument holds the questions, the analysis plan,
  and the measurement model.
- [`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md)
  examples now include a complete `analysis_plan` block.
- The README now leads with `install.packages("surveyframe")`, adds a
  short path for users who already have a response CSV, and points to
  `browseVignettes("surveyframe")`.

## surveyframe 0.3.0

CRAN release: 2026-05-27

The first CRAN release of the full workflow: a typed instrument object
carrying the questions, the analysis plan, and the measurement model,
with deployment, collection, analysis, and reporting built around it.

### New features

#### Analysis planning, survey statistics, and model syntax

- Added a role-based analysis-plan structure while preserving old
  `variables`/`test` analysis blocks. New plans can store `family`,
  `method`, `roles`, `options`, `hypotheses`, `decision_rule`,
  `reporting_references`, `status`, and `requires_data`.
- Added common survey analysis helpers:
  [`descriptives_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/descriptives_report.md),
  [`missing_data_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/missing_data_report.md),
  [`assumption_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/assumption_report.md),
  [`posthoc_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/posthoc_report.md),
  [`validity_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validity_report.md),
  and
  [`sample_size_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sample_size_plan.md).
- Expanded
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
  to dispatch the v0.3 method registry, including descriptives, missing
  data, sparse-table tests, related-sample tests, Kendall and partial
  correlations, two-way ANOVA, ANCOVA, repeated ANOVA, ordinal and
  multinomial logistic regression, mediation, moderation, and
  model-syntax output.
- Added a model specification layer:
  [`sf_construct()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_construct.md),
  [`sf_path()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_path.md),
  [`sf_covariance()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_covariance.md),
  [`sf_indirect()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_indirect.md),
  [`sf_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_model.md),
  [`validate_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_model.md),
  [`model_json()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/model_json.md),
  [`add_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/add_model.md),
  [`efa_solution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_solution.md),
  [`efa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_syntax.md),
  [`cfa_lavaan_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_lavaan_syntax.md),
  [`sem_lavaan_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sem_lavaan_syntax.md),
  [`seminr_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/seminr_syntax.md),
  and
  [`model_report_template()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/model_report_template.md).
  Syntax generation does not require `lavaan` or `seminr`.
- [`cfa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_syntax.md)
  remains available as a backward-compatible wrapper around
  [`cfa_lavaan_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_lavaan_syntax.md).
- SurveyBuilder Analyse mode now uses a three-panel Plan/Run/Report
  workspace with variable metadata badges, role-based variable
  assignment, method options, output preview, reporting references, and
  a table-based model builder. Significance level is shown only for
  inferential methods.

#### Static HTML survey export

- Added
  [`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md).
  This produces a single, self-contained HTML file that runs the survey
  in any modern browser without a Shiny server or an internet
  connection. All thirteen item types are fully rendered (Likert, single
  choice, multiple choice, matrix, numeric, text, long text, date,
  slider, rating, ranking, section break, text block). Branching logic,
  required-field validation, a progress bar, welcome and thank-you pages
  are all handled in client-side JavaScript. On submission the browser
  downloads a per-respondent CSV file. An optional `endpoint_url`
  argument adds a parallel JSON POST to any serverless endpoint (Google
  Apps Script, Netlify function, etc.).

  The exported file is suitable for hosting on GitHub Pages, Netlify, or
  any static file server, and can also be shared directly as an e-mail
  attachment and opened from disk.

  The SHA-256 hash written into `.sframe` files by
  [`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
  and by the SurveyBuilder HTML is computed using the same
  canonicalisation algorithm, so instruments round-trip correctly
  between the browser and R.

#### Interactive response dashboard

- Added
  [`launch_dashboard()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard.md).
  Opens a five-panel Shiny dashboard for exploring collected response
  data alongside the instrument definition, without modifying either.
  The panels are: Overview (response count, date range, instrument
  metadata), Items (per-item bar charts, histograms, and frequency
  tables), Scales (scale score distributions with mean overlay), Quality
  (attention-check pass rates), and Raw data (a scrollable response
  table with CSV download).

  When called without arguments the dashboard loads the bundled tourism
  services demo. When called with a user-supplied instrument and no
  `responses` argument, it opens in metadata-only mode showing
  instrument structure.

- Added
  [`sframe_demo_data()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo_data.md),
  [`sframe_input_types_demo_data()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_input_types_demo_data.md),
  [`launch_builder_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder_demo.md),
  [`launch_studio_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio_demo.md),
  and
  [`launch_dashboard_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard_demo.md)
  for CRAN-safe examples, training, and local GUI testing.

- Added a bundled input-types demo instrument and simulated response
  dataset for testing SurveyBuilder, SurveyStudio, the dashboard, and
  all supported item controls.

- [`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md)
  now accepts preloaded instruments, response data frames, CSV response
  paths, initial screen selection, host, port, and browser control.
  SurveyStudio reads these preloaded values during startup.

#### Shiny survey module

- Added
  [`survey_module_ui()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_ui.md)
  and
  [`survey_module_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_server.md).
  These allow a survey to be embedded inside a larger Shiny application
  as a first-class module.
  [`survey_module_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_server.md)
  returns a `reactive` that holds `NULL` until the form is submitted,
  then returns the response as a named list keyed by item ID.

  ``` r

  ui <- fluidPage(survey_module_ui("s1"))
  server <- function(input, output, session) {
    resp <- survey_module_server("s1", instrument = instr)
    observeEvent(resp(), { saveRDS(resp(), "response.rds") })
  }
  ```

  An optional `on_submit` callback fires immediately on submission,
  before any
  [`observeEvent()`](https://rdrr.io/pkg/shiny/man/observeEvent.html)
  elsewhere in the app.

#### Extended analysis plan tests

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
now implements four additional tests used by the SurveyBuilder’s test
dropdown:

- `anova_one`: One-way ANOVA with eta-squared effect size. When the
  result is significant and there are more than two groups, Tukey HSD
  post-hoc output is included in the result object.
- `t_test_pair`: Paired-samples t-test with Cohen’s d_z.
- `wilcoxon_pair`: Wilcoxon signed-rank test with r effect size.
- `regression_logistic_binary`: Binary logistic regression with McFadden
  R-squared and an overall model chi-square test. The full coefficient
  table is returned for interpretation.

All four runners produce an APA-formatted summary string and an
interpretation `prompt` field to guide write-up.

### Bug fixes

- [`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
  validates the instrument and writes the validated object, preserving
  `meta$validated = TRUE` in the saved `.sframe` file.

- `.sframe` serialisation now includes a `models` field and continues to
  read older `.sframe` files where `models` is absent.

- [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
  no longer requires display-only items such as `section_break` and
  `text_block` to appear as response columns.

- [`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
  now checks model references, analysis-plan roles, invalid model IDs,
  duplicate model IDs, and model indicator/path integrity.

- `launch_builder(open = TRUE)` opens the SurveyBuilder HTML in the
  system’s default browser via
  [`utils::browseURL()`](https://rdrr.io/r/utils/browseURL.html).

- `R/studio_builder.R` contains three fully implemented internal
  functions (`sframe_builder_empty_state`,
  `sframe_builder_state_from_instrument`,
  `sframe_builder_validate_draft`) used by SurveyStudio startup and
  draft validation.

- SHA-256 hashing in the SurveyBuilder HTML includes a pure-JavaScript
  fallback for environments where `crypto.subtle` is unavailable on
  `file://` origins, including common Firefox `file://` configurations.
  Saving a `.sframe` file from the builder now always succeeds.

- The SurveyBuilder’s `rqSuggest` box now appears with an icon and a
  plain-language recommendation when two or more variables are selected
  in the RQ modal.

- The undo and redo buttons in the SurveyBuilder topbar are now
  correctly disabled when their respective history stacks are empty.

### Security hardening

- [`export_google_sheet()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_google_sheet.md)
  now writes Google Apps Script using JSON-encoded JavaScript literals
  instead of interpolating instrument metadata directly into executable
  code. The generated endpoint also rejects missing, over-large, and
  non-object JSON POST bodies.
- SurveyStudio upload handlers now validate uploaded `.sframe` and
  `.csv` files by extension, size, and text-content checks before
  passing them to import functions.
- [`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)
  now validates the top-level `.sframe` payload structure before hash
  verification and object reconstruction.
- Internal HTML report generation now applies escaping consistently to
  report titles, instrument metadata, citations, and effect labels.
- Quarto report rendering now cleans temporary render directories and
  RDS files with [`on.exit()`](https://rdrr.io/r/base/on.exit.html) even
  when rendering fails.

### Documentation

- [`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
  [`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md),
  [`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md),
  [`cfa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_syntax.md),
  and `launch_builder(open = FALSE)` have fully runnable examples.
- Reworked the vignette set into a coherent workflow covering instrument
  building, response analysis, reliability and validity, EFA/CFA/SEM/PLS
  syntax generation, and GUI usage.
- The demo launchers
  ([`launch_builder_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder_demo.md),
  [`launch_studio_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio_demo.md),
  and
  [`launch_dashboard_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard_demo.md))
  open in the browser with the demo instrument, scales, and analysis
  plan preloaded, so no manual file loading is needed.
- The interactive package demo (`demo("survey")`) walks through the
  whole workflow with step-by-step prompts.

### Dashboard and report polish

- The dashboard parses response dates in the common formats (ISO 8601,
  date-only, UK and US day orders) instead of erroring on non-standard
  strings, colour-codes quality rows by flag status, matches the
  download button to the active theme, and draws the Items and Scales
  charts as soon as their tabs open.
- HTML report tables use APA formatting, with horizontal rules only and
  a significance footnote added automatically when a p-value column is
  present.

## surveyframe 0.1.0

- Initial release.
- Core S3 object system:
  [`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md),
  [`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md),
  [`sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_choices.md),
  [`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md).
- Serialisation:
  [`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md),
  [`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)
  with SHA-256 integrity checking.
- Shiny survey renderer:
  [`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md).
- Static SurveyBuilder HTML:
  [`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md).
- Response reader:
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md).
