# A list of instrument components

The value returned by
[`sf_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md),
[`sf_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md),
[`sf_choice_sets()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md),
[`sf_branches()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md),
[`sf_checks()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md)
and
[`sf_models()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md).
It is a list of component objects named by their IDs, so a single
component is reached with `[[`.

## Usage

``` r
# S3 method for class 'sf_component_list'
print(x, ...)

# S3 method for class 'sf_component_list'
x[i, ...]
```

## Arguments

- x:

  An `sf_component_list`.

- ...:

  Ignored. Present for S3 consistency.

- i:

  Index, name, or logical vector selecting components.

## Value

[`print()`](https://rdrr.io/r/base/print.html) returns `x` invisibly.
`[` returns an `sf_component_list`.

## Examples

``` r
item1 <- sf_item("q1", "First question", type = "text")
item2 <- sf_item("q2", "Second question", type = "text")
instr <- sf_instrument("Demo", components = list(item1, item2))

sf_items(instr)
#> <item list: 2>
#>  <sf_item: q1 | type: text>
#>  <sf_item: q2 | type: text>
sf_items(instr)[["q2"]]
#> <sf_item: q2 | type: text>
#>   Label: Second question
```
