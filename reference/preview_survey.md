# Preview a survey as a respondent sees it

Opens an instrument as a respondent would meet it, either as a
standalone page in the browser or on SurveyStudio's preview screen. The
preview has its collector removed, so trying it is safe: no answer is
sent anywhere.

## Usage

``` r
preview_survey(x, where = c("browser", "studio"), open = interactive())
```

## Arguments

- x:

  An `sframe` instrument, or a demo name from
  [`sframe_list_demos()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_list_demos.md).
  A demo is shown with the standard demo branding, as
  `sframe_demo(name, branded = TRUE)` applies it.

- where:

  One of `"browser"`, a standalone HTML page written by
  [`export_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_survey.md),
  or `"studio"`, the preview screen of
  [`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md).

- open:

  Logical. Whether to open the browser. Defaults to
  [`interactive()`](https://rdrr.io/r/base/interactive.html).

## Value

For `"browser"`, the path of the HTML page, invisibly. For `"studio"`,
what
[`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md)
returns.

## See also

[`export_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_survey.md)
for the page you send to respondents,
[`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md),
[`sframe_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo.md)

Other Preview functions:
[`run_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_survey.md)

## Examples

``` r
# A demo by name
path <- preview_survey("two_group", open = FALSE)
#> Static survey written to '/tmp/RtmpbhdiJG/surveyframe-preview-two_group.html' (79.4 KB).
file.exists(path)
#> [1] TRUE

# Your own instrument
ins <- sframe_demo("first_survey")$instrument
path <- preview_survey(ins, open = FALSE)
#> Static survey written to '/tmp/RtmpbhdiJG/surveyframe-preview-survey.html' (79.8 KB).
file.exists(path)
#> [1] TRUE
```
