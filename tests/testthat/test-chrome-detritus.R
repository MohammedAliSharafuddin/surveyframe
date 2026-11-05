# tests/testthat/test-chrome-detritus.R
# pagedown::chrome_print() starts Chrome, which leaves its scratch folders
# (com.google.Chrome.*, scoped_dir*) in TMPDIR, which R CMD check reports as
# "detritus in the temp directory" and which fills a user's temp folder.
# render_report(format = "pdf") runs Chrome with a TMPDIR of its own and
# removes it. These tests used to look in tempdir(), where Chrome never
# writes, so they passed either way (Session CI).

test_that("Chrome's own TMPDIR is set for the call, then removed and restored", {
  vars <- c("TMPDIR", "TMP", "TEMP")
  before <- Sys.getenv(vars, unset = NA)
  seen <- surveyframe:::sframe_with_chrome_tmp({
    dir <- Sys.getenv("TMPDIR")
    dir.create(file.path(dir, "com.google.Chrome.testXY"))
    dir.create(file.path(dir, "scoped_dirTESTXY"))
    list(dir = dir, tmp = Sys.getenv("TMP"), temp = Sys.getenv("TEMP"))
  })
  expect_true(nzchar(seen$dir))
  expect_identical(seen$tmp, seen$dir)
  expect_identical(seen$temp, seen$dir)
  expect_false(identical(seen$dir, unname(before[["TMPDIR"]])))
  expect_false(dir.exists(seen$dir))
  expect_identical(Sys.getenv(vars, unset = NA), before)
  # Short enough for Chrome's socket path (104 bytes on macOS).
  expect_lt(nchar(seen$dir) + 50L, 104L)
})

test_that("Chrome's TMPDIR goes and TMPDIR is restored when the call fails", {
  before <- Sys.getenv("TMPDIR", unset = NA)
  dir <- NULL
  expect_error(surveyframe:::sframe_with_chrome_tmp({
    dir <- Sys.getenv("TMPDIR")
    stop("Chrome failed")
  }), "Chrome failed")
  expect_false(dir.exists(dir))
  expect_identical(Sys.getenv("TMPDIR", unset = NA), before)
})

# End-to-end: Chrome printed with a TMPDIR of its own, which is gone after.
# The shared TMPDIR is not listed before and after, since parallel browser
# tests start their own Chrome there. The 2 tests above guard the wrapper.
test_that("render_report(format = 'pdf') leaves no Chrome detritus behind", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if_not_installed("pagedown")
  chrome <- tryCatch(pagedown::find_chrome(), error = function(e) NULL)
  chrome_command <- if (length(chrome) == 1L && !is.na(chrome) && nzchar(chrome)) {
    if (file.exists(chrome)) chrome else unname(Sys.which(chrome))
  } else {
    ""
  }
  skip_if(!nzchar(chrome_command), "No Chrome available for chrome_print()")

  instr <- sframe_instrument("Detritus check", components = list(
    sframe_choice_set("ag5", 1:5, c("SD", "D", "N", "A", "SA")),
    sframe_item("q1", "Item 1", type = "likert", choice_set = "ag5")
  ))

  before <- list.files(tempdir(), all.files = TRUE, no.. = TRUE)
  out <- tempfile(fileext = ".pdf")
  on.exit(unlink(out, force = TRUE), add = TRUE)
  old <- options(surveyframe.use_quarto = FALSE)
  on.exit(options(old), add = TRUE)

  env <- surveyframe:::.sframe_figure_env
  env$chrome_tmp <- NULL
  render_report(instr, output_file = out, format = "pdf")
  expect_true(is.character(env$chrome_tmp) && nzchar(env$chrome_tmp))
  expect_false(dir.exists(env$chrome_tmp))

  leftover <- grep("^(com\\.google\\.Chrome\\.|scoped_dir)",
                   setdiff(list.files(tempdir(), all.files = TRUE, no.. = TRUE),
                           before),
                   value = TRUE)
  expect_identical(leftover, character(0))
})
