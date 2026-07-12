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

An object of class `sframe_item_report`, a list with one data.frame per
scale.

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
#> 1    dm_1 3.141667 0.9982828  -0.5118417 0.05000000  0.10000000         0
#> 2    dm_2 3.125000 0.9663455  -0.4619588 0.05000000  0.07500000         0
#> 3    dm_3 3.191667 0.9982828  -0.5122414 0.05833333  0.08333333         0
#> 
#> Item diagnostics: service_quality (Service quality)
#> 
#>   item_id     mean       sd item_rest_r  floor_pct ceiling_pct n_missing
#> 1    sq_1 3.008333 1.041136  -0.5085869 0.06666667  0.09166667         0
#> 2    sq_2 3.100000 1.007535  -0.4567793 0.04166667  0.09166667         0
#> 3    sq_3 3.058333 1.031405  -0.4946654 0.05833333  0.07500000         0
#> 
#> Item diagnostics: sustainability (Sustainability perception)
#> 
#>   item_id     mean        sd item_rest_r   floor_pct ceiling_pct n_missing
#> 1   sus_1 3.133333 0.8786289  -0.3616182 0.008333333  0.07500000         0
#> 2   sus_2 3.241667 0.9437618  -0.4965945 0.033333333  0.09166667         0
#> 
#> Item diagnostics: satisfaction (Tourist satisfaction)
#> 
#>   item_id     mean       sd item_rest_r  floor_pct ceiling_pct n_missing
#> 1   sat_1 3.325000 1.167936  -0.4530650 0.06666667   0.1916667         0
#> 2   sat_2 3.258333 1.103819  -0.3320542 0.03333333   0.1583333         0
#> 
#> Item diagnostics: behavioural_intention (Behavioural intention)
#> 
#>   item_id mean       sd item_rest_r  floor_pct ceiling_pct n_missing
#> 1    bi_1  3.1 1.125712  -0.3597099 0.07500000   0.1250000         0
#> 2    bi_2  3.1 1.133152  -0.3752154 0.08333333   0.1333333         0
#> 
# }
```
