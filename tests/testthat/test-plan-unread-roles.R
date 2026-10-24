# tests/testthat/test-plan-unread-roles.R
#
# Ethos request 11 (2026-10-01). A frequency block naming its item under a
# role the method does not read ran on nothing and returned "Frequency
# distribution for NA (N = 0)" with an empty table and no error.
# validate_sframe() accepted the block. 0.4.3 taught frequency to read
# `variables` as well as `variable`, which mended the 3 demos Ethos found,
# but any other role name still ran on nothing.

one_choice_instrument <- function(roles, method = "frequency") {
  sf_instrument("Roles", components = list(
    sf_item("q1", "Preferred format", type = "single_choice", choice_set = "fmt"),
    sf_item("q2", "Satisfaction", type = "numeric"),
    sf_item("q3", "Value", type = "numeric"),
    sf_item("q4", "Age", type = "numeric"),
    sf_choices("fmt", values = c("1", "2"), labels = c("Online", "In person"))
  ), analysis_plan = list(list(
    id = "RQ1", research_question = "Which format?", method = method,
    roles = roles
  )))
}

responses <- data.frame(q1 = c("1", "2", "1", "1", "2", "2", "1", "2"),
                        q2 = c(3, 4, 5, 2, 4, 5, 3, 4),
                        q3 = c(2, 4, 4, 1, 5, 5, 3, 3),
                        q4 = c(30, 41, 25, 52, 36, 44, 29, 38))

test_that("11: the validator refuses a block whose roles its method never reads", {
  v <- validate_sframe(one_choice_instrument(list(items = "q1")), strict = FALSE)
  expect_false(v$valid)
  problems <- unlist(v$problems)
  expect_match(problems, "Analysis plan 'RQ1' gives no variables", fixed = TRUE,
               all = FALSE)
  expect_match(problems, "reads the roles variables or variable", fixed = TRUE,
               all = FALSE)
  expect_match(problems, "the block names items", fixed = TRUE, all = FALSE)
})

test_that("11: such a block reports an error, not a result on N = 0", {
  ins <- one_choice_instrument(list(items = "q1"))
  res <- run_analysis_plan(responses, ins)
  expect_match(res[[1]]$error, "No variables to analyse", fixed = TRUE)
  expect_match(res[[1]]$error, "'frequency'", fixed = TRUE)
  expect_null(res[[1]]$n)
})

test_that("11: both roles frequency reads validate and run", {
  for (role in c("variable", "variables")) {
    ins <- one_choice_instrument(stats::setNames(list("q1"), role))
    expect_true(validate_sframe(ins, strict = FALSE)$valid)
    res <- run_analysis_plan(responses, ins)
    expect_null(res[[1]]$error)
    expect_gt(sum(res[[1]]$table$Frequency), 0)
  }
})

test_that("11: the 3 demos Ethos found run their frequency block on data", {
  for (demo in c("first_survey", "instrument_revision", "verification")) {
    d <- sframe_demo(demo)
    res <- run_analysis_plan(d$responses, d$instrument)
    rq1 <- Filter(function(r) identical(r$block_id, "RQ1"), res)[[1]]
    expect_null(rq1$error)
    expect_gt(sum(rq1$table$Frequency), 0)
  }
})

test_that("the resolver reads every role alias the partial correlation runner reads", {
  ins <- one_choice_instrument(list(predictor = "q2", outcome = "q3"),
                               method = "partial_correlation")
  ins$analysis_plan[[1]]$roles$control <- "q4"
  expect_true(validate_sframe(ins, strict = FALSE)$valid)
  expect_setequal(surveyframe:::sframe_method_role_names("partial_correlation"),
                  c("x", "predictor", "y", "outcome", "dependent",
                    "controls", "control", "covariates"))
})

test_that("an instrument-level method with no roles is left alone", {
  expect_length(surveyframe:::sframe_method_role_names("reliability_alpha"), 0L)
  expect_null(surveyframe:::sframe_unread_roles_problem(
    "reliability_alpha", list(scales = "s1"), list()))
})
