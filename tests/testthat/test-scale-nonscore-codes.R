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
                 "Scale 'sat': 99 is not scored. 1 answer of 99, outside the run of scoring codes, is read as missing.",
                 fixed = TRUE)
  # min_valid defaults to every item, so the first respondent has no score.
  expect_equal(out$sat, c(NA, 3.75))
})

test_that("validate_sframe() notes the set and the instrument stays valid", {
  v <- validate_sframe(cfb_dk_instrument(), strict = FALSE)
  expect_true(v$valid)
  expect_true(any(grepl("Choice set 'ag', used by scale 'sat', has 1 code 99 outside its run of scores 1 to 5: 99 is not scored.",
                        sframe_notes(v), fixed = TRUE)))
})

test_that("evenly spaced codes are 1 run, and 0 to 1 stays 1 run", {
  expect_equal(sframe_score_codes(seq(0, 100, 25)), seq(0, 100, 25))
  expect_equal(sframe_score_codes(c(1:5, 8, 9)), 1:5)
  expect_equal(sframe_score_codes(c(0, 1)), c(0, 1))
  expect_equal(sframe_score_codes(c("1", "2", "3", "-9")), 1:3)
  expect_null(sframe_score_codes(c("a", "b")))
})

test_that("a gap after the run keeps the longer run, and 2 equal runs refuse the scale", {
  # Coordinator conditions on FR-18 (2026-11-13).
  expect_equal(sframe_score_codes(c(1, 2, 3, 7)), 1:3)
  tied <- sframe_score_codes(c(1, 2, 4, 5))
  expect_length(tied, 0)
  expect_equal(attr(tied, "tie"), list(c(1, 2), c(4, 5)))
  cs <- sframe_choice_set("gap", c(1, 2, 4, 5), c("a", "b", "c", "d"))
  it <- lapply(1:2, function(i) sframe_item(paste0("g_", i), "i", type = "likert",
                                            choice_set = "gap", scale_id = "g"))
  sc <- sframe_scale("g", "G", items = c("g_1", "g_2"))
  ins <- sframe_instrument("T", components = c(list(cs, sc), it))
  expect_error(score_scales(data.frame(g_1 = 1, g_2 = 5), ins),
               "Scale 'g' cannot be scored: choice set 'gap' has 2 or more equally long runs of codes (1 to 2 and 4 to 5)",
               fixed = TRUE, class = "sframe_error")
  expect_true(any(grepl("refuses the scale", sframe_notes(validate_sframe(ins, strict = FALSE)),
                        fixed = TRUE)))
  cs7 <- sframe_choice_set("gap", c(1, 2, 3, 7), c("a", "b", "c", "d"))
  ins7 <- sframe_instrument("T", components = c(list(cs7, sc), it))
  expect_message(out <- score_scales(data.frame(g_1 = c(1, 3), g_2 = c(7, 2)), ins7),
                 "7 is not scored", fixed = TRUE)
  expect_equal(out$g, c(NA, 2.5))
})
