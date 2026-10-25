# R/figures.R
#
# Figure size, resolution and format, for the report and for charts saved as
# files. A journal asks for figures at a stated resolution and width, often
# 300 dpi for print and sometimes TIFF, PDF or SVG, and render_report() fixed
# its own output (Ethos request 19).

.sframe_figure_formats <- c("png", "svg", "pdf", "tiff", "jpeg")

# Checks a figures list: any of width and height in inches, dpi, and format.
# Absent entries stay absent, meaning each engine's own default.
sframe_figure_settings <- function(figures) {
  figures <- figures %||% list()
  abort <- function(msg) rlang::abort(msg, class = c("sframe_validation_error", "sframe_error"))
  if (!is.list(figures)) abort("`figures` must be a list, for example list(width = 7, dpi = 300).")
  unknown <- setdiff(names(figures), c("width", "height", "dpi", "format"))
  if (length(unknown) > 0) {
    abort(paste0("`figures` takes width, height, dpi and format. Unknown: ",
                 paste(unknown, collapse = ", "), "."))
  }
  for (k in intersect(c("width", "height", "dpi"), names(figures))) {
    v <- figures[[k]]
    if (!is.numeric(v) || length(v) != 1 || is.na(v) || v <= 0) {
      abort(paste0("`figures$", k, "` must be one positive number."))
    }
  }
  if (!is.null(figures$format)) {
    figures$format <- tolower(as.character(figures$format)[1])
    if (identical(figures$format, "jpg")) figures$format <- "jpeg"
    if (!figures$format %in% .sframe_figure_formats) {
      abort(paste0("`figures$format` must be one of ",
                   paste(.sframe_figure_formats, collapse = ", "), "."))
    }
  }
  figures
}

# The settings in force while render_report() draws, read by the built-in
# HTML engine's chart helpers.
.sframe_figure_env <- new.env(parent = emptyenv())

#' Save the charts from an analysis plan as files
#'
#' Writes each chart [run_analysis_plan()] drew with `plots = TRUE` to its own
#' file, at the size, resolution and format a journal asks for. The charts the
#' exported `sframe_plot_*()` functions return are `ggplot` objects, so any one
#' of them can also be saved at any size with [ggplot2::ggsave()].
#'
#' @param results The list [run_analysis_plan()] returns, run with
#'   `plots = TRUE`.
#' @param dir Directory to write into. Created when absent.
#' @param width,height Size in inches. Default 7 by 4.5.
#' @param dpi Resolution in dots per inch, for the raster formats. Default 300.
#' @param format One of `"png"` (default), `"tiff"`, `"jpeg"`, `"pdf"` or
#'   `"svg"`.
#'
#' @return The paths written, named by block id, invisibly. A block with no
#'   chart writes nothing.
#' @export
#' @seealso [render_report()], which takes the same settings as `figures`.
#' @examples
#' \donttest{
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   d <- sframe_demo("two_group")
#'   res <- run_analysis_plan(d$responses, d$instrument, plots = TRUE)
#'   paths <- sframe_save_figures(res, file.path(tempdir(), "figures"),
#'                                width = 6, height = 4, dpi = 300)
#'   basename(paths)
#' }
#' }
sframe_save_figures <- function(results, dir, width = 7, height = 4.5, dpi = 300,
                                format = c("png", "tiff", "jpeg", "pdf", "svg")) {
  rlang::check_installed("ggplot2", reason = "to save charts as files.")
  format <- rlang::arg_match(format)
  sframe_figure_settings(list(width = width, height = height, dpi = dpi, format = format))
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  paths <- character(0)
  for (i in seq_along(results)) {
    r <- results[[i]]
    if (!inherits(r$plot, "ggplot")) next
    id <- as.character(r$block_id %||% names(results)[i] %||% i)[1]
    file <- file.path(dir, paste0(gsub("[^A-Za-z0-9_.-]", "_", id), ".", format))
    ggplot2::ggsave(file, r$plot, width = width, height = height, dpi = dpi,
                    device = format, bg = "white")
    paths[id] <- file
  }
  invisible(paths)
}
