## surveyframe guided end-to-end demo
##
## This walkthrough uses a simulated tourism-services questionnaire and
## response dataset bundled with the package. It is safe to run offline.

library(surveyframe)

`%||%` <- function(x, y) if (is.null(x)) y else x

pause_demo <- function() {
  if (interactive()) {
    invisible(readline("Press <Return> to continue..."))
  } else {
    invisible(NULL)
  }
}

section <- function(title) {
  cat("\n", strrep("=", 72), "\n", sep = "")
  cat(title, "\n")
  cat(strrep("=", 72), "\n", sep = "")
}

demo_dir <- file.path(tempdir(), "surveyframe-demo")
dir.create(demo_dir, recursive = TRUE, showWarnings = FALSE)

section("1. Load a complete instrument and simulated response dataset")

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

print(instr)
cat("\nResponses loaded:", nrow(responses), "rows x", ncol(responses), "columns\n")
cat("Demo output folder:\n", demo_dir, "\n", sep = "")
pause_demo()

section("2. Score multi-item constructs")

scored <- score_scales(responses, instr)
scale_names <- vapply(instr$scales, function(s) s$id, character(1))

scale_summary <- data.frame(
  scale = scale_names,
  label = vapply(instr$scales, function(s) s$label, character(1)),
  n_items = vapply(instr$scales, function(s) length(s$items), integer(1)),
  mean = round(vapply(scored[scale_names], mean, numeric(1), na.rm = TRUE), 2),
  sd = round(vapply(scored[scale_names], stats::sd, numeric(1), na.rm = TRUE), 2),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

print(scale_summary, row.names = FALSE)
utils::write.csv(
  scale_summary,
  file.path(demo_dir, "table_scale_summary.csv"),
  row.names = FALSE
)

png(file.path(demo_dir, "plot_scale_distributions.png"), width = 1100, height = 750)
op <- par(mfrow = c(2, 3), mar = c(4, 4, 3, 1))
for (nm in scale_names) {
  hist(
    scored[[nm]],
    breaks = seq(1, 5, by = 0.5),
    col = "#1f6f78",
    border = "white",
    main = gsub("_", " ", nm),
    xlab = "Scale score",
    xlim = c(1, 5)
  )
  abline(v = mean(scored[[nm]], na.rm = TRUE), col = "#d97706", lwd = 2)
}
par(op)
dev.off()

cat("\nSaved table_scale_summary.csv and plot_scale_distributions.png\n")
pause_demo()

section("3. Run the pre-planned analysis plan")

results <- run_analysis_plan(responses, instr)

analysis_table <- data.frame(
  rq = seq_along(results),
  research_question = vapply(results, function(x) x$research_question, character(1)),
  test = vapply(results, function(x) x$test, character(1)),
  apa_result = vapply(results, function(x) x$apa %||% x$error %||% "", character(1)),
  interpretation_prompt = vapply(results, function(x) x$prompt %||% "", character(1)),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

print(analysis_table[, c("rq", "test", "apa_result")], row.names = FALSE)
utils::write.csv(
  analysis_table,
  file.path(demo_dir, "table_analysis_results.csv"),
  row.names = FALSE
)

png(file.path(demo_dir, "plot_digital_marketing_satisfaction.png"),
    width = 900, height = 650)
plot(
  scored$digital_marketing,
  scored$satisfaction,
  pch = 19,
  col = "#1f6f7899",
  xlab = "Digital marketing effectiveness",
  ylab = "Tourist satisfaction",
  main = "Digital marketing and satisfaction"
)
abline(stats::lm(satisfaction ~ digital_marketing, data = scored),
       col = "#d97706", lwd = 2)
grid()
dev.off()

cat("\nSaved table_analysis_results.csv and plot_digital_marketing_satisfaction.png\n")
pause_demo()

section("4. Check response quality")

quality <- quality_report(
  responses,
  instr,
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  started_at = "started_at",
  straightline_scales = FALSE
)

quality_table <- data.frame(
  metric = c(
    "Respondents",
    "Flagged respondents",
    "Flag rate",
    "Attention-check pass rate",
    "Median completion time seconds"
  ),
  value = c(
    quality$summary$n_respondents,
    quality$summary$n_flagged,
    sprintf("%.1f%%", quality$summary$flag_rate * 100),
    sprintf("%.1f%%", quality$attention$attention_agree$pass_rate * 100),
    round(quality$timing$median_sec, 1)
  ),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

print(quality_table, row.names = FALSE)
utils::write.csv(
  quality_table,
  file.path(demo_dir, "table_quality_summary.csv"),
  row.names = FALSE
)

png(file.path(demo_dir, "plot_attention_check.png"), width = 780, height = 520)
barplot(
  c(
    Pass = quality$attention$attention_agree$n_pass,
    Fail = quality$attention$attention_agree$n_fail
  ),
  col = c("#1f6f78", "#dc2626"),
  border = NA,
  main = "Attention-check outcome",
  ylab = "Respondents"
)
dev.off()

cat("\nSaved table_quality_summary.csv and plot_attention_check.png\n")
pause_demo()

section("5. Render publication-ready HTML outputs")

results_report <- render_results(
  results,
  instr,
  output_file = file.path(demo_dir, "analysis_results.html")
)

old <- options(surveyframe.use_quarto = FALSE)
full_report <- render_report(
  instr,
  data = responses,
  output_file = file.path(demo_dir, "survey_report.html"),
  include_reliability = FALSE,
  include_analysis = FALSE
)
options(old)

cat("Analysis results report:\n", results_report, "\n", sep = "")
cat("Full survey report:\n", full_report, "\n", sep = "")

cat("\nFiles created:\n")
print(list.files(demo_dir, full.names = TRUE))

cat("\nTo open the interactive response dashboard, run:\n")
cat("launch_dashboard()\n")
