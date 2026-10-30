# tests/testthat/test-report-builtin-references.R
#
# D8 / CX-10. Without Quarto the built-in HTML engine was never given the
# instrument's references, so [@key] citations printed raw and no References
# list appeared.

refs_instrument <- function() {
  ins <- sframe_demo("two_group")$instrument
  add_references(
    ins,
    sf_reference("cronbach_1951", "Coefficient alpha and the internal structure of tests",
                 author = "Cronbach, L. J.", year = 1951, container = "Psychometrika",
                 volume = "16", issue = "3", pages = "297-334", doi = "10.1007/BF02310555"),
    sf_reference("field_2018", "Discovering statistics using IBM SPSS statistics",
                 author = "Field, A.", year = 2018, type = "book", edition = "5",
                 publisher = "SAGE")
  )
}

built_in <- function(ins, ..., interpretations = list()) {
  path <- tempfile(fileext = ".html")
  surveyframe:::.render_report_html(ins, output_path = path, include_analysis = FALSE, interpretations = interpretations, ...)
  paste(readLines(path, warn = FALSE), collapse = "\n")
}

test_that("D8: citations resolve to (Author, Year) in text", {
  refs <- surveyframe:::sframe_reference_index(refs_instrument())
  f <- surveyframe:::sframe_resolve_citations
  expect_equal(f("See [@cronbach_1951].", refs), "See (Cronbach, 1951).")
  expect_equal(f("Both [@cronbach_1951; @field_2018].", refs),
               "Both (Cronbach, 1951; Field, 2018).")
  expect_match(f("x [@nope_1999] y", refs), "nope_1999", fixed = TRUE)
})

test_that("D8: the built-in report lists instrument and extra references in APA 7", {
  extra <- list(sf_reference("web_2021", "A web page", author = "{World Health Organization}",
                             year = 2021, type = "webpage", url = "https://example.org/x"))
  html <- built_in(refs_instrument(), references = extra)
  expect_match(html, "<h2>References</h2>", fixed = TRUE)
  expect_match(html, "Cronbach, L. J. (1951). Coefficient alpha", fixed = TRUE)
  expect_match(html, "<em>Psychometrika</em>, <em>16</em>(3), 297&ndash;334.", fixed = TRUE)
  expect_match(html, "https://doi.org/10.1007/BF02310555", fixed = TRUE)
  expect_match(html, "<em>Discovering statistics using IBM SPSS statistics</em> (5th ed.). SAGE.", fixed = TRUE)
  expect_match(html, "World Health Organization. (2021). <em>A web page</em>. https://example.org/x", fixed = TRUE)
  expect_match(html, "class=\"csl-entry\"", fixed = TRUE)
  expect_true(regexpr("Cronbach, L. J.", html, fixed = TRUE) <
                regexpr("Field, A.", html, fixed = TRUE))
})

test_that("D8: citations in printed text resolve and none print raw", {
  ins <- refs_instrument()
  ins$items[[1]]$label <- paste(ins$items[[1]]$label, "[@cronbach_1951]")
  html <- built_in(ins)
  expect_no_match(html, "[@", fixed = TRUE)
  expect_match(html, "(Cronbach, 1951)", fixed = TRUE)
})

test_that("D8: interpretations with citations are resolved when the plan prints them", {
  ins <- refs_instrument()
  txt <- surveyframe:::sframe_resolve_citations(
    "Reliable [@cronbach_1951, p. 300].", surveyframe:::sframe_reference_index(ins))
  expect_equal(txt, "Reliable (Cronbach, 1951, p. 300).")
})

test_that("D8: the common CSL types format, and an unformattable entry shows a note", {
  f <- surveyframe:::sframe_format_reference_html
  chap <- sf_reference("c1", "A chapter", author = c("Lee, K.", "Roe, J."), year = 2019,
                       type = "chapter", container = "The big book", editor = "Poe, E.",
                       pages = "10-20", publisher = "Press")
  expect_match(f(chap), "Lee, K., &amp; Roe, J. (2019). A chapter. In E. Poe (Ed.), <em>The big book</em> (pp. 10&ndash;20). Press.", fixed = TRUE)
  rep <- sf_reference("r1", "A report", author = "{WHO}", year = 2020, type = "report", publisher = "Geneva Press")
  expect_match(f(rep), "WHO. (2020). <em>A report</em>. Geneva Press.", fixed = TRUE)
  sw <- sf_reference("s1", "pkg", author = "Doe, J.", year = 2024, type = "software",
                     version = "1.2", url = "https://x.org")
  expect_match(f(sw), "<em>pkg</em> (Version 1.2) [Computer software]. https://x.org", fixed = TRUE)
  odd <- sf_reference("t1", "A thesis", author = "Doe, J.", year = 2024, type = "thesis")
  html <- built_in(add_references(sframe_demo("two_group")$instrument, odd))
  expect_match(html, "t1", fixed = TRUE)
  expect_match(html, "could not be formatted", fixed = TRUE)
})

test_that("D8: render_report forwards references to the built-in engine", {
  withr_free <- options(surveyframe.use_quarto = FALSE)
  on.exit(options(withr_free), add = TRUE)
  out <- tempfile(fileext = ".html")
  suppressMessages(render_report(
    sframe_demo("two_group")$instrument, output_file = out, include_analysis = FALSE,
    references = list(sf_reference("zed_2020", "Zed's work", author = "Zed, A.", year = 2020))))
  html <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_match(html, "Zed, A. (2020).", fixed = TRUE)
})

test_that("a bracket with no known key stays as written and names are escaped", {
  refs <- sframe_reference_index(extra = list(sf_reference("sm", "T", type = "book",
    author = c("Smith, A.", "Jones, B."), year = 2020)))
  expect_identical(sframe_resolve_citations("[contact a@b.org]", refs), "[contact a@b.org]")
  expect_identical(sframe_resolve_citations("see [@sm]", refs), "see (Smith &amp; Jones, 2020)")
})
