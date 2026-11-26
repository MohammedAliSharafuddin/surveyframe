# The .sframe format version

The version written into every file as `sframe_format`. It tracks the
shape of the serialised object. The package version and the instrument's
own version are separate. Bump it only when the file's structure changes
in a way a consumer must react to. `sframe-schema` conformance profiles
are keyed to this value.

## Usage

``` r
SFRAME_FORMAT_VERSION
```

## Value

A character scalar containing the current `.sframe` format version.
