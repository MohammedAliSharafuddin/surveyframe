# R/rstudio_addins.R
# RStudio Addins menu bindings. Thin launchers plus one text insert, and
# nothing else.
#
# Two rules hold this file apart from the rest of the package. No other file
# in R/ may call an rstudioapi:: function, so surveyframe behaves identically
# outside RStudio. And every binding here fails soft with a message() and an
# invisible NULL rather than an error, because these are interactive
# conveniences rather than part of the API contract: an add-in that throws
# inside the IDE is worse than one that explains itself and stops.
#
# rstudioapi stays in Suggests. Nothing here is a hard dependency.

sframe_addin_ready <- function() {
  if (!requireNamespace("rstudioapi", quietly = TRUE)) {
    message(
      "rstudioapi is required for the surveyframe add-ins. ",
      "Install it with: install.packages(\"rstudioapi\")"
    )
    return(FALSE)
  }
  TRUE
}

#' @keywords internal
#' @noRd
addin_launch_builder <- function() {
  if (!sframe_addin_ready()) return(invisible(NULL))
  launch_builder()
}

#' @keywords internal
#' @noRd
addin_launch_studio <- function() {
  if (!sframe_addin_ready()) return(invisible(NULL))
  launch_studio()
}

# Asks the researcher for a .sframe file, and returns NULL where the dialog is
# cancelled or unavailable. Its own function so a test can drive both answers.
sframe_addin_choose_sframe <- function(
    caption = "Choose an instrument (.sframe)") {
  if (!requireNamespace("rstudioapi", quietly = TRUE) ||
      !rstudioapi::isAvailable()) {
    return(NULL)
  }
  path <- tryCatch(
    rstudioapi::selectFile(caption = caption, filter = "sframe files (*.sframe)",
                           existing = TRUE),
    error = function(e) NULL)
  if (is.null(path) || !length(path) || !nzchar(path)) return(NULL)
  path
}

#' @keywords internal
#' @noRd
addin_launch_dashboard <- function() {
  if (!sframe_addin_ready()) return(invisible(NULL))
  # launch_dashboard() refuses a missing instrument, so calling it with no
  # arguments turned an advertised menu entry into an error message. The addin
  # asks which instrument to open, and does nothing where that is cancelled.
  path <- sframe_addin_choose_sframe()
  if (is.null(path)) return(invisible(NULL))
  # Read first, so a file that will not load reports itself here rather than
  # inside the launcher.
  instrument <- read_sframe(path)
  launch_dashboard(instrument = instrument)
}

# The skeleton is checked against the shipped constructors by
# tests/testthat/test-rstudio-addins.R, which parses it, evaluates it, and
# validates the resulting instrument. A skeleton that does not build a valid
# instrument is worse than no skeleton, and the implementation guide's
# original version was written against an API that no longer exists: it
# passed id = to sf_instrument(), named the component list items =, and
# handed sf_item() an inline choices = argument. Choice sets are declared as
# their own component and referenced by id.
#
# 3 items per scale, not 2 (fixed 2026-08-15). Alpha on exactly 2 items
# reduces to a single pairwise correlation rather than measuring internal
# consistency, and a 2-indicator factor is not identifiable if this
# instrument is later carried into a measurement model. The skeleton is the
# first thing a new user copies, so it should not model the statistical
# floor as if it were normal practice.
sframe_addin_skeleton <- function() {
  paste(
    'instrument <- sf_instrument(',
    '  title       = "My study",',
    '  version     = "1.0.0",',
    '  description = "One line on what this instrument measures.",',
    '  components  = list(',
    '    sf_choices(',
    '      "agree5",',
    '      values = 1:5,',
    '      labels = c("Strongly disagree", "Disagree", "Neutral",',
    '                 "Agree", "Strongly agree")',
    '    ),',
    '    sf_item("q1", "First item text.", type = "likert",',
    '            choice_set = "agree5", scale_id = "construct_1"),',
    '    sf_item("q2", "Second item text.", type = "likert",',
    '            choice_set = "agree5", scale_id = "construct_1"),',
    '    sf_item("q3", "Third item text.", type = "likert",',
    '            choice_set = "agree5", scale_id = "construct_1"),',
    '    sf_scale("construct_1", "Construct one", items = c("q1", "q2", "q3"))',
    '  ),',
    '  analysis_plan = list(',
    '    list(',
    '      id                = "RQ1",',
    '      research_question = "How reliable is construct one?",',
    '      family            = "measurement",',
    '      method            = "reliability_alpha",',
    '      roles             = list(items = c("q1", "q2", "q3"))',
    '    )',
    '  )',
    ')',
    '',
    'validate_sframe(instrument)',
    sep = "\n"
  )
}

#' @keywords internal
#' @noRd
addin_insert_skeleton <- function() {
  if (!sframe_addin_ready()) return(invisible(NULL))
  rstudioapi::insertText(sframe_addin_skeleton())
}
