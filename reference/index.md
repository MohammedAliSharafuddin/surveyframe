# Package index

## Design

Start visually in the HTML SurveyBuilder or construct instruments in R.

- [`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md)
  : Launch the surveyframe visual survey builder
- [`launch_builder_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder_demo.md)
  : Launch SurveyBuilder with the bundled input-types demo preloaded
- [`launch_studio_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio_demo.md)
  : Launch SurveyStudio with the bundled input-types demo
- [`launch_dashboard_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard_demo.md)
  : Launch the response dashboard with the bundled input-types demo

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
- [`sf_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_model.md)
  : Create a surveyframe model specification
- [`sf_construct()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_construct.md)
  : Define a latent or composite construct
- [`sf_path()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_path.md)
  : Define a structural path between constructs
- [`sf_covariance()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_covariance.md)
  : Define a covariance between constructs
- [`sf_indirect()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_indirect.md)
  : Define an indirect effect path
- [`add_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/add_model.md)
  : Add a model specification to an instrument

## Save and load

Read and write instruments as portable .sframe JSON files with SHA-256
integrity hashing.

- [`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
  : Write an instrument to a .sframe file
- [`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)
  : Read an instrument from a .sframe file
- [`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
  : Validate an instrument object
- [`validate_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_model.md)
  : Validate a surveyframe model specification
- [`model_json()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/model_json.md)
  : Serialise a model specification to JSON

## Deploy

Render the instrument as a Shiny survey or launch SurveyStudio.

- [`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md)
  : Render a survey from an instrument object
- [`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md)
  : Export a self-contained static HTML survey
- [`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md)
  : Launch the SurveyStudio interface
- [`launch_dashboard()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard.md)
  : Launch the interactive response dashboard
- [`survey_module_ui()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_ui.md)
  : Shiny module UI for an embedded survey
- [`survey_module_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_server.md)
  : Shiny module server for an embedded survey

## Collect responses

Load and validate response data against the instrument specification.

- [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
  : Read and validate survey responses
- [`export_google_sheet()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_google_sheet.md)
  : Export a survey instrument to Google Sheets collection format
- [`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md)
  : Read survey responses from a Google Sheet

## Quality checks

Evaluate response data for attention check failures, straight-lining,
missingness, and duplicate submissions.

- [`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md)
  : Generate a data quality report for survey responses
- [`missing_data_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/missing_data_report.md)
  : Missing-data report
- [`outlier_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/outlier_report.md)
  : Flag univariate and multivariate outliers
- [`assumption_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/assumption_report.md)
  : Assumption-check report

## Score and analyse

Score composite scales, compute reliability statistics, and prepare
psychometric diagnostics and pre-planned analyses.

- [`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md)
  : Score defined scales from survey responses
- [`descriptives_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/descriptives_report.md)
  : Descriptive statistics report
- [`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md)
  : Compute reliability statistics for scored scales
- [`item_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/item_report.md)
  : Generate item-level diagnostics
- [`efa_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_report.md)
  : Prepare a survey instrument for exploratory factor analysis
- [`efa_solution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_solution.md)
  : Estimate an exploratory factor solution
- [`validity_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validity_report.md)
  : Validity report for construct models
- [`cfa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_syntax.md)
  : Generate lavaan CFA syntax from an instrument object
- [`cfa_lavaan_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_lavaan_syntax.md)
  : Generate lavaan CFA syntax
- [`efa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_syntax.md)
  : Generate EFA planning syntax
- [`sem_lavaan_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sem_lavaan_syntax.md)
  : Generate lavaan CB-SEM syntax
- [`seminr_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/seminr_syntax.md)
  : Generate seminr PLS-SEM syntax
- [`posthoc_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/posthoc_report.md)
  : Post-hoc and pairwise comparison report
- [`sample_size_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sample_size_plan.md)
  : Sample-size and power planning helper
- [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
  : Run a pre-planned analysis from an instrument's analysis plan

## Report

Generate codebooks, scale appendices, and reproducible HTML reports.

- [`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md)
  : Generate a survey codebook from an instrument object
- [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
  : Render a reproducible survey report
- [`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md)
  : Render analysis results to a formatted HTML report
- [`model_report_template()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/model_report_template.md)
  : Create a model reporting template

## Package

- [`surveyframe`](https://mohammedalisharafuddin.github.io/surveyframe/reference/surveyframe-package.md)
  [`surveyframe-package`](https://mohammedalisharafuddin.github.io/surveyframe/reference/surveyframe-package.md)
  : surveyframe: Survey Instrument Workflows for R
- [`sframe_demo_data()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo_data.md)
  : Load bundled surveyframe demo data
- [`sframe_input_types_demo_data()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_input_types_demo_data.md)
  : Load bundled input-types demo data
- [`sframe_builder_empty_state()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_builder_empty_state.md)
  : Create an empty SurveyStudio builder state
- [`sframe_builder_state_from_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_builder_state_from_instrument.md)
  : Convert an instrument into a SurveyStudio builder state
- [`sframe_builder_validate_draft()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_builder_validate_draft.md)
  : Validate a SurveyStudio draft state
- [`print(`*`<sframe>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sframe.md)
  : Print an sframe instrument object
- [`format(`*`<sframe>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/format.sframe.md)
  : Format an sframe instrument object as a string
- [`summary(`*`<sframe>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sframe.md)
  : Summarise an sframe instrument object
