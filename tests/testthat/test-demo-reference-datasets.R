# tests/testthat/test-demo-reference-datasets.R
# Naming principle 5, one way into the demos. The tourism-services and
# input-types datasets load through sframe_demo() like the teaching demos, and
# sframe_list_demos() lists them apart, with focus "reference".

test_that("sframe_demo() loads the 2 reference datasets", {
  for (nm in c("tourism_services", "input_types")) {
    d <- sframe_demo(nm)
    expect_s3_class(d$instrument, "sframe")
    expect_s3_class(d$responses, "data.frame")
    expect_true(file.exists(d$instrument_path))
    expect_true(file.exists(d$responses_path))
    expect_true(nrow(d$responses) > 0)
  }
})

test_that("the reference datasets keep the loader the old functions used", {
  d <- sframe_demo("tourism_services")
  expect_identical(basename(d$instrument_path), "tourism_services_demo.sframe")
  expect_identical(basename(d$responses_path), "tourism_services_responses.csv")
  # submitted_at is read as the submission time, not as a meta column
  ref <- read_responses(
    d$responses_path, read_sframe(d$instrument_path),
    respondent_id = "respondent_id", submitted_at = "submitted_at",
    meta_cols = "started_at")
  expect_identical(d$responses, ref)

  d <- sframe_demo("input_types")
  expect_identical(basename(d$instrument_path),
                   "surveyframe_input_types_demo.sframe")
  ref <- read_responses(
    d$responses_path, read_sframe(d$instrument_path),
    respondent_id = "respondent_id", submitted_at = "submitted_at",
    meta_cols = "started_at", strict = TRUE)
  expect_identical(d$responses, ref)
})

test_that("branded = TRUE works on a reference dataset", {
  d <- sframe_demo("input_types", branded = TRUE)
  expect_identical(d$instrument$render, unclass(sframe_demo_branding()))
})

test_that("sframe_list_demos() lists the reference datasets apart", {
  idx <- sframe_list_demos()
  ref <- idx[idx$focus == "reference", ]
  expect_setequal(ref$name, c("tourism_services", "input_types"))
  # listed after the teaching demos
  expect_identical(utils::tail(idx$name, 2), ref$name)
  expect_identical(sum(idx$focus != "reference"), 22L)
})

test_that("the old loaders forward to sframe_demo()", {
  expect_identical(sframe_demo_data()$responses,
                   sframe_demo("tourism_services")$responses)
  expect_identical(sframe_input_types_demo_data()$instrument,
                   sframe_demo("input_types")$instrument)
  old <- options(surveyframe.warn_superseded = TRUE)
  on.exit(options(old))
  rlang::reset_warning_verbosity("surveyframe_superseded_sframe_demo_data()")
  expect_warning(sframe_demo_data(), "sframe_demo\\(\"tourism_services\"\\)",
                 class = "sframe_superseded_warning")
})
