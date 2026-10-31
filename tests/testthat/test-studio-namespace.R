# tests/testthat/test-studio-namespace.R
#
# Naming decision 6. launch_studio() sources SurveyStudio's app.R into an
# environment whose parent is the package namespace, as launch_dashboard()
# does, so the app calls internal helpers directly with no `:::` and no
# copies. Before 0.4.3 it ran app.R through shiny::runApp() on the folder,
# where only exported functions were visible, and the installed app failed
# at start-up when it called an internal one (owner, 2026-10-27). That the
# installed app starts is checked in a browser by
# test-studio-screens-browser.R, which launches it from the build under test.

skip_if_not_installed("shiny")

test_that("SurveyStudio is built in an environment under the namespace", {
  app <- sframe_studio_app()
  expect_s3_class(app, "shiny.appobj")
  server <- app$serverFuncSource()
  expect_identical(parent.env(environment(server)), asNamespace("surveyframe"))
})

test_that("app.R keeps no copies of package helpers", {
  src <- sframe_installed_text("shiny", "app.R")
  # The screen list and the ordered-choice check were written out in 7f846f7.
  expect_no_match(src, "studio_choice_set_ordered", fixed = TRUE)
  expect_no_match(src, "\"quality\", \"reliability\", \"analysis\", \"dashboard\", \"export\"",
                  fixed = TRUE)
  expect_no_match(src, "surveyframe::", fixed = TRUE)
})

test_that("launch_studio() runs the app object, not the folder", {
  seen <- NULL
  local_mocked_bindings(
    runApp = function(appDir, ...) { seen <<- appDir; invisible(NULL) },
    .package = "shiny")
  launch_studio(launch.browser = FALSE)
  expect_s3_class(seen, "shiny.appobj")
  expect_true("sfstudio" %in% names(shiny::resourcePaths()))
})
