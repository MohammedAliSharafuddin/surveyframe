# Print an sf_choices object

Print an sf_choices object

## Usage

``` r
# S3 method for class 'sf_choices'
print(x, ...)
```

## Arguments

- x:

  An object of class `sf_choices`.

- ...:

  Ignored. Present for S3 consistency.

## Value

`x`, invisibly.

## Examples

``` r
cs <- sf_choices("agree5", 1:5,
                 c("Strongly disagree", "Disagree", "Neutral",
                   "Agree", "Strongly agree"))
print(cs)
#> <sf_choices: agree5 | 5 option(s)>
#>  value             label
#>      1 Strongly disagree
#>      2          Disagree
#>      3           Neutral
#>      4             Agree
#>      5    Strongly agree
```
