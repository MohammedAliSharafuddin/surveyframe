# Define a scored scale

Creates a scale definition that groups items and specifies how composite
scores are computed. The scale carries scoring rules used by
[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md)
and measurement structure used by
[`sframe_reliability_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reliability_results.md),
[`sframe_item_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item_results.md),
and
[`sframe_syntax_cfa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_cfa.md).

## Usage

``` r
sframe_scale(
  id,
  label,
  items,
  method = c("mean", "sum"),
  min_valid = NULL,
  reverse_items = NULL,
  weights = NULL
)
```

## Arguments

- id:

  Character. A unique identifier for this scale. Referenced in the
  `scale_id` argument of
  [`sframe_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item.md).

- label:

  Character. A human-readable name for the scale, used in reports and
  codebooks.

- items:

  Character vector. The `id` values of items that belong to this scale,
  each listed once. Order controls presentation in reports, while
  scoring uses the same item IDs regardless of order. Items themselves
  are passed to
  [`sframe_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_instrument.md)
  as separate components.

- method:

  Character. Scoring method. Either `"mean"` (default) or `"sum"`.

- min_valid:

  Integer or NULL. The minimum number of answered items required to
  compute a score for a respondent, a whole number from 1 to the number
  of items. When `NULL`, every item must be answered. An item whose
  column is absent from the data counts as unanswered. Used by
  [`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md).

- reverse_items:

  Character vector or NULL. A subset of `items` that this scale
  reverse-codes. Reversal applies within this scale only, so the same
  item can be reversed in one scale and scored as answered in another.
  An item can also be flagged with `reverse = TRUE` in
  [`sframe_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item.md),
  which reverses it within the scale named by its `scale_id`. A reversed
  item needs declared response bounds, from a numeric choice set, slider
  limits or a rating maximum.

- weights:

  Numeric vector or NULL. Item weights for weighted scoring, one
  positive finite number per item, in the order of `items`.
  [`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md)
  applies the weights to either `method = "mean"` or `method = "sum"`.

## Value

An object of class `sf_scale` (a named list).

## See also

[`sframe_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item.md),
[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md),
[`sframe_reliability_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reliability_results.md)

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
[`sframe_validation`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)

## Examples

``` r
sat_scale <- sframe_scale(
  id            = "satisfaction",
  label         = "Customer Satisfaction",
  items         = c("sat_overall", "sat_speed", "sat_quality"),
  method        = "mean",
  min_valid     = 2,
  reverse_items = NULL
)
```
