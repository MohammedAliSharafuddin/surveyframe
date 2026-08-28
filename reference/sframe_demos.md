# List the bundled demos

Every demo does one job, so a failure points at one method and a reader
can hold the whole questionnaire in view. Use
[`sframe_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo.md)
to load one.

## Usage

``` r
sframe_demos()
```

## Value

A data frame with 1 row per demo: its `name`, whether its `focus` is
analysis, presentation or provenance, what it `teaches`, the input
`fields` it uses, the statistical `technique` it demonstrates, and the
demo whose responses it reuses, if any.

## See also

[`sframe_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo.md),
[`sframe_demo_branding()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo_branding.md),
[`sframe_demo_qmd()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo_qmd.md)

## Examples

``` r
head(sframe_demos(), 3)
#>            name    focus                                       teaches
#> 1  first_survey analysis             Design, export, collect, describe
#> 2  likert_scale analysis         A scale and whether it holds together
#> 3 matrix_likert analysis A matrix item and the columns it expands into
#>                                                          fields
#> 1 single_choice, numeric, date, text, section_break, text_block
#> 2                                                        likert
#> 3                                         matrix, single_choice
#>                                                                    technique
#> 1                             frequency, descriptives, missing_data, quality
#> 2 scale_descriptives, reliability_alpha, reliability_omega, item_diagnostics
#> 3                                          descriptives, frequency, crosstab
#>   reuse
#> 1  <NA>
#> 2  <NA>
#> 3  <NA>
subset(sframe_demos(), focus == "provenance")
#>                   name      focus
#> 21 instrument_revision provenance
#> 22        verification provenance
#>                                            teaches          fields
#> 21 Changing an instrument mid-study, on the record as first_survey
#> 22       Proving a file is the one you think it is as first_survey
#>                                         technique        reuse
#> 21 frequency, descriptives, missing_data, quality first_survey
#> 22 frequency, descriptives, missing_data, quality first_survey
```
