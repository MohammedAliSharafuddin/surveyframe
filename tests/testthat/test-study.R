# tests/testthat/test-study.R
#
# D13 (decided 2026-10-30), the R side. A top-level `study` field holds the
# problem statement, the objectives and the sampling plan, so the chain a
# supervisor or pre-registration reviewer reads starts at the problem, not
# at the research questions. Bounded so it stays a declaration the package
# can check: objectives are short items with ids, a plan block names the
# objective it serves, the sampling method comes from a fixed list. Inside
# the content hash, never on the respondent's page, and a change to it after
# collection is a design amendment.

study_instr <- function(study = NULL, plan_objective = "O1") {
  ins <- sframe_demo("likert_scale")$instrument
  # A new instrument built in R from the demo, not an edit of its file.
  attr(ins, "sframe_origin") <- NULL
  if (!is.null(plan_objective)) {
    for (k in seq_along(ins$analysis_plan)) ins$analysis_plan[[k]]$objective <- plan_objective
  }
  ins$study <- study %||% list(
    problem = "Students rate course organisation poorly, and no one knows which parts.",
    objectives = list(list(id = "O1", text = "Measure perceived organisation.")),
    sampling = list(population = "Undergraduates on the course",
                    method = "convenience", planned_n = 120L))
  ins
}
roundtrip <- function(ins) {
  path <- tempfile(fileext = ".sframe")
  write_sframe(ins, path)
  read_sframe(path)
}

test_that("D13: sframe_instrument(study = ) stores it, and it survives a write and read", {
  ins <- sframe_instrument("S", components = list(sframe_item("q1", "Q?", "text")),
    study = list(problem = "Why?", objectives = list(list(id = "O1", text = "Find out.")),
                 sampling = list(population = "Staff", method = "census", planned_n = 40)))
  expect_identical(sframe_get_study(ins)$problem, "Why?")
  back <- roundtrip(ins)
  expect_identical(back$study$problem, "Why?")
  expect_identical(back$study$objectives[[1]]$id, "O1")
  expect_identical(back$study$sampling$method, "census")
  expect_identical(back$study$sampling$planned_n, 40L)
  expect_identical(sframe_content_hash(back), sframe_content_hash(roundtrip(back)))
})

test_that("D13: an instrument without a study hashes as before, and the study is inside the hash", {
  plain <- sframe_demo("likert_scale")$instrument
  expect_false("study" %in% names(sframe_serialization_payload(plain)))
  with <- study_instr()
  expect_false(identical(sframe_content_hash(with), sframe_content_hash(study_instr(
    list(problem = "Another problem.", objectives = list(list(id = "O1", text = "Measure perceived organisation.")))))))
})

test_that("D13: the validator refuses a malformed study", {
  bad <- function(study, plan_objective = "O1") {
    v <- validate_sframe(study_instr(study, plan_objective), strict = FALSE)
    expect_false(sframe_is_valid(v))
    paste(sframe_problems(v), collapse = "\n")
  }
  expect_match(bad(list(problem = c("a", "b"))), "problem", fixed = TRUE)
  expect_match(bad(list(objectives = list(list(id = "O1", text = "A"), list(id = "O1", text = "B")))),
               "more than once", fixed = TRUE)
  expect_match(bad(list(objectives = list(list(id = "O 1", text = "A"))), plan_objective = NULL), "id", fixed = TRUE)
  expect_match(bad(list(objectives = list(list(id = "O1", text = "")))), "text", fixed = TRUE)
  expect_match(bad(list(sampling = list(method = "whoever turns up")), plan_objective = NULL), "method", fixed = TRUE)
  expect_match(bad(list(sampling = list(planned_n = -3)), plan_objective = NULL), "planned_n", fixed = TRUE)
  expect_match(bad(list(objectives = list(list(id = "O1", text = "A"))), plan_objective = "O9"), "O9", fixed = TRUE)
  expect_match(bad(list(aims = "x"), plan_objective = NULL), "aims", fixed = TRUE)
})

test_that("D13: an untraced objective or question and a long problem are notes, not problems", {
  ins <- study_instr(list(
    problem = paste(rep("word", 160), collapse = " "),
    objectives = list(list(id = "O1", text = "Measure it."), list(id = "O2", text = "Explain it."))))
  ins$analysis_plan[[1]]$objective <- NULL
  v <- validate_sframe(ins, strict = FALSE)
  expect_true(sframe_is_valid(v))
  notes <- sframe_notes(v)
  expect_true(any(grepl("O2", notes, fixed = TRUE)))
  expect_true(any(grepl(ins$analysis_plan[[1]]$id, notes, fixed = TRUE)))
  expect_true(any(grepl("150 words", notes, fixed = TRUE)))
  expect_match(paste(utils::capture.output(print(v)), collapse = "\n"), "Notes", fixed = TRUE)
  expect_length(sframe_notes(validate_sframe(study_instr(), strict = FALSE)), 0L)
})

test_that("D13: a study change after collection is a design amendment", {
  before <- roundtrip(study_instr())
  after <- before
  after$study$objectives[[1]]$text <- "Measure and explain perceived organisation."
  expect_error(amend_sframe(before, after, "other", "Reworded O1.", tier = "pipeline"),
               "study", class = "sframe_error")
  am <- suppressMessages(amend_sframe(before, after, "other", "Reworded O1.",
                                      deviation_report = "The objective widened."))
  expect_identical(sframe_get_amendments(am)$tier, "design")
})

test_that("D13: the respondent's page never carries the study", {
  out <- tempfile(fileext = ".html")
  export_survey(study_instr(), output_path = out, open = FALSE)
  page <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_false(grepl("no one knows which parts", page, fixed = TRUE))
  expect_false(grepl("Measure perceived organisation", page, fixed = TRUE))
})

test_that("D13: SurveyBuilder and Studio carry the study through a save", {
  ins <- study_instr()
  ctx <- builder_context()
  builder_open(ctx, ins)
  back <- read_sframe(builder_save(ctx))
  expect_identical(back$study, roundtrip(ins)$study)
  # A study change is a design change to the builder too.
  ctx$eval("var o = S._origin; S._carry.study.problem = 'Changed.';")
  expect_identical(ctx$eval("String(sframeAmendInfo(S._origin, sframePayload()).design_forced)"), "true")

  state <- sframe_builder_state_from_instrument(roundtrip(ins))
  again <- do.call(sframe_builder_compose_instrument, state)
  expect_identical(again$study, roundtrip(ins)$study)
})

test_that("D13: an other method is described, and the methods are grouped", {
  v <- validate_sframe(study_instr(list(sampling = list(method = "other")), plan_objective = NULL),
                       strict = FALSE)
  expect_match(paste(sframe_problems(v), collapse = "\n"), "method_other", fixed = TRUE)
  ok <- study_instr(list(sampling = list(method = "other", method_other = "Intercept at the exit.")),
                    plan_objective = NULL)
  expect_true(sframe_is_valid(validate_sframe(ok, strict = FALSE)))
  expect_identical(roundtrip(ok)$study$sampling$method_other, "Intercept at the exit.")
  stray <- study_instr(list(sampling = list(method = "census", method_other = "x")), plan_objective = NULL)
  expect_false(sframe_is_valid(validate_sframe(stray, strict = FALSE)))
  expect_identical(sframe_sampling_methods("non_probability"),
                   c("convenience", "purposive", "quota", "snowball"))
  expect_setequal(sframe_sampling_methods(), c(sframe_sampling_methods("probability"),
    sframe_sampling_methods("non_probability"), "census", "other"))
})
