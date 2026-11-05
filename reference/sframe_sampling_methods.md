# Sampling methods a study can declare

The fixed list `study$sampling$method` is checked against.

- Probability methods: `"simple_random"`, `"systematic"`, `"stratified"`
  and `"cluster"`. Every member of the population has a known chance of
  selection.

- Non-probability methods: `"convenience"`, `"purposive"`, `"quota"` and
  `"snowball"`. A report says the sample is a non-probability one, so
  its results do not generalise to the population by sampling theory.

- `"census"`: the whole population is asked.

- `"other"`: described in `study$sampling$method_other`, which is then
  required.

## Usage

``` r
sframe_sampling_methods(
  type = c("all", "probability", "non_probability", "census")
)
```

## Arguments

- type:

  `"all"` (the default), `"probability"`, `"non_probability"` or
  `"census"`.

## Value

A character vector.

## See also

Other Design functions:
[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md),
[`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md),
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md),
[`sframe_attention_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_attention_check.md),
[`sframe_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_branch.md),
[`sframe_choice_set()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_choice_set.md),
[`sframe_conjoint_design()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_conjoint_design.md),
[`sframe_get_study()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_study.md),
[`sframe_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_instrument.md),
[`sframe_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item.md),
[`sframe_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_scale.md),
[`sframe_validation`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)

## Examples

``` r
sframe_sampling_methods()
#>  [1] "simple_random" "systematic"    "stratified"    "cluster"      
#>  [5] "convenience"   "purposive"     "quota"         "snowball"     
#>  [9] "census"        "other"        
sframe_sampling_methods("non_probability")
#> [1] "convenience" "purposive"   "quota"       "snowball"   
```
