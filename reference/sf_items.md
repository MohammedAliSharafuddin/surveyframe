# Get survey items

Returns the declared question items in instrument order.

## Usage

``` r
sf_items(x, ...)
```

## Arguments

- x:

  A surveyframe object.

- ...:

  Passed to methods.

## Value

An
[sf_component_list](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_component_list.md)
for an instrument or an item data frame for a codebook.

## See also

[sf_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md)

## Examples

``` r
sf_items(sframe_demo_data()$instrument)
#> <item list: 15>
#>  <sf_item: visit_type | type: single_choice>
#>  <sf_item: dm_1 | type: likert>
#>  <sf_item: dm_2 | type: likert>
#>  <sf_item: dm_3 | type: likert>
#>  <sf_item: sq_1 | type: likert>
#>  <sf_item: sq_2 | type: likert>
#>  <sf_item: sq_3 | type: likert>
#>  <sf_item: sus_1 | type: likert>
#>  <sf_item: sus_2 | type: likert>
#>  <sf_item: sat_1 | type: likert>
#>  <sf_item: sat_2 | type: likert>
#>  <sf_item: bi_1 | type: likert>
#>  <sf_item: bi_2 | type: likert>
#>  <sf_item: attention | type: single_choice>
#>  <sf_item: comments | type: textarea>
```
