# List an instrument's references

List an instrument's references

## Usage

``` r
sframe_get_references(instrument, cited_by = NULL)
```

## Arguments

- instrument:

  An `sframe` object.

- cited_by:

  Optional target, for example `"scale:satisfaction"`, to list only the
  references cited there.

## Value

A list of `sf_reference` objects, named by id.

## See also

Other References functions:
[`read_bibtex()`](https://surveyframe.org/reference/read_bibtex.md),
[`sframe_add_references()`](https://surveyframe.org/reference/sframe_add_references.md),
[`sframe_bibliography()`](https://surveyframe.org/reference/sframe_bibliography.md),
[`sframe_reference()`](https://surveyframe.org/reference/sframe_reference.md)

## Examples

``` r
instr <- sframe_demo("likert_scale")$instrument
sframe_get_references(instr)
```
