# Get model specifications

Returns declared CFA, SEM, PLS-SEM, mediation, and related model
objects.

## Usage

``` r
sf_models(x, ...)
```

## Arguments

- x:

  A surveyframe object.

- ...:

  Passed to methods.

## Value

An
[sf_component_list](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_component_list.md)
for an instrument or a model data frame for a codebook.

## See also

[sf_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md)

## Examples

``` r
sf_models(sframe_demo_data()$instrument)
#> <model list: 3>
#>  <sf_model: tourism_cfa | type: cfa | 5 construct(s)>
#>  <sf_model: tourism_sem | type: cb_sem | 5 construct(s)>
#>  <sf_model: tourism_pls | type: pls_sem | 5 construct(s)>
```
