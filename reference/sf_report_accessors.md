# Read the reportable parts of an analysis or quality result

`sf_apa()` returns the APA-formatted sentence for each analysis block.
`sf_flagged()` returns the row numbers a quality report flagged.

## Usage

``` r
sf_apa(x, ...)

sf_flagged(x, ...)

# S3 method for class 'sframe_analysis_results'
sf_apa(x, ...)

# S3 method for class 'sframe_descriptives_report'
sf_apa(x, ...)

# S3 method for class 'sframe_missing_data_report'
sf_apa(x, ...)

# S3 method for class 'sframe_validity_report'
sf_apa(x, ...)

# S3 method for class 'sframe_assumption_report'
sf_apa(x, ...)

# S3 method for class 'sframe_quality_report'
sf_flagged(x, ...)
```

## Arguments

- x:

  An `sframe_analysis_results` object for `sf_apa()`, or an
  `sframe_quality_report` for `sf_flagged()`.

- ...:

  Passed to methods.

## Value

`sf_apa()` returns a named character vector, one element per analysis
block. `sf_flagged()` returns an integer vector of row numbers.

## Examples

``` r
demo <- sframe_demo_data()
qr <- quality_report(demo$responses, demo$instrument)
head(sf_flagged(qr))
#> [1]  37  48  61  73 107 108
```
