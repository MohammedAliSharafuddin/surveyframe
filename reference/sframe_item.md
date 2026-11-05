# Define a survey item

Creates a single survey item object for inclusion in an `sframe`
instrument. Items are the atomic units of a survey instrument. Every
item must have a unique `id` within the instrument it is added to.

## Usage

``` r
sframe_item(
  id,
  label,
  type = c("likert", "single_choice", "multiple_choice", "numeric",
    "text", "textarea", "date", "matrix", "slider", "ranking", "rating",
    "pairwise_comparison", "criteria_weight", "section_break",
    "text_block"),
  required = FALSE,
  choice_set = NULL,
  scale_id = NULL,
  reverse = FALSE,
  help = NULL,
  placeholder = NULL,
  matrix_items = NULL,
  comparison_items = NULL,
  comparison_scale = NULL,
  slider_min = NULL,
  slider_max = NULL,
  slider_step = NULL,
  rating_max = NULL,
  rating_icon = NULL,
  date_min = NULL,
  date_max = NULL,
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
  `"matrix"`, `"slider"`, `"ranking"`, `"rating"`,
  `"pairwise_comparison"`, `"criteria_weight"`, `"section_break"`, or
  `"text_block"`.

- required:

  Logical. Whether the respondent must answer this item.

- choice_set:

  Character or NULL. The `id` of a choice set defined with
  [`sframe_choice_set()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_choice_set.md).

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

- comparison_items:

  Character vector or NULL. The things being compared or weighted, for
  `"pairwise_comparison"` and `"criteria_weight"` types. At least 2
  entries, all distinct. A `"saaty"` pairwise item renders `n(n-1)/2`
  unordered pair rows, an `"influence"` item renders `n(n-1)` ordered
  rows, and a `"criteria_weight"` item renders one numeric input per
  entry. An advisory warning is raised above 7 items (`"saaty"`) or 6
  (`"influence"`), and above 10 the item is rejected.

- comparison_scale:

  Character or NULL. For `"pairwise_comparison"` only. `"saaty"` (the
  default) gives the bipolar 1-9 importance scale used by AHP and ANP,
  while `"influence"` gives the unipolar 0-4 directed influence scale
  used by DEMATEL.

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

- date_min:

  Character or Date or NULL. Earliest selectable date for `"date"` type,
  as `"YYYY-MM-DD"`.

- date_max:

  Character or Date or NULL. Latest selectable date for `"date"` type,
  as `"YYYY-MM-DD"`.

- section_intro:

  Character or NULL. Intro text for `"section_break"` type.

- page:

  Integer or NULL. Page number for multi-page surveys.

## Value

An object of class `sf_item` (a named list).

## See also

[`sframe_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_instrument.md),
[`sframe_choice_set()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_choice_set.md),
[`sframe_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_scale.md)

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
[`sframe_sampling_methods()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_sampling_methods.md),
[`sframe_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_scale.md),
[`sframe_validation`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)

## Examples

``` r
item <- sframe_item(
  id = "sat_overall", label = "Overall, how satisfied are you?",
  type = "likert", required = TRUE, choice_set = "agree5",
  scale_id = "satisfaction"
)

sec <- sframe_item("sec_1", "Demographic Information", type = "section_break",
               section_intro = "Please answer the following questions.")
```
