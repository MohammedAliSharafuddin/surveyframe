# tests/testthat/test-studio-internal-helpers.R
#
# Naming decision 6. Studio's app.R runs under the package namespace and the
# report template prints content render_report() computed, so the 11
# helpers only they called are internal, with no accessor. Studio starting
# and the template rendering against the installed build are checked by
# test-studio-screens-browser.R and the Quarto tests in the slow tier.

internal_now <- c(
  "sframe_plot_item_chart", "sframe_plot_scale_chart",
  "sframe_draw_likert_diverging", "sframe_draw_mosaic",
  "sframe_likert_scale_groups", "sframe_codebook_items_display",
  "sframe_builder_empty_state", "sframe_builder_state_from_instrument",
  "sframe_builder_validate_draft", "sframe_result_supplement",
  "sframe_demo_branding")

test_that("the 11 Studio and template helpers are not exported", {
  ns <- readLines(sframe_installed_path("NAMESPACE"))
  for (fn in internal_now) {
    expect_false(paste0("export(", fn, ")") %in% ns, label = fn)
    expect_true(exists(fn, envir = asNamespace("surveyframe"), inherits = FALSE),
                label = fn)
  }
})

test_that("Studio still builds and the template names no internal helper", {
  skip_if_not_installed("shiny")
  expect_s3_class(sframe_studio_app(), "shiny.appobj")
  qmd <- sframe_installed_text("inst", "templates", "report.qmd")
  for (fn in internal_now) expect_false(grepl(fn, qmd, fixed = TRUE), label = fn)
})
