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
  expect_identical(p$value[["Results"]], "The analysis plan results match the recorded results")
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
  expect_identical(p$value[["Results"]], "The analysis plan results match the recorded results")
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
               sprintf("The analysis plan results differ from the recorded results (recorded %s, now %s)",
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

# Where two record strings first differ, with 120 characters of each from
# a little before it, for a failure message.
first_difference <- function(a, b) {
  x <- strsplit(a, "", useBytes = TRUE)[[1]]
  y <- strsplit(b, "", useBytes = TRUE)[[1]]
  n <- min(length(x), length(y))
  at <- which(x[seq_len(n)] != y[seq_len(n)])[1]
  if (is.na(at) && length(x) == length(y)) return("the 2 records are identical")
  if (is.na(at)) at <- n + 1L
  from <- max(1L, at - 40L)
  sprintf("first difference at character %d of %d and %d\nrecorded: %s\nnow:      %s",
          at, length(x), length(y), substr(a, from, from + 119L), substr(b, from, from + 119L))
}

test_that("the report source renders with Quarto and checks itself", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  s <- write_source()
  # Quarto's own R session writes the record it recomputes, and its locale
  # and library, so a mismatch names its cause (macOS, CI run 41994727848).
  dump <- tempfile(fileext = ".json")
  about <- tempfile(fileext = ".txt")
  profile <- tempfile(fileext = ".R")
  writeLines(c(
    "setHook(packageEvent('surveyframe', 'onLoad'), function(...) {",
    "  f <- get('sframe_results_record_json', envir = asNamespace('surveyframe'))",
    "  g <- function(...) {",
    "    j <- f(...)",
    "    writeBin(charToRaw(enc2utf8(j)), Sys.getenv('SF_RECORD_DUMP'))",
    "    j",
    "  }",
    "  utils::assignInNamespace('sframe_results_record_json', g, ns = 'surveyframe')",
    "  writeLines(c(Sys.getlocale(), R.version.string, .libPaths(),",
    "               as.character(utils::packageVersion('surveyframe'))),",
    "             Sys.getenv('SF_ABOUT_DUMP'))",
    "})"), profile)
  out <- quarto_render_in(s$dir, "html", c(R_PROFILE_USER = profile, SF_RECORD_DUMP = dump,
                                           SF_ABOUT_DUMP = about))
  html <- file.path(s$dir, "report.html")
  expect_true(file.exists(html), info = paste(utils::tail(out, 20), collapse = "\n"))
  doc <- paste(readLines(html, warn = FALSE), collapse = "\n")
  recorded <- file.path(s$dir, "report_results.json")
  why <- paste(c(
    if (file.exists(dump)) {
      first_difference(readChar(recorded, file.size(recorded), useBytes = TRUE),
                       readChar(dump, file.size(dump), useBytes = TRUE))
    } else "Quarto's R wrote no record",
    "Quarto's R:", if (file.exists(about)) readLines(about) else "(not written)",
    "This R:", Sys.getlocale(), R.version.string, .libPaths(),
    as.character(utils::packageVersion("surveyframe"))), collapse = "\n")
  expect_match(doc, "The analysis plan results match the recorded results", fixed = TRUE, info = why)
  expect_match(doc, "Unchanged since surveyframe generated it", fixed = TRUE)
  expect_match(doc, sframe_hash_value(s$d$instrument), fixed = TRUE)
})

test_that("an edited or deleted results record is reported though the numbers match (P2-02, FR-04)", {
  s <- write_source()
  rec <- file.path(s$dir, "report_results.json")
  p <- prov_of(s$dir)
  expect_true(p$src$check$results_file_match)
  expect_identical(p$value[["Results record"]], "report_results.json, the file exported")
  cat(" ", file = rec, append = TRUE)
  p <- prov_of(s$dir)
  expect_true(p$src$check$numbers_match)
  expect_false(p$src$check$results_file_match)
  expect_match(p$value[["Results record"]],
               "^report_results.json, which differs from the file exported \\(recorded [0-9a-f]{64}, now [0-9a-f]{64}\\)$")
  unlink(rec)
  p <- prov_of(s$dir)
  expect_true(p$src$check$numbers_match)
  expect_false(p$src$check$results_file_match)
  expect_match(p$value[["Results record"]], "^report_results.json is missing \\(recorded [0-9a-f]{64}\\)$")
})

test_that("the bibliography and the interpretations are in the manifest and the check (FR-17)", {
  plan_id <- sframe_demo("likert_scale")$instrument$analysis_plan[[1]]$id
  s <- write_source(interpretations = stats::setNames(list("As planned."), plan_id))
  ids <- vapply(jsonlite::read_json(file.path(s$dir, "manifest.json"))$objects,
                function(o) o$object_id, "")
  expect_true(all(c("results", "references", "interpretations") %in% ids))
  p <- prov_of(s$dir)
  expect_true(p$src$check$references_match)
  expect_true(p$src$check$interpretations_match)
  expect_identical(p$value[["Bibliography"]], "references.json, the file exported")
  expect_identical(p$value[["Interpretations"]], "interpretations.json, the file exported")
  writeLines("[]", file.path(s$dir, "references.json"))
  writeLines(sprintf('{"%s": "Not as planned."}', plan_id), file.path(s$dir, "interpretations.json"))
  p <- prov_of(s$dir)
  expect_false(p$src$check$references_match)
  expect_false(p$src$check$interpretations_match)
  expect_match(p$value[["Bibliography"]], "differs from the file exported", fixed = TRUE)
  expect_match(p$value[["Interpretations"]], "differs from the file exported", fixed = TRUE)
  # An interpretation added to a folder exported with none.
  s2 <- write_source()
  expect_identical(prov_of(s2$dir)$value[["Interpretations"]], "none")
  writeLines(sprintf('{"%s": "Added later."}', plan_id), file.path(s2$dir, "interpretations.json"))
  p2 <- prov_of(s2$dir)
  expect_false(p2$src$check$interpretations_match)
  expect_match(p2$value[["Interpretations"]], "^interpretations.json, added since export \\(now [0-9a-f]{64}\\)$")
})

test_that("the responses sha256 keeps type and full precision, and times in UTC (FR-15)", {
  h <- function(...) surveyframe:::sframe_responses_sha256(data.frame(..., stringsAsFactors = FALSE))
  expect_false(identical(h(x = NA_real_), h(x = NaN)))
  expect_false(identical(h(x = NA_real_), h(x = Inf)))
  expect_false(identical(h(x = Inf), h(x = -Inf)))
  expect_false(identical(h(x = 0.3), h(x = 0.1 + 0.2)))
  expect_false(identical(h(x = 1L), h(x = 1)))
  expect_false(identical(h(x = "NA"), h(x = NA_character_)))
  expect_false(identical(h(x = "1"), h(x = 1)))
  t_utc <- as.POSIXct("2026-11-11 08:00:00", tz = "UTC")
  t_male <- t_utc
  attr(t_male, "tzone") <- "Indian/Maldives"
  # The same instant in 2 zones hashes alike, the same clock time in 2 zones does not.
  expect_identical(h(t = t_utc), h(t = t_male))
  expect_false(identical(h(t = t_utc), h(t = as.POSIXct("2026-11-11 08:00:00", tz = "Indian/Maldives"))))
  expect_identical(h(x = c(1.5, NA)), h(x = c(1.5, NA)))
})
