# tests/testthat/test-choices-ordered.R
#
# SurveyBuilder tagged every single_choice item NOM, ordinal ones included,
# so a frequency or an education item could not reach the methods for
# ordered categories. 0.4.3 shipped that as a known limitation. A choice set
# can now declare `ordered = TRUE`, and the builder and SurveyStudio read a
# single_choice item on such a set as ordinal.

ordered_instrument <- function() {
  sf_instrument("Ordered", components = list(
    sf_item("freq", "How often do you attend?", type = "single_choice", choice_set = "often"),
    sf_item("fmt", "Preferred format", type = "single_choice", choice_set = "fmt"),
    sf_choices("often", values = c("1", "2", "3"),
               labels = c("Rarely", "Sometimes", "Often"), ordered = TRUE),
    sf_choices("fmt", values = c("a", "b"), labels = c("Online", "In person"))))
}

test_that("ordered is stored only when TRUE", {
  ins <- ordered_instrument()
  expect_true(ins$choices[[1]]$ordered)
  expect_false("ordered" %in% names(ins$choices[[2]]))
  expect_error(sf_choices("x", values = "1", labels = "A", ordered = NA),
               "`ordered` must be TRUE or FALSE")
})

test_that("ordered survives a write and a read, and an unordered set writes no field", {
  path <- tempfile(fileext = ".sframe")
  write_sframe(ordered_instrument(), path)
  raw <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  expect_true(raw$choices[[1]]$ordered)
  expect_false("ordered" %in% names(raw$choices[[2]]))
  back <- read_sframe(path)
  expect_true(back$choices[[1]]$ordered)
  expect_null(back$choices[[2]]$ordered)
})

test_that("an instrument without ordered sets hashes as before", {
  ins <- sframe_demo("two_group")$instrument
  path <- tempfile(fileext = ".sframe")
  write_sframe(ins, path)
  expect_identical(sframe_content_hash(read_sframe(path)), sframe_content_hash(ins))
  expect_false(any(grepl("\"ordered\"", readLines(path), fixed = TRUE)))
})

test_that("the validator refuses an ordered flag that is no TRUE or FALSE", {
  ins <- ordered_instrument()
  ins$choices[[1]]$ordered <- "yes"
  v <- validate_sframe(ins, strict = FALSE)
  expect_match(unlist(v$problems), "Choice set 'often': `ordered` has to be TRUE or FALSE",
               fixed = TRUE, all = FALSE)
})

test_that("SurveyStudio reads an item on an ordered set as ordinal and keeps the flag", {
  app <- system.file("shiny", "app.R", package = "surveyframe")
  skip_if(!nzchar(app) || !file.exists(app), "studio app not available")
  txt <- readLines(app, warn = FALSE)
  from <- grep("^studio_level_meta <- function", txt)[1]
  to <- grep("^studio_flatten_roles <- function", txt)[1]
  env <- new.env()
  eval(parse(text = paste(txt[from:(to - 1)], collapse = "\n")), envir = env)
  catalog <- env$studio_variable_catalog(ordered_instrument())
  levels <- vapply(catalog, function(v) v$code, character(1))
  names(levels) <- vapply(catalog, function(v) v$id, character(1))
  expect_identical(unname(levels[c("freq", "fmt")]), c("ORD", "NOM"))
  # The rebuild path a Studio session takes keeps the flag.
  plain <- unclass(ordered_instrument()$choices[[1]])
  expect_true(surveyframe:::sframe_builder_as_choice(plain)$ordered)
})

test_that("SurveyBuilder tags an item on an ordered set ORD", {
  ctx <- builder_context()
  builder_open(ctx, ordered_instrument())
  expect_identical(ctx$eval("varLevel('freq').code"), "ORD")
  expect_identical(ctx$eval("varLevel('fmt').code"), "NOM")
})

test_that("SurveyBuilder marks a set ordered from the inspector, and R reads it", {
  ctx <- builder_context()
  builder_open(ctx, ordered_instrument())
  ctx$eval("selId = 'fmt'; setCsOrdered(true);")
  expect_identical(ctx$eval("varLevel('fmt').code"), "ORD")
  back <- read_sframe(builder_save(ctx), validate = FALSE)
  fmt <- Filter(function(cs) identical(cs$id, "fmt"), back$choices)[[1]]
  expect_true(fmt$ordered)
  ctx$eval("setCsOrdered(false);")
  back <- read_sframe(builder_save(ctx), validate = FALSE)
  fmt <- Filter(function(cs) identical(cs$id, "fmt"), back$choices)[[1]]
  expect_null(fmt$ordered)
})
