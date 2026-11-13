# FR-18 (Fable sitting 2), Session CF-B: a "do not know" code (99) in a scale
# item's choice set is not a score. Its bounds were read as 1 to 99, so a
# reversed 1 became 99, and an answer of 99 entered the mean.

cfb_dk_instrument <- function() {
  cs <- sframe_choice_set("ag", c(1:5, 99), c("SD", "D", "N", "A", "SA", "Do not know"))
  it <- lapply(1:4, function(i) sframe_item(paste0("s_", i), "i", type = "likert",
                                            choice_set = "ag", scale_id = "sat"))
  sc <- sframe_scale("sat", "Sat", items = paste0("s_", 1:4), reverse_items = "s_4")
  sframe_instrument("T", components = c(list(cs, sc), it))
}

test_that("reversal uses the run of scores, not the do-not-know code", {
  # Fable's reproducer: 27.25 at 2a910b0.
  ins <- cfb_dk_instrument()
  d <- data.frame(s_1 = 4, s_2 = 4, s_3 = 2, s_4 = 1)
  expect_equal(score_scales(d, ins)$sat, 3.75)
})

test_that("an answer of 99 is missing, with a message", {
  ins <- cfb_dk_instrument()
  d <- data.frame(s_1 = c(5, 4), s_2 = c(4, 4), s_3 = c(99, 2), s_4 = c(1, 1))
  expect_message(out <- score_scales(d, ins),
                 "Scale 'sat': 1 answer of 99, outside the run of scoring codes, is read as missing.",
                 fixed = TRUE)
  # min_valid defaults to every item, so the first respondent has no score.
  expect_equal(out$sat, c(NA, 3.75))
})

test_that("validate_sframe() notes the set and the instrument stays valid", {
  v <- validate_sframe(cfb_dk_instrument(), strict = FALSE)
  expect_true(v$valid)
  expect_true(any(grepl("Choice set 'ag', used by scale 'sat', has 1 code 99 outside its run of scores 1 to 5",
                        sframe_notes(v), fixed = TRUE)))
})

test_that("evenly spaced codes are 1 run, and 0 to 1 stays 1 run", {
  expect_equal(sframe_score_codes(seq(0, 100, 25)), seq(0, 100, 25))
  expect_equal(sframe_score_codes(c(1:5, 8, 9)), 1:5)
  expect_equal(sframe_score_codes(c(0, 1)), c(0, 1))
  expect_equal(sframe_score_codes(c("1", "2", "3", "-9")), 1:3)
  expect_null(sframe_score_codes(c("a", "b")))
})
