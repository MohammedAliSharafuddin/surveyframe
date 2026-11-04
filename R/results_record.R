# R/results_record.R
#
# The results record, the manifest and the provenance block (session 8b-R,
# NAMING decision 6, SSR 6.0 Layer 4). A report in any format is a
# presentation of the plan results, and a Word or Quarto copy is meant to be
# edited. What a reviewer verifies is the results, so every render_report()
# writes beside its output:
#   <name>_results.json   the plan results as canonical JSON, with no
#                         timestamp, so the same instrument and responses give
#                         the same bytes and the same sha256
#   <name>_manifest.json  the sha256 of the instrument content, the responses,
#                         the results record and the output as generated, with
#                         the surveyframe version and the time. The field names
#                         follow the SSR 6.0 hash manifest (Table 2), so the
#                         0.6 bundle functions can read it unchanged.
# The provenance block states the same hashes inside the report.

# Fields of a result that hold a drawing for this session only, never numbers.
sframe_record_drop <- c("plot", "plots", "diagnostic_plots")

sframe_record_plain <- function(x) {
  if (inherits(x, c("gg", "ggplot", "ggplot2::ggplot", "grob", "gtable", "recordedplot"))) {
    return(NULL)
  }
  if (is.data.frame(x)) {
    x[] <- lapply(x, function(col) if (is.factor(col)) as.character(col) else col)
    return(x)
  }
  if (is.factor(x)) return(as.character(x))
  if (is.list(x)) {
    x <- sframe_plain(x)
    if (!is.null(names(x))) x <- x[!names(x) %in% sframe_record_drop]
    x <- lapply(x, sframe_record_plain)
    x <- x[!vapply(x, is.null, logical(1))]
  }
  x
}

# The results record as a JSON string: canonical (keys sorted, compact,
# full precision), so its sha256 is a fingerprint of the numbers.
sframe_results_record_json <- function(results, instrument, seed) {
  blocks <- if (is.list(results)) lapply(unclass(results), sframe_record_plain) else list()
  names(blocks) <- NULL
  record <- list(
    record = "surveyframe results record",
    record_version = 1L,
    instrument_hash = sframe_hex(sframe_hash_value(instrument)),
    instrument_version = as.character(instrument$meta$version %||% ""),
    analysis_seed = as.character(seed),
    results = blocks
  )
  # An empty list would serialise as {} after canonicalisation, so the result
  # list is kept an array.
  payload <- sframe_canonical_payload(record[setdiff(names(record), "results")])
  payload$results <- lapply(blocks, sframe_canonical_payload)
  payload <- payload[order(names(payload))]
  json <- jsonlite::toJSON(payload, auto_unbox = TRUE, pretty = FALSE, null = "null",
                           na = "null", digits = NA)
  sub("\"results\":\\{\\}", "\"results\":[]", as.character(json))
}

# A digest as a plain 64-character string: openssl keeps its hash class on
# as.character(), which jsonlite cannot write.
sframe_hex <- function(h) {
  h <- unclass(h)
  if (is.raw(h)) paste(as.character(h), collapse = "") else as.vector(as.character(h))
}

sframe_sha256_text <- function(text) {
  sframe_hex(openssl::sha256(charToRaw(enc2utf8(text))))
}

sframe_sha256_file <- function(path) {
  con <- file(path, open = "rb")
  on.exit(close(con), add = TRUE)
  sframe_hex(openssl::sha256(con))
}

# The sha256 of responses held in memory: the data as JSON by column, in
# column order, with dates as ISO 8601. A data frame has no file to hash, and
# this form is the same for the same values whatever file they came from.
sframe_responses_sha256 <- function(data) {
  if (is.null(data)) return(NA_character_)
  df <- as.data.frame(data, stringsAsFactors = FALSE)
  df[] <- lapply(df, function(col) if (is.factor(col)) as.character(col) else col)
  json <- jsonlite::toJSON(df, dataframe = "columns", digits = NA, na = "null",
                           POSIXt = "ISO8601", Date = "ISO8601", null = "null")
  sframe_sha256_text(as.character(json))
}

# The file names beside a report: report.html gives report_results.json and
# report_manifest.json.
sframe_record_paths <- function(dest) {
  stem <- sub("\\.[^./\\\\]+$", "", dest)
  list(results = paste0(stem, "_results.json"),
       manifest = paste0(stem, "_manifest.json"))
}

# How the instrument's hash was checked, in words.
sframe_instrument_verification <- function(instrument) {
  v <- attr(instrument, "sframe_verified")
  if (isTRUE(v)) return("verified by read_sframe()")
  if (identical(v, FALSE)) return("not verified: read with verify = FALSE")
  "not read from a .sframe file in this session"
}

# The provenance block, 1 table for both engines.
sframe_report_provenance <- function(instrument, data, record_sha) {
  n_amend <- length(instrument$amendments %||% list())
  data.frame(
    Field = c("Instrument hash", "Instrument check", "Amendments disclosed",
              "Responses sha256", "Results record sha256", "surveyframe"),
    Value = c(
      sframe_hex(sframe_hash_value(instrument)),
      sframe_instrument_verification(instrument),
      as.character(n_amend),
      if (is.null(data)) "no responses supplied" else sframe_responses_sha256(data),
      record_sha,
      as.character(utils::packageVersion("surveyframe"))
    ),
    stringsAsFactors = FALSE
  )
}

# Write the manifest for an output file, its results record beside it.
sframe_write_manifest <- function(dest, instrument, data, record_path, extra = list()) {
  if (!file.exists(dest) || !file.exists(record_path)) return(invisible(NULL))
  paths <- sframe_record_paths(dest)
  obj <- function(id, type, file, hash, ...) {
    c(list(object_id = id, object_type = type, file_name = file,
           hash_algorithm = "SHA-256", hash_value = hash), list(...))
  }
  objects <- list(
    obj("instrument", "sframe_instrument", "", sframe_hex(sframe_hash_value(instrument)),
        hash_of = "the instrument content, as read_sframe() verifies it",
        version = as.character(instrument$meta$version %||% ""))
  )
  if (!is.null(data)) {
    objects <- c(objects, list(obj("responses", "responses", "",
                                   sframe_responses_sha256(data),
                                   hash_of = "the responses as JSON by column")))
  }
  objects <- c(objects, list(
    obj("results", "results_record", basename(record_path), sframe_sha256_file(record_path)),
    obj("report", paste0("report_", tolower(tools::file_ext(dest))), basename(dest),
        sframe_sha256_file(dest), hash_of = "the output as surveyframe generated it")
  ), extra)
  manifest <- list(
    manifest_version = 1L,
    study_id = as.character(instrument$meta$id %||% instrument$meta$title %||% ""),
    created_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
    software = paste0("R ", getRversion(), " and surveyframe ",
                      utils::packageVersion("surveyframe")),
    objects = objects
  )
  writeLines(jsonlite::toJSON(manifest, auto_unbox = TRUE, pretty = TRUE, null = "null",
                              digits = NA),
             paths$manifest, useBytes = TRUE)
  invisible(paths$manifest)
}
