# tests/testthat/test-render-empty-object.R
#
# Ethos request 3 (2026-10-01), second half. An empty render was written as
# [], which a host reading the JSON took for a list. It is now {}. Files and
# amendment logs written with [] must keep working: a file verifies as it was
# written, and an amendment recorded against the [] form still matches.

test_that("3: an empty render is written as {}", {
  ins <- sf_instrument("Plain", components = list(sf_item("q1", "Q", type = "text")))
  path <- tempfile(fileext = ".sframe")
  write_sframe(ins, path)
  txt <- paste(readLines(path), collapse = "\n")
  expect_match(txt, "\"render\": {}", fixed = TRUE)
  expect_s3_class(read_sframe(path), "sframe")
})

test_that("3: a file whose log was recorded with render as [] takes a further amendment", {
  ins <- sf_instrument("Legacy", components = list(sf_item("q1", "Q", type = "text")))
  revised <- ins
  revised$meta$description <- "First revision"
  revised <- amend_sframe(ins, revised, "other", "First", tier = "pipeline")
  path <- tempfile(fileext = ".sframe")
  write_sframe(revised, path)

  # Rewrite the file as a pre-0.4.3 writer would have: render as [], and the
  # amendment's hashes taken over that form, with the file hash recomputed.
  parsed <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  parsed$render <- list()
  legacy <- function(x) surveyframe:::sframe_content_hash(x, empty_render_array = TRUE)
  parsed$amendments[[1]]$previous_hash <- legacy(ins)
  parsed$amendments[[1]]$new_hash <- legacy(revised)
  parsed$hash$value <- ""
  parsed$hash$value <- surveyframe:::sframe_hash_payload(parsed)
  writeLines(jsonlite::toJSON(parsed, auto_unbox = TRUE, null = "null", digits = NA,
                              pretty = TRUE), path)
  expect_match(paste(readLines(path), collapse = ""), "\"render\": []", fixed = TRUE)

  old <- read_sframe(path)
  expect_no_error(write_sframe(old, tempfile(fileext = ".sframe")))
  again <- old
  again$meta$description <- "Second revision"
  again <- amend_sframe(old, again, "other", "Second", tier = "pipeline")
  expect_identical(again$amendments[[2]]$previous_hash, again$amendments[[1]]$new_hash)
  expect_no_error(write_sframe(again, tempfile(fileext = ".sframe")))
})
