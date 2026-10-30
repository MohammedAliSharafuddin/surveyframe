# tests/testthat/test-group-order.R
# D1. A two-group test takes its groups in the declared order: the grouping
# item's choice set as the instrument lists it, then factor levels, then
# sorted values. Row order used to decide it, so re-sorting the responses
# flipped the sign of t.

order_instr <- function() {
  sf_instrument(
    "Group order",
    components = list(
      sf_choices("arm", values = c("treat", "ctrl"),
                 labels = c("Treatment", "Control")),
      sf_item("grp", "Arm", type = "single_choice", choice_set = "arm"),
      sf_item("score", "Score", type = "numeric")
    )
  )
}

order_data <- function() {
  data.frame(grp = rep(c("ctrl", "treat"), each = 6),
             score = c(1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7),
             stringsAsFactors = FALSE)
}

order_block <- function(test) {
  list(id = "RQ1", research_question = "Q", method = test, test = test,
       roles = list(group = "grp", outcome = "score"),
       variables = c("grp", "score"), options = list())
}

test_that("the independent t test follows the choice set, not row order", {
  d <- order_data()
  res <- sframe_run_one_block(order_block("t_test_ind"), d, order_instr())
  expect_equal(res$groups, c("treat", "ctrl"))
  expect_gt(res$t, 0)
  flipped <- sframe_run_one_block(order_block("t_test_ind"), d[nrow(d):1, ],
                                  order_instr())
  expect_equal(flipped$groups, c("treat", "ctrl"))
  expect_equal(flipped$t, res$t)
})

test_that("Mann-Whitney follows the choice set, not row order", {
  d <- order_data()
  res <- sframe_run_one_block(order_block("mann_whitney"), d, order_instr())
  expect_equal(res$groups, c("treat", "ctrl"))
  expect_gt(res$z, 0)
})

test_that("without a choice set the groups are factor levels, then sorted", {
  d <- order_data()
  d$grp <- factor(d$grp, levels = c("treat", "ctrl"))
  expect_equal(sframe_group_order(d$grp), c("treat", "ctrl"))
  expect_equal(sframe_group_order(c("b", "a", "b", NA)), c("a", "b"))
})

test_that("analysis_syntax() writes the order the runner used", {
  res <- sframe_run_one_block(order_block("t_test_ind"), order_data(),
                              order_instr())
  code <- paste(sframe_syntax_call(res), collapse = "\n")
  expect_match(code, 'levels_seen <- c("treat", "ctrl")', fixed = TRUE)
  expect_false(grepl("unique(", code, fixed = TRUE))
})
