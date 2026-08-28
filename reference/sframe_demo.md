# Load one bundled demo

Load one bundled demo

## Usage

``` r
sframe_demo(name, branded = FALSE)
```

## Arguments

- name:

  Character. A demo name, as listed by
  [`sframe_demos()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demos.md).

- branded:

  Logical. When `TRUE`, the instrument comes back with the standard
  welcome page, logo, theme colour and thank you page spliced into its
  `render` block. The bundled file on disk is left unchanged, so the
  same branding can be shown on whichever demo matches your own survey.
  See
  [`sframe_demo_branding()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo_branding.md).

## Value

A list with `instrument`, `responses`, and the paths behind them:
`instrument_path`, `responses_path`, `codebook_path` and `results_path`.
The codebook carries variable and value labels, so the data means
something outside R. The results table is what surveyframe reports for
this demo, which is the reference to compare against when you run the
same data through another package.

## See also

[`sframe_demos()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demos.md),
[`sframe_export_labelled()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_export_labelled.md)

## Examples

``` r
demo <- sframe_demo("two_group")
demo$instrument
#> <sframe>
#>   Title:      In person or online?
#>   Version:    1.0.0
#>   Items:      2
#>   Scales:     0
#>   Analysis:   2 block(s)
#>   Status:     valid
head(demo$responses)
#>   respondent_id           started_at         submitted_at    format
#> 1          R001 2026-06-01T09:04:00Z 2026-06-01T09:08:00Z in_person
#> 2          R002 2026-06-01T09:04:37Z 2026-06-01T09:08:37Z in_person
#> 3          R003 2026-06-01T09:05:14Z 2026-06-01T09:09:14Z in_person
#> 4          R004 2026-06-01T09:05:51Z 2026-06-01T09:09:51Z in_person
#> 5          R005 2026-06-01T09:06:28Z 2026-06-01T09:10:28Z in_person
#> 6          R006 2026-06-01T09:07:05Z 2026-06-01T09:11:05Z in_person
#>   sessions_attended
#> 1                10
#> 2                 4
#> 3                 6
#> 4                 5
#> 5                12
#> 6                 6
```
