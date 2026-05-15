# Read and validate survey responses

Loads survey response data and checks that it conforms to the instrument
specification. Column names in the response file must match item IDs
defined in the instrument. Non-item columns are allowed only when
declared through `respondent_id`, `submitted_at`, or `meta_cols`.

## Usage

``` r
read_responses(
  x,
  instrument,
  respondent_id = NULL,
  submitted_at = NULL,
  meta_cols = NULL,
  strict = TRUE
)
```

## Arguments

- x:

  A file path to a CSV file, a `data.frame`, or a `tibble`.

- instrument:

  An `sframe` object created by
  [`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md).

- respondent_id:

  Character or NULL. The name of the column containing unique respondent
  identifiers. If NULL, no respondent ID column is expected.

- submitted_at:

  Character or NULL. The name of the column containing submission
  timestamps.

- meta_cols:

  Character vector or NULL. Additional column names that are not item
  IDs but should be retained (for example, condition assignment or
  source URL).

- strict:

  Logical. When `TRUE` (default), columns in the response data outside
  the declared item IDs and metadata columns raise an error. When
  `FALSE`, undeclared columns are retained with a warning.

## Value

A `data.frame` with columns ordered as: metadata columns first, then
item columns in instrument order. Unrecognised columns are dropped when
`strict = TRUE` or appended with a warning when `strict = FALSE`.

## See also

[`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md),
[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md)

## Examples

``` r
responses <- read_responses(
  x = system.file("extdata", "tourism_services_responses.csv",
                  package = "surveyframe"),
  instrument = read_sframe(
    system.file("extdata", "tourism_services_demo.sframe",
                package = "surveyframe")
  ),
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  meta_cols = "started_at"
)
head(responses[, c("respondent_id", "visit_type", "dm_1")])
#>   respondent_id visit_type dm_1
#> 1          R001 first_time    2
#> 2          R002 first_time    3
#> 3          R003 first_time    4
#> 4          R004     repeat    5
#> 5          R005 first_time    3
#> 6          R006     repeat    5
```
