# tests/testthat/test-demo-branding-print.R
#
# sframe_demo_branding() printed a raw nested list, which a first-time user
# read as a failed demo (todo_0.4.3.md, section 2). It now prints each
# setting as a respondent meets it, and stays a plain list wherever it
# becomes an instrument's render block.

test_that("the branding prints its settings and where to see them applied", {
  out <- capture.output(print(sframe_demo_branding()))
  expect_identical(out[1], "<sframe demo branding>")
  expect_match(out, "Theme: +#2563eb", all = FALSE)
  expect_match(out, "Welcome: +\"Thank you for coming\"", all = FALSE)
  expect_match(out, "Consent: .*, required$", all = FALSE)
  expect_match(out, "preview_demo(\"two_group\")", fixed = TRUE, all = FALSE)
  expect_no_match(out, "^\\$", all = TRUE)
})

test_that("printing returns the branding unchanged", {
  b <- sframe_demo_branding()
  capture.output(v <- withVisible(print(b)))
  expect_false(v$visible)
  expect_identical(v$value, b)
})

test_that("the branding is stored as a plain list in an instrument", {
  ins <- sf_instrument("Branded", components = list(sf_item("q1", "Q", type = "text")),
                       render = sframe_demo_branding())
  expect_identical(class(ins$render), "list")
  expect_identical(class(sframe_demo("two_group", branded = TRUE)$instrument$render), "list")
  path <- tempfile(fileext = ".sframe")
  write_sframe(ins, path)
  expect_identical(read_sframe(path)$render$theme, "#2563eb")
})
