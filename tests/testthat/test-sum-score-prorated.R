# FR-26 (Fable sitting 2), Session CF-B: a sum score with min_valid below the
# item count is prorated, not a sum with 0 for each unanswered item.

cfb_sum_instrument <- function(weights = NULL) {
  cs <- sframe_choice_set("ag", 1:5, c("SD", "D", "N", "A", "SA"))
  it <- lapply(1:4, function(i) sframe_item(paste0("s_", i), "i", type = "likert", choice_set = "ag"))
  sc <- sframe_scale("sat", "Sat", items = paste0("s_", 1:4), method = "sum", min_valid = 2,
                     weights = weights)
  sframe_instrument("T", components = c(list(cs, sc), it))
}

test_that("2 top answers of 4 score the top of the sum scale", {
  # Fable's reproducer: 10 at 2a910b0.
  out <- score_scales(data.frame(s_1 = 5, s_2 = 5, s_3 = NA, s_4 = NA), cfb_sum_instrument())
  expect_equal(out$sat, 20)
})

test_that("a complete respondent keeps the plain sum, weighted or not", {
  d <- data.frame(s_1 = c(1, 2), s_2 = c(2, 4), s_3 = c(3, NA), s_4 = c(4, 1))
  expect_equal(score_scales(d, cfb_sum_instrument())$sat, c(10, 7 / 3 * 4))
  w <- c(1, 2, 1, 2)
  out <- score_scales(d, cfb_sum_instrument(weights = w))$sat
  expect_equal(out[1], sum(w * c(1, 2, 3, 4)))
  expect_equal(out[2], (2 * 1 + 4 * 2 + 1 * 2) / (1 + 2 + 2) * sum(w))
})

test_that("an absent item column is prorated over the declared items", {
  d <- data.frame(s_1 = 4, s_2 = 4, s_3 = 4)
  expect_warning(out <- score_scales(d, cfb_sum_instrument()), "no column")
  expect_equal(out$sat, 16)
})
