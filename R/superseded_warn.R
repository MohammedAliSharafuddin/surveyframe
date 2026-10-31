# R/superseded_warn.R
# The warning behind every superseded name (naming decision 3). In 0.4.3 old
# names work silently. options(surveyframe.warn_superseded = TRUE) turns on 1
# warning per old name per session, so a host can find every old call.

sframe_superseded <- function(old, new) {
  if (!isTRUE(getOption("surveyframe.warn_superseded", FALSE))) {
    return(invisible(NULL))
  }
  rlang::warn(
    paste0(
      "`", old, "` is superseded. Use `", new, "` instead. ",
      "The old name still works."
    ),
    class = "sframe_superseded_warning",
    .frequency = "once",
    .frequency_id = paste0("surveyframe_superseded_", old)
  )
  invisible(NULL)
}
