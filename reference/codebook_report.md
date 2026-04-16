# Generate a survey codebook from an instrument object

Produces a structured codebook listing all items, their types, choice
sets, scale membership, and reverse-coding status. The codebook can be
rendered as HTML or Markdown.

## Usage

``` r
codebook_report(instrument, format = c("html", "md"))
```

## Arguments

- instrument:

  An `sframe` object.

- format:

  Character. Output format. Either `"html"` or `"md"`.

## Value

An object of class `sframe_codebook`, a list with elements
`instrument_meta`, `items_table`, `choices_table`, and `scales_table`.
Call [`print()`](https://rdrr.io/r/base/print.html) to display a compact
summary or use
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
to include the codebook in a full report.

## See also

[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)

## Examples

``` r
if (FALSE) { # \dontrun{
cb <- codebook_report(instr, format = "html")
print(cb)
} # }
```
