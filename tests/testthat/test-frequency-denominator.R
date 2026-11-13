# FR-23 (Fable sitting 2), Session CF-B: a frequency table's percentages are
# of those who answered, as the weighted table and a descriptives block's
# counts are, and the sentence gives that N with the missing count. North was
# 28.9% in the table, 36.1% beside it, and the sentence said N = 90 where 72
# answered.

cfb_region_freq <- function(method, roles) {
  d <- data.frame(g3 = c(rep(NA, 18), rep(1, 26), rep(2, 16), rep(3, 30)), w = 1)
  cfb_block(d, method, roles,
            sframe_choice_set("reg", 1:3, c("North", "South", "East")),
            sframe_item("g3", "Region", type = "single_choice", choice_set = "reg"),
            cfb_num("w"))
}

test_that("the frequency, weighted and descriptives tables agree on North", {
  f <- cfb_region_freq("frequency", list(variable = "g3", weights = "w"))
  north <- f$table$Percent[f$table$Value %in% "North"]
  expect_equal(north, round(26 / 72 * 100, 1))
  expect_equal(f$weighted_table$Weighted_Percent[f$weighted_table$Value %in% "North"], north)
  expect_true(is.na(f$table$Percent[is.na(f$table$Code)]))
  expect_equal(f$table$Frequency[is.na(f$table$Code)], 18L)
  expect_equal(f$n, 72L)
  expect_match(f$apa, "(N = 72, 18 missing).", fixed = TRUE)
})

test_that("an item nobody skipped says no missing count", {
  d <- data.frame(g = c("a", "b", "a"))
  f <- cfb_block(d, "frequency", list(variable = "g"), sframe_item("g", "G", type = "text"))
  expect_match(f$apa, "(N = 3).", fixed = TRUE)
  expect_equal(sum(f$table$Percent), 100)
})
