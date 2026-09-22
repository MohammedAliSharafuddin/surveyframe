# Convert an instrument into a SurveyStudio builder state

Convert an instrument into a SurveyStudio builder state

## Usage

``` r
sframe_builder_state_from_instrument(instrument = NULL)
```

## Arguments

- instrument:

  An `sframe` object or `NULL`.

## Value

A builder state list. Component classes are restored so the state can be
edited or validated by SurveyStudio.

## Examples

``` r
demo <- sframe_demo_data()
state <- sframe_builder_state_from_instrument(demo$instrument)
length(state$items)
#> [1] 15
length(state$scales)
#> [1] 5
```
