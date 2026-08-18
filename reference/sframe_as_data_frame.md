# Coerce a surveyframe object to a data frame

Every surveyframe class returns its primary table. For an instrument
that is the item table, for a validation result the problems, for a
report the table it is mainly about. Where an object holds more than one
table, the others are reachable through the named accessors in
[sf_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md)
or, for a full tabular record of an instrument, through
[`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md).

## Usage

``` r
# S3 method for class 'sframe'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)

# S3 method for class 'sf_choices'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)

# S3 method for class 'sframe_codebook'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)

# S3 method for class 'sframe_reliability_report'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)

# S3 method for class 'sframe_item_report'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)

# S3 method for class 'sframe_efa_report'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)

# S3 method for class 'sframe_efa_solution'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)

# S3 method for class 'sframe_descriptives_report'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)

# S3 method for class 'sframe_missing_data_report'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)

# S3 method for class 'sframe_validity_report'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)

# S3 method for class 'sframe_assumption_report'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)

# S3 method for class 'sframe_sample_size_plan'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)

# S3 method for class 'sframe_quality_report'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)

# S3 method for class 'sframe_sensitivity'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)

# S3 method for class 'sframe_analysis_results'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)
```

## Arguments

- x:

  A surveyframe object.

- row.names:

  Passed to
  [`base::as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html).

- optional:

  Passed to
  [`base::as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html).

- ...:

  Ignored. Present for S3 consistency.

## Value

A data frame.

## See also

[sf_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md),
[`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md)

## Examples

``` r
cs    <- sf_choices("ag5", 1:5,
           c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree"))
item  <- sf_item("sat_1", "The service met my expectations.",
                 type = "likert", choice_set = "ag5", scale_id = "sat")
scale <- sf_scale("sat", "Satisfaction", items = "sat_1")
instr <- sf_instrument("Demo Survey", components = list(cs, item, scale))

as.data.frame(instr)
#>      id                            label   type choice_set scale_id reverse
#> 1 sat_1 The service met my expectations. likert        ag5      sat   FALSE
#>   required
#> 1    FALSE
as.data.frame(cs)
#>   value             label
#> 1     1 Strongly disagree
#> 2     2          Disagree
#> 3     3           Neutral
#> 4     4             Agree
#> 5     5    Strongly agree
```
