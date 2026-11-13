# FR-30 (Fable sitting 2), Session CF-B: score_scales() reads a value its
# item's choice set does not declare, and one that is not a number, as
# missing, with a message. 7 on a 1 to 5 item was scored as 7, a reversed 0
# became 6, and "4,5" became NA without a word.

cfb_15_instrument <- function() {
  cs <- sframe_choice_set("ag", 1:5, c("SD", "D", "N", "A", "SA"))
  it <- lapply(1:3, function(i) sframe_item(paste0("s_", i), "i", type = "likert",
                                            choice_set = "ag", scale_id = "sat"))
  sc <- sframe_scale("sat", "Sat", items = paste0("s_", 1:3), reverse_items = "s_3",
                     min_valid = 1)
  sframe_instrument("T", components = c(list(cs, sc), it))
}

test_that("7 and a reversed 0 are missing, with a message naming them", {
  d <- data.frame(s_1 = c(7, 4), s_2 = c(4, 4), s_3 = c(0, 2))
  expect_message(out <- score_scales(d, cfb_15_instrument()),
                 "Scale 'sat': 2 answers of 0, 7, which no item's choice set declares, are read as missing.",
                 fixed = TRUE)
  expect_equal(out$sat, c(4, (4 + 4 + 4) / 3))
})

test_that("an answer that is not a number is named", {
  d <- data.frame(s_1 = c("4,5", "4"), s_2 = c("4", "4"), s_3 = c("2", "2"))
  expect_message(out <- score_scales(d, cfb_15_instrument()),
                 "1 answer that does not read as a number (\"4,5\") is read as missing.",
                 fixed = TRUE)
  expect_equal(out$sat, c(4, 4))
})

test_that("declared answers give no message", {
  expect_no_message(score_scales(data.frame(s_1 = 1, s_2 = 5, s_3 = 3), cfb_15_instrument()))
})
