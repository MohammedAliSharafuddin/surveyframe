# SurveyBuilder GUI overview

`surveyframe` has three graphical entry points. They are intentionally
kept separate in v0.3.

- [`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md)
  is a standalone questionnaire builder. It runs in the browser and
  saves `.sframe` files for later use in R.
- [`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md)
  is the workflow hub. It can build, preview, load responses, run
  quality and reliability checks, plan analyses, and export outputs.
- [`launch_dashboard()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard.md)
  is a read-only response explorer for instruments and response data
  that are already available.

## Input-types demo

The input-types demo covers the main controls supported by SurveyBuilder
and SurveyStudio.

``` r

demo <- sframe_input_types_demo_data()
instr <- demo$instrument
responses <- demo$responses

table(vapply(instr$items, function(x) x$type, character(1)))
#> 
#>            date          likert          matrix multiple_choice         numeric 
#>               1               5               1               1               1 
#>         ranking          rating   section_break   single_choice          slider 
#>               1               1               1               4               1 
#>            text      text_block        textarea 
#>               2               1               1
dim(responses)
#> [1] 120  22
```

## Recommended GUI workflow

1.  Use
    [`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md)
    to create or revise a questionnaire.
2.  Save the instrument as a `.sframe` file.
3.  Use
    [`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)
    to load the saved instrument in R.
4.  Use
    [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
    to import collected data.
5.  Use
    [`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md)
    to inspect the instrument and responses together.
6.  Use
    [`launch_dashboard()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard.md)
    for read-only response exploration.

## Demo launchers

This vignette leaves the demo launchers unevaluated because CRAN
examples and vignettes should avoid opening browsers.

``` r

launch_builder_demo()
launch_studio_demo()
launch_dashboard_demo()
```

[`launch_builder_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder_demo.md)
injects the demo instrument state directly into a temporary copy of
`survey_builder.html` and opens it. The demo questions, scales, and
analysis plan are visible immediately — no manual Load .sframe step is
needed.
[`launch_studio_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio_demo.md)
opens the full workflow with an instrument and response data already
loaded, and always opens the browser automatically.
[`launch_dashboard_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard_demo.md)
opens the response dashboard with the same demo data and also always
opens the browser automatically.

## Standalone builder

``` r

builder_file <- launch_builder(open = FALSE)
builder_file
```

Use the builder when the immediate task is questionnaire authoring. The
builder is client-side and is best kept for questionnaire authoring.
Response exploration belongs in SurveyStudio or the dashboard.

## Studio workflow hub

``` r

launch_studio(
  instrument = instr,
  responses = responses,
  screen = "analysis",
  launch.browser = FALSE
)
```

SurveyStudio reads preloaded objects passed by
[`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md).
When response data are present, `screen = "auto"` opens the dashboard
screen. The dashboard button in Studio explains how to open the separate
dashboard launcher from the R console.

## Dashboard

``` r

launch_dashboard(
  instrument = instr,
  responses = responses,
  launch.browser = FALSE
)
```

Use the dashboard after data collection for read-only exploration. In
v0.4, the dashboard can be refactored into a native SurveyStudio tab
after the v0.3 CRAN release is stable.

## Known limitations

SurveyBuilder stores short autosave recovery data in browser
`localStorage`. Browsers can clear that storage when site data are
cleared, private browsing is used, or a storage quota is reached. Save a
`.sframe` file before closing the browser when work matters.

The builder first tries the browser `crypto.subtle` API for SHA-256
hashing and then uses the bundled JavaScript fallback. This supports
browsers that restrict `crypto.subtle` on local `file://` pages.

## Moving files between tools

The `.sframe` file is the shared object between the GUI and R workflow:

1.  Build or edit the questionnaire in SurveyBuilder.
2.  Save the `.sframe` file.
3.  Load it in R with
    [`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md).
4.  Import responses with
    [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md).
5.  Use SurveyStudio or the dashboard for response checking and
    reporting.
