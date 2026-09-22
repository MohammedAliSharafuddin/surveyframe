# Read an instrument from a .sframe file

Reads a `.sframe` JSON file and reconstructs an `sframe` instrument
object. The SHA-256 integrity hash is always verified, and a file whose
content does not match its hash is refused. The hash covers a canonical
form of the content, so it detects a change to the content of a written
file, and it ignores whitespace and key order. It is unsigned, so anyone
who edits a file can also recompute it.

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
  Defaults to `TRUE`. This controls structural validation only. The
  integrity hash is verified either way.

## Value

An `sframe` object.

## Details

The instrument remembers the content and amendment log it was read with,
so
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
can refuse an undisclosed revision.

## See also

[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)

## Examples

``` r
instr <- read_sframe(
  system.file("extdata", "tourism_services_demo.sframe",
              package = "surveyframe")
)
print(instr)
#> <sframe>
#>   Title:      Tourism Services Experience Demo
#>   Version:    0.3.0
#>   Items:      15
#>   Scales:     5
#>   Analysis:   34 block(s)
#>   Status:     valid
```
