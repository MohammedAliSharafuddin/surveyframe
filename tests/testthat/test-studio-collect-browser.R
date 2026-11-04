# tests/testthat/test-studio-collect-browser.R
#
# SurveyStudio's Collect screen (session 7): the survey file to deploy, the
# Google Sheets Apps Script collector with its setup steps, and the way on
# to reading the sheet's responses. Driven in a real Chrome against the build
# under test. The downloads are fetched from their links in the page.

test_that("collect is a Studio screen launch_studio() accepts", {
  expect_true("collect" %in% sframe_studio_screens())
  expect_identical(sframe_studio_screen("collect"), "collect")
})

test_that("the Collect screen downloads the survey and its collector", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if_not_installed("shiny")
  skip_if_not_installed("chromote")
  skip_if_not_installed("callr")
  chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
  skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome), "Chrome not found")

  # The child loads the build under test with library(), never load_all().
  libpath <- sframe_build_libpath()
  port <- httpuv::randomPort()
  proc <- callr::r_bg(function(port) {
    library(surveyframe)
    launch_studio(demo = "likert_scale", screen = "collect", port = port,
                  launch.browser = FALSE)
  }, args = list(port), libpath = libpath)
  on.exit(proc$kill(), add = TRUE)
  url <- paste0("http://127.0.0.1:", port)
  for (i in 1:180) {
    up <- tryCatch({ suppressWarnings(readLines(url, n = 1)); TRUE }, error = function(e) FALSE)
    if (up) break
    Sys.sleep(0.5)
  }
  skip_if(!up, "Studio did not start")
  b <- sframe_chrome_session(width = 1280, height = 900)
  on.exit(b$close(), add = TRUE)
  b$Page$navigate(url)
  js <- function(code) {
    b$Runtime$evaluate(code, returnByValue = TRUE, awaitPromise = TRUE)$result$value
  }
  wait <- function(cond) {
    for (i in 1:300) {
      if (isTRUE(tryCatch(js(cond), error = function(e) FALSE))) return(TRUE)
      Sys.sleep(0.5)
    }
    FALSE
  }
  fetch <- function(id) {
    js(paste0("fetch($('#", id, "').attr('href')).then(function(r) { return r.text(); })"))
  }

  expect_true(wait("$('#screen-collect').hasClass('active')"))
  expect_true(wait("!!$('#collect_survey_dl').attr('href') && $('#collect_survey_dl').attr('href') !== '#'"))

  endpoint <- "https://script.google.com/macros/s/TESTDEPLOYMENT/exec"
  sheet <- "https://docs.google.com/spreadsheets/d/TESTSHEET"
  js(paste0("$('#collect_endpoint').val('", endpoint, "').trigger('change'); true"))
  js(paste0("$('#collect_sheet_url').val('", sheet, "').trigger('change'); true"))
  Sys.sleep(1.5)

  survey <- fetch("collect_survey_dl")
  expect_match(survey, "<!doctype html>", ignore.case = TRUE)
  expect_match(survey, endpoint, fixed = TRUE)

  script <- fetch("collect_gs_dl")
  expect_match(script, "doPost", fixed = TRUE)
  expect_match(script, sheet, fixed = TRUE)

  # The steps end on the screen that reads the sheet, with the sheet given.
  steps <- js("$('#screen-collect').text()")
  expect_match(steps, "Who has access", fixed = TRUE)
  js("$('#screen-collect [data-tab=\"responses\"]').first().click(); true")
  expect_true(wait("$('#screen-responses').hasClass('active')"))
  expect_true(wait(paste0("$('#sheet_url').val() === '", sheet, "'")))
})
