# tests/testthat/test-studio-item-flags.R
#
# UI-1: SurveyStudio's Drop from scale and Put back, and the Amendments
# screen's history and version line. Drop opens the 1 amendment dialog with
# the change from sframe_drop_items() and the reason from sframe_item_flags().
# Put back is a second amendment built from the before state Studio keeps in
# the session (an amendment entry records none), so the history keeps both.
# The browser proof is in test-studio-amend-browser.R.

skip_if_not_installed("psych")

fs_flagged <- function() {
  d <- sframe_demo("factor_structure")
  res <- suppressWarnings(run_analysis_plan(d$responses, d$instrument))
  hit <- Filter(function(r) identical(r$block_id, "RQ2"), res)[[1]]
  list(instrument = d$instrument, result = hit,
       flags = surveyframe:::sframe_studio_result_flags(hit))
}

test_that("a flagged EFA item is dropped from the scale holding it", {
  x <- fs_flagged()
  expect_identical(x$flags$item, "con_4")
  expect_identical(surveyframe:::sframe_studio_drop_targets(x$instrument, x$flags),
                   "content")

  p <- surveyframe:::sframe_studio_drop_proposal(x$instrument, x$flags)
  content <- Filter(function(s) s$id == "content", p$after$scales)[[1]]
  expect_false("con_4" %in% content$items)
  expect_match(p$defaults$reason_text, "con_4: loading .39 in RQ2, below .40",
               fixed = TRUE)
  expect_match(p$start_label, "Drop con_4 from content", fixed = TRUE)
})

test_that("a reliability flag names its scale, a CFA flag its models", {
  ins <- sframe_demo("factor_structure")$instrument
  rel <- data.frame(result_type = "reliability", block = "B", group = "organisation",
                    item = "org_4", reason = "r", stringsAsFactors = FALSE)
  expect_identical(surveyframe:::sframe_studio_drop_targets(ins, rel), "organisation")
  cfa <- rel
  cfa$result_type <- "cfa"
  cfa$group <- "ORG"
  expect_identical(surveyframe:::sframe_studio_drop_targets(ins, cfa), character(0))
  expect_null(surveyframe:::sframe_studio_drop_proposal(ins, cfa))
})

test_that("Put back is a second amendment that restores the scale and the item", {
  x <- fs_flagged()
  p <- surveyframe:::sframe_studio_drop_proposal(x$instrument, x$flags)
  dropped <- suppressMessages(amend_sframe(
    x$instrument, p$after, reason_code = "model_respecification",
    reason_text = p$defaults$reason_text, tier = "design",
    deviation_report = p$defaults$deviation_report, version = "1.1.0"))
  drop <- list(item = p$item, before = x$instrument, after = dropped)

  restored <- surveyframe:::sframe_studio_put_back(dropped, drop)
  expect_identical(restored$scales, x$instrument$scales)
  expect_identical(restored$items, x$instrument$items)
  back <- suppressMessages(amend_sframe(
    dropped, restored, reason_code = "model_respecification",
    reason_text = "Put con_4 back in content.", tier = "design",
    deviation_report = "Undoing the drop.", version = "1.2.0"))
  log <- sframe_get_amendments(back)
  expect_identical(nrow(log), 2L)
  expect_identical(log$previous_hash[2], log$new_hash[1])
  expect_identical(surveyframe:::sframe_studio_version_label(back),
                   "1.2.0, 2 amendments")

  hist <- surveyframe:::sframe_studio_amendment_history(back)
  expect_identical(names(hist), c("Date", "Tier", "Reason", "What changed",
                                  "Deviation report", "Hash before", "Hash after"))
  expect_identical(hist$Tier, c("Design", "Design"))
  expect_match(hist$Reason[2], "^Model respecification: Put con_4 back")
  expect_identical(hist$`Hash before`[2], hist$`Hash after`[1])
  expect_identical(nchar(hist$`Hash after`), c(12L, 12L))
})

test_that("Put back refuses a scale changed again since the drop", {
  x <- fs_flagged()
  p <- surveyframe:::sframe_studio_drop_proposal(x$instrument, x$flags)
  drop <- list(item = p$item, before = x$instrument, after = p$after)
  later <- p$after
  k <- which(vapply(later$scales, function(s) s$id, "") == "content")
  later$scales[[k]]$items <- setdiff(later$scales[[k]]$items, "con_3")
  expect_error(surveyframe:::sframe_studio_put_back(later, drop),
               class = "sframe_put_back_error")
})

test_that("the version label counts the amendments", {
  ins <- sframe_demo("factor_structure")$instrument
  expect_match(surveyframe:::sframe_studio_version_label(ins), ", no amendments$")
  expect_null(surveyframe:::sframe_studio_amendment_history(ins))
})
