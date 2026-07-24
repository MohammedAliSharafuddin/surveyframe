# Group a scale's Likert items for a combined diverging chart

Identifies which of an instrument's scales are eligible for one grouped
diverging chart across their member items
([`sframe_plot_likert_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_likert_scale.md)),
the same way a `"matrix"` question's rows are grouped
([`sframe_plot_likert_matrix()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_likert_matrix.md)):
every member item is `"likert"` type and all share one choice set.
Scales that mix response scales, that resolve to fewer than 2 qualifying
items, or whose choice set cannot be found are left out and fall back to
one chart per item in the report's Response distributions section.

## Usage

``` r
sframe_likert_scale_groups(instrument)
```

## Arguments

- instrument:

  An `sframe` object.

## Value

A named list, one entry per eligible scale (named by scale id), each a
list with `scale_id`, `title` (the scale's label), `items` (the member
item objects, in scale order), and `choice_set` (the shared choice set
object). Empty list if no scale qualifies.

## See also

[`sframe_plot_likert_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_likert_scale.md),
[`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md)
