# Write an instrument to a .sframe file

Serialises an `sframe` instrument object to a UTF-8 JSON file with a
SHA-256 integrity hash. The instrument is always validated before
writing, and an invalid instrument is refused. The hash is computed over
a canonical serialisation of the content with `hash.value` set to an
empty string: object keys are sorted, so it identifies content, not the
exact bytes.

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
  [`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md).

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
  instrument must carry no amendment log. Defaults to `FALSE`.

## Value

The file path, invisibly.

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

## See also

[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md),
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
