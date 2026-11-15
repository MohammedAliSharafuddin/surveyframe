# Write an instrument to a .sframe file

Serialises an `sframe` instrument object to a UTF-8 JSON file with a
SHA-256 integrity hash. The instrument is always validated before
writing, and writes an instrument that passes validation. The hash is
computed over the content with `hash.value` set to an empty string, in
the canonical form of RFC 8785, the JSON Canonicalization Scheme: keys
sorted, numbers in their shortest form and whitespace removed. It
identifies content independently of the exact bytes, and SurveyBuilder
and the verifier page on the package website compute the same hash. An
`NA` is written as null where the published schema allows null for that
field. Elsewhere, the function names and rejects `NA` or a number
outside JSON's finite range, such as `Inf`.

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
  [`sframe_instrument()`](https://surveyframe.org/reference/sframe_instrument.md).

- path:

  Character. The file path to write to. The `.sframe` extension is
  appended automatically if not already present.

- pretty:

  Logical. Whether to write formatted JSON with indentation. Defaults to
  `TRUE`. Set to `FALSE` for compact files.

- overwrite:

  Logical. Whether to overwrite an existing file. Defaults to `FALSE`.

- new_instrument:

  Logical. `TRUE` declares that the content is a new instrument,
  separate from the one it was read from, so an amendment is
  unnecessary. The instrument must carry an empty amendment log, and an
  instrument read with
  [`read_sframe()`](https://surveyframe.org/reference/read_sframe.md)
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
[`amend_sframe()`](https://surveyframe.org/reference/amend_sframe.md).
Each entry must follow the one before it, the instrument must still
match its last recorded amendment, and an instrument read with
[`read_sframe()`](https://surveyframe.org/reference/read_sframe.md) must
keep every amendment it was read with. Content changed since it was read
is refused unless the change was recorded with
[`amend_sframe()`](https://surveyframe.org/reference/amend_sframe.md).
To publish changed content as a different instrument, remove its
amendment log and set `new_instrument = TRUE`.

These are checks on the content in hand. The hash is unsigned and can be
recomputed by anyone who edits a file, so it establishes content
integrity. Use a separate signing record to establish who wrote an
instrument and when.

The link between an instrument and the file it was read from is an
attribute, `sframe_origin`, that
[`read_sframe()`](https://surveyframe.org/reference/read_sframe.md)
sets. These checks rest on it. The package's own functions keep it,
among them
[`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md),
[`as_sframe()`](https://surveyframe.org/reference/as_sframe.md),
[`sframe_drop_items()`](https://surveyframe.org/reference/sframe_drop_items.md),
[`sframe_add_references()`](https://surveyframe.org/reference/sframe_add_references.md),
`sframe_plan<-` and
[`sframe_add_model()`](https://surveyframe.org/reference/sframe_add_model.md),
as do `$<-`, [`modifyList()`](https://rdrr.io/r/utils/modifyList.html)
and [`saveRDS()`](https://rdrr.io/r/base/readRDS.html) with
[`readRDS()`](https://rdrr.io/r/base/readRDS.html). Base R that builds a
new list from the parts drops it, such as `x[names(x)]`, `c(x)` or
[`lapply()`](https://rdrr.io/r/base/lapply.html) over the fields: the
result is an instrument built from its parts, and its changes are then
written outside the amendment record. Change a read instrument's fields
in place, and record the change with
[`amend_sframe()`](https://surveyframe.org/reference/amend_sframe.md).

## See also

[`read_sframe()`](https://surveyframe.org/reference/read_sframe.md),
[`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md)

Other Design functions:
[`as_sframe()`](https://surveyframe.org/reference/as_sframe.md),
[`launch_builder()`](https://surveyframe.org/reference/launch_builder.md),
[`read_sframe()`](https://surveyframe.org/reference/read_sframe.md),
[`sframe_attention_check()`](https://surveyframe.org/reference/sframe_attention_check.md),
[`sframe_branch()`](https://surveyframe.org/reference/sframe_branch.md),
[`sframe_choice_set()`](https://surveyframe.org/reference/sframe_choice_set.md),
[`sframe_conjoint_design()`](https://surveyframe.org/reference/sframe_conjoint_design.md),
[`sframe_get_study()`](https://surveyframe.org/reference/sframe_get_study.md),
[`sframe_instrument()`](https://surveyframe.org/reference/sframe_instrument.md),
[`sframe_item()`](https://surveyframe.org/reference/sframe_item.md),
[`sframe_sampling_methods()`](https://surveyframe.org/reference/sframe_sampling_methods.md),
[`sframe_scale()`](https://surveyframe.org/reference/sframe_scale.md),
[`sframe_validation`](https://surveyframe.org/reference/sframe_validation.md),
[`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md)

## Examples

``` r
instr <- read_sframe(
  system.file("extdata", "tourism_services_demo.sframe",
              package = "surveyframe")
)
out <- write_sframe(instr, tempfile(fileext = ".sframe"))
sframe_show(out)
```
