# Report on a validation result

`sframe_validation` is the diagnostic object returned by
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
and
[`validate_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_model.md).
It records whether the object passed, every problem found, and every
check that ran, including the checks that found nothing.

## Usage

``` r
# S3 method for class 'sframe_validation'
print(x, ...)

# S3 method for class 'sframe_validation'
format(x, ...)

# S3 method for class 'sframe_validation'
summary(object, ...)

# S3 method for class 'sframe_validation'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)
```

## Arguments

- x, object:

  An `sframe_validation` object.

- ...:

  Ignored. Present for S3 consistency.

- row.names:

  Passed to
  [`base::as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html).

- optional:

  Passed to
  [`base::as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html).

## Value

[`print()`](https://rdrr.io/r/base/print.html) returns `x` invisibly.
[`format()`](https://rdrr.io/r/base/format.html) returns a single
character string. [`summary()`](https://rdrr.io/r/base/summary.html)
returns the check table as a data frame.
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) returns
one row per problem.

## Details

Use
[`sf_is_valid()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_validation_accessors.md)
for the pass or fail flag,
[`sf_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_validation_accessors.md)
for the messages,
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) for a
problem-per-row table,
[`summary()`](https://rdrr.io/r/base/summary.html) for the full check
roster, and
[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md)
to recover the validated instrument.

## See also

[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
[`validate_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_model.md),
[`sf_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_validation_accessors.md),
[`sf_is_valid()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_validation_accessors.md),
[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md)

## Examples

``` r
cs    <- sf_choices("ag5", 1:5,
           c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree"))
item  <- sf_item("sat_1", "The service met my expectations.",
                 type = "likert", choice_set = "ag5", scale_id = "sat")
scale <- sf_scale("sat", "Satisfaction", items = "sat_1")
instr <- sf_instrument("Demo Survey", components = list(cs, item, scale))

v <- validate_sframe(instr, strict = FALSE)
v
#> <sframe validation>
#>   Instrument:  Demo Survey (0.1.0)
#>   Status:      valid
#>   Checks:      19 run, 0 with problems
sf_is_valid(v)
#> [1] TRUE
sf_problems(v)
#> character(0)
as.data.frame(v)
#> [1] check   problem
#> <0 rows> (or 0-length row.names)
summary(v)
#>                           check status n_problems
#> 1            duplicate_item_ids     ok          0
#> 2                item_id_format     ok          0
#> 3          duplicate_choice_ids     ok          0
#> 4           duplicate_scale_ids     ok          0
#> 5                   item_labels     ok          0
#> 6          item_choice_set_refs     ok          0
#> 7               item_scale_refs     ok          0
#> 8         reverse_without_scale     ok          0
#> 9           decision_item_shape     ok          0
#> 10             comparison_scale     ok          0
#> 11             scale_membership     ok          0
#> 12               branching_refs     ok          0
#> 13             branching_values     ok          0
#> 14                   check_refs     ok          0
#> 15         analysis_plan_models     ok          0
#> 16      analysis_plan_variables     ok          0
#> 17 decision_scale_compatibility     ok          0
#> 18                    model_ids     ok          0
#> 19                  model_specs     ok          0
```
