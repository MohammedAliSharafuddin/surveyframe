# tests/testthat/test-quarto-find.R
#
# Session 8b-R, item 1 (PREP-01, Codex T3). render_report() found Quarto with
# Sys.which("quarto") alone, so the copies RStudio and Positron bundle, which
# neither puts on the PATH, were never used, and QUARTO_PATH was ignored. The
# finder follows the T3 search order: QUARTO_PATH, the PATH, RSTUDIO_QUARTO,
# then RStudio's and Positron's bundled copies. A candidate counts only when
# `quarto --version` runs and exits 0.

fake_quarto <- function(version = "9.9.9", status = 0L, marker = NULL) {
  dir <- tempfile("fake-quarto-")
  dir.create(dir)
  path <- file.path(dir, "quarto")
  writeLines(c(
    "#!/bin/sh",
    sprintf("if [ \"$1\" = \"--version\" ]; then echo %s; exit %d; fi", version, status),
    if (!is.null(marker)) sprintf("touch '%s'", marker),
    "exit 1"
  ), path)
  Sys.chmod(path, "755")
  path
}

set_env <- function(...) {
  vals <- list(...)
  old <- Sys.getenv(names(vals), unset = NA, names = TRUE)
  do.call(Sys.setenv, vals)
  old
}

restore_env <- function(old) {
  for (n in names(old)) {
    if (is.na(old[[n]])) Sys.unsetenv(n) else do.call(Sys.setenv, stats::setNames(list(old[[n]]), n))
  }
}

test_that("the candidates follow the T3 search order", {
  skip_on_os("windows")
  old <- set_env(QUARTO_PATH = "/x/quarto", RSTUDIO_QUARTO = "/y/quarto")
  on.exit(restore_env(old), add = TRUE)
  cand <- surveyframe:::sframe_quarto_candidates(sysname = "Linux")
  expect_identical(cand$source[1], "QUARTO_PATH")
  expect_identical(cand$path[1], "/x/quarto")
  first <- function(s) match(s, cand$source)
  expect_true(first("RSTUDIO_QUARTO") > first("QUARTO_PATH"))
  expect_true(first("RStudio") > first("RSTUDIO_QUARTO"))
  expect_true(first("Positron") > first("RStudio"))
  expect_true("/usr/lib/rstudio/resources/app/bin/quarto/bin/quarto" %in% cand$path)
  expect_true("/usr/lib/rstudio-server/bin/quarto/bin/quarto" %in% cand$path)
  expect_true("/usr/share/positron/resources/app/quarto/bin/quarto" %in% cand$path)

  mac <- surveyframe:::sframe_quarto_candidates(sysname = "Darwin")
  expect_true("/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto" %in% mac$path)
  expect_true("/Applications/Positron.app/Contents/Resources/app/quarto/bin/quarto" %in% mac$path)
  win <- surveyframe:::sframe_quarto_candidates(sysname = "Windows")
  expect_true(any(grepl("RStudio/resources/app/bin/quarto/bin/quarto.exe", win$path, fixed = TRUE)))
  expect_true(any(grepl("Positron/resources/app/quarto/bin/quarto.exe", win$path, fixed = TRUE)))
})

test_that("QUARTO_PATH comes first when it runs", {
  skip_on_os("windows")
  fake <- fake_quarto("9.9.9")
  old <- set_env(QUARTO_PATH = fake)
  on.exit(restore_env(old), add = TRUE)
  found <- surveyframe:::sframe_quarto_find(refresh = TRUE)
  expect_identical(found$path, fake)
  expect_identical(found$version, "9.9.9")
  expect_identical(found$source, "QUARTO_PATH")
})

test_that("a candidate that does not run is passed over and listed as checked", {
  skip_on_os("windows")
  broken <- fake_quarto("1.0.0", status = 1L)
  good <- fake_quarto("2.0.0")
  cand <- data.frame(source = c("QUARTO_PATH", "PATH", "RStudio"),
                     path = c(broken, "/no/such/quarto", good),
                     stringsAsFactors = FALSE)
  found <- surveyframe:::sframe_quarto_find(candidates = cand, refresh = TRUE)
  expect_identical(found$path, good)
  expect_identical(found$source, "RStudio")
  expect_identical(found$checked$path, cand$path)
  expect_identical(found$checked$state[1:2], c("did not run", "not found"))
  expect_identical(found$checked$state[3], "2.0.0")
})

test_that("nothing found gives a result that lists every path checked", {
  cand <- data.frame(source = c("QUARTO_PATH", "RStudio"),
                     path = c("/no/such/quarto", "/nor/this/quarto"),
                     stringsAsFactors = FALSE)
  found <- surveyframe:::sframe_quarto_find(candidates = cand, refresh = TRUE)
  expect_true(is.na(found$path))
  expect_identical(found$checked$path, cand$path)
  expect_true(all(found$checked$state == "not found"))
})

test_that("render_report() renders with the Quarto the finder selects", {
  skip_on_os("windows")
  marker <- tempfile("quarto-called-")
  fake <- fake_quarto("9.9.9", marker = marker)
  old <- set_env(QUARTO_PATH = fake)
  on.exit(restore_env(old), add = TRUE)
  oldopt <- options(surveyframe.use_quarto = TRUE)
  on.exit(options(oldopt), add = TRUE)
  surveyframe:::sframe_quarto_find(refresh = TRUE)
  out <- tempfile(fileext = ".html")
  res <- suppressMessages(render_report(sframe_demo("likert_scale")$instrument,
                                        output_file = out, open = FALSE))
  # The fake copy was asked to render, failed, and the built-in engine wrote
  # the report.
  expect_true(file.exists(marker))
  expect_identical(attr(res, "engine"), "html")
  surveyframe:::sframe_quarto_find(refresh = TRUE)
})

test_that("reporting.R detects Quarto through the finder only", {
  src <- file.path(sframe_build_source(), "R", "reporting.R")
  skip_if(!file.exists(src), "no source tree")
  expect_false(any(grepl("Sys.which(\"quarto\")", readLines(src), fixed = TRUE)))
})
