# Print an sframe instrument object

Displays a compact summary of an `sframe` instrument object, showing the
title, version, item count, scale count, and validation status.

## Usage

``` r
# S3 method for class 'sframe'
print(x, ...)
```

## Arguments

- x:

  An object of class `sframe`.

- ...:

  Ignored. Present for S3 consistency.

## Value

`x`, invisibly.

## Examples

``` r
item <- sf_item("q1", "How satisfied are you?", type = "likert",
                choice_set = "agree5")
instr <- sf_instrument("My Survey", components = list(item))
print(instr)
#> <sframe>
#>   Title:      My Survey
#>   Version:    0.1.0
#>   Items:      1
#>   Scales:     0
#>   Status:     not validated
```
