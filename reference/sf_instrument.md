# Create a survey instrument object

Assembles a survey instrument from its component objects. This is the
top-level constructor for the `sframe` class. All other constructors
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
  render = NULL,
  analysis_plan = list(),
  models = list()
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
  Components are sorted by class automatically. Supply components
  created by the surveyframe constructors.

- render:

  List or NULL. Optional rendering hints passed to
  [`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md),
  such as theme colour or progress bar visibility.

- analysis_plan:

  List. Optional pre-planned analysis blocks created in the HTML
  SurveyBuilder Analyse mode.

- models:

  List. Optional model specifications created with
  [`sf_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_model.md)
  or imported from a `.sframe` file.

## Value

An object of class `sframe` with slots `meta`, `items`, `choices`,
`scales`, `branching`, `checks`, `analysis_plan`, `models`, and
`render`.

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

visitor_cs <- sf_choices("visitor", c("new", "returning"),
                          c("New visitor", "Returning visitor"))

item1 <- sf_item("sat_1", "The service met my expectations.",
                 type = "likert", choice_set = "agree5",
                 scale_id = "sat", required = TRUE)
item2 <- sf_item("sat_2", "I would recommend this service.",
                 type = "likert", choice_set = "agree5",
                 scale_id = "sat", required = TRUE)
item3 <- sf_item("visitor_type", "I am a",
                 type = "single_choice", choice_set = "visitor")

scale <- sf_scale("sat", "Satisfaction", items = c("sat_1", "sat_2"))

# The analysis_plan binds each research question to a statistical method
# and the variable roles it needs. Declare it before any data arrive.
plan <- list(
  list(
    id               = "RQ1",
    research_question = "Do new and returning visitors differ in satisfaction?",
    family           = "group_comparison",
    method           = "mann_whitney",
    roles            = list(group = "visitor_type", outcome = "sat"),
    options          = list(alpha = 0.05)
  )
)

instr <- sf_instrument(
  title         = "Service Quality Survey",
  version       = "1.0.0",
  components    = list(choices, visitor_cs, item1, item2, item3, scale),
  analysis_plan = plan
)
print(instr)
#> <sframe>
#>   Title:      Service Quality Survey
#>   Version:    1.0.0
#>   Items:      3
#>   Scales:     1
#>   Status:     not validated
length(instr$analysis_plan)
#> [1] 1
```
