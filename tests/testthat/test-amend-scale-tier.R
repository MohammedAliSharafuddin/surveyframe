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

# Fable sitting 1 FR-06. An item's own reverse = TRUE, which score_scales()
# applies as the scale's reverse_items, passed as a pipeline amendment, and
# moved the 4 probe scores from 1.25, 2.25, 4.75, 4.5 to 2.25, 2.75, 3.75, 4.
# So did recoding a scored item's choice codes, changing an attention check's
# pass value and removing an item's scale_id.

scored_instr <- function() {
  comps <- list(
    sframe_choice_set("agree5", 1:5, c("SD", "D", "N", "A", "SA")),
    sframe_choice_set("grp", c("a", "b"), c("A", "B")))
  comps <- c(comps, lapply(1:4, function(i)
    sframe_item(paste0("s_", i), paste("Item", i), "likert", choice_set = "agree5",
                scale_id = "sat")))
  comps <- c(comps, list(
    sframe_item("grp_q", "Group", "single_choice", choice_set = "grp"),
    sframe_item("att", "Select Agree", "likert", choice_set = "agree5"),
    sframe_scale("sat", "Satisfaction", items = paste0("s_", 1:4)),
    sframe_attention_check("ac1", "att", pass_values = 4)))
  sframe_instrument("Scored", version = "1.0.0", components = comps)
}

test_that("FR-06: what moves a score or a flag outside the scale is design tier", {
  changes <- list(
    item_reverse = function(x) { x$items[[1]]$reverse <- TRUE; x },
    codes_reversed = function(x) { x$choices[[1]]$values <- 5:1; x },
    codes_shifted = function(x) { x$choices[[1]]$values <- 0:4; x },
    pass_value = function(x) { x$checks[[1]]$pass_values <- 2; x },
    scale_id_removed = function(x) { x$items[[2]]$scale_id <- NULL; x })
  for (n in names(changes)) {
    expect_error(amend_sframe(scored_instr(), changes[[n]](scored_instr()),
                              "data_correction", "Tidy up", tier = "pipeline"),
                 "design-tier", class = "sframe_validation_error", label = n)
  }
  p <- sframe_amendment_preview(scored_instr(), changes$item_reverse(scored_instr()))
  expect_true(p$design_forced)
  expect_identical(p$design_changes, "the items' reverse keys")
})

test_that("FR-06: wording and a code no scale scores stay pipeline", {
  wording <- scored_instr()
  wording$items[[1]]$label <- "Reworded"
  other_codes <- scored_instr()
  other_codes$choices[[2]]$values <- c("x", "y")
  added <- scored_instr()
  added$items <- c(added$items, list(sframe_item("note", "Anything else?", "text")))
  for (new in list(wording, other_codes, added)) {
    am <- amend_sframe(scored_instr(), new, "data_correction", "Tidy up", tier = "pipeline")
    expect_identical(sframe_get_amendments(am)$tier, "pipeline")
  }
})
