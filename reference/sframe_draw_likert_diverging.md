# Diverging stacked bar for a single Likert item (base graphics)

Base graphics only (no ggplot2 dependency), so it draws in the report's
distributions section regardless of whether ggplot2 is installed,
including from the Quarto report template, which runs in its own
[`library(surveyframe)`](https://mohammedalisharafuddin.github.io/surveyframe/)
session and cannot see unexported functions. `counts` is a named numeric
vector in scale order (names are the response labels, e.g. "Strongly
disagree" .. "Strongly agree"), not sorted alphabetically or by
frequency. The middle category of an odd-length scale is treated as
neutral and split evenly across the zero line. An even-length scale has
no neutral category. This is the standard survey-report convention (Pew
Research, SurveyMonkey) for visualising an ordered agree/disagree scale,
and reads in one glance which way opinion leans, unlike a plain
frequency bar.

## Usage

``` r
sframe_draw_likert_diverging(
  counts,
  theme_color = "#16B3B1",
  palette = c("web", "print")
)
```

## Arguments

- counts:

  Named numeric vector of response counts, in scale order.

- theme_color:

  Character. Hex colour for the "agree" pole.

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

Invisibly `NULL`, called for its plotting side effect on the current
graphics device.

## Details

Kept horizontal deliberately: this is the one chart in the package where
the horizontal orientation is the domain convention, not an accident,
and a vertical diverging stack is materially harder to read for this
specific shape (see the file-level note in the roxygen docs of the
ggplot2 equivalents above). Position (left of zero vs right of zero)
carries the primary signal either way, so it also satisfies "do not rely
on colour alone" regardless of palette. In print mode, the two poles are
further distinguished by a diagonal hatch on the "disagree" side, not
colour tone alone.

## See also

[`sframe_plot_item_chart()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_item_chart.md)
