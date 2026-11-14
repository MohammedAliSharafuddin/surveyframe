# R/next_stage.R
# Each stage of a study names the one after it (Session 10, first contact
# section 5 item 5): what was done, then the call that comes next. Only in an
# interactive session and for a call made at the top level, so a script, a
# render, a test, a server running surveyframe and the package's own calls
# (render_report() running the plan, sframe_demo() reading responses) stay as
# quiet as before. Silence them with suppressMessages(), or catch the class
# sframe_next_stage.
sframe_next_stage <- function(done, next_call, caller = parent.frame(2)) {
  if (!sframe_is_interactive() || isTRUE(getOption("knitr.in.progress")) ||
      !identical(caller, globalenv())) {
    return(invisible(NULL))
  }
  rlang::inform(paste0(done, " Next: ", next_call),
                class = "sframe_next_stage")
}

sframe_stage_title <- function(instrument) {
  title <- instrument$meta$title %||% ""
  if (nzchar(title)) paste0("'", title, "'") else "the instrument"
}
