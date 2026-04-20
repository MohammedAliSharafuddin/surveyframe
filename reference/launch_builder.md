# Launch the surveyframe visual survey builder

Opens the SurveyBuilder, a self-contained HTML application for designing
survey instruments visually. The builder runs entirely in the browser
with no active R session or Shiny server required. Instruments are saved
as `.sframe` files and loaded back into R with
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md).

## Usage

``` r
launch_builder(open = TRUE)
```

## Arguments

- open:

  Logical. If `TRUE` (the default), opens the builder in the default
  browser. Set to `FALSE` to return the file path without opening, which
  is useful for testing.

## Value

Returns the path to the builder HTML file invisibly.

## Details

The builder provides a three-mode interface: Build (item editor with
persistent inspector panel), Preview (full survey render with welcome,
body, and thank-you pages), and Analyse (research question planning with
automatic test suggestion and citation lookup). All changes autosave to
browser localStorage. The final instrument is exported as a `.sframe`
file.

## See also

[`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md),
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md),
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)

## Examples

``` r
if (FALSE) { # \dontrun{
launch_builder()
} # }

# Get path without opening (useful for testing)
path <- launch_builder(open = FALSE)
```
