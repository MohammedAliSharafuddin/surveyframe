# render_report(instrument) with no data is the pre-analysis plan (Session
# 10, owner 2026-11-10, coordinator spec 2026-11-14): a document to submit
# to OSF, Zenodo or an ethics committee, not a results page.

plan_md <- function(name, edit = identity) {
  ins <- edit(sframe_demo(name, preview = FALSE)$instrument)
  paste(surveyframe:::sframe_plan_md(surveyframe:::sframe_plan_blocks(ins)), collapse = "\n")
}

test_that("the plan has its sections in order, and no results rows", {
  md <- plan_md("two_group")
  heads <- regmatches(md, gregexpr("(?m)^## .*$", md, perl = TRUE))[[1]]
  expect_identical(heads, paste("##", c("Study", "Participant information", "The questionnaire",
    "Scales and scoring", "Pre-declared analysis plan", "Amendments", "References",
    "To complete before submission")))
  expect_false(grepl("Results record|Analysis seed|Not specified", md))
})

test_that("the title page carries the hash and how to verify it", {
  ins <- sframe_demo("two_group", preview = FALSE)$instrument
  md <- plan_md("two_group")
  expect_match(md, surveyframe:::sframe_hash_value(ins), fixed = TRUE)
  expect_match(md, "https://surveyframe.org/verify", fixed = TRUE)
  expect_identical(surveyframe:::sframe_plan_title(ins), "Pre-analysis plan: In person or online?")
})

test_that("methods are in words with their reference, and alpha only for tests", {
  md <- plan_md("two_group")
  expect_match(md, "**Method:** Independent samples t-test", fixed = TRUE)
  expect_match(md, "**Method:** Mann-Whitney U test", fixed = TRUE)
  expect_match(md, "**Method reference:**", fixed = TRUE)
  expect_match(md, "alpha = .05, the package default", fixed = TRUE)
  expect_false(grepl("t_test_ind", md, fixed = TRUE))
  br <- plan_md("branching")
  expect_false(grepl("Significance level:** alpha", br, fixed = TRUE))
})

test_that("the questionnaire is in order with its branching in words", {
  md <- plan_md("branching")
  expect_match(md, "1. What brought you here? (Single choice, required). Options: Delegate, Speaker", fixed = TRUE)
  expect_match(md, "Shown only when 'What brought you here?' is one of Delegate or Speaker.", fixed = TRUE)
})

test_that("scales show items, reverse keys and the missing-answer rule", {
  md <- plan_md("likert_scale", function(ins) { ins$scales[[1]]$min_valid <- 3L; ins })
  expect_match(md, "org\\_4", fixed = TRUE)
  expect_match(md, "at least 3 of 4 items", fixed = TRUE)
  expect_match(plan_md("likert_scale"), "all 4 items needed", fixed = TRUE)
})

test_that("participant text, study and amendments print as written", {
  md <- plan_md("instrument_revision", function(ins) {
    ins$study <- list(problem = "Why attendance fell.",
                      sampling = list(population = "Attendees", method = "convenience", planned_n = 80L))
    ins
  })
  expect_match(md, "**Consent (required to start):** I agree to take part", fixed = TRUE)
  expect_match(md, "**Research problem:** Why attendance fell.", fixed = TRUE)
  expect_match(md, "**Planned sample size:** 80", fixed = TRUE)
  expect_match(md, "Reworded the open question", fixed = TRUE)
  expect_match(plan_md("two_group"), "None. This is the instrument as first planned.", fixed = TRUE)
})

test_that("To complete before submission prompts each field, or prints what is declared", {
  md <- plan_md("two_group")
  for (f in c("Exclusion rules", "Stopping rule", "Primary and secondary outcomes",
              "Multiplicity", "Contingency decisions", "Significance level")) {
    expect_match(md, paste0("**", f, ":**"), fixed = TRUE, info = f)
  }
  held <- plan_md("two_group", function(ins) { ins$analysis_plan[[1]]$options$alpha <- 0.01; ins })
  expect_match(held, "Declared in the instrument: alpha = 0.01", fixed = TRUE)
})

test_that("instrument text cannot inject Markdown or HTML", {
  md <- plan_md("two_group", function(ins) { ins$meta$description <- "*bold* <script>x</script>"; ins })
  expect_match(md, "\\*bold\\* \\<script\\>", fixed = TRUE)
  ins <- sframe_demo("two_group", preview = FALSE)$instrument
  ins$meta$description <- "<script>x</script>"
  html <- surveyframe:::sframe_plan_html(surveyframe:::sframe_plan_blocks(ins))
  expect_false(grepl("<script>", html, fixed = TRUE))
})

test_that("the built-in plan page is the plan, titled as one", {
  old <- options(surveyframe.use_quarto = FALSE)
  on.exit(options(old), add = TRUE)
  ins <- sframe_demo("two_group", preview = FALSE)$instrument
  out <- suppressMessages(render_report(ins, output_file = tempfile(fileext = ".html"), open = FALSE))
  html <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_match(html, "Pre-analysis plan: In person or online?", fixed = TRUE)
  expect_match(html, "<h2>To complete before submission</h2>", fixed = TRUE)
  expect_false(grepl("Results record|Analysis seed|short results page", html))
  expect_match(html, "plain version of the plan", fixed = TRUE)
  expect_match(html, surveyframe:::sframe_hash_value(ins), fixed = TRUE)
})

test_that("a report with data is unchanged", {
  d <- sframe_demo("two_group", preview = FALSE)
  out <- suppressMessages(render_report(d$instrument, d$responses,
                                        output_file = tempfile(fileext = ".html"), open = FALSE))
  html <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_false(grepl("Pre-analysis plan", html, fixed = TRUE))
})

test_that("the plan renders through Quarto in HTML, Word and PDF", {
  skip_if_not_slow()
  ins <- sframe_demo("two_group", preview = FALSE)$instrument
  hash <- surveyframe:::sframe_hash_value(ins)
  for (fmt in c("html", "docx", "pdf")) {
    out <- suppressMessages(render_report(ins, output_file = tempfile(fileext = paste0(".", fmt)),
                                          format = fmt, open = FALSE))
    expect_identical(attr(out, "engine"), "quarto", info = fmt)
    txt <- switch(fmt,
      html = paste(readLines(out, warn = FALSE), collapse = "\n"),
      docx = { d <- tempfile(); utils::unzip(out, "word/document.xml", exdir = d)
               gsub("<[^>]+>", "", paste(readLines(file.path(d, "word", "document.xml"), warn = FALSE), collapse = "")) },
      pdf = { skip_if(!nzchar(Sys.which("pdftotext")), "pdftotext not found")
              paste(system2("pdftotext", c("-layout", shQuote(out), "-"), stdout = TRUE), collapse = " ") })
    txt <- gsub("\\s+", " ", txt)
    expect_match(txt, "Pre-analysis plan", fixed = TRUE, info = fmt)
    expect_match(txt, "To complete before submission", fixed = TRUE, info = fmt)
    expect_match(txt, "Independent samples t-test", fixed = TRUE, info = fmt)
    expect_match(gsub("\\s+", "", txt), hash, fixed = TRUE, info = fmt)
  }
})
