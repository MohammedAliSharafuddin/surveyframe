# codebook_report.R

#' Generate a survey codebook from an instrument object
#'
#' Produces a structured codebook listing all items, their types, choice sets,
#' scale membership, and reverse-coding status. The codebook can be rendered
#' as HTML or Markdown.
#'
#' @param instrument An `sframe` object.
#' @param format Character. Output format. Either `"html"` or `"md"`.
#'
#' @return An object of class `sframe_codebook`, a list with elements
#'   `instrument_meta`, `items_table`, `choices_table`, and `scales_table`.
#'   Call `print()` to display a compact summary or use `render_report()` to
#'   include the codebook in a full report.
#' @export
#' @seealso [render_report()]
#'
#' @examples
#' \dontrun{
#' cb <- codebook_report(instr, format = "html")
#' print(cb)
#' }
codebook_report <- function(instrument, format = c("html", "md")) {
  stopifnot(inherits(instrument, "sframe"))
  format <- rlang::arg_match(format)

  item_ids <- vapply(instrument$items, function(i) i$id, character(1))

  # Build reverse map
  reverse_map <- stats::setNames(
    vapply(instrument$items, function(i) isTRUE(i$reverse), logical(1)),
    item_ids
  )
  scale_map <- stats::setNames(
    vapply(instrument$items, function(i) i$scale_id %||% "", character(1)),
    item_ids
  )

  items_table <- tibble::tibble(
    id         = vapply(instrument$items, function(i) i$id,          character(1)),
    label      = vapply(instrument$items, function(i) i$label,       character(1)),
    type       = vapply(instrument$items, function(i) i$type,        character(1)),
    choice_set = vapply(instrument$items, function(i) i$choice_set %||% "", character(1)),
    scale_id   = vapply(instrument$items, function(i) i$scale_id %||% "", character(1)),
    reverse    = vapply(instrument$items, function(i) isTRUE(i$reverse), logical(1)),
    required   = vapply(instrument$items, function(i) isTRUE(i$required), logical(1))
  )

  choices_table <- if (length(instrument$choices) > 0) {
    rows <- lapply(instrument$choices, function(cs) {
      tibble::tibble(
        choice_set_id = cs$id,
        value         = as.character(cs$values),
        label         = cs$labels
      )
    })
    do.call(rbind, rows)
  } else {
    tibble::tibble(choice_set_id = character(0), value = character(0),
                   label = character(0))
  }

  scales_table <- if (length(instrument$scales) > 0) {
    tibble::tibble(
      id     = vapply(instrument$scales, function(s) s$id,    character(1)),
      label  = vapply(instrument$scales, function(s) s$label, character(1)),
      method = vapply(instrument$scales, function(s) s$method, character(1)),
      n_items = vapply(instrument$scales, function(s) length(s$items), integer(1)),
      items  = vapply(instrument$scales, function(s) paste(s$items, collapse = ", "), character(1))
    )
  } else {
    tibble::tibble(id = character(0), label = character(0),
                   method = character(0), n_items = integer(0), items = character(0))
  }

  structure(
    list(
      instrument_meta = instrument$meta,
      items_table     = items_table,
      choices_table   = choices_table,
      scales_table    = scales_table,
      format          = format
    ),
    class = "sframe_codebook"
  )
}

#' @exportS3Method print sframe_codebook
print.sframe_codebook <- function(x, ...) {
  cat(sprintf("Codebook: %s v%s\n", x$instrument_meta$title,
              x$instrument_meta$version))
  cat(sprintf("  %d items  |  %d choice sets  |  %d scales\n",
              nrow(x$items_table), nrow(unique(x$choices_table["choice_set_id"])),
              nrow(x$scales_table)))
  cat("\nItems:\n")
  print(x$items_table[, c("id", "label", "type", "scale_id", "reverse")])
  invisible(x)
}


# render_report.R

#' Render a reproducible survey report
#'
#' Generates a self-contained Quarto HTML report that includes the instrument
#' codebook, data quality summary, and reliability diagnostics. All outputs
#' are derived from the instrument object and the response data supplied,
#' making the report fully reproducible from those two inputs.
#'
#' Requires the `quarto` package. An error is raised if it is not installed.
#'
#' @param instrument An `sframe` object.
#' @param data A `tibble` or `data.frame` of responses, or NULL to generate a
#'   codebook-only report.
#' @param output_file Character or NULL. The output file path. When NULL, a
#'   temporary file is written and its path returned.
#' @param format Character. Output format. Only `"html"` is supported in
#'   v0.1.
#' @param include_quality Logical. Whether to include the data quality report.
#'   Requires `data`. Defaults to `TRUE`.
#' @param include_reliability Logical. Whether to include reliability
#'   diagnostics. Requires `data`. Defaults to `TRUE`.
#' @param include_codebook Logical. Whether to include the instrument codebook.
#'   Defaults to `TRUE`.
#'
#' @return The output file path, invisibly.
#' @export
#' @seealso [codebook_report()], [quality_report()], [reliability_report()]
#'
#' @examples
#' \dontrun{
#' render_report(instr, data = responses, output_file = "my_report.html")
#' }
render_report <- function(
    instrument,
    data              = NULL,
    output_file       = NULL,
    format            = c("html"),
    include_quality   = TRUE,
    include_reliability = TRUE,
    include_codebook  = TRUE
) {
  rlang::check_installed("quarto", reason = "to render survey reports")
  stopifnot(inherits(instrument, "sframe"))

  format <- rlang::arg_match(format)

  if (is.null(output_file)) {
    output_file <- tempfile(fileext = ".html")
  }

  output_file <- path.expand(output_file)
  output_dir <- dirname(output_file)
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  }
  output_dir <- normalizePath(output_dir, mustWork = FALSE)
  output_name <- basename(output_file)

  template <- system.file("templates", "report.qmd", package = "surveyframe")
  if (!file.exists(template)) {
    rlang::abort("Report template not found. Please reinstall surveyframe.",
                 class = "sframe_error")
  }

  render_dir <- tempfile("surveyframe-report-")
  dir.create(render_dir, recursive = TRUE, showWarnings = FALSE)
  render_input <- file.path(render_dir, "report.qmd")
  if (!file.copy(template, render_input, overwrite = TRUE)) {
    rlang::abort("Could not prepare the Quarto report template for rendering.",
                 class = "sframe_error")
  }

  # Write instrument and data to temp RDS for the template to read
  tmp_instr <- tempfile(fileext = ".rds")
  tmp_data  <- tempfile(fileext = ".rds")
  saveRDS(instrument, tmp_instr)
  if (!is.null(data)) saveRDS(data, tmp_data) else tmp_data <- ""

  params <- list(
    instrument_path     = tmp_instr,
    data_path           = tmp_data,
    include_quality     = include_quality && !is.null(data),
    include_reliability = include_reliability && !is.null(data),
    include_codebook    = include_codebook,
    instrument_hash     = sframe_hash_value(instrument)
  )

  quarto::quarto_render(
    input         = render_input,
    output_file   = output_name,
    quarto_args   = c("--output-dir", output_dir),
    execute_dir   = render_dir,
    execute_params = params
  )

  invisible(output_file)
}
