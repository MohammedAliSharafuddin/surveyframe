# List the bundled demos

Lists the demos that ship with the package. Every demo does one job, so
a failure points at one method and a reader can hold the whole
questionnaire in view. Use
[`sframe_demo()`](https://surveyframe.org/reference/sframe_demo.md) to
load one.

## Usage

``` r
sframe_list_demos()
```

## Value

A data frame of class `sframe_demo_list` with 1 row per demo: its
`name`, whether its `focus` is analysis, presentation, provenance or
reference, what it `teaches`, the input `fields` it uses, the
statistical `technique` it demonstrates and the demo whose responses it
reuses, if any. Printed, it shows 1 line per demo, grouped by focus,
with `two_group` named as the place to start.
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) gives the
full table.

## Details

The 25 teaching demos come first. The last 2 rows, with focus
`"reference"`, are larger datasets: `"tourism_services"`, a realistic
multi-scale instrument, and `"input_types"`, which uses every input type
SurveyBuilder and SurveyStudio support.

## See also

[`sframe_demo()`](https://surveyframe.org/reference/sframe_demo.md),
[`sframe_demo_qmd()`](https://surveyframe.org/reference/sframe_demo_qmd.md)

Other Demo functions:
[`sframe_demo()`](https://surveyframe.org/reference/sframe_demo.md),
[`sframe_demo_qmd()`](https://surveyframe.org/reference/sframe_demo_qmd.md)

## Examples

``` r
sframe_list_demos()
head(as.data.frame(sframe_list_demos())[, c("name", "focus")], 3)
```
