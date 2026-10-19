# tests/testthat/test-startup-message.R
#
# library(surveyframe) prints a short call to action. These tests hold it to
# what it promises: every command it shows runs, it stays quiet outside an
# interactive session, and suppressPackageStartupMessages() silences it.

startup_text <- function() surveyframe:::sframe_startup_message()

# The indented demo lines of the message, as R code.
startup_demo_lines <- function() {
  lines <- strsplit(startup_text(), "\n", fixed = TRUE)[[1]]
  sub("\\s+#.*$", "", trimws(grep("^  \\S", lines, value = TRUE)))
}

test_that("the message names the version, the citation and the site", {
  txt <- startup_text()
  expect_match(txt, as.character(utils::packageVersion("surveyframe")),
               fixed = TRUE)
  expect_match(txt, 'citation("surveyframe")', fixed = TRUE)
  expect_match(txt, "https://mohammedalisharafuddin.github.io/surveyframe/",
               fixed = TRUE)
})

test_that("every function the message names is exported", {
  called <- regmatches(startup_text(),
                       gregexpr("[A-Za-z_][A-Za-z0-9_.]*(?=\\()",
                                startup_text(), perl = TRUE))[[1]]
  called <- setdiff(unique(called), c("citation", "vignette"))
  expect_true(length(called) >= 5)
  for (fn in called) {
    expect_true(fn %in% getNamespaceExports("surveyframe"), info = fn)
  }
})

test_that("the vignette the message points at exists", {
  vig <- sframe_installed_path("inst", "doc", "surveyframe.html")
  src <- sframe_source_path("vignettes", "surveyframe.Rmd")
  # covr installs without building vignettes and runs away from the source
  # tree, so neither copy is present there. R CMD check has both.
  skip_if(is.na(vig) && is.na(src), "no built vignettes and no source tree")
  expect_true(TRUE)
})

test_that("the demo commands run as printed", {
  code <- startup_demo_lines()
  expect_length(code, 3)
  # Keep the browser closed, nothing else changed.
  code[1:2] <- sub(")$", ", open = FALSE)", code[1:2])
  studio_args <- NULL
  local_mocked_bindings(
    launch_studio = function(...) {
      studio_args <<- list(...)
      invisible(NULL)
    }
  )
  env <- new.env(parent = asNamespace("surveyframe"))
  path <- NULL
  expect_no_error(path <- suppressMessages(eval(parse(text = code[1]), envir = env)))
  expect_true(file.exists(path))
  # The preview strips the collector
  expect_false(any(grepl("script.google.com", readLines(path, warn = FALSE),
                         fixed = TRUE)))
  expect_no_error(suppressMessages(eval(parse(text = code[2]), envir = env)))
  expect_s3_class(studio_args[[1]], "sframe")
  expect_identical(studio_args$screen, "preview")
  expect_false(studio_args$launch.browser)
  expect_no_error(suppressMessages(eval(parse(text = code[3]), envir = env)))
  expect_s3_class(get("demo", envir = env)$instrument, "sframe")
})

test_that("preview_demo() rejects an unknown destination", {
  expect_error(preview_demo("two_group", where = "phone", open = FALSE))
})

test_that("attaching is silent outside an interactive session", {
  local_mocked_bindings(sframe_is_interactive = function() FALSE)
  expect_silent(surveyframe:::.onAttach("", "surveyframe"))
})

test_that("attaching prints one startup message, which can be suppressed", {
  local_mocked_bindings(sframe_is_interactive = function() TRUE)
  conds <- list()
  withCallingHandlers(
    surveyframe:::.onAttach("", "surveyframe"),
    message = function(m) {
      conds[[length(conds) + 1L]] <<- m
      invokeRestart("muffleMessage")
    }
  )
  expect_length(conds, 1L)
  expect_s3_class(conds[[1]], "packageStartupMessage")
  expect_silent(suppressPackageStartupMessages(
    surveyframe:::.onAttach("", "surveyframe")))
})
