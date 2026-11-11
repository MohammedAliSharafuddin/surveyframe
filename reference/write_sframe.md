# Write an instrument to a .sframe file

Serialises an `sframe` instrument object to a UTF-8 JSON file with a
SHA-256 integrity hash. The instrument is always validated before
writing, and an invalid instrument is refused. The hash is computed over
the content with `hash.value` set to an empty string, in the canonical
form of RFC 8785, the JSON Canonicalization Scheme: keys sorted, numbers
in their shortest form and no whitespace. So it identifies content, not
the exact bytes, and SurveyBuilder and the verifier page on the package
website compute the same hash. An `NA` is written as null where the
published schema allows null for that field, and refused with the field
named anywhere else, as is a number JSON cannot hold, such as `Inf`.

## Usage

``` r
write_sframe(
  instrument,
  path,
  pretty = TRUE,
  overwrite = FALSE,
  new_instrument = FALSE
)
```

## Arguments

- instrument:

  An `sframe` object created by
  [`sframe_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_instrument.md).

- path:

  Character. The file path to write to. The `.sframe` extension is
  appended automatically if not already present.

- pretty:

  Logical. Whether to write formatted JSON with indentation. Defaults to
  `TRUE`. Set to `FALSE` for compact files.

- overwrite:

  Logical. Whether to overwrite an existing file. Defaults to `FALSE`.

- new_instrument:

  Logical. `TRUE` declares that the content is a new instrument, not a
  revision of the one it was read from, so no amendment is required. The
  instrument must carry no amendment log, and an instrument read with
  [`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)
  must have a new `meta$title` or `meta$version`, so 2 different files
  never claim to be one instrument. Defaults to `FALSE`.

## Value

The file path, invisibly.

## Details

The hash object is
`{"algo": "sha256", "value": ..., "canonical": "rfc8785"}`. `canonical`
names the canonical form the hash was taken in. It sits inside the
hashed content, so changing it after writing breaks the hash.

## Revisions and the amendment log

Writing checks the amendment log recorded by
[`amend_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amend_sframe.md).
Each entry must follow the one before it, the instrument must still
match its last recorded amendment, and an instrument read with
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)
must keep every amendment it was read with. Content changed since it was
read is refused unless the change was recorded with
[`amend_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amend_sframe.md).
To publish changed content as a different instrument, remove its
amendment log and set `new_instrument = TRUE`.

These are checks on the content in hand. The hash is unsigned and can be
recomputed by anyone who edits a file, so it does not establish who
wrote an instrument or when.

The link between an instrument and the file it was read from is an
attribute, `sframe_origin`, that
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)
sets. These checks rest on it. The package's own functions keep it,
among them
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md),
[`sframe_drop_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_drop_items.md),
[`sframe_add_references()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_add_references.md),
`sframe_plan<-` and
[`sframe_add_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_add_model.md),
as do `$<-`, [`modifyList()`](https://rdrr.io/r/utils/modifyList.html)
and [`saveRDS()`](https://rdrr.io/r/base/readRDS.html) with
[`readRDS()`](https://rdrr.io/r/base/readRDS.html). Base R that builds a
new list from the parts drops it, such as `x[names(x)]`, `c(x)` or
[`lapply()`](https://rdrr.io/r/base/lapply.html) over the fields: the
result is an instrument read from no file, and its changes are then
written with no amendment recorded. Change a read instrument's fields in
place, and record the change with
[`amend_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amend_sframe.md).

## See also

[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)

Other Design functions:
[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md),
[`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md),
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md),
[`sframe_attention_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_attention_check.md),
[`sframe_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_branch.md),
[`sframe_choice_set()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_choice_set.md),
[`sframe_conjoint_design()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_conjoint_design.md),
[`sframe_get_study()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_study.md),
[`sframe_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_instrument.md),
[`sframe_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item.md),
[`sframe_sampling_methods()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_sampling_methods.md),
[`sframe_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_scale.md),
[`sframe_validation`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)

## Examples

``` r
instr <- read_sframe(
  system.file("extdata", "tourism_services_demo.sframe",
              package = "surveyframe")
)
out <- write_sframe(instr, tempfile(fileext = ".sframe"))
file.exists(out)
#> [1] TRUE
```
