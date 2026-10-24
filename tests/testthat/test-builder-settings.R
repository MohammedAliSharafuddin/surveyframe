# tests/testthat/test-builder-settings.R
#
# SurveyBuilder's Survey settings dialog, run under V8 (helper-v8-builder.R).
#
# Save settings wrote every General, Welcome and Thank You field from its
# input, so an absent author list became "" and absent screens were filled
# with their defaults. On an amended instrument that is a content change
# nobody made and nobody disclosed, and write_sframe() then refused the file.
# Opening a file did the same on a smaller scale, adding empty welcome,
# thank-you and header objects. And R writes an empty render as [], which the
# builder held as an array, so every setting saved into it vanished from the
# saved file.

# An instrument with one recorded amendment and a render holding a theme
# alone, so anything the builder adds to it is a change.
amended_with_theme <- function() {
  ins <- sframe_demo("first_survey")$instrument
  revised <- ins
  revised$render <- list(theme = "#2563eb")
  amend_sframe(ins, revised, "other", "Theme", tier = "pipeline")
}

settings_save <- function(ctx, inputs = list()) {
  ctx$call("openSettings", "meta")
  for (id in names(inputs)) {
    ctx$eval(sprintf("document.getElementById(%s).value = %s;",
                     jsonlite::toJSON(id, auto_unbox = TRUE),
                     jsonlite::toJSON(inputs[[id]], auto_unbox = TRUE)))
  }
  ctx$call("saveSettings")
}

test_that("opening and saving a file changes none of its content", {
  ins <- amended_with_theme()
  ctx <- builder_context()
  builder_open(ctx, ins)
  back <- read_sframe(builder_save(ctx))
  expect_identical(sframe_content_hash(back), sframe_content_hash(ins))
  expect_identical(names(back$render), "theme")
})

test_that("Save settings with nothing edited changes none of the content", {
  ins <- amended_with_theme()
  ctx <- builder_context()
  builder_open(ctx, ins)
  settings_save(ctx)
  back <- read_sframe(builder_save(ctx))
  expect_identical(sframe_content_hash(back), sframe_content_hash(ins))
  expect_null(back$meta$authors)
  # An amended instrument the builder left alone takes a further write.
  expect_no_error(write_sframe(back, tempfile(fileext = ".sframe")))
  expect_match(builder_toasts(ctx)$msg, "No settings changed", fixed = TRUE,
               all = FALSE)
})

test_that("Save settings writes the field the user changed and only that", {
  ins <- amended_with_theme()
  ctx <- builder_context()
  builder_open(ctx, ins)
  settings_save(ctx, list(`s-authors` = "Rahman, A."))
  back <- read_sframe(builder_save(ctx), validate = FALSE)
  expect_identical(back$meta$authors, "Rahman, A.")
  expect_identical(names(back$render), "theme")
  expect_identical(back$meta$description, ins$meta$description)
})

test_that("an emptied author list is saved as absent, as R writes it", {
  ins <- sframe_demo("first_survey")$instrument
  ins$meta$authors <- "Rahman, A."
  ctx <- builder_context()
  builder_open(ctx, ins, new_instrument = TRUE)
  settings_save(ctx, list(`s-authors` = ""))
  back <- read_sframe(builder_save(ctx), validate = FALSE)
  expect_null(back$meta$authors)
})

test_that("a setting saved on an instrument with an empty render is kept", {
  ins <- sframe_demo("first_survey")$instrument
  expect_length(ins$render, 0L)
  ctx <- builder_context()
  builder_open(ctx, ins)
  settings_save(ctx, list(`s-theme` = "#aa0000", `s-wt` = "Welcome"))
  back <- read_sframe(builder_save(ctx), validate = FALSE)
  expect_identical(back$render$theme, "#aa0000")
  expect_identical(back$render$welcome$title, "Welcome")
  # The welcome screen gains the title alone, no defaults alongside it.
  expect_identical(names(back$render$welcome), "title")
})
