# tests/testthat/test-citation-picker.R
#
# The shared citation picker (inst/builder/citation_picker.js), its parsing,
# filtering, insertion and unknown-key check, run under V8 on the references
# fixture (helper-references-fixture.R). The popover itself is checked in a
# real Chrome in test-builder-citation-browser.R.

picker_context <- function() {
  skip_if_not_installed("V8")
  ctx <- V8::v8()
  ctx$eval(sframe_installed_text("inst", "builder", "citation_picker.js"))
  refs <- lapply(sframe_get_references(sframe_references_fixture()), unclass)
  ctx$assign("REFS", unname(refs), auto_unbox = TRUE)
  ctx
}

cp <- function(ctx, code) ctx$get(paste0("(function(){var P=SurveyframeCitationPicker;return ", code, ";})()"))

test_that("each author shape displays with its year, or n.d. without one", {
  ctx <- picker_context()
  n <- cp(ctx, "REFS.map(P.normalise)")
  expect_identical(n$key, c("likert_1932", "parasuraman_1988", "rcore_2024", "max_nd"))
  expect_identical(n$authorText, c("Likert", "Parasuraman et al.", "R Core Team", "Max"))
  expect_identical(n$year, c("1932", "1988", "2024", "n.d."))
  expect_identical(cp(ctx, "REFS.map(P.narrativeText)"),
                   c("Likert (1932)", "Parasuraman et al. (1988)",
                     "R Core Team (2024)", "Max (n.d.)"))
  expect_identical(cp(ctx, "P.parentheticalText(REFS[0])"), "(Likert, 1932)")
})

test_that("filtering matches every word typed against key, author, year and title", {
  ctx <- picker_context()
  expect_identical(cp(ctx, "P.filter(REFS,'').length"), 4L)
  expect_identical(cp(ctx, "P.filter(REFS,'zeithaml').map(function(x){return x.key;})"), "parasuraman_1988")
  expect_identical(cp(ctx, "P.filter(REFS,'1932 attitudes').map(function(x){return x.key;})"), "likert_1932")
  expect_identical(cp(ctx, "P.filter(REFS,'core R').map(function(x){return x.key;})"), "rcore_2024")
  expect_identical(cp(ctx, "P.filter(REFS,'nothing here').length"), 0L)
})

test_that("@ and /cite open the picker only where a citation can start", {
  ctx <- picker_context()
  tr <- function(text) cp(ctx, sprintf("P.trigger(%s,%d)",
    jsonlite::toJSON(text, auto_unbox = TRUE), nchar(text)))
  expect_identical(tr("As shown by @")$start, 12L)
  expect_identical(tr("@")$start, 0L)
  expect_identical(tr("see [@")$start, 5L)
  expect_identical(tr("see [@a; @")$start, 9L)
  expect_identical(tr("use /cite")$start, 4L)
  expect_null(tr("mail me@"))
  expect_null(tr("run `x @"))
  expect_null(tr("x/cite"))
})

test_that("a pick inserts @key, [@key] or, inside an open bracket, ; @key", {
  ctx <- picker_context()
  ins <- function(text, start, end, style = "narrative") {
    cp(ctx, sprintf("P.insertion(%s,%d,%d,'likert_1932','%s').text",
      jsonlite::toJSON(text, auto_unbox = TRUE), start, end, style))
  }
  expect_identical(ins("As shown by @ here", 12, 13), "As shown by @likert_1932 here")
  expect_identical(ins("Agreement @", 10, 11, "parenthetical"), "Agreement [@likert_1932]")
  expect_identical(ins("Scale /cite.", 6, 11, "parenthetical"), "Scale [@likert_1932].")
  # Inside [...] the style is not asked: a further key joins the bracket.
  expect_identical(ins("[@max_nd]", 8, 8), "[@max_nd; @likert_1932]")
  expect_identical(ins("[@max_nd; @]", 10, 11), "[@max_nd; @likert_1932]")
  expect_identical(ins("[see @]", 5, 6), "[see @likert_1932]")
  # A button press after a word keeps a space before the key.
  expect_identical(ins("Likert", 6, 6), "Likert @likert_1932")
})

test_that("a key with no reference is reported, once, outside code", {
  ctx <- picker_context()
  bad <- function(text, extra = character()) {
    cp(ctx, sprintf("P.unknownKeys(%s,REFS.map(function(r){return r.id;}).concat(%s))",
      jsonlite::toJSON(text, auto_unbox = TRUE), jsonlite::toJSON(extra)))
  }
  expect_length(bad("As @likert_1932 found [@max_nd; -@rcore_2024]."), 0L)
  expect_identical(bad("[@smith_2000; @likert_1932] and @smith_2000 again"), "smith_2000")
  expect_identical(bad("Ends with a full stop @nobody."), "nobody")
  expect_length(bad("Write to a@b.org, or run `@x` and\n```\n@y\n```"), 0L)
  expect_length(bad("Built in [@cohen_1988]", "cohen_1988"), 0L)
  expect_identical(cp(ctx, "P.message"),
                   "No reference with this key. Add it under References.")
})

test_that("the picker script is ASCII, as the builder's JavaScript must be", {
  js <- sframe_installed_text("inst", "builder", "citation_picker.js")
  expect_false(grepl("[^\\x01-\\x7f]", js, perl = TRUE))
})
