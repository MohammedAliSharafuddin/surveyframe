# Show a file surveyframe wrote

Opens a file in the viewer of RStudio, Positron or VS Code when it is an
HTML page, and otherwise in the web browser or the program the system
opens it with. It opens files only in an interactive session. In a
script, a knitr or Quarto render or under `R CMD check` it opens nothing
and prints the file's path on a line of its own, so a file written to
the temporary folder is never left unseen. The examples that write a
file end with it.

## Usage

``` r
sframe_show(path, quiet = FALSE, option = NULL)
```

## Arguments

- path:

  Character. The file to show.

- quiet:

  Logical. When `TRUE`, nothing is printed when the file is not opened.
  Defaults to `FALSE`.

- option:

  Character or `NULL`. The name of an option that, set to `FALSE`, keeps
  the file closed, for a function with its own switch.

## Value

`TRUE` when the file was opened, `FALSE` otherwise, invisibly.

## See also

Other Report functions:
[`render_report()`](https://surveyframe.org/reference/render_report.md),
[`render_results()`](https://surveyframe.org/reference/render_results.md),
[`sframe_analysis_qmd()`](https://surveyframe.org/reference/sframe_analysis_qmd.md),
[`sframe_codebook()`](https://surveyframe.org/reference/sframe_codebook.md),
[`sframe_format_result()`](https://surveyframe.org/reference/sframe_format_result.md),
[`sframe_report_source()`](https://surveyframe.org/reference/sframe_report_source.md),
[`sframe_reports`](https://surveyframe.org/reference/sframe_reports.md),
[`sframe_save_figures()`](https://surveyframe.org/reference/sframe_save_figures.md)

## Examples

``` r
path <- file.path(tempdir(), "hello.html")
writeLines("<h1>Hello</h1>", path)
sframe_show(path)
```
