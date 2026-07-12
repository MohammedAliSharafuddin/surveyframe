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
# \donttest{
if (requireNamespace("psych", quietly = TRUE)) {
  demo <- sframe_demo_data()
  rr <- reliability_report(demo$responses, demo$instrument, omega = FALSE)
  print(rr)
}
#> Reliability Report
#> 
#> Scale: digital_marketing (Digital marketing effectiveness)
#>   Items: 3   N: 120
#>   Alpha:   0.837
#> 
#> Scale: service_quality (Service quality)
#>   Items: 3   N: 120
#>   Alpha:   0.844
#> 
#> Scale: sustainability (Sustainability perception)
#>   Items: 2   N: 120
#>   Alpha:   0.772
#> 
#> Scale: satisfaction (Tourist satisfaction)
#>   Items: 2   N: 120
#>   Alpha:   0.816
#> 
#> Scale: behavioural_intention (Behavioural intention)
#>   Items: 2   N: 120
#>   Alpha:   0.844
#> 
# }
```
