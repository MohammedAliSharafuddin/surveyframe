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
  models = list(),
  render = list(),
  amendments = list(),
  designs = list(),
  origin = NULL
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

- render:

  List of rendering settings (welcome, header/logo, thankyou, theme)
  carried from the loaded instrument so previews and exports match.

- amendments:

  List of previously disclosed amendment entries, carried through
  unchanged so a draft round trip does not drop them.

- designs:

  List of conjoint designs, carried through unchanged, since Studio has
  no editor for them.

- origin:

  The load record of an instrument read with
  [`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md),
  from the builder state, or `NULL`. Carried onto the draft so an edit
  of a loaded file is recognised as a revision.

## Value

A list with `valid`, `problems`, `instrument`, and `revision_problem`:
the reason
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
would refuse the draft as an undisclosed revision, or `NULL`.

## Examples

``` r
demo  <- sframe_demo_data()
state <- sframe_builder_state_from_instrument(demo$instrument)
draft <- sframe_builder_validate_draft(
  meta = state$meta, choices = state$choices, items = state$items,
  scales = state$scales, branching = state$branching, checks = state$checks
)
draft$valid
#> [1] TRUE
```
