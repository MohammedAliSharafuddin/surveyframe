# Columns the instrument declares that the responses left out

A partial export gives a quality report every column it holds, and none
of the ones it dropped. This names the declared columns that never
arrived, so a missingness figure can be read against what was expected.
They count as missing for every respondent in
[`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md)'s
rates.

## Usage

``` r
sf_missing_columns(x, ...)
```

## Arguments

- x:

  An `sframe_quality_report` object.

- ...:

  Passed to methods.

## Value

A character vector of column names, empty where the export carried every
declared column.

## See also

[`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md),
[`sf_flagged()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_flagged.md)

## Examples

``` r
demo <- sframe_demo_data()
qr   <- quality_report(demo$responses, demo$instrument)
sf_missing_columns(qr)
#> character(0)
```
