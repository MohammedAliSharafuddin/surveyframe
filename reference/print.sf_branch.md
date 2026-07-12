# Print an sf_branch object

Print an sf_branch object

## Usage

``` r
# S3 method for class 'sf_branch'
print(x, ...)
```

## Arguments

- x:

  An object of class `sf_branch`.

- ...:

  Ignored. Present for S3 consistency.

## Value

`x`, invisibly.

## Examples

``` r
br <- sf_branch("q2", depends_on = "q1", operator = "==",
                value = "yes", action = "show")
print(br)
#> <sf_branch: q2>
#>   Rule: show when q1 == yes
```
