# tests/testthat/test-dashboard-filter-labels.R
#
# The dashboard named each filter by its item id ("visit_type") and offered
# the stored codes, where the rest of the dashboard and the tables use the
# instrument's labels. Found capturing the vignette screenshots, 2026-10-25.

test_that("dashboard filters take the question label and the choice labels", {
  app <- system.file("shiny", "dashboard", "app.R", package = "surveyframe")
  skip_if(!nzchar(app) || !file.exists(app), "dashboard app not available")
  src <- paste(readLines(app, warn = FALSE), collapse = "\n")
  bar <- regmatches(src, regexpr("output\\$filter_bar <- renderUI\\(\\{(?s).*?\\n  \\}\\)",
                                 src, perl = TRUE))
  expect_length(bar, 1L)
  expect_match(bar, "sframe_label_lookup(instr)", fixed = TRUE)
  expect_match(bar, "sframe_item_value_labels(instr, nm)", fixed = TRUE)
  expect_match(bar, "choices = stats::setNames(vals, shown)", fixed = TRUE)
  expect_no_match(bar, "tags$label(nm)", fixed = TRUE)
})

test_that("the demo's filter items resolve to their labels", {
  ins <- sframe_input_types_demo_data()$instrument
  expect_identical(unname(sframe_label_lookup(ins)[["visit_type"]]),
                   "Was this your first visit?")
  expect_true(length(sframe_item_value_labels(ins, "visit_type")) > 0)
})
