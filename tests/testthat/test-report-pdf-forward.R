# tests/testthat/test-report-pdf-forward.R
#
# CX-04. The PDF path of render_report() builds an HTML report and prints it.
# That inner render dropped title, authors, references, csl and the figure
# settings, so a PDF differed from the HTML report built from the same call.
# The inner render is mocked so no Chrome is needed.

test_that("CX-04: the PDF path forwards title, authors, references, csl and figures", {
  skip_if_not_installed("pagedown")
  ins <- sframe_demo("two_group")$instrument
  orig <- render_report
  seen <- NULL
  fake <- function(instrument, ..., format = "html") {
    if (identical(format, "pdf")) return(orig(instrument, ..., format = format))
    seen <<- list(...)
    writeLines("<html></html>", seen$output_file)
    invisible(seen$output_file)
  }
  testthat::local_mocked_bindings(render_report = fake)
  testthat::local_mocked_bindings(
    chrome_print = function(input, output, ...) {
      writeLines("pdf", output)
      output
    },
    .package = "pagedown"
  )
  ref <- sf_reference("zed_2020", "A title", author = "Zed, A.", year = 2020)
  csl_file <- tempfile(fileext = ".csl")
  writeLines("<style/>", csl_file)
  figs <- list(width = 5, height = 3, dpi = 150, format = "png")
  out <- tempfile(fileext = ".pdf")
  suppressMessages(render_report(
    ins, output_file = out, format = "pdf", include_analysis = FALSE,
    title = "Chosen title", authors = c("Rahman, A.", "Lee, K."),
    references = list(ref), csl = csl_file, figures = figs
  ))
  expect_equal(seen$title, "Chosen title")
  expect_equal(seen$authors, c("Rahman, A.", "Lee, K."))
  expect_equal(seen$references[[1]]$id, "zed_2020")
  expect_equal(seen$csl, csl_file)
  expect_equal(seen$figures$width, 5)
  expect_equal(seen$figures$dpi, 150)
})
