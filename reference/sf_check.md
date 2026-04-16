# Define a design-time survey check

Specifies an attention, instructional, or trap check item at instrument
design time. The check is stored in the instrument object and evaluated
against collected response data by
[`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md).
This function only defines the check; it does not evaluate it.

## Usage

``` r
sf_check(
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
  [`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md)
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
  [`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md)
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

[`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md),
[`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md),
[`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md)

## Examples

``` r
# An attention check: respondent must select 4
chk <- sf_check(
  id          = "attn_1",
  item_id     = "attention_check_q",
  type        = "attention",
  pass_values = 4,
  fail_action = "flag",
  label       = "Attention check 1"
)
```
