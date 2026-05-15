# Launch SurveyBuilder with the bundled input-types demo preloaded

Opens a temporary copy of the SurveyBuilder with the bundled input-types
instrument already injected into the JavaScript state. The demo
questions, scales, and analysis plan are visible immediately — no manual
file-load step is required.

## Usage

``` r
launch_builder_demo(open = TRUE)
```

## Arguments

- open:

  Logical. When `TRUE` (the default), the pre-populated builder HTML is
  opened in the system's default web browser.

## Value

Invisibly returns a list with `builder_path`, `demo_file`, and
`responses_path`.
