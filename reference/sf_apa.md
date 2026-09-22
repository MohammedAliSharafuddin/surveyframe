# Extract APA-formatted result summaries

Returns the report-ready sentence attached to each analysis result.

## Usage

``` r
sf_apa(x, ...)
```

## Arguments

- x:

  An `sframe_analysis_results`, `sframe_descriptives_report`,
  `sframe_missing_data_report`, `sframe_validity_report`, or
  `sframe_assumption_report` object.

- ...:

  Passed to methods.

## Value

A character vector containing one APA-formatted summary per result.

## See also

[sf_report_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_report_accessors.md),
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)

## Examples

``` r
results <- structure(
  list(RQ1 = list(apa = "Mean satisfaction was 4.20.")),
  class = c("sframe_analysis_results", "list")
)
sf_apa(results)
#>                           RQ1 
#> "Mean satisfaction was 4.20." 
```
