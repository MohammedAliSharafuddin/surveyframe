# Get rows flagged by response-quality checks

Pools failed attention checks, straight-lining, excess missingness,
timing, and duplicate checks into one set of response-row positions.

## Usage

``` r
sf_flagged(x, ...)
```

## Arguments

- x:

  An `sframe_quality_report` object.

- ...:

  Passed to methods.

## Value

A sorted integer vector of unique response-row positions.

## See also

[sf_report_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_report_accessors.md),
[`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md)

## Examples

``` r
demo <- sframe_demo_data()
qr <- quality_report(demo$responses, demo$instrument)
sf_flagged(qr)
#> [1]  37  48  61  73 107 108
```
