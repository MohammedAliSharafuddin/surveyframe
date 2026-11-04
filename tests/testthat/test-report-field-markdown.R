# tests/testthat/test-report-field-markdown.R
#
# Session 8b-R, item 10 (owner 2026-11-04). The research question, H0, H1,
# decision rule, interpretation, study problem and deviation report may hold
# Markdown. Plain prose prints exactly as typed. Formatting gives the same
# result in both engines. Equations render in every Quarto format, offline,
# and print as TeX in monospace on the built-in page. Shortcodes, raw blocks,
# div fences, heading lines, a --- line and HTML tags print as typed, R code
# in a field runs nothing, and @word is a citation only for a known key.

secret <- "zq9fieldsecret"

field_instrument <- function(h1 = "The groups differ.", rule = "", interp = NULL,
                             rq = "Do the groups differ?", problem = NULL) {
  block <- list(id = "RQ1", research_question = rq,
                family = "group_comparison", method = "t_test_ind",
                roles = list(outcome = "score", group = "grp"),
                hypotheses = list(alternative = h1), decision_rule = rule)
  block$interpretation <- interp
  ins <- sframe_instrument(title = "Fields", components = list(
    sframe_choice_set("ab", values = c("a", "b"), labels = c("A", "B")),
    sframe_item("score", "Score", type = "numeric"),
    sframe_item("grp", "Group", type = "single_choice", choice_set = "ab")),
    analysis_plan = list(block),
    study = if (!is.null(problem)) list(problem = problem))
  sframe_add_references(ins, sframe_reference(
    "cronbach_1951", "Coefficient alpha and the internal structure of tests",
    author = "Cronbach, L. J.", year = 1951))
}

field_data <- data.frame(score = c(3, 4, 5, 6, 2, 3, 4, 7, 8, 6),
                         grp = rep(c("a", "b"), each = 5))

builtin <- function(ins) {
  f <- tempfile(fileext = ".html")
  surveyframe:::.render_report_html(ins, field_data, output_path = f, show_code = FALSE)
  paste(readLines(f, warn = FALSE), collapse = "\n")
}

quarto <- function(ins, format = "html") {
  old <- options(surveyframe.use_quarto = TRUE)
  on.exit(options(old), add = TRUE)
  out <- tempfile(fileext = paste0(".", format))
  res <- suppressMessages(render_report(ins, data = field_data, output_file = out,
                                        format = format, show_code = FALSE, open = FALSE))
  expect_identical(attr(res, "engine"), "quarto")
  if (format != "html") return(out)
  paste(readLines(out, warn = FALSE), collapse = "\n")
}

skip_quarto <- function() {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
}

# Every form in 1 field each, so 1 render per engine checks them all.
forms <- list(
  prose = "Email a@b.org about item #1, which costs $5 and $10, and 5 * 3 is 15.",
  format = "**Bold**, *italic*, H~2~O, x^2^ and [@cronbach_1951].",
  list = "Reasons:\n\n- the first\n- the second",
  html = "Tagged <b>bold</b> and <script>alert(1)</script> here.",
  shortcode = sprintf("Shortcode {{< env SF_FIELD_SECRET >}} and {{< meta title >}} here."),
  raw = "Raw `<i>inline</i>`{=html} here.",
  fence = "Fence\n\n::: {.callout-warning}\nwarned\n:::",
  heading = "# A heading line",
  yaml = "Before\n\n---\nbibliography: evil.json\ntitle: Evil\n---\n\nAfter",
  code = "Code\n\n```{r}\nSys.getenv(\"SF_FIELD_SECRET\")\n```\n\nand `r Sys.getenv(\"SF_FIELD_SECRET\")` inline",
  nokey = "Ask @nokey or @cronbach_1951.",
  math = "Inline $r = .42$, display $$\\chi^2(1) = 4.21, p = .040$$, and a lone $x here."
)

forms_instrument <- function() {
  ins <- field_instrument(h1 = forms$prose, rule = forms$format, interp = forms$list,
                          problem = forms$math)
  extra <- forms[c("html", "shortcode", "raw", "fence", "heading", "yaml", "code", "nokey")]
  ins$analysis_plan <- c(ins$analysis_plan, Map(function(txt, k) {
    list(id = paste0("RQ", k + 1), research_question = paste("Block", k + 1),
         family = "group_comparison", method = "t_test_ind",
         roles = list(outcome = "score", group = "grp"), decision_rule = txt)
  }, extra, seq_along(extra)))
  ins
}

visible <- function(html) {
  t <- gsub("(?s)<script.*?</script>|(?s)<style.*?</style>", "", html, perl = TRUE)
  t <- gsub("<[^>]+>", "", t)
  t <- gsub("&lt;", "<", gsub("&gt;", ">", gsub("&quot;", "\"", gsub("&#39;", "'", t))))
  gsub("&amp;", "&", t)
}

check_forms <- function(doc, engine) {
  vis <- visible(doc)
  expect_match(vis, forms$prose, fixed = TRUE, info = engine)
  expect_match(doc, "<strong>Bold</strong>", fixed = TRUE, info = engine)
  expect_match(doc, "<em>italic</em>", fixed = TRUE, info = engine)
  expect_match(doc, "H<sub>2</sub>O", fixed = TRUE, info = engine)
  expect_match(doc, "x<sup>2</sup>", fixed = TRUE, info = engine)
  expect_match(doc, "Cronbach, 1951", fixed = TRUE, info = engine)
  expect_match(doc, "<li>the first</li>", fixed = TRUE, info = engine)
  # Neutralised forms print as typed and do nothing.
  expect_false(grepl("<b>bold</b>", doc, fixed = TRUE), info = engine)
  expect_false(grepl("<script>alert(1)</script>", doc, fixed = TRUE), info = engine)
  expect_match(vis, "Tagged <b>bold</b>", fixed = TRUE, info = engine)
  expect_match(vis, "{{< env SF_FIELD_SECRET >}}", fixed = TRUE, info = engine)
  expect_match(vis, "{{< meta title >}}", fixed = TRUE, info = engine)
  expect_false(grepl(secret, doc, fixed = TRUE), info = engine)
  expect_false(grepl("<i>inline</i>", doc, fixed = TRUE), info = engine)
  expect_match(vis, "{=html}", fixed = TRUE, info = engine)
  expect_match(vis, "::: {.callout-warning}", fixed = TRUE, info = engine)
  expect_false(grepl("callout-warning\"", doc, fixed = TRUE), info = engine)
  expect_match(vis, "# A heading line", fixed = TRUE, info = engine)
  expect_false(grepl("<h1[^>]*>A heading line", doc), info = engine)
  expect_match(vis, "bibliography: evil.json", fixed = TRUE, info = engine)
  expect_match(vis, "Sys.getenv(\"SF_FIELD_SECRET\")", fixed = TRUE, info = engine)
  expect_match(vis, "@nokey", fixed = TRUE, info = engine)
  expect_false(grepl("nokey?", vis, fixed = TRUE), info = engine)
  expect_match(vis, "a lone $x here", fixed = TRUE, info = engine)
}

test_that("a field with no Markdown prints as before", {
  expect_identical(surveyframe:::sframe_field_md("Do the groups differ?"), "Do the groups differ?")
  expect_identical(surveyframe:::sframe_field_html("Do the groups differ?", inline = TRUE),
                   "Do the groups differ?")
  expect_identical(surveyframe:::sframe_field_html(forms$prose),
                   paste0("<p>", surveyframe:::htmltools_escape(forms$prose), "</p>"))
})

test_that("the built-in engine renders the Markdown and neutralises the rest", {
  old <- Sys.getenv("SF_FIELD_SECRET", unset = NA)
  Sys.setenv(SF_FIELD_SECRET = secret)
  on.exit(if (is.na(old)) Sys.unsetenv("SF_FIELD_SECRET") else Sys.setenv(SF_FIELD_SECRET = old), add = TRUE)
  doc <- builtin(forms_instrument())
  check_forms(doc, "built-in")
  # Equations as their TeX in monospace, with no math library.
  expect_match(doc, "<code class=\"sf-tex\">$r = .42$</code>", fixed = TRUE)
  expect_match(doc, "<code class=\"sf-tex\">$$\\chi^2(1) = 4.21, p = .040$$</code>", fixed = TRUE)
  expect_false(grepl("mathjax|katex", doc, ignore.case = TRUE))
})

test_that("a deviation report holding Markdown is formatted under the amendments table", {
  path <- tempfile(fileext = ".sframe")
  write_sframe(field_instrument(), path)
  before <- read_sframe(path)
  after <- before
  after$items[[1]]$label <- "A clearer label"
  ins <- suppressMessages(amend_sframe(before, after, "other", "Clarified.",
                                       deviation_report = "Dropped **because** of H~2~O.",
                                       tier = "pipeline", version = "1.0.1"))
  doc <- builtin(ins)
  expect_match(doc, "Deviation report, amendment 1:</strong> Dropped <strong>because</strong> of H<sub>2</sub>O.",
               fixed = TRUE)
  md <- surveyframe:::sframe_amendment_notes_md(ins)
  expect_identical(md, "**Deviation report, amendment 1:** Dropped **because** of H~2~O.\n\n")
})

test_that("the Quarto engine renders the same fields the same way", {
  skip_quarto()
  old <- Sys.getenv("SF_FIELD_SECRET", unset = NA)
  Sys.setenv(SF_FIELD_SECRET = secret)
  on.exit(if (is.na(old)) Sys.unsetenv("SF_FIELD_SECRET") else Sys.setenv(SF_FIELD_SECRET = old), add = TRUE)
  doc <- quarto(forms_instrument())
  check_forms(doc, "Quarto")
  # The body's YAML block reset neither the bibliography nor the title.
  expect_match(doc, "<title>Fields</title>", fixed = TRUE)
  expect_match(doc, "Coefficient alpha", fixed = TRUE)
  # Equations as MathML with the TeX kept, and no script fetched from the web.
  expect_match(doc, "<math display=\"inline\"", fixed = TRUE)
  expect_match(doc, "<math display=\"block\"", fixed = TRUE)
  expect_match(doc, "<annotation encoding=\"application/x-tex\">r = .42</annotation>", fixed = TRUE)
  expect_false(grepl("<script[^>]*src=\"https?:", doc))
})

test_that("equations render in Word, OpenDocument and PDF", {
  skip_quarto()
  ins <- field_instrument(problem = "Inline $r = .42$ and $$\\chi^2(1) = 4.21, p = .040$$")
  docx <- quarto(ins, "docx")
  dir <- tempfile("docx-")
  utils::unzip(docx, files = "word/document.xml", exdir = dir)
  expect_match(paste(readLines(file.path(dir, "word/document.xml"), warn = FALSE), collapse = ""),
               "<m:oMath", fixed = TRUE)
  odt <- quarto(ins, "odt")
  expect_true(any(grepl("^Formula", utils::unzip(odt, list = TRUE)$Name)))
  pdf <- quarto(ins, "pdf")
  expect_identical(readBin(pdf, "raw", 4), charToRaw("%PDF"))
  if (nzchar(Sys.which("pdftotext"))) {
    txt <- paste(system2("pdftotext", c(shQuote(pdf), "-"), stdout = TRUE), collapse = "\n")
    expect_match(txt, "4.21", fixed = TRUE)
  }
})

test_that("the .qmd export reads the fields from its data files and never writes them into report.qmd", {
  dir <- tempfile("field-source-")
  suppressMessages(render_report(forms_instrument(), data = field_data, output_file = dir,
                                 format = "qmd", open = FALSE))
  qmd <- paste(readLines(file.path(dir, "report.qmd")), collapse = "\n")
  for (txt in c("SF_FIELD_SECRET", "evil.json", "A heading line", "callout-warning", "@nokey")) {
    expect_false(grepl(txt, qmd, fixed = TRUE), info = txt)
  }
  expect_true(any(grepl("SF_FIELD_SECRET", readLines(file.path(dir, "instrument.sframe")), fixed = TRUE)))
})
