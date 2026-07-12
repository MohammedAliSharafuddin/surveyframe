# Export a survey instrument to Google Sheets collection format

Generates a Google Apps Script file that, when run in a Google Sheet,
creates a response collection endpoint for a survey instrument. The
builder can store the deployed Apps Script URL in survey metadata, and
the same sheet can be read back with
[`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md).

## Usage

``` r
export_google_sheet(instrument, sheet_url, output_dir = ".")
```

## Arguments

- instrument:

  An `sframe` object.

- sheet_url:

  Character. The URL of an existing Google Sheet. The sheet must be
  shared so that anyone with the link can edit, or use service account
  credentials via `googlesheets4`.

- output_dir:

  Character. Directory to write the Apps Script file. Defaults to the
  current working directory.

## Value

The path to the generated `.gs` Apps Script file, invisibly.

## See also

[`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md),
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md),
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)

## Examples

``` r
instr <- read_sframe(
  system.file("extdata", "tourism_services_demo.sframe",
              package = "surveyframe")
)
script <- export_google_sheet(
  instr,
  sheet_url = "https://docs.google.com/spreadsheets/d/demo",
  output_dir = tempdir()
)
#> Apps Script written to: /tmp/Rtmpn873Ah/surveyframe_collector.gs
#> Follow the setup instructions inside the file to deploy it.
file.exists(script)
#> [1] TRUE
```
