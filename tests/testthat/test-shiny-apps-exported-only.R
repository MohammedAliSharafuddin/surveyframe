# tests/testthat/test-shiny-apps-exported-only.R
#
# SurveyStudio's app.R runs through shiny::runApp() in an environment of its
# own, so it sees surveyframe's exported functions and nothing else. 0.4.3's
# References and ordered-choice work called 2 internal functions from it.
# The browser test passed, because it loaded the package with load_all(),
# which exposes internals, and the installed package failed at start-up with
# "could not find function sframe_studio_screens". Found by the owner,
# 2026-10-27, on install_github(). This reads the app's source and lists every
# surveyframe function it calls that the package does not export.

internal_calls <- function(app) {
  src <- paste(readLines(app, warn = FALSE), collapse = "\n")
  # Comments say anything, so they are left out.
  src <- gsub("#[^\n]*", "", src)
  called <- unique(regmatches(src, gregexpr(
    "(?<![A-Za-z0-9_.:$])[A-Za-z_.][A-Za-z0-9_.]*(?=\\()", src, perl = TRUE))[[1]])
  defined <- unique(regmatches(src, gregexpr(
    "[A-Za-z_.][A-Za-z0-9_.]*(?= *<- *function)", src, perl = TRUE))[[1]])
  ns <- asNamespace("surveyframe")
  in_pkg <- called[vapply(called, exists, logical(1), envir = ns, inherits = FALSE)]
  internal <- setdiff(in_pkg, c(getNamespaceExports("surveyframe"), defined))
  internal[!vapply(internal, exists, logical(1), envir = baseenv())]
}

test_that("SurveyStudio's app calls exported functions alone", {
  app <- system.file("shiny", "app.R", package = "surveyframe")
  skip_if(!nzchar(app), "studio app not available")
  expect_identical(internal_calls(app), character(0))
})
