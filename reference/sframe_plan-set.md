# Set the pre-declared analysis plan

The replacement counterpart to
[`sframe_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plan.md).
Declaring the plan is the step the whole workflow turns on, so it has a
named function rather than assignment into the object's internals.

## Usage

``` r
sframe_plan(x) <- value
```

## Arguments

- x:

  An `sframe` object.

- value:

  A list of analysis blocks.

## Value

The updated `sframe` object.

## See also

[`sframe_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plan.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)

Other Plan functions:
[`sframe_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plan.md),
[`sframe_sample_size_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_sample_size_plan.md)

## Examples

``` r
item  <- sframe_item("q1", "How satisfied are you?", type = "numeric")
instr <- sframe_instrument("Demo", components = list(item))

sframe_plan(instr) <- list(
  list(id = "RQ1", research_question = "What is the average?",
       family = "descriptive", method = "descriptives",
       roles = list(variables = "q1"))
)
length(sframe_plan(instr))
#> [1] 1
```
