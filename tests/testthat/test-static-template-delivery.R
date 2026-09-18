# Batch 7 #8: the static survey told a participant their response had been
# recorded before it knew whether it had been delivered.
#
# The POST is no-cors, so the browser never sees the collector's answer and
# acceptance can never be confirmed. A network failure is a different matter:
# fetch rejects, and the template discarded that rejection with an empty
# .catch() and showed the thank-you screen regardless. A configured redirect
# then carried the participant away 2.5 seconds later, with the response in
# nobody's hands.

delivery_instrument <- function() {
  sf_instrument("Delivery", components = list(
    sf_item("q1", "How was it?", type = "text")
  ))
}

submit_with <- function(fails, endpoint = "https://example.com/collect",
                        thankyou = NULL) {
  instr <- delivery_instrument()
  if (!is.null(thankyou)) {
    instr$render <- list(thankyou = thankyou)
  }
  ctx <- static_survey_context(instr, endpoint_url = endpoint)
  ctx$eval(sprintf("__fetchFails = %s;", if (fails) "true" else "false"))
  ctx$eval("responses['q1'] = 'fine'; doSubmit();")
  ctx
}

app_html <- function(ctx) ctx$get("document.getElementById('app').innerHTML")

test_that("8: a failed delivery says so, and keeps the response reachable", {
  skip_if_not_installed("V8")
  ctx <- submit_with(fails = TRUE)

  expect_equal(ctx$get("deliveryState"), "failed")
  html <- app_html(ctx)
  # the claim that it was recorded is gone
  expect_false(grepl("has been recorded", html, fixed = TRUE))
  # and the participant is told, and given both ways out
  expect_match(html, "could not be sent", fixed = TRUE)
  expect_match(html, "Download my response", fixed = TRUE)
  expect_match(html, "Try sending again", fixed = TRUE)
})

test_that("8: a failed delivery cancels the redirect", {
  skip_if_not_installed("V8")
  ctx <- submit_with(fails = TRUE,
                     thankyou = list(redirect_url = "https://example.com/next"))
  ctx$eval("__runTimeouts();")
  expect_equal(ctx$get("window.location.href"), "")
})

test_that("8: retrying sends the same response again", {
  skip_if_not_installed("V8")
  ctx <- submit_with(fails = TRUE)
  expect_equal(ctx$get("__posts.length"), 1)

  ctx$eval("__fetchFails = false; retrySubmission();")
  expect_equal(ctx$get("__posts.length"), 2)
  expect_equal(ctx$get("deliveryState"), "sent")
  # the second attempt carries the same answers
  expect_equal(ctx$get("JSON.parse(__posts[0].body).q1"),
               ctx$get("JSON.parse(__posts[1].body).q1"))
})

test_that("8: a delivery that left the browser reports what it can", {
  skip_if_not_installed("V8")
  ctx <- submit_with(fails = FALSE)
  # "sent" is as much as a no-cors POST can establish: the request left
  # without error, and the collector's answer is unreadable
  expect_equal(ctx$get("deliveryState"), "sent")
  html <- app_html(ctx)
  expect_false(grepl("could not be sent", html, fixed = TRUE))
  expect_false(grepl("Try sending again", html, fixed = TRUE))
})

test_that("8: with no collector the screen still offers the download", {
  skip_if_not_installed("V8")
  ctx <- submit_with(fails = FALSE, endpoint = "")
  expect_equal(ctx$get("deliveryState"), "local")
  expect_equal(ctx$get("__posts.length"), 0)
  expect_match(app_html(ctx), "Download my response", fixed = TRUE)
})

test_that("8: a redirect still runs once delivery leaves the browser", {
  skip_if_not_installed("V8")
  ctx <- submit_with(fails = FALSE,
                     thankyou = list(redirect_url = "https://example.com/next"))
  ctx$eval("__runTimeouts();")
  expect_equal(ctx$get("window.location.href"), "https://example.com/next")
})
