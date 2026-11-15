# Define a design-time survey check

Specifies an attention, instructional, or trap check item at instrument
design time. The check is stored in the instrument object and evaluated
against collected response data by
[`sframe_quality_results()`](https://surveyframe.org/reference/sframe_quality_results.md).
This function only defines the check. Evaluation happens later in
[`sframe_quality_results()`](https://surveyframe.org/reference/sframe_quality_results.md).

## Usage

``` r
sframe_attention_check(
  id,
  item_id,
  type = c("attention", "instructional", "trap"),
  pass_values = NULL,
  fail_action = c("flag", "exclude"),
  label = NULL,
  notes = NULL
)
```

## Arguments

- id:

  Character. A unique identifier for this check.

- item_id:

  Character. The `id` of the item used as the check. The item must be
  defined separately with
  [`sframe_item()`](https://surveyframe.org/reference/sframe_item.md)
  and included in the same instrument.

- type:

  Character. The check type. One of:

  - `"attention"`: the item has a stated correct answer and flags
    respondents who answer incorrectly.

  - `"instructional"`: a manipulation check item used to test whether
    instructions were followed.

  - `"trap"`: an item designed to be selected only by inattentive
    respondents (e.g. "Please select Strongly agree for this item.").

- pass_values:

  Vector or NULL. The response value or values that constitute a pass.
  For `"attention"` and `"instructional"` types, at least one value
  should be supplied. For `"trap"` types, this is the value that should
  NOT be selected.

- fail_action:

  Character. What
  [`sframe_quality_results()`](https://surveyframe.org/reference/sframe_quality_results.md)
  does with respondents who fail this check. Either `"flag"` (mark in
  the report but retain) or `"exclude"` (mark for exclusion).

- label:

  Character or NULL. An optional human-readable label for the check,
  used in the quality report.

- notes:

  Character or NULL. Optional free-text notes about the purpose or
  rationale of this check.

## Value

An object of class `sf_check` (a named list).

## See also

[`sframe_item()`](https://surveyframe.org/reference/sframe_item.md),
[`sframe_instrument()`](https://surveyframe.org/reference/sframe_instrument.md),
[`sframe_quality_results()`](https://surveyframe.org/reference/sframe_quality_results.md)

Other Design functions:
[`as_sframe()`](https://surveyframe.org/reference/as_sframe.md),
[`launch_builder()`](https://surveyframe.org/reference/launch_builder.md),
[`read_sframe()`](https://surveyframe.org/reference/read_sframe.md),
[`sframe_branch()`](https://surveyframe.org/reference/sframe_branch.md),
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
# An attention check: respondent must select 4
chk <- sframe_attention_check(
  id          = "attn_1",
  item_id     = "attention_check_q",
  type        = "attention",
  pass_values = 4,
  fail_action = "flag",
  label       = "Attention check 1"
)
chk
```
