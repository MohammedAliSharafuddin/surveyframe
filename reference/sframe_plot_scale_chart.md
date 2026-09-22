# Scale score distribution chart, ggplot2 equivalent of the dashboard panel

Same sharing rationale as
[`sframe_plot_item_chart()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_item_chart.md).

## Usage

``` r
sframe_plot_scale_chart(scores, label, palette = c("web", "print"))
```

## Arguments

- scores:

  Numeric vector of scale scores (already averaged/summed).

- label:

  Character. Scale label, used as the x-axis title.

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object, or `NULL` if ggplot2 is unavailable or `scores` is
empty.

## Examples

``` r
# \donttest{
if (requireNamespace("ggplot2", quietly = TRUE)) {
  demo <- sframe_demo_data()
  scored <- score_scales(demo$responses, demo$instrument)
  sframe_plot_scale_chart(scored$satisfaction, "Satisfaction")
}

# }
```
