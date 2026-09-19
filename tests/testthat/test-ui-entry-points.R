# Batch 7's findings on the researcher-facing entry points.
#
# #22. SurveyStudio's preview gate told a researcher to add an item in "Build
#      Survey", a screen Studio does not have. The Open screen already routes
#      question design to the builder, so the gate contradicted it.
# #23. The RStudio addin called launch_dashboard() with no arguments, and the
#      launcher refuses a missing instrument, so an advertised menu entry
#      produced an error message where a dashboard was expected.

app_source <- function() {
  sframe_installed_text("inst", "shiny", "app.R")
}

test_that("22: the preview gate names a route Studio has", {
  src <- app_source()
  expect_false(grepl("Build Survey", src, fixed = TRUE))
  # it points at the builder, which is where questions are authored
  expect_match(src, "launch_builder()", fixed = TRUE)
})

test_that("22: every screen the app names is one it has", {
  src <- app_source()
  # the tab set the navigation builds, as launch_studio() also validates
  screens <- sframe_studio_screens()
  expect_true(all(vapply(screens, function(s) {
    grepl(paste0('"', s, '"'), src, fixed = TRUE)
  }, logical(1))))
})

test_that("23: the dashboard addin opens a chosen instrument", {
  path <- tempfile(fileext = ".sframe")
  instr <- sf_instrument("Addin", components = list(
    sf_item("q1", "One", type = "numeric")))
  write_sframe(instr, path)

  opened <- NULL
  local_mocked_bindings(
    sframe_addin_choose_sframe = function(...) path,
    launch_dashboard = function(instrument, ...) {
      opened <<- instrument
      invisible(NULL)
    }
  )
  addin_launch_dashboard()
  expect_s3_class(opened, "sframe")
  expect_identical(sf_meta(opened)$title, "Addin")
})

test_that("23: cancelling the chooser launches nothing", {
  launched <- FALSE
  local_mocked_bindings(
    sframe_addin_choose_sframe = function(...) NULL,
    launch_dashboard = function(...) {
      launched <<- TRUE
      invisible(NULL)
    }
  )
  expect_silent(addin_launch_dashboard())
  expect_false(launched)
})

test_that("23: an unreadable file is reported, and nothing launches", {
  bad <- tempfile(fileext = ".sframe")
  writeLines("{ not an instrument", bad)

  launched <- FALSE
  local_mocked_bindings(
    sframe_addin_choose_sframe = function(...) bad,
    launch_dashboard = function(instrument, ...) {
      force(instrument)
      launched <<- TRUE
      invisible(NULL)
    }
  )
  expect_error(addin_launch_dashboard(), class = "sframe_error")
  expect_false(launched)
})
