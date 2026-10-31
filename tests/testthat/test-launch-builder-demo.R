# tests/testthat/test-launch-builder-demo.R
# Naming principle 5, one way into the demos. launch_builder(demo =) opens
# SurveyBuilder with any sframe_demo() name preloaded, and replaces
# launch_builder_demo().

builder_state_title <- function(path) {
  html <- paste(readLines(path, encoding = "UTF-8", warn = FALSE),
                collapse = "\n")
  state <- regmatches(html, regexpr("var S=\\{\"meta\":.*?\\};", html))
  expect_length(state, 1)
  jsonlite::fromJSON(sub("^var S=", "", sub(";$", "", state)))$meta$title
}

test_that("launch_builder() with no demo still returns the bundled builder", {
  path <- launch_builder(open = FALSE)
  expect_identical(path, system.file("builder", "survey_builder.html",
                                     package = "surveyframe"))
})

test_that("launch_builder(demo =) preloads any demo into a temporary copy", {
  for (nm in c("input_types", "two_group")) {
    path <- launch_builder(demo = nm, open = FALSE)
    expect_true(file.exists(path))
    expect_false(identical(path, launch_builder(open = FALSE)))
    expect_identical(builder_state_title(path),
                     sframe_demo(nm)$instrument$meta$title)
  }
})

test_that("launch_builder(demo =) rejects an unknown demo", {
  expect_error(launch_builder(demo = "no_such_demo", open = FALSE),
               "Unknown demo", class = "sframe_error")
})

test_that("launch_builder_demo() forwards and keeps its old return value", {
  info <- launch_builder_demo(open = FALSE)
  expect_named(info, c("builder_path", "demo_file", "responses_path"))
  expect_identical(builder_state_title(info$builder_path),
                   sframe_demo("input_types")$instrument$meta$title)
  expect_identical(info$demo_file, sframe_demo("input_types")$instrument_path)
})
