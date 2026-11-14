# Each stage names the one after it, in an interactive session and for a
# call made at the console (Session 10, first contact section 5 item 5).
# Calls are evaluated in the global environment, as typed at the console.

stage_messages <- function(call) {
  got <- character(0)
  withCallingHandlers(
    eval(call, envir = globalenv()),
    sframe_next_stage = function(m) {
      got <<- c(got, conditionMessage(m))
      invokeRestart("muffleMessage")
    },
    message = function(m) invokeRestart("muffleMessage"))
  got
}

test_that("each stage names the next at the console", {
  local_mocked_bindings(sframe_is_interactive = function() TRUE)
  old <- options(knitr.in.progress = NULL)
  on.exit(options(old), add = TRUE)
  d <- sframe_demo("two_group", preview = FALSE)
  raw <- utils::read.csv(d$responses_path)
  m <- stage_messages(bquote(write_sframe(.(d$instrument), .(tempfile(fileext = ".sframe")))))
  expect_match(m, "^Saved 'In person or online\\?' to .*\\. Next: collect responses with export_survey\\(\\)")
  m <- stage_messages(bquote(export_survey(.(d$instrument), .(tempfile(fileext = ".html")), open = FALSE)))
  expect_match(m, "Next: read their answers with read_responses\\(\\)")
  m <- stage_messages(bquote(read_responses(.(raw), .(d$instrument), respondent_id = "respondent_id",
                                            meta_cols = c("started_at", "submitted_at"))))
  expect_identical(m, paste0("Read 60 responses to 'In person or online?'. Next: run the ",
                             "planned analyses with run_analysis_plan(responses, instrument)."))
  m <- stage_messages(bquote(run_analysis_plan(.(d$responses), .(d$instrument))))
  expect_identical(m, paste0("Ran 2 planned analyses. Next: write the report with ",
                             "render_report(instrument, responses)."))
  m <- stage_messages(bquote(render_report(.(d$instrument), .(d$responses),
                                           output_file = .(tempfile(fileext = ".html")), open = FALSE)))
  expect_length(m, 1)
  expect_match(m, "^The report is written\\. Next: share it with the \\.sframe file")
  m <- stage_messages(bquote(export_google_sheet(.(d$instrument), sheet_url = "https://docs.google.com/spreadsheets/d/x",
                                                 output_dir = .(tempdir()))))
  expect_match(m, "read them with read_sheet_responses\\(\\)")
})

test_that("an instrument with no plan is pointed at describing its answers", {
  local_mocked_bindings(sframe_is_interactive = function() TRUE)
  d <- sframe_demo("two_group", preview = FALSE)
  ins <- d$instrument
  ins$analysis_plan <- list()
  raw <- utils::read.csv(d$responses_path)
  m <- stage_messages(bquote(read_responses(.(raw), .(ins), respondent_id = "respondent_id",
                                            meta_cols = c("started_at", "submitted_at"))))
  expect_match(m, "sframe_item_results\\(\\)\\.$")
})

test_that("not interactive, inside a function or inside the package, no stage message", {
  d <- sframe_demo("two_group", preview = FALSE)
  local_mocked_bindings(sframe_is_interactive = function() FALSE)
  expect_length(stage_messages(bquote(run_analysis_plan(.(d$responses), .(d$instrument)))), 0)
  local_mocked_bindings(sframe_is_interactive = function() TRUE)
  wrapped <- bquote((function() run_analysis_plan(.(d$responses), .(d$instrument)))())
  expect_length(stage_messages(wrapped), 0)
  expect_length(stage_messages(quote(sframe_demo("two_group", preview = FALSE))), 0)
  old <- options(knitr.in.progress = TRUE)
  on.exit(options(old), add = TRUE)
  expect_length(stage_messages(bquote(run_analysis_plan(.(d$responses), .(d$instrument)))), 0)
})
