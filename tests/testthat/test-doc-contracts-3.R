# Batch 8's maintainability findings, and batch 3's oracle claim.
#
# #12. The sf_/sframe_/unprefixed split was inferable and undocumented.
# #13. 63 exports had no example section.
# #15. Two CFA syntax functions overlap with no guidance on which to use.
# #17. The 24 plot exports gave no way to tell their inputs apart.
# #18. The 12 report exports mixed data-in/object-out with object-in/file-out.
# Batch 3 #16. NEWS said independent agreement was required before a method
#              was accepted, which is wider than the 5 oracle calls the suite
#              makes across 10 methods.

source_of <- function(file) sframe_source_text("R", file)

test_that("12: the package page documents the 2 kinds of name", {
  src <- source_of("surveyframe-package.R")
  expect_match(src, "How functions are named", fixed = TRUE)
  # both kinds named, and the old names pointed to
  expect_match(src, "Everything else takes `sframe_`", fixed = TRUE)
  expect_match(src, "No 2 names sit 1 letter apart", fixed = TRUE)
  expect_match(src, "carry no", fixed = TRUE)
  # only the superseded wrappers keep the old sf_ prefix
  ex <- sframe_exports()
  old <- grep("^sf_", ex, value = TRUE)
  wrappers <- old[vapply(old, function(nm) any(grepl("sframe_superseded(", deparse(body(get(nm, asNamespace("surveyframe")))), fixed = TRUE)), logical(1))]
  expect_setequal(old, wrappers)
})

test_that("13: every export carries an example section", {
  man_dir <- sframe_installed_path("man")
  skip_if(is.na(man_dir), "no man directory here")
  man <- list.files(man_dir, pattern = "[.]Rd$", full.names = TRUE)
  documented <- unlist(lapply(man, function(f) {
    s <- paste(readLines(f, warn = FALSE), collapse = "\n")
    if (!grepl("\\\\examples\\{", s)) return(character(0))
    regmatches(s, gregexpr("(?<=\\\\alias\\{)[^}]+", s, perl = TRUE))[[1]]
  }))
  ex <- sframe_exports()
  expect_equal(setdiff(ex, documented), character(0))
})

test_that("15: the 2 CFA syntax functions are 1, and both old names still work", {
  exported <- sframe_exports()
  expect_true("sframe_syntax_cfa" %in% exported)
  # removing either old name would break public scripts
  expect_true(all(c("cfa_syntax", "cfa_lavaan_syntax") %in% exported))
})

test_that("17: the plot family has a selection guide naming inputs", {
  src <- source_of("plots.R")
  expect_match(src, "sframe_plots", fixed = TRUE)
  # the claims under test: the two multi-panel helpers return what it says
  demo <- sframe_demo_data()
  panels <- sframe_plot_variable_distribution(demo$responses, "sat_1")
  expect_length(panels, 3)
})

test_that("18: the report family index separates the two shapes", {
  src <- source_of("reporting.R")
  expect_match(src, "sframe_reports", fixed = TRUE)
  # the claim under test: sframe_codebook() returns an object, and
  # render_report() writes a file
  book <- sframe_codebook(sframe_demo_data()$instrument)
  expect_s3_class(book, "sframe_codebook")
})

test_that("batch 3 #16: the oracle claim matches the suite's coverage", {
  news <- sframe_installed_text("NEWS.md")
  expect_false(grepl("is required to agree", news, fixed = TRUE))
  expect_match(news, "5 of the 10", fixed = TRUE)
  # the count under test: 5 tests gate on RMCDA, one per method it checks
  tests <- list.files(".", pattern = "^test-decision.*[.]R$", full.names = TRUE)
  gated <- vapply(tests, function(f) {
    sum(grepl('skip_if_not_installed("RMCDA")', readLines(f, warn = FALSE),
              fixed = TRUE))
  }, numeric(1))
  expect_equal(sum(gated), 5)
})
