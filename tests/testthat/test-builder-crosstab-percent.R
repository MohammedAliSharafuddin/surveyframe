# tests/testthat/test-builder-crosstab-percent.R
#
# UX-02: a cross-tab or chi-square plan block carries options$percent (row,
# column or total), and the builder's plan dialog is where it is set. Run
# under V8 (helper-v8-builder.R). The options are read from the builder's
# state, since the V8 page has no role selects for read_sframe() to accept.

pct_context <- function(percent = NULL, method = "crosstab") {
  opts <- if (is.null(percent)) list() else list(percent = percent)
  ins <- sframe_instrument(
    "Percent", version = "1.0.0",
    components = list(
      sframe_item("a", "A", type = "single_choice", choice_set = "yn"),
      sframe_item("b", "B", type = "single_choice", choice_set = "yn"),
      sframe_choice_set("yn", c("0", "1"), c("No", "Yes"))),
    analysis_plan = list(list(
      id = "ct", research_question = "Are A and B related?", family = "descriptive",
      method = method, test = method, roles = list(row = "a", column = "b"),
      variables = c("a", "b"), options = opts)))
  ctx <- builder_context()
  ctx$eval("function clearInterval(){} function clearTimeout(){}
            function setTimeout(){ return 0; }")
  builder_open(ctx, ins)
  ctx
}
pct_saved <- function(ctx) ctx$get("S.analysis_plan[0].options.percent || null")

test_that("the dialog shows a block's percentages and keeps them on save", {
  ctx <- pct_context("column")
  ctx$call("openRQModal", "ct")
  expect_identical(ctx$get("document.getElementById('rq-pct').value"), "column")
  expect_identical(ctx$get("document.getElementById('rq-pct-field').style.display"), "block")
  ctx$call("saveRQ")
  expect_identical(pct_saved(ctx), "column")
})

test_that("the dialog sets and clears the percentages", {
  ctx <- pct_context(method = "chi_square")
  ctx$call("openRQModal", "ct")
  expect_identical(ctx$get("document.getElementById('rq-pct').value"), "")
  ctx$eval("document.getElementById('rq-pct').value = 'row';")
  ctx$call("saveRQ")
  expect_identical(pct_saved(ctx), "row")
  ctx$call("openRQModal", "ct")
  ctx$eval("document.getElementById('rq-pct').value = '';")
  ctx$call("saveRQ")
  expect_null(pct_saved(ctx))
})

test_that("other methods show no percentage choice and write none", {
  ctx <- pct_context()
  ctx$call("openRQModal", "ct")
  ctx$eval("document.getElementById('rq-test').value = 'fisher_exact'; onTestChg(false);
            document.getElementById('rq-pct').value = 'total';")
  expect_identical(ctx$get("document.getElementById('rq-pct-field').style.display"), "none")
  ctx$call("saveRQ")
  expect_null(pct_saved(ctx))
})
