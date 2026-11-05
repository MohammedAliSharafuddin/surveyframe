# R/report_source.R
#
# The Quarto source of a report (session 8b-R, NAMING decision 6).
# render_report(format = "qmd") writes a folder that renders the report again
# in RStudio or Positron:
#   report.qmd            the report template, its front matter holding the
#                         title, authors, formats, bibliography and the
#                         parameters, with source_dir: "." pointing at the
#                         folder. No _quarto.yml, so the folder is not a
#                         Quarto project.
#   instrument.sframe     the instrument, as write_sframe() writes it
#   responses.csv         the responses
#   interpretations.json  the written interpretations, when there are any
#   references.json       the bibliography, and style.csl, its style
#   report_results.json   the results record at export
#   manifest.json         the sha256 of each file above as written
#   report.scss, apa-reference.docx, apa-reference.odt
# The .qmd computes every number from the .sframe and the responses when it
# renders, so nothing is pasted in as text, and the text fields of the
# instrument are read from its files, never written into the .qmd.

sframe_source_files <- c(qmd = "report.qmd", instrument = "instrument.sframe",
                         responses = "responses.csv", interpretations = "interpretations.json",
                         results = "report_results.json", manifest = "manifest.json")

# Set the default of each named parameter in a .qmd's front matter. Values are
# written as JSON, which is valid YAML, so no value can end the block.
sframe_qmd_set_params <- function(lines, values) {
  ends <- which(lines == "---")
  start <- which(lines == "params:")
  start <- start[start > ends[1] & start < ends[2]][1]
  for (name in names(values)) {
    i <- grep(sprintf("^  %s:", name), lines)
    i <- i[i > start & i < ends[2]][1]
    value <- as.character(jsonlite::toJSON(values[[name]], auto_unbox = TRUE))
    line <- sprintf("  %s: %s", name, value)
    if (is.na(i)) lines <- append(lines, line, after = start) else lines[i] <- line
  }
  lines
}

sframe_write_report_source <- function(dir, instrument, data, record_json, front,
                                       params, style, bibliography_extra,
                                       interpretations = list()) {
  if (dir.exists(dir) && length(list.files(dir, all.files = TRUE, no.. = TRUE))) {
    rlang::abort(paste0("The folder '", dir, "' already holds files. Name a new folder ",
                        "for the report source, so nothing in it is overwritten."),
                 class = "sframe_error")
  }
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  path <- function(key) file.path(dir, sframe_source_files[[key]])
  template_dir <- dirname(system.file("templates", "report.qmd", package = "surveyframe"))

  written <- tryCatch(write_sframe(instrument, path("instrument")), error = function(e) e)
  if (inherits(written, "error")) {
    rlang::abort(c("The instrument could not be written into the report source.",
                   i = conditionMessage(written)), class = "sframe_error")
  }
  if (!is.null(data)) utils::write.csv(data, path("responses"), row.names = FALSE, na = "")
  if (length(interpretations)) {
    writeLines(jsonlite::toJSON(interpretations, auto_unbox = TRUE, pretty = TRUE),
               path("interpretations"), useBytes = TRUE)
  }
  sframe_write_text(record_json, path("results"))
  file.copy(file.path(template_dir, c("report.scss", "apa-reference.docx", "apa-reference.odt")),
            dir, overwrite = TRUE)
  # The style used, bundled or the researcher's own, named for it, so a rerun
  # formats with that copy (owner 2026-11-03).
  style_file <- paste0(style$name, ".csl")
  sframe_bibliography(instrument, extra = bibliography_extra,
                      file = file.path(dir, "references.json"))
  file.copy(style$path, file.path(dir, style_file), overwrite = TRUE)

  qmd <- readLines(file.path(template_dir, "report.qmd"), warn = FALSE)
  qmd <- qmd[!grepl("^title:", qmd) | seq_along(qmd) > grep("^---", qmd)[2]]
  qmd <- append(qmd, front, after = 1L)
  qmd <- sframe_qmd_set_params(qmd, c(list(source_dir = "."), params))
  writeLines(qmd, path("qmd"), useBytes = TRUE)

  # The manifest records each file as written, so a later render can say
  # what changed since. Field names as in the report manifest.
  obj <- function(id, type, key) {
    list(object_id = id, object_type = type, file_name = sframe_source_files[[key]],
         hash_algorithm = "SHA-256", hash_value = sframe_sha256_file(path(key)))
  }
  objects <- list(obj("report_source", "report_qmd", "qmd"),
                  c(obj("instrument", "sframe_instrument", "instrument"),
                    list(content_hash = sframe_hex(sframe_hash_value(instrument)))))
  if (!is.null(data)) objects <- c(objects, list(obj("responses", "responses_csv", "responses")))
  objects <- c(objects, list(obj("results", "results_record", "results"),
                             sframe_style_manifest_object(style, style_file)))
  manifest <- list(
    manifest_version = 1L,
    study_id = as.character(instrument$meta$id %||% instrument$meta$title %||% ""),
    created_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
    software = paste0("R ", getRversion(), " and surveyframe ",
                      utils::packageVersion("surveyframe")),
    objects = objects
  )
  writeLines(jsonlite::toJSON(manifest, auto_unbox = TRUE, pretty = TRUE, null = "null"),
             path("manifest"), useBytes = TRUE)
  invisible(dir)
}

#' Recompute and check a report source folder
#'
#' The first chunk of the `report.qmd` that `render_report(format = "qmd")`
#' writes calls this function. It reads the folder's `.sframe` and responses,
#' recomputes the analysis plan, and compares what it finds with the folder's
#' `manifest.json`. The report's Provenance section then states the
#' instrument hash and whether [read_sframe()] verified it, the amendments,
#' whether the responses file is the one exported, whether the numbers match
#' the recorded results ("Numbers match the recorded results", or "Numbers
#' differ from the recorded results" with both hashes), whether `report.qmd`
#' was edited after surveyframe wrote it, and which declared plan blocks the
#' report includes.
#'
#' Editing the `.qmd` stays allowed and is disclosed, as an amendment is.
#' Someone can delete the provenance chunk, as they can edit any document.
#' The tamper evidence a reviewer can check lives in the `.sframe`, the
#' responses hash and the results record, all checkable without the report.
#'
#' @param dir The report source folder. Defaults to the working directory,
#'   which is the folder itself when Quarto renders its `report.qmd`.
#' @param include_analysis Logical. Whether the report includes the analysis
#'   plan results.
#' @param plot_palette `"web"` or `"print"`, as in [render_report()].
#' @return A list the template reads: paths to the inputs it renders from, the
#'   instrument hash, the analysis seed, and `check`, a list of the verdicts
#'   (`numbers_match`, `source_edited`, `responses_match`, with the recorded
#'   and recomputed hashes).
#' @seealso [render_report()]
#' @family Report functions
#' @export
#' @examples
#' \donttest{
#' d <- sframe_demo("likert_scale")
#' dir <- file.path(tempdir(), "report-source-example")
#' render_report(d$instrument, d$responses, output_file = dir, format = "qmd",
#'               open = FALSE)
#' src <- sframe_report_source(dir)
#' src$check$numbers_match
#' src$check$source_edited
#' unlink(dir, recursive = TRUE)
#' }
sframe_report_source <- function(dir = ".", include_analysis = TRUE, plot_palette = "web") {
  path <- function(key) file.path(dir, sframe_source_files[[key]])
  if (!file.exists(path("instrument")) || !file.exists(path("manifest"))) {
    rlang::abort(paste0("'", dir, "' is not a surveyframe report source folder: it needs ",
                        "instrument.sframe and manifest.json."), class = "sframe_error")
  }
  manifest <- jsonlite::fromJSON(path("manifest"), simplifyVector = FALSE)
  recorded <- stats::setNames(
    lapply(manifest$objects, function(o) o$hash_value),
    vapply(manifest$objects, function(o) o$object_id, character(1)))

  instrument <- tryCatch(read_sframe(path("instrument")), error = function(e) NULL)
  if (is.null(instrument)) {
    instrument <- suppressWarnings(read_sframe(path("instrument"), verify = FALSE))
  }
  data <- if (file.exists(path("responses"))) suppressMessages(read_responses(path("responses"), instrument))
  interpretations <- if (file.exists(path("interpretations"))) {
    jsonlite::fromJSON(path("interpretations"), simplifyVector = FALSE)
  } else list()

  results <- NULL
  if (!is.null(data) && isTRUE(include_analysis) && length(instrument$analysis_plan %||% list())) {
    results <- tryCatch(
      run_analysis_plan(data, instrument, plots = requireNamespace("ggplot2", quietly = TRUE),
                        plot_palette = plot_palette),
      error = function(e) e)
  }
  seed <- sframe_report_seed(data, instrument, include_analysis)
  # The style as exported, so a changed style is reported apart from the numbers.
  style_rec <- Filter(function(o) identical(o$object_id, "citation_style"), manifest$objects)
  style_rec <- if (length(style_rec)) style_rec[[1]] else NULL
  style_now <- if (!is.null(style_rec) && file.exists(file.path(dir, style_rec$file_name))) {
    sframe_sha256_file(file.path(dir, style_rec$file_name))
  } else NA_character_
  record_now <- function() sframe_sha256_text(sframe_results_record_json(
    if (is.list(results) && !inherits(results, "error")) results else list(), instrument, seed,
    style = if (!is.null(style_rec)) list(name = style_rec$name, sha256 = style_rec$hash_value)))
  now_record <- record_now()
  rec_results <- recorded$results %||% ""
  # A record written before 0.4.3 sorted its keys in the session locale's order.
  if (!identical(now_record, rec_results) &&
      identical(sframe_with_locale_order(record_now()), rec_results)) {
    now_record <- rec_results
    sframe_inform_locale_order("The results record in this folder")
  }
  now_qmd <- sframe_sha256_file(path("qmd"))
  now_resp <- if (file.exists(path("responses"))) sframe_sha256_file(path("responses")) else NA_character_
  check <- list(
    numbers_match = identical(now_record, rec_results), recorded_results = rec_results,
    now_results = now_record,
    source_edited = !identical(now_qmd, recorded$report_source %||% ""),
    responses_match = identical(now_resp, recorded$responses %||% NA_character_),
    exported_on = substr(manifest$created_at %||% "", 1, 10)
  )

  plan <- instrument$analysis_plan %||% list()
  block_ids <- vapply(seq_along(plan), function(i) as.character(plan[[i]]$id %||% paste0("block ", i)),
                      character(1))
  reported <- isTRUE(include_analysis) && !is.null(data)
  provenance <- data.frame(
    Field = c("Instrument hash", "Instrument check", "Amendments disclosed", "Responses sha256",
              "Results", "Report source", "Citation style", "Declared plan blocks", "surveyframe"),
    Value = c(
      sframe_hex(sframe_hash_value(instrument)),
      sframe_instrument_verification(instrument),
      as.character(length(instrument$amendments %||% list())),
      if (is.na(now_resp)) "no responses supplied" else if (check$responses_match) {
        paste0(now_resp, ", the file exported")
      } else {
        paste0(now_resp, ", which differs from the file exported (", recorded$responses %||% "none", ")")
      },
      if (check$numbers_match) "Numbers match the recorded results" else {
        sprintf("Numbers differ from the recorded results (recorded %s, now %s)", rec_results, now_record)
      },
      if (check$source_edited) {
        sprintf("The report source was edited after surveyframe generated it on %s.", check$exported_on)
      } else {
        sprintf("Unchanged since surveyframe generated it on %s.", check$exported_on)
      },
      if (is.null(style_rec)) "not recorded" else if (identical(style_now, style_rec$hash_value)) {
        paste0(style_rec$name, ", the style exported")
      } else {
        paste0(style_rec$name, ", changed since export")
      },
      if (length(block_ids)) {
        paste0(block_ids, if (reported) " (reported)" else " (not reported)", collapse = ", ")
      } else "none declared",
      as.character(utils::packageVersion("surveyframe"))
    ),
    stringsAsFactors = FALSE
  )

  # Field text may cite any work in the folder's bibliography (8b-R).
  bib <- file.path(dir, "references.json")
  keys <- unique(c(sframe_md_keys(instrument), if (file.exists(bib)) {
    vapply(jsonlite::fromJSON(bib, simplifyVector = FALSE), function(x) as.character(x$id %||% ""), character(1))
  }))
  # The same inputs render_report() hands the template, as files.
  rds <- function(x) {
    f <- tempfile(fileext = ".rds")
    saveRDS(x, f)
    f
  }
  list(
    instrument_path = rds(instrument),
    data_path = if (is.null(data)) "" else rds(data),
    interpretations_path = if (length(interpretations)) rds(interpretations) else "",
    declarations_path = rds(sframe_plan_declarations(instrument, interpretations, keys)),
    content_path = rds(sframe_report_content(instrument, data, plot_palette,
                                             include_analysis = include_analysis,
                                             results = results)),
    provenance_path = rds(provenance),
    instrument_hash = sframe_hex(sframe_hash_value(instrument)),
    analysis_seed = as.character(seed),
    check = check
  )
}
