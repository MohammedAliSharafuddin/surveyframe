# surveyframe: A Survey Instrument Workflow for R

surveyframe defines a survey instrument as a first-class R object and
provides a complete workflow from instrument design through data
collection, quality checking, scoring, psychometric diagnostics, and
reproducible reporting. Version 0.2 adds the browser-based
SurveyBuilder, launched with
[`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md),
while SurveyStudio, launched with
[`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md),
remains the Shiny workflow shell.

### Core workflow

1.  **Design** an instrument with
    [`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md)
    or
    [`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md)
    and its component constructors:
    [`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md),
    [`sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_choices.md),
    [`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md),
    [`sf_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_branch.md),
    [`sf_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_check.md).

2.  **Validate and save** with
    [`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
    and
    [`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md).

3.  **Deploy** a Shiny survey with
    [`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md).

4.  **Load responses** with
    [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
    or
    [`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md).

5.  **Check quality** with
    [`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md).

6.  **Score and analyse** with
    [`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md),
    [`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md),
    [`item_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/item_report.md),
    [`efa_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_report.md),
    [`cfa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_syntax.md),
    and
    [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md).

7.  **Report** with
    [`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md),
    [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md),
    and
    [`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md).

### The instrument object

Every function in the package operates on an `sframe` object. The object
is the single source of truth for item definitions, scale structure,
reverse-coding keys, branching rules, and check specifications.

### File format

Instruments are stored as UTF-8 JSON files with the `.sframe` extension.
Each file includes a SHA-256 integrity hash for reproducibility
auditing.

## See also

Useful links:

- <https://github.com/MohammedAliSharafuddin/surveyframe>

- <https://mohammedalisharafuddin.github.io/surveyframe>

- Report bugs at
  <https://github.com/MohammedAliSharafuddin/surveyframe/issues>

## Author

**Maintainer**: Mohammed Ali Sharafuddin <mas@flairmi.com>
