# tests/testthat/test-studio-report-helpers.R
#
# UI-1: what SurveyStudio's Report screen says about the engine and offers as
# reference styles (R/studio_report.R). Studio asked Sys.which("quarto"), so it
# said "no Quarto" where render_report() found the copy bundled with RStudio
# or Positron. It now asks sframe_quarto_find(), as render_report() does.

test_that("the Quarto line names the version and where Quarto was found", {
  found <- list(path = "/opt/quarto/bin/quarto", version = "1.8.24", source = "PATH")
  note <- surveyframe:::sframe_studio_quarto_note(found, use_quarto = TRUE)
  expect_true(note$ok)
  expect_identical(note$text,
    "Quarto 1.8.24, found on the PATH, writes the report in any reference style.")

  bundled <- list(path = "/usr/lib/rstudio/quarto", version = "1.7.3", source = "RStudio")
  expect_match(surveyframe:::sframe_studio_quarto_note(bundled, TRUE)$text,
               "1.7.3, bundled with RStudio", fixed = TRUE)
})

test_that("without Quarto the line names the remedy", {
  none <- list(path = NA_character_, version = NA_character_, source = NA_character_)
  note <- surveyframe:::sframe_studio_quarto_note(none, use_quarto = TRUE)
  expect_false(note$ok)
  expect_match(note$text, "^Quarto was not found")
  expect_match(note$text, "Install Quarto from quarto.org", fixed = TRUE)
  expect_match(note$text, "RStudio or Positron", fixed = TRUE)

  off <- surveyframe:::sframe_studio_quarto_note(none, use_quarto = FALSE)
  expect_match(off$text, "options(surveyframe.use_quarto = FALSE)", fixed = TRUE)
})

test_that("Studio asks sframe_quarto_find(), never Sys.which()", {
  src <- readLines(system.file("shiny", "app.R", package = "surveyframe"))
  expect_false(any(grepl('Sys.which("quarto")', src, fixed = TRUE)))
  expect_true(any(grepl("sframe_studio_quarto_note()", src, fixed = TRUE)))
})

# UI-1 item 3 (UX-02): Analyse shows the declared plan read-only and runs it.

test_that("the declared plan names each method, or says what is missing", {
  ins <- sframe_demo("factor_structure")$instrument
  ins$analysis_plan[[1]]$method <- NULL
  ins$analysis_plan[[1]]$test <- NULL
  ins$analysis_plan[[2]]$method <- "made_up_test"
  tbl <- surveyframe:::sframe_studio_declared_plan(ins, c(efa_readiness = "EFA readiness"))
  expect_identical(names(tbl), c("ID", "Research question", "Method", "Variables",
                                 "Percentages", "Hypotheses", "Runs"))
  expect_identical(tbl$Method, c("No method declared",
                                 "made_up_test (not a method Studio knows)"))

  ins2 <- sframe_demo("factor_structure")$instrument
  m <- ins2$analysis_plan[[1]]$method
  tbl2 <- surveyframe:::sframe_studio_declared_plan(ins2, stats::setNames("Known label", m))
  expect_identical(tbl2$Method[1], "Known label")
  expect_null(surveyframe:::sframe_studio_declared_plan(
    sframe_instrument("Empty", components = list(sframe_item("q", "Q", "text")))))
})

test_that("a cross-tab shows its declared percentages, and syntax blocks say so", {
  ins <- sframe_demo("factor_structure")$instrument
  ins$analysis_plan[[1]]$method <- "crosstab"
  ins$analysis_plan[[1]]$options <- list(percent = "row")
  ins$analysis_plan[[2]]$method <- "chi_square"
  ins$analysis_plan[[2]]$requires_data <- FALSE
  ins$analysis_plan[[2]]$hypotheses <- list(null = "No association.")
  tbl <- surveyframe:::sframe_studio_declared_plan(ins)
  expect_identical(tbl$Percentages, c("Row percentages", "Counts only"))
  expect_identical(tbl$Runs, c("Yes", "Syntax only"))
  expect_identical(tbl$Hypotheses, c("None", "Declared"))
})

plan_changed_instr <- function() {
  path <- tempfile(fileext = ".sframe")
  write_sframe(sframe_demo("factor_structure")$instrument, path)
  before <- read_sframe(path)
  after <- before
  after$analysis_plan[[2]]$research_question <- "A narrower question."
  report <- surveyframe:::sframe_studio_plan_change_report(before, after)
  list(report = report, instrument = suppressMessages(amend_sframe(before, after,
    "model_respecification", "Narrowed RQ2.", tier = "design",
    deviation_report = paste0(report, "the first wording was too broad."),
    version = "1.1.0")))
}

test_that("a plan change after the data pre-fills the blocks it changed", {
  x <- plan_changed_instr()
  expect_identical(x$report,
    "Plan changed after the responses were loaded: RQ2 changed. Reason: ")
  ins <- sframe_demo("factor_structure")$instrument
  expect_null(surveyframe:::sframe_studio_plan_change_report(ins, ins))
  more <- ins
  more$analysis_plan <- more$analysis_plan[1]
  expect_match(surveyframe:::sframe_studio_plan_change_report(ins, more),
               "RQ2 removed", fixed = TRUE)
})

test_that("the built-in report's amendment list carries the plan change text", {
  f <- tempfile(fileext = ".html")
  surveyframe:::.render_report_html(plan_changed_instr()$instrument, NULL,
                                    output_path = f, include_analysis = FALSE)
  doc <- paste(readLines(f, warn = FALSE), collapse = "\n")
  expect_match(doc, "Plan changed after the responses were loaded: RQ2 changed. Reason: the first wording was too broad.", fixed = TRUE)
})

test_that("the Quarto report's amendment list carries the plan change text", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(is.na(surveyframe:::sframe_quarto_find()$path), "Quarto is not installed")
  old <- options(surveyframe.use_quarto = TRUE)
  on.exit(options(old), add = TRUE)
  out <- tempfile(fileext = ".html")
  render_report(plan_changed_instr()$instrument, output_file = out, open = FALSE)
  doc <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_match(doc, "Plan changed after the responses were loaded: RQ2 changed. Reason: the first wording was too broad.", fixed = TRUE)
})

# UI-1 item 4 (UX-20): 2 products. The Finished report offers Word and
# OpenDocument only with Quarto, and the .qmd folder is the Reproduce tab's.
test_that("the finished report's formats follow Quarto", {
  with_q <- surveyframe:::sframe_studio_report_formats(TRUE)
  expect_identical(unname(with_q), c("html", "pdf", "docx", "odt"))
  without <- surveyframe:::sframe_studio_report_formats(FALSE)
  expect_identical(unname(without), c("html", "pdf"))
  expect_false("qmd" %in% c(with_q, without))
})

test_that("Studio offers the report and its source, and no separate notebook", {
  src <- paste(readLines(system.file("shiny", "app.R", package = "surveyframe")),
               collapse = "\n")
  expect_match(src, '"Finished report"', fixed = TRUE)
  expect_match(src, '"Reproducible source"', fixed = TRUE)
  expect_match(src, 'list(format = "qmd", output_file = dir)', fixed = TRUE)
  expect_false(grepl("sframe_analysis_qmd(", src, fixed = TRUE))
})

# UI-1 item 6 (owner 2026-11-03): the Reference style select.
test_that("the style select lists APA 7 first, the bundled styles, then a file", {
  ch <- surveyframe:::sframe_studio_style_choices(TRUE)
  expect_identical(names(ch), c("APA 7", "Chicago author-date", "Harvard", "IEEE",
                                "MLA", "Other style (.csl file)"))
  expect_identical(unname(ch), c(names(surveyframe:::sframe_csl_styles), "other"))
  expect_identical(surveyframe:::sframe_studio_style_choices(FALSE), c("APA 7" = "apa"))
})

test_that("the style select gives render_report() a style name or the file", {
  csl <- surveyframe:::sframe_studio_csl
  expect_identical(csl("harvard"), "harvard")
  expect_identical(csl(NULL), "apa")
  expect_identical(csl("unknown"), "apa")
  expect_identical(csl("other", NULL), "apa")
  expect_identical(csl("other", list(datapath = "/tmp/x.csl")), "/tmp/x.csl")
})

# UI-1 item 8 (UX-03): References is the only place a source is added.
test_that("the Report screen has no BibTeX box and cites through the shared picker", {
  src <- paste(readLines(system.file("shiny", "app.R", package = "surveyframe")),
               collapse = "\n")
  expect_false(grepl("rpt_bibtex", src, fixed = TRUE))
  expect_false(grepl("Further references", src, fixed = TRUE))
  expect_match(src, 'tags$script(src = studio_asset_src("field_tools.js"))', fixed = TRUE)
  expect_match(src, "studio_cite_field(textAreaInput(fld, NULL,", fixed = TRUE)
  expect_match(src, 'id = "rpt_manage_refs", "Manage references"', fixed = TRUE)
  expect_match(src, 'paste0("hypothesis:", hyp)', fixed = TRUE)
  expect_match(src, '"study")', fixed = TRUE)
})
