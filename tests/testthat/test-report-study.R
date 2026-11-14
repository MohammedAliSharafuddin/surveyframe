# tests/testthat/test-report-study.R
#
# Session 8b-R, item 7 (D13 in the report, found at 8a close). The report's
# plan section prints the study problem, the objectives, and the trace from
# each objective to the research questions that serve it, in both engines.

study_instrument <- function() {
  ins <- sframe_demo("likert_scale")$instrument
  ins$study <- list(
    problem = "Event organisers do not know whether attendees found the event well run.",
    objectives = list(list(id = "O1", text = "Describe how organised the event felt."),
                      list(id = "O2", text = "Check that the organisation scale is reliable."),
                      list(id = "O3", text = "Compare first-time and returning attendees.")))
  ids <- vapply(ins$analysis_plan, function(b) b$id, character(1))
  # The demo's blocks name its own study's objectives (Session 10), cleared
  # here so only the 3 below are linked.
  for (k in seq_along(ins$analysis_plan)) ins$analysis_plan[[k]]$objective <- NULL
  ins$analysis_plan[[match("RQ1", ids)]]$objective <- "O1"
  ins$analysis_plan[[match("RQ2", ids)]]$objective <- "O2"
  ins$analysis_plan[[match("RQ3", ids)]]$objective <- "O2"
  ins
}

test_that("the trace table maps each objective to the questions that serve it", {
  s <- surveyframe:::sframe_report_study(study_instrument())
  expect_identical(s$problem, study_instrument()$study$problem)
  expect_identical(s$objectives$ID, c("O1", "O2", "O3"))
  expect_identical(names(s$trace), c("Objective", "Research questions"))
  expect_match(s$trace$`Research questions`[2], "RQ2.*RQ3")
  expect_identical(s$trace$`Research questions`[3], "none yet")
  expect_match(s$unlinked, "RQ4", fixed = TRUE)
  # The demos declare a study since Session 10, so 1 without it is made here.
  plain <- sframe_demo("likert_scale")$instrument
  plain$study <- NULL
  expect_null(surveyframe:::sframe_report_study(plain))
})

study_checks <- function(doc) {
  plan <- substring(doc, regexpr("Analysis Plan</h2>", doc, fixed = TRUE))
  expect_match(plan, "Event organisers do not know", fixed = TRUE)
  expect_match(plan, "Describe how organised the event felt.", fixed = TRUE)
  expect_match(plan, "Objectives and the research questions that serve them", fixed = TRUE)
  expect_match(plan, "none yet", fixed = TRUE)
  # The study comes before the first research question.
  expect_lt(regexpr("Event organisers do not know", plan, fixed = TRUE),
            regexpr("RQ 1:", plan, fixed = TRUE))
}

test_that("the built-in report prints the study in its plan section", {
  d <- sframe_demo("likert_scale")
  f <- tempfile(fileext = ".html")
  surveyframe:::.render_report_html(study_instrument(), d$responses, output_path = f,
                                    show_code = FALSE)
  study_checks(paste(readLines(f, warn = FALSE), collapse = "\n"))
  # With no data the page is the pre-analysis plan (Session 10): the study
  # opens it, with the objectives table, before the first research question.
  f2 <- tempfile(fileext = ".html")
  surveyframe:::.render_report_html(study_instrument(), NULL, output_path = f2)
  plan <- paste(readLines(f2, warn = FALSE), collapse = "\n")
  expect_match(plan, "Event organisers do not know", fixed = TRUE)
  expect_match(plan, "Describe how organised the event felt.", fixed = TRUE)
  expect_match(plan, "Objectives and the research questions that serve them", fixed = TRUE)
  expect_match(plan, "none yet", fixed = TRUE)
  expect_lt(regexpr("Event organisers do not know", plan, fixed = TRUE),
            regexpr("<h3>RQ1:", plan, fixed = TRUE))
})

test_that("the Quarto report prints the study in its plan section", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  old <- options(surveyframe.use_quarto = TRUE)
  on.exit(options(old), add = TRUE)
  d <- sframe_demo("likert_scale")
  out <- tempfile(fileext = ".html")
  res <- suppressMessages(render_report(study_instrument(), data = d$responses,
                                        output_file = out, show_code = FALSE, open = FALSE))
  expect_identical(attr(res, "engine"), "quarto")
  study_checks(paste(readLines(out, warn = FALSE), collapse = "\n"))
})
