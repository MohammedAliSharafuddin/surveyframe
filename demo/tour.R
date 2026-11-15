# This guided tour follows 1 study through the 5 surveyframe stages.
# Each stage uses the bundled two-group study and writes files to R's temporary folder.

step <- function(msg) if (interactive()) invisible(readline(paste0("\n", msg, " Press <Return>: ")))
old_use_quarto <- getOption("surveyframe.use_quarto")
options(surveyframe.use_quarto = FALSE)

study <- sframe_demo("two_group", preview = FALSE)
instrument <- study$instrument
responses <- study$responses

step("Stage 1 of 5, design: inspect the instrument and preview the questionnaire.")
print(instrument)
preview_path <- preview_survey(instrument, open = interactive())

step("Stage 2 of 5, collect: review the pre-analysis plan before collecting responses.")
plan_path <- render_report(
  instrument,
  output_file = file.path(tempdir(), "surveyframe-tour-plan.html"),
  open = FALSE
)
sframe_show(plan_path, quiet = !interactive())

step("Stage 3 of 5, check: inspect the response-quality checks.")
quality <- sframe_quality_results(responses, instrument)
print(quality)

step("Stage 4 of 5, analyse: run the declared plan and draw its charts.")
results <- run_analysis_plan(responses, instrument, plots = TRUE)
print(results)
plot(results)

step("Stage 5 of 5, report: write and open the reproducible results report.")
report_path <- render_report(
  instrument,
  responses,
  output_file = file.path(tempdir(), "surveyframe-tour-report.html"),
  open = FALSE
)
sframe_show(report_path, quiet = !interactive())
options(surveyframe.use_quarto = old_use_quarto)
