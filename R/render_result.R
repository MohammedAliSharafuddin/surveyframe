# R/render_result.R
#
# One analysis result rendered as the report renders it: the formatted table,
# its caption and note, any second table, and the chart. A host such as Ethos
# kept its own map from method to chart and its own table formatting, a
# second copy of the report's choices that drifted with each release (Ethos
# request 1). This draws on the report's own code, so a host and the report
# show the same thing.

#' Render one analysis result as the report does
#'
#' Takes one result from [run_analysis_plan()] and returns what the report
#' shows for it: the formatted table with its caption and note, any second
#' table [sframe_result_supplement()] gives, the APA line, and the chart the
#' report picks for that method, with the instrument's labels. The table, the
#' chart and their choice per method come from the code [render_report()]
#' uses, so a host rendering results one at a time and the report agree.
#'
#' @param result One element of the list [run_analysis_plan()] returns.
#' @param data The response data the result was computed from. The chart is
#'   drawn from it, with the scales scored first as [run_analysis_plan()]
#'   scores them when `instrument` is given.
#' @param instrument The `sframe` the plan belongs to, or `NULL`. Gives the
#'   chart the item and choice labels the tables use.
#' @param palette `"web"` (default) or `"print"`, the report's 2 palettes.
#' @param format `"html"` (default) returns an HTML fragment with the chart
#'   embedded. `"png"` and `"svg"` write the chart to a file as well, and
#'   return its path in `chart_file`.
#' @param width,height,dpi The chart's size in inches and its resolution,
#'   for the embedded or written chart. Defaults 7 by 4.5 at 150 dpi.
#'
#' @return A list with `block_id`, `test`, `caption`, `apa`, `table` (a data
#'   frame), `note`, `supplement` (a list with `table` and `caption`, or
#'   `NULL`), `chart` (a `ggplot`, or `NULL` where the method has none or
#'   ggplot2 is absent), `html` (the fragment, for `format = "html"`), and
#'   `chart_file` (for `"png"` and `"svg"`). A result that failed carries its
#'   `error`, and `html` shows it.
#' @export
#' @seealso [run_analysis_plan()], [render_report()], [sframe_save_figures()]
#' @examples
#' \donttest{
#' d <- sframe_demo("two_group")
#' res <- run_analysis_plan(d$responses, d$instrument)
#' out <- render_result(res[[1]], d$responses, d$instrument)
#' out$caption
#' out$table
#' }
render_result <- function(result, data, instrument = NULL,
                          palette = c("web", "print"),
                          format = c("html", "png", "svg"),
                          width = 7, height = 4.5, dpi = 150) {
  palette <- rlang::arg_match(palette)
  format <- rlang::arg_match(format)
  if (!is.list(result)) {
    rlang::abort("`result` must be one element of run_analysis_plan()'s results.",
                 class = "sframe_error")
  }
  sframe_figure_settings(list(width = width, height = height, dpi = dpi))

  block_id <- as.character(result$block_id %||% "")[1]
  rq <- as.character(result$research_question %||% "")[1]
  caption <- paste(c(if (nzchar(block_id)) block_id, if (nzchar(rq)) rq), collapse = ": ")
  out <- list(block_id = block_id, test = result$test %||% "", caption = caption,
              apa = result$apa %||% "", error = result$error)

  lookup <- sframe_label_lookup(instrument)
  table <- result$table %||% tryCatch(sframe_result_table(result), error = function(e) NULL)
  if (is.data.frame(table)) {
    table <- tryCatch(sframe_humanize_table(table, lookup, exclude_cols = "Code"),
                      error = function(e) table)
  }
  out$table <- table
  out$supplement <- tryCatch(sframe_result_supplement(result), error = function(e) NULL)
  keys <- names(result$citations %||% list())
  out$note <- if (length(keys)) paste0("Method references: ", sframe_intext_citation(keys), ".") else ""

  # The chart the report would draw, labelled from the instrument, from the
  # data the plan ran on: run_analysis_plan() scores the scales first, and a
  # block on a scale score needs that column.
  if (inherits(instrument, "sframe") && length(instrument$scales) > 0 && is.data.frame(data)) {
    scale_ids <- vapply(instrument$scales, function(s) s$id, character(1))
    if (!all(scale_ids %in% names(data))) {
      data <- tryCatch(score_scales(data, instrument, keep_items = TRUE, keep_meta = TRUE),
                       error = function(e) data)
    }
  }
  out$chart <- NULL
  if (is.null(result$error) && requireNamespace("ggplot2", quietly = TRUE)) {
    out$chart <- if (inherits(result$plot, "ggplot")) result$plot else tryCatch(
      .sframe_with_plot_labels(lookup, sframe_plot_for_result(result, data, palette = palette),
                               instrument),
      error = function(e) NULL)
  }

  if (identical(format, "svg")) sframe_check_svg()
  if (format %in% c("png", "svg")) {
    out$chart_file <- if (inherits(out$chart, "ggplot")) {
      f <- tempfile(fileext = paste0(".", format))
      ggplot2::ggsave(f, out$chart, width = width, height = height, dpi = dpi,
                      device = format, bg = "white")
      f
    }
  }

  if (identical(format, "html")) {
    if (!is.null(result$error)) {
      out$html <- sprintf("<section class=\"sf-result\"><h3>%s</h3><p class=\"sf-error\">%s</p></section>",
                          htmltools_escape(caption), htmltools_escape(result$error))
    } else {
      old <- .sframe_figure_env$settings
      .sframe_figure_env$settings <- list(width = width, height = height, dpi = dpi)
      on.exit(.sframe_figure_env$settings <- old, add = TRUE)
      parts <- c(
        sprintf("<h3>%s</h3>", htmltools_escape(caption)),
        # What the block declared before the data, above the result (D12).
        sframe_declaration_html(result),
        if (nzchar(out$apa)) sprintf("<p class=\"sf-apa\">%s</p>", sframe_apa_html(out$apa)),
        if (is.data.frame(table)) .render_report_table(table, caption = caption, note = out$note),
        if (is.list(out$supplement) && is.data.frame(out$supplement$table)) {
          .render_report_table(out$supplement$table, caption = out$supplement$caption)
        },
        if (inherits(out$chart, "ggplot")) .render_report_ggplot_png(out$chart, alt = caption),
        if (nzchar(interp <- sframe_written_interpretation(result))) {
          sprintf("<p><strong>%s:</strong> %s</p>", sframe_interpretation_label,
                  htmltools_escape(interp))
        }
      )
      out$html <- paste0("<section class=\"sf-result\">", paste(parts, collapse = "\n"), "</section>")
    }
  }
  out
}
