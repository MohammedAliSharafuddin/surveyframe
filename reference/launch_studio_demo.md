# Launch SurveyStudio with the bundled input-types demo

Opens SurveyStudio with the bundled input-types questionnaire and
simulated response data.

## Usage

``` r
launch_studio_demo(
  screen = "auto",
  port = NULL,
  host = "127.0.0.1",
  launch.browser = interactive()
)
```

## Arguments

- screen:

  Initial studio screen. Defaults to `"auto"`.

- port:

  TCP port for the Shiny server.

- host:

  Host address for the Shiny server.

- launch.browser:

  Whether to open the browser automatically.

## Value

Called for its side effect.
