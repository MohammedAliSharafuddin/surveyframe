# Define a scored scale

Creates a scale definition that groups items and specifies how composite
scores are computed. The scale carries scoring rules used by
[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md)
and measurement structure used by
[`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md),
[`item_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/item_report.md),
and
[`cfa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_syntax.md).

## Usage

``` r
sf_scale(
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
  [`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md).

- label:

  Character. A human-readable name for the scale, used in reports and
  codebooks.

- items:

  Character vector. The `id` values of items that belong to this scale.
  Order matters for presentation in reports; it does not affect scoring.

- method:

  Character. Scoring method. Either `"mean"` (default) or `"sum"`.

- min_valid:

  Integer or NULL. The minimum number of non-missing items required to
  compute a score for a respondent. When `NULL`, all items must be
  present. Used by
  [`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md).

- reverse_items:

  Character vector or NULL. A subset of `items` that are reverse-coded.
  These can also be flagged at the item level with the `reverse`
  argument in
  [`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md).
  Both sources are respected.

- weights:

  Numeric vector or NULL. Item weights for weighted scoring. Must have
  the same length as `items` if supplied.
  [`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md)
  applies the weights to either `method = "mean"` or `method = "sum"`.

## Value

An object of class `sf_scale` (a named list).

## See also

[`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md),
[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md),
[`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md)

## Examples

``` r
sat_scale <- sf_scale(
  id            = "satisfaction",
  label         = "Customer Satisfaction",
  items         = c("sat_overall", "sat_speed", "sat_quality"),
  method        = "mean",
  min_valid     = 2,
  reverse_items = NULL
)
```
