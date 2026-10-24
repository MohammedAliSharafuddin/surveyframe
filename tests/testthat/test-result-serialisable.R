# tests/testthat/test-result-serialisable.R
#
# Ethos request 5 (2026-10-01). In the open_text demo, stm_topics returned
# its fitted model inside the result list, and jsonlite could not write it,
# so a host serialising the results failed. 20 blocks across the demos had
# the same trouble through the classed report each psychometric result
# carried, and the KMO and parallel-analysis objects from psych. Those now
# sit in a runtime attribute, which toJSON() leaves out, and a report's own
# fields are plain data.

serialises <- function(result) {
  is.null(tryCatch({
    jsonlite::toJSON(result, auto_unbox = TRUE, null = "null", na = "null")
    NULL
  }, error = function(e) conditionMessage(e)))
}

test_that("5: a descriptives and a quality result serialise as they stand", {
  d <- sframe_demo("first_survey")
  res <- run_analysis_plan(d$responses, d$instrument)
  for (r in res) expect_true(serialises(r), info = r$block_id)
  # The classed report is still there for this session's plots.
  rq2 <- Filter(function(r) identical(r$test, "descriptives"), res)[[1]]
  expect_s3_class(surveyframe:::sframe_runtime(rq2, "report"), "sframe_descriptives_report")
  expect_null(rq2$report_obj)
})

test_that("5: an EFA readiness result keeps KMO as plain numbers", {
  skip_if_not_installed("psych")
  d <- sframe_demo("factor_structure")
  res <- run_analysis_plan(d$responses, d$instrument)
  efa <- Filter(function(r) identical(r$test, "efa_readiness"), res)[[1]]
  expect_true(serialises(efa))
  expect_true(is.numeric(efa$kmo$MSA))
  expect_null(oldClass(efa$kmo))
})

test_that("5: every demo's plan results serialise", {
  skip_on_cran()
  for (demo in sframe_demos()$name) {
    d <- sframe_demo(demo)
    res <- suppressWarnings(suppressMessages(run_analysis_plan(d$responses, d$instrument)))
    for (r in res) expect_true(serialises(r), info = paste(demo, r$block_id))
  }
})

test_that("5: a fitted topic model stays in the session, outside the list", {
  skip_on_cran()
  skip_if_not_installed("stm")
  skip_if_not_installed("tidytext")
  d <- sframe_demo("open_text")
  res <- suppressWarnings(run_analysis_plan(d$responses, d$instrument))
  stm <- Filter(function(r) identical(r$test, "stm_topics"), res)
  skip_if(length(stm) == 0 || !is.null(stm[[1]]$error), "stm block did not run")
  expect_true(serialises(stm[[1]]))
  expect_null(stm[[1]]$fit$model)
  expect_s3_class(surveyframe:::sframe_runtime(stm[[1]], "model"), "STM")
})
