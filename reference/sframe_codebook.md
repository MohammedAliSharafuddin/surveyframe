# Generate a survey codebook from an instrument object

Produces a structured codebook listing all items, their types, choice
sets, scale membership, and reverse-coding status. The codebook can be
rendered as HTML or Markdown.

## Usage

``` r
sframe_codebook(instrument, format = c("html", "md"))
```

## Arguments

- instrument:

  An `sframe` object.

- format:

  Character. Output format. Either `"html"` or `"md"`. With `"md"`, the
  codebook also carries itself as Markdown text, in `markdown`, and
  [`print()`](https://rdrr.io/r/base/print.html) writes that text.

## Value

An object of class `sframe_codebook`, a list with elements
`instrument_meta`, `items_table`, `choices_table`, `scales_table`,
`plan_table`, `models_table` and `format`, and with `format = "md"`,
`markdown`: one character string holding the whole codebook as Markdown,
with a pipe table per component. Save it with
`writeLines(cb$markdown, "codebook.md")`. With `"html"`,
[`print()`](https://rdrr.io/r/base/print.html) shows a compact summary,
and
[`render_report()`](https://surveyframe.org/reference/render_report.md)
includes the codebook in a full report.

## See also

[`render_report()`](https://surveyframe.org/reference/render_report.md)

Other Report functions:
[`render_report()`](https://surveyframe.org/reference/render_report.md),
[`render_results()`](https://surveyframe.org/reference/render_results.md),
[`sframe_analysis_qmd()`](https://surveyframe.org/reference/sframe_analysis_qmd.md),
[`sframe_format_result()`](https://surveyframe.org/reference/sframe_format_result.md),
[`sframe_report_source()`](https://surveyframe.org/reference/sframe_report_source.md),
[`sframe_reports`](https://surveyframe.org/reference/sframe_reports.md),
[`sframe_save_figures()`](https://surveyframe.org/reference/sframe_save_figures.md),
[`sframe_show()`](https://surveyframe.org/reference/sframe_show.md)

## Examples

``` r
cs    <- sframe_choice_set("ag5", 1:5,
           c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree"))
i1    <- sframe_item("sat_1", "Item 1", type = "likert",
                 choice_set = "ag5", scale_id = "sat")
i2    <- sframe_item("sat_2", "Item 2", type = "likert",
                 choice_set = "ag5", scale_id = "sat")
scale <- sframe_scale("sat", "Satisfaction", items = c("sat_1", "sat_2"))
instr <- sframe_instrument("Demo Survey", components = list(cs, i1, i2, scale))

cb <- sframe_codebook(instr)
print(cb)
md <- sframe_codebook(instr, format = "md")
cat(substr(md$markdown, 1, 200))
nrow(sframe_get_items(cb))
nrow(sframe_get_scales(cb))
```
