# tests/testthat/test-shiny-delivery-status.R
#
# D4 in Shiny (session 1 follow-up 4). The module's thank-you screen said
# "Your response has been recorded." whether or not anything was stored, and
# render_survey() said "Submitted successfully". A module with no on_submit,
# or render_survey() with save_responses = "none", stores nothing. The status
# line now comes from what the submission did with the answers: written to
# the CSV, handed to on_submit, or neither. The researcher's message sits
# below it, as in the static survey.

skip_if_not_installed("shiny")

status_instrument <- function(message = NULL) {
  ins <- sf_instrument(title = "Status", components = list(
    sf_item("t1", "Comment", "text")))
  if (!is.null(message)) ins$render$thankyou$message <- message
  ins
}

test_that("the persist step reports what it did with the answers", {
  row <- data.frame(t1 = "a")
  path <- tempfile(fileext = ".csv")
  expect_identical(sframe_persist_response(row, path, NULL, NULL)$outcome, "written")
  expect_identical(sframe_persist_response(row, NULL, function(r) NULL, NULL)$outcome,
                   "handed")
  expect_identical(sframe_persist_response(row, NULL, NULL, NULL)$outcome, "none")
})

module_thankyou <- function(on_submit = NULL, message = NULL) {
  html <- NULL
  shiny::testServer(survey_module_server,
                    args = list(instrument = status_instrument(message),
                                on_submit = on_submit), {
    session$setInputs(sf_start = 1)
    session$setInputs(sf_next = 1)
    html <<- as.character(output$survey_ui$html)
  })
  html
}

test_that("a module that stores nothing says so, above the researcher's message", {
  html <- module_thankyou(message = "Debrief text.")
  expect_match(html, "Your response has not been saved.", fixed = TRUE)
  expect_no_match(html, "recorded", fixed = TRUE)
  expect_match(html, "Debrief text.", fixed = TRUE)
  expect_lt(regexpr("not been saved", html), regexpr("Debrief text", html))
})

test_that("a module with on_submit says the response was handed on", {
  html <- module_thankyou(on_submit = function(r) NULL)
  expect_match(html, "Your response has been submitted.", fixed = TRUE)
  expect_match(html, "Thank you for participating.", fixed = TRUE)
})

app_thankyou <- function(...) {
  app <- render_survey(status_instrument("Debrief text."), ...)
  html <- NULL
  shiny::testServer(app, {
    session$setInputs(start_btn = 1)
    session$setInputs(submit_btn = 1)
    html <<- as.character(output$survey_ui$html)
  })
  html
}

test_that("render_survey() states delivery on its thank-you screen", {
  html <- app_thankyou()
  expect_match(html, "Your response has not been saved.", fixed = TRUE)
  expect_no_match(html, "Submitted successfully", fixed = TRUE)
  expect_match(html, "Debrief text.", fixed = TRUE)

  html <- app_thankyou(save_responses = "csv",
                       output_path = tempfile(fileext = ".csv"))
  expect_match(html, "Your response has been recorded.", fixed = TRUE)
})
