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

test_that("read_responses() accepts the code other and reads the Other text as text", {
  inst <- sframe_instrument(
    "Other numeric", version = "1.0.0",
    components = list(
      sframe_item("one", "Source", type = "single_choice", choice_set = "src"),
      sframe_item("many", "Used", type = "multiple_choice", choice_set = "src"),
      sframe_item("plain", "Plain", type = "single_choice", choice_set = "num"),
      sframe_choice_set("src", 1:2, c("Website", "A friend"), allow_other = TRUE),
      sframe_choice_set("num", 1:2, c("Yes", "No"))))
  data <- data.frame(one = c("1", "other", "2"), one__other_text = c("", "123", ""),
                     many__1 = c("1", "0", "1"), many__2 = c("0", "0", "1"),
                     many__other = c("0", "1", "0"), many__other_text = c("", "007", ""),
                     plain = c("1", "2", "1"), stringsAsFactors = FALSE)
  path <- tempfile(fileext = ".csv")
  utils::write.csv(data, path, row.names = FALSE)
  got <- read_responses(path, inst)
  unlink(path)
  expect_identical(got$one, c("1", "other", "2"))
  expect_identical(got$one__other_text, c(NA, "123", NA))
  expect_identical(got$many__other, c(0, 1, 0))
  expect_identical(got$many__other_text, c(NA, "007", NA))
  expect_identical(got$plain, c(1, 2, 1))
  expect_identical(names(got), c("one", "one__other_text", "many__1", "many__2",
                                 "many__other", "many__other_text", "plain"))
})

test_that("allow_other is refused on a set holding the value other or other_text", {
  for (v in c("other", "other_text")) {
    expect_error(sframe_choice_set("src", c("web", v), c("Website", "Something"),
                                   allow_other = TRUE),
                 paste0('reserves the value\\(s\\) "', v, '"'),
                 class = "sframe_validation_error")
  }
  expect_s3_class(sframe_choice_set("src", c("web", "other"), c("Website", "Other")),
                  "sf_choices")
  inst <- ao_instrument()
  inst$choices[[1]]$values <- c("web", "other")
  res <- validate_sframe(inst, strict = FALSE)
  expect_false(res$valid)
  expect_true(any(grepl('reserves the value(s) "other"', unlist(res$problems), fixed = TRUE)))
})

test_that("allow_other is refused on an ordered set", {
  expect_error(sframe_choice_set("often", 1:3, c("Rarely", "Sometimes", "Often"),
                                 allow_other = TRUE, ordered = TRUE),
               "cannot be used on an ordered set", class = "sframe_validation_error")
  inst <- ao_instrument()
  inst$choices[[1]]$ordered <- TRUE
  res <- validate_sframe(inst, strict = FALSE)
  expect_false(res$valid)
  expect_true(any(grepl("cannot be used on an ordered set", unlist(res$problems), fixed = TRUE)))
  expect_error(validate_sframe(inst), "ordered set")
})

test_that("a set with allow_other on unordered free codes validates", {
  expect_true(validate_sframe(ao_instrument(), strict = FALSE)$valid)
})
