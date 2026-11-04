# tests/testthat/test-static-template-other.R
#
# UX-11: a choice set's allow_other was set in R and the builder, and the
# survey page never read it. The page now adds "Other, please specify" with
# a text box, last and outside any shuffle. The submitted shape (coordinator,
# 2026-11-04): a single choice submits the code "other" in <id> and the text
# in <id>__other_text, a multiple choice submits <id>__other as 1 or 0 and
# the text in <id>__other_text. Run under V8 (helper-v8-dom.R).

other_instrument <- function(allow_other = TRUE, randomise = FALSE) {
  sframe_instrument(
    "Other", version = "1.0.0",
    components = list(
      sframe_item("one", "How did you hear of us?", type = "single_choice", choice_set = "src"),
      sframe_item("many", "Which did you use?", type = "multiple_choice", choice_set = "src"),
      sframe_choice_set("src", c("web", "friend"), c("Website", "A friend"),
                        allow_other = allow_other, randomise = randomise)))
}

test_that("Other, please specify is the last option, with its text box", {
  ctx <- static_survey_context(other_instrument(randomise = TRUE),
                               pre = "Math.random = function(){ return 0; };")
  for (id in c("one", "many")) {
    html <- static_render_item(ctx, id)
    vals <- regmatches(html, gregexpr('value="[a-z]+"', html))[[1]]
    expect_identical(vals[length(vals)], 'value="other"')
    expect_match(html, "Other, please specify</span>", fixed = TRUE)
    expect_match(html, sprintf('id="other_%s" aria-label="Other, please specify"', id), fixed = TRUE)
  }
  expect_match(static_render_item(ctx, "one"), 'type="radio" name="one" value="other"', fixed = TRUE)
  expect_match(static_render_item(ctx, "many"), 'type="checkbox" name="many" value="other"', fixed = TRUE)
})

test_that("a set without allow_other has no Other option", {
  ctx <- static_survey_context(other_instrument(FALSE))
  expect_false(grepl("Other, please specify", static_render_item(ctx, "one"), fixed = TRUE))
})

test_that("typing in the box chooses Other, and the row has the approved shape", {
  ctx <- static_survey_context(other_instrument())
  ctx$eval("setOther('one', 'A poster', false); setResp('many', 'web'); setOther('many', 'Radio', true);")
  expect_identical(ctx$get("responses.one"), "other")
  expect_identical(ctx$get("responses.many"), "web,other")
  row <- static_submit_row(ctx)
  expect_identical(row$one, "other")
  expect_identical(row$one__other_text, "A poster")
  expect_identical(c(row$many__web, row$many__friend, row$many__other), c("1", "0", "1"))
  expect_identical(row$many__other_text, "Radio")
})

test_that("text typed for an Other later unchosen is not submitted", {
  ctx <- static_survey_context(other_instrument())
  ctx$eval("setOther('one', 'A poster', false); setResp('one', 'web');")
  row <- static_submit_row(ctx)
  expect_identical(row$one, "web")
  expect_identical(row$one__other_text, "")
  expect_identical(row$many__other, "0")
  expect_identical(row$many__other_text, "")
})

test_that("Other chosen with nothing typed blocks the page", {
  ctx <- static_survey_context(other_instrument())
  ctx$eval("setResp('one', 'other');")
  expect_false(static_validate(ctx, "one"))
  expect_identical(static_error_text(ctx, "one"), "Please say what \"Other\" is.")
  ctx$eval("setOther('one', 'A poster', false);")
  expect_true(static_validate(ctx, "one"))
})

test_that("the builder turns Other off for an ordered set", {
  src <- sframe_installed_text("inst", "builder", "survey_builder.html")
  expect_match(src, "if(oth){if(on)oth.checked=false;oth.disabled=on;}", fixed = TRUE)
  expect_match(src, "allow_other:document.getElementById('c-other').checked&&!document.getElementById('c-ord').checked", fixed = TRUE)
})
