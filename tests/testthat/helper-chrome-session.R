# tests/testthat/helper-chrome-session.R
#
# Session T. Every browser test opens its tab through sframe_chrome_session().
# When Chrome cannot start, chromote's own error reached the test as a bare
# failure at the test_that() line (seen at test-builder-d12-browser.R:104),
# and the rest of the file failed the same way. This names the cause: Chrome
# did not open its debugging port within chromote.timeout, or the process
# exited first. The test still fails, so nothing that was checked is skipped.

sframe_chrome_session <- function(...) {
  tryCatch(
    chromote::ChromoteSession$new(...),
    error = function(e) {
      timeout <- getOption("chromote.timeout", 10)
      msg <- conditionMessage(e)
      cause <- if (inherits(e, "error_stop_port_search") ||
                   grepl("debugging port", msg, fixed = TRUE)) {
        paste0("Chrome did not open its debugging port within ", timeout,
               " s (option chromote.timeout).")
      } else if (grepl("Failed to start chrome", msg, fixed = TRUE)) {
        "Chrome exited before it opened its debugging port."
      } else {
        "Chrome could not open a tab."
      }
      stop(paste0(
        "The browser test could not start Chrome. ", cause,
        " Chrome may be missing, blocked, or slow under load. chromote said: ",
        msg), call. = FALSE)
    }
  )
}
