# tests/testthat/test-builder-narrow.R
#
# UX-01, UX-08: on a narrow screen SurveyBuilder's Design shows 1 pane at a
# time, the question list, then the editor with its live preview and a Back
# control. The layout is checked at 390 x 844 in a real Chrome in
# test-builder-ui2-browser.R. This checks the state that drives it, under V8.

test_that("opening a question marks the page as editing, and Back clears it", {
  ctx <- builder_context()
  builder_open(ctx, sframe_demo("first_survey")$instrument)
  id <- ctx$get("S.items[0].id")
  ctx$call("selItem", id)
  expect_true(ctx$get("document.body.classList.contains('editing')"))
  ctx$call("inspBack")
  expect_false(ctx$get("document.body.classList.contains('editing')"))
  expect_null(ctx$get("selId"))
  ctx$call("setMode", "analyse")
  expect_identical(ctx$get("document.body.dataset.mode"), "analyse")
})

test_that("the narrow layout is a media rule over those states", {
  src <- sframe_installed_text("inst", "builder", "survey_builder.html")
  expect_match(src, '<body data-mode="build">', fixed = TRUE)
  expect_match(src, "@media (max-width:760px){", fixed = TRUE)
  expect_match(src, 'body:not([data-mode="build"]) .sidebar,body.editing .sidebar{display:none}', fixed = TRUE)
  expect_match(src, 'body[data-mode="build"]:not(.editing) .main{display:none}', fixed = TRUE)
})
