# The ID and label of an instrument component

The ID and label of an instrument component

## Value

A single character string.
[`sf_label()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_label.md)
returns `""` when the component carries no label.

## Examples

``` r
item <- sf_item("q1", "How satisfied are you?", type = "likert",
                choice_set = "agree5")
sf_id(item)
#> [1] "q1"
sf_label(item)
#> [1] "How satisfied are you?"
```
