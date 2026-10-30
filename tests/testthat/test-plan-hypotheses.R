# tests/testthat/test-plan-hypotheses.R
#
# D12. The plan format carries hypotheses on each block, but neither
# interface had a place to write them, both saved 2 fixed sentences the
# researcher never wrote, and no report printed them. validate_sframe()
# accepted any shape under `hypotheses`.

hyp_instrument <- function(hypotheses = NULL, decision_rule = "",
                           interpretation = NULL) {
  block <- list(id = "RQ1", research_question = "Do the groups differ?",
                family = "group_comparison", method = "t_test_ind",
                roles = list(outcome = "score", group = "grp"),
                decision_rule = decision_rule)
  block$hypotheses <- hypotheses
  block$interpretation <- interpretation
  sf_instrument(title = "Hypotheses", components = list(
    sf_choices("ab", values = c("a", "b"), labels = c("A", "B")),
    sf_item("score", "Score", type = "numeric"),
    sf_item("grp", "Group", type = "single_choice", choice_set = "ab")),
    analysis_plan = list(block))
}

plan_problems <- function(ins) {
  sframe_plan_block_problems(ins$analysis_plan, sframe_dispatch_methods())
}

test_that("D12: hypotheses hold text fields named null and alternative", {
  expect_false(any(grepl("hypotheses", plan_problems(hyp_instrument(
    list(null = "No difference.", alternative = "A difference."))))))
  expect_false(any(grepl("hypotheses", plan_problems(hyp_instrument(
    list(alternative = "A difference."))))))
  expect_true(any(grepl("hypotheses", plan_problems(hyp_instrument(
    "Groups differ.")))))
  expect_true(any(grepl("hypotheses", plan_problems(hyp_instrument(
    list(h0 = "No difference."))))))
  expect_true(any(grepl("hypotheses", plan_problems(hyp_instrument(
    list(null = 1, alternative = c("a", "b")))))))
})
