# Write a Quarto analysis notebook for any instrument

Unlike
[`sframe_demo_qmd()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo_qmd.md),
which only works for one of the bundled demo instruments (it looks
`name` up in
[`sframe_demos()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demos.md)),
this writes a runnable Quarto notebook for any instrument, using its own
responses. It exposes the complete ordered plan, screening, run status,
detailed results, plots and reports. The notebook reads the instrument
and its responses back from 2 companion files written alongside it, so
all 3 files must stay together.

## Usage

``` r
sframe_analysis_qmd(
  instrument,
  data,
  dir = ".",
  basename = NULL,
  overwrite = FALSE
)
```

## Arguments

- instrument:

  An `sframe` object.

- data:

  A `data.frame` of responses, read by
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
  when the notebook runs.

- dir:

  Directory to write into. Defaults to the working directory.

- basename:

  Character or `NULL`. File base name shared by the `.qmd`, `.sframe`,
  and `_responses.csv` files. Defaults to a slug of the instrument's
  title.

- overwrite:

  Logical. Overwrite existing files of the same name.

## Value

A list with `qmd`, `sframe`, and `csv` paths, invisibly.

## See also

[`sframe_demo_qmd()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo_qmd.md),
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md),
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)

## Examples

``` r
item  <- sf_item("q1", "How satisfied are you?", type = "text")
instr <- sf_instrument("Demo", components = list(item))
resp  <- data.frame(q1 = c("Great", "Fine"))
out <- sframe_analysis_qmd(instr, resp, dir = tempdir())
#> Notebook written to: /tmp/Rtmpslj9I3/Demo.qmd
#> Instrument and responses written alongside it: Demo.sframe, Demo_responses.csv
#> Keep all 3 files together, then open and render the notebook.
basename(out$qmd)
#> [1] "Demo.qmd"
```
