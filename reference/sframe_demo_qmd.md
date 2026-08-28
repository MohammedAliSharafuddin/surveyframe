# Copy a demo's Quarto notebook so you can run and change it

The code route through a demo is a notebook that renders to a report,
which is what a research workflow looks like. This writes one for the
named demo: load the instrument, read the responses, run the
pre-declared plan, render the report, and export the data for checking
elsewhere.

## Usage

``` r
sframe_demo_qmd(name, dir = ".", overwrite = FALSE)
```

## Arguments

- name:

  Character. A demo name, as listed by
  [`sframe_demos()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demos.md).

- dir:

  Directory to write into. Defaults to the working directory.

- overwrite:

  Logical. Overwrite an existing file of the same name.

## Value

The path written, invisibly.

## See also

[`sframe_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo.md),
[`sframe_demos()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demos.md)

## Examples

``` r
out <- sframe_demo_qmd("two_group", dir = tempdir())
basename(out)
#> [1] "two_group.qmd"
```
