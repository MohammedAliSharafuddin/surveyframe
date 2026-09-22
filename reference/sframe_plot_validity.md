# Validity report plot: composite reliability and AVE by construct

Validity report plot: composite reliability and AVE by construct

## Usage

``` r
sframe_plot_validity(x, palette = c("web", "print"))
```

## Arguments

- x:

  An `sframe_validity_report` object from
  [`validity_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validity_report.md).

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object.

## See also

[`validity_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validity_report.md)

## Examples

``` r
# \donttest{
if (requireNamespace("ggplot2", quietly = TRUE)) {
  loadings <- list(
    sq  = c(sq_1 = 0.80, sq_2 = 0.75, sq_3 = 0.78),
    sat = c(sat_1 = 0.85, sat_2 = 0.82)
  )
  vr <- validity_report(loadings)
  sframe_plot_validity(vr)
}

# }
```
