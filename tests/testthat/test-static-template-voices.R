# tests/testthat/test-static-template-voices.R
#
# D4: the thank-you screen has 2 voices. The package writes one status line
# per delivery state, and the researcher's message sits below it in every
# state except a failed send. The default message claims nothing.

voices_instrument <- function(message = NULL) {
  ins <- sf_instrument("Voices", components = list(
    sf_item("q1", "How was it?", type = "text")))
  ins$render <- list(thankyou = if (!is.null(message)) list(message = message) else list())
  ins
}
voices_html <- function(ctx) ctx$get("document.getElementById('app').innerHTML")
voices_submit <- function(message = NULL, sender = NULL) {
  pre <- if (is.null(sender)) "" else
    paste0("window.sframeSendResponse = function(row){ ", sender, " };")
  ctx <- static_survey_context(voices_instrument(message), pre = pre)
  ctx$eval("responses['q1'] = 'fine'; doSubmit();")
  ctx
}

test_that("D4: no collector and no message claims nothing was recorded", {
  ctx <- voices_submit()
  expect_identical(ctx$get("deliveryState"), "local")
  html <- voices_html(ctx)
  expect_no_match(html, "recorded", fixed = TRUE)
  expect_match(html, "has not been sent", fixed = TRUE)
  expect_match(html, "Thank you for participating.", fixed = TRUE)
})

test_that("D4: a custom message shows in the local state", {
  html <- voices_html(voices_submit("Contact Dr Ames on 0123."))
  expect_match(html, "Contact Dr Ames on 0123.", fixed = TRUE)
  expect_match(html, "has not been sent", fixed = TRUE)
})

test_that("D4: a custom message shows in the confirmed state, under the status", {
  ctx <- voices_submit("Debrief text.", sender = "return Promise.resolve(true);")
  expect_identical(ctx$get("deliveryState"), "confirmed")
  html <- voices_html(ctx)
  expect_match(html, "has been recorded", fixed = TRUE)
  expect_match(html, "Debrief text.", fixed = TRUE)
  expect_lt(regexpr("has been recorded", html, fixed = TRUE),
            regexpr("Debrief text.", html, fixed = TRUE))
})

test_that("D4: the sent state, as a Sheets endpoint reaches it, keeps the message", {
  ctx <- voices_submit("Debrief text.", sender = "return Promise.resolve(false);")
  expect_identical(ctx$get("deliveryState"), "sent")
  html <- voices_html(ctx)
  expect_match(html, "cannot confirm", fixed = TRUE)
  expect_match(html, "Debrief text.", fixed = TRUE)
})

test_that("D4: a failed send hides the custom message", {
  ctx <- voices_submit("Debrief text.", sender = "return Promise.reject(new Error('x'));")
  expect_identical(ctx$get("deliveryState"), "failed")
  html <- voices_html(ctx)
  expect_no_match(html, "Debrief text.", fixed = TRUE)
  expect_match(html, "could not be sent", fixed = TRUE)
  expect_match(html, "Try sending again", fixed = TRUE)
})

test_that("D4: a preview says nothing was sent", {
  ctx <- static_survey_context(voices_instrument("Debrief text."), preview = TRUE)
  ctx$eval("responses['q1'] = 'fine'; doSubmit();")
  html <- voices_html(ctx)
  expect_match(html, "Nothing was sent", fixed = TRUE)
  expect_no_match(html, "no online collector", fixed = TRUE)
})
