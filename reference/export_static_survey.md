# Export a self-contained static HTML survey

Generates a single HTML file that presents the survey instrument in a
browser without requiring a Shiny server or any internet connection. All
thirteen item types, branching logic, required-field validation, and
multi-page navigation are handled entirely in client-side JavaScript.

## Usage

``` r
export_static_survey(
  instrument,
  output_path = NULL,
  open = interactive(),
  endpoint_url = NULL,
  overwrite = FALSE
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

## Value

The output path, invisibly.

## Details

When `output_path` is `NULL`, the file is written to
[`tempdir()`](https://rdrr.io/r/base/tempfile.html). Supply an explicit
`output_path` for any production export that should be kept.

When a respondent clicks the submit button, the browser downloads a
one-row CSV file named `<survey_title>_response_<id>.csv`. If
`endpoint_url` is supplied, the same payload is also sent as a JSON POST
request to that URL (for example a Google Apps Script web app or a
serverless function). The two mechanisms are independent: the download
happens regardless, so responses are never lost if the POST fails.

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
#> Static survey written to '/tmp/Rtmp490yWF/sat.html' (28 KB).
file.exists(out)
#> [1] TRUE

if (FALSE) { # \dontrun{
# Write and open in the default browser
export_static_survey(instr)

# Connect to a Google Apps Script endpoint for server-side collection
export_static_survey(
  instr,
  endpoint_url = "https://script.google.com/macros/s/XXXXX/exec"
)
} # }
```
