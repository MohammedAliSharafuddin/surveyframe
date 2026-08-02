# Aggregate individual judgement matrices

Aggregation of individual judgements (AIJ) across respondents. The
element-wise geometric mean is the standard choice for reciprocal AHP
matrices, because it is the only mean that preserves reciprocity: the
arithmetic mean of `m[a, b]` and the arithmetic mean of `m[b, a]` are
not reciprocals of each other. DEMATEL matrices are not reciprocal, so
they aggregate arithmetically.

## Usage

``` r
sframe_aggregate_judgements(
  matrices,
  method = c("geometric", "arithmetic"),
  cr_filter = FALSE
)
```

## Arguments

- matrices:

  Either a list of square numeric matrices or the object returned by
  [`sframe_assemble_pairwise()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_assemble_pairwise.md).

- method:

  `"geometric"` (the AHP default) or `"arithmetic"` (DEMATEL).

- cr_filter:

  Logical. When `TRUE`, individual matrices with a consistency ratio at
  or above 0.10 are dropped before aggregation. Applies to reciprocal
  matrices only. Default `FALSE`.

## Value

A list with `matrix`, `method`, `n_respondents`, `n_dropped`,
`n_dropped_consistency`, and `consistency` (the per-respondent CR
distribution, or `NULL` for a non-reciprocal set).

## See also

[`sframe_assemble_pairwise()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_assemble_pairwise.md)

## Examples

``` r
m1 <- matrix(c(1, 3, 1 / 3, 1), 2, 2)
m2 <- matrix(c(1, 5, 1 / 5, 1), 2, 2)
sframe_aggregate_judgements(list(m1, m2))$matrix
#>          [,1]      [,2]
#> [1,] 1.000000 0.2581989
#> [2,] 3.872983 1.0000000
```
