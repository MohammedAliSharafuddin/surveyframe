# Print an sf_scale object

Print an sf_scale object

## Usage

``` r
# S3 method for class 'sf_scale'
print(x, ...)
```

## Arguments

- x:

  An object of class `sf_scale`.

- ...:

  Ignored. Present for S3 consistency.

## Value

`x`, invisibly.

## Examples

``` r
sc <- sf_scale("sat", "Satisfaction", items = c("q1", "q2", "q3"))
print(sc)
#> <sf_scale: sat | 3 item(s)>
#>   Label: Satisfaction
#>   Items: q1, q2, q3
#>   Scoring: mean
```
