# Report on a validation result

`sframe_validation` is the diagnostic object returned by
[`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md)
and
[`sframe_validate_model()`](https://surveyframe.org/reference/sframe_validate_model.md).
It records whether the object passed, every problem found, and every
check that ran, including the checks that found nothing.

## Value

[`print()`](https://rdrr.io/r/base/print.html) returns `x` invisibly.
[`format()`](https://rdrr.io/r/base/format.html) returns a single
character string. [`summary()`](https://rdrr.io/r/base/summary.html)
returns the check table as a data frame.
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) returns
one row per problem.

## Details

Use
[`sframe_is_valid()`](https://surveyframe.org/reference/sframe_is_valid.md)
for the pass or fail flag,
[`sframe_problems()`](https://surveyframe.org/reference/sframe_problems.md)
for the messages,
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) for a
problem-per-row table,
[`summary()`](https://rdrr.io/r/base/summary.html) for the full check
roster, and
[`as_sframe()`](https://surveyframe.org/reference/as_sframe.md) to
recover the validated instrument.

## See also

[`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md),
[`sframe_validate_model()`](https://surveyframe.org/reference/sframe_validate_model.md),
[`sframe_problems()`](https://surveyframe.org/reference/sframe_problems.md),
[`sframe_is_valid()`](https://surveyframe.org/reference/sframe_is_valid.md),
[`as_sframe()`](https://surveyframe.org/reference/as_sframe.md)

Other Design functions:
[`as_sframe()`](https://surveyframe.org/reference/as_sframe.md),
[`launch_builder()`](https://surveyframe.org/reference/launch_builder.md),
[`read_sframe()`](https://surveyframe.org/reference/read_sframe.md),
[`sframe_attention_check()`](https://surveyframe.org/reference/sframe_attention_check.md),
[`sframe_branch()`](https://surveyframe.org/reference/sframe_branch.md),
[`sframe_choice_set()`](https://surveyframe.org/reference/sframe_choice_set.md),
[`sframe_conjoint_design()`](https://surveyframe.org/reference/sframe_conjoint_design.md),
[`sframe_get_study()`](https://surveyframe.org/reference/sframe_get_study.md),
[`sframe_instrument()`](https://surveyframe.org/reference/sframe_instrument.md),
[`sframe_item()`](https://surveyframe.org/reference/sframe_item.md),
[`sframe_sampling_methods()`](https://surveyframe.org/reference/sframe_sampling_methods.md),
[`sframe_scale()`](https://surveyframe.org/reference/sframe_scale.md),
[`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md),
[`write_sframe()`](https://surveyframe.org/reference/write_sframe.md)

## Examples

``` r
cs    <- sframe_choice_set("ag5", 1:5,
           c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree"))
item  <- sframe_item("sat_1", "The service met my expectations.",
                 type = "likert", choice_set = "ag5", scale_id = "sat")
scale <- sframe_scale("sat", "Satisfaction", items = "sat_1")
instr <- sframe_instrument("Demo Survey", components = list(cs, item, scale))

v <- validate_sframe(instr, strict = FALSE)
v
sframe_is_valid(v)
sframe_problems(v)
as.data.frame(v)
summary(v)
```
