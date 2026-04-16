# read_sframe.R and write_sframe.R

sframe_strip_component_class <- function(component) {
  class(component) <- NULL
  component
}

sframe_serialization_payload <- function(instrument, hash_value = "") {
  list(
    hash = list(algo = "sha256", value = hash_value),
    version = instrument$meta$version,
    meta = instrument$meta,
    items = lapply(instrument$items, sframe_strip_component_class),
    choices = lapply(instrument$choices, sframe_strip_component_class),
    scales = lapply(instrument$scales, sframe_strip_component_class),
    branching = lapply(instrument$branching, sframe_strip_component_class),
    checks = lapply(instrument$checks, sframe_strip_component_class),
    render = instrument$render
  )
}

sframe_hash_payload <- function(payload) {
  payload$hash$value <- ""
  json_for_hash <- jsonlite::toJSON(payload, auto_unbox = TRUE, pretty = FALSE)
  as.character(openssl::sha256(chartr("", "", json_for_hash)))
}

sframe_hash_value <- function(instrument) {
  sframe_hash_payload(sframe_serialization_payload(instrument))
}

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
  payload <- sframe_serialization_payload(instrument)

  # Insert real hash
  payload$hash$value <- sframe_hash_payload(payload)

  json_out <- jsonlite::toJSON(payload, auto_unbox = TRUE, pretty = pretty,
                               null = "null")
  writeLines(json_out, con = path, useBytes = FALSE)

  invisible(path)
}

sframe_as_vector <- function(x, mode = NULL) {
  if (is.null(x)) {
    return(NULL)
  }

  out <- unlist(x, recursive = TRUE, use.names = FALSE)
  if (is.null(mode)) {
    return(out)
  }

  switch(
    mode,
    character = as.character(out),
    numeric = as.numeric(out),
    logical = as.logical(out),
    out
  )
}

sframe_restore_item <- function(item) {
  item$required <- isTRUE(item$required)
  item$reverse <- isTRUE(item$reverse)
  class(item) <- "sf_item"
  item
}

sframe_restore_choices <- function(choice) {
  choice$values <- sframe_as_vector(choice$values)
  choice$labels <- sframe_as_vector(choice$labels, "character")
  choice$allow_other <- isTRUE(choice$allow_other)
  choice$randomise <- isTRUE(choice$randomise)
  class(choice) <- "sf_choices"
  choice
}

sframe_restore_scale <- function(scale) {
  scale$items <- sframe_as_vector(scale$items, "character")
  scale$reverse_items <- sframe_as_vector(scale$reverse_items, "character")
  scale$weights <- sframe_as_vector(scale$weights, "numeric")
  if (!is.null(scale$min_valid)) {
    scale$min_valid <- as.integer(scale$min_valid)
  }
  class(scale) <- "sf_scale"
  scale
}

sframe_restore_branch <- function(branch) {
  if (is.list(branch$value) && length(branch$value) > 0) {
    branch$value <- sframe_as_vector(branch$value)
  }
  class(branch) <- "sf_branch"
  branch
}

sframe_restore_check <- function(check) {
  check$pass_values <- sframe_as_vector(check$pass_values)
  class(check) <- "sf_check"
  check
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
      meta      = within(parsed$meta, {
        authors <- sframe_as_vector(authors, "character")
        languages <- sframe_as_vector(languages, "character")
      }),
      items     = lapply(parsed$items, sframe_restore_item),
      choices   = lapply(parsed$choices, sframe_restore_choices),
      scales    = lapply(parsed$scales, sframe_restore_scale),
      branching = lapply(parsed$branching, sframe_restore_branch),
      checks    = lapply(parsed$checks, sframe_restore_check),
      render    = parsed$render %||% list()
    ),
    class = "sframe"
  )

  if (validate) {
    instrument <- validate_sframe(instrument, strict = TRUE)
  }

  instrument
}
