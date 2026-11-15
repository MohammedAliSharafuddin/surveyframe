# Create a survey instrument object

Assembles a survey instrument from its component objects. This is the
top-level constructor for the `sframe` class. All other constructors
([`sframe_item()`](https://surveyframe.org/reference/sframe_item.md),
[`sframe_choice_set()`](https://surveyframe.org/reference/sframe_choice_set.md),
[`sframe_scale()`](https://surveyframe.org/reference/sframe_scale.md),
[`sframe_branch()`](https://surveyframe.org/reference/sframe_branch.md),
[`sframe_attention_check()`](https://surveyframe.org/reference/sframe_attention_check.md))
produce components that are passed into this function via `components`.

## Usage

``` r
sframe_instrument(
  title,
  version = "0.1.0",
  description = NULL,
  authors = NULL,
  languages = "en",
  components = list(),
  render = NULL,
  analysis_plan = list(),
  models = list(),
  study = NULL
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
  [`sframe_item()`](https://surveyframe.org/reference/sframe_item.md),
  [`sframe_choice_set()`](https://surveyframe.org/reference/sframe_choice_set.md),
  [`sframe_scale()`](https://surveyframe.org/reference/sframe_scale.md),
  [`sframe_branch()`](https://surveyframe.org/reference/sframe_branch.md),
  [`sframe_attention_check()`](https://surveyframe.org/reference/sframe_attention_check.md),
  [`sframe_conjoint_design()`](https://surveyframe.org/reference/sframe_conjoint_design.md),
  and
  [`sframe_reference()`](https://surveyframe.org/reference/sframe_reference.md).
  Components are sorted by class automatically, so they can be supplied
  in any order.

- render:

  List or NULL. Optional rendering hints passed to
  [`run_survey()`](https://surveyframe.org/reference/run_survey.md),
  such as theme colour or progress bar visibility.

- analysis_plan:

  List. Optional pre-planned analysis blocks created in the HTML
  SurveyBuilder Plan mode.

- models:

  List. Optional model specifications created with
  [`sframe_model_spec()`](https://surveyframe.org/reference/sframe_model_spec.md)
  or imported from a `.sframe` file.

- study:

  List or `NULL`. The study the instrument serves: `problem` (1 short
  paragraph), `objectives` (a list, each with an `id` such as `"O1"` and
  its `text`) and `sampling` (`population`, `method` from
  [`sframe_sampling_methods()`](https://surveyframe.org/reference/sframe_sampling_methods.md)
  and `planned_n`) and `preregistration` (`exclusion_rules`,
  `stopping_rule`, `primary_outcomes`, `secondary_outcomes`,
  `multiplicity` and `contingency`, each optional text). Never shown to
  respondents. See
  [`sframe_get_study()`](https://surveyframe.org/reference/sframe_get_study.md).

## Value

An object of class `sframe` with slots `meta`, `items`, `choices`,
`scales`, `branching`, `checks`, `analysis_plan`, `models`, and
`render`.

## See also

[`sframe_item()`](https://surveyframe.org/reference/sframe_item.md),
[`sframe_choice_set()`](https://surveyframe.org/reference/sframe_choice_set.md),
[`sframe_scale()`](https://surveyframe.org/reference/sframe_scale.md),
[`sframe_branch()`](https://surveyframe.org/reference/sframe_branch.md),
[`sframe_attention_check()`](https://surveyframe.org/reference/sframe_attention_check.md),
[`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md),
[`write_sframe()`](https://surveyframe.org/reference/write_sframe.md)

Other Design functions:
[`as_sframe()`](https://surveyframe.org/reference/as_sframe.md),
[`launch_builder()`](https://surveyframe.org/reference/launch_builder.md),
[`read_sframe()`](https://surveyframe.org/reference/read_sframe.md),
[`sframe_attention_check()`](https://surveyframe.org/reference/sframe_attention_check.md),
[`sframe_branch()`](https://surveyframe.org/reference/sframe_branch.md),
[`sframe_choice_set()`](https://surveyframe.org/reference/sframe_choice_set.md),
[`sframe_conjoint_design()`](https://surveyframe.org/reference/sframe_conjoint_design.md),
[`sframe_get_study()`](https://surveyframe.org/reference/sframe_get_study.md),
[`sframe_item()`](https://surveyframe.org/reference/sframe_item.md),
[`sframe_sampling_methods()`](https://surveyframe.org/reference/sframe_sampling_methods.md),
[`sframe_scale()`](https://surveyframe.org/reference/sframe_scale.md),
[`sframe_validation`](https://surveyframe.org/reference/sframe_validation.md),
[`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md),
[`write_sframe()`](https://surveyframe.org/reference/write_sframe.md)

## Examples

``` r
choices <- sframe_choice_set("agree5", 1:5,
  c("Strongly disagree", "Disagree", "Neutral", "Agree", "Strongly agree"))

visitor_cs <- sframe_choice_set("visitor", c("new", "returning"),
                          c("New visitor", "Returning visitor"))

item1 <- sframe_item("sat_1", "The service met my expectations.",
                 type = "likert", choice_set = "agree5",
                 scale_id = "sat", required = TRUE)
item2 <- sframe_item("sat_2", "I would recommend this service.",
                 type = "likert", choice_set = "agree5",
                 scale_id = "sat", required = TRUE)
item3 <- sframe_item("visitor_type", "I am a",
                 type = "single_choice", choice_set = "visitor")

scale <- sframe_scale("sat", "Satisfaction", items = c("sat_1", "sat_2"))

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

instr <- sframe_instrument(
  title         = "Service Quality Survey",
  version       = "1.0.0",
  components    = list(choices, visitor_cs, item1, item2, item3, scale),
  analysis_plan = plan
)
print(instr)
length(sframe_plan(instr))
```
