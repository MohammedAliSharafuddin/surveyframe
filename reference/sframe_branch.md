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

[`sframe_instrument()`](https://surveyframe.org/reference/sframe_instrument.md),
[`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md)

Other Design functions:
[`as_sframe()`](https://surveyframe.org/reference/as_sframe.md),
[`launch_builder()`](https://surveyframe.org/reference/launch_builder.md),
[`read_sframe()`](https://surveyframe.org/reference/read_sframe.md),
[`sframe_attention_check()`](https://surveyframe.org/reference/sframe_attention_check.md),
[`sframe_choice_set()`](https://surveyframe.org/reference/sframe_choice_set.md),
[`sframe_conjoint_design()`](https://surveyframe.org/reference/sframe_conjoint_design.md),
[`sframe_get_study()`](https://surveyframe.org/reference/sframe_get_study.md),
[`sframe_instrument()`](https://surveyframe.org/reference/sframe_instrument.md),
[`sframe_item()`](https://surveyframe.org/reference/sframe_item.md),
[`sframe_sampling_methods()`](https://surveyframe.org/reference/sframe_sampling_methods.md),
[`sframe_scale()`](https://surveyframe.org/reference/sframe_scale.md),
[`sframe_validation`](https://surveyframe.org/reference/sframe_validation.md),
[`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md),
[`write_sframe()`](https://surveyframe.org/reference/write_sframe.md)

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
rule
```
