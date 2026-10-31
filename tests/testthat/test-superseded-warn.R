# tests/testthat/test-superseded-warn.R
# Old names stay silent in 0.4.3. The option turns on one warning per old name
# per session (naming decision 3).

test_that("a superseded name is silent by default", {
  rlang::local_options(surveyframe.warn_superseded = NULL)
  expect_silent(surveyframe:::sframe_superseded("old_a()", "new_a()"))
})

test_that("the option turns on one warning per old name per session", {
  rlang::local_options(surveyframe.warn_superseded = TRUE)
  expect_warning(
    surveyframe:::sframe_superseded("old_b_once()", "new_b()"),
    class = "sframe_superseded_warning"
  )
  expect_silent(surveyframe:::sframe_superseded("old_b_once()", "new_b()"))
  expect_warning(
    surveyframe:::sframe_superseded("old_c_once()", "new_c()"),
    "Use `new_c\\(\\)` instead"
  )
})
