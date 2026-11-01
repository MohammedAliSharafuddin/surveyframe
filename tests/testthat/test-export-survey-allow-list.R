# tests/testthat/test-export-survey-allow-list.R
#
# A shared survey carries only what its page reads (session 7). export_survey()
# embedded the whole instrument minus its hash, so anyone given the link could
# read the instrument's references, analysis plan, hypotheses and amendment
# history, and the answers to its attention checks, from the page source. The builder's Preview embeds the same list,
# checked in test-builder-preview-browser.R.

planted_instrument <- function() {
  x <- sframe_demo("likert_scale")$instrument
  y <- x
  y$meta$version <- "2.0.0"
  y$analysis_plan[[1]]$research_question <- "Planted research question"
  y$analysis_plan[[1]]$hypotheses <- list(null = "Planted null hypothesis",
                                          alternative = "Planted alternative hypothesis")
  y$references <- list(sframe_reference("planted", "Planted reference title",
                                        author = "Planted, A.", year = 2020))
  y <- amend_sframe(x, y, "model_respecification", "Planted amendment note",
                    deviation_report = "Planted deviation report")
  y$meta$authors <- list("Planted Author")
  y$render$google_sheets_url <- "https://docs.google.com/spreadsheets/d/PLANTED"
  # An attention check's answer, and the likert_scale demo's reverse-keyed
  # org_4 in the organisation scale.
  y$checks <- list(list(id = "attn_1", type = "attention", item_id = "org_2",
                        label = "Planted check label", pass_values = list("3"),
                        fail_action = "flag", notes = "Planted check note"))
  y
}

survey_json <- function(html) {
  m <- regmatches(html, regexpr("id=\"sf-data\">[^<]*", html))
  jsonlite::fromJSON(sub("^id=\"sf-data\">", "", m), simplifyVector = FALSE)
}

for (preview in c(FALSE, TRUE)) {
  test_that(paste0("a shared survey carries only what its page reads, preview = ", preview), {
    out <- tempfile(fileext = ".html")
    on.exit(unlink(out), add = TRUE)
    suppressMessages(export_survey(planted_instrument(), output_path = out,
                                   open = FALSE, preview = preview))
    html <- paste(readLines(out, warn = FALSE, encoding = "UTF-8"), collapse = "\n")

    for (planted in c("Planted research question", "Planted null hypothesis",
                      "Planted alternative hypothesis", "Planted reference title",
                      "Planted amendment note", "Planted deviation report",
                      "Planted Author", "PLANTED", "Planted check label", "Planted check note", "pass_values", "fail_action", "scale_id",
                      "\"reverse\"")) {
      expect_false(grepl(planted, html, fixed = TRUE), info = planted)
    }
    j <- survey_json(html)
    expect_identical(names(j), c("meta", "items", "choices", "branching", "checks", "render"))
    expect_true(all(names(j$meta) %in% c("title", "description")))
    expect_true(all(names(j$render) %in% c("header", "mode", "save_draft", "submit_label",
                                           "thankyou", "theme", "welcome")))
    expect_length(j$items, length(planted_instrument()$items))
    # The page reads which item is a check, to lay it out, and nothing else.
    expect_identical(j$checks, list(list(item_id = "org_2")))
    for (item in j$items) {
      expect_true(all(names(item) %in% sframe_survey_item_fields), info = item$id)
    }
  })
}
