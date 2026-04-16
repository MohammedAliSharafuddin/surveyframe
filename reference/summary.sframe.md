# Summarise an sframe instrument object

Prints a structured summary of an `sframe` object including metadata,
item type counts, scale definitions, branching rules, and check
specifications.

## Usage

``` r
# S3 method for class 'sframe'
summary(object, ...)
```

## Arguments

- object:

  An object of class `sframe`.

- ...:

  Ignored. Present for S3 consistency.

## Value

`object`, invisibly.

## Examples

``` r
item <- sf_item("q1", "How satisfied are you?", type = "likert",
                choice_set = "agree5")
instr <- sf_instrument("My Survey", components = list(item))
summary(instr)
#> Survey Instrument: My Survey
#> Version:           0.1.0
#> Languages:         en
#> 
#> Items:
#>   likert               1
#>   TOTAL                1
#> 
#> Scales:    0
#> Branches:  0
#> Checks:    0
#> Status:    not validated
```
