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
if (FALSE) { # \dontrun{
responses <- read_responses("data/responses.csv", instr,
                            respondent_id = "id")
qr <- quality_report(responses, instr, respondent_id = "id")
print(qr)
} # }
```
