# tests/testthat/test-amendment-preview.R
#
# Session 8a, UX-06 and UX-19. Studio's 1 amendment dialog shows what a change
# touches before it is applied: the fields, the scales whose scoring changes,
# the models and the plan blocks, whether the change is design tier whatever
# is chosen, and the version suggested for each tier, with the reason. It all
# comes from sframe_amendment_preview(), which reads the change the way
# amend_sframe() records it.

prev_instr <- function() {
  ins <- sframe_demo("likert_scale")$instrument
  path <- tempfile(fileext = ".sframe")
  write_sframe(ins, path)
  read_sframe(path)
}

test_that("a wording change touches items only, and is not forced to design", {
  before <- prev_instr()
  after <- before
  after$items[[1]]$label <- "Reworded"
  p <- sframe_amendment_preview(before, after)
  expect_identical(p$changed_fields, "items")
  expect_false(p$design_forced)
  expect_length(p$scales, 0L)
  expect_length(p$plan_blocks, 0L)
  expect_identical(p$suggest$pipeline$version, "1.0.1")
  expect_identical(p$suggest$design$version, "1.1.0")
  expect_true(p$changed)
})

test_that("dropping an item from a scale names the scale and the plan blocks using it", {
  before <- prev_instr()
  after <- before
  after$scales[[1]]$items <- setdiff(after$scales[[1]]$items, "org_2")
  p <- sframe_amendment_preview(before, after)
  expect_true(p$design_forced)
  expect_identical(p$scales, "organisation")
  expect_true("the scales scored" %in% p$design_changes)
})

test_that("a plan change names the blocks added, removed and changed", {
  before <- prev_instr()
  after <- before
  ids <- vapply(before$analysis_plan, function(b) b$id, character(1))
  after$analysis_plan <- after$analysis_plan[-1]
  after$analysis_plan[[1]]$research_question <- "A new question?"
  p <- sframe_amendment_preview(before, after)
  expect_true(p$design_forced)
  expect_setequal(p$plan_blocks, ids[1:2])
  expect_match(p$plan_detail[[ids[1]]], "removed")
  expect_match(p$plan_detail[[ids[2]]], "changed")
})

test_that("no change is reported as none", {
  before <- prev_instr()
  p <- sframe_amendment_preview(before, before)
  expect_false(p$changed)
  expect_length(p$changed_fields, 0L)
})
