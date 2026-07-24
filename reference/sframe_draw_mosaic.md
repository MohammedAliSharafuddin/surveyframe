# Mosaic plot for a two-way categorical result

Base-graphics mosaic plot (via
[`graphics::mosaicplot()`](https://rdrr.io/r/graphics/mosaicplot.html)),
matching the existing base-graphics precedent in this file
([`sframe_draw_likert_diverging()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_draw_likert_diverging.md))
so it renders without ggplot2. An alternative view of the same crosstab
data `sframe_plot_crosstab()` renders as a grouped bar; use whichever
reads better for the table's shape (mosaic scales better to unbalanced
group sizes).

## Usage

``` r
sframe_draw_mosaic(result, palette = c("web", "print"))
```

## Arguments

- result:

  A `crosstab`/`chi_square` result list with a contingency `table`.

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

Invisibly `NULL`; called for its plotting side effect on the current
graphics device.

## See also

`sframe_plot_crosstab()`
