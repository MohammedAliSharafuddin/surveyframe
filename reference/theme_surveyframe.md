# surveyframe brand theme for ggplot2

A light, publication-oriented ggplot2 theme matching the surveyframe
report brand: dark ink typography, a teal accent, and quiet horizontal
grid lines. Apply it to any ggplot object, including the plots returned
by
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
when `plots = TRUE`.

## Usage

``` r
theme_surveyframe(base_size = 12, base_family = "")
```

## Arguments

- base_size:

  Numeric. Base font size in points. Defaults to 12.

- base_family:

  Character. Base font family. Defaults to `""` (the device default).

## Value

A ggplot2 theme object.

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point(colour = "#16B3B1") +
  theme_surveyframe()
```
