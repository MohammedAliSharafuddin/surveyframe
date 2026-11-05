# Define a reusable choice set

Creates a named set of response options that can be referenced by one or
more items. Defining choices once and referencing them by `id` keeps the
instrument consistent and reduces the risk of label mismatches across
items that share the same response format.

## Usage

``` r
sframe_choice_set(
  id,
  values,
  labels,
  allow_other = FALSE,
  randomise = FALSE,
  ordered = FALSE
)
```

## Arguments

- id:

  Character. A unique identifier for this choice set. Referenced in the
  `choice_set` argument of
  [`sframe_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item.md).

- values:

  Character or numeric vector. The stored values corresponding to each
  response option. Must have the same length as `labels`.

- labels:

  Character vector. The display labels shown to respondents. Must have
  the same length as `values`.

- allow_other:

  Logical. Whether to append an open-text "Other, please specify" option
  at the end of the choice list. Defaults to `FALSE`. It is submitted as
  the code `"other"`, so a set holding the value `"other"` or
  `"other_text"` cannot allow it, and nor can an ordered set.

- randomise:

  Logical. Whether to randomise the display order of options at render
  time. Defaults to `FALSE`.

- ordered:

  Logical. Whether the options run in a meaningful order, from least to
  most or the reverse, as in a frequency or an education scale.
  SurveyBuilder and SurveyStudio then treat a `single_choice` item on
  the set as ordinal, which opens the methods for ordered categories.
  Defaults to `FALSE`, nominal. Written to the file only when `TRUE`, so
  every earlier set keeps the hash it had. A `likert` item is ordered by
  its type.

## Value

An object of class `sf_choices` (a named list).

## See also

[`sframe_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item.md),
[`sframe_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_instrument.md)

Other Design functions:
[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md),
[`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md),
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md),
[`sframe_attention_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_attention_check.md),
[`sframe_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_branch.md),
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
# A five-point agreement scale
agree5 <- sframe_choice_set(
  id     = "agree5",
  values = 1:5,
  labels = c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree")
)

# An ordered set: a single_choice item on it is read as ordinal
often <- sframe_choice_set(
  id      = "often",
  values  = 1:4,
  labels  = c("Rarely", "Sometimes", "Often", "Always"),
  ordered = TRUE
)
```
