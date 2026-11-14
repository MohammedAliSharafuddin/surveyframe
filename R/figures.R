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

# Whether ggsave() can write SVG here. It writes SVG only through svglite, so
# R's own Cairo device does not count: with Cairo and no svglite, ggsave()
# stopped and the built-in engine's chart was left out.
sframe_svg_available <- function() {
  sframe_has_svglite()
}

sframe_has_svglite <- function() requireNamespace("svglite", quietly = TRUE)

# Whether R's own svg() device opens a file here. On macOS it needs the Cairo
# that XQuartz installs. Without XQuartz, capabilities("cairo") still says
# TRUE, svg() only warns "failed to load cairo DLL" and opens nothing, and
# knitr then wrote no figure (CI run 41984181153). Probed once per session.
# The probe closes only the device it opened and sets back the current one.
sframe_cairo_svg_works <- function() {
  if (!is.null(.sframe_figure_env$cairo_svg)) return(.sframe_figure_env$cairo_svg)
  before <- grDevices::dev.list()
  current <- grDevices::dev.cur()
  file <- tempfile(fileext = ".svg")
  ok <- tryCatch(suppressWarnings({
    grDevices::svg(file)
    opened <- setdiff(grDevices::dev.list(), before)
    if (length(opened)) grDevices::dev.off(opened[[1]])
    length(opened) > 0
  }), error = function(e) FALSE)
  if (current > 1) grDevices::dev.set(current)
  unlink(file)
  .sframe_figure_env$cairo_svg <- isTRUE(ok)
  .sframe_figure_env$cairo_svg
}

# The device a Quarto report draws an SVG figure with: R's own svg() where
# Cairo opens, as before, else svglite when installed, else PNG.
sframe_report_svg_device <- function() {
  if (sframe_cairo_svg_works()) "svg" else if (sframe_has_svglite()) "svglite" else "png"
}

sframe_check_svg <- function() {
  if (!sframe_svg_available()) {
    rlang::abort(paste0("SVG output needs the svglite package on this system. ",
                        "Install it with install.packages(\"svglite\")."),
                 class = "sframe_error")
  }
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
#' @return The paths written, named by block id, invisibly. Only blocks
#'   that drew a chart write a file.
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
#'   sframe_show(paths[1])
#' }
#' }
#' @family Report functions
sframe_save_figures <- function(results, dir, width = 7, height = 4.5, dpi = 300,
                                format = c("png", "tiff", "jpeg", "pdf", "svg")) {
  rlang::check_installed("ggplot2", reason = "to save charts as files.")
  format <- rlang::arg_match(format)
  sframe_figure_settings(list(width = width, height = height, dpi = dpi, format = format))
  if (identical(format, "svg")) sframe_check_svg()
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

# Wraps text to about `chars` characters a line, keeping existing line breaks.
sframe_wrap_text <- function(x, chars) {
  chars <- max(8L, as.integer(chars))
  vapply(as.character(x), function(s) {
    if (is.na(s) || !nzchar(s)) return(s)
    paste(unlist(lapply(strsplit(s, "\n", fixed = TRUE)[[1]], function(line) {
      if (nchar(line) <= chars) line else strwrap(line, width = chars)
    })), collapse = "\n")
  }, character(1), USE.NAMES = FALSE)
}

# Fits a finished chart to the export width, so the default 6.5 by 4 inch
# figure no longer clips titles, subtitles, captions, axis text or legends
# at its edges (CX-23). Wraps the plot labels and long discrete labels,
# lays a long legend out over as many rows as it needs, and keeps a margin
# round the plot. `width` is in inches and defaults to the figure settings
# in force, then 6.5. Anything that is not a ggplot is returned unchanged.
sframe_fit_plot <- function(p, width = NULL) {
  # Forced first, so a chart that fails to build fails here once and is not
  # built again by the handler below.
  force(p)
  tryCatch(.sframe_fit_plot(p, width), error = function(e) p)
}

.sframe_fit_plot <- function(p, width = NULL) {
  if (!inherits(p, "ggplot") || !requireNamespace("ggplot2", quietly = TRUE)) return(p)
  width <- width %||% .sframe_figure_env$settings$width %||% 6.5
  usable <- max(2, width - 0.5)
  chars_for <- function(pt, bold = FALSE) {
    floor(usable * 72 / (pt * if (bold) 0.62 else 0.55))
  }
  labs <- ggplot2::get_labs(p)
  size <- c(title = 14, subtitle = 12, caption = 9, x = 12, y = 12)
  new <- list()
  for (nm in intersect(names(size), names(labs))) {
    v <- labs[[nm]]
    if (is.character(v) && length(v) == 1L && !is.na(v)) {
      new[[nm]] <- sframe_wrap_text(v, chars_for(size[[nm]], nm == "title"))
    }
  }
  b <- tryCatch(ggplot2::ggplot_build(p), error = function(e) NULL)
  axis_wrap <- function(v) sframe_wrap_text(v, 18)
  legend_wrap <- function(v) sframe_wrap_text(v, 30)
  legend_hidden <- identical(p$theme$legend.position, "none")
  legend_shown <- FALSE
  if (!is.null(b)) {
    for (ax in c("x", "y")) {
      sc <- b$layout[[paste0("panel_scales_", ax)]][[1]]
      if (!is.null(sc) && isTRUE(sc$is_discrete()) &&
          is.null(p$scales$get_scales(ax))) {
        p <- p + if (ax == "x") ggplot2::scale_x_discrete(labels = axis_wrap)
                 else ggplot2::scale_y_discrete(labels = function(v) sframe_wrap_text(v, 30))
      }
    }
    for (aes in c("fill", "colour")) {
      sc <- b$plot$scales$get_scales(aes)
      if (is.null(sc) || !isTRUE(sc$is_discrete())) next
      lim <- as.character(sc$get_limits())
      # Rows the keys need: each key takes its label and about 4 characters
      # A legend the chart hides stays hidden.
      if (legend_hidden || sframe_guide_hidden(p, aes)) next
      wrapped <- legend_wrap(lim)
      per_key <- max(nchar(unlist(strsplit(wrapped, "\n", fixed = TRUE)))) + 4
      per_row <- max(1L, floor(chars_for(10) / per_key))
      guide <- ggplot2::guide_legend(nrow = max(1L, ceiling(length(lim) / per_row)))
      p <- p + do.call(ggplot2::guides, stats::setNames(list(guide), aes))
      legend_shown <- TRUE
      own <- p$scales$get_scales(aes)
      if (!is.null(own)) {
        # A copy, since a scale is shared with the plot the caller holds.
        if (inherits(own$labels, "waiver")) {
          own <- own$clone()
          own$labels <- legend_wrap
          p <- suppressMessages(p + own)
        }
      } else {
        p <- p + if (aes == "fill") ggplot2::scale_fill_discrete(labels = legend_wrap)
                 else ggplot2::scale_colour_discrete(labels = legend_wrap)
      }
    }
  }
  p <- p + do.call(ggplot2::labs, new)
  p <- p + ggplot2::theme(plot.margin = ggplot2::margin(8, 12, 8, 8))
  if (legend_shown) {
    p <- p + ggplot2::theme(legend.position = "bottom", legend.box = "vertical")
  }
  p
}

# TRUE where the plot turns off the legend for `aes` with guides(aes = "none").
sframe_guide_hidden <- function(p, aes) {
  g <- tryCatch(p$guides$guides[[aes]], error = function(e) NULL)
  identical(g, "none") || inherits(g, "GuideNone")
}
