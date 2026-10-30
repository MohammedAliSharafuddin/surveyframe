# tests/testthat/test-builder-hypotheses.R
#
# D12. The Plan editor had no hypothesis field, yet saving a test that carries
# hypotheses wrote two fixed sentences the researcher never wrote. The editor
# now has optional H0 and H1 fields, shown for those methods only. Only what
# the researcher typed is saved, and the placeholder examples are never saved.

hyp_instrument <- function() {
  sf_instrument("Hypotheses", components = list(
    sf_item("score", "Score", type = "numeric"),
    sf_item("group", "Group", type = "single_choice",
            choice_set = "yn"),
    sf_choices("yn", values = c("0", "1"), labels = c("No", "Yes"))))
}

# The editor's placeholder animation uses timers the stub DOM lacks.
plan_context <- function() {
  ctx <- builder_context()
  ctx$eval("function clearInterval(){} function clearTimeout(){}
            function setTimeout(){ return 0; }")
  builder_open(ctx, hyp_instrument())
  ctx
}

# Opens a new plan of `method`, types `h0` and `h1` (NULL leaves a field
# alone), saves, and returns the saved plan block as a list.
save_plan_with <- function(ctx, method, h0 = NULL, h1 = NULL) {
  ctx$eval("openRQModal()")
  ctx$assign("m", method)
  ctx$eval("document.getElementById('rq-q').value = 'Does it differ?';
            document.getElementById('rq-test').value = m; onTestChg(false);")
  if (!is.null(h0)) {
    ctx$assign("h0", h0)
    ctx$eval("document.getElementById('rq-h0').value = h0;")
  }
  if (!is.null(h1)) {
    ctx$assign("h1", h1)
    ctx$eval("document.getElementById('rq-h1').value = h1;")
  }
  ctx$eval("saveRQ()")
  jsonlite::fromJSON(ctx$eval("JSON.stringify(S.analysis_plan[S.analysis_plan.length - 1])"),
                     simplifyVector = FALSE)
}

test_that("the hypothesis fields show only for methods that carry hypotheses", {
  ctx <- plan_context()
  ctx$eval("openRQModal()")
  ctx$eval("document.getElementById('rq-test').value = 'mann_whitney'; onTestChg(false);")
  expect_identical(ctx$eval("document.getElementById('rq-hyp-field').style.display"),
                   "block")
  ctx$eval("document.getElementById('rq-test').value = 'frequency'; onTestChg(false);")
  expect_identical(ctx$eval("document.getElementById('rq-hyp-field').style.display"),
                   "none")
})

test_that("placeholders are examples and never saved", {
  src <- readLines(system.file("builder", "survey_builder.html",
                               package = "surveyframe"), warn = FALSE)
  expect_true(any(grepl('id="rq-h0"[^>]*placeholder=', src)))
  expect_true(any(grepl('id="rq-h1"[^>]*placeholder=', src)))
  ctx <- plan_context()
  plan <- save_plan_with(ctx, "mann_whitney")
  expect_null(plan$hypotheses)
})

test_that("a plan with no hypothesis written saves none, not the fixed sentences", {
  ctx <- plan_context()
  plan <- save_plan_with(ctx, "mann_whitney")
  expect_null(plan$hypotheses)
  expect_false(grepl("effect or association", jsonlite::toJSON(plan, auto_unbox = TRUE)))
})

test_that("only the written hypotheses are saved, trimmed", {
  ctx <- plan_context()
  plan <- save_plan_with(ctx, "mann_whitney", h0 = "  Groups do not differ.  ")
  expect_identical(plan$hypotheses, list(null = "Groups do not differ."))
  plan <- save_plan_with(ctx, "mann_whitney", h1 = "Groups differ.")
  expect_identical(plan$hypotheses, list(alternative = "Groups differ."))
  plan <- save_plan_with(ctx, "mann_whitney", h0 = "A.", h1 = "B.")
  expect_identical(plan$hypotheses, list(null = "A.", alternative = "B."))
})

test_that("a saved plan reaches R with the researcher's words", {
  ctx <- plan_context()
  save_plan_with(ctx, "mann_whitney", h0 = "Groups do not differ.",
                 h1 = "Groups differ.")
  ctx$eval("S.analysis_plan[0].roles = {outcome:'score', group:'group'};
            S.analysis_plan[0].variables = ['score', 'group'];")
  back <- read_sframe(builder_save(ctx))
  block <- back$analysis_plan[[1]]
  expect_identical(block$hypotheses$null, "Groups do not differ.")
  expect_identical(block$hypotheses$alternative, "Groups differ.")
})

test_that("the editor loads written hypotheses and treats the old fixed text as empty", {
  ctx <- plan_context()
  save_plan_with(ctx, "mann_whitney", h0 = "Groups do not differ.",
                 h1 = "Groups differ.")
  id <- ctx$eval("S.analysis_plan[0].id")
  ctx$assign("pid", id)
  ctx$eval("openRQModal(pid)")
  expect_identical(ctx$eval("document.getElementById('rq-h0').value"),
                   "Groups do not differ.")
  expect_identical(ctx$eval("document.getElementById('rq-h1').value"),
                   "Groups differ.")
  ctx$eval("S.analysis_plan[0].hypotheses = {null:'No effect or association is present.',
    alternative:'An effect or association is present.'}; openRQModal(pid)")
  expect_identical(ctx$eval("document.getElementById('rq-h0').value"), "")
  expect_identical(ctx$eval("document.getElementById('rq-h1').value"), "")
})

test_that("the plan card shows the written hypotheses", {
  ctx <- plan_context()
  save_plan_with(ctx, "mann_whitney", h0 = "Groups do not differ.")
  html <- ctx$eval("document.getElementById('rqsBody').innerHTML")
  expect_match(html, "Groups do not differ.", fixed = TRUE)
})
