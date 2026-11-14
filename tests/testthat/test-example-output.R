# Every help page's example ends with something to look at and at most 40
# console lines (Session 10, owner 2026-11-11). sframe_plan() printed 1,647
# lines, run_analysis_plan() 138 and sframe_item_results() 83, and 5 design
# constructors printed nothing. This reruns the measurement over man/, with
# \donttest run as RStudio's Run examples does and \dontrun left out, so a new
# example that breaks the rule fails here. Slow tier: it runs every example.

# The 1 page allowed past 40 lines: its output is the seminr script the
# function generates, and cutting it would hide the result.
example_line_exceptions <- c(sframe_syntax_pls = 42L)

example_output <- function(rd) {
  ex <- tempfile(fileext = ".R")
  tools::Rd2ex(rd, ex, commentDontrun = TRUE, commentDonttest = FALSE)
  if (!file.exists(ex)) return(NULL)
  wd <- tempfile("ex-wd-")
  dir.create(wd)
  old <- setwd(wd)
  on.exit(setwd(old), add = TRUE)
  utils::capture.output(suppressMessages(suppressWarnings(
    source(ex, echo = FALSE, print.eval = TRUE, local = new.env(parent = globalenv()))
  )))
}

example_console_lines <- function(rd) {
  out <- example_output(rd)
  if (is.null(out)) NA_integer_ else length(out)
}

test_that("every example prints at most 40 console lines", {
  skip_if_not_slow()
  man <- test_path("..", "..", "man")
  skip_if(!dir.exists(man), "no source tree")
  old_options <- options(viewer = function(...) invisible(NULL),
                                browser = function(...) invisible(NULL),
                                shiny.launch.browser = FALSE)
  on.exit(options(old_options), add = TRUE)
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  for (rd in list.files(man, pattern = "\\.Rd$", full.names = TRUE)) {
    page <- sub("\\.Rd$", "", basename(rd))
    n <- example_console_lines(rd)
    if (is.na(n)) next
    limit <- if (page %in% names(example_line_exceptions)) {
      example_line_exceptions[[page]]
    } else 40L
    expect_lte(n, limit, label = paste0(page, "'s example lines"))
  }
})

test_that("the design constructors' examples show what they made", {
  man <- test_path("..", "..", "man")
  skip_if(!dir.exists(man), "no source tree")
  for (page in c("sframe_item", "sframe_scale", "sframe_branch",
                 "sframe_choice_set", "sframe_attention_check", "sframe_plan")) {
    expect_gt(example_console_lines(file.path(man, paste0(page, ".Rd"))), 0)
  }
})

test_that("the examples that write a file end with sframe_show(), and open nothing here", {
  skip_if_not_slow()
  man <- test_path("..", "..", "man")
  skip_if(!dir.exists(man), "no source tree")
  opened <- 0
  old <- options(viewer = function(...) opened <<- opened + 1,
                 browser = function(...) opened <<- opened + 1)
  on.exit(options(old), add = TRUE)
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  pages <- c("sframe_show", "render_report", "render_results", "export_survey",
             "preview_survey", "launch_builder", "sframe_analysis_qmd",
             "sframe_demo_qmd", "sframe_save_figures", "write_sframe",
             "export_responses", "export_google_sheet")
  for (page in pages) {
    out <- example_output(file.path(man, paste0(page, ".Rd")))
    expect_true(any(grepl("^Written: ", out)), info = page)
  }
  expect_equal(opened, 0)
})
