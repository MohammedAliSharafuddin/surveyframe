# Generate item-level diagnostics

Produces item-total correlations, floor and ceiling effect proportions,
and item means and standard deviations for each item within each scale.

## Usage

``` r
item_report(data, instrument, scales = NULL)
```

## Arguments

- data:

  A `tibble` or `data.frame` of responses.

- instrument:

  An `sframe` object.

- scales:

  Character vector or NULL. A subset of scale IDs to analyse. When NULL
  (default), all scales are included.

## Value

An object of class `sframe_item_report`, a list with one tibble per
scale.

## See also

[`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md),
[`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md)

## Examples

``` r
if (FALSE) { # \dontrun{
ir <- item_report(responses, instr)
print(ir)
} # }
```
