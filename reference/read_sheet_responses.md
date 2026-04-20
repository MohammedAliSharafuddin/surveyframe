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
  submitted_at = "submitted_at"
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

## Value

A `tibble` validated against the instrument, ready for
[`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md),
[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md),
and
[`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md).

## See also

[`export_google_sheet()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_google_sheet.md),
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md),
[`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md)

## Examples

``` r
if (FALSE) { # \dontrun{
responses <- read_sheet_responses(
  sheet_id   = "your-sheet-id",
  instrument = instr
)
qr <- quality_report(responses, instr, respondent_id = "respondent_id")
} # }
```
