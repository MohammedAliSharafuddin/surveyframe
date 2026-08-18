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
integrity hashing, and record disclosed revisions to them.

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
- [`amend_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amend_sframe.md)
  : Record a disclosed amendment to an instrument
- [`amendment_log()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amendment_log.md)
  : Read an instrument's amendment log
- [`link_git_commit()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/link_git_commit.md)
  : Link an instrument to its current Git commit
- [`print(`*`<sframe_validation>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)
  [`format(`*`<sframe_validation>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)
  [`summary(`*`<sframe_validation>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)
  [`as.data.frame(`*`<sframe_validation>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)
  : Report on a validation result

## Accessors and coercion

Read parts of an instrument, a validation result, or a report without
reaching into the object directly, new in 0.4.0.

- [`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md)
  : Coerce to an instrument
- [`sf_meta()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md)
  [`sf_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md)
  [`sf_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md)
  [`sf_choice_sets()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md)
  [`sf_branches()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md)
  [`sf_checks()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md)
  [`sf_models()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md)
  [`sf_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md)
  : Explore a surveyframe object
- [`print(`*`<sf_component_list>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_component_list.md)
  [`` `[`( ``*`<sf_component_list>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_component_list.md)
  : A list of instrument components
- [`sf_id()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_identity.md)
  [`sf_label()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_identity.md)
  : The ID and label of an instrument component
- [`` `sf_plan<-`() ``](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_plan-set.md)
  : Set the pre-declared analysis plan
- [`sf_apa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_report_accessors.md)
  [`sf_flagged()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_report_accessors.md)
  : Read the reportable parts of an analysis or quality result
- [`sf_is_valid()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_validation_accessors.md)
  [`sf_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_validation_accessors.md)
  [`sf_object()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_validation_accessors.md)
  : Read a validation diagnostic
- [`as.data.frame(`*`<sframe>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md)
  [`as.data.frame(`*`<sf_choices>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md)
  [`as.data.frame(`*`<sframe_codebook>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md)
  [`as.data.frame(`*`<sframe_reliability_report>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md)
  [`as.data.frame(`*`<sframe_item_report>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md)
  [`as.data.frame(`*`<sframe_efa_report>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md)
  [`as.data.frame(`*`<sframe_efa_solution>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md)
  [`as.data.frame(`*`<sframe_descriptives_report>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md)
  [`as.data.frame(`*`<sframe_missing_data_report>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md)
  [`as.data.frame(`*`<sframe_validity_report>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md)
  [`as.data.frame(`*`<sframe_assumption_report>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md)
  [`as.data.frame(`*`<sframe_sample_size_plan>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md)
  [`as.data.frame(`*`<sframe_quality_report>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md)
  [`as.data.frame(`*`<sframe_sensitivity>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md)
  [`as.data.frame(`*`<sframe_analysis_results>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md)
  : Coerce a surveyframe object to a data frame
- [`` `[`( ``*`<sframe_analysis_results>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_subset.md)
  [`` `[`( ``*`<sframe_reliability_report>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_subset.md)
  [`` `[`( ``*`<sframe_item_report>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_subset.md)
  : Subset a surveyframe report

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

## Decision analysis

Multi-criteria decision analysis, new in 0.4.0. The 10 methods run
through the analysis plan like any other, so the functions here are the
ones that assemble their input, test how stable a ranking is, and build
choice designs.

- [`sensitivity_analysis()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sensitivity_analysis.md)
  : Test how far a decision ranking moves when the weights are perturbed
- [`sf_conjoint_design()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_conjoint_design.md)
  : Declare a choice-experiment (conjoint) design
- [`sframe_assemble_pairwise()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_assemble_pairwise.md)
  : Assemble per-respondent comparison matrices
- [`sframe_aggregate_judgements()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_aggregate_judgements.md)
  : Aggregate individual judgement matrices
- [`sframe_collected_weights()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_collected_weights.md)
  : Criterion weights collected from respondents
- [`sframe_rated_matrix()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_rated_matrix.md)
  : Build a performance matrix from rated matrix items
- [`sframe_decision_options()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_decision_options.md)
  : Normalise the decision options of an analysis-plan block
- [`sframe_dematel_compute()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_dematel_compute.md)
  : The DEMATEL total-relation classification

## Text analysis

Structured analysis of open-ended text responses, new in 0.5.0: term and
n-gram frequency, keyword-in-context concordance, co-occurrence (plain
and network), sentiment, topic modelling, and quote extraction.

- [`clean_text_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/clean_text_responses.md)
  : Clean open-ended text responses for analysis
- [`term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/term_frequency.md)
  : Term frequency for open-ended text
- [`ngram_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/ngram_frequency.md)
  : N-gram frequency for open-ended text
- [`term_context()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/term_context.md)
  : Keyword-in-context concordance for open-ended text
- [`extract_quotes()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/extract_quotes.md)
  : Extract representative quotes for each STM topic

## Confidence intervals

Base-R bootstrap and effect-size confidence interval helpers, reused
across the inferential runners.

- [`bootstrap_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/bootstrap_ci.md)
  : Percentile bootstrap confidence interval for a statistic
- [`cohens_d_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cohens_d_ci.md)
  : Bootstrap confidence interval for Cohen's d
- [`cramers_v_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cramers_v_ci.md)
  : Bootstrap confidence interval for Cramer's V
- [`eta_sq_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/eta_sq_ci.md)
  : Bootstrap confidence interval for eta squared

## Report

Generate codebooks, scale appendices, and reproducible HTML reports.

- [`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md)
  : Generate a survey codebook from an instrument object
- [`sframe_codebook_items_display()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_codebook_items_display.md)
  : Enrich a codebook's items table for display
- [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
  : Render a reproducible survey report
- [`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md)
  : Render analysis results to a formatted HTML report
- [`model_report_template()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/model_report_template.md)
  : Create a model reporting template

## Plotting

Opt-in ggplot2 charts for analysis results, and the package theme.

- [`theme_surveyframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/theme_surveyframe.md)
  : surveyframe brand theme for ggplot2
- [`plot(`*`<sframe_analysis_results>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/plot.sframe_analysis_results.md)
  : Plot analysis-plan results
- [`sframe_plot_correlation_matrix()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_correlation_matrix.md)
  : Correlation matrix heatmap
- [`sframe_plot_decision_ranking()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_decision_ranking.md)
  : Ranked-score bar chart for a decision-family result
- [`sframe_plot_dematel_influence()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_dematel_influence.md)
  : Prominence-relation scatter for a DEMATEL result
- [`sframe_plot_descriptives()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_descriptives.md)
  : Distribution shape by variable, standardised
- [`sframe_plot_efa_loadings()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_efa_loadings.md)
  : Loadings heatmap from a fitted EFA solution
- [`sframe_plot_efa_scree()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_efa_scree.md)
  : Scree plot from an EFA readiness report
- [`sframe_plot_group_comparison()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_group_comparison.md)
  : Group-comparison boxplot
- [`sframe_plot_likert_matrix()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_likert_matrix.md)
  : Grouped diverging chart for a Likert matrix question
- [`sframe_plot_likert_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_likert_scale.md)
  : Grouped diverging chart for a scale's Likert items
- [`sframe_plot_missingness()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_missingness.md)
  : Missing-data report plot: missingness rate by item
- [`sframe_plot_paired_comparison()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_paired_comparison.md)
  : Paired-comparison slope plot
- [`sframe_plot_quality()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_quality.md)
  : Quality report plot: straight-lining flag rate by scale
- [`sframe_plot_regression_diagnostics()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_regression_diagnostics.md)
  : Regression diagnostic plots for a regression_linear result
- [`sframe_plot_reliability()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_reliability.md)
  : Reliability plot: alpha and omega by scale
- [`sframe_plot_validity()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_validity.md)
  : Validity report plot: composite reliability and AVE by construct
- [`sframe_plot_variable_distribution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_variable_distribution.md)
  : Raw-variable distribution panels: histogram, boxplot, and Q-Q
- [`sframe_draw_mosaic()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_draw_mosaic.md)
  : Mosaic plot for a two-way categorical result
- [`sframe_likert_scale_groups()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_likert_scale_groups.md)
  : Group a scale's Likert items for a combined diverging chart
- [`sframe_plot_term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_term_frequency.md)
  : Term-frequency plot: horizontal bar or word cloud
- [`sframe_plot_ngram_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_ngram_frequency.md)
  : N-gram-frequency plot: horizontal bar
- [`sframe_plot_cooccurrence()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_cooccurrence.md)
  : Term co-occurrence heatmap
- [`sframe_plot_cooccurrence_network()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_cooccurrence_network.md)
  : Term co-occurrence network plot
- [`sframe_plot_sentiment()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_sentiment.md)
  : Sentiment plot: diverging bar, or a positive/negative comparison
  cloud
- [`sframe_plot_topics()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_topics.md)
  : Topic-model top-terms plot: faceted bars, one facet per topic

## Print, format, and summary methods

S3 methods so every component object prints and summarises cleanly at
the console and inside reports.

- [`print(`*`<sframe>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sframe.md)
  : Print an sframe instrument object
- [`format(`*`<sframe>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/format.sframe.md)
  : Format an sframe instrument object as a string
- [`summary(`*`<sframe>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sframe.md)
  : Summarise an sframe instrument object
- [`print(`*`<sf_choices>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sf_choices.md)
  : Print an sf_choices object
- [`format(`*`<sf_choices>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/format.sf_choices.md)
  : Format an sf_choices object as a string
- [`summary(`*`<sf_choices>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_choices.md)
  : Summarise an sf_choices object
- [`print(`*`<sf_item>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sf_item.md)
  : Print an sf_item object
- [`format(`*`<sf_item>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/format.sf_item.md)
  : Format an sf_item object as a string
- [`summary(`*`<sf_item>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_item.md)
  : Summarise an sf_item object
- [`print(`*`<sf_scale>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sf_scale.md)
  : Print an sf_scale object
- [`format(`*`<sf_scale>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/format.sf_scale.md)
  : Format an sf_scale object as a string
- [`summary(`*`<sf_scale>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_scale.md)
  : Summarise an sf_scale object
- [`print(`*`<sf_branch>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sf_branch.md)
  : Print an sf_branch object
- [`format(`*`<sf_branch>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/format.sf_branch.md)
  : Format an sf_branch object as a string
- [`summary(`*`<sf_branch>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_branch.md)
  : Summarise an sf_branch object
- [`print(`*`<sf_check>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sf_check.md)
  : Print an sf_check object
- [`format(`*`<sf_check>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/format.sf_check.md)
  : Format an sf_check object as a string
- [`summary(`*`<sf_check>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_check.md)
  : Summarise an sf_check object
- [`print(`*`<sf_model>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sf_model.md)
  : Print an sf_model object
- [`format(`*`<sf_model>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/format.sf_model.md)
  : Format an sf_model object as a string
- [`summary(`*`<sf_model>`*`)`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_model.md)
  : Summarise an sf_model object

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
