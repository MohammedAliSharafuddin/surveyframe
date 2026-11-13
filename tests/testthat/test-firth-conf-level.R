# FR-36 (Fable sitting 2), Session CF-B: the Firth block reads conf_level as
# well as conf.level.

test_that("conf_level = 0.90 gives a 90% interval", {
  skip_if_not_installed("logistf")
  set.seed(6); n <- 40; x <- rnorm(n)
  d <- data.frame(x = x, out = ifelse(x + rlogis(n) > 0, 1, 0))
  run <- function(opts) cfb_block(d, "firth_logistic", list(predictors = "x", dependent = "out"),
                                  cfb_num("x"), cfb_num("out"), options = opts)
  r90 <- run(list(conf_level = 0.90))
  rdot <- run(list(conf.level = 0.90))
  r95 <- run(list())
  expect_equal(r90$conf_level, 0.90)
  expect_equal(r90$conf_int, rdot$conf_int)
  expect_lt(diff(r90$conf_int[2, ]), diff(r95$conf_int[2, ]))
  expect_null(r90$options_ignored)
})
