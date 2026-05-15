# Launch SurveyBuilder with the bundled input-types demo

Opens the standalone browser builder and writes the bundled input-types
`.sframe` file to a temporary folder so users can load it through the
builder.

## Usage

``` r
launch_builder_demo(open = TRUE)
```

## Arguments

- open:

  Logical. Passed to
  [`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md).

## Value

Invisibly returns paths to the builder and demo `.sframe` file.
