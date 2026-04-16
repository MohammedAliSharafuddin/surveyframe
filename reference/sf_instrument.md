# Create a survey instrument object

Assembles a complete survey instrument from its component objects. This
is the top-level constructor for the `sframe` class. All other
constructors
([`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md),
[`sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_choices.md),
[`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md),
[`sf_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_branch.md),
[`sf_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_check.md))
produce components that are passed into this function via `components`.

## Usage

``` r
sf_instrument(
  title,
  version = "0.1.0",
  description = NULL,
  authors = NULL,
  languages = "en",
  components = list(),
  render = NULL
)
```

## Arguments

- title:

  Character. The title of the survey instrument.

- version:

  Character. A semantic version string. Defaults to `"0.1.0"`.

- description:

  Character or NULL. A brief description of the instrument and its
  intended population or purpose.

- authors:

  Character vector or NULL. Author names, used in codebooks and reports.

- languages:

  Character vector. Language codes for the instrument. Defaults to
  `"en"`. Multi-language support is planned for a later release.

- components:

  List. A list of component objects created by the constructor family:
  [`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md),
  [`sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_choices.md),
  [`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md),
  [`sf_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_branch.md),
  and
  [`sf_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_check.md).
  Components are sorted by class automatically. Raw lists are not
  accepted.

- render:

  List or NULL. Optional rendering hints passed to
  [`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md),
  such as theme colour or progress bar visibility.

## Value

An object of class `sframe` with slots `meta`, `items`, `choices`,
`scales`, `branching`, `checks`, and `render`.

## See also

[`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md),
[`sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_choices.md),
[`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md),
[`sf_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_branch.md),
[`sf_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_check.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)

## Examples

``` r
choices <- sf_choices("agree5", 1:5,
  c("Strongly disagree", "Disagree", "Neutral", "Agree", "Strongly agree"))

item1 <- sf_item("sat_1", "The service met my expectations.",
                 type = "likert", choice_set = "agree5",
                 scale_id = "sat", required = TRUE)
item2 <- sf_item("sat_2", "I would recommend this service.",
                 type = "likert", choice_set = "agree5",
                 scale_id = "sat", required = TRUE)

scale <- sf_scale("sat", "Satisfaction", items = c("sat_1", "sat_2"))

instr <- sf_instrument(
  title      = "Service Quality Survey",
  version    = "1.0.0",
  components = list(choices, item1, item2, scale)
)
print(instr)
#> <sframe>
#>   Title:      Service Quality Survey
#>   Version:    1.0.0
#>   Items:      2
#>   Scales:     1
#>   Status:     not validated
```
