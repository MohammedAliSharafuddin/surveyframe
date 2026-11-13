# FR-22 (Fable sitting 2) and P2-03 (Codex pass 2), Session CF-B: McNemar's
# table is laid out on 1 order for both items. table() of the 2 columns
# paired the first row level with the first column level, whatever they
# were, so the test ran on the wrong cells.

test_that("2 factors with the same labels in opposite level order give base R's aligned test", {
  # probe_numbers.R "McNemar same labels different factor order": 0.8,
  # p = .371 at 2a910b0, where the aligned table gives 0 and p = 1.
  d <- data.frame(
    before = factor(c("yes", "yes", "no", "no", "yes", "no"), levels = c("yes", "no")),
    after  = factor(c("yes", "no", "yes", "no", "no", "yes"), levels = c("no", "yes")))
  r <- cfb_block(d, "mcnemar", list(before = "before", after = "after"),
                 sframe_item("before", "b", type = "text"),
                 sframe_item("after", "a", type = "text"))
  expect_null(r$error)
  lev <- c("no", "yes")
  ref <- stats::mcnemar.test(table(factor(d$before, lev), factor(d$after, lev)))
  expect_equal(r$statistic, unname(ref$statistic))
  expect_equal(r$p, ref$p.value)
  expect_identical(rownames(r$table), colnames(r$table))
})

test_that("items whose observed categories differ are tested on the declared choice set", {
  # Fable's FR-22 reproducer: rows (a, b), columns (b, c). At 2a910b0 a 2 by 2
  # test paired a with b and b with c.
  set.seed(202)
  d <- data.frame(c1 = sample(c("a", "b"), 90, TRUE), c2 = sample(c("b", "c"), 90, TRUE))
  cs <- sframe_choice_set("abc", c("a", "b", "c"), c("A", "B", "C"))
  r <- cfb_block(d, "mcnemar", list(before = "c1", after = "c2"), cs,
                 sframe_item("c1", "c1", type = "single_choice", choice_set = "abc"),
                 sframe_item("c2", "c2", type = "single_choice", choice_set = "abc"))
  expect_null(r$error)
  lev <- c("a", "b", "c")
  ref <- stats::mcnemar.test(table(factor(d$c1, lev), factor(d$c2, lev)))
  expect_equal(r$df, 3)
  expect_equal(r$statistic, unname(ref$statistic))
  expect_equal(r$p, ref$p.value)
})

test_that("2 items with different choice sets are refused, naming both", {
  d <- data.frame(c1 = c("a", "b", "a", "b"), c2 = c("x", "y", "y", "x"))
  r <- cfb_block(d, "mcnemar", list(before = "c1", after = "c2"),
                 sframe_choice_set("ab", c("a", "b"), c("A", "B")),
                 sframe_choice_set("xy", c("x", "y"), c("X", "Y")),
                 sframe_item("c1", "First", type = "single_choice", choice_set = "ab"),
                 sframe_item("c2", "Second", type = "single_choice", choice_set = "xy"))
  expect_match(r$error, "different response options", fixed = TRUE)
  expect_match(r$error, "\"First\"", fixed = TRUE)
  expect_match(r$error, "\"Second\"", fixed = TRUE)
})

test_that("a pair of categories nobody moved between is an error, not NaN", {
  d <- data.frame(b = c("y", "n", "y", "n"), a = c("y", "n", "y", "n"))
  r <- cfb_block(d, "mcnemar", list(before = "b", after = "a"),
                 sframe_item("b", "b", type = "text"), sframe_item("a", "a", type = "text"))
  expect_match(r$error, "combine categories", fixed = TRUE)
})
