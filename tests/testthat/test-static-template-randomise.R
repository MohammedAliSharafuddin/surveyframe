# tests/testthat/test-static-template-randomise.R
#
# UX-11: a choice set's randomise was set in R and the builder, and the
# survey page never read it. The page now shows a single choice, multiple
# choice or ranking item's options in an order shuffled once per respondent,
# and each option still submits its own value. Run under V8
# (helper-v8-dom.R), with Math.random fixed so the order is known.

rand_instrument <- function(randomise = TRUE) {
  sframe_instrument(
    "Randomise", version = "1.0.0",
    components = list(
      sframe_item("one", "Pick one", type = "single_choice", choice_set = "fruit"),
      sframe_item("many", "Pick any", type = "multiple_choice", choice_set = "fruit"),
      sframe_item("rank", "Rank them", type = "ranking", choice_set = "fruit"),
      sframe_choice_set("fruit", c("a", "b", "c", "d"),
                        c("Apple", "Banana", "Cherry", "Date"), randomise = randomise)))
}

# Math.random returns 0 each time, so the Fisher-Yates shuffle moves the last
# option to the front at every step: a, b, c, d shows as b, c, d, a.
fixed_random <- "Math.random = function(){ return 0; };"

shown_values <- function(html) {
  m <- regmatches(html, gregexpr('(value|data-v)="[a-d]"', html))[[1]]
  unique(sub('^(value|data-v)="([a-d])"$', "\\2", m))
}

test_that("randomise shows the options shuffled, with each value its own", {
  ctx <- static_survey_context(rand_instrument(), pre = fixed_random)
  for (id in c("one", "many", "rank")) {
    expect_identical(shown_values(static_render_item(ctx, id)), c("b", "c", "d", "a"))
  }
  html <- static_render_item(ctx, "one")
  # The label stays with its value.
  expect_match(html, 'value="a"[^>]*>[^<]*<span class="opt-txt">Apple</span>', perl = TRUE)
})

test_that("the order is fixed for the visit, whatever Math.random says later", {
  ctx <- static_survey_context(rand_instrument(), pre = fixed_random)
  first <- shown_values(static_render_item(ctx, "one"))
  ctx$eval("Math.random = function(){ return 0.99; };")
  expect_identical(shown_values(static_render_item(ctx, "one")), first)
})

test_that("a set without randomise keeps its own order", {
  ctx <- static_survey_context(rand_instrument(FALSE), pre = fixed_random)
  for (id in c("one", "many", "rank")) {
    expect_identical(shown_values(static_render_item(ctx, id)), c("a", "b", "c", "d"))
  }
})

test_that("a draft keeps the order, so a resumed visit sees the same", {
  ctx <- static_survey_context(rand_instrument(), pre = fixed_random)
  static_render_item(ctx, "one")
  expect_identical(ctx$get("displayOrders.one"), c(1L, 2L, 3L, 0L))
  src <- sframe_installed_text("inst", "static_survey", "template.html")
  expect_match(src, "order:displayOrders", fixed = TRUE)
  expect_match(src, "if(d.order&&typeof d.order==='object')displayOrders=d.order;", fixed = TRUE)
})
