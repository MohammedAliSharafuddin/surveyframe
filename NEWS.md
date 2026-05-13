# surveyframe 0.3.0

## New features

### Static HTML survey export

* Added `export_static_survey()`. This produces a single, self-contained
  HTML file that runs the survey in any modern browser without a Shiny
  server or an internet connection. All thirteen item types are fully
  rendered (Likert, single choice, multiple choice, matrix, numeric, text,
  long text, date, slider, rating, ranking, section break, text block).
  Branching logic, required-field validation, a progress bar, welcome and
  thank-you pages are all handled in client-side JavaScript. On submission
  the browser downloads a per-respondent CSV file. An optional
  `endpoint_url` argument adds a parallel JSON POST to any serverless
  endpoint (Google Apps Script, Netlify function, etc.).

  The exported file is suitable for hosting on GitHub Pages, Netlify, or
  any static file server, and can also be shared directly as an e-mail
  attachment and opened from disk.

  The SHA-256 hash written into `.sframe` files by `write_sframe()` and by
  the SurveyBuilder HTML is computed using the same canonicalisation
  algorithm, so instruments round-trip correctly between the browser and R.

### Interactive response dashboard

* Added `launch_dashboard()`. Opens a five-panel Shiny dashboard for
  exploring collected response data alongside the instrument definition,
  without modifying either. The panels are:

  | Panel | Content |
  |---|---|
  | Overview | Response count, date range, instrument metadata |
  | Items | Per-item bar charts, histograms, and frequency tables |
  | Scales | Scale score distributions with mean overlay |
  | Quality | Attention-check pass rates |
  | Raw data | Scrollable response table with CSV download |

  When called without a `responses` argument the dashboard opens in
  metadata-only mode showing instrument structure.

### Shiny survey module

* Added `survey_module_ui()` and `survey_module_server()`. These allow a
  survey to be embedded inside a larger Shiny application as a first-class
  module. `survey_module_server()` returns a `reactive` that holds `NULL`
  until the form is submitted, then returns the response as a named list
  keyed by item ID.

  ```r
  ui <- fluidPage(survey_module_ui("s1"))
  server <- function(input, output, session) {
    resp <- survey_module_server("s1", instrument = instr)
    observeEvent(resp(), { saveRDS(resp(), "response.rds") })
  }
  ```

  An optional `on_submit` callback fires immediately on submission, before
  any `observeEvent()` elsewhere in the app.

### Extended analysis plan tests

`run_analysis_plan()` now implements four additional tests used by the
SurveyBuilder's test dropdown:

* `anova_one`: One-way ANOVA with eta-squared effect size. When the
  result is significant and there are more than two groups, Tukey HSD
  post-hoc output is included in the result object.
* `t_test_pair`: Paired-samples t-test with Cohen's d_z.
* `wilcoxon_pair`: Wilcoxon signed-rank test with r effect size.
* `regression_logistic_binary`: Binary logistic regression with
  McFadden R-squared and an overall model chi-square test. The full
  coefficient table is returned for interpretation.

All four runners produce an APA-formatted summary string and an
interpretation `prompt` field to guide write-up.

## Bug fixes

* `launch_builder(open = TRUE)` opens the SurveyBuilder HTML in the system's
  default browser via `utils::browseURL()`.
* `R/studio_builder.R` contains three fully implemented internal
  functions (`sframe_builder_empty_state`, `sframe_builder_state_from_instrument`,
  `sframe_builder_validate_draft`) used by SurveyStudio startup and draft
  validation.
* SHA-256 hashing in the SurveyBuilder HTML includes a pure-JavaScript
  fallback for environments where `crypto.subtle` is unavailable on
  `file://` origins, including common Firefox `file://` configurations.
  Saving a `.sframe` file from the builder now always succeeds.
* The SurveyBuilder's `rqSuggest` box now appears with an icon and a
  plain-language recommendation when two or more variables are selected in
  the RQ modal.
* The undo and redo buttons in the SurveyBuilder topbar are now correctly
  disabled when their respective history stacks are empty.

## Security hardening

* `export_google_sheet()` now writes Google Apps Script using JSON-encoded
  JavaScript literals instead of interpolating instrument metadata directly
  into executable code. The generated endpoint also rejects missing,
  over-large, and non-object JSON POST bodies.
* SurveyStudio upload handlers now validate uploaded `.sframe` and `.csv`
  files by extension, size, and text-content checks before passing them to
  import functions.
* `read_sframe()` now validates the top-level `.sframe` payload structure
  before hash verification and object reconstruction.
* Internal HTML report generation now applies escaping consistently to
  report titles, instrument metadata, citations, and effect labels.
* Quarto report rendering now cleans temporary render directories and RDS
  files with `on.exit()` even when rendering fails.

## Documentation

* `validate_sframe()`, `score_scales()`, `codebook_report()`, `cfa_syntax()`,
  and `launch_builder(open = FALSE)` have fully runnable examples.
* Added `cran-comments.md` with platform list, dependency justification,
  bundled-asset description, and a `\dontrun{}` use justification table.

---

# surveyframe 0.1.0

* Initial release.
* Core S3 object system: `sf_instrument()`, `sf_item()`, `sf_choices()`,
  `sf_scale()`.
* Serialisation: `write_sframe()`, `read_sframe()` with SHA-256 integrity
  checking.
* Shiny survey renderer: `render_survey()`.
* Static SurveyBuilder HTML: `launch_builder()`.
* Response reader: `read_responses()`.
