# Write an instrument to a .sframe file

Serialises an `sframe` instrument object to a UTF-8 JSON file with a
SHA-256 integrity hash. The instrument is validated before writing
unless the object already carries a valid status. The hash is computed
over the full serialised content with the `hash.value` field set to an
empty string.

## Usage

``` r
write_sframe(instrument, path, pretty = TRUE, overwrite = FALSE)
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

## Value

The file path, invisibly.

## See also

[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)

## Examples

``` r
if (FALSE) { # \dontrun{
write_sframe(instr, "my_instrument.sframe")
} # }
```
