# Load bundled surveyframe demo data

Loads the bundled tourism-services `.sframe` instrument and simulated
response dataset used in package examples and statistical workflow
demos.

## Usage

``` r
sframe_demo_data()
```

## Value

A list with `instrument`, `responses`, `instrument_path`, and
`responses_path`.

## Examples

``` r
demo <- sframe_demo_data()
sf_meta(demo$instrument)$title
#> [1] "Tourism Services Experience Demo"
nrow(demo$responses)
#> [1] 120
```
