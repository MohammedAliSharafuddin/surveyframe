# R/show.R
# One rule for showing a file to the user. RStudio, Positron and VS Code set
# getOption("viewer"), and an HTML file goes there. Base R sets none, and the
# file opens in the web browser. A script, a knitr or Quarto render, or the
# caller's option set to FALSE opens nothing. No rstudioapi is needed, so the
# Addins stay its only user.

#' Show a file surveyframe wrote
#'
#' Opens a file in the viewer of RStudio, Positron or VS Code when it is an
#' HTML page, and otherwise in the web browser or the program the system
#' opens it with. It opens files only in an interactive session. In a script,
#' a knitr or Quarto render or under `R CMD check` it opens nothing and
#' prints the file's path on a line of its own, so a file written to the temporary
#' folder is never left unseen. The examples that write a file end with it.
#'
#' @param path Character. The file to show.
#' @param quiet Logical. When `TRUE`, nothing is printed when the file is not
#'   opened.
#' @param option Character or `NULL`. The name of an option that, set to
#'   `FALSE`, keeps the file closed, for a function with its own switch.
#' @return `TRUE` when the file was opened, `FALSE` otherwise, invisibly.
#' @export
#' @examples
#' path <- file.path(tempdir(), "hello.html")
#' writeLines("<h1>Hello</h1>", path)
#' sframe_show(path)
#' @family Report functions
sframe_show <- function(path, quiet = FALSE, option = NULL) {
  if (!is.character(path) || length(path) != 1L || is.na(path)) {
    rlang::abort("`path` must be 1 file path.", class = "sframe_error")
  }
  if (!file.exists(path)) return(invisible(FALSE))
  shown <- sframe_is_interactive() && !isTRUE(getOption("knitr.in.progress")) &&
    (is.null(option) || !isFALSE(getOption(option)))
  if (!shown) {
    if (!isTRUE(quiet)) cat(sframe_path_line("Written", path), "\n", sep = "")
    return(invisible(FALSE))
  }
  path <- normalizePath(path)

  viewer <- getOption("viewer")
  if (is.function(viewer) && grepl("\\.html?$", path, ignore.case = TRUE)) {
    # RStudio's Viewer displays files inside the session's temporary
    # directory alone, so a file kept elsewhere is shown from a copy.
    if (!startsWith(path, normalizePath(tempdir()))) {
      dir <- tempfile("surveyframe-view-")
      dir.create(dir)
      copy <- file.path(dir, basename(path))
      file.copy(path, copy, overwrite = TRUE)
      path <- copy
    }
    viewer(path)
  } else {
    utils::browseURL(paste0("file://", path))
  }
  invisible(TRUE)
}

# A path as a message shows it: absolute, with forward slashes on every
# system, so it can be copied into R or a file manager as printed. A label
# such as "<text>", for an instrument read from a string, stays as it is.
sframe_show_path <- function(path) {
  if (!file.exists(path)) return(path)
  normalizePath(path, winslash = "/")
}

# A label and a path on 2 lines. The path stands on its own line, because a
# Windows temporary folder alone runs to about 60 characters and a path in
# the middle of a sentence ran past the console's edge.
sframe_path_line <- function(label, path) {
  paste0(label, ":\n", sframe_show_path(path))
}
