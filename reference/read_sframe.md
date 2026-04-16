# Read an instrument from a .sframe file

Reads a `.sframe` JSON file and reconstructs an `sframe` instrument
object. The SHA-256 integrity hash is verified on load unless
`validate = FALSE`.

## Usage

``` r
read_sframe(path, validate = TRUE)
```

## Arguments

- path:

  Character. The path to a `.sframe` file.

- validate:

  Logical. Whether to validate the loaded instrument with
  [`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md).
  Defaults to `TRUE`.

## Value

An `sframe` object.

## See also

[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)

## Examples

``` r
if (FALSE) { # \dontrun{
instr <- read_sframe("my_instrument.sframe")
} # }
```
