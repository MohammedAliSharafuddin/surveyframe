# The `.sframe` format version, written into every file as `sframe_format`.

Tracks the shape of the serialised object, not the package version and
not the instrument's own version. Bump it only when the file's structure
changes in a way a consumer must react to. `sframe-schema` conformance
profiles are keyed to this value.

## Usage

``` r
SFRAME_FORMAT_VERSION
```
