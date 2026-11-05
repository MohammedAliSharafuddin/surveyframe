# Read survey responses from a Google Sheet

Reads response data collected by the surveyframe Google Apps Script
endpoint and returns a validated data frame ready for the surveyframe
analysis pipeline.

## Usage

``` r
read_sheet_responses(
  sheet_id,
  instrument,
  sheet_name = "Responses",
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  meta_cols = NULL
)
```

## Arguments

- sheet_id:

  Character. The Google Sheet ID or full URL.

- instrument:

  An `sframe` object.

- sheet_name:

  Character. The name of the sheet tab holding responses. Defaults to
  `"Responses"`.

- respondent_id:

  Character or NULL. Column holding respondent IDs. Defaults to
  `"respondent_id"`.

- submitted_at:

  Character or NULL. Column holding submission timestamps. Defaults to
  `"submitted_at"`.

- meta_cols:

  Character vector or NULL. Additional sheet columns to accept as
  metadata without a warning, for example bridge fields a host
  application appends to each submission. `"started_at"` is always
  included.

## Value

A `data.frame` validated against the instrument, ready for
[`sframe_quality_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_quality_results.md),
[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md),
and
[`sframe_reliability_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reliability_results.md).

## See also

[`export_google_sheet()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_google_sheet.md),
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md),
[`sframe_quality_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_quality_results.md)

Other Responses functions:
[`export_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_responses.md),
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md),
[`sframe_missing_data_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_missing_data_results.md),
[`sframe_outlier_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_outlier_results.md),
[`sframe_quality_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_quality_results.md)

## Examples

``` r
if (FALSE) { # \dontrun{
responses <- read_sheet_responses(
  sheet_id   = "your-sheet-id",
  instrument = instr
)
qr <- sframe_quality_results(responses, instr, respondent_id = "respondent_id")
} # }
```
