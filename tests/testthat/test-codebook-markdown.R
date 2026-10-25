# tests/testthat/test-codebook-markdown.R
#
# Ethos request 9 (2026-10-03). codebook_report(format = "md") returned an
# object whose printed form was a text table, so a host asking for Markdown
# captured the console output and offered it as .txt.

test_that("9: format = 'md' carries the codebook as Markdown, and print writes it", {
  ins <- sframe_demo("two_group")$instrument
  cb <- codebook_report(ins, format = "md")
  expect_type(cb$markdown, "character")
  expect_length(cb$markdown, 1L)
  md <- strsplit(cb$markdown, "\n", fixed = TRUE)[[1]]
  expect_identical(md[1], paste0("# Codebook: ", ins$meta$title))
  expect_true(all(c("## Items", "## Choice sets", "## Scales", "## Analysis plan",
                    "## Models") %in% md))
  expect_true(any(grepl("^\\| id \\| label \\| type", md)))
  expect_identical(capture.output(print(cb))[1], md[1])
  # The accessors still work on the object.
  expect_identical(nrow(sf_items(cb)), length(ins$items))
})

test_that("9: a pipe inside a label is escaped, so the table keeps its columns", {
  ins <- sf_instrument("Pipes", components = list(
    sf_item("q1", "Either | or", type = "text")))
  md <- codebook_report(ins, format = "md")$markdown
  row <- grep("^\\| q1 ", strsplit(md, "\n", fixed = TRUE)[[1]], value = TRUE)
  expect_match(row, "Either \\| or", fixed = TRUE)
  skip_if(!nzchar(Sys.which("pandoc")), "pandoc not installed")
  f <- tempfile(fileext = ".md"); writeLines(md, f)
  html <- system2("pandoc", c("-f", "markdown", "-t", "html", shQuote(f)), stdout = TRUE)
  expect_true(any(grepl("<td>Either \\| or</td>|<td>Either | or</td>", html)))
})

test_that("9: the html format keeps its compact summary", {
  cb <- codebook_report(sframe_demo("two_group")$instrument)
  expect_null(cb$markdown)
  expect_match(capture.output(print(cb))[1], "^Codebook: ")
})
