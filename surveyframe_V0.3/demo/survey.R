## surveyframe end-to-end demo
##
## This demo uses a simulated tourism-services questionnaire and response
## dataset bundled with the package. It is safe to run offline.

library(surveyframe)

instrument_path <- system.file(
  "extdata", "tourism_services_demo.sframe",
  package = "surveyframe"
)
responses_path <- system.file(
  "extdata", "tourism_services_responses.csv",
  package = "surveyframe"
)

instr <- read_sframe(instrument_path)
responses <- read_responses(
  responses_path,
  instr,
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  meta_cols = "started_at"
)

cat("\nInstrument\n")
print(instr)

cat("\nResponses\n")
print(utils::head(responses[, c("respondent_id", "visit_type", "dm_1", "sat_1")]))

cat("\nScale scores\n")
scored <- score_scales(responses, instr)
print(utils::head(scored[, c(
  "digital_marketing",
  "service_quality",
  "sustainability",
  "satisfaction",
  "behavioural_intention"
)]))

cat("\nAnalysis plan results\n")
results <- run_analysis_plan(responses, instr)
print(results)

cat("\nQuality report\n")
quality <- quality_report(
  responses,
  instr,
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  started_at = "started_at",
  straightline_scales = FALSE
)
print(quality)

old <- options(surveyframe.use_quarto = FALSE)
report_path <- render_report(
  instr,
  data = responses,
  output_file = tempfile(fileext = ".html"),
  include_reliability = FALSE,
  include_analysis = FALSE
)
options(old)

cat("\nDemo report written to:\n", report_path, "\n", sep = "")
cat("\nTo open the interactive dashboard, run:\n")
cat("launch_dashboard()\n")
