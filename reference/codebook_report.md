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
cs    <- sf_choices("ag5", 1:5,
           c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree"))
i1    <- sf_item("sat_1", "Item 1", type = "likert",
                 choice_set = "ag5", scale_id = "sat")
i2    <- sf_item("sat_2", "Item 2", type = "likert",
                 choice_set = "ag5", scale_id = "sat")
scale <- sf_scale("sat", "Satisfaction", items = c("sat_1", "sat_2"))
instr <- sf_instrument("Demo Survey", components = list(cs, i1, i2, scale))

cb <- codebook_report(instr)
print(cb)
#> Codebook: Demo Survey v0.1.0
#>   2 items  |  1 choice sets  |  1 scales
#> 
#> Items:
#>      id  label   type scale_id reverse
#> 1 sat_1 Item 1 likert      sat   FALSE
#> 2 sat_2 Item 2 likert      sat   FALSE
nrow(cb$items_table)
#> [1] 2
nrow(cb$scales_table)
#> [1] 1
```
