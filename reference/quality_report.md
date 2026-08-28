# Generate a data quality report for survey responses

Evaluates collected response data against the instrument specification
and produces a structured quality report. The report covers attention
check performance, completion time, straight-lining within scale blocks,
item-level missingness, respondent-level missingness, and duplicate
respondent IDs where supplied.

## Usage

``` r
quality_report(
  data,
  instrument,
  respondent_id = NULL,
  submitted_at = NULL,
  started_at = NULL,
  time_min = NULL,
  straightline_scales = TRUE,
  straightline_min_items = 4L,
  missing_threshold = 0.2
)
```

## Arguments

- data:

  A `tibble` or `data.frame` of responses, typically produced by
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md).

- instrument:

  An `sframe` object created by
  [`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md).

- respondent_id:

  Character or NULL. The column name holding unique respondent
  identifiers. Used for duplicate detection.

- submitted_at:

  Character or NULL. The column name holding submission timestamps. Used
  for completion time analysis.

- started_at:

  Character or NULL. The column name holding survey start timestamps.
  When `NULL`, `quality_report()` looks for a recognised start-time
  column automatically.

- time_min:

  Numeric or NULL. Minimum acceptable completion time in seconds.
  Respondents with a submission time below this threshold are flagged as
  speeders when timing data are available.

- straightline_scales:

  Logical. Whether to check for straight-lining within each defined
  scale block. Defaults to `TRUE`.

- straightline_min_items:

  Integer. The minimum number of items a scale must have before it is
  checked for straight-lining. Defaults to `4`. A respondent who gives
  the identical response to every item in a 2-item scale has done
  exactly what a genuinely consistent respondent does, this is not
  evidence of inattention on its own, and checking scales that short
  flags a large share of honest respondents (see the worked example in
  [`vignette("surveyframe")`](https://mohammedalisharafuddin.github.io/surveyframe/articles/surveyframe.md),
  where 3 two-item scales alone drove a 91 percent flag rate before this
  threshold existed). Set to `2` to restore the previous, more
  permissive behaviour.

- missing_threshold:

  Numeric. The proportion of missing item responses above which a
  respondent is flagged. Defaults to `0.2`.

## Value

An object of class `sframe_quality_report`, a named list with elements:
`summary`, `attention`, `timing`, `straightline`, `missing`, and
`duplicates`. Use [`print()`](https://rdrr.io/r/base/print.html) for a
formatted summary.

## Details

Timing analysis is available when the data contain a submission
timestamp column and either an explicit `started_at` column or one of
the recognised defaults: `started_at`, `start_time`, `started`, or
`.started_at`.

## See also

[`sf_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_check.md),
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md),
[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md)

## Examples

``` r
instr <- read_sframe(
  system.file("extdata", "tourism_services_demo.sframe",
              package = "surveyframe")
)
responses <- read_responses(
  system.file("extdata", "tourism_services_responses.csv",
              package = "surveyframe"),
  instr,
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  meta_cols = "started_at"
)
qr <- quality_report(
  responses,
  instr,
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  started_at = "started_at",
  straightline_scales = FALSE
)
print(qr)
#> Survey Data Quality Report
#>   Respondents:  120
#>   Items:        15
#>   Flagged:      6 (5.0%)
#> 
#> Attention checks:
#>   attention_agree      pass 95%  fail 6
#> 
#> Timing:
#>   Median completion time: 966.0 seconds
#> 
#> Missingness:  0.0% of respondents exceed 20% threshold
```
