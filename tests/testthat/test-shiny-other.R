# tests/testthat/test-shiny-other.R
#
# UI-1, from session O: the Shiny survey carried the Other columns of a choice
# set with allow_other but never drew the option or its text box. It now draws
# them as the static survey does (UI-2's b11e460), with the same submitted
# shape: a single choice gives the code "other" in <id> and the text in
# <id>__other_text, a multiple choice gives <id>__other as 1 or 0 and the text
# in <id>__other_text. Other chosen with nothing typed stops the submission.
# The browser proof is in test-shiny-respondent-browser.R.

skip_if_not_installed("shiny")

so_instrument <- function(allow_other = TRUE) {
  sframe_instrument(title = "Other", components = list(
    sframe_choice_set("src", 1:2, c("Website", "A friend"),
                      allow_other = allow_other),
    sframe_item("heard", "Where did you hear of us?", "single_choice",
                choice_set = "src"),
    sframe_item("used", "Which have you used?", "multiple_choice",
                choice_set = "src")
  ))
}

so_html <- function(instrument, inputs = list()) {
  html <- NULL
  shiny::testServer(run_survey(instrument), {
    if (length(inputs)) do.call(session$setInputs, inputs)
    html <<- as.character(output$survey_ui$html)
  })
  html
}

so_tags <- function(html, pattern) {
  regmatches(html, gregexpr(pattern, html, perl = TRUE))[[1]]
}

test_that("a set with allow_other draws Other last, with its text box", {
  html <- so_html(so_instrument())

  for (id in c("heard", "used")) {
    opts <- so_tags(html, sprintf('<input[^>]*name="%s"[^>]*>', id))
    expect_length(opts, 3)
    expect_match(opts[3], 'value="other"', fixed = TRUE)
    box <- so_tags(html, sprintf('<input[^>]*id="%s__other_text"[^>]*>', id))
    expect_length(box, 1)
    expect_match(box, 'aria-label="Other, please specify"', fixed = TRUE)
  }
  expect_match(html, "Other, please specify</span>", fixed = TRUE)
})

test_that("a set without allow_other draws no Other option", {
  html <- so_html(so_instrument(FALSE))

  expect_false(grepl('value="other"', html, fixed = TRUE))
  expect_false(grepl("__other_text", html, fixed = TRUE))
})

test_that("the typed Other text is drawn back into its box", {
  html <- so_html(so_instrument(),
                  list(heard = "other", heard__other_text = "A podcast"))
  box <- so_tags(html, '<input[^>]*id="heard__other_text"[^>]*>')

  expect_match(box, 'value="A podcast"', fixed = TRUE)
})

test_that("the submitted row has the static survey's Other shape", {
  row <- NULL
  app <- run_survey(so_instrument(), on_submit = function(r) row <<- r)
  shiny::testServer(app, {
    session$setInputs(heard = "other", heard__other_text = "A podcast",
                      used = c("1", "other"), used__other_text = "A newsletter")
    session$setInputs(submit_btn = 1)
  })

  expect_identical(as.character(row$heard), "other")
  expect_identical(as.character(row$heard__other_text), "A podcast")
  expect_identical(as.character(row$used__1), "1")
  expect_identical(as.character(row$used__2), "0")
  expect_identical(as.character(row$used__other), "1")
  expect_identical(as.character(row$used__other_text), "A newsletter")
})

test_that("Other chosen with nothing typed stops the submission", {
  row <- NULL
  app <- run_survey(so_instrument(), on_submit = function(r) row <<- r)
  shiny::testServer(app, {
    session$setInputs(heard = "other", heard__other_text = "  ")
    session$setInputs(submit_btn = 1)
  })
  expect_null(row)

  inst <- so_instrument()
  bl <- surveyframe:::sframe_branch_lookup(inst)
  vals <- list(heard = "1", used = "other", used__other_text = "")
  gaps <- surveyframe:::sframe_other_unspecified_items(inst, inst$items, vals, bl)
  expect_identical(vapply(gaps, function(i) i$id, character(1)), "used")
  expect_match(surveyframe:::sframe_other_unspecified_message(gaps),
               "Which have you used?", fixed = TRUE)
})

test_that("the embedded survey module draws Other as well", {
  ui <- as.character(surveyframe:::sf_mod_survey(
    so_instrument(), 1L, list(), shiny::NS("m"), "sf1_"))

  expect_match(ui, 'id="m-sf1_heard__other_text"', fixed = TRUE)
  expect_match(ui, 'name="m-sf1_used"[^>]*value="other"', perl = TRUE)
})
