# Get choice sets

Returns the reusable value-and-label sets referenced by closed-response
items.

## Usage

``` r
sf_choice_sets(x, ...)
```

## Arguments

- x:

  A surveyframe object.

- ...:

  Passed to methods.

## Value

An
[sf_component_list](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_component_list.md)
for an instrument or a choice-set data frame for a codebook.

## See also

[sf_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md)

## Examples

``` r
sf_choice_sets(sframe_demo_data()$instrument)
#> <choice set list: 3>
#>  <sf_choices: agree5 | 5 option(s)>
#>  <sf_choices: visit_type | 2 option(s)>
#>  <sf_choices: yes_no | 2 option(s)>
```
