# Define a survey item

Creates a single survey item object for inclusion in an `sframe`
instrument. Items are the atomic units of a survey instrument. Every
item must have a unique `id` within the instrument it is added to.

## Usage

``` r
sf_item(
  id,
  label,
  type = c("likert", "single_choice", "multiple_choice", "numeric", "text", "textarea",
    "date", "matrix", "slider", "ranking", "rating", "section_break", "text_block"),
  required = FALSE,
  choice_set = NULL,
  scale_id = NULL,
  reverse = FALSE,
  help = NULL,
  placeholder = NULL,
  matrix_items = NULL,
  slider_min = NULL,
  slider_max = NULL,
  slider_step = NULL,
  rating_max = NULL,
  rating_icon = NULL,
  section_intro = NULL,
  page = NULL
)
```

## Arguments

- id:

  Character. A unique identifier for this item. Used as the column name
  in response data. Must contain only letters, numbers, and `_`
  characters.

- label:

  Character. The question text or content displayed to the respondent.

- type:

  Character. The response type. One of `"likert"`, `"single_choice"`,
  `"multiple_choice"`, `"numeric"`, `"text"`, `"textarea"`, `"date"`,
  `"matrix"`, `"slider"`, `"ranking"`, `"rating"`, `"section_break"`, or
  `"text_block"`.

- required:

  Logical. Whether the respondent must answer this item.

- choice_set:

  Character or NULL. The `id` of a choice set defined with
  [`sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_choices.md).

- scale_id:

  Character or NULL. The `id` of the scale this item belongs to.

- reverse:

  Logical. Whether this item is reverse-coded within its scale.

- help:

  Character or NULL. Help text displayed beneath the question.

- placeholder:

  Character or NULL. Placeholder text for text inputs.

- matrix_items:

  Character vector or NULL. Row labels for `"matrix"` type.

- slider_min:

  Numeric or NULL. Minimum value for `"slider"` type.

- slider_max:

  Numeric or NULL. Maximum value for `"slider"` type.

- slider_step:

  Numeric or NULL. Step size for `"slider"` type.

- rating_max:

  Integer or NULL. Maximum rating for `"rating"` type.

- rating_icon:

  Character or NULL. Icon type: `"star"` or `"heart"`.

- section_intro:

  Character or NULL. Intro text for `"section_break"` type.

- page:

  Integer or NULL. Page number for multi-page surveys.

## Value

An object of class `sf_item` (a named list).

## See also

[`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md),
[`sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_choices.md),
[`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md)

## Examples

``` r
item <- sf_item(
  id = "sat_overall", label = "Overall, how satisfied are you?",
  type = "likert", required = TRUE, choice_set = "agree5",
  scale_id = "satisfaction"
)

sec <- sf_item("sec_1", "Demographic Information", type = "section_break",
               section_intro = "Please answer the following questions.")
```
