# Compute reliability statistics for scored scales

Produces Cronbach's alpha and McDonald's omega for each scale defined in
the instrument, along with the number of items and sample size.

## Usage

``` r
reliability_report(data, instrument, scales = NULL, alpha = TRUE, omega = TRUE)
```

## Arguments

- data:

  A `tibble` or `data.frame` of responses. Item columns must be present.

- instrument:

  An `sframe` object.

- scales:

  Character vector or NULL. A subset of scale IDs to analyse. When NULL
  (default), all scales in the instrument are included.

- alpha:

  Logical. Whether to compute Cronbach's alpha. Defaults to `TRUE`.

- omega:

  Logical. Whether to compute McDonald's omega. Defaults to `TRUE`.

## Value

An object of class `sframe_reliability_report`, a list with one element
per scale. Each element is a list of statistics and a summary tibble.

## See also

[`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md),
[`item_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/item_report.md)

## Examples

``` r
if (FALSE) { # \dontrun{
rr <- reliability_report(responses, instr)
print(rr)
} # }
```
