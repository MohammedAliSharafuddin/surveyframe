# Score defined scales from survey responses

Applies scale scoring rules from the instrument to response data.
Handles reverse coding, optional weighted composite score computation,
and minimum valid item thresholds. Returns a data frame with one scored
column per scale.

## Usage

``` r
score_scales(data, instrument, keep_items = TRUE, keep_meta = TRUE)
```

## Arguments

- data:

  A `tibble` or `data.frame` of responses.

- instrument:

  An `sframe` object.

- keep_items:

  Logical. Whether to retain individual item columns in the output.
  Defaults to `TRUE`.

- keep_meta:

  Logical. Whether to retain non-item columns (metadata) in the output.
  Defaults to `TRUE`.

## Value

A `tibble` with scored scale columns appended. Scale columns are named
using the scale `id`.

## See also

[`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md),
[`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md)

## Examples

``` r
if (FALSE) { # \dontrun{
scored <- score_scales(responses, instr)
} # }
```
