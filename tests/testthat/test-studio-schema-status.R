# tests/testthat/test-studio-schema-status.R
#
# Open Instrument's status comes from validate_sframe() run on the open
# instrument, never from the stored meta$validated, which is a cache only
# (owner 2026-11-10, Codex P1-09). The valid two_group demo showed "Draft"
# and "Status: fix in Design" with no reason given. studio_schema_status() is
# parsed from app.R without starting the app.

studio_status_env <- function() {
  app <- system.file("shiny", "app.R", package = "surveyframe")
  skip_if(!nzchar(app), "studio app not available")
  exprs <- parse(app, keep.source = FALSE)
  pick <- Filter(function(e) is.call(e) && identical(e[[1]], as.name("<-")) &&
                   identical(e[[2]], as.name("studio_schema_status")), exprs)
  expect_length(pick, 1)
  env <- new.env(parent = asNamespace("surveyframe"))
  eval(pick[[1]], envir = env)
  env
}

test_that("a valid instrument reads Schema valid whatever its stored flag says (P1-09)", {
  env <- studio_status_env()
  instr <- sframe_demo("two_group")$instrument
  for (flag in list(TRUE, FALSE, NULL)) {
    instr$meta$validated <- flag
    st <- env$studio_schema_status(instr)
    expect_true(st$valid)
    expect_identical(st$label, "Schema valid")
    expect_identical(st$n, 0L)
  }
})

test_that("an invalid instrument reads Fix in Design, with the count and the first problem, though its flag says valid (P1-09)", {
  env <- studio_status_env()
  instr <- sframe_demo("two_group")$instrument
  type_2 <- instr$items[[2]]$type
  instr$items[[1]]$type <- "nonsense"
  instr$items[[2]]$type <- "nonsense"
  instr$meta$validated <- TRUE
  st <- env$studio_schema_status(instr)
  expect_false(st$valid)
  expect_identical(st$label, "Fix in Design")
  expect_identical(st$n, 2L)
  expect_match(st$detail, "^2 problems\\. The first: Item 'format' has the unknown type 'nonsense'")
  instr$items[[2]]$type <- type_2
  expect_match(env$studio_schema_status(instr)$detail, "^1 problem\\. The first: ")
})
