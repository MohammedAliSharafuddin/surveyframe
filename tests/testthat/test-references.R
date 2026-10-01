# tests/testthat/test-references.R
# References carried by an instrument (0.4.3): the record, BibTeX import, the
# file format and its hashes, validation, the built-in method references, and
# the report's single References section at the end.

demo_instrument <- function() {
  sf_instrument("References demo", components = list(
    sf_choices("agree5", 1:5, c("SD", "D", "N", "A", "SA")),
    sf_item("q1", "The event ran to time.", "likert", choice_set = "agree5", scale_id = "org"),
    sf_item("q2", "Staff were helpful.", "likert", choice_set = "agree5", scale_id = "org"),
    sf_scale("org", "Organisation", items = c("q1", "q2"))
  ))
}

test_that("sf_reference() builds a CSL-JSON record and refuses a bad key or title", {
  r <- sf_reference("likert_1932", "A technique for the measurement of attitudes",
                    author = c("Likert, R.", "{R Core Team}", "Ada Lovelace"), year = 1932,
                    container = "Archives of Psychology", volume = 22, pages = "1-55",
                    doi = "https://doi.org/10.1000/x1", cited_by = c("instrument", "scale:org"))
  expect_s3_class(r, "sf_reference")
  expect_equal(r$author[[1]], list(family = "Likert", given = "R."))
  expect_equal(r$author[[2]], list(literal = "R Core Team"))
  expect_equal(r$author[[3]], list(family = "Lovelace", given = "Ada"))
  expect_equal(r$issued$`date-parts`[[1]][[1]], 1932L)
  expect_equal(r$volume, "22")
  expect_equal(r$DOI, "10.1000/x1")
  expect_null(r$publisher)
  expect_error(sf_reference("bad key", "T"), class = "sframe_validation_error")
  expect_error(sf_reference("ok", "  "), class = "sframe_validation_error")
  expect_error(sf_reference("ok", "T", cited_by = "page:3"), class = "sframe_validation_error")
})

test_that("read_bibtex() reads common entries, accents, organisations and protected case", {
  bib <- '
  @comment{ignored}
  @article{cronbach_1951,
    author  = {Cronbach, Lee J. and M{\\"u}ller, K. and {Johnson and Johnson}},
    title   = {Coefficient alpha and the {I}nternal structure of tests},
    journal = {Psychometrika}, year = {1951}, volume = {16}, number = {3},
    pages   = {297--334}, doi = {https://doi.org/10.1007/BF02310555}
  }
  @book{field_2018, author = "Field, Andy", title = "Discovering statistics",
    publisher = {SAGE}, year = 2018, edition = {5}}
  @incollection{chap_1, author = {Doe, J.}, title = {A chapter}, booktitle = {A book},
    editor = {Roe, R.}, year = {2001}, pages = {1--10}, publisher = {Wiley}}
  @misc{site_1, title = {A page}, url = {https://example.org}, year = {2024}}
  @article{no_title, author = {A, B}, year = {2000}}
  '
  expect_warning(refs <- read_bibtex(text = bib), "no_title")
  expect_named(refs, c("cronbach_1951", "field_2018", "chap_1", "site_1"))
  cr <- refs$cronbach_1951
  expect_equal(cr$type, "article-journal")
  expect_equal(cr$title, "Coefficient alpha and the Internal structure of tests")
  expect_equal(cr$author[[2]]$family, "Müller")
  expect_equal(cr$author[[3]], list(literal = "Johnson and Johnson"))
  expect_equal(cr$page, "297-334")
  expect_equal(cr$DOI, "10.1007/BF02310555")
  expect_equal(refs$field_2018$type, "book")
  expect_equal(refs$field_2018$edition, "5")
  expect_equal(refs$chap_1$type, "chapter")
  expect_equal(refs$chap_1$`container-title`, "A book")
  expect_equal(refs$chap_1$editor[[1]]$family, "Roe")
  expect_equal(refs$site_1$type, "webpage")
  # Read from a file too, with targets given to every entry.
  f <- tempfile(fileext = ".bib"); writeLines(bib, f)
  from_file <- suppressWarnings(read_bibtex(f, cited_by = "scale:org"))
  expect_equal(from_file$field_2018$cited_by, "scale:org")
})

test_that("add_references() refuses a repeated key unless told to replace it", {
  instr <- demo_instrument()
  instr <- add_references(instr, sf_reference("a_1", "First", cited_by = "item:q1"))
  expect_error(add_references(instr, sf_reference("a_1", "Second")), class = "sframe_validation_error")
  replaced <- add_references(instr, sf_reference("a_1", "Second", cited_by = "scale:org"), replace = TRUE)
  expect_length(replaced$references, 1)
  expect_equal(replaced$references[[1]]$title, "Second")
  expect_setequal(replaced$references[[1]]$cited_by, c("item:q1", "scale:org"))
  expect_named(sframe_references(replaced, cited_by = "scale:org"), "a_1")
  # sf_instrument() takes references as components.
  direct <- sf_instrument("Direct", components = list(sf_item("q1", "Age?", "numeric"), sf_reference("b_1", "B")))
  expect_length(direct$references, 1)
})

test_that("references round-trip, and an instrument without them keeps its file hash", {
  plain <- demo_instrument()
  f0 <- tempfile(fileext = ".sframe"); write_sframe(plain, f0)
  expect_false("references" %in% names(jsonlite::fromJSON(f0, simplifyVector = FALSE)))

  cited <- add_references(plain, sf_reference("a_1", "First", year = 2001, cited_by = "item:q1"))
  f1 <- tempfile(fileext = ".sframe"); write_sframe(cited, f1)
  written <- jsonlite::fromJSON(f1, simplifyVector = FALSE)
  # One target still serialises as an array, and the date keeps its nesting.
  expect_true(grepl('"cited_by": \\[', paste(readLines(f1), collapse = "")))
  expect_equal(written$references[[1]]$issued$`date-parts`[[1]][[1]], 2001)

  back <- read_sframe(f1)
  expect_s3_class(back$references[[1]], "sf_reference")
  expect_equal(back$references[[1]]$cited_by, "item:q1")
  f2 <- tempfile(fileext = ".sframe"); write_sframe(back, f2)
  expect_identical(readLines(f1), readLines(f2))
})

test_that("citing a source is not an amendment: the content hash ignores references", {
  instr <- demo_instrument()
  before <- surveyframe:::sframe_content_hash(instr)
  after <- surveyframe:::sframe_content_hash(add_references(instr, sf_reference("a_1", "First")))
  expect_identical(before, after)

  # An amended instrument read from its file takes a reference and writes
  # again with no amendment recorded.
  f <- tempfile(fileext = ".sframe"); write_sframe(instr, f)
  prev <- read_sframe(f)
  revised <- prev; revised$items[[1]]$label <- "The event started on time."
  amended <- amend_sframe(prev, revised, reason_code = "instrument_revision",
                          reason_text = "Wording.", tier = "design", deviation_report = "Item q1 reworded.")
  write_sframe(amended, f, overwrite = TRUE)
  reread <- read_sframe(f)
  expect_no_error(write_sframe(add_references(reread, sf_reference("a_1", "First")), tempfile(fileext = ".sframe")))
  # A change to an item still needs one.
  reread$items[[2]]$label <- "Changed without disclosure."
  expect_error(write_sframe(reread, tempfile(fileext = ".sframe")))
})

test_that("validate_sframe() reports a missing target and a repeated key", {
  instr <- demo_instrument()
  instr$references <- list(sf_reference("a_1", "First", cited_by = "item:nope"),
                           sf_reference("a_1", "Again", cited_by = "plan:RQ9"))
  v <- validate_sframe(instr, strict = FALSE)
  expect_false(v$valid)
  msgs <- paste(unlist(v$problems %||% v$errors), collapse = " | ")
  expect_match(msgs, "item 'nope'")
  expect_match(msgs, "plan 'RQ9'")
  expect_match(msgs, "Duplicate reference id")
  expect_true("references" %in% surveyframe:::sframe_validation_checks)
  expect_true(validate_sframe(add_references(demo_instrument(), sf_reference("ok_1", "Fine", cited_by = "scale:org")), strict = FALSE)$valid)
})

test_that("every built-in method reference has a CSL record, keyed the same", {
  apa <- surveyframe:::.sframe_citations
  csl <- surveyframe:::.sframe_citation_csl
  expect_setequal(names(csl), names(apa))
  for (key in names(csl)) {
    ref <- surveyframe:::sframe_builtin_reference(key)
    expect_s3_class(ref, "sf_reference")
    expect_true(nzchar(ref$title), info = key)
    expect_false(is.null(ref$issued), info = key)
  }
  expect_equal(surveyframe:::sframe_intext_citation(c("field_2018", "cohen_1988", "hosmer_2013", "nope")),
               "(Cohen, 1988; Field, 2018; Hosmer et al., 2013)")
})

test_that("each built-in CSL record formats in APA as the shipped APA string reads", {
  skip_on_cran()
  pandoc <- Sys.which("pandoc")
  if (!nzchar(pandoc)) pandoc <- if (nzchar(Sys.which("quarto"))) "quarto-pandoc" else ""
  skip_if(!nzchar(pandoc), "pandoc not available")
  style <- system.file("csl", "apa.csl", package = "surveyframe")
  skip_if(!nzchar(style), "bundled APA style not found")
  dir <- tempfile("csl-"); dir.create(dir)
  keys <- names(surveyframe:::.sframe_citation_csl)
  refs <- lapply(keys, surveyframe:::sframe_builtin_reference)
  sframe_bibliography(extra = refs, file = file.path(dir, "refs.json"))
  md <- c("---", "nocite: '@*'", "---", "", "::: {#refs}", ":::")
  writeLines(md, file.path(dir, "in.md"))
  args <- c(file.path(dir, "in.md"), "--citeproc", paste0("--bibliography=", file.path(dir, "refs.json")),
            paste0("--csl=", style), "-t", "plain", "--wrap=none")
  out <- if (identical(pandoc, "quarto-pandoc")) system2("quarto", c("pandoc", args), stdout = TRUE) else system2(pandoc, args, stdout = TRUE)
  out <- out[nzchar(trimws(out))]
  # Compare without the markers the 2 forms write differently: asterisks for
  # italics in the APA strings, an en-dash for page ranges from the style,
  # and the templated year and version.
  norm <- function(x) {
    x <- gsub("\\*", "", x)
    x <- gsub("–", "-", x)
    x <- gsub("’", "'", x)
    x <- gsub("\\(\\d{4}\\)|\\(\\{(r_year|year)\\}\\)", "(YEAR)", x)
    x <- gsub("\\(Version [^)]*\\)", "(Version V)", x)
    trimws(gsub("\\s+", " ", x))
  }
  expected <- vapply(surveyframe:::.sframe_citations[keys], function(c) c$apa, character(1))
  formatted <- norm(out)
  for (key in keys) {
    want <- norm(expected[[key]])
    expect_true(want %in% formatted, info = paste0(key, "\n  expected: ", want))
  }
})

test_that("render_results() cites in text and lists each reference once, at the end", {
  d <- sframe_demo("two_group")
  res <- run_analysis_plan(d$responses, d$instrument)
  f <- tempfile(fileext = ".html")
  render_results(res, d$instrument, output_path = f)
  html <- paste(readLines(f, warn = FALSE), collapse = "\n")
  expect_false(grepl("citations-section", html, fixed = TRUE))
  expect_match(html, "References for this analysis: \\(")
  expect_equal(lengths(regmatches(html, gregexpr("<h2>References</h2>", html, fixed = TRUE))), 1L)
  entries <- regmatches(html, gregexpr('<div class="csl-entry">[^<]*', html))[[1]]
  expect_identical(entries, sort(entries))
})

test_that("the Quarto report cites in text and lists every reference once, at the end", {
  skip_on_cran()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto not available")
  d <- sframe_demo("likert_scale")
  instr <- d$instrument
  scale <- instr$scales[[1]]$id
  block <- instr$analysis_plan[[1]]$id
  instr <- add_references(instr,
    sf_reference("likert_1932", "A technique for the measurement of attitudes", author = "Likert, R.",
                 year = 1932, container = "Archives of Psychology", volume = "22", issue = "140",
                 pages = "1-55", cited_by = c("instrument", paste0("scale:", scale))),
    sf_reference("nunnally_1994", "Psychometric theory", author = c("Nunnally, J. C.", "Bernstein, I. H."),
                 year = 1994, type = "book", edition = "3", publisher = "McGraw-Hill", cited_by = paste0("plan:", block)))
  interp <- stats::setNames(list("As earlier work found [@smith_2020]."), block)
  extra <- list(sf_reference("smith_2020", "Writing about results", author = "Smith, A.", year = 2020, type = "book", publisher = "SAGE"))
  out <- suppressMessages(render_report(instr, data = d$responses, interpretations = interp,
                                        references = extra, output_file = tempfile(fileext = ".html")))
  skip_if(!identical(attr(out, "engine"), "quarto"), "Quarto render fell back to the built-in engine")
  html <- paste(readLines(out, warn = FALSE), collapse = "\n")
  text <- gsub("\\s+", " ", gsub("<[^>]+>", " ", html))
  expect_false(grepl("[@", text, fixed = TRUE))
  expect_false(grepl("References:</strong>", html, fixed = TRUE))
  expect_match(text, "Draws on: \\( Likert, 1932 \\)")
  expect_match(text, "As earlier work found \\( Smith, 2020 \\)")
  # One list, after every other section, holding each cited work once.
  expect_gt(regexpr('id="refs"', html), regexpr("sec-repro", html))
  ids <- regmatches(html, gregexpr('id="ref-[^"]+"', html))[[1]]
  expect_false(any(duplicated(ids)))
  expect_true(all(c('id="ref-likert_1932"', 'id="ref-nunnally_1994"', 'id="ref-smith_2020"') %in% ids))
})
