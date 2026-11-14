# Each teaching demo tells a study (Session 10, owner 2026-11-14): a
# placeholder author, a research-style purpose, the study's problem,
# objectives and sampling, and H0, H1 and a decision rule on each inferential
# block, so its pre-analysis plan shows every section.

teaching <- function() with(sframe_list_demos(), name[focus != "reference"])

test_that("every teaching demo has the placeholder author and a full study", {
  for (name in teaching()) {
    ins <- sframe_demo(name, preview = FALSE)$instrument
    expect_identical(ins$meta$authors, "Demo author", info = name)
    s <- sframe_get_study(ins)
    expect_true(nzchar(s$problem %||% ""), info = name)
    expect_gte(length(s$objectives), 1)
    expect_true(all(c("population", "method", "planned_n") %in% names(s$sampling)), info = name)
    expect_false(grepl("surveyframe|demo|teaches", ins$meta$description, ignore.case = TRUE), info = name)
  }
})

test_that("every inferential block declares H0, H1 and a decision rule", {
  inferential <- surveyframe:::sframe_inferential_methods
  for (name in teaching()) {
    for (b in sframe_demo(name, preview = FALSE)$instrument$analysis_plan) {
      if (!surveyframe:::sframe_analysis_method(b) %in% inferential) next
      who <- paste(name, b$id)
      expect_true(nzchar(b$hypotheses$null %||% ""), info = who)
      expect_true(nzchar(b$hypotheses$alternative %||% ""), info = who)
      expect_true(nzchar(b$decision_rule %||% ""), info = who)
    }
  }
})

test_that("every block serves an objective of its study", {
  for (name in teaching()) {
    ins <- sframe_demo(name, preview = FALSE)$instrument
    ids <- vapply(ins$study$objectives, function(o) o$id, character(1))
    for (b in ins$analysis_plan) expect_true(isTRUE(b$objective %in% ids), info = paste(name, b$id))
  }
})

test_that("the two_group plan shows the author, the purpose and the hypotheses", {
  ins <- sframe_demo("two_group", preview = FALSE)$instrument
  md <- paste(surveyframe:::sframe_plan_md(surveyframe:::sframe_plan_blocks(ins)), collapse = "\n")
  expect_match(md, "**Authors:** Demo author", fixed = TRUE)
  expect_match(md, "**Population:** Attendees of a hybrid conference", fixed = TRUE)
  expect_match(md, "**Null hypothesis (H0):**", fixed = TRUE)
  expect_false(grepl("commonest comparison", md, fixed = TRUE))
})

test_that("the 2 reference datasets have the placeholder author, a study and hypotheses", {
  for (name in c("tourism_services", "input_types")) {
    ins <- sframe_demo(name, preview = FALSE)$instrument
    expect_identical(ins$meta$authors, "Demo author", info = name)
    s <- sframe_get_study(ins)
    expect_true(nzchar(s$problem %||% ""), info = name)
    ids <- vapply(s$objectives, function(o) o$id, character(1))
    for (b in ins$analysis_plan) {
      who <- paste(name, b$id)
      expect_true(isTRUE(b$objective %in% ids), info = who)
      if (!surveyframe:::sframe_method_uses_alpha(surveyframe:::sframe_analysis_method(b))) next
      expect_true(nzchar(b$hypotheses$null %||% ""), info = who)
      expect_true(nzchar(b$decision_rule %||% ""), info = who)
    }
  }
})
