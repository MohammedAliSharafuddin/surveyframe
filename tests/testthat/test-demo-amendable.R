# tests/testthat/test-demo-amendable.R
#
# Every shipped demo can take one further amendment and be written.
#
# Ethos request 2 (2026-10-01): sframe_demo("instrument_revision") recorded
# an amendment whose new_hash its content did not hash to, because the file
# was built with code from before the content hash settled. amend_sframe()
# on it then failed with "The amendment log is out of sequence at entry 2",
# and so did write_sframe() after any change. Ethos opens every demo as a
# starting point and amends it, so a demo that refuses an amendment is a
# demo a researcher cannot begin from.

for (demo in sframe_demos()$name) {
  test_that(paste0("demo '", demo, "': its amendment log matches its content"), {
    ins <- sframe_demo(demo)$instrument
    log <- ins$amendments
    if (length(log) == 0) {
      expect_length(log, 0L)
    } else {
      expect_identical(log[[length(log)]]$new_hash, sframe_content_hash(ins))
    }
  })

  test_that(paste0("demo '", demo, "': takes one further amendment and a write"), {
    ins <- sframe_demo(demo)$instrument
    revised <- ins
    revised$meta$description <- "A further revision, made by a test."
    revised <- amend_sframe(ins, revised, "other", "A further revision",
                            tier = "pipeline")
    path <- tempfile(fileext = ".sframe")
    expect_no_error(write_sframe(revised, path))
    back <- read_sframe(path)
    expect_length(back$amendments, length(ins$amendments) + 1L)
  })
}
