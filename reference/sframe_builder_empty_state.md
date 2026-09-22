# Create an empty SurveyStudio builder state

Create an empty SurveyStudio builder state

## Usage

``` r
sframe_builder_empty_state()
```

## Value

A list containing empty metadata, choice, item, scale, branching, and
check collections suitable for SurveyStudio.

## Examples

``` r
state <- sframe_builder_empty_state()
state$meta$title
#> [1] "Untitled Survey"
length(state$items)
#> [1] 0
```
