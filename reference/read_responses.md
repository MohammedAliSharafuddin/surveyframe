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
  timestamps. The metadata columns surveyframe's own collectors write,
  `respondent_id`, `response_id`, `started_at` and `submitted_at`, are
  recognised without being declared: a file this package collected reads
  back without naming the columns it wrote. Anything else outside the
  instrument still has to be declared, or `strict = FALSE` used.

- meta_cols:

  Character vector or NULL. Additional column names, outside the item
  IDs, to retain (for example, condition assignment or source URL).

- strict:

  Logical. When `TRUE` (default), a column outside the declared item
  IDs, their expansion columns and the metadata columns is an error,
  naming the columns. When `FALSE`, such columns are kept, placed last,
  with a warning.

## Value

A `data.frame` with columns ordered as: metadata columns first, then
item columns in instrument order, each item followed by its expansion
columns, then any undeclared columns kept under `strict = FALSE`. To
keep an extra column under `strict = TRUE`, name it in `meta_cols`, or
select the columns you need before reading.

## Columns

A single-answer item has one column named by its ID. A matrix, ranking,
multiple-choice or decision item has one column per row, option, pair or
criterion, named `item__sub`, and each is checked: a battery with some
of its columns absent is reported by name. Two columns with the same
name are refused, since one would otherwise be lost.

## Values

A CSV file is read as text, so identifiers such as `001`, dates and text
answers arrive exactly as written, a literal `NA` included. Columns of
items with numeric responses (numeric, slider and rating items, choice
items whose codes are all numbers, and ranking, multiple-choice and
decision expansion columns) are then converted to numbers, with an empty
cell or `NA` read as missing. A column that does not convert cleanly is
kept as text. Data frames go through the same conversion, so a CSV file
and a data frame holding the same responses read the same.

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
