# Read an instrument from a .sframe file

Reads a `.sframe` JSON file, or the same JSON held as text, and
reconstructs an `sframe` instrument object. The SHA-256 integrity hash
is verified by default, and content that does not match its hash is
refused. The hash covers a canonical form of the content, so it detects
a change to the content of a written file, and it ignores whitespace and
key order. It is unsigned, so anyone who edits a file can also recompute
it.

## Usage

``` r
read_sframe(path = NULL, validate = TRUE, text = NULL, verify = TRUE)
```

## Arguments

- path:

  Character. The path to a `.sframe` file. Leave it `NULL` and give
  `text` to read a payload held in memory.

- validate:

  Logical. Whether to validate the loaded instrument with
  [`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md).
  Defaults to `TRUE`. This controls structural validation only. `verify`
  controls the integrity hash.

- text:

  Character. The `.sframe` JSON itself, for example a payload a host
  keeps in a database, read with no temporary file. One string, or lines
  to be joined.

- verify:

  Logical. Whether to refuse content whose hash is missing or does not
  match. Defaults to `TRUE`. With `FALSE`, such content is read with a
  warning of class `sframe_unverified_warning` and the instrument is
  marked unverified (see the Unverified reads section).

## Value

An `sframe` object.

## Details

The instrument remembers the content and amendment log it was read with,
so
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
can refuse an undisclosed revision.

## Unverified reads

`verify = FALSE` is for a host holding a payload it cannot vouch for,
which it would otherwise rebuild by hand and lose fields doing so. The
result carries the attribute `sframe_verified`, `FALSE` (it is `TRUE` on
every verified read), and [`print()`](https://rdrr.io/r/base/print.html)
says so.
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
refuses to write an unverified instrument with no amendment log unless
`new_instrument = TRUE` declares it new, since nothing ties its content
to a state anyone wrote. One with a log must match the log's last entry,
as every instrument must.

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
