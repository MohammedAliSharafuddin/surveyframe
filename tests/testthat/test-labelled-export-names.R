# tests/testthat/test-labelled-export-names.R
#
# D10 / CX-18. Matrix row columns such as `session__Opening keynote` and long
# MCDA pair names broke or were silently cut in SPSS and Stata files.

valid_name <- function(nm, limit) {
  grepl("^[A-Za-z][A-Za-z0-9_]*$", nm) && nchar(nm, "bytes") <= limit
}

export_demo <- function(name, ext) {
  demo <- sframe_demo(name)
  path <- tempfile(fileext = ext)
  msgs <- character()
  out <- withCallingHandlers(
    sframe_export_labelled(demo$responses, demo$instrument, path),
    message = function(m) {
      msgs <<- c(msgs, conditionMessage(m))
      invokeRestart("muffleMessage")
    })
  list(path = out, msgs = msgs, demo = demo)
}

test_that("D10: matrix_likert and mcdm_choice export to SPSS and Stata", {
  skip_if_not_installed("haven")
  for (nm in c("matrix_likert", "mcdm_choice")) {
    for (ext in c(".sav", ".dta")) {
      r <- export_demo(nm, ext)
      back <- if (ext == ".sav") haven::read_sav(r$path) else haven::read_dta(r$path)
      limit <- if (ext == ".sav") 64 else 32
      expect_true(all(vapply(names(back), valid_name, logical(1), limit = limit)),
                  info = paste(nm, ext))
      expect_equal(nrow(back), nrow(r$demo$responses))
      expect_equal(ncol(back), ncol(r$demo$responses))
      ren <- attr(r$path, "renamed")
      if (nm == "mcdm_choice" && ext == ".sav") {
        expect_length(r$msgs, 0)
        expect_null(ren)
      } else {
        expect_length(r$msgs, 1)
        expect_s3_class(ren, "data.frame")
        expect_true(all(c("kind", "column", "old", "new") %in% names(ren)))
        expect_true(all(ren$old != ren$new))
      }
    }
  }
})

test_that("D10: renamed names stay unique and labels are kept", {
  skip_if_not_installed("haven")
  ins <- sf_instrument("Dup", components = list(
    sf_item("q", "Question", type = "matrix", choice_set = "s",
            matrix_items = c("Row one!", "Row one?")),
    sf_choices("s", values = 1:2, labels = c("No", "Yes"))))
  demo_names <- sframe_item_expansion_columns(ins, ins$items)
  d <- as.data.frame(stats::setNames(rep(list(c(1, 2)), length(demo_names)),
                                     demo_names), check.names = FALSE)
  path <- tempfile(fileext = ".dta")
  out <- suppressMessages(sframe_export_labelled(d, ins, path))
  back <- haven::read_dta(out)
  expect_equal(anyDuplicated(names(back)), 0L)
  expect_identical(attr(back[[1]], "label"), "Question: Row one!")
})

test_that("D10: a long variable label is cut for Stata and reported", {
  skip_if_not_installed("haven")
  long <- strrep("word ", 30)
  ins <- sf_instrument("Long", components = list(
    sf_item("q1", long, type = "single_choice", choice_set = "s"),
    sf_choices("s", values = 1:2, labels = c("No", "Yes"))))
  d <- data.frame(q1 = c(1, 2))
  path <- tempfile(fileext = ".dta")
  msgs <- character()
  out <- withCallingHandlers(
    sframe_export_labelled(d, ins, path),
    message = function(m) {
      msgs <<- c(msgs, conditionMessage(m))
      invokeRestart("muffleMessage")
    })
  expect_length(msgs, 1)
  expect_lte(nchar(attr(haven::read_dta(out)$q1, "label")), 80)
  expect_true("variable label" %in% attr(out, "renamed")$kind)
})

test_that("D10: nothing to change means no message and no attribute rows", {
  skip_if_not_installed("haven")
  path <- tempfile(fileext = ".sav")
  msgs <- character()
  out <- withCallingHandlers(
    sframe_export_labelled(data.frame(fmt = c("online", "hybrid")),
      sf_instrument("T", components = list(
        sf_item("fmt", "Format", type = "single_choice", choice_set = "f"),
        sf_choices("f", values = c("online", "hybrid"),
                   labels = c("Online", "Hybrid")))), path),
    message = function(m) {
      msgs <<- c(msgs, conditionMessage(m))
      invokeRestart("muffleMessage")
    })
  expect_length(msgs, 0)
  expect_null(attr(out, "renamed"))
})
