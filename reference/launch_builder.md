# Launch the surveyframe visual survey builder

Opens the SurveyBuilder, a self-contained HTML application for visual
survey design. The builder runs client-side without an R session or
Shiny server. Save instruments as `.sframe` files from the browser and
load them into R with
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md).

## Usage

``` r
launch_builder(open = TRUE)
```

## Arguments

- open:

  Logical. When `TRUE` (the default), the builder HTML file is opened in
  the system's default web browser with
  [`utils::browseURL()`](https://rdrr.io/r/utils/browseURL.html). Set to
  `FALSE` to return the file path without opening it, which is useful
  for automated testing.

## Value

The path to the bundled builder HTML file, invisibly.

## Details

The builder includes a three-mode interface.

- Build:

  An item editor with a persistent inspector panel, drag-to-reorder,
  undo/redo, and autosave to browser localStorage.

- Preview:

  A full live render of the survey showing welcome, body, and thank-you
  pages.

- Analyse:

  A role-based analysis planner with method-specific options, planned
  outputs, reporting references, and decision rules.

The builder includes a pure-JavaScript SHA-256 fallback for browsers or
security policies where `crypto.subtle` is unavailable on `file://`
origins. Saved `.sframe` files can be loaded and validated with
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md).

## See also

[`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md),
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md),
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)

## Examples

``` r
# Retrieve the builder path for inspection without opening the browser
path <- launch_builder(open = FALSE)
file.exists(path)
#> [1] TRUE
```
