# tests/testthat/test-descriptives-display.R
#
# Ethos request 22 (2026-10-03). A descriptives plan result carried column
# names such as valid_n, missing_n and sd, where the other plan tables read
# Mean and SD, and its sentence read "computed for 1 variable(s)".

test_that("22: a descriptives plan table has reader headings", {
  d <- sframe_demo("likert_scale")
  res <- run_analysis_plan(d$responses, d$instrument)
  tb <- Filter(function(r) identical(r$test, "descriptives"), res)[[1]]$table
  expect_true(all(c("Variable", "N", "Valid N", "Missing", "Mean", "SD",
                    "95% CI lower", "95% CI upper") %in% names(tb)))
  expect_false(any(c("valid_n", "missing_n", "sd", "group", "weighted_mean") %in% names(tb)))
})

test_that("22: descriptives_report() keeps its own column names", {
  d <- sframe_demo("likert_scale")
  item <- d$instrument$items[[1]]$id
  dr <- descriptives_report(d$responses, variables = item)
  expect_true(all(c("variable", "valid_n", "sd") %in% names(dr$table)))
})

test_that("22: report sentences agree in number", {
  d <- sframe_demo("likert_scale")
  item <- d$instrument$items[[1]]$id
  expect_match(descriptives_report(d$responses, variables = item)$apa,
               "computed for 1 variable.", fixed = TRUE)
  two <- vapply(d$instrument$items[1:2], function(i) i$id, character(1))
  expect_match(descriptives_report(d$responses, variables = two)$apa,
               "computed for 2 variables.", fixed = TRUE)
  expect_no_match(descriptives_report(d$responses, variables = two)$apa, "(s)", fixed = TRUE)
})
