# tests/testthat/test-static-template-host-delivery.R
#
# Ethos request 7 (2026-10-01). The static template posts no-cors, so it can
# never read the collector's answer. Every respondent was told the page could
# not confirm storage, even on a host that confirms. The thank-you screen said
# "recorded" while the send was still in flight, "Submit another response"
# could not be hidden, and a closed tab lost every answer.

host_instrument <- function(render = list()) {
  ins <- sf_instrument("Delivery", components = list(
    sf_item("q1", "How was it?", type = "text"),
    sf_item("q2", "Anything else?", type = "text")))
  ins$render <- render
  ins
}
app_html <- function(ctx) ctx$get("document.getElementById('app').innerHTML")
memory_storage <- "window.localStorage = { _d:{},
  getItem:function(k){ return this._d.hasOwnProperty(k) ? this._d[k] : null; },
  setItem:function(k,v){ this._d[k] = String(v); },
  removeItem:function(k){ delete this._d[k]; } };"

test_that("7: a send in flight shows a sending screen, never 'recorded'", {
  ctx <- static_survey_context(host_instrument(),
    pre = "window.sframeSendResponse = function(row){ return new Promise(function(){}); };")
  ctx$eval("responses['q1'] = 'fine'; doSubmit();")
  expect_identical(ctx$get("deliveryState"), "sending")
  html <- app_html(ctx)
  expect_match(html, "Sending your answers", fixed = TRUE)
  expect_no_match(html, "recorded", fixed = TRUE)
})

test_that("7: a host that confirms delivery is shown as recorded", {
  ctx <- static_survey_context(host_instrument(),
    pre = "window.__sent = null; window.sframeSendResponse = function(row){ window.__sent = row; return Promise.resolve({confirmed: true}); };")
  ctx$eval("responses['q1'] = 'fine'; doSubmit();")
  expect_identical(ctx$get("deliveryState"), "confirmed")
  expect_identical(ctx$get("window.__sent.q1"), "fine")
  html <- app_html(ctx)
  expect_match(html, "has been recorded", fixed = TRUE)
  expect_no_match(html, "cannot confirm", fixed = TRUE)
  expect_match(html, "Submit another response", fixed = TRUE)
})

test_that("7: a host that cannot confirm is unconfirmed, and a rejection fails", {
  ctx <- static_survey_context(host_instrument(),
    pre = "window.sframeSendResponse = function(row){ return Promise.resolve(false); };")
  ctx$eval("responses['q1'] = 'fine'; doSubmit();")
  expect_identical(ctx$get("deliveryState"), "sent")
  expect_match(app_html(ctx), "cannot confirm", fixed = TRUE)
  ctx2 <- static_survey_context(host_instrument(),
    pre = "window.sframeSendResponse = function(row){ return Promise.reject(new Error('down')); };")
  ctx2$eval("responses['q1'] = 'fine'; doSubmit();")
  expect_identical(ctx2$get("deliveryState"), "failed")
})

test_that("7: thankyou$show_restart = FALSE hides Submit another response", {
  ctx <- static_survey_context(host_instrument(list(thankyou = list(show_restart = FALSE))),
    pre = "window.sframeSendResponse = function(row){ return Promise.resolve(true); };")
  ctx$eval("responses['q1'] = 'fine'; doSubmit();")
  expect_no_match(app_html(ctx), "Submit another response", fixed = TRUE)
})

test_that("7: with save_draft, answers survive a closed tab and resume", {
  render <- list(save_draft = TRUE,
                 welcome = list(title = "Hi", intro_text = "Welcome."))
  ctx <- static_survey_context(host_instrument(render), pre = memory_storage)
  ctx$eval("startSurvey(); responses['q1'] = 'half done'; saveDraft();")
  stored <- ctx$get("window.localStorage._d")
  expect_length(stored, 1L)

  # A new page load in the same browser: the storage carries over.
  ctx2 <- static_survey_context(host_instrument(render),
    pre = paste0(memory_storage, sprintf(" window.localStorage._d = %s;",
                                         jsonlite::toJSON(stored, auto_unbox = TRUE))))
  ctx2$eval("renderScreen();")
  expect_match(app_html(ctx2), "Resume where you left off", fixed = TRUE)
  ctx2$eval("resumeDraft();")
  expect_identical(ctx2$get("screen"), "survey")
  expect_identical(ctx2$get("responses.q1"), "half done")

  # Submitting clears it.
  ctx2$eval("responses['q2'] = 'done'; doSubmit();")
  expect_length(ctx2$get("Object.keys(window.localStorage._d)"), 0L)
})

test_that("7: drafts stay off unless the instrument asks for them", {
  ctx <- static_survey_context(host_instrument(), pre = memory_storage)
  ctx$eval("startSurvey(); responses['q1'] = 'x'; saveDraft();")
  expect_length(ctx$get("Object.keys(window.localStorage._d)"), 0L)
})
