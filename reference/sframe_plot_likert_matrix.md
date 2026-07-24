# Grouped diverging chart for a Likert matrix question

A matrix question asks several rows against one shared response scale (a
"grid" of Likert items). Plotting each row as its own separate
[`sframe_draw_likert_diverging()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_draw_likert_diverging.md)
chart loses the grouping the question was designed with, so this draws
every row as one diverging bar inside a single chart, sharing one x
scale and one legend, the standard way a Likert matrix is reported
(compare a typical multi-item satisfaction grid). Same diverging-stack
convention as the single-item chart: the middle category of an
odd-length scale is neutral and split evenly across the zero line, and
colour saturation increases toward each pole.

## Usage

``` r
sframe_plot_likert_matrix(item, data, choice_set, palette = c("web", "print"))
```

## Arguments

- item:

  A `"matrix"` sframe item, with `matrix_items` (the row labels) and a
  `choice_set` naming the shared response scale.

- data:

  The response data.frame, with one expanded `<item id>__<row label>`
  column per matrix row, as produced by
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md).

- choice_set:

  The item's choice set object (`values`, `labels`), typically looked up
  from `instrument$choices` by `item$choice_set`.

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object, or `NULL` if no row has response data.

## See also

[`sframe_draw_likert_diverging()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_draw_likert_diverging.md)
