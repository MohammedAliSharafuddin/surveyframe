# tests/testthat/test-preview-survey.R
# Naming decision 2, the Preview stage verb. preview_survey(x) shows a survey
# as a respondent meets it, with the collector removed, where x is an
# instrument or a demo name. It replaces preview_demo().

test_that("preview_survey() previews an instrument", {
  ins <- sframe_demo("two_group")$instrument
  path <- preview_survey(ins, open = FALSE)
  expect_true(file.exists(path))
  html <- paste(readLines(path, warn = FALSE), collapse = "\n")
  expect_match(html, ins$meta$title, fixed = TRUE)
})

test_that("preview_survey() previews a demo by name, with the demo branding", {
  path <- preview_survey("two_group", open = FALSE)
  expect_true(file.exists(path))
  html <- paste(readLines(path, warn = FALSE), collapse = "\n")
  expect_match(html, sframe_demo_branding()$welcome$title, fixed = TRUE)
})

test_that("preview_survey() opens SurveyStudio's preview screen on request", {
  skip_if_not_installed("shiny")
  seen <- NULL
  local_mocked_bindings(launch_studio = function(...) {
    seen <<- list(...)
    invisible(NULL)
  })
  ins <- sframe_demo("two_group")$instrument
  preview_survey(ins, where = "studio", open = FALSE)
  expect_identical(seen[[1]], ins)
  expect_identical(seen$screen, "preview")
  expect_false(seen$launch.browser)
})

test_that("preview_survey() rejects what it cannot preview", {
  expect_error(preview_survey("no_such_demo", open = FALSE), "Unknown demo",
               class = "sframe_error")
  expect_error(preview_survey(42, open = FALSE), class = "sframe_error")
  expect_error(preview_survey("two_group", where = "phone", open = FALSE))
})

test_that("preview_demo() forwards and keeps its two_group default", {
  path <- preview_demo(open = FALSE)
  expect_identical(path, preview_survey("two_group", open = FALSE))
})
