# P3-04 (Codex pass 3), Session CF-B: a choice code with white space at
# either end is a validation problem, and the reader compares codes as
# declared. Trimmed, " 1" counted as numeric and the answer " 1" became 1.

cfb_space_instrument <- function() {
  i <- sframe_instrument("P3", components = list(sframe_item("x", "Choice", "text")))
  i$choices <- list(sframe_choice_set("c", c("1", "2"), c("First", "Second")))
  i$choices[[1]]$values <- c(" 1", "2")
  i$items[[1]]$type <- "single_choice"
  i$items[[1]]$choice_set <- "c"
  i
}

test_that("validate_sframe() names the set and the padded code", {
  v <- validate_sframe(cfb_space_instrument(), strict = FALSE)
  expect_false(v$valid)
  expect_true(any(grepl("Choice set 'c': code \" 1\" has white space at the start or end",
                        v$problems, fixed = TRUE)))
})

test_that("the reader does not read a set with a padded code as numbers", {
  i <- cfb_space_instrument()
  expect_false("x" %in% sframe_numeric_response_columns(i, i$items))
  i$choices[[1]]$values <- c("1", "2")
  expect_true("x" %in% sframe_numeric_response_columns(i, i$items))
})
