# P2-04, P2-05, P2-07 (Codex pass 2) and FR-28, FR-29, FR-31 (Fable sitting
# 2), Session CF-B: every runner, the descriptives and the missing data report
# start from 1 cleaning, sframe_analysis_frame(): a blank answer is missing
# and a factor keeps only the levels that have answers. Data built by hand or
# passed from a host reached them with "" as an answer.

f <- function(n) get(n, asNamespace("surveyframe"))

test_that("the missing data report counts a blank answer as missing", {
  # probe_numbers.R "Missing report on empty response": 1 missing, 2 valid.
  m <- f("sframe_missing_data_results")(data.frame(x = c("", "a", NA)))
  expect_equal(m$item_missing$missing_n, 2L)
  expect_equal(m$item_missing$valid_n, 1L)
})

test_that("Fisher's test leaves blank answers out", {
  # probe_numbers.R "Fisher empty answers": N = 6 and a 3 by 2 table.
  d <- data.frame(x = c("a", "a", "b", "b", "", ""), y = c("c", "d", "c", "d", "c", "d"))
  r <- f("sframe_run_fisher")(d, list(row = "x", column = "y"))
  expect_equal(r$n, 4)
  expect_equal(dim(r$table), c(2L, 2L))
})

test_that("a blank group is not a group in ANOVA, Kruskal-Wallis, the t test or two-way ANOVA", {
  # FR-28: df1 = 3 with the blanks as a fourth group.
  set.seed(9)
  d <- data.frame(g = rep(c("a", "b", "c"), each = 10), y = rnorm(30), h = rep(c("u", "v"), 15))
  d$g[c(1, 11, 21, 22, 23)] <- ""
  r <- cfb_block(d, "anova_one", list(group = "g", outcome = "y"),
                 sframe_item("g", "g", type = "text"), cfb_num("y"))
  expect_equal(r$df1 %||% r$df_between %||% r$table$df[1], 2)
  k <- cfb_block(d, "kruskal_wallis", list(group = "g", outcome = "y"),
                 sframe_item("g", "g", type = "text"), cfb_num("y"))
  expect_equal(k$df, 2)
  d2 <- d[d$g != "c", ]
  t <- cfb_block(d2, "t_test_ind", list(group = "g", outcome = "y"),
                 sframe_item("g", "g", type = "text"), cfb_num("y"))
  expect_null(t$error)
  expect_identical(as.character(t$groups), c("a", "b"))
  two <- cfb_block(d, "anova_two", list(factor1 = "g", factor2 = "h", outcome = "y"),
                   sframe_item("g", "g", type = "text"), sframe_item("h", "h", type = "text"), cfb_num("y"))
  expect_equal(two$table$df[1], 2)
})

test_that("an unused factor level does not break the cross-tab or chi-square", {
  # probe_numbers.R "Crosstab unused factor level" and FR-29.
  d <- data.frame(x = factor(c("a", "a", "b", "b"), levels = c("a", "b", "unused")),
                  y = c("c", "d", "c", "d"))
  r <- f("sframe_run_crosstab")(d, c("x", "y"))
  expect_null(r$error)
  expect_equal(nrow(r$table), 2L)
  set.seed(3)
  d <- data.frame(g3 = factor(sample(1:3, 60, TRUE), levels = 1:4), g2 = rep(c("a", "b"), 30))
  r <- cfb_block(d, "chi_square", list(row = "g3", column = "g2"),
                 sframe_item("g3", "g3", type = "text"), sframe_item("g2", "g2", type = "text"))
  expect_null(r$error)
  expect_equal(r$df, 2)
})

test_that("a numeric column held as text with blanks gets descriptives", {
  # FR-31: valid 5, missing 0, mean NA at 2a910b0.
  d <- data.frame(y = c("", "", "1.5", "2", "3"))
  tab <- f("sframe_descriptives_results")(d, "y")$table
  expect_equal(tab$valid_n, 3)
  expect_equal(tab$missing_n, 2)
  expect_equal(tab$mean, mean(c(1.5, 2, 3)))
})
