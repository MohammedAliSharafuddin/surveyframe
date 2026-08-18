# Explore a surveyframe object

Accessors for the parts of an instrument, a codebook, or a report. They
replace reaching into the object with `$`, which ties user code to the
internal layout.

## Usage

``` r
sf_meta(x, ...)

sf_items(x, ...)

sf_scales(x, ...)

sf_choice_sets(x, ...)

sf_branches(x, ...)

sf_checks(x, ...)

sf_models(x, ...)

sf_plan(x, ...)

# S3 method for class 'sframe'
sf_meta(x, ...)

# S3 method for class 'sframe'
sf_items(x, ...)

# S3 method for class 'sframe'
sf_scales(x, ...)

# S3 method for class 'sframe'
sf_choice_sets(x, ...)

# S3 method for class 'sframe'
sf_branches(x, ...)

# S3 method for class 'sframe'
sf_checks(x, ...)

# S3 method for class 'sframe'
sf_models(x, ...)

# S3 method for class 'sframe'
sf_plan(x, ...)

# S3 method for class 'sframe_codebook'
sf_meta(x, ...)

# S3 method for class 'sframe_codebook'
sf_items(x, ...)

# S3 method for class 'sframe_codebook'
sf_scales(x, ...)

# S3 method for class 'sframe_codebook'
sf_choice_sets(x, ...)

# S3 method for class 'sframe_codebook'
sf_models(x, ...)

# S3 method for class 'sframe_codebook'
sf_plan(x, ...)
```

## Arguments

- x:

  A surveyframe object.

- ...:

  Passed to methods.

## Value

`sf_items()`, `sf_scales()`, `sf_choice_sets()`, `sf_branches()`,
`sf_checks()` and `sf_models()` return an
[sf_component_list](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_component_list.md).
`sf_meta()` and `sf_plan()` return lists.

## Details

`sf_items()`, `sf_scales()`, `sf_choice_sets()`, `sf_branches()`,
`sf_checks()` and `sf_models()` return the component objects as an
[sf_component_list](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_component_list.md).
`sf_meta()` returns the metadata as a list and `sf_plan()` returns the
pre-declared analysis plan. For a flat table of the same content, call
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) on the
object instead.

## See also

[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md),
[`sf_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_validation_accessors.md),
[sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)

## Examples

``` r
cs    <- sf_choices("ag5", 1:5,
           c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree"))
item  <- sf_item("sat_1", "The service met my expectations.",
                 type = "likert", choice_set = "ag5", scale_id = "sat")
scale <- sf_scale("sat", "Satisfaction", items = "sat_1")
instr <- sf_instrument("Demo Survey", components = list(cs, item, scale))

sf_meta(instr)$title
#> [1] "Demo Survey"
sf_items(instr)
#> <item list: 1>
#>  <sf_item: sat_1 | type: likert>
sf_scales(instr)[["sat"]]
#> <sf_scale: sat | 1 item(s)>
#>   Label: Satisfaction
#>   Items: sat_1
#>   Scoring: mean
as.data.frame(instr)
#>      id                            label   type choice_set scale_id reverse
#> 1 sat_1 The service met my expectations. likert        ag5      sat   FALSE
#>   required
#> 1    FALSE
```
