# Package index

## Build an instrument

Constructor functions for building the sframe instrument object. Start
here.

- [`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md)
  : Create a survey instrument object
- [`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md)
  : Define a survey item
- [`sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_choices.md)
  : Define a reusable choice set
- [`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md)
  : Define a scored scale
- [`sf_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_branch.md)
  : Define a branching rule
- [`sf_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_check.md)
  : Define a design-time survey check

## Save and load

Read and write instruments as portable .sframe JSON files with SHA-256
integrity hashing.

- [`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
  : Write an instrument to a .sframe file
- [`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)
  : Read an instrument from a .sframe file
- [`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
  : Validate an instrument object

## Deploy

Render the instrument as a Shiny survey or launch SurveyStudio.

- [`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md)
  : Render a survey from an instrument object
- [`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md)
  : Launch the SurveyStudio interface

## Collect responses

Load and validate response data against the instrument specification.

- [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
  : Read and validate survey responses

## Quality checks

Evaluate response data for attention check failures, straight-lining,
missingness, and duplicate submissions.

- [`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md)
  : Generate a data quality report for survey responses

## Score and analyse

Score composite scales, compute reliability statistics, and prepare
psychometric diagnostics.

- [`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md)
  : Score defined scales from survey responses
- [`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md)
  : Compute reliability statistics for scored scales
- [`item_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/item_report.md)
  : Generate item-level diagnostics
- [`efa_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_report.md)
  : Prepare a survey instrument for exploratory factor analysis
- [`cfa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_syntax.md)
  : Generate lavaan CFA syntax from an instrument object

## Report

Generate codebooks, scale appendices, and reproducible HTML reports.

- [`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md)
  : Generate a survey codebook from an instrument object
- [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
  : Render a reproducible survey report

## Package

- [`surveyframe`](https://mohammedalisharafuddin.github.io/surveyframe/reference/surveyframe-package.md)
  [`surveyframe-package`](https://mohammedalisharafuddin.github.io/surveyframe/reference/surveyframe-package.md)
  : surveyframe: A Survey Instrument Workflow for R
- [`print(`*`<sframe>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sframe.md)
  : Print an sframe instrument object
- [`format(`*`<sframe>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/format.sframe.md)
  : Format an sframe instrument object as a string
- [`summary(`*`<sframe>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sframe.md)
  : Summarise an sframe instrument object
