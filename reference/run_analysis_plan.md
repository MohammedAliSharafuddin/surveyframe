# Run a pre-planned analysis from an instrument's analysis plan

Executes every analysis block defined in the instrument's
`analysis_plan` slot against the supplied response data. Each block
corresponds to one research question defined during instrument design in
the SurveyBuilder. Results include APA-formatted statistics, effect
sizes, interpretation prompts, and pre-populated citations.

## Usage

``` r
run_analysis_plan(data, instrument, scored = TRUE)
```

## Arguments

- data:

  A `tibble` or `data.frame` of responses, typically produced by
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
  or
  [`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md).

- instrument:

  An `sframe` object containing an `analysis_plan`.

- scored:

  Logical. Whether to automatically score scales before running the
  analysis. Defaults to `TRUE`.

## Value

An object of class `sframe_analysis_results`, a list with one element
per analysis block. Each element contains the test result, APA string,
interpretation prompt, and citations. Pass to
[`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md)
to generate a formatted report.

## See also

[`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md),
[`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md)

## Examples

``` r
if (FALSE) { # \dontrun{
responses <- read_sheet_responses("your-sheet-id", instr)
results   <- run_analysis_plan(responses, instr)
render_results(results, instr, output_file = "results.html")
} # }
```
