# Define a branching rule

Creates a single-condition branching rule that shows or hides a survey
item depending on the value of a preceding item. In v0.1, only
single-condition rules are supported. Multi-condition AND/OR logic is
planned for a later release.

## Usage

``` r
sf_branch(
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

[`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)

## Examples

``` r
# Show an open-text follow-up only when the respondent selects "Other"
rule <- sf_branch(
  item_id    = "gender_other",
  depends_on = "gender",
  operator   = "==",
  value      = "other",
  action     = "show"
)
```
