# tests/testthat/test-report-results-record.R
#
# Session 8b-R, item 2 (NAMING decision 6, SSR 6.0 Layer 4). Every report
# gets a results record beside it, <name>_results.json, the plan results as
# canonical JSON, and a manifest, <name>_manifest.json, with the sha256 of the
# instrument content, the responses, the results record and the output as
# generated. A provenance block in every report states the instrument hash and
# whether read_sframe() verified it, the amendment count, the responses sha256
# and the results record's sha256.

sha_file <- function(path) surveyframe:::sframe_sha256_file(path)

record_paths <- function(out) {
  stem <- sub("\\.[^.]+$", "", out)
  c(results = paste0(stem, "_results.json"), manifest = paste0(stem, "_manifest.json"))
}

render_builtin <- function(instr, data, out = tempfile(fileext = ".html"), ...) {
  old <- options(surveyframe.use_quarto = FALSE)
  on.exit(options(old), add = TRUE)
  suppressMessages(render_report(instr, data = data, output_file = out, open = FALSE, ...))
  out
}

test_that("a report has a results record and a manifest beside it", {
  d <- sframe_demo("likert_scale")
  out <- render_builtin(d$instrument, d$responses)
  p <- record_paths(out)
  expect_true(all(file.exists(p)))

  rec <- jsonlite::fromJSON(p[["results"]], simplifyVector = FALSE)
  expect_identical(rec$instrument_hash, sframe_hash_value(d$instrument))
  expect_length(rec$results, length(d$instrument$analysis_plan))
  expect_false(any(vapply(rec$results, function(r) "plot" %in% names(r), logical(1))))

  man <- jsonlite::fromJSON(p[["manifest"]], simplifyVector = FALSE)
  objs <- stats::setNames(man$objects, vapply(man$objects, `[[`, "", "object_id"))
  expect_setequal(names(objs), c("instrument", "responses", "results", "report"))
  expect_identical(objs$instrument$hash_value, sframe_hash_value(d$instrument))
  expect_identical(objs$responses$hash_value, surveyframe:::sframe_responses_sha256(d$responses))
  expect_identical(objs$results$hash_value, sha_file(p[["results"]]))
  expect_identical(objs$results$file_name, basename(p[["results"]]))
  expect_identical(objs$report$hash_value, sha_file(out))
  expect_identical(objs$report$file_name, basename(out))
  expect_true(all(vapply(man$objects, function(o) identical(o$hash_algorithm, "SHA-256"), logical(1))))
  expect_match(man$software, paste0("surveyframe ", utils::packageVersion("surveyframe")), fixed = TRUE)
  expect_match(man$created_at, "^\\d{4}-\\d{2}-\\d{2}T")
})

test_that("the results record is the same for the same instrument and responses", {
  d <- sframe_demo("likert_scale")
  a <- record_paths(render_builtin(d$instrument, d$responses))[["results"]]
  b <- record_paths(render_builtin(d$instrument, d$responses))[["results"]]
  expect_identical(sha_file(a), sha_file(b))
})

test_that("the report's provenance block gives the 4 hashes and the amendment count", {
  d <- sframe_demo("likert_scale")
  attr(d$instrument, "sframe_verified") <- NULL
  out <- render_builtin(d$instrument, d$responses)
  p <- record_paths(out)
  doc <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_match(doc, "<h2>Provenance</h2>", fixed = TRUE)
  expect_match(doc, sframe_hash_value(d$instrument), fixed = TRUE)
  expect_match(doc, "not read from a .sframe file", fixed = TRUE)
  expect_match(doc, surveyframe:::sframe_responses_sha256(d$responses), fixed = TRUE)
  expect_match(doc, sha_file(p[["results"]]), fixed = TRUE)
  expect_match(doc, "Amendments disclosed</td>\\s*<td[^>]*>0", perl = TRUE)

  path <- tempfile(fileext = ".sframe")
  write_sframe(d$instrument, path)
  out2 <- render_builtin(read_sframe(path), d$responses)
  doc2 <- paste(readLines(out2, warn = FALSE), collapse = "\n")
  expect_match(doc2, "verified by read_sframe()", fixed = TRUE)
})

test_that("a codebook-only report records no responses and an empty result list", {
  d <- sframe_demo("likert_scale")
  out <- render_builtin(d$instrument, NULL)
  p <- record_paths(out)
  rec <- jsonlite::fromJSON(p[["results"]], simplifyVector = FALSE)
  expect_length(rec$results, 0)
  man <- jsonlite::fromJSON(p[["manifest"]], simplifyVector = FALSE)
  ids <- vapply(man$objects, `[[`, "", "object_id")
  expect_false("responses" %in% ids)
  doc <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_match(doc, "Responses sha256</td>\\s*<td[^>]*>no responses supplied", perl = TRUE)
})

test_that("both engines print the provenance table built in R", {
  d <- sframe_demo("likert_scale")
  prov <- surveyframe:::sframe_report_provenance(d$instrument, d$responses, "abc")
  expect_identical(prov$Field, c("Instrument hash", "Instrument check", "Amendments disclosed",
                                 "Responses sha256", "Results record sha256", "surveyframe"))
  qmd <- paste(readLines(system.file("templates", "report.qmd", package = "surveyframe")),
               collapse = "\n")
  expect_match(qmd, "params$provenance_path", fixed = TRUE)
  expect_match(qmd, "## Provenance", fixed = TRUE)
})

test_that("the Quarto report carries the record, the manifest and the provenance block", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  old <- options(surveyframe.use_quarto = TRUE)
  on.exit(options(old), add = TRUE)
  d <- sframe_demo("likert_scale")
  out <- tempfile(fileext = ".html")
  res <- suppressMessages(render_report(d$instrument, data = d$responses,
                                        output_file = out, open = FALSE))
  expect_identical(attr(res, "engine"), "quarto")
  p <- record_paths(out)
  expect_true(all(file.exists(p)))
  man <- jsonlite::fromJSON(p[["manifest"]], simplifyVector = FALSE)
  objs <- stats::setNames(man$objects, vapply(man$objects, `[[`, "", "object_id"))
  expect_identical(objs$report$hash_value, sha_file(out))
  doc <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_match(doc, "Provenance", fixed = TRUE)
  expect_match(doc, sha_file(p[["results"]]), fixed = TRUE)
  expect_match(doc, surveyframe:::sframe_responses_sha256(d$responses), fixed = TRUE)
  # The Quarto and built-in records hold the same numbers.
  b <- record_paths(render_builtin(d$instrument, d$responses))[["results"]]
  expect_identical(sha_file(p[["results"]]), sha_file(b))
})
