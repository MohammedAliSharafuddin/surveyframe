# Preview a demo survey in one line

Loads a bundled demo with the standard branding and opens it as a
respondent would see it, either as a standalone page in the browser or
on SurveyStudio's preview screen. The preview has its collector removed,
so trying it is safe.

## Usage

``` r
preview_demo(
  name = "two_group",
  where = c("browser", "studio"),
  open = interactive()
)
```

## Arguments

- name:

  Character. The demo to preview.
  [`sframe_demos()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demos.md)
  lists them. Defaults to `"two_group"`.

- where:

  One of `"browser"`, a standalone HTML page written by
  [`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md),
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

[`sframe_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo.md),
[`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md),
[`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md)

## Examples

``` r
path <- preview_demo("two_group", open = FALSE)
#> Static survey written to '/tmp/Rtmpn45ivP/surveyframe-preview-two_group.html' (72.7 KB).
file.exists(path)
#> [1] TRUE
```
