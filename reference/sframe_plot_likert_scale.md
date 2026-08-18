# Grouped diverging chart for a scale's Likert items

Several *separate* Likert items that make up one
[`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md)
(unlike a `"matrix"` item's rows, which are one question) are, by
default, each reported as their own single-item diverging chart. That
scatters a related batch of items (a satisfaction scale's 2-3 items,
say) across several charts instead of showing them the way a Likert
matrix or a typical multi-item satisfaction grid is reported: one
grouped chart, one diverging bar per item, sharing an x scale and a
legend. Applies only when every item in the scale shares the same choice
set. Scales that mix response scales fall back to one chart per item.

## Usage

``` r
sframe_plot_likert_scale(
  items,
  data,
  choice_set,
  title,
  palette = c("web", "print")
)
```

## Arguments

- items:

  A list of `"likert"` sframe items belonging to one scale, in display
  order.

- data:

  The response data.frame, with one column per item id.

- choice_set:

  The shared choice set object (`values`, `labels`).

- title:

  Chart title, typically the scale's label.

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object, or `NULL` if no item has response data.

## See also

[`sframe_plot_likert_matrix()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_likert_matrix.md),
[`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md)
