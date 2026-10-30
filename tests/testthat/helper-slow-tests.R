# tests/testthat/helper-slow-tests.R
#
# The tests that render through Quarto or drive Chrome form the slow tier,
# with the source install they need (setup-build-under-test.R). In a source
# tree they run only when SURVEYFRAME_SLOW_TESTS is "true". The routine check
# while fixing is the fast tier, everything else, and it renders every report
# with the built-in engine in this process, from the source under test. The
# closing run of a session sets the variable, so every test runs and the
# build guards pass.
#
# Under R CMD check there is no source tree and nothing changes: NOT_CRAN and
# skip_on_cran() decide what runs, as before.

sframe_slow_tests <- function() {
  identical(tolower(Sys.getenv("SURVEYFRAME_SLOW_TESTS")), "true")
}

sframe_fast_tier <- function() {
  !sframe_slow_tests() && nzchar(sframe_build_source())
}

skip_if_not_slow <- function() {
  testthat::skip_if(
    sframe_fast_tier(),
    "a Quarto or browser test: set SURVEYFRAME_SLOW_TESTS=true to run it"
  )
}
