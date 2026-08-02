# Assemble per-respondent comparison matrices

Builds one square judgement matrix per respondent from the pair columns
of a `"pairwise_comparison"` item. A `"saaty"` item stores one signed
integer per unordered pair, so the reciprocal half of each matrix is
reconstructed here rather than stored (a collected value of +5 becomes
`m[a, b] = 5` and `m[b, a] = 1/5`, and the diagonal is 1). An
`"influence"` item stores one unsigned integer per ordered pair, fills
the directed cell only, and has a zero diagonal, because the influence
of a on b says nothing about the influence of b on a.

## Usage

``` r
sframe_assemble_pairwise(data, instrument, item_id)
```

## Arguments

- data:

  A data frame of responses, as produced by
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md).

- instrument:

  An `sframe` instrument declaring `item_id`.

- item_id:

  Character. The id of a `"pairwise_comparison"` item.

## Value

A list with `matrices` (a list of square numeric matrices with
dimnames), `n_respondents`, `n_dropped`, `dropped` (a data frame of row
number and reason), `items`, and `scale`.

## Details

Respondents who left any pair blank, or whose answer falls outside the
declared scale, are dropped whole and counted. Completing partial
matrices (the Harker approach) is deliberately out of scope.

## See also

[`sframe_aggregate_judgements()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_aggregate_judgements.md),
[`sframe_collected_weights()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_collected_weights.md)

## Examples

``` r
crits <- c("price", "speed")
study <- sf_instrument(
  title = "Demo", components = list(
    sf_item("pairs", "Compare the criteria", type = "pairwise_comparison",
            comparison_items = crits)
  )
)
responses <- data.frame(pairs__price__vs__speed = c(3, -5))
sframe_assemble_pairwise(responses, study, "pairs")$matrices[[1]]
#>           price speed
#> price 1.0000000     3
#> speed 0.3333333     1
```
