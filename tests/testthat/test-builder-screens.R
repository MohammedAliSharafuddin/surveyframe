# tests/testthat/test-builder-screens.R
#
# UX-10: the welcome and thank-you pages are entries at the ends of
# SurveyBuilder's question list, with their editor on the right, where they
# were tabs of the Survey settings dialog. Run under V8 (helper-v8-builder.R).
# A page left alone keeps the content hash, and an edit writes that field and
# nothing else.

screens_instrument <- function() {
  src <- tempfile(fileext = ".sframe")
  ins <- sframe_demo("first_survey")$instrument
  ins$render <- list(theme = "#2563eb")
  ins$meta$version <- "1.0.1"
  write_sframe(ins, src, new_instrument = TRUE)
  read_sframe(src)
}

test_that("the list starts with the welcome page and ends with the thank-you page", {
  ctx <- builder_context()
  builder_open(ctx, screens_instrument())
  ctx$call("renderItemList")
  html <- ctx$get("document.getElementById('itemList').innerHTML")
  rows <- regmatches(html, gregexpr('data-id="[^"]+"', html))[[1]]
  expect_identical(rows[1], 'data-id="__welcome"')
  expect_identical(rows[length(rows)], 'data-id="__thankyou"')
  expect_match(html, "Welcome page", fixed = TRUE)
  expect_match(html, "Thank-you page", fixed = TRUE)
})

test_that("opening both pages and leaving them keeps the content hash", {
  ins <- screens_instrument()
  ctx <- builder_context()
  builder_open(ctx, ins)
  for (id in c("__welcome", "__thankyou")) {
    ctx$call("selItem", id)
    for (fid in c("s-wt", "s-wi", "s-wc", "s-wreq", "s-wsl", "s-tym", "s-tyu", "s-tydl")) {
      ctx$call("updScreen", fid)
    }
  }
  back <- read_sframe(builder_save(ctx))
  expect_identical(sframe_content_hash(back), sframe_content_hash(ins))
  expect_identical(names(back$render), "theme")
})

test_that("an edit on a page writes that field alone", {
  ctx <- builder_context()
  builder_open(ctx, screens_instrument())
  ctx$call("selItem", "__welcome")
  ctx$eval("document.getElementById('s-wi').value = 'This study asks about your visit.';")
  ctx$call("updScreen", "s-wi")
  ctx$call("selItem", "__thankyou")
  ctx$eval("document.getElementById('s-tydl').checked = true;")
  ctx$call("updScreen", "s-tydl")
  back <- read_sframe(builder_save(ctx), validate = FALSE)
  expect_identical(back$render$welcome, list(intro_text = "This study asks about your visit."))
  expect_identical(back$render$thankyou, list(show_download = TRUE))
})

test_that("Survey settings has no Welcome or Thank You tab", {
  src <- sframe_installed_text("inst", "builder", "survey_builder.html")
  expect_false(grepl('id="st-welcome"', src, fixed = TRUE))
  expect_false(grepl('id="st-thankyou"', src, fixed = TRUE))
  expect_false(grepl('id="sp-welcome"', src, fixed = TRUE))
  # Inside Studio, its Collect and References screens take those tabs' place.
  expect_match(src, "studioGoto('collect')", fixed = TRUE)
  expect_match(src, "studioGoto('references')", fixed = TRUE)
})
