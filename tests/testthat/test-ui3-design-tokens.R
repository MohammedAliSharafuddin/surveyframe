# tests/testthat/test-ui3-design-tokens.R
#
# Session UI-3, item 1: 1 shared stylesheet of design tokens for Studio and
# the builder. Studio links it, the builder inlines it, and neither app's own
# styles hold a colour literal outside a variable definition.

ui3_read <- function(...) {
  p <- sframe_installed_path(...)
  skip_if(is.na(p) || !nzchar(p) || !file.exists(p), "shipped asset not found")
  readLines(p, warn = FALSE, encoding = "UTF-8")
}
ui3_luminance <- function(hex) {
  v <- grDevices::col2rgb(hex)[, 1] / 255
  v <- ifelse(v <= 0.03928, v / 12.92, ((v + 0.055) / 1.055)^2.4)
  sum(c(0.2126, 0.7152, 0.0722) * v)
}
ui3_ratio <- function(a, b) {
  l <- sort(c(ui3_luminance(a), ui3_luminance(b)))
  (l[2] + 0.05) / (l[1] + 0.05)
}
ui3_colour_literals <- function(lines) {
  grep("#[0-9a-fA-F]{3,8}\\b|rgba?\\(|hsla?\\(", lines, value = TRUE)
}

test_that("the token file defines 1 primary colour that carries white text (UI-3)", {
  css <- ui3_read("inst", "builder", "design_tokens.css")
  hex <- function(name) {
    hit <- grep(paste0("^\\s*", name, ":\\s*#[0-9a-fA-F]{6};"), css, value = TRUE)
    expect_length(hit, 1)
    sub(".*(#[0-9a-fA-F]{6}).*", "\\1", hit)
  }
  primary <- hex("--sf-primary")
  expect_gte(ui3_ratio(primary, "#ffffff"), 4.5)
  expect_gte(ui3_ratio(hex("--sf-primary-hover"), "#ffffff"), 4.5)
  for (t in c("--sf-ink", "--sf-text-2", "--sf-text-3")) {
    expect_gte(ui3_ratio(hex(t), hex("--sf-canvas")), 4.5)
  }
  for (t in c("--sf-nav-text", "--sf-nav-muted")) {
    expect_gte(ui3_ratio(hex(t), hex("--sf-nav")), 4.5)
  }
})

test_that("Studio links the tokens and its styles hold no colour literal (UI-3)", {
  src <- ui3_read("inst", "shiny", "app.R")
  expect_true(any(grepl('href = studio_asset_src("design_tokens.css")', src, fixed = TRUE)))
  a <- grep('tags$style(HTML("', src, fixed = TRUE)[1]
  b <- a + which(src[(a + 1):length(src)] == '    "))')[1]
  expect_identical(ui3_colour_literals(src[a:b]), character(0))
  # The button levels live in the token file, so Studio's old stylesheet went.
  expect_false(file.exists(file.path(dirname(sframe_installed_path("inst", "shiny", "app.R")),
                                     "www", "studio-actions.css")))
  # The charts R draws take their colours from the token file too.
  expect_true(any(grepl('^dash_theme <- studio_token\\("--sf-primary"', src)))
  expect_false(any(grepl("#16B3B1", src, fixed = TRUE)))
})

test_that("the builder's own styles take every colour from a variable (UI-3)", {
  b <- ui3_read("inst", "builder", "survey_builder.html")
  end_tokens <- grep("<!-- DESIGN_TOKENS_END -->", b, fixed = TRUE)
  expect_length(end_tokens, 1)
  st <- end_tokens + which(b[(end_tokens + 1):length(b)] == "<style>")[1]
  en <- st + which(b[(st + 1):length(b)] == "</style>")[1]
  css <- b[st:en]
  root_end <- which(css == "}")[1]
  # Inside :root the builder's own names point at the shared tokens, apart
  # from its item-type hues and badge colours.
  expect_true(any(grepl("--cp:var(--sf-primary);", css[seq_len(root_end)], fixed = TRUE)))
  expect_identical(ui3_colour_literals(css[-seq_len(root_end)]), character(0))
  tools <- ui3_read("inst", "builder", "field_tools.js")
  lit <- regmatches(tools, gregexpr("(var\\(--sf-[a-z0-9-]+,)?(?<!&)#[0-9a-fA-F]{3,6}\\b", tools, perl = TRUE))
  lit <- unlist(lit)
  expect_gt(length(lit), 0)
  expect_true(all(startsWith(lit, "var(--sf-")))
})
