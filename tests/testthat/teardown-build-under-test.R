# tests/testthat/teardown-build-under-test.R
#
# Puts back the R_LIBS that setup-build-under-test.R replaced. testthat
# empties teardown_env() through withr::deferred_run(), and the tests do not
# use withr, so the restore sits in a teardown file, which testthat sources
# once after the last test file of the run.

if ("sframe.test_r_libs" %in% names(options())) {
  local({
    old <- getOption("sframe.test_r_libs")
    if (is.na(old)) Sys.unsetenv("R_LIBS") else Sys.setenv(R_LIBS = old)
    options(sframe.test_r_libs = NULL)
  })
}
