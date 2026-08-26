# R/review_032_functions.R
# surveyframe 0.3.2 — complete source map for the MAS co-review
#
# Open each file in RStudio (Ctrl+click the path or use File > Open File).
# Work through layers in order. Tick each item in mas_review_032.md as you go.
# This script is a navigation aid only — no code is executed.

# ------------------------------------------------------------------------------
# LAYER 1 — Component constructors
# The six building blocks that every instrument is assembled from.
# ------------------------------------------------------------------------------

# R/sf_choices.R        sf_choices()          — choice set constructor
# R/sf_branch.R         sf_branch()           — branching/skip-logic rule
# R/sf_check.R          sf_check()            — attention/quality check
# R/sf_scale.R          sf_scale()            — scale definition
# R/sf_item.R           sf_item()             — individual question/item
# R/sf_component_methods.R                    — print/format/summary S3 methods
#                                               for all six classes above
#                                               (Change 2 of 0.3.2)

# ------------------------------------------------------------------------------
# LAYER 2 — Instrument, validation, and serialisation
# How the pieces are assembled, checked, and stored to disk.
# ------------------------------------------------------------------------------

# R/conditions.R        sframe_check_instrument()  — typed condition helpers
#                                                    used by every user-facing error
# R/sf_instrument.R     sf_instrument()            — top-level instrument constructor
# R/validate_sframe.R   validate_sframe()          — integrity rules and validation
# R/sframe_methods.R    print.sframe()             — S3 print/summary for sframe
#                       summary.sframe()
# R/read_write_sframe.R write_sframe()             — JSON serialisation + hash
#                       read_sframe()              — deserialise + hash check

# ------------------------------------------------------------------------------
# LAYER 3 — Survey delivery
# Everything that renders or launches the instrument for respondents.
# ------------------------------------------------------------------------------

# R/export_static_survey.R  export_static_survey()   — write self-contained HTML
#                                                       (Change 5: single_choice
#                                                       items render as Likert rows)
# R/render_survey.R         render_survey()          — HTML template engine and
#                                                       item-type renderers
# R/survey_module.R         survey_module_ui()       — Shiny module for embedding
#                           survey_module_server()     the survey inside any app
# R/builder.R               launch_builder()         — open SurveyBuilder HTML
#                           launch_builder_demo()
# R/studio_builder.R        launch_studio()          — SurveyStudio Shiny internals
#                           launch_studio_demo()
# R/dashboard.R             launch_dashboard()       — response dashboard Shiny app
#                           launch_dashboard_demo()
# R/launch_studio.R         launch_studio() wrappers

# ------------------------------------------------------------------------------
# LAYER 4 — Data ingestion and analysis
# Response reading, scoring, psychometrics, and analysis plan execution.
# ------------------------------------------------------------------------------

# R/read_responses.R    read_responses()          — read CSV from static survey
# R/score_scales.R      score_scales()            — score scales from responses
# R/quality_report.R    quality_report()          — attention checks, completion
# R/psychometrics.R     reliability_report()      — Cronbach's alpha / omega
#                       efa_report()              — KMO, Bartlett, factor count
#                       validity_report()         — CR and AVE
#                       assumption_report()       — normality, homogeneity
# R/statistics_reports.R   all statistical runners   — the engine behind each RQ
#                                                       test (52 KB, largest file)
# R/analysis_plan.R     run_analysis_plan()       — dispatch over declared RQs
#                                                   (48 KB, second largest)
# R/model_layer.R       sf_model()                — measurement/structural model
#                       sf_construct()
#                       sf_path(), sf_covariance(), sf_indirect()
#                       cfa_lavaan_syntax()       — lavaan CFA model string
#                       sem_lavaan_syntax()       — lavaan SEM model string
#                       seminr_syntax()           — SEMinR syntax
#                       (lavaan moved to Suggests — Change 3 of 0.3.2)
# R/reporting.R         render_report()           — full HTML report
#                       render_results()          — analysis results HTML
#                       codebook_report()         — codebook data frame

# ------------------------------------------------------------------------------
# LAYER 5 — Demo data, Google Sheets, and utilities
# ------------------------------------------------------------------------------

# R/demo_helpers.R      sframe_demo_data()        — bundled demo instrument + responses
#                       sframe_input_types_demo_data()
#                       launch_builder_demo()
#                       launch_studio_demo()
#                       launch_dashboard_demo()
# R/google_sheets.R     export_google_sheet()     — push survey to Google Sheets
#                       read_sheet_responses()    — pull responses back
# R/utils.R                                       — internal helpers (no exports)
# R/surveyframe-package.R                         — package-level @docType doc
#                                                   CITATION title fix (Change 1)

# ------------------------------------------------------------------------------
# LAYER 6 — Vignettes
# Each is a worked example. Knit each one before sign-off (Part U of review).
# ------------------------------------------------------------------------------

# vignettes/surveyframe.Rmd              — main vignette; full end-to-end workflow
#                                          Contains 0.3.2 additions:
#                                          - EFA readiness section
#                                          - Construct validity section
#                                          - Assumption checks section
#                                          - Scale means as labelled data frame
#                                          - render_results() path + file size
#                                          - Omega interpretation note
#                                          (Change 6 of 0.3.2)
# vignettes/building-survey-instrument.Rmd   — sf_instrument() walkthrough
# vignettes/analysing-survey-responses.Rmd   — analysis plan walkthrough
# vignettes/scale-reliability-validity.Rmd   — psychometrics deep-dive
# vignettes/efa-cfa-sem-pls-syntax.Rmd       — EFA / CFA / SEM / PLS syntax
# vignettes/surveybuilder-gui-overview.Rmd   — GUI builder overview

# ------------------------------------------------------------------------------
# LAYER 7 — inst/ assets
# HTML templates, Shiny apps, bundled data, and the CITATION file.
# ------------------------------------------------------------------------------

# inst/static_survey/template.html       — exported static survey template
#                                          (reads R.render.header for logo)
# inst/builder/survey_builder.html       — SurveyBuilder GUI (HTML/JS)
# inst/shiny/app.R                       — SurveyStudio Shiny app entry point
# inst/shiny/server/                     — server-side modules
# inst/shiny/ui/                         — UI modules
# inst/shiny/www/                        — static assets for SurveyStudio
# inst/shiny/dashboard/app.R             — response dashboard Shiny app
# inst/shiny/dashboard/www/              — static assets for dashboard
# inst/templates/report.qmd             — Quarto template (future use)
# inst/extdata/tourism_services_demo.sframe          — bundled demo instrument
# inst/extdata/tourism_services_responses.csv        — bundled demo responses
# inst/extdata/surveyframe_input_types_demo.sframe   — input types demo
# inst/extdata/surveyframe_input_types_responses.csv — input types demo responses
# inst/CITATION                          — citation metadata (version fix Change 1)

# ------------------------------------------------------------------------------
# LAYER 8 — Tests
# Run devtools::test() to confirm 407/407 pass before sign-off (Part V).
# ------------------------------------------------------------------------------

# tests/testthat/test-core.R             — core instrument construction and validation
# tests/testthat/test-component-methods.R — S3 print/format/summary for all classes
#                                           (Change 2 of 0.3.2)
# tests/testthat/test-0.3.1-fixes.R     — regression tests for 0.3.1 collection fixes
# tests/testthat/test-builder-analysis.R — builder state and analysis integration
# tests/testthat/test-input-types-demo.R — all 13 input types round-trip
# tests/testthat/test-v03-analysis-models.R — analysis plan and model layer

# ------------------------------------------------------------------------------
# LAYER 9 — Package metadata
# ------------------------------------------------------------------------------

# DESCRIPTION    — version (0.3.2), Imports (jsonlite, rlang, openssl),
#                  Suggests (lavaan, psych, shiny, googlesheets4, rmarkdown, ...)
#                  (lavaan moved from Imports to Suggests — Change 3 of 0.3.2)
# NAMESPACE      — generated by roxygen2 via devtools::document()
# man/           — 87 .Rd help files, generated from roxygen2 tags

# ------------------------------------------------------------------------------
# LAYER 10 — JSS paper (surveyframe-dev only, not in CRAN tarball)
# ------------------------------------------------------------------------------

# jss-paper/surveyframe.Rnw              — JSS manuscript (Rnw, not yet revised)
# jss-paper/replicate.R                  — replication script reviewed in Part T
#                                          export_static_survey() and
#                                          render_results() guarded with
#                                          if (interactive()) { }
#                                          (Change 4 of 0.3.2)
