# tests/testthat/test-report-csl-styles.R
#
# Session 8b-R, item 6 (owner 2026-11-03). render_report(csl = ) takes a style
# name, "apa" (the default), "chicago-author-date", "harvard", "ieee" or
# "mla", or a path to a .csl file. The style used is copied into the .qmd
# report folder, and its name and sha256 go into the results record and the
# manifest. Styles are never fetched from the network. The built-in engine
# stays APA only and says so.

style_names <- c("apa", "chicago-author-date", "harvard", "ieee", "mla")

one_ref_instrument <- function() {
  sframe_add_references(
    sframe_demo("likert_scale")$instrument,
    sframe_reference("cronbach_1951", "Coefficient alpha and the internal structure of tests",
                     author = "Cronbach, L. J.", year = 1951, container = "Psychometrika",
                     volume = "16", issue = "3", pages = "297-334"))
}

test_that("each style name resolves to a bundled CSL file", {
  for (nm in style_names) {
    s <- surveyframe:::sframe_resolve_csl(nm)
    expect_identical(s$name, nm)
    expect_true(file.exists(s$path))
    expect_match(paste(readLines(s$path, n = 5), collapse = ""), "<style", fixed = TRUE)
  }
  expect_identical(surveyframe:::sframe_resolve_csl(NULL)$name, "apa")
})

test_that("an unknown style name gives a message that lists the 5", {
  err <- tryCatch(surveyframe:::sframe_resolve_csl("vancouver"), error = function(e) conditionMessage(e))
  for (nm in style_names) expect_match(err, sprintf("\"%s\"", nm), fixed = TRUE)
  expect_error(render_report(one_ref_instrument(), output_file = tempfile(fileext = ".html"),
                             csl = "vancouver", open = FALSE),
               "apa", class = "sframe_error")
})

test_that("a path to a .csl file is used as given, named by its file", {
  path <- file.path(tempdir(), "my-journal.csl")
  file.copy(system.file("csl", "apa.csl", package = "surveyframe"), path, overwrite = TRUE)
  s <- surveyframe:::sframe_resolve_csl(path)
  expect_identical(s$name, "my-journal")
  expect_identical(s$path, normalizePath(path))
})

test_that("the record and the manifest carry the style's name and sha256", {
  old <- options(surveyframe.use_quarto = FALSE)
  on.exit(options(old), add = TRUE)
  d <- sframe_demo("likert_scale")
  out <- tempfile(fileext = ".html")
  suppressMessages(render_report(d$instrument, d$responses, output_file = out, csl = "ieee",
                                 open = FALSE))
  p <- surveyframe:::sframe_record_paths(out)
  sha <- surveyframe:::sframe_sha256_file(surveyframe:::sframe_resolve_csl("ieee")$path)
  rec <- jsonlite::fromJSON(p$results, simplifyVector = FALSE)
  expect_identical(rec$citation_style$name, "ieee")
  expect_identical(rec$citation_style$sha256, sha)
  man <- jsonlite::fromJSON(p$manifest, simplifyVector = FALSE)
  style <- Filter(function(o) identical(o$object_id, "citation_style"), man$objects)[[1]]
  expect_identical(style$hash_value, sha)
  expect_identical(style$name, "ieee")
})

test_that("the built-in engine says it formats APA only when another style is asked for", {
  old <- options(surveyframe.use_quarto = FALSE)
  on.exit(options(old), add = TRUE)
  expect_message(render_report(one_ref_instrument(), output_file = tempfile(fileext = ".html"),
                               csl = "harvard", open = FALSE),
                 "APA 7 only", class = "sframe_report_progress")
})

test_that("the .qmd report folder holds the style used, named for it, and renders with it", {
  dir <- tempfile("csl-source-")
  suppressMessages(render_report(one_ref_instrument(), output_file = dir, format = "qmd",
                                 csl = "harvard", open = FALSE))
  expect_true(file.exists(file.path(dir, "harvard.csl")))
  expect_false(file.exists(file.path(dir, "style.csl")))
  lines <- readLines(file.path(dir, "report.qmd"))
  expect_true("csl: \"harvard.csl\"" %in% lines)
  src <- sframe_report_source(dir)
  expect_true(src$check$numbers_match)
})

test_that("each style renders 1 reference through Quarto", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  old <- options(surveyframe.use_quarto = TRUE)
  on.exit(options(old), add = TRUE)
  ins <- one_ref_instrument()
  for (nm in style_names) {
    out <- tempfile(fileext = ".html")
    res <- suppressMessages(render_report(ins, output_file = out, csl = nm, open = FALSE))
    expect_identical(attr(res, "engine"), "quarto", info = nm)
    doc <- paste(readLines(out, warn = FALSE), collapse = "\n")
    entries <- regmatches(doc, gregexpr("class=\"csl-entry\"", doc, fixed = TRUE))[[1]]
    expect_length(entries, 1)
    # Chicago and MLA title-case the title.
    expect_match(doc, "Coefficient alpha", ignore.case = TRUE, info = nm)
  }
})
