# tests/testthat/test-sframe-print-status.R
#
# print(), format() and summary() of an sframe give the status from
# validate_sframe() run on the object, as Studio's Open Instrument does
# (studio_schema_status(), Codex P1-09), never from the stored
# meta$validated, which is a cache only. Counts are in words, "1 block" and
# "2 blocks" in print() and summary(), "1 analysis block" in format(), never
# "block(s)" (coordinator 2026-11-11, UF follow-up 1).

print_status_instr <- function() sframe_demo("two_group")$instrument

print_status_line <- function(out) {
  sub("^\\s*Status:\\s*", "", grep("^\\s*Status:", out, value = TRUE))
}

test_that("a valid instrument prints and summarises as valid whatever its stored flag says", {
  instr <- print_status_instr()
  for (flag in list(TRUE, FALSE, NULL)) {
    instr$meta$validated <- flag
    expect_identical(print_status_line(capture.output(print(instr))), "valid")
    expect_identical(print_status_line(capture.output(summary(instr))), "valid")
    expect_match(format(instr), "| valid>", fixed = TRUE)
  }
})

test_that("an invalid instrument prints its problem count though its flag says valid", {
  instr <- print_status_instr()
  instr$items[[1]]$type <- "nonsense"
  instr$items[[2]]$type <- "nonsense"
  instr$meta$validated <- TRUE
  msg <- "invalid, 2 problems. validate_sframe(x, strict = FALSE) lists them"
  expect_identical(print_status_line(capture.output(print(instr))), msg)
  expect_identical(print_status_line(capture.output(summary(instr))), msg)
  expect_match(format(instr), "| invalid, 2 problems>", fixed = TRUE)
  instr$items[[2]]$type <- print_status_instr()$items[[2]]$type
  expect_match(print_status_line(capture.output(print(instr))), "^invalid, 1 problem\\. ")
})

test_that("print, format and summary count in words, with no '(s)'", {
  instr <- print_status_instr()
  block <- list(id = "RQ1", method = "descriptives", roles = list(variables = instr$items[[1]]$id))
  for (n in 0:2) {
    instr$analysis_plan <- rep(list(block), n)
    if (n > 1) instr$analysis_plan[[2]]$id <- "RQ2"
    words <- c("0 blocks", "1 block", "2 blocks")[n + 1]
    out <- c(capture.output(print(instr)), format(instr), capture.output(summary(instr)))
    expect_false(any(grepl("(s)", out, fixed = TRUE)), info = n)
    expect_match(grep("^\\s*Analysis:", capture.output(print(instr)), value = TRUE), paste0(" ", words, "$"))
    expect_match(format(instr), paste0("| ", sub(" ", " analysis ", words), " |"), fixed = TRUE)
    expect_match(capture.output(summary(instr)), paste0("^Analysis plan: ", words, "$"), all = FALSE)
  }
  expect_match(format(instr), sprintf("| %s |", sframe_count_noun(length(instr$items), "item")), fixed = TRUE)
})
