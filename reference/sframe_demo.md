# Load one bundled demo

One of the 25 demos in the teaching library: 19 analysis examples, 3
presentation examples and 3 provenance examples. Or 1 of the 2 reference
datasets: `"tourism_services"`, a realistic multi-scale instrument, and
`"input_types"`, which uses every input type SurveyBuilder and
SurveyStudio support in a single instrument.

## Usage

``` r
sframe_demo(name, branded = FALSE, preview = interactive())
```

## Arguments

- name:

  Character. A demo name, as listed by
  [`sframe_list_demos()`](https://surveyframe.org/reference/sframe_list_demos.md).

- branded:

  Logical. When `TRUE`, the instrument comes back with the standard
  welcome page, logo, theme colour and thank-you page spliced into its
  `render` block. The bundled file on disk is left unchanged, so the
  same branding can be shown on whichever demo matches your own survey.

- preview:

  Logical. When `TRUE`, in an interactive session, the survey opens as a
  respondent sees it, in the viewer of RStudio, Positron or VS Code,
  else the browser, through
  [`sframe_show()`](https://surveyframe.org/reference/sframe_show.md).
  It is a preview, so answers go nowhere. Nothing opens in a script, a
  knitr or Quarto render, or with
  `options(surveyframe.demo_preview = FALSE)`.

## Value

A list of class `sframe_demo` with `instrument`, `responses` and the
paths behind them. Printed, it shows a short card: what the demo
teaches, its size, its files and the commands to try next. The parts are
`instrument`, `responses`, `instrument_path`, `responses_path`,
`codebook_path` and `results_path`. The codebook carries variable and
value labels, so the data means something outside R. The results table
is what surveyframe reports for this demo, which is the reference to
compare against when you run the same data through another package. The
2 reference datasets omit codebook or results table, so those 2 paths
are `NA`.

## How the demos may be used

The demos' responses are simulated. Each respondent id starts with
`DEMO-`, and a `data_status` column says "Demonstration data, not
collected from participants". Every output made from data that carries
it says so too: each APA sentence from
[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md)
ends with "(demonstration data)", and a report's title, its opening line
and each table and figure title carry the same, also after the data is
copied into another project. Use the demos to learn, teach and test a
method or an instrument. Presenting their results as findings, or
editing the data to hide where it came from, is fabrication. The stamp
makes a copied output visible to a reader.

## See also

[`sframe_list_demos()`](https://surveyframe.org/reference/sframe_list_demos.md),
[`export_responses()`](https://surveyframe.org/reference/export_responses.md)

Other Demo functions:
[`sframe_demo_qmd()`](https://surveyframe.org/reference/sframe_demo_qmd.md),
[`sframe_list_demos()`](https://surveyframe.org/reference/sframe_list_demos.md)

## Examples

``` r
demo <- sframe_demo("two_group")
demo
head(demo$responses)
```
