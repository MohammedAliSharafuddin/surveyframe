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
    {
      sframe_chrome_start()
      chromote::ChromoteSession$new(...)
    },
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

# Chrome writes com.google.Chrome.* and scoped_dir* folders into TMPDIR and
# leaves them when its process is killed, which R CMD check reports as
# detritus in the temp directory (Ubuntu runners, CI 41973734890). The
# shared Chrome starts here with TMPDIR in a folder of this test process's
# own. Chrome's SingletonSocket path must stay under the Unix socket limit
# (104 bytes on macOS), which the check's temp folder there exceeds, so a
# long temp folder gives way to a short one under /tmp. At exit Chrome is
# closed first and the folder removed. TMPDIR is restored at once, so later
# child processes are unaffected. Windows Chrome does not read TMPDIR.
sframe_chrome_start <- function() {
  if (chromote::has_default_chromote_object() || .Platform$OS.type == "windows") {
    return(invisible())
  }
  base <- if (nchar(tempdir()) + 60L < 100L || !dir.exists("/tmp")) tempdir() else "/tmp"
  chrome_tmp <- tempfile("sfc", tmpdir = base)
  dir.create(chrome_tmp, showWarnings = FALSE)
  old <- Sys.getenv("TMPDIR", unset = NA)
  Sys.setenv(TMPDIR = chrome_tmp)
  on.exit(if (is.na(old)) Sys.unsetenv("TMPDIR") else Sys.setenv(TMPDIR = old), add = TRUE)
  chromote::set_default_chromote_object(chromote::Chromote$new())
  sframe_chrome_keep$dirs <- c(sframe_chrome_keep$dirs, chrome_tmp)
  invisible()
}

# Lives as long as the test process, so its finalizer runs only at exit. A
# finalizer on a function's own environment ran at the next garbage
# collection and closed Chrome mid-run (CI run 41984181153, macOS).
# Held in an option, so sourcing the helpers again reuses it rather than
# leaving the first one to be collected.
sframe_chrome_keep <- getOption("surveyframe.test_chrome_keep")
if (is.null(sframe_chrome_keep)) {
  sframe_chrome_keep <- new.env()
  reg.finalizer(sframe_chrome_keep, function(e) {
    if (chromote::has_default_chromote_object()) {
      try(chromote::default_chromote_object()$close(), silent = TRUE)
    }
    # Chrome's SingletonSocket stops unlink(recursive = TRUE), so files go first.
    for (d in e$dirs) try(surveyframe:::sframe_remove_dir(d), silent = TRUE)
  }, onexit = TRUE)
  options(surveyframe.test_chrome_keep = sframe_chrome_keep)
}
