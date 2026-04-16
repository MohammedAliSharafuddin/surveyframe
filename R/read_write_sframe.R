# read_sframe.R and write_sframe.R

#' Write an instrument to a .sframe file
#'
#' Serialises an `sframe` instrument object to a UTF-8 JSON file with a
#' SHA-256 integrity hash. The instrument is validated before writing unless
#' the object already carries a valid status. The hash is computed over the
#' full serialised content with the `hash.value` field set to an empty string.
#'
#' @param instrument An `sframe` object created by [sf_instrument()].
#' @param path Character. The file path to write to. The `.sframe` extension
#'   is appended automatically if not already present.
#' @param pretty Logical. Whether to write formatted JSON with indentation.
#'   Defaults to `TRUE`. Set to `FALSE` for compact files.
#' @param overwrite Logical. Whether to overwrite an existing file. Defaults
#'   to `FALSE`.
#'
#' @return The file path, invisibly.
#' @export
#' @seealso [read_sframe()], [validate_sframe()]
#'
#' @examples
#' \dontrun{
#' write_sframe(instr, "my_instrument.sframe")
#' }
write_sframe <- function(instrument, path, pretty = TRUE, overwrite = FALSE) {
  stopifnot(inherits(instrument, "sframe"))

  strip_component_class <- function(component) {
    class(component) <- NULL
    component
  }

  if (!endsWith(path, ".sframe")) {
    path <- paste0(path, ".sframe")
  }

  if (file.exists(path) && !overwrite) {
    sframe_abort_import(
      paste0("File already exists: '", path,
             "'. Use overwrite = TRUE to replace it."),
      path = path
    )
  }

  # Validate before writing
  validate_sframe(instrument, strict = TRUE)

  # Build the full JSON payload with an empty hash placeholder
  payload <- list(
    hash = list(algo = "sha256", value = ""),
    version   = instrument$meta$version,
    meta      = instrument$meta,
    items     = lapply(instrument$items, strip_component_class),
    choices   = lapply(instrument$choices, strip_component_class),
    scales    = lapply(instrument$scales, strip_component_class),
    branching = lapply(instrument$branching, strip_component_class),
    checks    = lapply(instrument$checks, strip_component_class),
    render    = instrument$render
  )

  # Compute hash over content with empty hash value
  json_for_hash <- jsonlite::toJSON(payload, auto_unbox = TRUE, pretty = FALSE)
  hash_value    <- as.character(openssl::sha256(chartr("", "", json_for_hash)))

  # Insert real hash
  payload$hash$value <- hash_value

  json_out <- jsonlite::toJSON(payload, auto_unbox = TRUE, pretty = pretty,
                               null = "null")
  writeLines(json_out, con = path, useBytes = FALSE)

  invisible(path)
}

#' Read an instrument from a .sframe file
#'
#' Reads a `.sframe` JSON file and reconstructs an `sframe` instrument object.
#' The SHA-256 integrity hash is verified on load unless `validate = FALSE`.
#'
#' @param path Character. The path to a `.sframe` file.
#' @param validate Logical. Whether to validate the loaded instrument with
#'   [validate_sframe()]. Defaults to `TRUE`.
#'
#' @return An `sframe` object.
#' @export
#' @seealso [write_sframe()], [validate_sframe()]
#'
#' @examples
#' \dontrun{
#' instr <- read_sframe("my_instrument.sframe")
#' }
read_sframe <- function(path, validate = TRUE) {
  if (!file.exists(path)) {
    sframe_abort_import(
      paste0("File not found: '", path, "'."),
      path = path
    )
  }

  raw_text <- tryCatch(
    readLines(path, warn = FALSE, encoding = "UTF-8"),
    error = function(e) {
      sframe_abort_import(
        paste0("Could not read file: '", path, "'. ", conditionMessage(e)),
        path = path
      )
    }
  )

  raw_json <- paste(raw_text, collapse = "\n")

  parsed <- tryCatch(
    jsonlite::fromJSON(raw_json, simplifyVector = FALSE),
    error = function(e) {
      sframe_abort_import(
        paste0("Failed to parse JSON in '", path, "'. ", conditionMessage(e)),
        path = path
      )
    }
  )

  # Verify hash
  stored_hash <- parsed$hash$value
  parsed$hash$value <- ""
  json_for_check <- jsonlite::toJSON(parsed, auto_unbox = TRUE, pretty = FALSE)
  computed_hash  <- as.character(openssl::sha256(chartr("", "", json_for_check)))

  if (!identical(stored_hash, computed_hash)) {
    sframe_abort_import(
      paste0(
        "Integrity check failed for '", path, "'. ",
        "The file may have been modified after it was written. ",
        "Expected hash: ", computed_hash, ". ",
        "Stored hash: ", stored_hash, "."
      ),
      path = path
    )
  }

  # Reconstruct the sframe object
  instrument <- structure(
    list(
      meta      = parsed$meta,
      items     = parsed$items,
      choices   = parsed$choices,
      scales    = parsed$scales,
      branching = parsed$branching,
      checks    = parsed$checks,
      render    = parsed$render %||% list()
    ),
    class = "sframe"
  )

  if (validate) {
    instrument <- validate_sframe(instrument, strict = TRUE)
  }

  instrument
}
