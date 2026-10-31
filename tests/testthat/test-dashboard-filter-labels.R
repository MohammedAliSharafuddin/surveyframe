# tests/testthat/test-dashboard-filter-labels.R
#
# The dashboard filters moved into SurveyStudio's Dashboard screen with the
# standalone dashboard app. The Studio filter bar names each filter by its
# question label and offers choice labels. The helpers that choose the
# filters are internal functions, tested directly here.

test_that("the Studio filter bar takes the question label and the choice labels", {
  src <- sframe_installed_text("shiny", "app.R")
  bar <- regmatches(src, regexpr("output\\$dash_filter_bar <- renderUI\\(\\{(?s).*?\\n  \\}\\)",
                                 src, perl = TRUE))
  expect_length(bar, 1L)
  expect_match(bar, "sframe_label_lookup(instr)", fixed = TRUE)
  expect_match(bar, "sframe_item_value_labels(instr, nm)", fixed = TRUE)
  expect_match(bar, "choices = stats::setNames(vals, shown)", fixed = TRUE)
  expect_no_match(bar, "tags$label(nm)", fixed = TRUE)
  expect_match(src, "dash_filtered_responses <- reactive", fixed = TRUE)
})

test_that("the standalone dashboard app is gone", {
  expect_false(nzchar(system.file("shiny", "dashboard", package = "surveyframe")))
})

test_that("the demo's filter items resolve to their labels", {
  ins <- sframe_demo("input_types")$instrument
  expect_identical(unname(sframe_label_lookup(ins)[["visit_type"]]),
                   "Was this your first visit?")
  expect_true(length(sframe_item_value_labels(ins, "visit_type")) > 0)
})

test_that("categorical filters are text, factor or logical columns with 2 to 12 values", {
  d <- data.frame(
    two = rep(c("a", "b"), 7),
    one = rep("a", 14),
    twelve = rep(letters[1:12], length.out = 14),
    thirteen = rep(letters[1:13], length.out = 14),
    flag = rep(c(TRUE, FALSE), 7),
    fac = factor(rep(c("x", "y", "z"), length.out = 14)),
    num = seq_len(14),
    respondent_id = paste0("r", 1:14),
    session_id = rep(c("s1", "s2"), 7),
    stringsAsFactors = FALSE)
  expect_identical(dashboard_categorical_columns(d),
                   c("two", "twelve", "flag", "fac"))
  expect_identical(dashboard_categorical_columns(NULL), character(0))
  expect_identical(dashboard_categorical_columns(1:3), character(0))
})

test_that("the date filter prefers submitted_at, then started_at, then any date column", {
  d <- data.frame(started_at = c("2026-01-02", "2026-01-03"),
                  submitted_at = c("2026-01-05", "2026-01-06"),
                  other = as.Date(c("2026-02-01", "2026-02-02")))
  expect_identical(dashboard_date_column(d), "submitted_at")
  expect_identical(dashboard_date_column(d[c("started_at", "other")]), "started_at")
  expect_identical(dashboard_date_column(d["other"]), "other")
  expect_null(dashboard_date_column(data.frame(x = c("a", "b"))))
  expect_null(dashboard_date_column(NULL))
})

test_that("dashboard_parse_date reads ISO, UK and US dates and gives NA for the rest", {
  out <- dashboard_parse_date(c("2026-01-15T10:30:00Z", "15/01/2026", "", "nope", NA))
  expect_identical(out[1:2], rep(as.Date("2026-01-15"), 2))
  expect_true(all(is.na(out[3:5])))
  expect_identical(dashboard_parse_date(as.Date("2026-03-01")), as.Date("2026-03-01"))
  expect_true(is.na(dashboard_parse_date(1)))
})

test_that("free-text answers never become a filter, however few their values", {
  demo <- sframe_demo("input_types")
  types <- vapply(demo$instrument$items, function(i) i$type, character(1))
  ids <- vapply(demo$instrument$items, function(i) i$id, character(1))
  text_ids <- intersect(ids[types %in% c("text", "textarea")], names(demo$responses))
  expect_true("open_comment" %in% text_ids)
  cols <- dashboard_categorical_columns(demo$responses, demo$instrument)
  expect_length(intersect(cols, text_ids), 0L)
  expect_true("visit_type" %in% cols)
})
