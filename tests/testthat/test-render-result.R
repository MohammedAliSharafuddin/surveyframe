# tests/testthat/test-render-result.R
#
# Ethos request 1 (2026-10-01). The function that picks a result's chart was
# internal, so Ethos kept its own map from method to chart and its own table
# formatting, and frequencies, crosstabs, correlations, regressions,
# moderation, mediation, item diagnostics and repeated measures got no chart
# there. render_result() renders one result with the report's own code.

test_that("1: render_result() gives the table, caption, note and chart", {
  skip_if_not_installed("ggplot2")
  d <- sframe_demo("two_group")
  res <- run_analysis_plan(d$responses, d$instrument)
  out <- render_result(res[[1]], d$responses, d$instrument)
  expect_identical(out$caption, paste0(res[[1]]$block_id, ": ", res[[1]]$research_question))
  expect_s3_class(out$table, "data.frame")
  expect_identical(out$table$Group, c("In person", "Online"))
  expect_match(out$note, "^Method references: \\(")
  expect_s3_class(out$chart, "ggplot")
  expect_match(out$html, "<section class=\"sf-result\">", fixed = TRUE)
  expect_match(out$html, "data:image/png;base64,", fixed = TRUE)
})

test_that("1: the chart is the one run_analysis_plan(plots = TRUE) draws", {
  skip_on_cran()
  skip_if_not_installed("ggplot2")
  for (demo in c("first_survey", "likert_scale", "categorical", "correlation_regression",
                 "paired", "multi_group", "repeated", "logistic")) {
    d <- sframe_demo(demo)
    plain <- run_analysis_plan(d$responses, d$instrument)
    drawn <- run_analysis_plan(d$responses, d$instrument, plots = TRUE)
    for (i in seq_along(plain)) {
      out <- render_result(plain[[i]], d$responses, d$instrument)
      expect_identical(inherits(out$chart, "ggplot"), inherits(drawn[[i]]$plot, "ggplot"),
                       info = paste(demo, plain[[i]]$block_id))
      if (inherits(out$chart, "ggplot")) {
        expect_identical(out$chart$labels$title, drawn[[i]]$plot$labels$title,
                         info = paste(demo, plain[[i]]$block_id))
      }
    }
  }
})

test_that("1: png and svg write the chart to a file, and an error is shown", {
  skip_if_not_installed("ggplot2")
  d <- sframe_demo("two_group")
  res <- run_analysis_plan(d$responses, d$instrument)
  png <- render_result(res[[1]], d$responses, d$instrument, format = "png", dpi = 100,
                       width = 5, height = 3)
  expect_true(file.exists(png$chart_file))
  expect_null(png$html)
  failed <- list(block_id = "RQ9", research_question = "Q", test = "t_test_ind",
                 error = "Too few responses with a value for this test.")
  html <- render_result(failed, d$responses, d$instrument)$html
  expect_match(html, "Too few responses", fixed = TRUE)
})
