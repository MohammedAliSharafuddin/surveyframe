# R/show.R
# One rule for showing a file to the user. RStudio, Positron and VS Code set
# getOption("viewer"), and an HTML file goes there. Base R sets none, and the
# file opens in the web browser. A script, a knitr or Quarto render, or the
# caller's option set to FALSE opens nothing. No rstudioapi is needed, so the
# Addins stay its only user.

# Returns TRUE when the file was shown, FALSE otherwise, invisibly.
sframe_show <- function(path, option = NULL) {
  if (!sframe_is_interactive() || isTRUE(getOption("knitr.in.progress"))) {
    return(invisible(FALSE))
  }
  if (!is.null(option) && isFALSE(getOption(option))) return(invisible(FALSE))
  if (!file.exists(path)) return(invisible(FALSE))
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
