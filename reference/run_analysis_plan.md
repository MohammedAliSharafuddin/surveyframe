# Run a pre-planned analysis from an instrument's analysis plan

Executes every analysis block defined in the instrument's
`analysis_plan` slot against the supplied response data. Each block
corresponds to one research question defined during instrument design in
the SurveyBuilder. Results include APA-formatted statistics, effect
sizes, interpretation prompts, and reporting references.

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
interpretation prompt, and reporting-reference metadata. Pass to
[`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md)
to generate a formatted report.

## See also

[`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md),
[`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md)

## Examples

``` r
instr <- read_sframe(
  system.file("extdata", "tourism_services_demo.sframe",
              package = "surveyframe")
)
responses <- read_responses(
  system.file("extdata", "tourism_services_responses.csv",
              package = "surveyframe"),
  instr,
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  meta_cols = "started_at"
)
results <- run_analysis_plan(responses, instr)
print(results)
#> Analysis Results: 3 research question(s)
#> 
#> RQ 1: Is perceived digital marketing effectiveness associated with tourist satisfaction?
#>   Test: correlation_pearson
#>   APA:  r(118) = 0.54, p < .001
#> 
#> RQ 2: Do digital marketing, service quality, and sustainability perceptions predict satisfaction?
#>   Test: regression_linear
#>   APA:  R² = 0.383, F(3, 116) = 23.95, p < .001
#> 
#> RQ 3: Do first-time and repeat visitors differ in behavioural intention?
#>   Test: mann_whitney
#>   APA:  U = 1576, z = -0.98, p = 0.327, r = 0.09
#> 
```
