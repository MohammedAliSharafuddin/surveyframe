# tests/testthat/test-studio-report-helpers.R
#
# UI-1: what SurveyStudio's Report screen says about the engine and offers as
# reference styles (R/studio_report.R). Studio asked Sys.which("quarto"), so it
# said "no Quarto" where render_report() found the copy bundled with RStudio
# or Positron. It now asks sframe_quarto_find(), as render_report() does.

test_that("the Quarto line names the version and where Quarto was found", {
  found <- list(path = "/opt/quarto/bin/quarto", version = "1.8.24", source = "PATH")
  note <- surveyframe:::sframe_studio_quarto_note(found, use_quarto = TRUE)
  expect_true(note$ok)
  expect_identical(note$text,
    "Quarto 1.8.24, found on the PATH, writes the report in any reference style.")

  bundled <- list(path = "/usr/lib/rstudio/quarto", version = "1.7.3", source = "RStudio")
  expect_match(surveyframe:::sframe_studio_quarto_note(bundled, TRUE)$text,
               "1.7.3, bundled with RStudio", fixed = TRUE)
})

test_that("without Quarto the line names the remedy", {
  none <- list(path = NA_character_, version = NA_character_, source = NA_character_)
  note <- surveyframe:::sframe_studio_quarto_note(none, use_quarto = TRUE)
  expect_false(note$ok)
  expect_match(note$text, "^Quarto was not found")
  expect_match(note$text, "Install Quarto from quarto.org", fixed = TRUE)
  expect_match(note$text, "RStudio or Positron", fixed = TRUE)

  off <- surveyframe:::sframe_studio_quarto_note(none, use_quarto = FALSE)
  expect_match(off$text, "options(surveyframe.use_quarto = FALSE)", fixed = TRUE)
})

test_that("Studio asks sframe_quarto_find(), never Sys.which()", {
  src <- readLines(system.file("shiny", "app.R", package = "surveyframe"))
  expect_false(any(grepl('Sys.which("quarto")', src, fixed = TRUE)))
  expect_true(any(grepl("sframe_studio_quarto_note()", src, fixed = TRUE)))
})
