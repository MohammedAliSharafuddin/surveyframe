# FR-21 (Fable sitting 2) and P2-08 (Codex pass 2), Session CF-B: a binary
# outcome's modelled level (the event) follows the declared order, never the
# session locale, and is named. as.factor() modelled the level that sorted
# last under LC_COLLATE, and a factor with an unused level gave codes 0 and 2.

cfb_yes_no <- function() {
  set.seed(202); n <- 90; x <- round(rnorm(n), 2)
  data.frame(x = x, out = ifelse(0.9 * x + rlogis(n) > 0, "Yes", "no"))
}
cfb_in_collation <- function(locale, code) {
  old <- Sys.getlocale("LC_COLLATE")
  ok <- suppressWarnings(Sys.setlocale("LC_COLLATE", locale))
  on.exit(Sys.setlocale("LC_COLLATE", old), add = TRUE)
  if (!nzchar(ok)) skip(paste("locale", locale, "is not installed"))
  force(code)
}

test_that("the slope and the event are the same in the C and an English collation", {
  d <- cfb_yes_no()
  run <- function() cfb_block(d, "regression_logistic_binary", list(predictors = "x", dependent = "out"),
                              cfb_num("x"), sframe_item("out", "Outcome", type = "text"))
  c_run <- cfb_in_collation("C", run())
  en_run <- cfb_in_collation("en_GB.UTF-8", run())
  expect_equal(c_run$coefficients["x", "Estimate"], en_run$coefficients["x", "Estimate"])
  expect_identical(c_run$event, en_run$event)
  # With no choice set, radix order: "Yes" (Y is 89) before "no" (n is 110).
  expect_identical(c_run$event, "no")
  expect_match(c_run$apa, "The odds are of \"Outcome\" being no, against Yes.", fixed = TRUE)
})

test_that("the event is the last declared code, and options$event names another", {
  d <- cfb_yes_no()
  cs <- sframe_choice_set("yn", c("no", "Yes"), c("No", "Yes"))
  it <- sframe_item("out", "Outcome", type = "single_choice", choice_set = "yn")
  r <- cfb_block(d, "regression_logistic_binary", list(predictors = "x", dependent = "out"),
                 cs, it, cfb_num("x"))
  ref <- glm(I(out == "Yes") ~ x, binomial, d)
  expect_identical(r$event, "Yes")
  expect_identical(r$reference_level, "no")
  expect_equal(r$coefficients["x", "Estimate"], unname(coef(ref)["x"]), tolerance = 1e-6)
  expect_match(r$apa, "being Yes, against No", fixed = TRUE)
  r2 <- cfb_block(d, "regression_logistic_binary", list(predictors = "x", dependent = "out"),
                  cs, it, cfb_num("x"), options = list(event = "no"))
  expect_identical(r2$event, "no")
  expect_equal(r2$coefficients["x", "Estimate"], -r$coefficients["x", "Estimate"], tolerance = 1e-6)
  expect_null(r2$options_ignored)
  r3 <- cfb_block(d, "regression_logistic_binary", list(predictors = "x", dependent = "out"),
                  cs, it, cfb_num("x"), options = list(event = "maybe"))
  expect_match(r3$error, "options$event is 'maybe'", fixed = TRUE)
})

test_that("a factor outcome with an unused level fits its 2 observed levels", {
  # probe_numbers.R P2-08: "y values must be 0 <= y <= 1" at 2a910b0.
  d <- cfb_yes_no()
  d$out <- factor(tolower(d$out), levels = c("no", "unused", "yes"))
  r <- cfb_block(d, "regression_logistic_binary", list(predictors = "x", dependent = "out"),
                 cfb_num("x"), sframe_item("out", "Outcome", type = "text"))
  expect_null(r$error)
  expect_identical(r$event, "yes")
  ref <- glm(I(out == "yes") ~ x, binomial, d)
  expect_equal(r$coefficients["x", "Estimate"], unname(coef(ref)["x"]), tolerance = 1e-6)
})

test_that("the multinomial reference and the t test groups do not follow the locale", {
  d <- data.frame(g = rep(c("alpha", "Beta"), each = 10), y = c(1:10, 3:12))
  run <- function() cfb_block(d, "t_test_ind", list(group = "g", outcome = "y"),
                              sframe_item("g", "g", type = "text"), cfb_num("y"))
  expect_identical(cfb_in_collation("C", run())$groups,
                   cfb_in_collation("en_GB.UTF-8", run())$groups)
  skip_if_not_installed("nnet")
  set.seed(3); n <- 120; x <- rnorm(n)
  d <- data.frame(x = x, m = sample(c("beta", "Alpha", "gamma"), n, TRUE))
  run <- function() cfb_block(d, "regression_logistic_multinomial", list(predictors = "x", dependent = "m"),
                              cfb_num("x"), sframe_item("m", "m", type = "text"))
  expect_identical(cfb_in_collation("C", run())$reference, "Alpha")
  expect_identical(cfb_in_collation("en_GB.UTF-8", run())$reference, "Alpha")
})
