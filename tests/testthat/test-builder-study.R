# tests/testthat/test-builder-study.R
#
# D13 in SurveyBuilder: the Study tab of Survey settings edits the study an
# instrument serves, the problem, the objectives and the sampling plan, run
# under V8 (helper-v8-builder.R). What it saves goes back through
# read_sframe() and validate_sframe(). A study left alone keeps its content
# hash, and the builder refuses what the validator would.

study_instrument <- function(study = NULL, objective = NULL) {
  block <- list(id = "rq1", research_question = "Does satisfaction differ by group?",
                family = "group_comparison", method = "t_test_ind", test = "t_test_ind",
                roles = list(outcome = "sat", group = "group"),
                variables = c("sat", "group"))
  if (!is.null(objective)) block$objective <- objective
  sframe_instrument(
    "Study tab", version = "1.0.0",
    components = list(
      sframe_item("sat", "Satisfaction", type = "numeric"),
      sframe_item("group", "Group", type = "single_choice", choice_set = "yn"),
      sframe_choice_set("yn", c("0", "1"), c("No", "Yes"))),
    analysis_plan = list(block), study = study)
}

a_study <- list(
  problem = "Why do delegates not return?",
  objectives = list(list(id = "O1", text = "Describe the reasons for not returning.")),
  sampling = list(population = "Delegates of 2026", method = "convenience", planned_n = 120L))

study_save <- function(ctx, inputs = list(), objs = NULL) {
  ctx$call("openSettings", "study")
  for (id in names(inputs)) {
    ctx$eval(sprintf("document.getElementById(%s).value = %s;",
                     jsonlite::toJSON(id, auto_unbox = TRUE),
                     jsonlite::toJSON(inputs[[id]], auto_unbox = TRUE)))
  }
  if (!is.null(objs)) ctx$eval(sprintf("studyObjs = %s;", jsonlite::toJSON(objs, auto_unbox = TRUE)))
  ctx$call("saveSettings")
}

test_that("a study opened and saved untouched keeps the content hash", {
  # The file as written is the reference: a plan block built by hand is
  # normalised on writing, so the object in memory hashes differently.
  src <- tempfile(fileext = ".sframe")
  write_sframe(study_instrument(a_study, objective = "O1"), src)
  ins <- read_sframe(src)
  ctx <- builder_context()
  builder_open(ctx, ins)
  study_save(ctx)
  back <- read_sframe(builder_save(ctx))
  expect_identical(sframe_content_hash(back), sframe_content_hash(ins))
  expect_match(builder_toasts(ctx)$msg, "No settings changed", fixed = TRUE, all = FALSE)
})

test_that("the Study tab shows the study as saved", {
  ctx <- builder_context()
  builder_open(ctx, study_instrument(a_study))
  ctx$call("openSettings", "study")
  expect_identical(ctx$get("document.getElementById('s-problem').value"), a_study$problem)
  expect_identical(ctx$get("document.getElementById('s-method').value"), "convenience")
  expect_identical(ctx$get("document.getElementById('s-n').value"), "120")
  expect_identical(ctx$get("studyObjs")$id, "O1")
})

test_that("a study typed in saves in the shape write_sframe() writes", {
  ctx <- builder_context()
  builder_open(ctx, study_instrument(), new_instrument = TRUE)
  study_save(ctx,
             list(`s-problem` = "  Why do delegates not return?  ", `s-pop` = "Delegates of 2026",
                  `s-method` = "other", `s-other` = "Intercept at the exit", `s-n` = "120"),
             objs = list(list(id = "O1", text = "Describe the reasons."),
                         list(id = "O2", text = "Compare first-time and repeat delegates."),
                         list(id = "", text = "")))
  back <- read_sframe(builder_save(ctx))
  st <- sframe_get_study(back)
  expect_identical(st$problem, "Why do delegates not return?")
  expect_identical(vapply(st$objectives, function(o) o$id, ""), c("O1", "O2"))
  expect_identical(st$sampling$method_other, "Intercept at the exit")
  expect_identical(st$sampling$planned_n, 120L)
  expect_true(validate_sframe(back)$valid)
})

test_that("method_other is dropped when the method is not Other", {
  ctx <- builder_context()
  builder_open(ctx, study_instrument(), new_instrument = TRUE)
  study_save(ctx, list(`s-method` = "quota", `s-other` = "left over"))
  back <- read_sframe(builder_save(ctx))
  expect_identical(back$study$sampling, list(method = "quota"))
})

test_that("the builder refuses what the validator refuses, and saves nothing", {
  cases <- list(
    list(inputs = list(`s-method` = "other"), msg = "The sampling method is Other, so describe it."),
    list(inputs = list(`s-n` = "2.5"), msg = "The planned sample size must be a whole number of 1 or more."),
    list(objs = list(list(id = "1st", text = "x")), msg = "Objective 1 needs an id"),
    list(objs = list(list(id = "O1", text = "a"), list(id = "O1", text = "b")),
         msg = "Objective id O1 is used more than once."),
    list(objs = list(list(id = "O1", text = "")), msg = "Objective O1 needs its text."))
  for (case in cases) {
    ctx <- builder_context()
    builder_open(ctx, study_instrument(), new_instrument = TRUE)
    study_save(ctx, if (is.null(case$inputs)) list() else case$inputs, case$objs)
    expect_match(builder_toasts(ctx)$msg, case$msg, fixed = TRUE, all = FALSE)
    expect_null(read_sframe(builder_save(ctx))$study)
  }
})

test_that("an objective a plan names cannot be removed", {
  ctx <- builder_context()
  builder_open(ctx, study_instrument(a_study, objective = "O1"))
  study_save(ctx, objs = list(list(id = "O2", text = "Another aim.")))
  expect_match(builder_toasts(ctx)$msg, "Plan rq1 names objective O1.", fixed = TRUE, all = FALSE)
  expect_identical(read_sframe(builder_save(ctx))$study$objectives[[1]]$id, "O1")
})

test_that("clearing every field drops the study", {
  ctx <- builder_context()
  builder_open(ctx, study_instrument(a_study), new_instrument = TRUE)
  study_save(ctx, list(`s-problem` = "", `s-pop` = "", `s-method` = "", `s-n` = ""), objs = list())
  path <- builder_save(ctx)
  expect_false(grepl("\"study\"", paste(readLines(path), collapse = "\n"), fixed = TRUE))
})
