# tests/testthat/test-studio-hypotheses.R
# The Analysis Plan screen used to save two fixed sentences as the hypotheses
# of every method that shows them, so the researcher never wrote their own.
# The plan editor now has optional H0 and H1 fields. Only text the researcher
# wrote is saved, and the placeholder examples are never saved.

studio_plan_env <- function() {
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

test_that("nothing written saves no hypotheses", {
  env <- studio_plan_env()
  expect_null(env$studio_build_hypotheses("", "   "))
  expect_null(env$studio_build_hypotheses(NULL, NULL))
})

test_that("only the fields written are saved, trimmed", {
  env <- studio_plan_env()
  expect_identical(
    env$studio_build_hypotheses("  Means do not differ.  ", ""),
    list(null = "Means do not differ.")
  )
  expect_identical(
    env$studio_build_hypotheses("", "Means differ."),
    list(alternative = "Means differ.")
  )
  expect_identical(
    env$studio_build_hypotheses("a", "b"),
    list(null = "a", alternative = "b")
  )
})

test_that("the old fixed sentences load back as unwritten", {
  env <- studio_plan_env()
  old <- list(hypotheses = list(
    null = "No effect or association is present.",
    alternative = "An effect or association is present."))
  expect_identical(env$studio_block_hypothesis(old, "null"), "")
  expect_identical(env$studio_block_hypothesis(old, "alternative"), "")
  written <- list(hypotheses = list(null = "Mine."))
  expect_identical(env$studio_block_hypothesis(written, "null"), "Mine.")
  expect_identical(env$studio_block_hypothesis(written, "alternative"), "")
  expect_identical(env$studio_block_hypothesis(list(), "null"), "")
})

test_that("placeholders are method-appropriate examples with a fallback", {
  env <- studio_plan_env()
  expect_match(env$studio_hypothesis_placeholder("t_test_ind", "null"),
               "does not differ")
  expect_match(env$studio_hypothesis_placeholder("correlation_pearson", "null"),
               "not correlated")
  expect_true(nzchar(env$studio_hypothesis_placeholder("anova_oneway", "alternative")))
  expect_true(nzchar(env$studio_hypothesis_placeholder("unknown", "null")))
})
