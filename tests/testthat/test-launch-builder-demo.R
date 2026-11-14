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

# launch_builder(instrument =), Session 10. The copy opens the instrument
# through openSframeText() at start-up, so it is read as an opened file is.
injected_builder_context <- function(path) {
  skip_if_not_installed("V8")
  src <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  blocks <- regmatches(src, gregexpr("(?s)<script>.*?</script>", src, perl = TRUE))[[1]]
  body <- sub("(?s)^<script>", "", blocks[[length(blocks)]], perl = TRUE)
  body <- sub("(?s)</script>$", "", body, perl = TRUE)
  ctx <- V8::v8()
  ctx$assign("__sfData", "{}")
  ctx$assign("__endpoint", "")
  ctx$eval(static_dom_stub)
  ctx$eval(builder_extra_stub)
  # Toasts recorded before the script runs, since the instrument opens at
  # start-up.
  ctx$eval("var __early = []; function toast(m, k){ __early.push({ msg:String(m), kind:k||'' }); }")
  ctx$eval(body)
  ctx
}

test_that("launch_builder(instrument =) opens the instrument and keeps its log on save", {
  ins <- sframe_demo("instrument_revision", preview = FALSE)$instrument
  path <- launch_builder(instrument = ins, open = FALSE)
  expect_true(file.exists(path))
  expect_false(identical(path, system.file("builder", "survey_builder.html", package = "surveyframe")))
  ctx <- injected_builder_context(path)
  expect_identical(ctx$get("S.meta.title"), ins$meta$title)
  expect_identical(ctx$get("S.items.length"), length(ins$items))
  errs <- Filter(function(t) identical(t$kind, "err"), ctx$get("__early", simplifyVector = FALSE))
  expect_length(errs, 0)
  saved <- builder_save(ctx)
  back <- read_sframe(saved)
  expect_identical(length(back$amendments), length(ins$amendments))
  expect_identical(surveyframe:::sframe_content_hash(back), surveyframe:::sframe_content_hash(ins))
})

test_that("launch_builder() takes demo or instrument, not both, and checks the instrument", {
  ins <- sframe_demo("two_group", preview = FALSE)$instrument
  expect_error(launch_builder(demo = "two_group", instrument = ins, open = FALSE),
               "not both", class = "sframe_error")
  expect_error(launch_builder(instrument = list(a = 1), open = FALSE))
})

test_that("an instrument whose text holds </script> cannot close the builder's script", {
  ins <- sframe_demo("two_group", preview = FALSE)$instrument
  ins$meta$description <- "Ends here </script><script>alert(1)</script>"
  path <- launch_builder(instrument = ins, open = FALSE)
  html <- paste(readLines(path, warn = FALSE), collapse = "\n")
  expect_false(grepl("alert(1)</script>", html, fixed = TRUE))
  ctx <- injected_builder_context(path)
  expect_identical(ctx$get("S.meta.description"), ins$meta$description)
})
