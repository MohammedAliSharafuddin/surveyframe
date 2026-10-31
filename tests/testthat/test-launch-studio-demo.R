# tests/testthat/test-launch-studio-demo.R
# Naming principle 5, one way into the demos. launch_studio(demo =) opens
# SurveyStudio with any sframe_demo() name loaded, and replaces
# launch_studio_demo(). shiny::runApp() is replaced, so nothing starts.

skip_if_not_installed("shiny")

capture_studio <- function(code) {
  seen <- NULL
  local_mocked_bindings(
    runApp = function(...) {
      seen <<- list(
        instrument = shiny::getShinyOption("surveyframe_instrument"),
        responses = shiny::getShinyOption("surveyframe_responses"),
        screen = shiny::getShinyOption("surveyframe_initial_screen"),
        args = list(...))
      invisible(NULL)
    },
    .package = "shiny")
  force(code)
  seen
}

test_that("launch_studio(demo =) loads the demo's instrument and responses", {
  for (nm in c("input_types", "two_group")) {
    seen <- capture_studio(launch_studio(demo = nm, launch.browser = FALSE))
    d <- sframe_demo(nm)
    expect_identical(seen$instrument, d$instrument)
    expect_identical(seen$responses, d$responses)
    expect_identical(seen$screen, "auto")
  }
})

test_that("launch_studio(demo =) passes screen and server settings on", {
  seen <- capture_studio(launch_studio(demo = "two_group", screen = "preview",
                                       port = 4321, launch.browser = FALSE))
  expect_identical(seen$screen, "preview")
  expect_identical(seen$args$port, 4321)
})

test_that("launch_studio() refuses demo together with instrument or responses", {
  d <- sframe_demo("two_group")
  expect_error(launch_studio(instrument = d$instrument, demo = "two_group"),
               "demo", class = "sframe_error")
  expect_error(launch_studio(responses = d$responses, demo = "two_group"),
               "demo", class = "sframe_error")
})

test_that("launch_studio_demo() forwards with the preview screen", {
  seen <- capture_studio(launch_studio_demo(launch.browser = FALSE))
  expect_identical(seen$instrument, sframe_demo("input_types")$instrument)
  expect_identical(seen$screen, "preview")
})

test_that("launch_dashboard() forwards to the Studio dashboard screen", {
  d <- sframe_demo("input_types")
  seen <- capture_studio(launch_dashboard(d$instrument, d$responses,
                                          port = 4322, launch.browser = FALSE))
  expect_identical(seen$instrument, d$instrument)
  expect_identical(seen$responses, d$responses)
  expect_identical(seen$screen, "dashboard")
  expect_identical(seen$args$port, 4322)
})

test_that("launch_dashboard_demo() opens the Studio dashboard with the input_types demo", {
  seen <- capture_studio(launch_dashboard_demo(launch.browser = FALSE))
  expect_identical(seen$instrument, sframe_demo("input_types")$instrument)
  expect_identical(seen$screen, "dashboard")
})

test_that("launch_dashboard() keeps its argument checks", {
  expect_error(launch_dashboard(), "instrument", class = "sframe_error")
  d <- sframe_demo("input_types")
  expect_error(launch_dashboard(d$instrument, responses = 1:3),
               "data.frame", class = "sframe_error")
})
