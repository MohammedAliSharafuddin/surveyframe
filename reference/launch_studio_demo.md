# Launch SurveyStudio with the bundled input-types demo

Opens SurveyStudio with the bundled input-types questionnaire and
simulated response data already loaded. The browser is opened
automatically by default.

## Usage

``` r
launch_studio_demo(
  screen = "preview",
  port = NULL,
  host = "127.0.0.1",
  launch.browser = TRUE
)
```

## Arguments

- screen:

  Initial studio screen. Defaults to `"preview"` so the demo content is
  immediately visible.

- port:

  TCP port for the Shiny server.

- host:

  Host address for the Shiny server.

- launch.browser:

  Whether to open the browser automatically. Defaults to `TRUE` for this
  demo helper.

## Value

Called for its side effect.
