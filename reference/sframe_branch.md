# Define a branching rule

Creates a single-condition branching rule that shows or hides a survey
item depending on the value of a preceding item. Only single-condition
rules are supported. Multi-condition AND/OR logic is planned for a later
release.

## Usage

``` r
sframe_branch(
  item_id,
  depends_on,
  operator = c("==", "!=", "%in%", ">", ">=", "<", "<="),
  value,
  action = c("show", "hide")
)
```

## Arguments

- item_id:

  Character. The `id` of the item whose visibility this rule controls.

- depends_on:

  Character. The `id` of the item whose response value triggers this
  rule.

- operator:

  Character. The comparison operator. One of `"=="`, `"!="`, `"%in%"`,
  `">"`, `">="`, `"<"`, or `"<="`.

- value:

  The value to compare against the response to `depends_on`. For
  `"%in%"`, supply a character or numeric vector.

- action:

  Character. What to do when the condition is met. Either `"show"`
  (default) or `"hide"`.

## Value

An object of class `sf_branch` (a named list).

## See also

[`sframe_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_instrument.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)

Other Design functions:
[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md),
[`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md),
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md),
[`sframe_attention_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_attention_check.md),
[`sframe_choice_set()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_choice_set.md),
[`sframe_conjoint_design()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_conjoint_design.md),
[`sframe_get_study()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_study.md),
[`sframe_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_instrument.md),
[`sframe_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item.md),
[`sframe_sampling_methods()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_sampling_methods.md),
[`sframe_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_scale.md),
[`sframe_validation`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)

## Examples

``` r
# Show an open-text follow-up only when the respondent selects "Other"
rule <- sframe_branch(
  item_id    = "gender_other",
  depends_on = "gender",
  operator   = "==",
  value      = "other",
  action     = "show"
)
```
