# tests/testthat/test-collector-formula-injection.R
#
# A8. The collector wrote each row with appendRow(), which applies Sheets'
# user-entered semantics. A respondent whose answer began with "=" had it
# parsed as a formula before the researcher ever saw it: "=1+1" was stored as
# 2, and "=IMPORTXML(...)" was evaluated inside the researcher's own sheet.
# Numeric-looking codes lost their leading zeros the same way.
#
# The answer is altered between submission and storage, so nothing downstream
# can recover it. The mock in helper-apps-script.R models the coercion, which
# is what makes this visible at all.

test_that("an answer beginning with = is stored as the text the participant typed", {
  cols <- c("respondent_id", "submitted_at", "q_comment")
  ctx <- apps_script_context(cols)
  apps_script_post(ctx, c(respondent_id = "r1", submitted_at = "t1",
                          q_comment = "=1+1"))

  expect_identical(apps_script_cell(ctx, 1, "q_comment"), "=1+1")
})

test_that("a formula-shaped answer is never evaluated in the researcher's sheet", {
  cols <- c("respondent_id", "submitted_at", "q_comment")
  ctx <- apps_script_context(cols)
  hostile <- "=IMPORTXML(\"http://example.invalid/x\",\"//a\")"
  apps_script_post(ctx, c(respondent_id = "r1", submitted_at = "t1",
                          q_comment = hostile))

  stored <- apps_script_cell(ctx, 1, "q_comment")
  expect_identical(stored, hostile)
  expect_false(grepl("#FORMULA", stored, fixed = TRUE))
})

test_that("a leading-zero code keeps its zeros", {
  cols <- c("respondent_id", "submitted_at", "q_site")
  ctx <- apps_script_context(cols)
  apps_script_post(ctx, c(respondent_id = "r1", submitted_at = "t1",
                          q_site = "007"))

  expect_identical(apps_script_cell(ctx, 1, "q_site"), "007")
})

test_that("ordinary answers and header mapping are unaffected", {
  cols <- c("respondent_id", "submitted_at", "q_freq", "q_prior")
  ctx <- apps_script_context(cols)
  apps_script_post(ctx, c(respondent_id = "r1", submitted_at = "t1",
                          q_freq = "Daily", q_prior = "Yes"))
  apps_script_post(ctx, c(respondent_id = "r2", submitted_at = "t2",
                          q_freq = "Weekly", q_prior = "No"))

  expect_identical(ctx$get("__ss.sheets['Responses'].rows[0]"), cols)
  expect_identical(apps_script_cell(ctx, 1, "q_freq"), "Daily")
  expect_identical(apps_script_cell(ctx, 2, "q_prior"), "No")
  expect_identical(apps_script_cell(ctx, 2, "respondent_id"), "r2")
})

test_that("the builder's inlined collector carries the same text-write fix", {
  # The builder ships its own copy of the collector script. It is maintained
  # by hand, so a fix applied to inst/static_survey/collector_template.gs
  # alone leaves every GUI-built survey still writing user-entered values.
  # That drift is what this asserts against.
  p <- system.file("builder", "survey_builder.html", package = "surveyframe")
  skip_if(!nzchar(p) || !file.exists(p), "builder not found")
  builder <- paste(readLines(p, warn = FALSE), collapse = "\n")

  expect_true(grepl("appendRowAsText_", builder, fixed = TRUE))
  expect_true(grepl("setNumberFormat(\"@\")", builder, fixed = TRUE))
  expect_false(grepl("sheet.appendRow(row)", builder, fixed = TRUE))
})

test_that("neither copy of the collector writes user-entered values", {
  paths <- c(
    system.file("static_survey", "collector_template.gs", package = "surveyframe"),
    system.file("builder", "survey_builder.html", package = "surveyframe")
  )
  skip_if(!all(nzchar(paths) & file.exists(paths)), "shipped assets not found")

  for (p in paths) {
    src <- paste(readLines(p, warn = FALSE), collapse = "\n")
    expect_false(grepl("sheet.appendRow(", src, fixed = TRUE),
                 info = paste("user-entered write still present in", basename(p)))
  }
})

# A8, reopened by review: the original fix set the plain-text number format and
# then called setValues(). Google documents setValues() as applying
# user-entered semantics and promises nothing about the number format
# suppressing that, and the mock used to encode the assumption it was meant to
# test by returning the string unchanged whenever the format was "@". The mock
# now parses regardless of format, so an answer can only survive literally
# through the Sheets API's documented RAW option.

test_that("A8: the row is written through the documented RAW option", {
  skip_if_not_installed("V8")
  ctx <- apps_script_context(c("respondent_id", "q1"))
  apps_script_post(ctx, c(respondent_id = "r1", q1 = "=1+1"))

  writes <- ctx$get("__rawWrites")
  expect_gt(nrow(writes), 0)
  expect_true(all(writes$option == "RAW"))
})

test_that("A8: a formula-like answer is stored as the participant typed it", {
  skip_if_not_installed("V8")
  ctx <- apps_script_context(c("respondent_id", "q1", "q2", "q3"))
  apps_script_post(ctx, c(respondent_id = "r1", q1 = "=1+1",
                          q2 = '=IMPORTXML("http://x","//a")', q3 = "007"))
  row <- ctx$get("__ss.sheets['Responses'].rows[1]")
  expect_equal(row[[2]], "=1+1")
  expect_equal(row[[3]], '=IMPORTXML("http://x","//a")')
  expect_equal(row[[4]], "007")
})

test_that("A8: the response says which write path stored the row", {
  skip_if_not_installed("V8")
  ctx <- apps_script_context(c("respondent_id", "q1"))
  apps_script_post(ctx, c(respondent_id = "r1", q1 = "ok"))
  parsed <- apps_script_reply(ctx)
  expect_equal(parsed$status, "ok")
  expect_equal(parsed$stored, "raw")
  expect_null(parsed$warning)
})

test_that("A8: without the advanced service the fallback is unsafe, and says so", {
  skip_if_not_installed("V8")
  ctx <- apps_script_context(c("respondent_id", "q1"))
  # the researcher skipped the Services step
  ctx$eval("Sheets = undefined;")
  apps_script_post(ctx, c(respondent_id = "r1", q1 = "=1+1"))
  parsed <- apps_script_reply(ctx)

  expect_equal(parsed$stored, "user_entered_with_text_format")
  expect_match(parsed$warning, "RAW", fixed = TRUE)
  # and the answer really is mangled on that path, which is why it warns: this
  # is the behaviour Google's contract allows and the old test assumed away
  row <- ctx$get("__ss.sheets['Responses'].rows[1]")
  expect_false(identical(row[[2]], "=1+1"))
})
