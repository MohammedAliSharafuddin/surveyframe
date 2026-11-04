# tests/testthat/test-allow-other.R
#
# Session O: the R side of a choice set's allow_other ("Other, please
# specify"). The submitted shape (coordinator, 2026-11-04): a single choice
# submits the code "other" in <id> and the typed text in <id>__other_text, a
# multiple choice submits <id>__other as 1 or 0 beside its option columns and
# the text in <id>__other_text. The template side is in
# test-static-template-other.R.

ao_instrument <- function(allow_other = TRUE, values = c("web", "friend")) {
  sframe_instrument(
    "Other", version = "1.0.0",
    components = list(
      sframe_item("one", "How did you hear of us?", type = "single_choice", choice_set = "src"),
      sframe_item("many", "Which did you use?", type = "multiple_choice", choice_set = "src"),
      sframe_choice_set("src", values, c("Website", "A friend")[seq_along(values)],
                        allow_other = allow_other)))
}

test_that("a set with allow_other adds the Other columns to both item types", {
  inst <- ao_instrument()
  expect_identical(
    surveyframe:::sframe_item_expansion_columns(inst),
    c("one__other_text", "many__web", "many__friend", "many__other", "many__other_text"))
  expect_identical(surveyframe:::sframe_item_response_columns(inst, inst$items[[1]]),
                   c("one", "one__other_text"))
  expect_identical(surveyframe:::sframe_other_text_columns(inst),
                   c("one__other_text", "many__other_text"))
  plain <- ao_instrument(FALSE)
  expect_identical(surveyframe:::sframe_item_expansion_columns(plain),
                   c("many__web", "many__friend"))
  expect_identical(surveyframe:::sframe_item_response_columns(plain, plain$items[[1]]), "one")
})

test_that("the Google Sheets header carries the Other columns after the item", {
  dir <- tempfile("gs"); dir.create(dir)
  path <- export_google_sheet(ao_instrument(), "https://docs.google.com/spreadsheets/d/demo",
                              output_dir = dir)
  src <- paste(readLines(path, warn = FALSE), collapse = "\n")
  unlink(dir, recursive = TRUE)
  expect_match(src, paste0('["respondent_id","started_at","submitted_at","one","one__other_text",',
                           '"many__web","many__friend","many__other","many__other_text"]'),
               fixed = TRUE)
})

test_that("the Shiny row has the same Other columns as the static survey", {
  inst <- ao_instrument()
  row <- function(vals) {
    surveyframe:::sframe_response_row(
      inst, vals, surveyframe:::sframe_branch_lookup(inst),
      started_at = as.POSIXct("2026-01-01 10:00:00", tz = "UTC"),
      submitted_at = as.POSIXct("2026-01-01 10:05:00", tz = "UTC"))
  }
  r <- row(list(one = "other", one__other_text = "A poster",
                many = c("web", "other"), many__other_text = "Radio"))
  expect_identical(r$one, "other")
  expect_identical(r$one__other_text, "A poster")
  expect_identical(c(r$many__web, r$many__friend, r$many__other), c("1", "0", "1"))
  expect_identical(r$many__other_text, "Radio")
  r <- row(list(one = "web", one__other_text = "stale", many = "friend",
                many__other_text = "stale"))
  expect_true(is.na(r$one__other_text))
  expect_identical(r$many__other, "0")
  expect_true(is.na(r$many__other_text))
})

test_that("the text of an Other does not count as a missing answer", {
  inst <- ao_instrument()
  data <- data.frame(respondent_id = c("a", "b"), one = c("web", "other"),
                     one__other_text = c(NA, "A poster"),
                     many__web = c("1", "0"), many__friend = c("0", "1"),
                     many__other = c("0", "0"), many__other_text = c(NA, NA),
                     stringsAsFactors = FALSE)
  q <- suppressWarnings(sframe_quality_results(data, inst, respondent_id = "respondent_id"))
  expect_false(any(grepl("__other_text$", q$missing$expected_columns)))
  expect_true("one" %in% q$missing$expected_columns)
  expect_identical(unname(q$missing$respondent_miss), c(0, 0))
})
