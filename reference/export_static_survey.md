# Export a self-contained static HTML survey

Generates a single HTML file that presents the survey instrument in a
browser, with no Shiny server and no internet connection. Every item
type, branching, required-item checks and multi-page navigation run in
the browser's own JavaScript.

## Usage

``` r
export_static_survey(
  instrument,
  output_path = NULL,
  open = interactive(),
  endpoint_url = NULL,
  overwrite = FALSE,
  preview = FALSE
)
```

## Arguments

- instrument:

  An `sframe` object.

- output_path:

  Character. File path for the output HTML. When `NULL`, a
  `<survey_title>.html` file is written in
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html).

- open:

  Logical. If `TRUE` (default) and the session is interactive, the file
  is opened in the default browser after writing.

- endpoint_url:

  Character or NULL. A URL to which responses are POSTed as JSON on
  submission. When NULL, CSV download is the only collection mechanism.

- overwrite:

  Logical. Whether to overwrite an existing file at `output_path`.
  Defaults to `FALSE`.

- preview:

  Logical. `TRUE` exports a survey that collects nothing: the collector
  endpoint and the completion redirect are both removed, and the
  thank-you screen says the response went nowhere. This is what
  SurveyStudio's preview uses, so a test answer cannot reach a live
  study's collector. Supplying `endpoint_url` alongside it is an error.
  Defaults to `FALSE`.

## Value

The output path, invisibly.

## Details

When `output_path` is `NULL`, the file is written to
[`tempdir()`](https://rdrr.io/r/base/tempfile.html). Supply an explicit
`output_path` for any production export that should be kept.

## How a response reaches you

On submission the survey builds a one-row CSV in the browser's memory
and shows the thank-you screen. When `endpoint_url` is supplied, it also
sends the response as a POST request to that URL, for example a Google
Apps Script web app. The browser reports nothing back from that request,
so the survey treats it as sent and the respondent sees the thank-you
screen either way.

The thank-you screen offers the CSV as a download button, which the
respondent chooses to use. It appears when the instrument's thank-you
settings ask for it, and whenever there is no `endpoint_url`, where that
file is the only copy of the response.

Plan for both parts. Test the endpoint with a pilot submission and
confirm the row arrives before collecting, and treat the download as a
route a respondent may decline.

The exported file works offline. It can be hosted on GitHub Pages,
Netlify, any static file server, or e-mailed as an attachment for
opening directly from disk.

## See also

[`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md),
[`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md),
[`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md)

## Examples

``` r
cs    <- sf_choices("ag5", 1:5,
           c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree"))
i1    <- sf_item("sat_1", "Overall I am satisfied with the service.",
                 type = "likert", choice_set = "ag5", required = TRUE)
i2    <- sf_item("comments", "Any additional comments?", type = "textarea")
instr <- sf_instrument("Customer Satisfaction Survey",
                       components = list(cs, i1, i2))

# Write to a temp file without opening the browser
out <- export_static_survey(instr,
                             output_path = file.path(tempdir(), "sat.html"),
                             open = FALSE)
#> Static survey written to '/tmp/RtmphUHlN5/sat.html' (68.6 KB).
file.exists(out)
#> [1] TRUE

# \donttest{
# Write to a temp file and open in the default browser
export_static_survey(instr,
                     output_path = file.path(tempdir(), "sat_browser.html"),
                     overwrite = TRUE)
#> Static survey written to '/tmp/RtmphUHlN5/sat_browser.html' (68.6 KB).

# Write with a Google Apps Script endpoint for server-side collection
export_static_survey(
  instr,
  output_path  = file.path(tempdir(), "sat_endpoint.html"),
  endpoint_url = "https://script.google.com/macros/s/XXXXX/exec",
  open         = FALSE,
  overwrite    = TRUE
)
#> Static survey written to '/tmp/RtmphUHlN5/sat_endpoint.html' (68.6 KB).
# }
```
