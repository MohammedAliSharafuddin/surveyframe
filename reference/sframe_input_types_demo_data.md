# Load the input-types demo backing SurveyBuilder and SurveyStudio

Loads the bundled `.sframe` instrument and simulated response dataset
that cover all main survey input types supported by surveyframe. This is
a different demo from the 22-item teaching library behind
[`sframe_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo.md):
where
[`sframe_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo.md)
demonstrates one analysis method per call, this one exists to exercise
every input control SurveyBuilder and SurveyStudio support in a single
instrument, and is what backs
[`launch_builder_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder_demo.md),
[`launch_studio_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio_demo.md),
and
[`launch_dashboard_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard_demo.md).

## Usage

``` r
sframe_input_types_demo_data()
```

## Value

A list with `instrument`, `responses`, `instrument_path`, and
`responses_path`.

## See also

[`sframe_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo.md)
for the 22-item teaching library instead.

## Examples

``` r
demo <- sframe_input_types_demo_data()
sf_meta(demo$instrument)$title
#> [1] "Surveyframe Demo: Survey Title"
nrow(demo$responses)
#> [1] 120
```
