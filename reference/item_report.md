# Generate item-level diagnostics

Produces, for each item within each scale, the item-rest correlation,
floor and ceiling proportions, and the item mean and standard deviation.

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

An object of class `sframe_item_report`: a named list with one element
per scale, each a list holding `scale_id`, `label` and `diagnostics`, a
data frame with one row per item and columns `item_id`, `mean`, `sd`,
`item_rest_r`, `floor_pct`, `ceiling_pct` and `n_missing`.
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) stacks
every scale's diagnostics into one table.

## Details

Diagnostics use the scale's scoring orientation, so an item the scale
reverse-codes is reversed first, as in
[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md)
and
[`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md).
The item-rest correlation is the correlation between an item and the sum
of the scale's other items. It is computed on respondents who answered
every item in the scale, the same rows
[`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md)
uses, and `n_missing` counts the item's own missing values in `data`.

Floor and ceiling are the proportions at the item's declared lowest and
highest response, taken from its choice set, slider limits or rating
maximum. They are `NA` for an item that declares no bounds, since the
sample's own extremes say nothing about a floor or ceiling effect.

## See also

[`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md),
[`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md)

## Examples

``` r
# \donttest{
demo <- sframe_demo_data()
ir <- item_report(demo$responses, demo$instrument)
print(ir)
#> Item diagnostics: digital_marketing (Digital marketing effectiveness)
#> 
#>   item_id     mean        sd item_rest_r  floor_pct ceiling_pct n_missing
#> 1    dm_1 3.141667 0.9982828   0.6877922 0.05000000  0.10000000         0
#> 2    dm_2 3.125000 0.9663455   0.7061626 0.05000000  0.07500000         0
#> 3    dm_3 3.191667 0.9982828   0.7026148 0.05833333  0.08333333         0
#> 
#> Item diagnostics: service_quality (Service quality)
#> 
#>   item_id     mean       sd item_rest_r  floor_pct ceiling_pct n_missing
#> 1    sq_1 3.008333 1.041136   0.6873656 0.06666667  0.09166667         0
#> 2    sq_2 3.100000 1.007535   0.7302414 0.04166667  0.09166667         0
#> 3    sq_3 3.058333 1.031405   0.7124990 0.05833333  0.07500000         0
#> 
#> Item diagnostics: sustainability (Sustainability perception)
#> 
#>   item_id     mean        sd item_rest_r   floor_pct ceiling_pct n_missing
#> 1   sus_1 3.133333 0.8786289   0.6296654 0.008333333  0.07500000         0
#> 2   sus_2 3.241667 0.9437618   0.6296654 0.033333333  0.09166667         0
#> 
#> Item diagnostics: satisfaction (Tourist satisfaction)
#> 
#>   item_id     mean       sd item_rest_r  floor_pct ceiling_pct n_missing
#> 1   sat_1 3.325000 1.167936   0.6904532 0.06666667   0.1916667         0
#> 2   sat_2 3.258333 1.103819   0.6904532 0.03333333   0.1583333         0
#> 
#> Item diagnostics: behavioural_intention (Behavioural intention)
#> 
#>   item_id mean       sd item_rest_r  floor_pct ceiling_pct n_missing
#> 1    bi_1  3.1 1.125712   0.7299236 0.07500000   0.1250000         0
#> 2    bi_2  3.1 1.133152   0.7299236 0.08333333   0.1333333         0
#> 
# one scale's diagnostics
ir[[1]]$diagnostics
#>   item_id     mean        sd item_rest_r  floor_pct ceiling_pct n_missing
#> 1    dm_1 3.141667 0.9982828   0.6877922 0.05000000  0.10000000         0
#> 2    dm_2 3.125000 0.9663455   0.7061626 0.05000000  0.07500000         0
#> 3    dm_3 3.191667 0.9982828   0.7026148 0.05833333  0.08333333         0
# every scale in one table
as.data.frame(ir)
#>                 scale_id item_id     mean        sd item_rest_r   floor_pct
#> 1      digital_marketing    dm_1 3.141667 0.9982828   0.6877922 0.050000000
#> 2      digital_marketing    dm_2 3.125000 0.9663455   0.7061626 0.050000000
#> 3      digital_marketing    dm_3 3.191667 0.9982828   0.7026148 0.058333333
#> 4        service_quality    sq_1 3.008333 1.0411357   0.6873656 0.066666667
#> 5        service_quality    sq_2 3.100000 1.0075346   0.7302414 0.041666667
#> 6        service_quality    sq_3 3.058333 1.0314046   0.7124990 0.058333333
#> 7         sustainability   sus_1 3.133333 0.8786289   0.6296654 0.008333333
#> 8         sustainability   sus_2 3.241667 0.9437618   0.6296654 0.033333333
#> 9           satisfaction   sat_1 3.325000 1.1679365   0.6904532 0.066666667
#> 10          satisfaction   sat_2 3.258333 1.1038194   0.6904532 0.033333333
#> 11 behavioural_intention    bi_1 3.100000 1.1257117   0.7299236 0.075000000
#> 12 behavioural_intention    bi_2 3.100000 1.1331521   0.7299236 0.083333333
#>    ceiling_pct n_missing
#> 1   0.10000000         0
#> 2   0.07500000         0
#> 3   0.08333333         0
#> 4   0.09166667         0
#> 5   0.09166667         0
#> 6   0.07500000         0
#> 7   0.07500000         0
#> 8   0.09166667         0
#> 9   0.19166667         0
#> 10  0.15833333         0
#> 11  0.12500000         0
#> 12  0.13333333         0
# }
```
