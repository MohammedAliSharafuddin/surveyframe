# tests/testthat/test-builder-plan-tabs.R
#
# UX-17: the Plan mode's tabs said "Run preview" and "Report outline", so
# "preview" named 2 things in the builder. They are "Declared analyses" and
# "Expected outputs", and Preview means the respondent's survey alone.

test_that("the Plan tabs are Declared analyses and Expected outputs", {
  src <- sframe_installed_text("inst", "builder", "survey_builder.html")
  tab <- function(id) regmatches(src, regexpr(
    sprintf("setAnalyseTab\\('%s'\\)\">[^<]*<", id), src))
  expect_identical(tab("run"), "setAnalyseTab('run')\">Declared analyses<")
  expect_identical(tab("report"), "setAnalyseTab('report')\">Expected outputs<")
  expect_false(grepl("Run preview|Report outline|Run queue", src))
})

test_that("each tab's heading names it, and neither calls itself a preview", {
  ctx <- builder_context()
  builder_open(ctx, sframe_references_fixture())
  for (tab in c("run", "report")) {
    ctx$call("setAnalyseTab", tab)
    expect_identical(ctx$get("document.getElementById('anMidTitle').textContent"),
                     if (tab == "run") "Declared analyses" else "Expected outputs")
    expect_false(grepl("preview", ctx$get("document.getElementById('anMidCaption').innerHTML"),
                       ignore.case = TRUE))
  }
})
