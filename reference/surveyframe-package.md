# surveyframe: Survey Instrument Workflows for R

surveyframe defines a survey instrument as a first-class R object and
supports a complete workflow from questionnaire design through data
collection, quality checking, scoring, psychometric diagnostics, and
reproducible reporting. The package covers static HTML survey export, an
embeddable Shiny survey module, an interactive response dashboard, a
role-based analysis planner with pre-declared research questions, common
survey statistics with small-sample alternatives (Hodges-Lehmann,
pseudomedian, exact odds-ratio, and Firth logistic regression), multi-
criteria decision analysis (AHP, ANP, DEMATEL, VIKOR, MOORA, SMART,
WASPAS, PROMETHEE, ELECTRE, and TOPSIS), and model syntax planning for
EFA, CFA, CB-SEM, and PLS-SEM.

### Start here

[`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md)
opens SurveyStudio, which takes an instrument through every stage below
with no code. `launch_studio(demo = "first_survey")` opens it on a whole
survey to try. In code, `sframe_demo("first_survey")` loads the same
survey, and
[`sframe_list_demos()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_list_demos.md)
lists 22 teaching demos, each one instrument, its responses and the
results surveyframe produced.
[`vignette("learn-by-example")`](https://mohammedalisharafuddin.github.io/surveyframe/articles/learn-by-example.md)
teaches from the same library.

The stages follow, in order. Each names where it lives in SurveyStudio
or SurveyBuilder and the function that does it in code.

### Design

In SurveyBuilder,
[`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md),
the Build mode. In code,
[`sframe_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_instrument.md)
and its makers:
[`sframe_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item.md),
[`sframe_choice_set()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_choice_set.md),
[`sframe_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_scale.md),
[`sframe_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_branch.md)
and
[`sframe_attention_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_attention_check.md).
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
checks the instrument and
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
saves it as a `.sframe` file.
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
returns an `sframe_validation` diagnostic, and
[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md)
recovers the validated instrument.

### Plan

In SurveyBuilder, the Plan mode. In code, `sframe_plan(x) <- plan`, read
back with
[`sframe_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plan.md).
[`sframe_sample_size_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_sample_size_plan.md)
says how many responses the plan needs.

### Preview

In SurveyStudio, the Preview screen. In code,
[`preview_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/preview_survey.md),
which collects nothing, or
[`run_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_survey.md)
for a local Shiny survey.

### Collect

In SurveyBuilder, Export survey. In code,
[`export_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_survey.md)
writes a standalone page, optionally saving answers to a Google Sheet
through
[`export_google_sheet()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_google_sheet.md).
[`sframe_survey_ui()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_survey_ui.md)
and
[`sframe_survey_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_survey_server.md)
put the survey inside your own Shiny app.

### Responses

In SurveyStudio, the Responses and Quality screens. In code,
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
or
[`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md),
then
[`sframe_quality_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_quality_results.md).
[`export_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_responses.md)
writes them with labels for SPSS or Stata.

### Analyse

In SurveyStudio, the Explore, Reliability and Analyse screens. In code,
[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md)
and
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
which runs every block of the plan, decision-analysis blocks included.
The `_results` functions, such as
[`sframe_reliability_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reliability_results.md),
run one analysis on its own.

### Report

In SurveyStudio, the Report screen. In code,
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md),
[`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md)
and
[`sframe_codebook()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_codebook.md).

### References

In SurveyStudio, the References screen. In code,
[`sframe_reference()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reference.md)
and
[`sframe_add_references()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_add_references.md).
The report lists each work once, at the end.

### Amendments

In SurveyStudio, the Amendments screen. In code,
[`amend_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amend_sframe.md),
read back with
[`sframe_get_amendments()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_amendments.md).

### The instrument object

The workflow runs on an `sframe` object. It is the single source of
truth for item definitions, scale structure, reverse-coding keys,
branching rules, check specifications, analysis plans, and optional
model specifications. Accessors such as
[`sframe_meta()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_meta.md),
[`sframe_get_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_items.md),
[`sframe_get_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_scales.md),
[`sframe_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plan.md),
and
[`sframe_get_models()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_models.md)
read its parts without reaching into the object directly.

Some helpers work on plain vectors, for use beside that workflow or on
their own: the text helpers such as
[`sframe_term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_term_frequency.md),
and the interval helpers
[`sframe_bootstrap_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_bootstrap_ci.md),
[`sframe_cohens_d_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_cohens_d_ci.md),
[`sframe_cramers_v_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_cramers_v_ci.md)
and
[`sframe_eta_sq_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_eta_sq_ci.md).

### How functions are named

Names come in 2 kinds, so a function says which stage it belongs to.

- The stage verbs name the step a researcher is taking and carry no
  prefix:
  [`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md),
  [`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
  [`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md),
  [`amend_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amend_sframe.md),
  [`preview_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/preview_survey.md),
  [`run_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_survey.md),
  [`export_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_survey.md),
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md),
  [`export_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_responses.md),
  [`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md),
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
  [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md),
  [`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md)
  and
  [`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md).

- Everything else takes `sframe_`: the makers such as
  [`sframe_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item.md)
  and
  [`sframe_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_scale.md),
  the listers such as
  [`sframe_get_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_items.md),
  the accessors such as
  [`sframe_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plan.md),
  the `_results` functions such as
  [`sframe_reliability_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reliability_results.md),
  which return results and write no file, the `sframe_syntax_`
  generators, the plots and the demo library.

No 2 names sit 1 letter apart: a lister is
[`sframe_get_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_items.md),
never `sframe_items()`. The names used before 0.4.3 still work,
silently. See
[superseded](https://mohammedalisharafuddin.github.io/surveyframe/reference/superseded.md).

### File format

Instruments are stored as UTF-8 JSON files with the `.sframe` extension.
Each file includes a SHA-256 integrity hash for reproducibility
auditing.

## See also

Useful links:

- <https://mohammedalisharafuddin.github.io/surveyframe/>

- <https://github.com/MohammedAliSharafuddin/surveyframe>

- Report bugs at
  <https://github.com/MohammedAliSharafuddin/surveyframe/issues>

Other entry points:
[`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md)

## Author

**Maintainer**: Mohammed Ali Sharafuddin <mohammedali.page@gmail.com>
([ORCID](https://orcid.org/0000-0001-5247-2964))

Authors:

- Mohammed Ali Sharafuddin <mohammedali.page@gmail.com>
  ([ORCID](https://orcid.org/0000-0001-5247-2964))
