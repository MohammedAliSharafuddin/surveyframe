# Print an sf_item object

Print an sf_item object

## Usage

``` r
# S3 method for class 'sf_item'
print(x, ...)
```

## Arguments

- x:

  An object of class `sf_item`.

- ...:

  Ignored. Present for S3 consistency.

## Value

`x`, invisibly.

## Examples

``` r
it <- sf_item("q1", "How satisfied are you?", type = "likert",
              choice_set = "agree5")
print(it)
#> <sf_item: q1 | type: likert>
#>   Label: How satisfied are you?
#>   Choice set: agree5
```
