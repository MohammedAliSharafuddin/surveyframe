# tests/testthat/test-read-responses-delim.R
#
# read_responses() detects a comma, semicolon or tab separator from the header
# line, with delim = to override. Semicolon files use a decimal comma.

delim_instrument <- function() {
  sf_instrument(
    "Delim",
    components = list(
      sf_item("age", "Age", type = "numeric"),
      sf_item("score", "Score", type = "numeric"),
      sf_item("note", "Note", type = "text")
    )
  )
}

test_that("an Excel-style semicolon file with decimal commas and a BOM reads", {
  path <- tempfile(fileext = ".csv")
  con <- file(path, "wb")
  writeBin(as.raw(c(0xEF, 0xBB, 0xBF)), con)
  writeBin(charToRaw(paste0(
    "age;score;note\n",
    "30;3,5;\"a; b, c\"\n",
    "41;4,25;caf\u00e9\n")), con)
  close(con)
  expect_message(d <- read_responses(path, delim_instrument()), "semicolon")
  expect_equal(colnames(d), c("age", "score", "note"))
  expect_equal(d$age, c(30, 41))
  expect_equal(d$score, c(3.5, 4.25))
  expect_equal(d$note[1], "a; b, c")
})

test_that("a tab file is detected and a comma file stays silent", {
  p <- tempfile(fileext = ".tsv")
  writeLines(c("age\tscore\tnote", "30\t3.5\tx"), p)
  expect_message(d <- read_responses(p, delim_instrument()), "tab")
  expect_equal(d$score, 3.5)
  p2 <- tempfile(fileext = ".csv")
  writeLines(c("age,score,note", "30,3.5,x"), p2)
  expect_no_message(d2 <- read_responses(p2, delim_instrument()))
  expect_equal(d2$score, 3.5)
})

test_that("delim overrides the detection", {
  p <- tempfile(fileext = ".csv")
  writeLines(c("age;score;note", "30;3,5;x"), p)
  expect_error(suppressWarnings(read_responses(p, delim_instrument(), delim = ",")))
  d <- suppressMessages(read_responses(p, delim_instrument(), delim = ";"))
  expect_equal(d$score, 3.5)
  expect_error(read_responses(p, delim_instrument(), delim = "|"),
               "delim")
})
