# tests/testthat/setup-build-under-test.R
#
# Quarto renders a report in its own R process, and so do paths that reach
# render_report() from inside the package (the Studio export). Each loads
# surveyframe with library(), from the first library on its path. Under
# devtools::test() that was the copy installed earlier, not the source under
# test. A render_report() shadow in a helper file was meant to fix that, but
# under devtools::test() the helpers sit after the package namespace in
# lookup, so a test's render_report() was the package's and the shadow never
# ran.
#
# So the build is made once here, when Quarto is installed and a source tree
# is at hand, and goes first on R_LIBS for the whole run. Every child process
# inherits it. teardown-build-under-test.R puts R_LIBS back at the end of the
# run. Under R CMD check the installed package is the build under test and
# nothing changes. The build serves only the slow tier
# (helper-slow-tests.R), so the fast tier skips it.

local({
  # The fast tier renders every report with the built-in engine, in this
  # process, from the source under test. Quarto would render with the
  # installed copy, since the build is not made.
  if (sframe_fast_tier()) {
    options(sframe.test_use_quarto = list(getOption("surveyframe.use_quarto")),
            surveyframe.use_quarto = FALSE)
    return(invisible())
  }
  if (!nzchar(Sys.which("quarto"))) return(invisible())
  lib <- sframe_build_under_test()
  if (is.na(lib)) return(invisible())
  if (startsWith(lib, "skip:")) {
    message("The Quarto tests render with the installed surveyframe: ",
            sub("^skip: ", "", lib))
    return(invisible())
  }
  old <- Sys.getenv("R_LIBS", unset = NA)
  options(sframe.test_r_libs = old)
  Sys.setenv(R_LIBS = paste(c(lib, if (!is.na(old) && nzchar(old)) old),
                            collapse = .Platform$path.sep))
})
