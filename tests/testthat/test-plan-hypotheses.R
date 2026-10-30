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

hyp_data <- data.frame(score = c(3, 4, 5, 6, 2, 3, 4, 7, 8, 6),
                       grp = rep(c("a", "b"), each = 5))

engine_html <- function(ins, data = hyp_data, interpretations = list()) {
  .render_report_analysis_section(ins, data = data, show_code = FALSE,
                                  interpretations = interpretations)
}

before <- function(html, a, b) {
  regexpr(a, html, fixed = TRUE) < regexpr(b, html, fixed = TRUE)
}

test_that("D12: the built-in engine prints the declaration before the result", {
  html <- engine_html(hyp_instrument(
    hypotheses = list(null = "Mean score is equal in both groups.",
                      alternative = "Mean score differs between the groups."),
    decision_rule = "Reject H0 if p < .05."),
    interpretations = list(RQ1 = "The groups differ."))
  expect_match(html, "Null hypothesis (H0):</strong> Mean score is equal", fixed = TRUE)
  expect_match(html, "Alternative hypothesis (H1):</strong> Mean score differs", fixed = TRUE)
  expect_match(html, "Planned decision rule:</strong> Reject H0", fixed = TRUE)
  expect_true(before(html, "Null hypothesis (H0)", "Result:"))
  expect_true(before(html, "Planned decision rule", "Result:"))
  expect_match(html, "Interpretation (written after the results):</strong> The groups differ.",
               fixed = TRUE)
  expect_true(before(html, "Result:", "Interpretation (written after"))
})

test_that("D12: the declaration prints without a written interpretation", {
  html <- engine_html(hyp_instrument(decision_rule = "Reject H0 if p < .05."))
  expect_match(html, "Planned decision rule:</strong> Reject H0", fixed = TRUE)
  html <- engine_html(hyp_instrument(decision_rule = "Reject H0 if p < .05."), data = NULL)
  expect_match(html, "Planned decision rule:</strong> Reject H0", fixed = TRUE)
})

test_that("D12: the 2 fixed sentences earlier interfaces saved are no declaration", {
  html <- engine_html(hyp_instrument(hypotheses = list(
    null = "No effect or association is present.",
    alternative = "An effect or association is present.")))
  expect_no_match(html, "hypothesis (H", fixed = TRUE)
  expect_no_match(html, "No effect or association", fixed = TRUE)
})

test_that("D12: an interpretation never stands in for the decision rule", {
  html <- engine_html(hyp_instrument(interpretation = "Written afterwards."))
  expect_no_match(html, "Planned decision rule", fixed = TRUE)
  expect_match(html, "Interpretation (written after the results):</strong> Written afterwards.",
               fixed = TRUE)
  html <- engine_html(hyp_instrument(interpretation = "Written afterwards."), data = NULL)
  expect_no_match(html, "Planned decision rule", fixed = TRUE)
})

test_that("D12: an interpretation copied from the decision rule is not printed twice", {
  html <- engine_html(hyp_instrument(decision_rule = "Reject H0 if p < .05.",
                                     interpretation = "Reject H0 if p < .05."))
  expect_no_match(html, "Interpretation", fixed = TRUE)
})

declared_instrument <- function(interpretation = NULL) {
  hyp_instrument(
    hypotheses = list(null = "Mean score is equal in both groups.",
                      alternative = "Mean score differs between the groups."),
    decision_rule = "Reject H0 if p < .05.", interpretation = interpretation)
}

test_that("D12: render_results() prints the declaration before each result", {
  ins <- declared_instrument()
  res <- suppressWarnings(run_analysis_plan(hyp_data, ins))
  out <- tempfile(fileext = ".html")
  render_results(res, ins, output_file = out,
                 interpretations = list(RQ1 = "The groups differ."))
  html <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_match(html, "Null hypothesis (H0):</strong> Mean score is equal", fixed = TRUE)
  expect_match(html, "Planned decision rule:</strong> Reject H0", fixed = TRUE)
  expect_true(before(html, "Planned decision rule", "<div class=\"apa-string\">"))
  expect_match(html, "Interpretation (written after the results)", fixed = TRUE)
  expect_true(before(html, "<div class=\"apa-string\">", "The groups differ."))
})

test_that("D12: render_results() never shows the decision rule as the interpretation", {
  ins <- declared_instrument()
  res <- suppressWarnings(run_analysis_plan(hyp_data, ins))
  out <- tempfile(fileext = ".html")
  render_results(res, ins, output_file = out)
  html <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_identical(lengths(regmatches(html, gregexpr("Reject H0 if p", html, fixed = TRUE))), 1L)
  expect_match(html, "Your interpretation will appear here.", fixed = TRUE)
})

test_that("D12: render_result() prints the declaration and a written interpretation", {
  ins <- declared_instrument(interpretation = "The groups differ.")
  res <- suppressWarnings(run_analysis_plan(hyp_data, ins))
  html <- render_result(res[[1]], hyp_data, ins)$html
  expect_match(html, "Alternative hypothesis (H1):</strong> Mean score differs", fixed = TRUE)
  expect_true(before(html, "Planned decision rule", "sf-apa"))
  expect_match(html, "Interpretation (written after the results):</strong> The groups differ.",
               fixed = TRUE)
  expect_true(before(html, "sf-apa", "Interpretation (written"))
})
