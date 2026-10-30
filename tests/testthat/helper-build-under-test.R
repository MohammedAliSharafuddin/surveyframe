# tests/testthat/helper-build-under-test.R
#
# Quarto renders a report in its own R process, and a browser test starts
# Studio or a survey in a callr process. Each loads surveyframe with
# library(), from whatever library comes first. Under
# devtools::test() that was the copy installed earlier (6b95ede on
# 2026-10-30), not the source under test, so a Quarto test ran old analysis
# code and passed wherever its assertions did not need a new function.
#
# sframe_build_under_test() installs the source tree once per R session into
# a temporary library, keyed on a fingerprint of the files that install, so
# an edit to the source makes a new build. render_report() below shadows the
# package's own in the test environment, and puts that library first on
# R_LIBS for the length of the call, restored with on.exit(). Every test that
# calls render_report() goes through it, Quarto or not. A browser test passes
# sframe_build_libpath() to callr::r_bg(libpath =) and calls
# library(surveyframe), never pkgload::load_all(): a browser test that loaded
# the source passed while the installed Studio could not start (7f846f7).
#
# Under R CMD check the tests run beside the installed package under test,
# so no build is needed. Where a source tree is at hand but cannot be built,
# a call that would render with Quarto is skipped and says why.

sframe_build_parts <- c("DESCRIPTION", "NAMESPACE", "R", "inst", "man", "data")

sframe_build_source <- function() {
  src <- tryCatch(normalizePath(test_path("..", ".."), mustWork = TRUE),
                  error = function(e) "")
  if (nzchar(src) && file.exists(file.path(src, "DESCRIPTION")) &&
      dir.exists(file.path(src, "R"))) src else ""
}

# The commit the source tree is at, with "-dirty" when the files that
# install differ from it, or "" outside a git checkout.
sframe_build_commit <- function(src) {
  if (!nzchar(Sys.which("git"))) return("")
  git <- function(...) tryCatch(
    suppressWarnings(system2("git", c("-C", shQuote(src), ...),
                             stdout = TRUE, stderr = FALSE)),
    error = function(e) character(0))
  out <- git("rev-parse", "HEAD")
  if (length(out) != 1 || !grepl("^[0-9a-f]{40}$", out)) return("")
  changed <- git("status", "--porcelain", "--", sframe_build_parts)
  if (length(changed) > 0) paste0(out, "-dirty") else out
}

# The temporary library holding the source under test, NA under R CMD check
# (the installed package is the build under test), or a string starting
# "skip:" with the reason no build could be made.
sframe_build_under_test <- function() {
  src <- sframe_build_source()
  if (!nzchar(src)) return(NA_character_)
  parts <- file.path(src, sframe_build_parts)
  files <- list.files(parts[dir.exists(parts)], recursive = TRUE, full.names = TRUE)
  files <- c(files, parts[file.exists(parts) & !dir.exists(parts)])
  sums <- unname(tools::md5sum(sort(files)))
  key <- substr(rlang::hash(c(sums, sframe_build_commit(src))), 1, 12)
  lib <- file.path(tempdir(), paste0("sf-build-", key))
  if (file.exists(file.path(lib, "surveyframe", "DESCRIPTION"))) return(lib)

  copy <- file.path(tempdir(), paste0("sf-build-src-", key), "surveyframe")
  dir.create(copy, recursive = TRUE, showWarnings = FALSE)
  for (p in sframe_build_parts[file.exists(file.path(src, sframe_build_parts))]) {
    file.copy(file.path(src, p), copy, recursive = TRUE)
  }
  # RemoteSha is the field remotes and pak write on install, and the report
  # records it, so a test can see which build rendered it. A build with
  # uncommitted changes says so.
  commit <- sframe_build_commit(src)
  if (nzchar(commit)) {
    desc <- read.dcf(file.path(copy, "DESCRIPTION"))
    desc <- cbind(desc, RemoteSha = commit)
    write.dcf(desc, file.path(copy, "DESCRIPTION"))
  }
  dir.create(lib, showWarnings = FALSE)
  log <- tempfile("sf-build-", fileext = ".log")
  status <- system2(file.path(R.home("bin"), "R"),
                    c("CMD", "INSTALL", "--no-docs", "--no-multiarch",
                      "--no-test-load", paste0("--library=", shQuote(lib)),
                      shQuote(copy)),
                    stdout = log, stderr = log)
  if (!identical(status, 0L) ||
      !file.exists(file.path(lib, "surveyframe", "DESCRIPTION"))) {
    unlink(lib, recursive = TRUE)
    return(paste0("skip: the source under test could not be installed ",
                  "(see ", log, ")"))
  }
  lib
}

# The library path for a callr process that must load the build under test.
# Under R CMD check the installed package is that build.
sframe_build_libpath <- function() {
  lib <- sframe_build_under_test()
  if (is.na(lib)) return(.libPaths())
  if (startsWith(lib, "skip:")) testthat::skip(sub("^skip: ", "", lib))
  c(lib, .libPaths())
}

sframe_quarto_would_render <- function() {
  isTRUE(getOption("surveyframe.use_quarto", TRUE)) && nzchar(Sys.which("quarto"))
}

render_report <- function(...) {
  if (sframe_quarto_would_render()) {
    lib <- sframe_build_under_test()
    if (!is.na(lib) && startsWith(lib, "skip:")) {
      testthat::skip(sub("^skip: ", "", lib))
    }
    if (!is.na(lib)) {
      old <- Sys.getenv("R_LIBS", unset = NA)
      on.exit(if (is.na(old)) Sys.unsetenv("R_LIBS") else Sys.setenv(R_LIBS = old),
              add = TRUE)
      Sys.setenv(R_LIBS = paste(c(lib, if (!is.na(old) && nzchar(old)) old),
                                collapse = .Platform$path.sep))
    }
  }
  surveyframe::render_report(...)
}
