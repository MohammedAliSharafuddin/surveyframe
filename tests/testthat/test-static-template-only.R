# tests/testthat/test-static-template-only.R
#
# The survey template's show-only mode, which SurveyBuilder's centre pane uses
# to draw the selected item with the template's own renderer (UX-09). Run
# under V8 (helper-v8-dom.R). Only a preview takes the mode: a live survey
# given data-only renders its survey as before.

only_instrument <- function() {
  sframe_instrument(
    "Only", version = "1.0.0",
    components = list(
      sframe_item("intro", "About you", type = "section_break"),
      sframe_item("q1", "How satisfied are you?", type = "likert", choice_set = "agree3"),
      sframe_item("note", "Thank you for these answers.", type = "text_block"),
      sframe_choice_set("agree3", 1:3, c("Disagree", "Neutral", "Agree"))))
}

only_render <- function(id, preview = TRUE) {
  ctx <- static_survey_context(only_instrument(), preview = preview,
                               pre = sprintf("document.body.dataset.only = %s;",
                                             jsonlite::toJSON(id, auto_unbox = TRUE)))
  ctx
}

test_that("a preview with data-only draws that item alone, as the survey does", {
  for (id in c("q1", "intro", "note")) {
    ctx <- only_render(id)
    expect_identical(ctx$get("ONLY_ID"), id)
    ctx$call("renderOnly")
    html <- ctx$get("document.getElementById('app').innerHTML")
    expect_identical(html, paste0('<div class="card"><div class="card-body">',
                                  static_render_item(ctx, id), "</div></div>"))
    expect_identical(ctx$get("document.getElementById('app').attrs.inert"), "")
  }
})

test_that("the welcome and thank-you pages can be shown alone", {
  ctx <- only_render("__welcome")
  ctx$call("renderOnly")
  expect_match(ctx$get("document.getElementById('app').innerHTML"),
               "No welcome page: the survey opens at its first question.", fixed = TRUE)
  ctx <- only_render("__thankyou")
  ctx$call("renderOnly")
  expect_identical(ctx$get("screen"), "thankyou")
})

test_that("a live survey ignores data-only", {
  ctx <- only_render("q1", preview = FALSE)
  expect_identical(ctx$get("ONLY_ID"), "")
})
