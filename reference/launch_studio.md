# Launch the SurveyStudio interface

Opens the SurveyStudio Shiny application, a visual shell for the full
surveyframe workflow. The studio provides screens to build a survey
draft, open an existing instrument, preview the survey, upload
responses, review data quality, inspect reliability, and export the
instrument or report.

## Usage

``` r
launch_studio(instrument = NULL, responses = NULL)
```

## Arguments

- instrument:

  An `sframe` object or NULL. When supplied, the studio opens directly
  to the preview screen with this instrument loaded.

- responses:

  A `tibble`, `data.frame`, or file path to a CSV, or NULL. When
  supplied alongside `instrument`, the studio opens with responses
  pre-loaded and the quality dashboard available immediately.

## Value

Launches a Shiny application. Does not return a value.

## Details

An instrument and response data can be pre-loaded at launch time. If
neither is supplied, the studio opens at the build screen so the
researcher can start authoring interactively.

## See also

[`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md),
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md),
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Open the studio with no pre-loaded data
launch_studio()

# Open with an instrument pre-loaded
instr <- read_sframe("my_instrument.sframe")
launch_studio(instrument = instr)

# Open with both instrument and responses ready
launch_studio(instrument = instr, responses = "data/responses.csv")
} # }
```
