# tests/testthat/test-demo-screens.R
#
# Ethos request 3 (2026-10-01). 19 of the 22 demos carried an empty render,
# so a respondent saw no welcome, consent or thank-you screen, and Ethos
# added them by amendment whenever a researcher opened an example.

test_that("3: every demo has a welcome screen asking for consent, and a thank-you", {
  for (demo in sframe_demos()$name) {
    r <- sframe_demo(demo)$instrument$render
    expect_true(nzchar(r$welcome$title %||% ""), info = demo)
    expect_true(nzchar(r$welcome$consent_text %||% ""), info = demo)
    expect_true(nzchar(r$thankyou$message %||% ""), info = demo)
  }
})

test_that("3: the unbranded demos keep the default look", {
  r <- sframe_demo("two_group")$instrument$render
  expect_identical(r$welcome$title, sframe_demo("two_group")$instrument$meta$title)
  expect_true(isTRUE(r$welcome$consent_required))
  expect_null(r$theme)
  expect_null(r$header)
  # branded = TRUE still replaces the whole block.
  expect_identical(sframe_demo("two_group", branded = TRUE)$instrument$render,
                   unclass(sframe_demo_branding()))
})
