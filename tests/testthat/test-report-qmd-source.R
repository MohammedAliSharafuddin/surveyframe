# tests/testthat/test-report-qmd-source.R
#
# Session 8b-R, item 3 (NAMING decision 6). render_report(format = "qmd")
# writes a folder holding report.qmd, the .sframe, the responses, the
# bibliography and its style, the results record and manifest.json, with no
# _quarto.yml. The .qmd recomputes every number from the folder's own files,
# and its Provenance section says whether the numbers match the recorded
# results and whether report.qmd was edited after it was written.

write_source <- function(..., title = NULL) {
  d <- sframe_demo("likert_scale")
  dir <- tempfile("report-source-")
  res <- suppressMessages(render_report(d$instrument, data = d$responses,
                                        output_file = dir, format = "qmd",
                                        open = FALSE, title = title, ...))
  list(dir = dir, res = res, d = d)
}

prov_of <- function(dir) {
  src <- sframe_report_source(dir)
  p <- readRDS(src$provenance_path)
  list(src = src, value = stats::setNames(p$Value, p$Field))
}

# The front matter as its lines: every value render_report() writes is JSON,
# which is valid YAML, so a value reads back with jsonlite.
front_lines <- function(path) {
  lines <- readLines(path, warn = FALSE)
  ends <- which(lines == "---")
  lines[(ends[1] + 1):(ends[2] - 1)]
}
front_value <- function(path, key, indent = "") {
  fl <- front_lines(path)
  hit <- grep(sprintf("^%s%s: ", indent, key), fl, value = TRUE)
  if (!length(hit)) return(NULL)
  value <- sub(sprintf("^%s%s: ", indent, key), "", hit[1])
  tryCatch(jsonlite::fromJSON(value), error = function(e) value)
}

test_that("the report source folder holds its files and no _quarto.yml", {
  s <- write_source()
  expect_identical(attr(s$res, "engine"), "qmd")
  files <- list.files(s$dir)
  expect_true(all(c("report.qmd", "instrument.sframe", "responses.csv", "references.json",
                    "apa.csl", "report_results.json", "manifest.json", "report.scss",
                    "apa-reference.docx", "apa-reference.odt") %in% files))
  expect_false(file.exists(file.path(s$dir, "_quarto.yml")))
  qmd <- file.path(s$dir, "report.qmd")
  expect_identical(front_value(qmd, "source_dir", "  "), ".")
  expect_identical(front_value(qmd, "bibliography"), "references.json")
  expect_identical(front_value(qmd, "instrument_path", "  "), "")
  expect_true(all(c("  html:", "  docx:", "  odt:", "  pdf:") %in% front_lines(qmd)))
  # The instrument in the folder verifies and is the one reported.
  expect_identical(sframe_hash_value(read_sframe(file.path(s$dir, "instrument.sframe"))),
                   sframe_hash_value(s$d$instrument))
})

test_that("a fresh folder says its numbers match and its source is unchanged", {
  s <- write_source()
  p <- prov_of(s$dir)
  expect_true(p$src$check$numbers_match)
  expect_false(p$src$check$source_edited)
  expect_true(p$src$check$responses_match)
  expect_identical(p$value[["Results"]], "Numbers match the recorded results")
  expect_match(p$value[["Report source"]], "^Unchanged since surveyframe generated it on \\d{4}-")
  expect_match(p$value[["Instrument check"]], "verified by read_sframe()", fixed = TRUE)
  expect_match(p$value[["Declared plan blocks"]], "(reported)", fixed = TRUE)
})

test_that("an edited report.qmd is disclosed and the numbers still match", {
  s <- write_source()
  qmd <- file.path(s$dir, "report.qmd")
  cat("\nA paragraph the researcher added.\n", file = qmd, append = TRUE)
  p <- prov_of(s$dir)
  expect_true(p$src$check$source_edited)
  expect_match(p$value[["Report source"]],
               "^The report source was edited after surveyframe generated it on \\d{4}-\\d{2}-\\d{2}\\.$")
  expect_identical(p$value[["Results"]], "Numbers match the recorded results")
})

test_that("changed responses give numbers that differ, with both hashes", {
  s <- write_source()
  csv <- file.path(s$dir, "responses.csv")
  r <- utils::read.csv(csv, stringsAsFactors = FALSE)
  item <- s$d$instrument$items[[1]]$id
  r[[item]][1:10] <- ifelse(r[[item]][1:10] == 1, 5, 1)
  utils::write.csv(r, csv, row.names = FALSE, na = "")
  p <- prov_of(s$dir)
  expect_false(p$src$check$numbers_match)
  expect_false(p$src$check$responses_match)
  expect_match(p$value[["Results"]],
               sprintf("Numbers differ from the recorded results (recorded %s, now %s)",
                       p$src$check$recorded_results, p$src$check$now_results), fixed = TRUE)
  expect_match(p$value[["Responses sha256"]], "differs from the file exported", fixed = TRUE)
})

test_that("a title holding a quote, a colon, a hash and a newline then --- leaves the front matter whole", {
  title <- "A \"quoted\": study # one\n---\nbibliography: evil.json"
  s <- write_source(title = title)
  qmd <- file.path(s$dir, "report.qmd")
  expect_identical(front_value(qmd, "title"), title)
  expect_identical(front_value(qmd, "bibliography"), "references.json")
  expect_identical(sum(grepl("^title: ", front_lines(qmd))), 1L)
  lines <- readLines(file.path(s$dir, "report.qmd"))
  expect_identical(sum(lines == "---") >= 2, TRUE)
  expect_false(any(lines == "bibliography: evil.json"))
})

test_that("a folder that already holds files is not overwritten", {
  dir <- tempfile("occupied-")
  dir.create(dir)
  writeLines("keep", file.path(dir, "notes.txt"))
  expect_error(suppressMessages(render_report(sframe_demo("likert_scale")$instrument,
                                              output_file = dir, format = "qmd", open = FALSE)),
               "already holds files")
  expect_identical(readLines(file.path(dir, "notes.txt")), "keep")
})

test_that("the report source renders with Quarto and checks itself", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  s <- write_source()
  old <- setwd(s$dir)
  on.exit(setwd(old), add = TRUE)
  out <- suppressWarnings(system2("quarto", c("render", "report.qmd", "--to", "html"),
                                  stdout = TRUE, stderr = TRUE))
  expect_true(file.exists("report.html"), info = paste(utils::tail(out, 20), collapse = "\n"))
  doc <- paste(readLines("report.html", warn = FALSE), collapse = "\n")
  expect_match(doc, "Numbers match the recorded results", fixed = TRUE)
  expect_match(doc, "Unchanged since surveyframe generated it", fixed = TRUE)
  expect_match(doc, sframe_hash_value(s$d$instrument), fixed = TRUE)
})
