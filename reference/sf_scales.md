# Get survey scales

Returns the scale definitions, including their item membership and
scoring settings.

## Usage

``` r
sf_scales(x, ...)
```

## Arguments

- x:

  A surveyframe object.

- ...:

  Passed to methods.

## Value

An
[sf_component_list](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_component_list.md)
for an instrument or a scale data frame for a codebook.

## See also

[sf_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md)

## Examples

``` r
sf_scales(sframe_demo_data()$instrument)
#> <scale list: 5>
#>  <sf_scale: digital_marketing | 3 item(s)>
#>  <sf_scale: service_quality | 3 item(s)>
#>  <sf_scale: sustainability | 2 item(s)>
#>  <sf_scale: satisfaction | 2 item(s)>
#>  <sf_scale: behavioural_intention | 2 item(s)>
```
