# tests/testthat/test-results-display-fixes.R
# Fixes to results, tables and their display on the R side, with one test or
# more each.

u43_display_instrument <- function() {
  sframe_instrument("Display items", components = list(
    sframe_item("sec_1", "Part 1", type = "section_break"),
    sframe_item("intro", "Please read this first.", type = "text_block"),
    sframe_item("q1", "How was it?", type = "text"),
    sframe_item("age", "Age", type = "numeric")))
}

test_that("A run_survey() response row has no column for display items", {
  row <- sframe_response_row(u43_display_instrument(),
                             list(q1 = "fine", age = 30), list(), Sys.time())
  expect_false(any(c("sec_1", "intro") %in% names(row)))
  expect_true(all(c("q1", "age") %in% names(row)))
})

test_that("The blank response template follows the instrument's columns", {
  ins <- u43_display_instrument()
  cols <- sframe_response_template_columns(ins)
  expect_identical(cols, c("respondent_id", "started_at", "submitted_at", "q1", "age"))
  f <- tempfile(fileext = ".csv")
  on.exit(unlink(f))
  sframe_write_response_template(ins, f)
  back <- utils::read.csv(f, check.names = FALSE)
  expect_identical(names(back), cols)
  expect_equal(nrow(back), 0L)
  # a demo with matrix items expands them, as read_responses() expects
  demo <- sframe_demo("matrix_likert", preview = FALSE)
  mcols <- sframe_response_template_columns(demo$instrument)
  expect_true(all(setdiff(mcols, c("respondent_id", "started_at", "submitted_at")) %in%
                    names(demo$responses)))
})

test_that("A rewritten header names check.names = FALSE", {
  ins <- sframe_instrument("H2", components = list(
    sframe_item("sat_1", "Satisfied", type = "numeric"),
    sframe_item("sat_2", "Return", type = "numeric")))
  d <- data.frame(sat.1 = 1:3, sat.2 = 3:1)
  err <- tryCatch(suppressWarnings(read_responses(d, ins)), error = function(e) e)
  expect_s3_class(err, "error")
  expect_match(conditionMessage(err), "check.names = FALSE", fixed = TRUE)
  # a header with spaces, as another tool writes it
  d2 <- stats::setNames(data.frame(1:3, 3:1), c("Sat 1", "Sat 2"))
  err2 <- tryCatch(suppressWarnings(read_responses(d2, ins)), error = function(e) e)
  expect_match(conditionMessage(err2), "check.names = FALSE", fixed = TRUE)
})

test_that("missing_pct is a percentage, and tables show missing_prop once", {
  demo <- sframe_demo("likert_scale", preview = FALSE)
  mr <- sframe_missing_data_results(demo$responses, demo$instrument)
  expect_equal(mr$item_missing$missing_pct, 100 * mr$item_missing$missing_prop)
  shown <- surveyframe:::sframe_drop_old_share_cols(mr$item_missing)
  expect_false("missing_pct" %in% names(shown))
})

test_that("The assumption advisory fires when normality clearly fails", {
  set.seed(3)
  d <- data.frame(y = c(rexp(80, 1) ^ 2, rexp(80, 1) ^ 2),
                  g = rep(c("a", "b"), each = 80))
  ar <- sframe_assumption_results(d, variables = "y", group = "g")
  expect_false(is.null(ar$advisory))
  expect_match(ar$advisory, "Normality clearly fails")
  expect_match(ar$advisory, "Mann-Whitney")
  # a near-normal outcome draws no violation advisory
  set.seed(4)
  ok <- data.frame(y = rnorm(160), g = rep(c("a", "b"), each = 80))
  ar2 <- sframe_assumption_results(ok, variables = "y", group = "g")
  expect_false(grepl("clearly fails", ar2$advisory %||% ""))
})

test_that("The paired line names the measure briefly, higher in the larger mean", {
  set.seed(5)
  n <- 30
  before <- rnorm(n, 50, 10)
  after <- before + rnorm(n, 8, 5)
  d <- data.frame(confidence_before = before, confidence_after = after)
  r <- cfb_block(d, "t_test_pair", list(before = "confidence_before", after = "confidence_after"),
                 sframe_item("confidence_before",
                             "Before the training, how confident are you applying this skill? (0 to 100)",
                             type = "numeric"),
                 sframe_item("confidence_after",
                             "After the training, how confident are you applying this skill? (0 to 100)",
                             type = "numeric"))
  expect_null(r$error)
  expect_false(grepl("how confident", r$apa, fixed = TRUE))
  # before - after is negative, so t is negative and the higher mean is after
  expect_match(r$apa, "t\\([0-9]+\\) = -")
  expect_match(r$apa, "higher in confidence after", fixed = TRUE)
})

test_that("A partial correlation given roles$variables says what it needs", {
  set.seed(6)
  d <- data.frame(a = rnorm(40), b = rnorm(40), c = rnorm(40))
  r <- cfb_block(d, "partial_correlation", list(variables = c("a", "b"), controls = "c"),
                 cfb_num("a"), cfb_num("b"), cfb_num("c"))
  expect_false(is.null(r$error))
  expect_match(r$error, "x and y")
  expect_false(grepl("undefined columns", r$error))
})

test_that("The multinomial carries syntax, formatted p and a separation warning", {
  skip_if_not_installed("nnet")
  set.seed(7)
  n <- 90
  x <- rnorm(n)
  y <- ifelse(x > 0.8, "high", sample(c("low", "mid"), n, replace = TRUE))
  d <- data.frame(y = y, x = x, stringsAsFactors = FALSE)
  expect_warning(
    res <- sframe_run_multinomial_logistic(d, list(dependent = "y", predictors = "x")),
    class = "sframe_separation_warning")
  expect_match(res$separation, "separation")
  tb <- sframe_result_table(res)
  # p stays numeric, for the APA layer to print as .032 or <.001
  expect_true(is.numeric(tb$p))
  expect_false(grepl("Intercept", res$separation, fixed = TRUE))
  expect_false(any(suppressWarnings(as.numeric(tb$OR)) > 999, na.rm = TRUE))
  # through the plan, it gains the R that refits it
  ins <- sframe_instrument("Multinomial", components = list(
    sframe_item("y", "Outcome", type = "text"), cfb_num("x")))
  set.seed(8)
  d2 <- data.frame(y = sample(c("a", "b", "c"), 120, replace = TRUE), x = rnorm(120))
  r2 <- cfb_block(d2, "regression_logistic_multinomial", list(dependent = "y", predictors = "x"),
                  sframe_item("y", "Outcome", type = "text"), cfb_num("x"))
  expect_null(r2$error)
  expect_true(is.character(r2$syntax) && nzchar(r2$syntax))
})

test_that("sframe_syntax_sem() refuses a CFA model", {
  m <- sframe_model_spec("m1", type = "cfa",
                         constructs = list(F1 = c("a", "b", "c")))
  expect_error(sframe_syntax_sem(m), "sframe_syntax_cfa")
})

test_that("A small sample gets an advisory, and Firth gives LR chi-square, df and p", {
  skip_if_not_installed("logistf")
  set.seed(9)
  n <- 18
  x <- rnorm(n)
  d <- data.frame(x = x, out = ifelse(x + rlogis(n) > 0, 1, 0))
  r <- cfb_block(d, "firth_logistic", list(predictors = "x", dependent = "out"),
                 cfb_num("x"), cfb_num("out"))
  expect_null(r$error)
  expect_match(r$apa, "chi-square\\(1, N = 18\\) = [0-9.]+, p ")
  expect_match(r$advisory, "Small sample \\(N = 18\\)")
  d2 <- data.frame(a = rnorm(n), b = rnorm(n))
  r2 <- cfb_block(d2, "correlation_pearson", list(x = "a", y = "b"),
                  cfb_num("a"), cfb_num("b"))
  expect_match(r2$advisory, "Spearman")
})

test_that("Result sentences set their symbols in italics for every engine", {
  md <- surveyframe:::sframe_apa_markdown("t(29) = -2.10, p = .045, d = 0.38, N = 30")
  expect_match(md, "*t*(29)", fixed = TRUE)
  expect_match(md, "*p* = ", fixed = TRUE)
  expect_match(md, "*d* = ", fixed = TRUE)
  expect_match(md, "*N* = ", fixed = TRUE)
})

test_that("The alpha result carries Feldt's interval", {
  demo <- sframe_demo("likert_scale", preview = FALSE)
  rr <- sframe_reliability_results(demo$responses, demo$instrument)
  s <- rr[[1]]
  expect_length(s$alpha_ci, 2)
  expect_lt(s$alpha_ci[[1]], s$alpha)
  expect_gt(s$alpha_ci[[2]], s$alpha)
  skip_if_not_installed("psych")
  ref <- psych::alpha.ci(s$alpha, s$n, p.val = .05, s$n_items, digits = 10)
  expect_equal(unname(s$alpha_ci[[1]]), unname(ref$lower.ci), tolerance = 1e-6)
})

test_that("The cross-tab chart keeps the option order, sized 6.5 by 4", {
  skip_if_not_installed("ggplot2")
  expect_identical(formals(sframe_save_figures)$width, 6.5)
  expect_identical(formals(sframe_save_figures)$height, 4)
  ins <- sframe_instrument("B1", components = list(
    sframe_choice_set("yn", 0:1, c("No", "Yes")),
    sframe_choice_set("ag", 1:5, c("Strongly disagree", "Disagree", "Neutral",
                                   "Agree", "Strongly agree")),
    sframe_item("ret", "Would return", "single_choice", choice_set = "yn"),
    sframe_item("sat", "How satisfied were you with the stay overall, all things considered?",
                "likert", choice_set = "ag")))
  sframe_plan(ins) <- list(list(id = "B1", research_question = "q", family = "inferential",
                                method = "chi_square", roles = list(row = "ret", column = "sat")))
  set.seed(5)
  d <- data.frame(ret = sample(0:1, 80, TRUE), sat = sample(1:5, 80, TRUE))
  r <- suppressWarnings(run_analysis_plan(d, ins, plots = TRUE, scored = FALSE))$B1
  expect_null(r$error)
  p <- surveyframe:::sframe_plot_crosstab(r)
  expect_identical(levels(p$data$Column),
                   c("Strongly disagree", "Disagree", "Neutral", "Agree", "Strongly agree"))
  # the fitted chart wraps the long legend title and puts it above the keys
  fp <- surveyframe:::sframe_fit_plot(p + ggplot2::labs(fill = "How satisfied were you with the stay overall, all things considered?"))
  expect_match(fp$labels$fill, "\n")
})

test_that("The codebook items table carries each item's help text", {
  ins <- sframe_instrument("Help text", components = list(
    sframe_item("age", "Age", type = "numeric", help = "In whole years."),
    sframe_item("q1", "How was it?", type = "text")))
  cb <- sframe_codebook(ins)
  expect_true("help" %in% names(cb$items_table))
  expect_identical(cb$items_table$help, c("In whole years.", ""))
  expect_true("help" %in% names(sframe_codebook_items_display(cb)))
  md <- sframe_codebook(ins, format = "md")$markdown
  expect_match(md, "In whole years.", fixed = TRUE)
})

test_that("A section left out drops its heading in the report template", {
  qmd <- readLines(system.file("templates", "report.qmd", package = "surveyframe"))
  heads <- grep("^## (Codebook|Data Quality|Missing Data|Descriptives|Reliability|Analysis Plan|Model Appendix) \\{", qmd)
  expect_length(heads, 0)
  expect_true(any(grepl("eval=isTRUE(params$include_codebook)", qmd, fixed = TRUE)))
  expect_true(any(grepl("eval=isTRUE(params$include_quality)", qmd, fixed = TRUE)))
})

test_that("The report's start message names the Quarto version", {
  src <- paste(deparse(render_report), collapse = "\n")
  expect_match(src, "Rendering the report with Quarto", fixed = TRUE)
  expect_match(src, "quarto$version", fixed = TRUE)
})

test_that("A two-group table names its groups by their labels", {
  ins <- sframe_instrument("B1", components = list(
    sframe_choice_set("yn", 1:2, c("First visit", "Returning guest")),
    sframe_choice_set("ag", 1:5, c("SD", "D", "N", "A", "SA")),
    sframe_item("visit", "Visit", "single_choice", choice_set = "yn"),
    sframe_item("sat", "Satisfied", "likert", choice_set = "ag")))
  set.seed(12)
  d <- data.frame(visit = rep(1:2, each = 30), sat = sample(1:5, 60, TRUE))
  for (m in c("t_test_ind", "mann_whitney")) {
    sframe_plan(ins) <- list(list(id = "B1", research_question = "q",
                                  family = "inferential", method = m,
                                  roles = list(group = "visit", outcome = "sat")))
    r <- suppressWarnings(run_analysis_plan(d, ins, scored = FALSE))$B1
    expect_null(r$error, info = m)
    expect_identical(r$table$Group, c("First visit", "Returning guest"), info = m)
  }
})

test_that("Studio names the chosen file when it does not open as an instrument", {
  skip_if_not_installed("shiny")
  env <- new.env(parent = asNamespace("surveyframe"))
  sys.source(system.file("shiny", "app.R", package = "surveyframe"), envir = env)
  tmp <- tempfile(fileext = ".sframe")
  writeLines("{}", tmp)
  on.exit(unlink(tmp))
  png <- list(name = "logo.png", datapath = tmp)
  msg <- env$studio_open_error_message(simpleError("Unsupported file type '.png'. Expected: .sframe."), png)
  expect_match(msg, "^logo.png is not an instrument file")
  bad <- list(name = "study_tampered.sframe", datapath = tmp)
  e <- simpleError(paste0("Integrity check failed for:\n", normalizePath(tmp), "\nThe file may have been modified."))
  msg2 <- env$studio_open_error_message(e, bad)
  expect_match(msg2, "Integrity check failed for study_tampered.sframe", fixed = TRUE)
  expect_false(grepl(basename(tmp), msg2, fixed = TRUE))
})

test_that("A wording-only save starts the builder's amendment dialog on pipeline", {
  ctx <- builder_context()
  builder_open(ctx, sframe_demo("likert_scale", preview = FALSE)$instrument)
  info <- function() ctx$eval("JSON.stringify(sframeAmendInfo(S._origin, sframePayload()))")
  ctx$eval("S.items[0].label = S.items[0].label + ' (reworded)';")
  i1 <- jsonlite::fromJSON(info())
  expect_true(i1$wording_only)
  expect_false(i1$design_forced)
  # a new item is more than wording
  ctx$eval("S.items.push(JSON.parse(JSON.stringify(S.items[0]))); S.items[S.items.length-1].id = 'extra_q';")
  expect_false(jsonlite::fromJSON(info())$wording_only)
})

test_that("An uncentred predictor's large intercept is not called separation", {
  skip_if_not_installed("nnet")
  d <- sframe_demo("logistic", preview = FALSE)
  expect_no_warning(run_analysis_plan(d$responses, d$instrument),
                    class = "sframe_separation_warning")
})
