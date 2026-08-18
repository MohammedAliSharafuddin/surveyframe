# Set the pre-declared analysis plan

The replacement counterpart to
[`sf_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md).
Declaring the plan is the step the whole workflow turns on, so it has a
named function rather than assignment into the object's internals.

## Usage

``` r
sf_plan(x) <- value

# S3 method for class 'sframe'
sf_plan(x) <- value
```

## Arguments

- x:

  An `sframe` object.

- value:

  A list of analysis blocks.

## Value

The updated `sframe` object.

## See also

[`sf_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)

## Examples

``` r
item  <- sf_item("q1", "How satisfied are you?", type = "numeric")
instr <- sf_instrument("Demo", components = list(item))

sf_plan(instr) <- list(
  list(id = "RQ1", research_question = "What is the average?",
       family = "descriptive", method = "descriptives",
       roles = list(variables = "q1"))
)
length(sf_plan(instr))
#> [1] 1
```
