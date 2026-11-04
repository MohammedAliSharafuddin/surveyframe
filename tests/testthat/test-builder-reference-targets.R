# tests/testthat/test-builder-reference-targets.R
#
# The builder side of 8b-R's reference targets: a reference can be cited by
# the study and by the hypotheses a plan block declares, as cited_by
# "study" and "hypothesis:<block id>". The builder offers a target only while
# it is there. Run under V8 (helper-v8-builder.R). The targets are checked
# against R's cited_by pattern, and the round trip through validate_sframe()
# is the coordinator's, after the merge with 8b-R's branch.

target_pattern <- "^(instrument|study|(item|scale|plan|model|hypothesis):.+)$"

targets_instrument <- function(study = NULL, hypotheses = NULL) {
  block <- list(id = "rq1", research_question = "Does satisfaction differ by group?",
                family = "group_comparison", method = "t_test_ind", test = "t_test_ind",
                roles = list(outcome = "sat", group = "group"), variables = c("sat", "group"))
  if (!is.null(hypotheses)) block$hypotheses <- hypotheses
  sframe_instrument(
    "Targets", version = "1.0.0",
    components = list(
      sframe_item("sat", "Satisfaction", type = "numeric"),
      sframe_item("group", "Group", type = "single_choice", choice_set = "yn"),
      sframe_choice_set("yn", c("0", "1"), c("No", "Yes"))),
    analysis_plan = list(block), study = study)
}
targets_of <- function(ctx) ctx$get("refTargets().map(function(t){return t.v;})")

test_that("study and hypothesis targets are offered while they are there", {
  ctx <- builder_context()
  builder_open(ctx, targets_instrument(
    study = list(problem = "Why do delegates not return?"),
    hypotheses = list(null = "No difference.", alternative = "A difference.")))
  t <- targets_of(ctx)
  expect_true(all(c("study", "hypothesis:rq1", "plan:rq1", "instrument") %in% t))
  expect_true(all(grepl(target_pattern, t)))
})

test_that("with no study and no hypothesis neither is offered", {
  ctx <- builder_context()
  builder_open(ctx, targets_instrument())
  t <- targets_of(ctx)
  expect_false("study" %in% t)
  expect_false(any(startsWith(t, "hypothesis:")))
  # A block with only blank hypotheses declares none.
  ctx$eval("S.analysis_plan[0].hypotheses = {null: '  ', alternative: ''};")
  expect_false(any(startsWith(targets_of(ctx), "hypothesis:")))
  ctx$eval("S.analysis_plan[0].hypotheses = {alternative: 'Groups differ.'};")
  expect_true("hypothesis:rq1" %in% targets_of(ctx))
  # An empty study is no study.
  ctx$eval("S._carry = S._carry || {}; S._carry.study = {objectives: []};")
  expect_false("study" %in% targets_of(ctx))
})

test_that("a reference added for the study and a hypothesis carries both targets", {
  ctx <- builder_context()
  builder_open(ctx, targets_instrument(
    study = list(problem = "Why?"), hypotheses = list(alternative = "A difference.")))
  ctx$eval("document.getElementById('r-cite').options = [
    {value:'study', selected:true}, {value:'hypothesis:rq1', selected:true}, {value:'plan:rq1', selected:false}];")
  ok <- ctx$eval("String(addRef({id:'smith_2020', type:'article-journal', title:'A study'}))")
  expect_identical(ok, "true")
  refs <- ctx$get("sframePayload().references")
  expect_identical(unlist(refs$cited_by), c("study", "hypothesis:rq1"))
})

test_that("a target cited but no longer there still shows, ticked, to take off", {
  ctx <- builder_context()
  builder_open(ctx, targets_instrument())
  ctx$eval("S.references = [{id:'smith_2020', type:'article-journal', title:'A study', cited_by:['study','hypothesis:rq1']}];")
  ctx$call("renderRefs")
  html <- ctx$get("document.getElementById('refList').innerHTML")
  expect_match(html, 'checked onchange="toggleCite(0,this.value,this.checked)" value="study"', fixed = TRUE)
  expect_match(html, "hypothesis:rq1 (no longer declared)", fixed = TRUE)
})
