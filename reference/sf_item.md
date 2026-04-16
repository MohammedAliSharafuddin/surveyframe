# Define a survey item

Creates a single survey item object for inclusion in an `sframe`
instrument. Items are the atomic units of a survey instrument. Every
item must have a unique `id` within the instrument it is added to.

## Usage

``` r
sf_item(
  id,
  label,
  type = c("single_choice", "multiple_choice", "likert", "numeric", "text", "textarea",
    "date"),
  required = FALSE,
  choice_set = NULL,
  scale_id = NULL,
  reverse = FALSE,
  help = NULL,
  placeholder = NULL
)
```

## Arguments

- id:

  Character. A unique identifier for this item. Must contain only
  letters, numbers, and underscores. Used as the column name in response
  data.

- label:

  Character. The question text displayed to the respondent.

- type:

  Character. The response type. One of `"single_choice"`,
  `"multiple_choice"`, `"likert"`, `"numeric"`, `"text"`, `"textarea"`,
  or `"date"`.

- required:

  Logical. Whether the respondent must answer this item before
  proceeding. Defaults to `FALSE`.

- choice_set:

  Character or NULL. The `id` of a choice set defined with
  [`sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_choices.md).
  Required for `"single_choice"`, `"multiple_choice"`, and `"likert"`
  types.

- scale_id:

  Character or NULL. The `id` of the scale this item belongs to, as
  defined with
  [`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md).
  Items may belong to at most one scale.

- reverse:

  Logical. Whether this item is reverse-coded within its scale. Ignored
  if `scale_id` is `NULL`. Defaults to `FALSE`.

- help:

  Character or NULL. Optional help text displayed beneath the question
  label.

- placeholder:

  Character or NULL. Placeholder text for `"text"` and `"textarea"`
  types.

## Value

An object of class `sf_item` (a named list).

## See also

[`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md),
[`sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_choices.md),
[`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md)

## Examples

``` r
# A required Likert item linked to a scale
item <- sf_item(
  id         = "sat_overall",
  label      = "Overall, how satisfied are you with the service?",
  type       = "likert",
  required   = TRUE,
  choice_set = "agree5",
  scale_id   = "satisfaction"
)

# A numeric item
age <- sf_item("age", "What is your age?", type = "numeric", required = TRUE)
```
