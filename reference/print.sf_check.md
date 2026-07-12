# Print an sf_check object

Print an sf_check object

## Usage

``` r
# S3 method for class 'sf_check'
print(x, ...)
```

## Arguments

- x:

  An object of class `sf_check`.

- ...:

  Ignored. Present for S3 consistency.

## Value

`x`, invisibly.

## Examples

``` r
ck <- sf_check("attn1", item_id = "q5", type = "attention",
               pass_values = 3)
print(ck)
#> <sf_check: attn1 | type: attention>
#>   Item: q5
#>   Pass values: 3
```
