# Get the pre-declared analysis plan

Returns the ordered analysis blocks attached to an instrument or
codebook.

## Usage

``` r
sframe_plan(x, ...)
```

## Arguments

- x:

  A surveyframe object.

- ...:

  Passed to methods.

## Value

A list of analysis blocks for an instrument or a plan data frame for a
codebook.

## See also

[sframe_accessors](https://surveyframe.org/reference/sframe_accessors.md),
sframe_plan\<-

Other Plan functions:
[`sframe_plan<-()`](https://surveyframe.org/reference/sframe_plan-set.md),
[`sframe_sample_size_plan()`](https://surveyframe.org/reference/sframe_sample_size_plan.md)

## Examples

``` r
plan <- sframe_plan(sframe_demo("two_group")$instrument)
length(plan)
# 1 block, its fields
str(plan[[1]], max.level = 1)
```
