# Get survey metadata

Reads the title, version, description, language, validation state, and
other metadata without depending on the object's internal list layout.

## Usage

``` r
sf_meta(x, ...)
```

## Arguments

- x:

  A surveyframe object.

- ...:

  Passed to methods.

## Value

A list of instrument or codebook metadata.

## See also

[sf_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md)

## Examples

``` r
sf_meta(sframe_demo_data()$instrument)
#> $title
#> [1] "Tourism Services Experience Demo"
#> 
#> $version
#> [1] "0.3.0"
#> 
#> $description
#> [1] "Simulated demo questionnaire inspired by tourism-services research on digital marketing, service quality, sustainability, satisfaction, and behavioural intention."
#> 
#> $authors
#> [1] "Mohammed Ali Sharafuddin"
#> 
#> $languages
#> [1] "en"
#> 
#> $validated
#> [1] TRUE
#> 
#> $created_at
#> [1] "2026-05-13T18:16:19Z"
#> 
```
