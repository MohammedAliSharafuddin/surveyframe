# data-raw/rename_0.4.3.R
# Applies the 0.4.3 naming table (REVIEW_0.4.3_NAMING.md, decisions 1 to 8)
# across the package source, and writes R/superseded.R, the silent wrappers
# that keep every old name working (decision 3).
#
# Run from the package root: Rscript data-raw/rename_0.4.3.R
# Then run devtools::document(). man/, NAMESPACE and NEWS.md are not
# rewritten: roxygen regenerates the first 2, and NEWS keeps its history.
# Rerunning is safe: a renamed file has no old names left to match, and
# R/superseded.R is written from the table each time.

renames <- read.csv(text = "
old,new,kind
sf_instrument,sframe_instrument,plain
sf_item,sframe_item,plain
sf_choices,sframe_choice_set,plain
sf_scale,sframe_scale,plain
sf_branch,sframe_branch,plain
sf_check,sframe_attention_check,plain
sf_conjoint_design,sframe_conjoint_design,plain
sf_construct,sframe_construct,plain
sf_path,sframe_path,plain
sf_covariance,sframe_covariance,plain
sf_indirect,sframe_indirect_effect,plain
sf_model,sframe_model_spec,plain
add_model,sframe_add_model,plain
validate_model,sframe_validate_model,plain
model_json,sframe_model_json,plain
model_report_template,sframe_model_outline,plain
sf_items,sframe_get_items,generic
sf_scales,sframe_get_scales,generic
sf_checks,sframe_get_attention_checks,generic
sf_models,sframe_get_models,generic
sf_branches,sframe_get_branches,generic
sf_choice_sets,sframe_get_choice_sets,generic
sf_meta,sframe_meta,generic
sf_plan,sframe_plan,generic
sf_id,sframe_id,generic
sf_label,sframe_label,generic
sf_apa,sframe_apa,generic
sf_flagged,sframe_flagged,generic
sf_problems,sframe_problems,generic
sf_is_valid,sframe_is_valid,generic
sf_object,sframe_object,generic
sf_missing_columns,sframe_missing_columns,generic
sample_size_plan,sframe_sample_size_plan,plain
sf_reference,sframe_reference,plain
add_references,sframe_add_references,plain
sframe_references,sframe_get_references,plain
link_git_commit,sframe_link_git_commit,plain
amendment_log,sframe_get_amendments,plain
render_survey,run_survey,plain
export_static_survey,export_survey,plain
survey_module_ui,sframe_survey_ui,plain
survey_module_server,sframe_survey_server,plain
sframe_export_labelled,export_responses,plain
quality_report,sframe_quality_results,plain
missing_data_report,sframe_missing_data_results,plain
outlier_report,sframe_outlier_results,plain
reliability_report,sframe_reliability_results,plain
item_report,sframe_item_results,plain
efa_report,sframe_efa_readiness_results,plain
efa_solution,sframe_efa_solution,plain
validity_report,sframe_validity_results,plain
descriptives_report,sframe_descriptives_results,plain
assumption_report,sframe_assumption_results,plain
posthoc_report,sframe_posthoc_results,plain
bootstrap_ci,sframe_bootstrap_ci,plain
cohens_d_ci,sframe_cohens_d_ci,plain
cramers_v_ci,sframe_cramers_v_ci,plain
eta_sq_ci,sframe_eta_sq_ci,plain
cfa_lavaan_syntax,sframe_syntax_cfa,plain
cfa_syntax,sframe_syntax_cfa,custom
sem_lavaan_syntax,sframe_syntax_sem,plain
seminr_syntax,sframe_syntax_pls,plain
efa_syntax,sframe_syntax_efa,plain
analysis_syntax,sframe_syntax_result,plain
clean_text_responses,sframe_clean_text,plain
term_frequency,sframe_term_frequency,plain
ngram_frequency,sframe_ngram_frequency,plain
term_context,sframe_term_context,plain
extract_quotes,sframe_extract_quotes,plain
sensitivity_analysis,sframe_sensitivity_analysis,plain
render_result,sframe_format_result,plain
codebook_report,sframe_codebook,plain
sframe_demos,sframe_list_demos,plain
sframe_demo_data,sframe_demo,custom
sframe_input_types_demo_data,sframe_demo,custom
launch_builder_demo,launch_builder,custom
launch_studio_demo,launch_studio,custom
", stringsAsFactors = FALSE, strip.white = TRUE)

# Wrappers whose arguments differ from the new function's, keyed by old name:
# the formals, then the body after the warning, then the replacement as shown
# in the warning and on the help page.
custom <- list(
  cfa_syntax = c(
    "instrument, scales = NULL, std_lv = TRUE",
    "sframe_syntax_cfa(instrument = instrument, scales = scales, std_lv = std_lv)",
    "sframe_syntax_cfa()"
  ),
  sframe_demo_data = c(
    "",
    "sframe_demo(\"tourism_services\")",
    "sframe_demo(\"tourism_services\")"
  ),
  sframe_input_types_demo_data = c(
    "",
    "sframe_demo(\"input_types\")",
    "sframe_demo(\"input_types\")"
  ),
  # launch_builder() returns the path alone, so the wrapper rebuilds the list
  # launch_builder_demo() returned.
  launch_builder_demo = c(
    "open = TRUE",
    paste(
      "path <- launch_builder(open = open, demo = \"input_types\")",
      "  demo <- sframe_demo(\"input_types\")",
      "  invisible(list(builder_path = path, demo_file = demo$instrument_path,",
      "                 responses_path = demo$responses_path))",
      sep = "\n"),
    "launch_builder(demo = \"input_types\")"
  ),
  # launch_studio_demo() opened on the preview screen.
  launch_studio_demo = c(
    "screen = \"preview\", port = NULL, host = \"127.0.0.1\", launch.browser = TRUE",
    paste(
      "launch_studio(demo = \"input_types\", screen = screen, port = port,",
      "                host = host, launch.browser = launch.browser)",
      sep = "\n"),
    "launch_studio(demo = \"input_types\")"
  )
)

# Calls rewritten whole before the name rules run, for the old names that
# became an argument: the pattern after `before`, then the replacement. A
# roxygen link such as [sframe_demo_data()] becomes [sframe_demo()] first.
calls <- c(
  "sframe_demo_data\\(\\)" = "sframe_demo(\"tourism_services\")",
  "sframe_input_types_demo_data\\(\\)" = "sframe_demo(\"input_types\")",
  "launch_builder_demo\\(\\)" = "launch_builder(demo = \"input_types\")",
  "launch_builder_demo\\(" = "launch_builder(demo = \"input_types\", ",
  "launch_studio_demo\\(\\)" = "launch_studio(demo = \"input_types\", screen = \"preview\")",
  "launch_studio_demo\\(" = "launch_studio(demo = \"input_types\", "
)

# Not after a letter, digit, underscore, dot, `$` or `@`, so internal helpers
# such as `.item_report_rows()` and list elements such as `x$sf_plan` stay.
before <- "(?<![A-Za-z0-9_.$@])"

rewrite <- function(txt) {
  for (old in renames$old[renames$kind == "custom"]) {
    new <- renames$new[match(old, renames$old)]
    txt <- gsub(paste0("\\[", old, "\\(\\)\\]"), paste0("[", new, "()]"), txt, perl = TRUE)
  }
  for (p in names(calls)) {
    txt <- gsub(paste0(before, p), calls[[p]], txt, perl = TRUE)
  }
  for (i in seq_len(nrow(renames))) {
    old <- renames$old[[i]]
    new <- renames$new[[i]]
    # A call, a call written into a string, or a link: `old(`, `[old()]`.
    # No space before the bracket, so prose such as "term_context (say)",
    # naming a plan method, stays.
    txt <- gsub(paste0(before, old, "(?=\\()"), new, txt, perl = TRUE)
    # The function as a value: pkg::old, do.call(old, ), formals(old).
    txt <- gsub(
      paste0("(?<=::|do\\.call\\(|formals\\(|testServer\\(|match\\.fun\\()",
             old, "(?![A-Za-z0-9_])"),
      new, txt, perl = TRUE)
    # The definition itself, at the start of a line.
    txt <- gsub(paste0("^", old, "(?=\\s*<-)"), new, txt, perl = TRUE)
    # Roxygen links and tags naming a topic: [old], \link{old}, @rdname old.
    txt <- gsub(paste0("\\[", old, "\\]"), paste0("[", new, "]"), txt, perl = TRUE)
    txt <- gsub(paste0("\\\\link\\{", old, "\\}"), paste0("\\\\link{", new, "}"), txt, perl = TRUE)
    txt <- gsub(
      paste0("(@(rdname|inheritParams|inherit|describeIn|inheritDotParams) +)", old, "(?![A-Za-z0-9_])"),
      paste0("\\1", new), txt, perl = TRUE)
    if (renames$kind[[i]] == "generic") {
      # S3 generics: the dispatch string and every method name.
      txt <- gsub(paste0("UseMethod\\(\"", old, "\""), paste0("UseMethod(\"", new, "\""), txt, perl = TRUE)
      txt <- gsub(paste0(before, old, "\\.(?=[A-Za-z])"), paste0(new, "."), txt, perl = TRUE)
      txt <- gsub(paste0(before, old, "(?=<-)"), new, txt, perl = TRUE)
      txt <- gsub(paste0("UseMethod\\(\"", old, "<-\""), paste0("UseMethod(\"", new, "<-\""), txt, perl = TRUE)
      txt <- gsub(paste0("(@(exportS3Method|method) +`?)", old, "(?=[` ]|<-|$)"), paste0("\\1", new), txt, perl = TRUE)
    }
  }
  txt
}

files <- c(
  list.files("R", pattern = "\\.R$", full.names = TRUE),
  list.files("tests/testthat", pattern = "\\.R$", full.names = TRUE),
  list.files("vignettes", pattern = "\\.(Rmd|qmd)$", full.names = TRUE, recursive = TRUE),
  list.files("inst", pattern = "\\.(R|Rmd|qmd|html|js|md|gs)$", full.names = TRUE, recursive = TRUE),
  list.files("data-raw", pattern = "\\.R$", full.names = TRUE),
  "README.md"
)
files <- setdiff(files, c(
  "R/superseded.R", "R/superseded_warn.R", "data-raw/rename_0.4.3.R",
  "tests/testthat/test-superseded.R", "tests/testthat/test-superseded-warn.R",
  "tests/testthat/test-demo-reference-datasets.R",
  "tests/testthat/test-launch-builder-demo.R",
  "tests/testthat/test-launch-studio-demo.R"
))

changed <- character()
for (f in files) {
  before_txt <- readLines(f, warn = FALSE, encoding = "UTF-8")
  after_txt <- rewrite(before_txt)
  if (!identical(before_txt, after_txt)) {
    writeLines(after_txt, f, useBytes = TRUE)
    changed <- c(changed, f)
  }
}
message(length(changed), " files rewritten")

# R/superseded.R ------------------------------------------------------------

shown <- function(i) {
  old <- renames$old[[i]]
  if (old %in% names(custom)) custom[[old]][[3]] else paste0(renames$new[[i]], "()")
}

table_rows <- vapply(seq_len(nrow(renames)), function(i) {
  args <- sub("^[^(]*\\((.*)\\)$", "\\1", shown(i))
  with <- if (nzchar(args)) paste0(" with `", args, "`") else ""
  paste0("#' | `", renames$old[[i]], "()` | [", sub("\\(.*$", "", shown(i)), "()]", with, " |")
}, character(1))

wrapper <- function(i) {
  old <- renames$old[[i]]
  new <- renames$new[[i]]
  if (old %in% names(custom)) {
    args <- custom[[old]][[1]]
    call <- custom[[old]][[2]]
  } else {
    args <- "..."
    call <- paste0(new, "(...)")
  }
  c(
    "#' @rdname superseded",
    "#' @export",
    paste0(old, " <- function(", args, ") {"),
    paste0("  sframe_superseded(\"", old, "()\", \"", gsub("\"", "\\\\\"", shown(i)), "\")"),
    paste0("  ", call),
    "}",
    ""
  )
}

out <- c(
  "# R/superseded.R",
  "# Written by data-raw/rename_0.4.3.R from the 0.4.3 naming table. Edit the",
  "# table there and rerun it, not this file.",
  "",
  "#' Superseded function names",
  "#'",
  "#' In 0.4.3 every exported function took the `sframe_` prefix or a stage",
  "#' verb, so a name says which stage it belongs to and no 2 names sit 1",
  "#' letter apart. The old names still work and give the same result, with no",
  "#' warning. Set `options(surveyframe.warn_superseded = TRUE)` to get 1",
  "#' warning per old name per session, naming its replacement.",
  "#'",
  "#' | Old name | New name |",
  "#' |---|---|",
  table_rows,
  "#' | `sf_plan(x) <- value` | [sframe_plan<-][sframe_plan] |",
  "#'",
  "#' @param ... Passed to the new function.
#' @param open Passed to [launch_builder()].
#' @param screen,port,host,launch.browser Passed to [launch_studio()].",
  "#' @param instrument,scales,std_lv Passed to [sframe_syntax_cfa()].",
  "#' @param x An instrument.",
  "#' @param value The analysis plan, as for [sframe_plan()].",
  "#' @return What the new function returns.",
  "#' @examples",
  "#' # The old name and the new one make the same item",
  "#' identical(sf_item(\"q1\", \"Question 1\", type = \"text\"),",
  "#'           sframe_item(\"q1\", \"Question 1\", type = \"text\"))",
  "#' @name superseded",
  "#' @family superseded",
  "NULL",
  "",
  unlist(lapply(seq_len(nrow(renames)), wrapper)),
  "#' @rdname superseded",
  "#' @export",
  "`sf_plan<-` <- function(x, value) {",
  "  sframe_superseded(\"sf_plan(x) <- value\", \"sframe_plan(x) <- value\")",
  "  `sframe_plan<-`(x, value = value)",
  "}"
)
writeLines(out, "R/superseded.R")
message("R/superseded.R written with ", nrow(renames) + 1, " wrappers")
