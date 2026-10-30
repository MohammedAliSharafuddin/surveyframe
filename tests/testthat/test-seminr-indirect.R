# tests/testthat/test-seminr-indirect.R
# Every declared sf_indirect() reaches both the lavaan syntax and the seminr
# script, where it is tested with specific_effect_significance().

indirect_models <- function() {
  cons <- function(mode) list(
    sf_construct("X", items = paste0("x", 1:3), mode = mode),
    sf_construct("M1", items = paste0("m", 1:3), mode = mode),
    sf_construct("M2", items = paste0("n", 1:3), mode = mode),
    sf_construct("Y", items = paste0("y", 1:3), mode = mode)
  )
  paths <- list(sf_path("X", "M1"), sf_path("M1", "Y"),
                sf_path("X", "M2"), sf_path("M2", "Y"), sf_path("X", "Y"))
  ind <- list(sf_indirect("X", through = "M1", to = "Y"),
              sf_indirect("X", through = "M2", to = "Y"))
  list(
    pls = sf_model("p", type = "pls_sem", engine = "seminr",
                   constructs = cons("composite"), paths = paths,
                   indirect = ind),
    cb = sf_model("c", type = "cb_sem", engine = "lavaan",
                  constructs = cons("reflective"), paths = paths,
                  indirect = ind)
  )
}

test_that("two declared indirect effects appear in the lavaan and seminr syntax", {
  ms <- indirect_models()
  lav <- sem_lavaan_syntax(ms$cb)
  expect_match(lav, "indirect_X_M1_Y :=", fixed = TRUE)
  expect_match(lav, "indirect_X_M2_Y :=", fixed = TRUE)
  sem <- seminr_syntax(ms$pls)
  expect_match(sem, 'specific_effect_significance(boot_model, from = "X", through = "M1", to = "Y", alpha = 0.05)', fixed = TRUE)
  expect_match(sem, 'specific_effect_significance(boot_model, from = "X", through = "M2", to = "Y", alpha = 0.05)', fixed = TRUE)
})

test_that("a serial mediation passes every mediator to seminr", {
  m <- indirect_models()$pls
  m$structural$paths <- c(m$structural$paths, list(sf_path("M1", "M2")))
  m$structural$indirect <- list(sf_indirect("X", through = c("M1", "M2"), to = "Y"))
  expect_match(seminr_syntax(m),
               'through = c("M1", "M2"), to = "Y"', fixed = TRUE)
})

test_that("a model with no indirect effects writes no effect test", {
  m <- indirect_models()$pls
  m$structural$indirect <- list()
  expect_false(grepl("specific_effect_significance", seminr_syntax(m)))
})

test_that("the seminr script with indirect effects parses and names a real function", {
  skip_if_not_installed("seminr")
  code <- seminr_syntax(indirect_models()$pls)
  expect_no_error(parse(text = code))
  expect_true(is.function(seminr::specific_effect_significance))
})
