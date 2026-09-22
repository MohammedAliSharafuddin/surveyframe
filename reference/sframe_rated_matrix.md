# Build a performance matrix from rated matrix items

The third collection path: respondents rate every alternative on every
criterion with ordinary matrix items, one item per criterion with the
alternatives as its rows, and the decision matrix is the per-cell
aggregate. No new item type is needed. Per-cell counts and standard
deviations are kept so the report can show how firm each cell is.

## Usage

``` r
sframe_rated_matrix(data, instrument, items, statistic = c("mean", "median"))
```

## Arguments

- data:

  A data frame of responses.

- instrument:

  An `sframe` instrument declaring every id in `items`.

- items:

  Character vector of `"matrix"` item ids, one per criterion, in the
  intended criterion order. Every item must declare the same
  `matrix_items` (the alternatives) in the same order. When a decision
  block also collects weights through a `weights_item` whose criterion
  names differ from these ids, the items pair with its criteria in this
  order, and the result notes each pairing.

- statistic:

  `"mean"` or `"median"`.

## Value

A list with `matrix` (alternatives x criteria, with dimnames), `n`,
`sd`, `alternatives`, `criteria`, and `statistic`.

## See also

[`sframe_collected_weights()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_collected_weights.md)

## Examples

``` r
q5    <- sf_choices("q5", 1:5,
           c("Very poor", "Poor", "Fair", "Good", "Excellent"))
price <- sf_item("rate_price", "Rate each supplier: value",
                 type = "matrix", matrix_items = c("Alpha", "Basilica"),
                 choice_set = "q5")
study <- sf_instrument("Supplier selection", components = list(q5, price))
responses <- data.frame(rate_price__Alpha = c(3, 4), rate_price__Basilica = c(5, 5))
rm <- sframe_rated_matrix(responses, study, "rate_price")
rm$matrix
#>          rate_price
#> Alpha           3.5
#> Basilica        5.0
```
