# Get branching rules

Returns the rules that control whether conditional items are shown.

## Usage

``` r
sf_branches(x, ...)
```

## Arguments

- x:

  A surveyframe object.

- ...:

  Passed to methods.

## Value

An
[sf_component_list](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_component_list.md)
of branching rules.

## See also

[sf_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md)

## Examples

``` r
sf_branches(sframe_demo_data()$instrument)
#> <branch rule list: 0>
```
