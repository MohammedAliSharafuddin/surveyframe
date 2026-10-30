# tests/testthat/test-studio-decision-rule.R
# The plan editor wrote one box into both the decision rule and the
# interpretation of a saved block, so a result carried the planned rule as if
# it were the researcher's reading of the data. The editor now saves the
# decision rule only and keeps any interpretation the block already had.

studio_rule_env <- function() {
  app <- system.file("shiny", "app.R", package = "surveyframe")
  skip_if(!nzchar(app) || !file.exists(app), "studio app not available")
  txt <- readLines(app, warn = FALSE)
  from <- grep("^trim_or_null <- function", txt)[1]
  to   <- grep("^# end studio plan helpers", txt)[1]
  skip_if(is.na(from) || is.na(to), "studio plan helpers not found")
  env <- new.env()
  env$`%||%` <- function(x, y) if (is.null(x)) y else x
  eval(parse(text = paste(txt[from:(to - 1)], collapse = "\n")), envir = env)
  env
}

test_that("a new block gets an empty interpretation", {
  env <- studio_rule_env()
  expect_identical(env$studio_saved_interpretation(list()), "")
})

test_that("an edited block keeps the interpretation it had", {
  env <- studio_rule_env()
  block <- list(decision_rule = "Reject H0 if p < .05.",
                interpretation = "The groups differ.")
  expect_identical(env$studio_saved_interpretation(block), "The groups differ.")
})

test_that("an interpretation identical to the decision rule counts as unwritten", {
  env <- studio_rule_env()
  block <- list(decision_rule = "Reject H0 if p < .05.",
                interpretation = "Reject H0 if p < .05.")
  expect_identical(env$studio_saved_interpretation(block), "")
})

test_that("the plan editor labels its box as the declared decision rule", {
  app <- system.file("shiny", "app.R", package = "surveyframe")
  skip_if(!nzchar(app) || !file.exists(app), "studio app not available")
  txt <- paste(readLines(app, warn = FALSE), collapse = "\n")
  expect_match(txt, "Decision rule (declared now)", fixed = TRUE)
  expect_false(grepl("interpretation = trim_or_null(input$analysis_decision_rule)",
                     txt, fixed = TRUE))
})
