# tests/testthat/test-report-formats.R
#
# Session 8b-R, item 3 (NAMING decision 6, owner 2026-10-31, coordinator
# 2026-11-04). render_report() writes HTML, PDF, Word (.docx) and OpenDocument
# (.odt). Word and ODT go through Quarto, styled by the bundled APA 7
# reference documents. PDF goes through Quarto and LaTeX when a LaTeX engine
# is found, through Quarto's Typst otherwise, and without Quarto through the
# built-in page printed by pagedown. The manifest records the engine and the
# converter. The results record does not, so it stays the same whichever
# engine ran.

unzip_text <- function(path, member) {
  dir <- tempfile("unz-")
  utils::unzip(path, files = member, exdir = dir)
  paste(readLines(file.path(dir, member), warn = FALSE, encoding = "UTF-8"), collapse = "\n")
}

pdf_text_has <- function(out, words) {
  if (!nzchar(Sys.which("pdftotext"))) return(invisible())
  # UTF-8 both ways: Windows read the native code page, and testthat could
  # not print the mismatch ("input string 1 is invalid").
  txt <- paste(suppressWarnings(system2("pdftotext", c("-layout", "-enc", "UTF-8", shQuote(out), "-"),
                                        stdout = TRUE)), collapse = "\n")
  Encoding(txt) <- "UTF-8"
  for (w in words) expect_match(txt, w, fixed = TRUE)
}

manifest_of <- function(out) {
  jsonlite::fromJSON(surveyframe:::sframe_record_paths(out)$manifest, simplifyVector = FALSE)
}

test_that("the APA reference documents set Times New Roman 12 and double spacing", {
  docx <- system.file("templates", "apa-reference.docx", package = "surveyframe")
  odt <- system.file("templates", "apa-reference.odt", package = "surveyframe")
  expect_true(file.exists(docx))
  expect_true(file.exists(odt))
  sty <- unzip_text(docx, "word/styles.xml")
  expect_match(sty, "w:ascii=\"Times New Roman\"", fixed = TRUE)
  expect_match(sty, "w:line=\"480\"", fixed = TRUE)
  expect_false(grepl("asciiTheme", sty, fixed = TRUE))
  expect_false(grepl("<w:sz w:val=\"(?!24\")", sty, perl = TRUE))
  osty <- unzip_text(odt, "styles.xml")
  expect_match(osty, "fo:line-height=\"200%\"", fixed = TRUE)
  expect_false(grepl("style:font-name=\"Arial\"", osty, fixed = TRUE))
  # OpenDocument needs mimetype first in the archive.
  expect_identical(utils::unzip(odt, list = TRUE)$Name[1], "mimetype")
})

test_that("the template names the reference documents for Word and ODT", {
  qmd <- paste(readLines(system.file("templates", "report.qmd", package = "surveyframe")),
               collapse = "\n")
  expect_match(qmd, "reference-doc: apa-reference.docx", fixed = TRUE)
  expect_match(qmd, "reference-doc: apa-reference.odt", fixed = TRUE)
  expect_match(qmd, "knitr::is_html_output()", fixed = TRUE)
})

test_that("Word and ODT without Quarto stop with a message that names Quarto", {
  old <- options(surveyframe.use_quarto = FALSE)
  on.exit(options(old), add = TRUE)
  ins <- sframe_demo("likert_scale")$instrument
  for (f in c("docx", "odt")) {
    expect_error(render_report(ins, output_file = tempfile(fileext = paste0(".", f)),
                               format = f, open = FALSE),
                 "needs Quarto", class = "sframe_missing_quarto")
  }
})

test_that("options(surveyframe.latex = FALSE) hides LaTeX", {
  old <- options(surveyframe.latex = FALSE)
  on.exit(options(old), add = TRUE)
  expect_false(surveyframe:::sframe_latex_available())
})

render_format <- function(format, ..., latex = NULL) {
  old <- options(surveyframe.use_quarto = TRUE, surveyframe.latex = latex)
  on.exit(options(old), add = TRUE)
  d <- sframe_demo("likert_scale")
  out <- tempfile(fileext = paste0(".", format))
  res <- suppressMessages(render_report(d$instrument, data = d$responses, output_file = out,
                                        format = format, open = FALSE, ...))
  list(out = out, res = res, d = d)
}

test_that("a Word report renders through Quarto with the APA styles", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  r <- render_format("docx")
  expect_identical(attr(r$res, "engine"), "quarto")
  expect_identical(attr(r$res, "converter"), "quarto")
  doc <- unzip_text(r$out, "word/document.xml")
  expect_match(doc, "Provenance", fixed = TRUE)
  expect_match(doc, "Quality summary", fixed = TRUE)
  expect_match(doc, "<w:tbl>", fixed = TRUE)
  expect_false(grepl("&lt;figure", doc, fixed = TRUE))
  expect_match(unzip_text(r$out, "word/styles.xml"), "w:line=\"480\"", fixed = TRUE)
  man <- manifest_of(r$out)
  expect_identical(man$rendering$engine, "quarto")
  expect_identical(man$rendering$converter, "quarto")
})

test_that("an OpenDocument report renders through Quarto with the APA styles", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  r <- render_format("odt")
  expect_identical(attr(r$res, "converter"), "quarto")
  content <- unzip_text(r$out, "content.xml")
  expect_match(content, "Provenance", fixed = TRUE)
  expect_match(content, "<table:table ", fixed = TRUE)
  expect_match(unzip_text(r$out, "styles.xml"), "fo:line-height=\"200%\"", fixed = TRUE)
})

test_that("a PDF renders through Quarto and LaTeX when LaTeX is found", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  skip_if(!surveyframe:::sframe_latex_available(), "no LaTeX engine")
  skip_if_latex_broken()
  r <- render_format("pdf")
  expect_identical(attr(r$res, "converter"), "quarto-latex")
  expect_identical(readBin(r$out, "raw", 4), charToRaw("%PDF"))
  pdf_text_has(r$out, c("Provenance", "Quality summary", "Respondents", "Flag rate", "Item-wise missingness"))
  expect_identical(manifest_of(r$out)$rendering$converter, "quarto-latex")
})

test_that("a PDF renders through Quarto's Typst when LaTeX is hidden", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  r <- render_format("pdf", latex = FALSE)
  expect_identical(attr(r$res, "converter"), "quarto-typst")
  expect_identical(readBin(r$out, "raw", 4), charToRaw("%PDF"))
  pdf_text_has(r$out, c("Provenance", "Quality summary", "Respondents", "Flag rate", "Item-wise missingness"))
  expect_identical(manifest_of(r$out)$rendering$converter, "quarto-typst")
})

test_that("every format's results record is the same", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  rec <- function(out) surveyframe:::sframe_sha256_file(surveyframe:::sframe_record_paths(out)$results)
  html <- render_format("html")
  docx <- render_format("docx")
  expect_identical(rec(html$out), rec(docx$out))
})

test_that("the Typst route renders offline, importing no Typst package", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  # Quarto imports @preview/fontawesome for a callout in Typst. The template
  # writes none there, so a render with an empty package cache leaves it
  # empty: nothing was fetched.
  qmd <- paste(readLines(system.file("templates", "report.qmd", package = "surveyframe")),
               collapse = "\n")
  expect_match(qmd, "if (out_html) {\n              cat(\"\\n::: {.callout-note", fixed = TRUE)
  cache <- tempfile("typst-cache-")
  dir.create(cache)
  old <- Sys.getenv("TYPST_PACKAGE_CACHE_PATH", unset = NA)
  Sys.setenv(TYPST_PACKAGE_CACHE_PATH = cache)
  on.exit(if (is.na(old)) Sys.unsetenv("TYPST_PACKAGE_CACHE_PATH")
          else Sys.setenv(TYPST_PACKAGE_CACHE_PATH = old), add = TRUE)
  r <- render_format("pdf", latex = FALSE, show_code = TRUE)
  expect_identical(attr(r$res, "converter"), "quarto-typst")
  expect_identical(readBin(r$out, "raw", 4), charToRaw("%PDF"))
  expect_identical(list.files(cache, recursive = TRUE, all.files = TRUE), character(0))
})

