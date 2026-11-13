# M-04 (Fable sitting 2, owner 2026-11-13), Session CF-B: a binary model's
# event is the last declared code (FR-21, glm's convention), so SurveyBuilder's
# Yes/No presets declare No first and new files model Yes. The 2 bundled
# files that declare yes, no keep their order, since their hashes would move.

test_that("the builder's Yes/No templates and its binary set declare no first", {
  ctx <- builder_context()
  expect_identical(ctx$get("PRESET_CHOICE_SETS.yesno.values"), c("no", "yes"))
  expect_identical(ctx$get("PRESET_CHOICE_SETS.yesno.labels"), c("No", "Yes"))
  expect_identical(ctx$get("PRESET_CHOICE_SETS.yesnounsure.values"), c("no", "yes", "unsure"))
  ctx$eval("var __yn = ensureChoiceSet('binary');")
  expect_identical(ctx$get("__yn"), "yes_no")
  expect_identical(ctx$get("S.choices.find(function(c){return c.id==='yes_no';}).values"),
                   c("no", "yes"))
})

test_that("the Yes / No quick-fill button fills No, then Yes", {
  src <- builder_script()
  fill <- regmatches(src, regexpr("function fillYN\\(\\)\\{[^\n]*", src))
  expect_match(fill, "[['no','No'],['yes','Yes']]", fixed = TRUE)
})

test_that("a file declaring yes, no models No, and options$event names Yes", {
  set.seed(4); x <- rnorm(80)
  d <- data.frame(x = x, out = ifelse(x + rlogis(80) > 0, "yes", "no"))
  cs <- sframe_choice_set("yn", c("yes", "no"), c("Yes", "No"))
  it <- sframe_item("out", "Out", type = "single_choice", choice_set = "yn")
  r <- cfb_block(d, "regression_logistic_binary", list(predictors = "x", dependent = "out"),
                 cs, it, cfb_num("x"))
  expect_identical(r$event, "no")
  r2 <- cfb_block(d, "regression_logistic_binary", list(predictors = "x", dependent = "out"),
                  cs, it, cfb_num("x"), options = list(event = "yes"))
  expect_identical(r2$event, "yes")
})
