# tests/testthat/test-amend-scale-tier.R
#
# Session 8a, item (a) (owner 2026-11-01). amend_sframe() forced the design
# tier for a change to the analysis plan, a model or a conjoint design, and
# not for a scale. Dropping an item from a scale, reverse keying one or
# changing its weights changes every score the plan analyses, so it is a
# design-tier change and needs a deviation report. A scale's label is wording.

scale_instr <- function(items = c("s1", "s2", "s3"), reverse = NULL,
                        weights = NULL, label = "Satisfaction") {
  lik <- sframe_choice_set("agree5", 1:5,
                          c("SD", "D", "N", "A", "SA"))
  comps <- c(list(lik), lapply(c("s1", "s2", "s3"), function(id)
    sframe_item(id, paste("Item", id), "likert", choice_set = "agree5")),
    list(sframe_scale("sat", label, items = items, reverse_items = reverse,
                      weights = weights)))
  sframe_instrument("Scales", version = "1.0.0", components = comps)
}

test_that("(a) a change to a scale's items is design tier", {
  expect_error(
    amend_sframe(scale_instr(), scale_instr(items = c("s1", "s2")),
                 "data_correction", "Dropped s3.", tier = "pipeline"),
    "scale", class = "sframe_error")
  expect_error(
    amend_sframe(scale_instr(), scale_instr(items = c("s1", "s2")),
                 "data_correction", "Dropped s3."),
    "deviation_report", class = "sframe_error")
  am <- amend_sframe(scale_instr(), scale_instr(items = c("s1", "s2")),
                     "instrument_revision", "Dropped s3.",
                     deviation_report = "s3 loaded below .40.")
  expect_identical(sframe_get_amendments(am)$tier, "design")
})

test_that("(a) reverse keys and weights are design tier", {
  expect_error(
    amend_sframe(scale_instr(), scale_instr(reverse = "s2"),
                 "data_correction", "Reverse keyed s2."),
    "deviation_report", class = "sframe_error")
  expect_error(
    amend_sframe(scale_instr(), scale_instr(weights = c(1, 1, 2)),
                 "data_correction", "Weighted s3."),
    "deviation_report", class = "sframe_error")
})

test_that("(a) a new or removed scale is design tier", {
  two <- scale_instr()
  two$scales <- c(two$scales, list(sframe_scale("sat2", "Second",
                                                items = c("s1", "s2"))))
  expect_error(amend_sframe(scale_instr(), two, "data_correction", "Added."),
               "deviation_report", class = "sframe_error")
})

test_that("(a) a scale's label alone stays pipeline", {
  am <- amend_sframe(scale_instr(), scale_instr(label = "Overall satisfaction"),
                     "other", "Renamed the scale.", tier = "pipeline")
  expect_identical(sframe_get_amendments(am)$tier, "pipeline")
})
