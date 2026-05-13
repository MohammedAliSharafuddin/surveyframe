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
#' cs    <- sf_choices("ag5", 1:5,
#'            c("Strongly disagree", "Disagree", "Neutral",
#'              "Agree", "Strongly agree"))
#' i1    <- sf_item("sat_1", "Item 1", type = "likert",
#'                  choice_set = "ag5", scale_id = "sat")
#' i2    <- sf_item("sat_2", "Item 2", type = "likert",
#'                  choice_set = "ag5", scale_id = "sat")
#' scale <- sf_scale("sat", "Satisfaction", items = c("sat_1", "sat_2"))
#' instr <- sf_instrument("Demo Survey", components = list(cs, i1, i2, scale))
#'
#' cb <- codebook_report(instr)
#' print(cb)
#' nrow(cb$items_table)
#' nrow(cb$scales_table)
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

  items_table <- data.frame(
    id         = vapply(instrument$items, function(i) i$id,          character(1)),
    label      = vapply(instrument$items, function(i) i$label,       character(1)),
    type       = vapply(instrument$items, function(i) i$type,        character(1)),
    choice_set = vapply(instrument$items, function(i) i$choice_set %||% "", character(1)),
    scale_id   = vapply(instrument$items, function(i) i$scale_id %||% "", character(1)),
    reverse    = vapply(instrument$items, function(i) isTRUE(i$reverse), logical(1)),
    required   = vapply(instrument$items, function(i) isTRUE(i$required), logical(1)),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )

  choices_table <- if (length(instrument$choices) > 0) {
    rows <- lapply(instrument$choices, function(cs) {
      data.frame(
        choice_set_id = cs$id,
        value         = as.character(cs$values),
        label         = cs$labels,
        stringsAsFactors = FALSE,
        check.names = FALSE
      )
    })
    do.call(rbind, rows)
  } else {
    data.frame(
      choice_set_id = character(0),
      value = character(0),
      label = character(0),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
  }

  scales_table <- if (length(instrument$scales) > 0) {
    data.frame(
      id     = vapply(instrument$scales, function(s) s$id,    character(1)),
      label  = vapply(instrument$scales, function(s) s$label, character(1)),
      method = vapply(instrument$scales, function(s) s$method, character(1)),
      n_items = vapply(instrument$scales, function(s) length(s$items), integer(1)),
      items  = vapply(instrument$scales, function(s) paste(s$items, collapse = ", "), character(1)),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
  } else {
    data.frame(
      id = character(0),
      label = character(0),
      method = character(0),
      n_items = integer(0),
      items = character(0),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
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
#' Generates an HTML report that includes the instrument codebook, data
#' quality summary, reliability diagnostics, and analysis-plan content.
#' When Quarto and the bundled template are available, the report is rendered
#' through Quarto. Otherwise, surveyframe writes an internal HTML fallback so
#' the reporting workflow still runs on machines without Quarto.
#'
#' @param instrument An `sframe` object.
#' @param data A `tibble` or `data.frame` of responses, or NULL to generate a
#'   codebook-only report.
#' @param output_file Character or NULL. The output file path. When NULL, a
#'   temporary file is written and its path returned.
#' @param output_path Character or NULL. Alias for `output_file`. If both are
#'   supplied, `output_file` takes precedence.
#' @param format Character. Output format. Currently `"html"`.
#' @param include_quality Logical. Whether to include the data quality report.
#'   Requires `data`. Defaults to `TRUE`.
#' @param include_reliability Logical. Whether to include reliability
#'   diagnostics. Requires `data`. Defaults to `TRUE`.
#' @param include_codebook Logical. Whether to include the instrument codebook.
#'   Defaults to `TRUE`.
#' @param include_analysis Logical. Whether to include analysis-plan results
#'   when `data` are supplied and the instrument has an `analysis_plan`.
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
    output_path       = NULL,
    format            = c("html"),
    include_quality   = TRUE,
    include_reliability = TRUE,
    include_codebook  = TRUE,
    include_analysis  = TRUE
) {
  stopifnot(inherits(instrument, "sframe"))

  format <- rlang::arg_match(format)
  dest <- output_file %||% output_path %||% tempfile(fileext = ".html")
  dest <- path.expand(dest)

  output_dir <- dirname(dest)
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  }
  output_dir <- normalizePath(output_dir, mustWork = FALSE)
  output_name <- basename(dest)

  has_quarto <- requireNamespace("quarto", quietly = TRUE) &&
    nzchar(Sys.which("quarto"))
  template <- system.file("templates", "report.qmd", package = "surveyframe")
  if (has_quarto && file.exists(template)) {
    render_dir <- tempfile("surveyframe-report-")
    dir.create(render_dir, recursive = TRUE, showWarnings = FALSE)
    on.exit(unlink(render_dir, recursive = TRUE, force = TRUE), add = TRUE)
    render_input <- file.path(render_dir, "report.qmd")
    if (!file.copy(template, render_input, overwrite = TRUE)) {
      rlang::abort(
        "Could not prepare the Quarto report template for rendering.",
        class = "sframe_error"
      )
    }

    # Write instrument and data to temp RDS for the template to read
    tmp_instr <- tempfile(fileext = ".rds")
    tmp_data  <- tempfile(fileext = ".rds")
    temp_rds <- tmp_instr
    saveRDS(instrument, tmp_instr)
    if (!is.null(data)) {
      saveRDS(data, tmp_data)
      temp_rds <- c(temp_rds, tmp_data)
    } else {
      tmp_data <- ""
    }
    on.exit(unlink(temp_rds, force = TRUE), add = TRUE)

    params <- list(
      instrument_path     = tmp_instr,
      data_path           = tmp_data,
      include_quality     = include_quality && !is.null(data),
      include_reliability = include_reliability && !is.null(data),
      include_codebook    = include_codebook,
      include_analysis    = include_analysis,
      instrument_hash     = sframe_hash_value(instrument)
    )

    quarto_ok <- tryCatch({
      quarto::quarto_render(
        input          = render_input,
        output_file    = output_name,
        quarto_args    = c("--output-dir", output_dir),
        execute_dir    = render_dir,
        execute_params = params
      )
      TRUE
    }, error = function(e) FALSE)

    if (isTRUE(quarto_ok) && file.exists(dest)) {
      return(invisible(dest))
    }
  }

  .render_report_html(
    instrument          = instrument,
    data                = data,
    output_path         = dest,
    include_quality     = include_quality && !is.null(data),
    include_reliability = include_reliability && !is.null(data),
    include_codebook    = include_codebook,
    include_analysis    = include_analysis
  )

  invisible(dest)
}

.render_report_html <- function(
    instrument,
    data = NULL,
    output_path,
    include_quality = TRUE,
    include_reliability = TRUE,
    include_codebook = TRUE,
    include_analysis = TRUE
) {
  meta <- instrument$meta %||% list()
  sections <- character(0)

  if (isTRUE(include_codebook)) {
    cb <- codebook_report(instrument)
    codebook_parts <- c(
      "<h2>Codebook</h2>",
      .render_report_table(cb$items_table, "Survey items")
    )
    if (nrow(cb$choices_table) > 0) {
      codebook_parts <- c(
        codebook_parts,
        .render_report_table(cb$choices_table, "Choice sets")
      )
    }
    if (nrow(cb$scales_table) > 0) {
      codebook_parts <- c(
        codebook_parts,
        .render_report_table(cb$scales_table, "Scale definitions")
      )
    }
    sections <- c(sections, sprintf("<section>%s</section>", paste(codebook_parts, collapse = "\n")))
  }

  if (isTRUE(include_quality)) {
    qr <- tryCatch(quality_report(data, instrument), error = function(e) e)
    quality_html <- if (inherits(qr, "error")) {
      sprintf("<p>%s</p>", htmltools_escape(conditionMessage(qr)))
    } else {
      summary_tbl <- data.frame(
        Metric = c("Respondents", "Items", "Flagged", "Flag rate"),
        Value = c(
          qr$summary$n_respondents,
          qr$summary$n_items,
          qr$summary$n_flagged,
          sprintf("%.1f%%", qr$summary$flag_rate * 100)
        ),
        stringsAsFactors = FALSE
      )
      paste(
        "<h2>Data Quality</h2>",
        .render_report_table(summary_tbl, "Quality summary"),
        collapse = "\n"
      )
    }
    sections <- c(sections, sprintf("<section>%s</section>", quality_html))
  }

  if (isTRUE(include_reliability)) {
    rr <- tryCatch(reliability_report(data, instrument), error = function(e) e)
    reliability_html <- if (inherits(rr, "error")) {
      sprintf(
        "<h2>Reliability</h2><p>%s</p>",
        htmltools_escape(conditionMessage(rr))
      )
    } else if (length(rr) == 0) {
      "<h2>Reliability</h2><p>No scales with enough data were available for reliability analysis.</p>"
    } else {
      rel_tbl <- do.call(
        rbind,
        lapply(rr, function(scale) {
          data.frame(
            Scale = paste0(scale$label, " (", scale$scale_id, ")"),
            Items = scale$n_items,
            N = scale$n,
            Alpha = if (!is.null(scale$alpha)) sprintf("%.3f", scale$alpha) else "n/a",
            Omega_h = if (!is.null(scale$omega_h)) sprintf("%.3f", scale$omega_h) else "n/a",
            Omega_t = if (!is.null(scale$omega_t)) sprintf("%.3f", scale$omega_t) else "n/a",
            stringsAsFactors = FALSE
          )
        })
      )
      paste(
        "<h2>Reliability</h2>",
        "<p>Cronbach alpha and McDonald's omega by scale.</p>",
        .render_report_table(rel_tbl, "Scale reliability"),
        collapse = "\n"
      )
    }
    sections <- c(sections, sprintf("<section>%s</section>", reliability_html))
  }

  if (isTRUE(include_analysis) && length(instrument$analysis_plan %||% list()) > 0) {
    analysis_html <- .render_report_analysis_section(instrument, data)
    sections <- c(sections, sprintf("<section>%s</section>", analysis_html))
  }

  repro_tbl <- data.frame(
    Field = c("Instrument hash", "Generated"),
    Value = c(
      sframe_hash_value(instrument),
      format(Sys.time(), "%Y-%m-%d %H:%M %Z")
    ),
    stringsAsFactors = FALSE
  )
  sections <- c(
    sections,
    sprintf(
      "<section><h2>Reproducibility</h2>%s</section>",
      .render_report_table(repro_tbl, "Reproducibility details")
    )
  )

  title <- htmltools_escape(meta$title %||% "Survey Report")
  subtitle <- sprintf(
    "Version %s",
    htmltools_escape(meta$version %||% "")
  )

  html <- sprintf(
    paste(
      "<!DOCTYPE html>",
      "<html lang=\"en\">",
      "<head>",
      "<meta charset=\"UTF-8\">",
      "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">",
      "<title>%s</title>",
      "<style>",
      "body { font-family: Arial, sans-serif; max-width: 960px; margin: 0 auto; padding: 32px 20px; color: #1f2933; line-height: 1.6; }",
      "h1, h2, h3 { color: #102a43; }",
      "section { margin: 0 0 28px; padding-bottom: 12px; border-bottom: 1px solid #d9e2ec; }",
      "table { width: 100%%; border-collapse: collapse; margin: 12px 0 0; }",
      "caption { text-align: left; font-weight: 700; margin-bottom: 8px; }",
      "th, td { border: 1px solid #bcccdc; padding: 8px 10px; text-align: left; vertical-align: top; }",
      "th { background: #f0f4f8; }",
      ".meta { color: #52606d; margin-bottom: 24px; }",
      ".rq-block { margin: 18px 0; padding: 14px; background: #f8fafc; border: 1px solid #d9e2ec; border-radius: 6px; }",
      ".apa { font-family: Georgia, serif; }",
      "</style>",
      "</head>",
      "<body>",
      "<h1>%s</h1>",
      "<p class=\"meta\">%s</p>",
      "%s",
      "</body>",
      "</html>",
      sep = "\n"
    ),
    title,
    title,
    subtitle,
    paste(sections, collapse = "\n")
  )

  writeLines(html, output_path)
  invisible(output_path)
}

.render_report_analysis_section <- function(instrument, data = NULL) {
  plan <- instrument$analysis_plan %||% list()
  if (length(plan) == 0) {
    return("")
  }

  blocks <- if (is.null(data)) {
    vapply(seq_along(plan), function(i) {
      rq <- plan[[i]]
      sprintf(
        paste(
          "<div class=\"rq-block\">",
          "<h3>RQ %d: %s</h3>",
          "<p><strong>Planned test:</strong> %s</p>",
          "<p><strong>Variables:</strong> %s</p>",
          "</div>",
          sep = "\n"
        ),
        i,
        htmltools_escape(rq$research_question %||% paste("Research Question", i)),
        htmltools_escape(rq$test %||% ""),
        htmltools_escape(paste(rq$variables %||% character(0), collapse = ", "))
      )
    }, character(1))
  } else {
    results <- tryCatch(run_analysis_plan(data, instrument), error = function(e) e)
    if (inherits(results, "error")) {
      return(sprintf(
        "<h2>Analysis Plan</h2><p>%s</p>",
        htmltools_escape(conditionMessage(results))
      ))
    }

    vapply(seq_along(results), function(i) {
      result <- results[[i]]
      table_html <- ""
      if (is.data.frame(result$table)) {
        table_html <- .render_report_table(result$table, "Results table")
      }
      sprintf(
        paste(
          "<div class=\"rq-block\">",
          "<h3>RQ %d: %s</h3>",
          "<p class=\"apa\"><strong>Result:</strong> %s</p>",
          "%s",
          "</div>",
          sep = "\n"
        ),
        i,
        htmltools_escape(result$research_question %||% paste("Research Question", i)),
        htmltools_escape(result$apa %||% result$error %||% ""),
        table_html
      )
    }, character(1))
  }

  paste(c("<h2>Analysis Plan</h2>", blocks), collapse = "\n")
}

.render_report_table <- function(x, caption = NULL) {
  if (!is.data.frame(x) || nrow(x) == 0) {
    return("")
  }

  header <- paste(
    sprintf("<th>%s</th>", htmltools_escape(colnames(x))),
    collapse = ""
  )
  rows <- paste(
    apply(x, 1, function(row) {
      cells <- paste(
        sprintf("<td>%s</td>", htmltools_escape(as.character(row))),
        collapse = ""
      )
      sprintf("<tr>%s</tr>", cells)
    }),
    collapse = "\n"
  )

  if (!is.null(caption) && nzchar(caption)) {
    caption <- sprintf("<caption>%s</caption>", htmltools_escape(caption))
  } else {
    caption <- ""
  }

  sprintf(
    "<table>%s<thead><tr>%s</tr></thead><tbody>%s</tbody></table>",
    caption,
    header,
    rows
  )
}
