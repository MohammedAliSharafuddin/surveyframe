# tests/testthat/test-choice-codes-numeric.R
#
# Ethos request 14 (2026-10-02). read_responses() reads a choice set whose
# codes are all numbers as numbers, so the codes 1 and 1.0 both became 1 and
# export_responses() then failed with "`labels` must be unique".
# validate_sframe() accepted the set.

test_that("14: codes that read as the same number are refused when the set is made", {
  expect_error(sframe_choice_set("cs", values = c("1", "1.0", "2"), labels = c("A", "B", "C")),
               "the codes 1 and 1.0 read as the same number")
  expect_error(sframe_choice_set("cs", values = c("1", "2", "02"), labels = c("A", "B", "C")),
               "the codes 2 and 02 read as the same number")
})

test_that("14: the validator refuses such a set after an edit", {
  ins <- sframe_instrument("Codes", components = list(
    sframe_item("q1", "Q", type = "single_choice", choice_set = "cs"),
    sframe_choice_set("cs", values = c("1", "2"), labels = c("A", "B"))))
  ins$choices[[1]]$values <- c("1", "1.0")
  v <- validate_sframe(ins, strict = FALSE)
  expect_false(v$valid)
  expect_match(unlist(v$problems), "Choice set 'cs': the codes 1 and 1.0",
               fixed = TRUE, all = FALSE)
})

test_that("14: text codes and distinct numbers are accepted", {
  expect_s3_class(sframe_choice_set("cs", values = c("a", "A", "b"), labels = c("x", "y", "z")),
                  "sf_choices")
  expect_s3_class(sframe_choice_set("cs", values = c("1", "1.5", "2"), labels = c("x", "y", "z")),
                  "sf_choices")
  # A mix of text and numbers is read as text, so 1 and 1.0 stay apart.
  expect_s3_class(sframe_choice_set("cs", values = c("1", "1.0", "other"), labels = c("x", "y", "z")),
                  "sf_choices")
})
