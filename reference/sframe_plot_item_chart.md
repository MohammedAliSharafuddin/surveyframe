# Item distribution chart, ggplot2 equivalent of the dashboard/studio panel

Shared by
[`launch_dashboard()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard.md)
(`inst/shiny/dashboard/app.R`) and the SurveyStudio dashboard tab
(`inst/shiny/app.R`), which otherwise duplicated this base-graphics
chart. Callers fall back to their own base graphics when this returns
`NULL` (ggplot2 not installed, unsupported item type, or no data), so
the dashboard keeps working without ggplot2.

## Usage

``` r
sframe_plot_item_chart(
  item,
  col_data,
  choice_set = NULL,
  palette = c("web", "print")
)
```

## Arguments

- item:

  A list with at least `type` and `label` (an sframe item).

- col_data:

  The response column for this item.

- choice_set:

  A list with `values` and `labels` (an sframe choice set), or `NULL` if
  the item has none.

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object, or `NULL` if this item type/data is unsupported.
