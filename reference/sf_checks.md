# Get response-quality checks

Returns declared attention and other response-quality checks.

## Usage

``` r
sf_checks(x, ...)
```

## Arguments

- x:

  A surveyframe object.

- ...:

  Passed to methods.

## Value

An
[sf_component_list](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_component_list.md)
of declared checks.

## See also

[sf_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md)

## Examples

``` r
sf_checks(sframe_demo_data()$instrument)
#> <attention check list: 1>
#>  <sf_check: attention_agree | type: attention | item: attention>
```
