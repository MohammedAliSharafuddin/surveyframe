# data-raw/inline_role_aliases.R
# Inlines the role alias table from R/analysis_role_aliases.R into
# inst/builder/survey_builder.html between the ALIAS_TABLE_START/END markers,
# so SurveyBuilder reads every alias R reads. Run after editing the table.
# tests/testthat/test-builder-role-aliases.R fails whenever the two differ.

pkgload::load_all(quiet = TRUE)

builder_path <- file.path("inst", "builder", "survey_builder.html")
stopifnot(file.exists(builder_path))
builder <- readLines(builder_path, encoding = "UTF-8", warn = FALSE)

start <- grep("/* ALIAS_TABLE_START", builder, fixed = TRUE)
end   <- grep("/* ALIAS_TABLE_END */", builder, fixed = TRUE)
stopifnot(length(start) == 1L, length(end) == 1L, start < end)

block <- paste0("var ROLE_ALIASES_BY_METHOD=", sframe_role_aliases_json(), ";")
builder <- c(builder[seq_len(start)], block, builder[end:length(builder)])

writeLines(builder, builder_path, useBytes = TRUE)
message("Inlined the role alias table into ", builder_path, ".")
