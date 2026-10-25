# Write a bibliography as CSL-JSON

Writes the references a report cites as CSL-JSON, which pandoc, Quarto
and reference managers read directly. It holds the instrument's own
references, the method references of any analysis results given, and any
further references a host supplies, each once.
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
uses this for its References section, and a host that builds its own
documents can use the same file.

## Usage

``` r
sframe_bibliography(
  instrument = NULL,
  results = NULL,
  extra = NULL,
  file = NULL
)
```

## Arguments

- instrument:

  An `sframe` object, or `NULL`.

- results:

  Optional results from
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
  whose methods' references are included.

- extra:

  Optional further `sf_reference` objects, for example the references a
  host keeps for the write-up.

- file:

  Path to write. When `NULL`, the CSL-JSON is returned as a string.

## Value

The path, invisibly, or the JSON string when `file` is `NULL`.

## Examples

``` r
instr <- sframe_demo("two_group")$instrument
cat(substr(sframe_bibliography(instr), 1, 200))
#> []
```
