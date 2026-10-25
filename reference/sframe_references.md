# List an instrument's references

List an instrument's references

## Usage

``` r
sframe_references(instrument, cited_by = NULL)
```

## Arguments

- instrument:

  An `sframe` object.

- cited_by:

  Optional target, for example `"scale:satisfaction"`, to list only the
  references cited there.

## Value

A list of `sf_reference` objects, named by id.

## Examples

``` r
instr <- sframe_demo("likert_scale")$instrument
sframe_references(instr)
#> named list()
```
