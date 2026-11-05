# Launch the SurveyStudio interface

Opens the SurveyStudio Shiny application, the visual interface for
working with an instrument. Its sidebar follows the study: open an
instrument, then Build (design it, plan its analysis and preview it),
Collect (set up collection and load the responses), Analyse (check their
quality, explore them, inspect reliability and run the plan), Report,
and Record (its references and amendments).

## Usage

``` r
launch_studio(
  instrument = NULL,
  responses = NULL,
  respondent_id = NULL,
  submitted_at = NULL,
  meta_cols = NULL,
  strict = TRUE,
  screen = "auto",
  port = NULL,
  host = "127.0.0.1",
  launch.browser = interactive(),
  demo = NULL
)
```

## Arguments

- instrument:

  An `sframe` object or NULL.

- responses:

  A data.frame, tibble, CSV file path, or NULL.

- respondent_id:

  Character or NULL. Response ID column when `responses` is a CSV path.

- submitted_at:

  Character or NULL. Submission time column when `responses` is a CSV
  path.

- meta_cols:

  Character vector or NULL. Metadata columns when `responses` is a CSV
  path.

- strict:

  Logical. Passed to
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
  when `responses` is a CSV path.

- screen:

  The screen to open on. One of `"auto"`, which picks by what you
  supply, or a screen name, given here with its sidebar label: `"open"`
  (Open Instrument), `"design"` (Design), `"preview"` (Preview),
  `"collect"` (Collect), `"responses"` (Responses), `"quality"`
  (Quality), `"dashboard"` (Explore), `"reliability"` (Reliability),
  `"analysis"` (Analyse), `"export"` (Report), `"references"`
  (References) or `"amendments"` (Amendments). `"data"` is accepted for
  `"responses"`.

- port:

  TCP port for the Shiny server.

- host:

  Host address passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

- launch.browser:

  Whether to open the browser automatically.

- demo:

  Optional. A demo name from
  [`sframe_list_demos()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_list_demos.md).
  Studio then opens with that demo's instrument and responses loaded, in
  place of `instrument` and `responses`, which must be left out.
  `"input_types"` uses every input type Studio supports.

## Value

Called for its side effect.

## Details

The Design screen holds the SurveyBuilder, and a save there becomes the
instrument Studio has open.
[`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md)
opens the builder on its own.

## See also

[`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md),
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md),
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)

Other entry points:
[`surveyframe-package`](https://mohammedalisharafuddin.github.io/surveyframe/reference/surveyframe-package.md)

## Examples

``` r
if (FALSE) { # \dontrun{
launch_studio()

# A demo, opened on the preview screen
launch_studio(demo = "two_group", screen = "preview")

demo <- sframe_demo("tourism_services")
launch_studio(instrument = demo$instrument, launch.browser = FALSE)

launch_studio(
  instrument    = demo$instrument,
  responses     = demo$responses,
  respondent_id = "respondent_id",
  submitted_at  = "submitted_at"
)
} # }
```
