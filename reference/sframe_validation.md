# Report on a validation result

`sframe_validation` is the diagnostic object returned by
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
and
[`sframe_validate_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validate_model.md).
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
[`sframe_is_valid()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_is_valid.md)
for the pass or fail flag,
[`sframe_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_problems.md)
for the messages,
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) for a
problem-per-row table,
[`summary()`](https://rdrr.io/r/base/summary.html) for the full check
roster, and
[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md)
to recover the validated instrument.

## See also

[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
[`sframe_validate_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validate_model.md),
[`sframe_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_problems.md),
[`sframe_is_valid()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_is_valid.md),
[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md)

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
[`sframe_sampling_methods()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_sampling_methods.md),
[`sframe_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_scale.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)

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
#> <sframe validation>
#>   Instrument:  Demo Survey (0.1.0)
#>   Status:      valid
#>   Checks:      30 run, 0 with problems
sframe_is_valid(v)
#> [1] TRUE
sframe_problems(v)
#> character(0)
as.data.frame(v)
#> [1] check   problem
#> <0 rows> (or 0-length row.names)
summary(v)
#>                           check status n_problems
#> 1                  field_shapes     ok          0
#> 2            duplicate_item_ids     ok          0
#> 3                item_id_format     ok          0
#> 4          duplicate_choice_ids     ok          0
#> 5           choice_set_contents     ok          0
#> 6           duplicate_scale_ids     ok          0
#> 7                  id_namespace     ok          0
#> 8                   item_config     ok          0
#> 9                   item_labels     ok          0
#> 10         item_choice_set_refs     ok          0
#> 11              item_scale_refs     ok          0
#> 12        reverse_without_scale     ok          0
#> 13          decision_item_shape     ok          0
#> 14             comparison_scale     ok          0
#> 15             scale_membership     ok          0
#> 16             scale_parameters     ok          0
#> 17      reverse_item_membership     ok          0
#> 18               branching_refs     ok          0
#> 19             branching_values     ok          0
#> 20                   check_refs     ok          0
#> 21          duplicate_check_ids     ok          0
#> 22               branch_targets     ok          0
#> 23         analysis_plan_blocks     ok          0
#> 24         analysis_plan_models     ok          0
#> 25      analysis_plan_variables     ok          0
#> 26 decision_scale_compatibility     ok          0
#> 27                    model_ids     ok          0
#> 28                  model_specs     ok          0
#> 29                   references     ok          0
#> 30                        study     ok          0
```
