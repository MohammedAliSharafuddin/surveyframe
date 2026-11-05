# Superseded function names

In 0.4.3 every exported function took the `sframe_` prefix or a stage
verb, so a name says which stage it belongs to and no 2 names sit 1
letter apart. The old names still work and give the same result, with no
warning. Set `options(surveyframe.warn_superseded = TRUE)` to get 1
warning per old name per session, naming its replacement.

## Usage

``` r
sf_instrument(...)

sf_item(...)

sf_choices(...)

sf_scale(...)

sf_branch(...)

sf_check(...)

sf_conjoint_design(...)

sf_construct(...)

sf_path(...)

sf_covariance(...)

sf_indirect(...)

sf_model(...)

add_model(...)

validate_model(...)

model_json(...)

model_report_template(...)

sf_items(...)

sf_scales(...)

sf_checks(...)

sf_models(...)

sf_branches(...)

sf_choice_sets(...)

sf_meta(...)

sf_plan(...)

sf_id(...)

sf_label(...)

sf_apa(...)

sf_flagged(...)

sf_problems(...)

sf_is_valid(...)

sf_object(...)

sf_missing_columns(...)

sample_size_plan(...)

sf_reference(...)

add_references(...)

sframe_references(...)

link_git_commit(...)

amendment_log(...)

render_survey(...)

export_static_survey(...)

survey_module_ui(...)

survey_module_server(...)

sframe_export_labelled(...)

quality_report(...)

missing_data_report(...)

outlier_report(...)

reliability_report(...)

item_report(...)

efa_report(...)

efa_solution(...)

validity_report(...)

descriptives_report(...)

assumption_report(...)

posthoc_report(...)

bootstrap_ci(...)

cohens_d_ci(...)

cramers_v_ci(...)

eta_sq_ci(...)

cfa_lavaan_syntax(...)

cfa_syntax(instrument, scales = NULL, std_lv = TRUE)

sem_lavaan_syntax(...)

seminr_syntax(...)

efa_syntax(...)

analysis_syntax(...)

clean_text_responses(...)

term_frequency(...)

ngram_frequency(...)

term_context(...)

extract_quotes(...)

sensitivity_analysis(...)

render_result(...)

codebook_report(...)

sframe_demos(...)

sframe_demo_data()

sframe_input_types_demo_data()

launch_builder_demo(open = TRUE)

launch_studio_demo(
  screen = "preview",
  port = NULL,
  host = "127.0.0.1",
  launch.browser = TRUE
)

preview_demo(
  name = "two_group",
  where = c("browser", "studio"),
  open = interactive()
)

sf_plan(x) <- value

launch_dashboard(
  instrument = NULL,
  responses = NULL,
  port = NULL,
  host = "127.0.0.1",
  launch.browser = interactive()
)

launch_dashboard_demo(port = NULL, host = "127.0.0.1", launch.browser = TRUE)
```

## Arguments

- ...:

  Passed to the new function.

- instrument, scales, std_lv:

  Passed to
  [`sframe_syntax_cfa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_cfa.md).
  `instrument` is also passed to
  [`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md)
  by `launch_dashboard()`.

- open:

  Passed to
  [`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md)
  or
  [`preview_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/preview_survey.md).

- screen, port, host, launch.browser:

  Passed to
  [`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md).

- name, where:

  Passed to
  [`preview_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/preview_survey.md),
  as its `x` and `where`.

- x:

  An instrument.

- value:

  The analysis plan, as for
  [`sframe_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plan.md).

- responses:

  A data frame of responses, passed to
  [`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md).

## Value

What the new function returns.

## Details

|  |  |
|----|----|
| Old name | New name |
| `sf_instrument()` | [`sframe_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_instrument.md) |
| `sf_item()` | [`sframe_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item.md) |
| `sf_choices()` | [`sframe_choice_set()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_choice_set.md) |
| `sf_scale()` | [`sframe_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_scale.md) |
| `sf_branch()` | [`sframe_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_branch.md) |
| `sf_check()` | [`sframe_attention_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_attention_check.md) |
| `sf_conjoint_design()` | [`sframe_conjoint_design()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_conjoint_design.md) |
| `sf_construct()` | [`sframe_construct()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_construct.md) |
| `sf_path()` | [`sframe_path()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_path.md) |
| `sf_covariance()` | [`sframe_covariance()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_covariance.md) |
| `sf_indirect()` | [`sframe_indirect_effect()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_indirect_effect.md) |
| `sf_model()` | [`sframe_model_spec()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_model_spec.md) |
| `add_model()` | [`sframe_add_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_add_model.md) |
| `validate_model()` | [`sframe_validate_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validate_model.md) |
| `model_json()` | [`sframe_model_json()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_model_json.md) |
| `model_report_template()` | [`sframe_model_outline()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_model_outline.md) |
| `sf_items()` | [`sframe_get_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_items.md) |
| `sf_scales()` | [`sframe_get_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_scales.md) |
| `sf_checks()` | [`sframe_get_attention_checks()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_attention_checks.md) |
| `sf_models()` | [`sframe_get_models()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_models.md) |
| `sf_branches()` | [`sframe_get_branches()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_branches.md) |
| `sf_choice_sets()` | [`sframe_get_choice_sets()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_choice_sets.md) |
| `sf_meta()` | [`sframe_meta()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_meta.md) |
| `sf_plan()` | [`sframe_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plan.md) |
| `sf_id()` | [`sframe_id()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_id.md) |
| `sf_label()` | [`sframe_label()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_label.md) |
| `sf_apa()` | [`sframe_apa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_apa.md) |
| `sf_flagged()` | [`sframe_flagged()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_flagged.md) |
| `sf_problems()` | [`sframe_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_problems.md) |
| `sf_is_valid()` | [`sframe_is_valid()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_is_valid.md) |
| `sf_object()` | [`sframe_object()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_object.md) |
| `sf_missing_columns()` | [`sframe_missing_columns()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_missing_columns.md) |
| `sample_size_plan()` | [`sframe_sample_size_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_sample_size_plan.md) |
| `sf_reference()` | [`sframe_reference()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reference.md) |
| `add_references()` | [`sframe_add_references()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_add_references.md) |
| `sframe_references()` | [`sframe_get_references()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_references.md) |
| `link_git_commit()` | [`sframe_link_git_commit()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_link_git_commit.md) |
| `amendment_log()` | [`sframe_get_amendments()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_amendments.md) |
| `render_survey()` | [`run_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_survey.md) |
| `export_static_survey()` | [`export_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_survey.md) |
| `survey_module_ui()` | [`sframe_survey_ui()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_survey_ui.md) |
| `survey_module_server()` | [`sframe_survey_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_survey_server.md) |
| `sframe_export_labelled()` | [`export_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_responses.md) |
| `quality_report()` | [`sframe_quality_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_quality_results.md) |
| `missing_data_report()` | [`sframe_missing_data_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_missing_data_results.md) |
| `outlier_report()` | [`sframe_outlier_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_outlier_results.md) |
| `reliability_report()` | [`sframe_reliability_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reliability_results.md) |
| `item_report()` | [`sframe_item_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item_results.md) |
| `efa_report()` | [`sframe_efa_readiness_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_efa_readiness_results.md) |
| `efa_solution()` | [`sframe_efa_solution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_efa_solution.md) |
| `validity_report()` | [`sframe_validity_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validity_results.md) |
| `descriptives_report()` | [`sframe_descriptives_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_descriptives_results.md) |
| `assumption_report()` | [`sframe_assumption_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_assumption_results.md) |
| `posthoc_report()` | [`sframe_posthoc_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_posthoc_results.md) |
| `bootstrap_ci()` | [`sframe_bootstrap_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_bootstrap_ci.md) |
| `cohens_d_ci()` | [`sframe_cohens_d_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_cohens_d_ci.md) |
| `cramers_v_ci()` | [`sframe_cramers_v_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_cramers_v_ci.md) |
| `eta_sq_ci()` | [`sframe_eta_sq_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_eta_sq_ci.md) |
| `cfa_lavaan_syntax()` | [`sframe_syntax_cfa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_cfa.md) |
| `cfa_syntax()` | [`sframe_syntax_cfa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_cfa.md) |
| `sem_lavaan_syntax()` | [`sframe_syntax_sem()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_sem.md) |
| `seminr_syntax()` | [`sframe_syntax_pls()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_pls.md) |
| `efa_syntax()` | [`sframe_syntax_efa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_efa.md) |
| `analysis_syntax()` | [`sframe_syntax_result()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_result.md) |
| `clean_text_responses()` | [`sframe_clean_text()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_clean_text.md) |
| `term_frequency()` | [`sframe_term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_term_frequency.md) |
| `ngram_frequency()` | [`sframe_ngram_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_ngram_frequency.md) |
| `term_context()` | [`sframe_term_context()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_term_context.md) |
| `extract_quotes()` | [`sframe_extract_quotes()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_extract_quotes.md) |
| `sensitivity_analysis()` | [`sframe_sensitivity_analysis()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_sensitivity_analysis.md) |
| `render_result()` | [`sframe_format_result()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_format_result.md) |
| `codebook_report()` | [`sframe_codebook()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_codebook.md) |
| `sframe_demos()` | [`sframe_list_demos()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_list_demos.md) |
| `sframe_demo_data()` | [`sframe_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo.md) with `"tourism_services"` |
| `sframe_input_types_demo_data()` | [`sframe_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo.md) with `"input_types"` |
| `launch_builder_demo()` | [`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md) with `demo = "input_types"` |
| `launch_studio_demo()` | [`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md) with `demo = "input_types"` |
| `preview_demo()` | [`preview_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/preview_survey.md) |
| `launch_dashboard()` | [`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md) with `screen = "dashboard"` |
| `launch_dashboard_demo()` | [`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md) with `demo = "input_types"` and `screen = "dashboard"` |
| `sf_plan(x) <- value` | [sframe_plan\<-](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plan.md) |

## Examples

``` r
# The old name and the new one make the same item
identical(sf_item("q1", "Question 1", type = "text"),
          sframe_item("q1", "Question 1", type = "text"))
#> [1] TRUE
```
