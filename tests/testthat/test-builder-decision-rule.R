# tests/testthat/test-builder-decision-rule.R
#
# One text box was saved into both decision_rule and interpretation, so a rule
# declared before data collection read back as a finished interpretation. The
# Plan editor now saves the decision rule only. The results screen shows the
# rule read-only and offers a separate interpretation box once results exist,
# which saves interpretation only.

rule_instrument <- function() {
  sf_instrument("Rule", components = list(
    sf_item("score", "Score", type = "numeric"),
    sf_item("age", "Age", type = "numeric")))
}

rule_context <- function() {
  ctx <- builder_context()
  ctx$eval("function clearInterval(){} function clearTimeout(){}
            function setTimeout(){ return 0; }")
  builder_open(ctx, rule_instrument())
  ctx
}

# Saves a new plan through the editor with `rule` typed in the decision rule
# box, and returns the saved block.
save_plan_rule <- function(ctx, rule) {
  ctx$assign("rule", rule)
  ctx$eval("openRQModal();
    document.getElementById('rq-q').value = 'Are they related?';
    document.getElementById('rq-test').value = 'correlation_pearson';
    onTestChg(false);
    document.getElementById('rq-interp').value = rule; saveRQ();")
  jsonlite::fromJSON(ctx$eval("JSON.stringify(S.analysis_plan[S.analysis_plan.length - 1])"),
                     simplifyVector = FALSE)
}

test_that("the editor labels the box as the rule declared now and saves decision_rule only", {
  src <- readLines(system.file("builder", "survey_builder.html",
                               package = "surveyframe"), warn = FALSE)
  expect_true(any(grepl("Decision rule (declared now)", src, fixed = TRUE)))
  ctx <- rule_context()
  plan <- save_plan_rule(ctx, "  Reject H0 when p < .05.  ")
  expect_identical(plan$decision_rule, "Reject H0 when p < .05.")
  expect_true(is.null(plan$interpretation) || identical(plan$interpretation, ""))
})

test_that("the editor loads the rule from decision_rule, and from interpretation for an old file", {
  ctx <- rule_context()
  ctx$eval("S.analysis_plan = [{id:'a', research_question:'q', method:'correlation_pearson',
    test:'correlation_pearson', roles:{x:'score', y:'age'}, decision_rule:'Rule A.',
    interpretation:'Words A.'},
    {id:'b', research_question:'q', method:'correlation_pearson',
    test:'correlation_pearson', roles:{}, interpretation:'Old rule.'}];")
  ctx$eval("openRQModal('a')")
  expect_identical(ctx$eval("document.getElementById('rq-interp').value"), "Rule A.")
  ctx$eval("openRQModal('b')")
  expect_identical(ctx$eval("document.getElementById('rq-interp').value"), "Old rule.")
})

test_that("saving a plan keeps an interpretation already written", {
  ctx <- rule_context()
  ctx$eval("S.analysis_plan = [{id:'a', research_question:'q', method:'correlation_pearson',
    test:'correlation_pearson', roles:{}, decision_rule:'Rule A.',
    interpretation:'Words A.'}]; openRQModal('a'); saveRQ();")
  expect_identical(ctx$eval("S.analysis_plan[0].interpretation"), "Words A.")
  expect_identical(ctx$eval("S.analysis_plan[0].decision_rule"), "Rule A.")
})

test_that("the results screen shows the rule read-only and no interpretation box before results", {
  ctx <- rule_context()
  save_plan_rule(ctx, "Reject H0 when p < .05.")
  html <- ctx$eval("reportSkeletonHtml(S.analysis_plan)")
  expect_match(html, "Reject H0 when p &lt; .05.", fixed = TRUE)
  expect_false(grepl("<textarea id=\"rsRule", html, fixed = TRUE))
  expect_false(grepl("oninput=\"updatePlanInterp", html, fixed = TRUE))
  expect_false(grepl("rsInterp_0", html, fixed = TRUE))
})

test_that("once results exist an interpretation box saves interpretation only", {
  ctx <- rule_context()
  save_plan_rule(ctx, "Reject H0 when p < .05.")
  ctx$eval("S.analysis_plan[0].result = {statistic: 1.2};")
  html <- ctx$eval("reportSkeletonHtml(S.analysis_plan)")
  expect_match(html, "oninput=\"updatePlanInterp", fixed = TRUE)
  expect_match(html, "for=\"rsInterp_0\">Interpretation</label>", fixed = TRUE)
  ctx$eval("updatePlanInterp(S.analysis_plan[0].id, '  The link is weak.  ')")
  expect_identical(ctx$eval("S.analysis_plan[0].interpretation"), "The link is weak.")
  expect_identical(ctx$eval("S.analysis_plan[0].decision_rule"),
                   "Reject H0 when p < .05.")
})

test_that("an interpretation identical to the rule counts as unwritten", {
  ctx <- rule_context()
  ctx$eval("S.analysis_plan = [{id:'a', research_question:'q', method:'correlation_pearson',
    test:'correlation_pearson', roles:{}, decision_rule:'Same.', interpretation:'Same.',
    result:{statistic:1}}];")
  html <- ctx$eval("reportSkeletonHtml(S.analysis_plan)")
  expect_match(html, "<textarea id=\"rsInterp_0\"[^>]*></textarea>")
})
