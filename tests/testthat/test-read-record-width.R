# P3-01 (Codex pass 3), Session CF-B: a CSV whose data rows are wider than
# its header is refused, or, when every row has 1 empty extra field, read
# with that field dropped. read.csv() made column 1 the row names and moved
# every answer and the respondent id 1 column left.

cfb_p3_instrument <- function() {
  sframe_instrument("P3", components = list(sframe_item("n", "Number", "numeric"),
                                           sframe_item("note", "Note", "text")))
}

test_that("a trailing separator on every row is dropped, and nothing shifts", {
  p <- tempfile(fileext = ".csv")
  writeLines(c("respondent_id,n,note", "001,10,A,", "002,20,B,"), p)
  expect_message(out <- read_responses(p, cfb_p3_instrument()), "The empty field is dropped",
                 fixed = TRUE)
  expect_identical(out$respondent_id, c("001", "002"))
  expect_equal(out$n, c(10, 20))
  expect_identical(out$note, c("A", "B"))
})

test_that("a row wider than its header with a value in the extra field is refused, naming lines", {
  p <- tempfile(fileext = ".csv")
  writeLines(c("respondent_id,n,note", "001,10,A,x", "002,20,B", "003,30,C,y,z"), p)
  expect_error(read_responses(p, cfb_p3_instrument()),
               "has rows whose number of fields differs from its header's 3: lines 2, 4 (4, 5 fields)",
               fixed = TRUE, class = "sframe_import_error")
})

test_that("a short row is refused too, and a quoted field across lines is 1 record", {
  p <- tempfile(fileext = ".csv")
  writeLines(c("respondent_id,n,note", "001,10", "002,20,B"), p)
  expect_error(read_responses(p, cfb_p3_instrument()), "line 2 (2 fields)", fixed = TRUE)
  writeLines(c("respondent_id,n,note", "001,10,\"two", "lines\"", "002,20,B"), p)
  out <- read_responses(p, cfb_p3_instrument())
  expect_identical(out$note, c("two\nlines", "B"))
})

test_that("a 1-column file keeps an unanswered respondent's blank line", {
  # P3-02 (Codex pass 3): read.csv() skipped the blank line, so the file read
  # as 2 respondents, first and last.
  i <- sframe_instrument("P3", components = list(sframe_item("note", "Note", "text")))
  p <- tempfile(fileext = ".csv")
  write.csv(data.frame(note = c("first", NA, "last")), p, row.names = FALSE, na = "")
  expect_identical(read_responses(p, i)$note, c("first", NA, "last"))
  # Blank lines after the last answer are not respondents.
  writeLines(c("note", "first", "", "last", "", ""), p)
  expect_identical(read_responses(p, i)$note, c("first", NA, "last"))
})
