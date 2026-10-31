# R/superseded.R
# Written by data-raw/rename_0.4.3.R from the 0.4.3 naming table. Edit the
# table there and rerun it, not this file.

#' Superseded function names
#'
#' In 0.4.3 every exported function took the `sframe_` prefix or a stage
#' verb, so a name says which stage it belongs to and no 2 names sit 1
#' letter apart. The old names still work and give the same result, with no
#' warning. Set `options(surveyframe.warn_superseded = TRUE)` to get 1
#' warning per old name per session, naming its replacement.
#'
#' | Old name | New name |
#' |---|---|
#' | `sf_instrument()` | [sframe_instrument()] |
#' | `sf_item()` | [sframe_item()] |
#' | `sf_choices()` | [sframe_choice_set()] |
#' | `sf_scale()` | [sframe_scale()] |
#' | `sf_branch()` | [sframe_branch()] |
#' | `sf_check()` | [sframe_attention_check()] |
#' | `sf_conjoint_design()` | [sframe_conjoint_design()] |
#' | `sf_construct()` | [sframe_construct()] |
#' | `sf_path()` | [sframe_path()] |
#' | `sf_covariance()` | [sframe_covariance()] |
#' | `sf_indirect()` | [sframe_indirect_effect()] |
#' | `sf_model()` | [sframe_model_spec()] |
#' | `add_model()` | [sframe_add_model()] |
#' | `validate_model()` | [sframe_validate_model()] |
#' | `model_json()` | [sframe_model_json()] |
#' | `model_report_template()` | [sframe_model_outline()] |
#' | `sf_items()` | [sframe_get_items()] |
#' | `sf_scales()` | [sframe_get_scales()] |
#' | `sf_checks()` | [sframe_get_attention_checks()] |
#' | `sf_models()` | [sframe_get_models()] |
#' | `sf_branches()` | [sframe_get_branches()] |
#' | `sf_choice_sets()` | [sframe_get_choice_sets()] |
#' | `sf_meta()` | [sframe_meta()] |
#' | `sf_plan()` | [sframe_plan()] |
#' | `sf_id()` | [sframe_id()] |
#' | `sf_label()` | [sframe_label()] |
#' | `sf_apa()` | [sframe_apa()] |
#' | `sf_flagged()` | [sframe_flagged()] |
#' | `sf_problems()` | [sframe_problems()] |
#' | `sf_is_valid()` | [sframe_is_valid()] |
#' | `sf_object()` | [sframe_object()] |
#' | `sf_missing_columns()` | [sframe_missing_columns()] |
#' | `sample_size_plan()` | [sframe_sample_size_plan()] |
#' | `sf_reference()` | [sframe_reference()] |
#' | `add_references()` | [sframe_add_references()] |
#' | `sframe_references()` | [sframe_get_references()] |
#' | `link_git_commit()` | [sframe_link_git_commit()] |
#' | `amendment_log()` | [sframe_get_amendments()] |
#' | `render_survey()` | [run_survey()] |
#' | `export_static_survey()` | [export_survey()] |
#' | `survey_module_ui()` | [sframe_survey_ui()] |
#' | `survey_module_server()` | [sframe_survey_server()] |
#' | `sframe_export_labelled()` | [export_responses()] |
#' | `quality_report()` | [sframe_quality_results()] |
#' | `missing_data_report()` | [sframe_missing_data_results()] |
#' | `outlier_report()` | [sframe_outlier_results()] |
#' | `reliability_report()` | [sframe_reliability_results()] |
#' | `item_report()` | [sframe_item_results()] |
#' | `efa_report()` | [sframe_efa_readiness_results()] |
#' | `efa_solution()` | [sframe_efa_solution()] |
#' | `validity_report()` | [sframe_validity_results()] |
#' | `descriptives_report()` | [sframe_descriptives_results()] |
#' | `assumption_report()` | [sframe_assumption_results()] |
#' | `posthoc_report()` | [sframe_posthoc_results()] |
#' | `bootstrap_ci()` | [sframe_bootstrap_ci()] |
#' | `cohens_d_ci()` | [sframe_cohens_d_ci()] |
#' | `cramers_v_ci()` | [sframe_cramers_v_ci()] |
#' | `eta_sq_ci()` | [sframe_eta_sq_ci()] |
#' | `cfa_lavaan_syntax()` | [sframe_syntax_cfa()] |
#' | `cfa_syntax()` | [sframe_syntax_cfa()] |
#' | `sem_lavaan_syntax()` | [sframe_syntax_sem()] |
#' | `seminr_syntax()` | [sframe_syntax_pls()] |
#' | `efa_syntax()` | [sframe_syntax_efa()] |
#' | `analysis_syntax()` | [sframe_syntax_result()] |
#' | `clean_text_responses()` | [sframe_clean_text()] |
#' | `term_frequency()` | [sframe_term_frequency()] |
#' | `ngram_frequency()` | [sframe_ngram_frequency()] |
#' | `term_context()` | [sframe_term_context()] |
#' | `extract_quotes()` | [sframe_extract_quotes()] |
#' | `sensitivity_analysis()` | [sframe_sensitivity_analysis()] |
#' | `render_result()` | [sframe_format_result()] |
#' | `codebook_report()` | [sframe_codebook()] |
#' | `sframe_demos()` | [sframe_list_demos()] |
#' | `sframe_demo_data()` | [sframe_demo()] with `"tourism_services"` |
#' | `sframe_input_types_demo_data()` | [sframe_demo()] with `"input_types"` |
#' | `launch_builder_demo()` | [launch_builder()] with `demo = "input_types"` |
#' | `sf_plan(x) <- value` | [sframe_plan<-][sframe_plan] |
#'
#' @param ... Passed to the new function.
#' @param instrument,scales,std_lv Passed to [sframe_syntax_cfa()].
#' @param x An instrument.
#' @param value The analysis plan, as for [sframe_plan()].
#' @return What the new function returns.
#' @examples
#' # The old name and the new one make the same item
#' identical(sf_item("q1", "Question 1", type = "text"),
#'           sframe_item("q1", "Question 1", type = "text"))
#' @name superseded
#' @family superseded
NULL

#' @rdname superseded
#' @export
sf_instrument <- function(...) {
  sframe_superseded("sf_instrument()", "sframe_instrument()")
  sframe_instrument(...)
}

#' @rdname superseded
#' @export
sf_item <- function(...) {
  sframe_superseded("sf_item()", "sframe_item()")
  sframe_item(...)
}

#' @rdname superseded
#' @export
sf_choices <- function(...) {
  sframe_superseded("sf_choices()", "sframe_choice_set()")
  sframe_choice_set(...)
}

#' @rdname superseded
#' @export
sf_scale <- function(...) {
  sframe_superseded("sf_scale()", "sframe_scale()")
  sframe_scale(...)
}

#' @rdname superseded
#' @export
sf_branch <- function(...) {
  sframe_superseded("sf_branch()", "sframe_branch()")
  sframe_branch(...)
}

#' @rdname superseded
#' @export
sf_check <- function(...) {
  sframe_superseded("sf_check()", "sframe_attention_check()")
  sframe_attention_check(...)
}

#' @rdname superseded
#' @export
sf_conjoint_design <- function(...) {
  sframe_superseded("sf_conjoint_design()", "sframe_conjoint_design()")
  sframe_conjoint_design(...)
}

#' @rdname superseded
#' @export
sf_construct <- function(...) {
  sframe_superseded("sf_construct()", "sframe_construct()")
  sframe_construct(...)
}

#' @rdname superseded
#' @export
sf_path <- function(...) {
  sframe_superseded("sf_path()", "sframe_path()")
  sframe_path(...)
}

#' @rdname superseded
#' @export
sf_covariance <- function(...) {
  sframe_superseded("sf_covariance()", "sframe_covariance()")
  sframe_covariance(...)
}

#' @rdname superseded
#' @export
sf_indirect <- function(...) {
  sframe_superseded("sf_indirect()", "sframe_indirect_effect()")
  sframe_indirect_effect(...)
}

#' @rdname superseded
#' @export
sf_model <- function(...) {
  sframe_superseded("sf_model()", "sframe_model_spec()")
  sframe_model_spec(...)
}

#' @rdname superseded
#' @export
add_model <- function(...) {
  sframe_superseded("add_model()", "sframe_add_model()")
  sframe_add_model(...)
}

#' @rdname superseded
#' @export
validate_model <- function(...) {
  sframe_superseded("validate_model()", "sframe_validate_model()")
  sframe_validate_model(...)
}

#' @rdname superseded
#' @export
model_json <- function(...) {
  sframe_superseded("model_json()", "sframe_model_json()")
  sframe_model_json(...)
}

#' @rdname superseded
#' @export
model_report_template <- function(...) {
  sframe_superseded("model_report_template()", "sframe_model_outline()")
  sframe_model_outline(...)
}

#' @rdname superseded
#' @export
sf_items <- function(...) {
  sframe_superseded("sf_items()", "sframe_get_items()")
  sframe_get_items(...)
}

#' @rdname superseded
#' @export
sf_scales <- function(...) {
  sframe_superseded("sf_scales()", "sframe_get_scales()")
  sframe_get_scales(...)
}

#' @rdname superseded
#' @export
sf_checks <- function(...) {
  sframe_superseded("sf_checks()", "sframe_get_attention_checks()")
  sframe_get_attention_checks(...)
}

#' @rdname superseded
#' @export
sf_models <- function(...) {
  sframe_superseded("sf_models()", "sframe_get_models()")
  sframe_get_models(...)
}

#' @rdname superseded
#' @export
sf_branches <- function(...) {
  sframe_superseded("sf_branches()", "sframe_get_branches()")
  sframe_get_branches(...)
}

#' @rdname superseded
#' @export
sf_choice_sets <- function(...) {
  sframe_superseded("sf_choice_sets()", "sframe_get_choice_sets()")
  sframe_get_choice_sets(...)
}

#' @rdname superseded
#' @export
sf_meta <- function(...) {
  sframe_superseded("sf_meta()", "sframe_meta()")
  sframe_meta(...)
}

#' @rdname superseded
#' @export
sf_plan <- function(...) {
  sframe_superseded("sf_plan()", "sframe_plan()")
  sframe_plan(...)
}

#' @rdname superseded
#' @export
sf_id <- function(...) {
  sframe_superseded("sf_id()", "sframe_id()")
  sframe_id(...)
}

#' @rdname superseded
#' @export
sf_label <- function(...) {
  sframe_superseded("sf_label()", "sframe_label()")
  sframe_label(...)
}

#' @rdname superseded
#' @export
sf_apa <- function(...) {
  sframe_superseded("sf_apa()", "sframe_apa()")
  sframe_apa(...)
}

#' @rdname superseded
#' @export
sf_flagged <- function(...) {
  sframe_superseded("sf_flagged()", "sframe_flagged()")
  sframe_flagged(...)
}

#' @rdname superseded
#' @export
sf_problems <- function(...) {
  sframe_superseded("sf_problems()", "sframe_problems()")
  sframe_problems(...)
}

#' @rdname superseded
#' @export
sf_is_valid <- function(...) {
  sframe_superseded("sf_is_valid()", "sframe_is_valid()")
  sframe_is_valid(...)
}

#' @rdname superseded
#' @export
sf_object <- function(...) {
  sframe_superseded("sf_object()", "sframe_object()")
  sframe_object(...)
}

#' @rdname superseded
#' @export
sf_missing_columns <- function(...) {
  sframe_superseded("sf_missing_columns()", "sframe_missing_columns()")
  sframe_missing_columns(...)
}

#' @rdname superseded
#' @export
sample_size_plan <- function(...) {
  sframe_superseded("sample_size_plan()", "sframe_sample_size_plan()")
  sframe_sample_size_plan(...)
}

#' @rdname superseded
#' @export
sf_reference <- function(...) {
  sframe_superseded("sf_reference()", "sframe_reference()")
  sframe_reference(...)
}

#' @rdname superseded
#' @export
add_references <- function(...) {
  sframe_superseded("add_references()", "sframe_add_references()")
  sframe_add_references(...)
}

#' @rdname superseded
#' @export
sframe_references <- function(...) {
  sframe_superseded("sframe_references()", "sframe_get_references()")
  sframe_get_references(...)
}

#' @rdname superseded
#' @export
link_git_commit <- function(...) {
  sframe_superseded("link_git_commit()", "sframe_link_git_commit()")
  sframe_link_git_commit(...)
}

#' @rdname superseded
#' @export
amendment_log <- function(...) {
  sframe_superseded("amendment_log()", "sframe_get_amendments()")
  sframe_get_amendments(...)
}

#' @rdname superseded
#' @export
render_survey <- function(...) {
  sframe_superseded("render_survey()", "run_survey()")
  run_survey(...)
}

#' @rdname superseded
#' @export
export_static_survey <- function(...) {
  sframe_superseded("export_static_survey()", "export_survey()")
  export_survey(...)
}

#' @rdname superseded
#' @export
survey_module_ui <- function(...) {
  sframe_superseded("survey_module_ui()", "sframe_survey_ui()")
  sframe_survey_ui(...)
}

#' @rdname superseded
#' @export
survey_module_server <- function(...) {
  sframe_superseded("survey_module_server()", "sframe_survey_server()")
  sframe_survey_server(...)
}

#' @rdname superseded
#' @export
sframe_export_labelled <- function(...) {
  sframe_superseded("sframe_export_labelled()", "export_responses()")
  export_responses(...)
}

#' @rdname superseded
#' @export
quality_report <- function(...) {
  sframe_superseded("quality_report()", "sframe_quality_results()")
  sframe_quality_results(...)
}

#' @rdname superseded
#' @export
missing_data_report <- function(...) {
  sframe_superseded("missing_data_report()", "sframe_missing_data_results()")
  sframe_missing_data_results(...)
}

#' @rdname superseded
#' @export
outlier_report <- function(...) {
  sframe_superseded("outlier_report()", "sframe_outlier_results()")
  sframe_outlier_results(...)
}

#' @rdname superseded
#' @export
reliability_report <- function(...) {
  sframe_superseded("reliability_report()", "sframe_reliability_results()")
  sframe_reliability_results(...)
}

#' @rdname superseded
#' @export
item_report <- function(...) {
  sframe_superseded("item_report()", "sframe_item_results()")
  sframe_item_results(...)
}

#' @rdname superseded
#' @export
efa_report <- function(...) {
  sframe_superseded("efa_report()", "sframe_efa_readiness_results()")
  sframe_efa_readiness_results(...)
}

#' @rdname superseded
#' @export
efa_solution <- function(...) {
  sframe_superseded("efa_solution()", "sframe_efa_solution()")
  sframe_efa_solution(...)
}

#' @rdname superseded
#' @export
validity_report <- function(...) {
  sframe_superseded("validity_report()", "sframe_validity_results()")
  sframe_validity_results(...)
}

#' @rdname superseded
#' @export
descriptives_report <- function(...) {
  sframe_superseded("descriptives_report()", "sframe_descriptives_results()")
  sframe_descriptives_results(...)
}

#' @rdname superseded
#' @export
assumption_report <- function(...) {
  sframe_superseded("assumption_report()", "sframe_assumption_results()")
  sframe_assumption_results(...)
}

#' @rdname superseded
#' @export
posthoc_report <- function(...) {
  sframe_superseded("posthoc_report()", "sframe_posthoc_results()")
  sframe_posthoc_results(...)
}

#' @rdname superseded
#' @export
bootstrap_ci <- function(...) {
  sframe_superseded("bootstrap_ci()", "sframe_bootstrap_ci()")
  sframe_bootstrap_ci(...)
}

#' @rdname superseded
#' @export
cohens_d_ci <- function(...) {
  sframe_superseded("cohens_d_ci()", "sframe_cohens_d_ci()")
  sframe_cohens_d_ci(...)
}

#' @rdname superseded
#' @export
cramers_v_ci <- function(...) {
  sframe_superseded("cramers_v_ci()", "sframe_cramers_v_ci()")
  sframe_cramers_v_ci(...)
}

#' @rdname superseded
#' @export
eta_sq_ci <- function(...) {
  sframe_superseded("eta_sq_ci()", "sframe_eta_sq_ci()")
  sframe_eta_sq_ci(...)
}

#' @rdname superseded
#' @export
cfa_lavaan_syntax <- function(...) {
  sframe_superseded("cfa_lavaan_syntax()", "sframe_syntax_cfa()")
  sframe_syntax_cfa(...)
}

#' @rdname superseded
#' @export
cfa_syntax <- function(instrument, scales = NULL, std_lv = TRUE) {
  sframe_superseded("cfa_syntax()", "sframe_syntax_cfa()")
  sframe_syntax_cfa(instrument = instrument, scales = scales, std_lv = std_lv)
}

#' @rdname superseded
#' @export
sem_lavaan_syntax <- function(...) {
  sframe_superseded("sem_lavaan_syntax()", "sframe_syntax_sem()")
  sframe_syntax_sem(...)
}

#' @rdname superseded
#' @export
seminr_syntax <- function(...) {
  sframe_superseded("seminr_syntax()", "sframe_syntax_pls()")
  sframe_syntax_pls(...)
}

#' @rdname superseded
#' @export
efa_syntax <- function(...) {
  sframe_superseded("efa_syntax()", "sframe_syntax_efa()")
  sframe_syntax_efa(...)
}

#' @rdname superseded
#' @export
analysis_syntax <- function(...) {
  sframe_superseded("analysis_syntax()", "sframe_syntax_result()")
  sframe_syntax_result(...)
}

#' @rdname superseded
#' @export
clean_text_responses <- function(...) {
  sframe_superseded("clean_text_responses()", "sframe_clean_text()")
  sframe_clean_text(...)
}

#' @rdname superseded
#' @export
term_frequency <- function(...) {
  sframe_superseded("term_frequency()", "sframe_term_frequency()")
  sframe_term_frequency(...)
}

#' @rdname superseded
#' @export
ngram_frequency <- function(...) {
  sframe_superseded("ngram_frequency()", "sframe_ngram_frequency()")
  sframe_ngram_frequency(...)
}

#' @rdname superseded
#' @export
term_context <- function(...) {
  sframe_superseded("term_context()", "sframe_term_context()")
  sframe_term_context(...)
}

#' @rdname superseded
#' @export
extract_quotes <- function(...) {
  sframe_superseded("extract_quotes()", "sframe_extract_quotes()")
  sframe_extract_quotes(...)
}

#' @rdname superseded
#' @export
sensitivity_analysis <- function(...) {
  sframe_superseded("sensitivity_analysis()", "sframe_sensitivity_analysis()")
  sframe_sensitivity_analysis(...)
}

#' @rdname superseded
#' @export
render_result <- function(...) {
  sframe_superseded("render_result()", "sframe_format_result()")
  sframe_format_result(...)
}

#' @rdname superseded
#' @export
codebook_report <- function(...) {
  sframe_superseded("codebook_report()", "sframe_codebook()")
  sframe_codebook(...)
}

#' @rdname superseded
#' @export
sframe_demos <- function(...) {
  sframe_superseded("sframe_demos()", "sframe_list_demos()")
  sframe_list_demos(...)
}

#' @rdname superseded
#' @export
sframe_demo_data <- function() {
  sframe_superseded("sframe_demo_data()", "sframe_demo(\"tourism_services\")")
  sframe_demo("tourism_services")
}

#' @rdname superseded
#' @export
sframe_input_types_demo_data <- function() {
  sframe_superseded("sframe_input_types_demo_data()", "sframe_demo(\"input_types\")")
  sframe_demo("input_types")
}

#' @rdname superseded
#' @export
launch_builder_demo <- function(open = TRUE) {
  sframe_superseded("launch_builder_demo()", "launch_builder(demo = \"input_types\")")
  path <- launch_builder(open = open, demo = "input_types")
  demo <- sframe_demo("input_types")
  invisible(list(builder_path = path, demo_file = demo$instrument_path,
                 responses_path = demo$responses_path))
}

#' @rdname superseded
#' @export
`sf_plan<-` <- function(x, value) {
  sframe_superseded("sf_plan(x) <- value", "sframe_plan(x) <- value")
  `sframe_plan<-`(x, value = value)
}
