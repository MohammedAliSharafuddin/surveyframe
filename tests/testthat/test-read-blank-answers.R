# P3-05 (Codex pass 3), Session CF-B: a blank answer is missing in every
# column, factors included, and a declared numeric column that stays text
# says so. A factor column kept its "", and a numeric column with 1 value
# that did not convert stayed text with its "" and no message.

test_that("a blank in a text or factor column is missing", {
  i <- sframe_instrument("P3", components = list(sframe_item("note", "Note", "text")))
  a <- read_responses(data.frame(note = c("", "yes", "  ")), i)
  b <- read_responses(data.frame(note = factor(c("", "yes"))), i)
  expect_identical(a$note, c(NA, "yes", NA))
  expect_identical(b$note, c(NA, "yes"))
})

test_that("a declared numeric column that stays text warns, naming column and values", {
  ni <- sframe_instrument("P3", components = list(sframe_item("n", "Number", "numeric")))
  expect_warning(out <- read_responses(data.frame(n = c("", "oops", "1")), ni),
                 "Column 'n' holds numeric answers, and 1 value did not read as a number (\"oops\")",
                 fixed = TRUE, class = "sframe_warning")
  expect_identical(out$n, c(NA, "oops", "1"))
  expect_no_warning(ok <- read_responses(data.frame(n = c("", " 2", "1")), ni))
  expect_equal(ok$n, c(NA, 2, 1))
})

test_that("a Windows-1252 file is still read, its bytes as written", {
  # The blank rule tests text byte-wise: trimws() refused text that is not
  # valid UTF-8 (probe_roundtrip.R windows1252, during CF-B).
  i <- sframe_instrument("P3", components = list(sframe_item("note", "Note", "text")))
  p <- tempfile(fileext = ".csv")
  con <- file(p, "wb")
  writeBin(c(charToRaw("respondent_id,note\n001,caf"), as.raw(0xe9), charToRaw("\n002,\n")), con)
  close(con)
  out <- read_responses(p, i)
  expect_identical(charToRaw(out$note[1]), as.raw(c(0x63, 0x61, 0x66, 0xe9)))
  expect_true(is.na(out$note[2]))
})
