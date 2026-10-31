# tests/testthat/test-seminr-indirect.R
# Every declared sframe_indirect_effect() reaches both the lavaan syntax and the seminr
# script, where it is tested with specific_effect_significance().

indirect_models <- function() {
  cons <- function(mode) list(
    sframe_construct("X", items = paste0("x", 1:3), mode = mode),
    sframe_construct("M1", items = paste0("m", 1:3), mode = mode),
    sframe_construct("M2", items = paste0("n", 1:3), mode = mode),
    sframe_construct("Y", items = paste0("y", 1:3), mode = mode)
  )
  paths <- list(sframe_path("X", "M1"), sframe_path("M1", "Y"),
                sframe_path("X", "M2"), sframe_path("M2", "Y"), sframe_path("X", "Y"))
  ind <- list(sframe_indirect_effect("X", through = "M1", to = "Y"),
              sframe_indirect_effect("X", through = "M2", to = "Y"))
  list(
    pls = sframe_model_spec("p", type = "pls_sem", engine = "seminr",
                   constructs = cons("composite"), paths = paths,
                   indirect = ind),
    cb = sframe_model_spec("c", type = "cb_sem", engine = "lavaan",
                  constructs = cons("reflective"), paths = paths,
                  indirect = ind)
  )
}

test_that("two declared indirect effects appear in the lavaan and seminr syntax", {
  ms <- indirect_models()
  lav <- sframe_syntax_sem(ms$cb)
  expect_match(lav, "indirect_X_M1_Y :=", fixed = TRUE)
  expect_match(lav, "indirect_X_M2_Y :=", fixed = TRUE)
  sem <- sframe_syntax_pls(ms$pls)
  expect_match(sem, 'specific_effect_significance(boot_model, from = "X", through = "M1", to = "Y", alpha = 0.05)', fixed = TRUE)
  expect_match(sem, 'specific_effect_significance(boot_model, from = "X", through = "M2", to = "Y", alpha = 0.05)', fixed = TRUE)
})

test_that("a serial mediation passes every mediator to seminr", {
  m <- indirect_models()$pls
  m$structural$paths <- c(m$structural$paths, list(sframe_path("M1", "M2")))
  m$structural$indirect <- list(sframe_indirect_effect("X", through = c("M1", "M2"), to = "Y"))
  expect_match(sframe_syntax_pls(m),
               'through = c("M1", "M2"), to = "Y"', fixed = TRUE)
})

test_that("a model with no indirect effects writes no effect test", {
  m <- indirect_models()$pls
  m$structural$indirect <- list()
  expect_false(grepl("specific_effect_significance", sframe_syntax_pls(m)))
})

test_that("the seminr script with indirect effects parses and names a real function", {
  skip_if_not_installed("seminr")
  code <- sframe_syntax_pls(indirect_models()$pls)
  expect_no_error(parse(text = code))
  expect_true(is.function(seminr::specific_effect_significance))
})
