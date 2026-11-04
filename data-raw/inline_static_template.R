# data-raw/inline_static_template.R
# Re-inlines inst/static_survey/template.html, collector_template.gs and
# inst/builder/field_tools.js into
# inst/builder/survey_builder.html between the STATIC_TEMPLATE_START/END and
# COLLECTOR_TEMPLATE_START/END and FIELD_TOOLS_START/END markers. The
# builder's Export survey and Generate collector features stay single-sourced
# with the R export path, and its citation picker with Studio's.
# Run after any edit to template.html, collector_template.gs or
# field_tools.js.
# Recreated 2026-07-08 from the marker format in survey_builder.html; the
# original script was gitignored on main and lost.
# Tracked on main since 2026-09-17 (0.4.2), where the release is built.
# tests/testthat/test-builder-template-sync.R fails whenever the builder
# copies and these templates differ, so run this after editing either.

builder_path   <- file.path("inst", "builder", "survey_builder.html")
tools_path    <- file.path("inst", "builder", "field_tools.js")
template_path  <- file.path("inst", "static_survey", "template.html")
collector_path <- file.path("inst", "static_survey", "collector_template.gs")

stopifnot(file.exists(builder_path), file.exists(template_path),
          file.exists(collector_path),
          file.exists(tools_path))

read_utf8 <- function(path) readLines(path, encoding = "UTF-8", warn = FALSE)

escape_script <- function(lines) {
  gsub("</script>", "<\\\\/script>", lines, fixed = FALSE)
}

replace_block <- function(builder, start_marker, end_marker, block) {
  start <- grep(start_marker, builder, fixed = TRUE)
  end   <- grep(end_marker, builder, fixed = TRUE)
  stopifnot(length(start) == 1L, length(end) == 1L, start < end)
  c(builder[seq_len(start)], block, builder[end:length(builder)])
}

builder <- read_utf8(builder_path)

static_block <- c(
  '<script type="text/template" id="staticSurveyTpl">',
  escape_script(read_utf8(template_path)),
  "</script>"
)
builder <- replace_block(
  builder,
  "<!-- STATIC_TEMPLATE_START:",
  "<!-- STATIC_TEMPLATE_END -->",
  static_block
)

collector_block <- c(
  '<script type="text/template" id="collectorTpl">',
  escape_script(read_utf8(collector_path)),
  "</script>"
)
builder <- replace_block(
  builder,
  "<!-- COLLECTOR_TEMPLATE_START:",
  "<!-- COLLECTOR_TEMPLATE_END -->",
  collector_block
)

# The shared citation picker, a plain script, so the builder still opens
# from a copied file with no sibling files beside it.
tools_block <- c("<script>", escape_script(read_utf8(tools_path)), "</script>")
builder <- replace_block(
  builder,
  "<!-- FIELD_TOOLS_START:",
  "<!-- FIELD_TOOLS_END -->",
  tools_block
)

writeLines(builder, builder_path, useBytes = TRUE)
message("Re-inlined templates into ", builder_path,
        " (", length(builder), " lines).")
