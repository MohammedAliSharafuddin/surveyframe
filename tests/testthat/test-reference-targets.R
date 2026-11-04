# tests/testthat/test-reference-targets.R
#
# Session 8b-R, item 4. A source can be cited by the hypotheses of a plan
# block, `hypothesis:<block id>`, and by the study description, `study`, as
# well as by the instrument, an item, a scale, a plan block or a model.
# validate_sframe() checks that each target exists: the block for a
# hypothesis target, with hypotheses declared, and a study for `study`.

target_instrument <- function(hypotheses = list(null = "No difference.",
                                                alternative = "A difference."),
                              study = NULL, references = list()) {
  block <- list(id = "RQ1", research_question = "Do the groups differ?",
                family = "group_comparison", method = "t_test_ind",
                roles = list(outcome = "score", group = "grp"))
  block$hypotheses <- hypotheses
  ins <- sframe_instrument(title = "Targets", components = list(
    sframe_choice_set("ab", values = c("a", "b"), labels = c("A", "B")),
    sframe_item("score", "Score", type = "numeric"),
    sframe_item("grp", "Group", type = "single_choice", choice_set = "ab")),
    analysis_plan = list(block), study = study)
  if (length(references)) ins <- sframe_add_references(ins, references)
  ins
}

ref_problems <- function(ins) surveyframe:::sframe_reference_problems(ins)

a_study <- list(problem = "Why do the groups differ?",
                objectives = list(list(id = "O1", text = "Compare the groups.")))

test_that("hypothesis:<block id> and study are cited_by targets", {
  r <- sframe_reference("h_1", "A source", cited_by = c("hypothesis:RQ1", "study"))
  expect_identical(r$cited_by, c("hypothesis:RQ1", "study"))
  expect_error(sframe_reference("h_2", "A source", cited_by = "hypotheses:RQ1"),
               "'hypothesis:<block id>'.*'study'")
})

test_that("validate_sframe() accepts a hypothesis and a study target that exist", {
  ins <- target_instrument(study = a_study, references = list(
    sframe_reference("h_1", "On the hypothesis", cited_by = "hypothesis:RQ1"),
    sframe_reference("s_1", "On the problem", cited_by = "study")))
  expect_identical(ref_problems(ins), character(0))
  expect_true(validate_sframe(ins, strict = FALSE)$valid)
})

test_that("a hypothesis target needs the block, and hypotheses declared on it", {
  ins <- target_instrument(references = list(
    sframe_reference("h_1", "Missing block", cited_by = "hypothesis:RQ9")))
  expect_match(paste(ref_problems(ins), collapse = " | "), "hypothesis 'RQ9'", fixed = TRUE)
  ins2 <- target_instrument(hypotheses = NULL, references = list(
    sframe_reference("h_1", "No hypotheses", cited_by = "hypothesis:RQ1")))
  expect_match(paste(ref_problems(ins2), collapse = " | "),
               "plan block 'RQ1' declares no hypotheses", fixed = TRUE)
  expect_false(validate_sframe(ins2, strict = FALSE)$valid)
})

test_that("a study target needs a study", {
  ins <- target_instrument(references = list(
    sframe_reference("s_1", "On the problem", cited_by = "study")))
  expect_match(paste(ref_problems(ins), collapse = " | "),
               "cited by the study, which the instrument does not describe", fixed = TRUE)
})

test_that("hypothesis and study targets survive a write and a read", {
  ins <- target_instrument(study = a_study, references = list(
    sframe_reference("h_1", "On the hypothesis", cited_by = c("hypothesis:RQ1", "study"))))
  path <- tempfile(fileext = ".sframe")
  write_sframe(ins, path)
  back <- read_sframe(path)
  expect_identical(back$references[[1]]$cited_by, c("hypothesis:RQ1", "study"))
})
