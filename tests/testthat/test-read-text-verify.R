# tests/testthat/test-read-text-verify.R
#
# Ethos request 4 (2026-10-01). read_sframe() read only a file path and always
# verified the hash. Ethos keeps instruments as JSON in PostgreSQL, wrote a
# temporary file to read one, and rebuilt a payload without a matching hash by
# hand, dropping models, branching, checks and render settings.

demo_json <- function() {
  path <- tempfile(fileext = ".sframe")
  write_sframe(sframe_demo("first_survey")$instrument, path, new_instrument = TRUE)
  paste(readLines(path), collapse = "\n")
}

test_that("4: a payload held in memory reads with no file, verified", {
  ins <- read_sframe(text = demo_json())
  expect_s3_class(ins, "sframe")
  expect_true(attr(ins, "sframe_verified"))
  expect_identical(sframe_content_hash(ins),
                   sframe_content_hash(sframe_demo("first_survey")$instrument))
  expect_error(read_sframe(path = "x.sframe", text = demo_json()), "not both")
})

test_that("4: an edited payload is refused by default", {
  edited <- sub("Event feedback", "Event feedback, edited", demo_json(), fixed = TRUE)
  expect_error(read_sframe(text = edited), "Integrity check failed",
               class = "sframe_import_error")
})

test_that("4: verify = FALSE reads it, warns, and marks it unverified", {
  edited <- sub("Event feedback", "Event feedback, edited", demo_json(), fixed = TRUE)
  expect_warning(ins <- read_sframe(text = edited, verify = FALSE),
                 class = "sframe_unverified_warning")
  expect_false(attr(ins, "sframe_verified"))
  expect_identical(ins$meta$title, "Event feedback, edited")
  # Every field survives, with no hand rebuild.
  expect_length(ins$analysis_plan, length(sframe_demo("first_survey")$instrument$analysis_plan))
  expect_match(capture.output(print(ins)), "unverified", all = FALSE)
})

test_that("4: a payload with no hash at all reads with verify = FALSE", {
  parsed <- jsonlite::fromJSON(demo_json(), simplifyVector = FALSE)
  parsed$hash <- NULL
  txt <- jsonlite::toJSON(parsed, auto_unbox = TRUE, null = "null", digits = NA)
  expect_error(read_sframe(text = txt), "hash", class = "sframe_import_error")
  expect_warning(ins <- read_sframe(text = txt, verify = FALSE),
                 class = "sframe_unverified_warning")
  expect_false(attr(ins, "sframe_verified"))
})

test_that("4: an unverified instrument is written only as a new instrument", {
  edited <- sub("Event feedback", "Event feedback, edited", demo_json(), fixed = TRUE)
  ins <- suppressWarnings(read_sframe(text = edited, verify = FALSE))
  path <- tempfile(fileext = ".sframe")
  expect_error(write_sframe(ins, path), "new_instrument = TRUE")
  expect_no_error(write_sframe(ins, path, new_instrument = TRUE))
  expect_true(attr(read_sframe(path), "sframe_verified"))
})
