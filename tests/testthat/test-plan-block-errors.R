# tests/testthat/test-plan-block-errors.R
#
# Ethos request 6 (2026-10-01). A plan block whose role named an item the
# instrument lacked failed with error "Test failed.", so a host had to
# re-derive the reason itself. A block's error now names its cause: a
# variable the responses lack, a variable that holds no numbers, or too few
# responses.

block_instrument <- function(plan) {
  ins <- sf_instrument("Block errors", components = list(
    sf_item("grp", "Group", type = "single_choice", choice_set = "g"),
    sf_item("score", "Score", type = "numeric"),
    sf_item("other", "Other score", type = "numeric"),
    sf_item("note", "Note", type = "text"),
    sf_item("extra", "Extra", type = "numeric"),
    sf_choices("g", values = c("1", "2"), labels = c("A", "B"))))
  ins$analysis_plan <- plan
  ins
}
blk <- function(method, roles) {
  list(list(id = "RQ1", research_question = "Q", method = method, roles = roles))
}
block_data <- data.frame(grp = c("1", "2", "1", "2"), score = c(1, 2, NA, NA),
                         other = c(2, 1, NA, NA), note = c("a", "b", "c", "d"))
run_block <- function(method, roles) {
  suppressWarnings(run_analysis_plan(block_data, block_instrument(blk(method, roles)),
                                     scored = FALSE))[[1]]
}

test_that("6: a variable the instrument lacks is named", {
  r <- run_block("t_test_ind", list(group = "grp", outcome = "q9"))
  expect_match(r$error, "'q9' is neither an item nor a scale of the instrument",
               fixed = TRUE)
})

test_that("6: an item with no column in the responses is named", {
  r <- run_block("t_test_ind", list(group = "grp", outcome = "extra"))
  expect_match(r$error, "'extra' is an item with no column in the responses",
               fixed = TRUE)
})

test_that("6: a role naming a text item for a numeric test says so", {
  r <- run_block("t_test_ind", list(group = "grp", outcome = "note"))
  expect_match(r$error, "needs numbers, and 'note' holds none", fixed = TRUE)
})

test_that("6: too few responses is reported as such", {
  r <- run_block("correlation_pearson", list(x = "score", y = "other"))
  expect_match(r$error, "^Too few responses")
})

test_that("6: no block reports the bare 'Test failed.'", {
  src <- sframe_source_text("R/analysis_plan.R")
  expect_no_match(src, 'error = "Test failed."', fixed = TRUE)
  expect_no_match(src, 'error = "ANOVA failed."', fixed = TRUE)
  expect_no_match(src, 'error = "Regression failed."', fixed = TRUE)
  stats_src <- sframe_source_text("R/statistics_reports.R")
  expect_no_match(stats_src, 'ANOVA failed."', fixed = TRUE)
})

test_that("6: the expansion columns of a multiple-choice item count as present", {
  expect_null(surveyframe:::sframe_missing_variables_problem(
    "mc", data.frame(mc__a = 1, mc__b = 0), block_instrument(list())))
})

test_that("CX-16: an efa_solution block naming a missing item reports it", {
  r <- run_block("efa_solution", list(items = c("score", "q9")))
  expect_match(r$error, "'q9' is neither an item nor a scale of the instrument",
               fixed = TRUE)
  r <- run_block("efa_solution", list(variables = c("score", "extra")))
  expect_match(r$error, "'extra' is an item with no column in the responses",
               fixed = TRUE)
})
