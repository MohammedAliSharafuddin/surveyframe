# tests/testthat/test-studio-run-layout.R
#
# SurveyStudio drew each run result inside the middle third of the Analysis
# Plan screen, about 230 px wide at 1440, so a result table printed "120" one
# digit per line and clipped its p column. Found capturing the vignette
# screenshots, 2026-10-25. Results now take a full-width row below the 3
# columns, drawn only on the Run preview tab.

studio_source <- function() {
  app <- system.file("shiny", "app.R", package = "surveyframe")
  skip_if(!nzchar(app) || !file.exists(app), "studio app not available")
  paste(readLines(app, warn = FALSE), collapse = "\n")
}

test_that("run results sit in a full-width row, outside the middle column", {
  src <- studio_source()
  middle <- regmatches(src, regexpr(
    "output\\$analysis_middle_panel <- renderUI\\(\\{(?s).*?\\n  \\}\\)", src, perl = TRUE))
  expect_length(middle, 1L)
  expect_no_match(middle, "analysis_results_output", fixed = TRUE)

  row <- regmatches(src, regexpr(
    "output\\$analysis_results_row <- renderUI\\(\\{(?s).*?\\n  \\}\\)", src, perl = TRUE))
  expect_length(row, 1L)
  expect_match(row, "column(12, uiOutput(\"analysis_results_output\"))", fixed = TRUE)
  expect_match(row, "\"Run\"", fixed = TRUE)
  expect_match(src, "uiOutput(\"analysis_results_row\")", fixed = TRUE)
})
