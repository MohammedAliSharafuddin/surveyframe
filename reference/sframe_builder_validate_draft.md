# Validate a SurveyStudio draft state

Validate a SurveyStudio draft state

## Usage

``` r
sframe_builder_validate_draft(
  meta,
  choices = list(),
  items = list(),
  scales = list(),
  branching = list(),
  checks = list(),
  analysis_plan = list(),
  models = list()
)
```

## Arguments

- meta:

  List of instrument metadata.

- choices, items, scales, branching, checks:

  Lists of draft components.

- analysis_plan:

  List of draft analysis-plan blocks.

- models:

  List of draft model specifications.

## Value

A list with `valid`, `problems`, and `instrument`.
