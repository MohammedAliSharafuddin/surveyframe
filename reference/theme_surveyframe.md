# surveyframe brand theme for ggplot2

A `theme_classic()`-based ggplot2 theme (visible axis lines, no floating
panel), verified against WCAG 2.2 contrast minimums: 4.5:1 for text, 3:1
for non-text graphical objects. Apply it to any ggplot object, including
the plots returned by
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
when `plots = TRUE`.

## Usage

``` r
theme_surveyframe(
  base_size = 12,
  base_family = "",
  palette = c("web", "print")
)
```

## Arguments

- base_size:

  Numeric. Base font size in points. Defaults to 12.

- base_family:

  Character. Base font family. Defaults to `""` (the device default).

- palette:

  One of `"web"` (brand colours, for on-screen use) or `"print"`
  (black/grey/white only, for journal-ready figures). See
  `sframe_brand()` for the verified contrast ratios behind each.

## Value

A ggplot2 theme object.

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point(colour = "#0E9694") +
  theme_surveyframe()
```
