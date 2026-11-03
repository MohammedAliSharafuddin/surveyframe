# tests/testthat/test-drop-items.R
#
# Session 8a, item (c) (owner 2026-11-01). sframe_drop_items(instrument,
# items, from) takes items out of the named scales or models, and out of any
# plan block role that lists them with other variables. The question stays,
# and so do its responses, and nothing is recorded: amend_sframe() records
# the change, as a design amendment, since a scale's scoring changes.

test_that("(c) an item leaves the scale, its reverse key and the plan blocks listing it", {
  ins <- sframe_demo("factor_structure")$instrument
  expect_message(
    out <- sframe_drop_items(ins, "org_4", from = "organisation"),
    "org_4", class = "sframe_drop_items_message")
  sc <- out$scales[[which(vapply(out$scales, `[[`, "", "id") == "organisation")]]
  expect_false("org_4" %in% sc$items)
  expect_false("org_4" %in% (sc$reverse_items %||% character(0)))
  # The question stays.
  expect_true("org_4" %in% vapply(out$items, `[[`, "", "id"))
  # Both plan blocks listed it among their items.
  for (b in out$analysis_plan) expect_false("org_4" %in% unlist(b$roles))
  # The other scale is untouched.
  other <- out$scales[[which(vapply(out$scales, `[[`, "", "id") != "organisation")]]
  expect_identical(other, ins$scales[[which(vapply(ins$scales, `[[`, "", "id") != "organisation")]])
  # Nothing recorded, and the result still validates.
  expect_length(out$amendments %||% list(), 0L)
  expect_no_error(validate_sframe(out, strict = TRUE))
  # The question no longer names the scale it left.
  q <- out$items[[which(vapply(out$items, `[[`, "", "id") == "org_4")]]
  expect_null(q$scale_id)
})

test_that("(c) weights follow their items", {
  lik <- sframe_choice_set("a5", 1:5, c("SD", "D", "N", "A", "SA"))
  ins <- sframe_instrument("W", components = c(list(lik),
    lapply(c("w1", "w2", "w3"), function(i) sframe_item(i, i, "likert", choice_set = "a5")),
    list(sframe_scale("ws", "Weighted", items = c("w1", "w2", "w3"), weights = c(1, 2, 3)))))
  out <- suppressMessages(sframe_drop_items(ins, "w2", from = "ws"))
  expect_identical(out$scales[[1]]$items, c("w1", "w3"))
  expect_equal(out$scales[[1]]$weights, c(1, 3))
})

test_that("(c) a model drops the item from its constructs", {
  ins <- sframe_demo("sem_pls")$instrument
  out <- suppressMessages(sframe_drop_items(ins, "cq_3", from = "m1"))
  m1 <- out$models[[which(vapply(out$models, `[[`, "", "id") == "m1")]]
  expect_false("cq_3" %in% unlist(lapply(m1$measurement$constructs, `[[`, "items")))
  # Other models and the scale of the same name keep it.
  m2 <- out$models[[which(vapply(out$models, `[[`, "", "id") == "m2")]]
  expect_true("cq_3" %in% unlist(lapply(m2$measurement$constructs, `[[`, "items")))
  expect_true("cq_3" %in% out$scales[[1]]$items)
})

test_that("(c) a single-variable role keeps the item", {
  ins <- sframe_demo("likert_scale")$instrument
  ins$analysis_plan <- c(ins$analysis_plan, list(list(id = "RQ9",
    research_question = "How is org_4 answered?", method = "frequency",
    roles = list(variable = "org_4"))))
  out <- suppressMessages(sframe_drop_items(ins, "org_4", from = "organisation"))
  b <- out$analysis_plan[[length(out$analysis_plan)]]
  expect_identical(unlist(b$roles), c(variable = "org_4"))
})

test_that("(c) unknown ids and an emptied scale are errors", {
  ins <- sframe_demo("likert_scale")$instrument
  expect_error(sframe_drop_items(ins, "org_4", from = "nope"), "nope", class = "sframe_error")
  expect_error(sframe_drop_items(ins, "zzz", from = "organisation"), "zzz", class = "sframe_error")
  expect_error(sframe_drop_items(ins, c("org_1", "org_2", "org_3", "org_4"), from = "organisation"),
               "no items", class = "sframe_error")
})

test_that("(c) the drop is then a design amendment", {
  path <- tempfile(fileext = ".sframe")
  write_sframe(sframe_demo("likert_scale")$instrument, path)
  before <- read_sframe(path)
  after <- suppressMessages(sframe_drop_items(before, "org_4", from = "organisation"))
  expect_error(amend_sframe(before, after, "data_correction", "Dropped org_4.", tier = "pipeline"),
               class = "sframe_error")
  am <- suppressMessages(amend_sframe(before, after, "instrument_revision", "Dropped org_4.",
                                      deviation_report = "Loading below .40.", version = "1.1.0"))
  expect_identical(sframe_get_amendments(am)$tier, "design")
})
