# Package index

## Start here

SurveyStudio opens an instrument and takes it through every stage below,
by point and click. ?surveyframe is the map of the package, and
sframe_demo(“first_survey”) is a whole survey to start from.

- [`surveyframe`](https://surveyframe.org/reference/surveyframe-package.md)
  [`surveyframe-package`](https://surveyframe.org/reference/surveyframe-package.md)
  : surveyframe: Survey Instrument Workflows for R
- [`launch_studio()`](https://surveyframe.org/reference/launch_studio.md)
  : Launch the SurveyStudio interface

## Design

Make the instrument: its questions, choice sets, scales, branching and
attention checks, saved as a portable .sframe file. In SurveyBuilder:
the Build mode. In code:
[`sframe_instrument()`](https://surveyframe.org/reference/sframe_instrument.md)
and the makers listed here, then
[`write_sframe()`](https://surveyframe.org/reference/write_sframe.md).

- [`launch_builder()`](https://surveyframe.org/reference/launch_builder.md)
  : Launch the surveyframe visual survey builder
- [`sframe_instrument()`](https://surveyframe.org/reference/sframe_instrument.md)
  : Create a survey instrument object
- [`sframe_get_study()`](https://surveyframe.org/reference/sframe_get_study.md)
  : The study an instrument serves
- [`sframe_sampling_methods()`](https://surveyframe.org/reference/sframe_sampling_methods.md)
  : Sampling methods a study can declare
- [`sframe_item()`](https://surveyframe.org/reference/sframe_item.md) :
  Define a survey item
- [`sframe_choice_set()`](https://surveyframe.org/reference/sframe_choice_set.md)
  : Define a reusable choice set
- [`sframe_scale()`](https://surveyframe.org/reference/sframe_scale.md)
  : Define a scored scale
- [`sframe_branch()`](https://surveyframe.org/reference/sframe_branch.md)
  : Define a branching rule
- [`sframe_attention_check()`](https://surveyframe.org/reference/sframe_attention_check.md)
  : Define a design-time survey check
- [`sframe_conjoint_design()`](https://surveyframe.org/reference/sframe_conjoint_design.md)
  : Declare a choice-experiment (conjoint) design
- [`write_sframe()`](https://surveyframe.org/reference/write_sframe.md)
  : Write an instrument to a .sframe file
- [`read_sframe()`](https://surveyframe.org/reference/read_sframe.md) :
  Read an instrument from a .sframe file
- [`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md)
  : Validate an instrument object
- [`sframe_validation`](https://surveyframe.org/reference/sframe_validation.md)
  : Report on a validation result
- [`as_sframe()`](https://surveyframe.org/reference/as_sframe.md) :
  Coerce to an instrument

## Plan

Declare the analysis before the data arrive, so the report shows what
was planned and what was run. In SurveyBuilder: the Plan mode. In
SurveyStudio: Plan, or the Analyse screen. In code:
`sframe_plan(x) <- plan`.

- [`sframe_plan()`](https://surveyframe.org/reference/sframe_plan.md) :
  Get the pre-declared analysis plan
- [`` `sframe_plan<-`() ``](https://surveyframe.org/reference/sframe_plan-set.md)
  : Set the pre-declared analysis plan
- [`sframe_sample_size_plan()`](https://surveyframe.org/reference/sframe_sample_size_plan.md)
  : Sample-size and power planning helper

## Preview

See the survey as a respondent meets it, with nothing collected. In
SurveyStudio: the Preview screen. In code:
[`preview_survey()`](https://surveyframe.org/reference/preview_survey.md).

- [`preview_survey()`](https://surveyframe.org/reference/preview_survey.md)
  : Preview a survey as a respondent sees it
- [`run_survey()`](https://surveyframe.org/reference/run_survey.md) :
  Render a survey from an instrument object

## Collect

Send the survey out: a standalone HTML page, optionally saving answers
to a Google Sheet, or a Shiny module inside your own app. In
SurveyBuilder: Export survey, with the Google Sheets settings. In code:
[`export_survey()`](https://surveyframe.org/reference/export_survey.md).

- [`export_survey()`](https://surveyframe.org/reference/export_survey.md)
  : Export a self-contained static HTML survey
- [`export_google_sheet()`](https://surveyframe.org/reference/export_google_sheet.md)
  : Export a survey instrument to Google Sheets collection format
- [`sframe_survey_ui()`](https://surveyframe.org/reference/sframe_survey_ui.md)
  : Shiny module UI for an embedded survey
- [`sframe_survey_server()`](https://surveyframe.org/reference/sframe_survey_server.md)
  : Shiny module server for an embedded survey

## Responses

Read the answers back against the instrument, check their quality, and
export them with labels for other software. In SurveyStudio: the
Responses and Quality screens. In code:
[`read_responses()`](https://surveyframe.org/reference/read_responses.md).

- [`read_responses()`](https://surveyframe.org/reference/read_responses.md)
  : Read and validate survey responses
- [`read_sheet_responses()`](https://surveyframe.org/reference/read_sheet_responses.md)
  : Read survey responses from a Google Sheet
- [`export_responses()`](https://surveyframe.org/reference/export_responses.md)
  : Write responses to SPSS or Stata with the labels attached
- [`sframe_quality_results()`](https://surveyframe.org/reference/sframe_quality_results.md)
  : Generate a data quality report for survey responses
- [`sframe_missing_data_results()`](https://surveyframe.org/reference/sframe_missing_data_results.md)
  : Missing-data report
- [`sframe_outlier_results()`](https://surveyframe.org/reference/sframe_outlier_results.md)
  : Flag univariate and multivariate outliers

## Analyse

Score the scales and run the plan, block by block. In SurveyStudio: the
Explore, Reliability and Analyse screens. In code:
[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md).

- [`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md)
  : Run a pre-planned analysis from an instrument's analysis plan
- [`score_scales()`](https://surveyframe.org/reference/score_scales.md)
  : Score defined scales from survey responses
- [`sframe_descriptives_results()`](https://surveyframe.org/reference/sframe_descriptives_results.md)
  : Descriptive statistics report
- [`sframe_reliability_results()`](https://surveyframe.org/reference/sframe_reliability_results.md)
  : Estimate scale reliability from item responses
- [`sframe_item_results()`](https://surveyframe.org/reference/sframe_item_results.md)
  : Generate item-level diagnostics
- [`sframe_efa_readiness_results()`](https://surveyframe.org/reference/sframe_efa_readiness_results.md)
  : Prepare a survey instrument for exploratory factor analysis
- [`sframe_efa_solution()`](https://surveyframe.org/reference/sframe_efa_solution.md)
  : Estimate an exploratory factor solution
- [`sframe_validity_results()`](https://surveyframe.org/reference/sframe_validity_results.md)
  : Validity report for construct models
- [`sframe_assumption_results()`](https://surveyframe.org/reference/sframe_assumption_results.md)
  : Assumption-check report
- [`sframe_posthoc_results()`](https://surveyframe.org/reference/sframe_posthoc_results.md)
  : Post-hoc and pairwise comparison report

## Report

Write up what was run: an HTML, PDF, Word or OpenDocument report or its
Quarto source, a codebook, the figures, and the R code behind each
result, and
[`sframe_show()`](https://surveyframe.org/reference/sframe_show.md) to
open a written file. In SurveyStudio: the Report screen. In code:
[`render_report()`](https://surveyframe.org/reference/render_report.md).

- [`render_report()`](https://surveyframe.org/reference/render_report.md)
  : Render a reproducible survey report
- [`sframe_report_source()`](https://surveyframe.org/reference/sframe_report_source.md)
  : Recompute and check a report source folder
- [`render_results()`](https://surveyframe.org/reference/render_results.md)
  : Render analysis results to a formatted HTML report
- [`sframe_reports`](https://surveyframe.org/reference/sframe_reports.md)
  : Choosing a report
- [`sframe_format_result()`](https://surveyframe.org/reference/sframe_format_result.md)
  : Render one analysis result as the report does
- [`sframe_codebook()`](https://surveyframe.org/reference/sframe_codebook.md)
  : Generate a survey codebook from an instrument object
- [`sframe_save_figures()`](https://surveyframe.org/reference/sframe_save_figures.md)
  : Save the charts from an analysis plan as files
- [`sframe_analysis_qmd()`](https://surveyframe.org/reference/sframe_analysis_qmd.md)
  : Write a Quarto analysis notebook for any instrument
- [`sframe_show()`](https://surveyframe.org/reference/sframe_show.md) :
  Show a file surveyframe wrote

## References

Cite the works an instrument draws on. The references travel in the
.sframe file and the report lists each one once, at the end. In
SurveyStudio: the References screen. In code:
[`sframe_add_references()`](https://surveyframe.org/reference/sframe_add_references.md).

- [`sframe_reference()`](https://surveyframe.org/reference/sframe_reference.md)
  : Create a reference
- [`read_bibtex()`](https://surveyframe.org/reference/read_bibtex.md) :
  Read references from BibTeX
- [`sframe_add_references()`](https://surveyframe.org/reference/sframe_add_references.md)
  : Add references to an instrument
- [`sframe_get_references()`](https://surveyframe.org/reference/sframe_get_references.md)
  : List an instrument's references
- [`sframe_bibliography()`](https://surveyframe.org/reference/sframe_bibliography.md)
  : Write a bibliography as CSL-JSON

## Amendments

Change an instrument mid-study, on the record: each amendment is logged
with its reason and the hash it replaced. In SurveyStudio: the
Amendments screen. In code:
[`amend_sframe()`](https://surveyframe.org/reference/amend_sframe.md).

- [`amend_sframe()`](https://surveyframe.org/reference/amend_sframe.md)
  : Record a disclosed amendment to an instrument
- [`sframe_get_amendments()`](https://surveyframe.org/reference/sframe_get_amendments.md)
  : Read an instrument's amendment log
- [`sframe_drop_items()`](https://surveyframe.org/reference/sframe_drop_items.md)
  : Drop items from scales or models
- [`sframe_item_flags()`](https://surveyframe.org/reference/sframe_item_flags.md)
  : Items past the usual cut-offs in a measurement result
- [`sframe_link_git_commit()`](https://surveyframe.org/reference/sframe_link_git_commit.md)
  : Link an instrument to its current Git commit

## Inspect

Read parts of an instrument, a validation result or a report without
reaching into the object, at any stage. Each accessor and as.data.frame
method states the classes it accepts and what it returns.

- [`sframe_accessors`](https://surveyframe.org/reference/sframe_accessors.md)
  [`sf_accessors`](https://surveyframe.org/reference/sframe_accessors.md)
  : Explore a surveyframe object
- [`sframe_apa()`](https://surveyframe.org/reference/sframe_apa.md) :
  Extract APA-formatted result summaries
- [`sframe_get_branches()`](https://surveyframe.org/reference/sframe_get_branches.md)
  : Get branching rules
- [`sframe_get_attention_checks()`](https://surveyframe.org/reference/sframe_get_attention_checks.md)
  : Get response-quality checks
- [`sframe_get_choice_sets()`](https://surveyframe.org/reference/sframe_get_choice_sets.md)
  : Get choice sets
- [`sf_component_list`](https://surveyframe.org/reference/sf_component_list.md)
  : A list of instrument components
- [`sframe_flagged()`](https://surveyframe.org/reference/sframe_flagged.md)
  : Get rows flagged by response-quality checks
- [`sframe_id()`](https://surveyframe.org/reference/sframe_id.md) : Get
  an instrument component ID
- [`sframe_identity`](https://surveyframe.org/reference/sframe_identity.md)
  [`sf_identity`](https://surveyframe.org/reference/sframe_identity.md)
  : The ID and label of an instrument component
- [`sframe_is_valid()`](https://surveyframe.org/reference/sframe_is_valid.md)
  : Test whether validation passed
- [`sframe_get_items()`](https://surveyframe.org/reference/sframe_get_items.md)
  : Get survey items
- [`sframe_label()`](https://surveyframe.org/reference/sframe_label.md)
  : Get an instrument component label
- [`sframe_meta()`](https://surveyframe.org/reference/sframe_meta.md) :
  Get survey metadata
- [`sframe_missing_columns()`](https://surveyframe.org/reference/sframe_missing_columns.md)
  : Columns the instrument declares that the responses left out
- [`sframe_get_models()`](https://surveyframe.org/reference/sframe_get_models.md)
  : Get model specifications
- [`sframe_object()`](https://surveyframe.org/reference/sframe_object.md)
  : Recover the validated object
- [`sframe_problems()`](https://surveyframe.org/reference/sframe_problems.md)
  : Get validation problems
- [`sframe_notes()`](https://surveyframe.org/reference/sframe_notes.md)
  : Notes from a validation
- [`sframe_report_accessors`](https://surveyframe.org/reference/sframe_report_accessors.md)
  [`sf_report_accessors`](https://surveyframe.org/reference/sframe_report_accessors.md)
  : Read the reportable parts of an analysis or quality result
- [`sframe_get_scales()`](https://surveyframe.org/reference/sframe_get_scales.md)
  : Get survey scales
- [`sframe_validation_accessors`](https://surveyframe.org/reference/sframe_validation_accessors.md)
  [`sf_validation_accessors`](https://surveyframe.org/reference/sframe_validation_accessors.md)
  : Read a validation diagnostic
- [`sframe_as_data_frame`](https://surveyframe.org/reference/sframe_as_data_frame.md)
  : Coerce a surveyframe object to a data frame
- [`sframe_subset`](https://surveyframe.org/reference/sframe_subset.md)
  : Subset a surveyframe report
- [`as.data.frame(`*`<sf_choices>`*`)`](https://surveyframe.org/reference/as.data.frame.sf_choices.md)
  : Coerce a choice set to a data frame
- [`as.data.frame(`*`<sframe>`*`)`](https://surveyframe.org/reference/as.data.frame.sframe.md)
  : Coerce an instrument to its item summary
- [`as.data.frame(`*`<sframe_analysis_results>`*`)`](https://surveyframe.org/reference/as.data.frame.sframe_analysis_results.md)
  : Summarise analysis-plan results as a data frame
- [`as.data.frame(`*`<sframe_assumption_report>`*`)`](https://surveyframe.org/reference/as.data.frame.sframe_assumption_report.md)
  : Coerce an assumption report to a data frame
- [`as.data.frame(`*`<sframe_codebook>`*`)`](https://surveyframe.org/reference/as.data.frame.sframe_codebook.md)
  : Extract the item table from a codebook report
- [`as.data.frame(`*`<sframe_descriptives_report>`*`)`](https://surveyframe.org/reference/as.data.frame.sframe_descriptives_report.md)
  : Extract the descriptives results table
- [`as.data.frame(`*`<sframe_efa_report>`*`)`](https://surveyframe.org/reference/as.data.frame.sframe_efa_report.md)
  : Coerce an EFA readiness report to a data frame
- [`as.data.frame(`*`<sframe_efa_solution>`*`)`](https://surveyframe.org/reference/as.data.frame.sframe_efa_solution.md)
  : Extract the loading table from an EFA solution
- [`as.data.frame(`*`<sframe_item_report>`*`)`](https://surveyframe.org/reference/as.data.frame.sframe_item_report.md)
  : Coerce an item report to a data frame
- [`as.data.frame(`*`<sframe_missing_data_report>`*`)`](https://surveyframe.org/reference/as.data.frame.sframe_missing_data_report.md)
  : Extract item missingness results
- [`as.data.frame(`*`<sframe_quality_report>`*`)`](https://surveyframe.org/reference/as.data.frame.sframe_quality_report.md)
  : Coerce a response-quality report to a data frame
- [`as.data.frame(`*`<sframe_reliability_report>`*`)`](https://surveyframe.org/reference/as.data.frame.sframe_reliability_report.md)
  : Coerce a reliability report to a data frame
- [`as.data.frame(`*`<sframe_sample_size_plan>`*`)`](https://surveyframe.org/reference/as.data.frame.sframe_sample_size_plan.md)
  : Coerce a sample-size plan to a data frame
- [`as.data.frame(`*`<sframe_sensitivity>`*`)`](https://surveyframe.org/reference/as.data.frame.sframe_sensitivity.md)
  : Extract a sensitivity-analysis results table
- [`as.data.frame(`*`<sframe_validation>`*`)`](https://surveyframe.org/reference/as.data.frame.sframe_validation.md)
  : Coerce validation problems to a data frame
- [`as.data.frame(`*`<sframe_validity_report>`*`)`](https://surveyframe.org/reference/as.data.frame.sframe_validity_report.md)
  : Extract reliability evidence from a validity report

## Models and syntax

Declare constructs, paths and covariances, and generate lavaan, seminr
and psych syntax from the instrument.

- [`sframe_model_spec()`](https://surveyframe.org/reference/sframe_model_spec.md)
  : Create a surveyframe model specification
- [`sframe_construct()`](https://surveyframe.org/reference/sframe_construct.md)
  : Define a latent or composite construct
- [`sframe_path()`](https://surveyframe.org/reference/sframe_path.md) :
  Define a structural path between constructs
- [`sframe_covariance()`](https://surveyframe.org/reference/sframe_covariance.md)
  : Define a covariance between constructs
- [`sframe_indirect_effect()`](https://surveyframe.org/reference/sframe_indirect_effect.md)
  : Define an indirect effect path
- [`sframe_add_model()`](https://surveyframe.org/reference/sframe_add_model.md)
  : Add a model specification to an instrument
- [`sframe_validate_model()`](https://surveyframe.org/reference/sframe_validate_model.md)
  : Validate a surveyframe model specification
- [`sframe_model_json()`](https://surveyframe.org/reference/sframe_model_json.md)
  : Serialise a model specification to JSON
- [`sframe_model_outline()`](https://surveyframe.org/reference/sframe_model_outline.md)
  : Create a model reporting template
- [`sframe_syntax_cfa()`](https://surveyframe.org/reference/sframe_syntax_cfa.md)
  : Generate lavaan CFA syntax from an instrument or a declared model
- [`sframe_syntax_efa()`](https://surveyframe.org/reference/sframe_syntax_efa.md)
  : Generate EFA planning syntax
- [`sframe_syntax_sem()`](https://surveyframe.org/reference/sframe_syntax_sem.md)
  : Generate lavaan CB-SEM syntax
- [`sframe_syntax_pls()`](https://surveyframe.org/reference/sframe_syntax_pls.md)
  : Generate seminr PLS-SEM syntax
- [`sframe_syntax_result()`](https://surveyframe.org/reference/sframe_syntax_result.md)
  : The R code behind an analysis result

## Charts

Opt-in ggplot2 charts for analysis results, and the package theme.

- [`sframe_plots`](https://surveyframe.org/reference/sframe_plots.md) :
  Choosing a plot
- [`theme_surveyframe()`](https://surveyframe.org/reference/theme_surveyframe.md)
  : surveyframe brand theme for ggplot2
- [`plot(`*`<sframe_analysis_results>`*`)`](https://surveyframe.org/reference/plot.sframe_analysis_results.md)
  : Plot analysis-plan results
- [`sframe_plot_correlation_matrix()`](https://surveyframe.org/reference/sframe_plot_correlation_matrix.md)
  : Correlation matrix heatmap
- [`sframe_plot_decision_ranking()`](https://surveyframe.org/reference/sframe_plot_decision_ranking.md)
  : Ranked-score bar chart for a decision-family result
- [`sframe_plot_dematel_influence()`](https://surveyframe.org/reference/sframe_plot_dematel_influence.md)
  : Prominence-relation scatter for a DEMATEL result
- [`sframe_plot_descriptives()`](https://surveyframe.org/reference/sframe_plot_descriptives.md)
  : Distribution shape by variable, standardised
- [`sframe_plot_efa_loadings()`](https://surveyframe.org/reference/sframe_plot_efa_loadings.md)
  : Loadings heatmap from a fitted EFA solution
- [`sframe_plot_efa_scree()`](https://surveyframe.org/reference/sframe_plot_efa_scree.md)
  : Scree plot from an EFA readiness report
- [`sframe_plot_group_comparison()`](https://surveyframe.org/reference/sframe_plot_group_comparison.md)
  : Group-comparison boxplot
- [`sframe_plot_likert_matrix()`](https://surveyframe.org/reference/sframe_plot_likert_matrix.md)
  : Grouped diverging chart for a Likert matrix question
- [`sframe_plot_likert_scale()`](https://surveyframe.org/reference/sframe_plot_likert_scale.md)
  : Grouped diverging chart for a scale's Likert items
- [`sframe_plot_missingness()`](https://surveyframe.org/reference/sframe_plot_missingness.md)
  : Missing-data report plot: missingness rate by item
- [`sframe_plot_paired_comparison()`](https://surveyframe.org/reference/sframe_plot_paired_comparison.md)
  : Paired-comparison slope plot
- [`sframe_plot_quality()`](https://surveyframe.org/reference/sframe_plot_quality.md)
  : Quality report plot: straight-lining flag rate by scale
- [`sframe_plot_regression_diagnostics()`](https://surveyframe.org/reference/sframe_plot_regression_diagnostics.md)
  : Regression diagnostic plots for a regression_linear result
- [`sframe_plot_reliability()`](https://surveyframe.org/reference/sframe_plot_reliability.md)
  : Reliability plot: alpha and omega by scale
- [`sframe_plot_validity()`](https://surveyframe.org/reference/sframe_plot_validity.md)
  : Validity report plot: composite reliability and AVE by construct
- [`sframe_plot_variable_distribution()`](https://surveyframe.org/reference/sframe_plot_variable_distribution.md)
  : Raw-variable distribution panels: histogram, boxplot, and Q-Q
- [`sframe_plot_term_frequency()`](https://surveyframe.org/reference/sframe_plot_term_frequency.md)
  : Term-frequency plot: horizontal bar or word cloud
- [`sframe_plot_ngram_frequency()`](https://surveyframe.org/reference/sframe_plot_ngram_frequency.md)
  : N-gram-frequency plot: horizontal bar
- [`sframe_plot_cooccurrence()`](https://surveyframe.org/reference/sframe_plot_cooccurrence.md)
  : Term co-occurrence heatmap
- [`sframe_plot_cooccurrence_network()`](https://surveyframe.org/reference/sframe_plot_cooccurrence_network.md)
  : Term co-occurrence network plot
- [`sframe_plot_sentiment()`](https://surveyframe.org/reference/sframe_plot_sentiment.md)
  : Sentiment plot: diverging bar, or a positive/negative comparison
  cloud
- [`sframe_plot_topics()`](https://surveyframe.org/reference/sframe_plot_topics.md)
  : Topic-model top-terms plot: faceted bars, one facet per topic

## Decision analysis

Multi-criteria decision analysis. The 10 methods run through the
analysis plan like any other, so the functions here assemble their input
and test how stable a ranking is.

- [`sframe_sensitivity_analysis()`](https://surveyframe.org/reference/sframe_sensitivity_analysis.md)
  : Test how far a decision ranking moves when the weights are perturbed
- [`sframe_assemble_pairwise()`](https://surveyframe.org/reference/sframe_assemble_pairwise.md)
  : Assemble per-respondent comparison matrices
- [`sframe_aggregate_judgements()`](https://surveyframe.org/reference/sframe_aggregate_judgements.md)
  : Aggregate individual judgement matrices
- [`sframe_collected_weights()`](https://surveyframe.org/reference/sframe_collected_weights.md)
  : Criterion weights collected from respondents
- [`sframe_rated_matrix()`](https://surveyframe.org/reference/sframe_rated_matrix.md)
  : Build a performance matrix from rated matrix items
- [`sframe_decision_options()`](https://surveyframe.org/reference/sframe_decision_options.md)
  : Normalise the decision options of an analysis-plan block
- [`sframe_dematel_compute()`](https://surveyframe.org/reference/sframe_dematel_compute.md)
  : The DEMATEL total-relation classification

## Text analysis

Open-ended answers: term and n-gram frequency, keyword in context, and
quote extraction.

- [`sframe_clean_text()`](https://surveyframe.org/reference/sframe_clean_text.md)
  : Clean open-ended text responses for analysis
- [`sframe_term_frequency()`](https://surveyframe.org/reference/sframe_term_frequency.md)
  : Term frequency for open-ended text
- [`sframe_ngram_frequency()`](https://surveyframe.org/reference/sframe_ngram_frequency.md)
  : N-gram frequency for open-ended text
- [`sframe_term_context()`](https://surveyframe.org/reference/sframe_term_context.md)
  : Keyword-in-context concordance for open-ended text
- [`sframe_extract_quotes()`](https://surveyframe.org/reference/sframe_extract_quotes.md)
  : Extract representative quotes for each STM topic

## Confidence intervals

Base-R bootstrap and effect-size confidence intervals, reused across the
inferential runners.

- [`sframe_bootstrap_ci()`](https://surveyframe.org/reference/sframe_bootstrap_ci.md)
  : Percentile bootstrap confidence interval for a statistic
- [`sframe_cohens_d_ci()`](https://surveyframe.org/reference/sframe_cohens_d_ci.md)
  : Bootstrap confidence interval for Cohen's d
- [`sframe_cramers_v_ci()`](https://surveyframe.org/reference/sframe_cramers_v_ci.md)
  : Confidence interval for Cramer's V
- [`sframe_eta_sq_ci()`](https://surveyframe.org/reference/sframe_eta_sq_ci.md)
  : Confidence interval for eta squared

## Demos

25 small teaching demos, each doing one job, and 2 larger reference
datasets. Each comes with an instrument and response data, and the
teaching demos with a codebook and the results surveyframe produced. See
the “Learn by example” article.

- [`sframe_list_demos()`](https://surveyframe.org/reference/sframe_list_demos.md)
  : List the bundled demos
- [`sframe_demo()`](https://surveyframe.org/reference/sframe_demo.md) :
  Load one bundled demo
- [`sframe_demo_qmd()`](https://surveyframe.org/reference/sframe_demo_qmd.md)
  : Copy a demo's Quarto notebook so you can run and change it

## Methods

Print, format and summary methods, so every component prints and
summarises cleanly at the console and inside reports.

- [`print(`*`<sframe>`*`)`](https://surveyframe.org/reference/print.sframe.md)
  : Print an sframe instrument object
- [`format(`*`<sframe>`*`)`](https://surveyframe.org/reference/format.sframe.md)
  : Format an sframe instrument object as a string
- [`summary(`*`<sframe>`*`)`](https://surveyframe.org/reference/summary.sframe.md)
  : Summarise an sframe instrument object
- [`print(`*`<sf_choices>`*`)`](https://surveyframe.org/reference/print.sf_choices.md)
  : Print an sf_choices object
- [`format(`*`<sf_choices>`*`)`](https://surveyframe.org/reference/format.sf_choices.md)
  : Format an sf_choices object as a string
- [`summary(`*`<sf_choices>`*`)`](https://surveyframe.org/reference/summary.sf_choices.md)
  : Summarise an sf_choices object
- [`print(`*`<sf_item>`*`)`](https://surveyframe.org/reference/print.sf_item.md)
  : Print an sf_item object
- [`format(`*`<sf_item>`*`)`](https://surveyframe.org/reference/format.sf_item.md)
  : Format an sf_item object as a string
- [`summary(`*`<sf_item>`*`)`](https://surveyframe.org/reference/summary.sf_item.md)
  : Summarise an sf_item object
- [`print(`*`<sf_scale>`*`)`](https://surveyframe.org/reference/print.sf_scale.md)
  : Print an sf_scale object
- [`format(`*`<sf_scale>`*`)`](https://surveyframe.org/reference/format.sf_scale.md)
  : Format an sf_scale object as a string
- [`summary(`*`<sf_scale>`*`)`](https://surveyframe.org/reference/summary.sf_scale.md)
  : Summarise an sf_scale object
- [`print(`*`<sf_branch>`*`)`](https://surveyframe.org/reference/print.sf_branch.md)
  : Print an sf_branch object
- [`format(`*`<sf_branch>`*`)`](https://surveyframe.org/reference/format.sf_branch.md)
  : Format an sf_branch object as a string
- [`summary(`*`<sf_branch>`*`)`](https://surveyframe.org/reference/summary.sf_branch.md)
  : Summarise an sf_branch object
- [`print(`*`<sf_check>`*`)`](https://surveyframe.org/reference/print.sf_check.md)
  : Print an sf_check object
- [`format(`*`<sf_check>`*`)`](https://surveyframe.org/reference/format.sf_check.md)
  : Format an sf_check object as a string
- [`summary(`*`<sf_check>`*`)`](https://surveyframe.org/reference/summary.sf_check.md)
  : Summarise an sf_check object
- [`print(`*`<sf_model>`*`)`](https://surveyframe.org/reference/print.sf_model.md)
  : Print an sf_model object
- [`format(`*`<sf_model>`*`)`](https://surveyframe.org/reference/format.sf_model.md)
  : Format an sf_model object as a string
- [`summary(`*`<sf_model>`*`)`](https://surveyframe.org/reference/summary.sf_model.md)
  : Summarise an sf_model object

## For the report template

The APA cell formatter the Quarto report template calls. Exported
because Quarto renders against the installed package.

- [`sframe_apa_cells()`](https://surveyframe.org/reference/sframe_apa_cells.md)
  [`sframe_apa_col_labels()`](https://surveyframe.org/reference/sframe_apa_cells.md)
  : Format a result table's cells as an APA 7 report prints them

## Old names (superseded)

Every name changed in 0.4.3, each still working, and what replaced it.

- [`sf_instrument()`](https://surveyframe.org/reference/superseded.md)
  [`sf_item()`](https://surveyframe.org/reference/superseded.md)
  [`sf_choices()`](https://surveyframe.org/reference/superseded.md)
  [`sf_scale()`](https://surveyframe.org/reference/superseded.md)
  [`sf_branch()`](https://surveyframe.org/reference/superseded.md)
  [`sf_check()`](https://surveyframe.org/reference/superseded.md)
  [`sf_conjoint_design()`](https://surveyframe.org/reference/superseded.md)
  [`sf_construct()`](https://surveyframe.org/reference/superseded.md)
  [`sf_path()`](https://surveyframe.org/reference/superseded.md)
  [`sf_covariance()`](https://surveyframe.org/reference/superseded.md)
  [`sf_indirect()`](https://surveyframe.org/reference/superseded.md)
  [`sf_model()`](https://surveyframe.org/reference/superseded.md)
  [`add_model()`](https://surveyframe.org/reference/superseded.md)
  [`validate_model()`](https://surveyframe.org/reference/superseded.md)
  [`model_json()`](https://surveyframe.org/reference/superseded.md)
  [`model_report_template()`](https://surveyframe.org/reference/superseded.md)
  [`sf_items()`](https://surveyframe.org/reference/superseded.md)
  [`sf_scales()`](https://surveyframe.org/reference/superseded.md)
  [`sf_checks()`](https://surveyframe.org/reference/superseded.md)
  [`sf_models()`](https://surveyframe.org/reference/superseded.md)
  [`sf_branches()`](https://surveyframe.org/reference/superseded.md)
  [`sf_choice_sets()`](https://surveyframe.org/reference/superseded.md)
  [`sf_meta()`](https://surveyframe.org/reference/superseded.md)
  [`sf_plan()`](https://surveyframe.org/reference/superseded.md)
  [`sf_id()`](https://surveyframe.org/reference/superseded.md)
  [`sf_label()`](https://surveyframe.org/reference/superseded.md)
  [`sf_apa()`](https://surveyframe.org/reference/superseded.md)
  [`sf_flagged()`](https://surveyframe.org/reference/superseded.md)
  [`sf_problems()`](https://surveyframe.org/reference/superseded.md)
  [`sf_is_valid()`](https://surveyframe.org/reference/superseded.md)
  [`sf_object()`](https://surveyframe.org/reference/superseded.md)
  [`sf_missing_columns()`](https://surveyframe.org/reference/superseded.md)
  [`sample_size_plan()`](https://surveyframe.org/reference/superseded.md)
  [`sf_reference()`](https://surveyframe.org/reference/superseded.md)
  [`add_references()`](https://surveyframe.org/reference/superseded.md)
  [`sframe_references()`](https://surveyframe.org/reference/superseded.md)
  [`link_git_commit()`](https://surveyframe.org/reference/superseded.md)
  [`amendment_log()`](https://surveyframe.org/reference/superseded.md)
  [`render_survey()`](https://surveyframe.org/reference/superseded.md)
  [`export_static_survey()`](https://surveyframe.org/reference/superseded.md)
  [`survey_module_ui()`](https://surveyframe.org/reference/superseded.md)
  [`survey_module_server()`](https://surveyframe.org/reference/superseded.md)
  [`sframe_export_labelled()`](https://surveyframe.org/reference/superseded.md)
  [`quality_report()`](https://surveyframe.org/reference/superseded.md)
  [`missing_data_report()`](https://surveyframe.org/reference/superseded.md)
  [`outlier_report()`](https://surveyframe.org/reference/superseded.md)
  [`reliability_report()`](https://surveyframe.org/reference/superseded.md)
  [`item_report()`](https://surveyframe.org/reference/superseded.md)
  [`efa_report()`](https://surveyframe.org/reference/superseded.md)
  [`efa_solution()`](https://surveyframe.org/reference/superseded.md)
  [`validity_report()`](https://surveyframe.org/reference/superseded.md)
  [`descriptives_report()`](https://surveyframe.org/reference/superseded.md)
  [`assumption_report()`](https://surveyframe.org/reference/superseded.md)
  [`posthoc_report()`](https://surveyframe.org/reference/superseded.md)
  [`bootstrap_ci()`](https://surveyframe.org/reference/superseded.md)
  [`cohens_d_ci()`](https://surveyframe.org/reference/superseded.md)
  [`cramers_v_ci()`](https://surveyframe.org/reference/superseded.md)
  [`eta_sq_ci()`](https://surveyframe.org/reference/superseded.md)
  [`cfa_lavaan_syntax()`](https://surveyframe.org/reference/superseded.md)
  [`cfa_syntax()`](https://surveyframe.org/reference/superseded.md)
  [`sem_lavaan_syntax()`](https://surveyframe.org/reference/superseded.md)
  [`seminr_syntax()`](https://surveyframe.org/reference/superseded.md)
  [`efa_syntax()`](https://surveyframe.org/reference/superseded.md)
  [`analysis_syntax()`](https://surveyframe.org/reference/superseded.md)
  [`clean_text_responses()`](https://surveyframe.org/reference/superseded.md)
  [`term_frequency()`](https://surveyframe.org/reference/superseded.md)
  [`ngram_frequency()`](https://surveyframe.org/reference/superseded.md)
  [`term_context()`](https://surveyframe.org/reference/superseded.md)
  [`extract_quotes()`](https://surveyframe.org/reference/superseded.md)
  [`sensitivity_analysis()`](https://surveyframe.org/reference/superseded.md)
  [`render_result()`](https://surveyframe.org/reference/superseded.md)
  [`codebook_report()`](https://surveyframe.org/reference/superseded.md)
  [`sframe_demos()`](https://surveyframe.org/reference/superseded.md)
  [`sframe_demo_data()`](https://surveyframe.org/reference/superseded.md)
  [`sframe_input_types_demo_data()`](https://surveyframe.org/reference/superseded.md)
  [`launch_builder_demo()`](https://surveyframe.org/reference/superseded.md)
  [`launch_studio_demo()`](https://surveyframe.org/reference/superseded.md)
  [`preview_demo()`](https://surveyframe.org/reference/superseded.md)
  [`` `sf_plan<-`() ``](https://surveyframe.org/reference/superseded.md)
  [`launch_dashboard()`](https://surveyframe.org/reference/superseded.md)
  [`launch_dashboard_demo()`](https://surveyframe.org/reference/superseded.md)
  : Superseded function names
