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
