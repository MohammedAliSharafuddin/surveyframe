# data-raw/help_by_stage_0.4.3.R
# Naming decision 8: help organised by stage. Rewrites the reference index in
# _pkgdown.yml in stage order, then the toolboxes, and adds an @family tag by
# section to the roxygen block behind every listed help page, so each page
# ends with links to the rest of its section.
#
# Run from the package root: Rscript data-raw/help_by_stage_0.4.3.R
# It reads the old index from commit fa5e120, the last before it ran.
# Then run devtools::document(). It stops if a topic in the old index has no
# section, or sits in 2. Rerunning replaces the @family tags it wrote.

sections <- list(
  list(title = "Start here", family = "entry points",
       desc = paste(
         "SurveyStudio opens an instrument and takes it through every stage",
         "below, with no code. ?surveyframe is the map of the package, and",
         "sframe_demo(\"first_survey\") is a whole survey to start from."),
       contents = c("surveyframe-package", "launch_studio")),
  list(title = "Design", family = "Design functions",
       desc = paste(
         "Make the instrument: its questions, choice sets, scales, branching",
         "and attention checks, saved as a portable .sframe file.",
         "In SurveyBuilder: the Build mode. In code: `sframe_instrument()`",
         "and the makers listed here, then `write_sframe()`."),
       contents = c("launch_builder", "sframe_instrument", "sframe_item",
                    "sframe_choice_set", "sframe_scale", "sframe_branch",
                    "sframe_attention_check", "sframe_conjoint_design",
                    "write_sframe", "read_sframe", "validate_sframe",
                    "sframe_validation", "as_sframe")),
  list(title = "Plan", family = "Plan functions",
       desc = paste(
         "Declare the analysis before the data arrive, so the report shows",
         "what was planned and what was run.",
         "In SurveyBuilder: the Analyse mode. In SurveyStudio: the Analysis",
         "Plan screen. In code: `sframe_plan(x) <- plan`."),
       contents = c("sframe_plan", "sframe_plan<-", "sframe_sample_size_plan")),
  list(title = "Preview", family = "Preview functions",
       desc = paste(
         "See the survey as a respondent meets it, with nothing collected.",
         "In SurveyStudio: the Preview screen. In code: `preview_survey()`."),
       contents = c("preview_survey", "run_survey")),
  list(title = "Collect", family = "Collect functions",
       desc = paste(
         "Send the survey out: a standalone HTML page, optionally saving",
         "answers to a Google Sheet, or a Shiny module inside your own app.",
         "In SurveyBuilder: Export survey, with the Google Sheets settings.",
         "In code: `export_survey()`."),
       contents = c("export_survey", "export_google_sheet",
                    "sframe_survey_ui", "sframe_survey_server")),
  list(title = "Responses", family = "Responses functions",
       desc = paste(
         "Read the answers back against the instrument, check their quality,",
         "and export them with labels for other software.",
         "In SurveyStudio: the Responses and Quality screens.",
         "In code: `read_responses()`."),
       contents = c("read_responses", "read_sheet_responses",
                    "export_responses", "sframe_quality_results",
                    "sframe_missing_data_results", "sframe_outlier_results")),
  list(title = "Analyse", family = "Analyse functions",
       desc = paste(
         "Score the scales and run the plan, block by block.",
         "In SurveyStudio: the Reliability, Analysis Plan and Dashboard",
         "screens. In code: `run_analysis_plan()`."),
       contents = c("run_analysis_plan", "score_scales",
                    "sframe_descriptives_results", "sframe_reliability_results",
                    "sframe_item_results", "sframe_efa_readiness_results",
                    "sframe_efa_solution", "sframe_validity_results",
                    "sframe_assumption_results", "sframe_posthoc_results")),
  list(title = "Report", family = "Report functions",
       desc = paste(
         "Write up what was run: an HTML or PDF report, a codebook,",
         "the figures, and the R code behind each result.",
         "In SurveyStudio: the Export screen. In code: `render_report()`."),
       contents = c("render_report", "render_results", "sframe_reports",
                    "sframe_format_result", "sframe_codebook",
                    "sframe_save_figures", "sframe_analysis_qmd")),
  list(title = "References", family = "References functions",
       desc = paste(
         "Cite the works an instrument draws on. The references travel in the",
         ".sframe file and the report lists each one once, at the end.",
         "In SurveyStudio: the References screen.",
         "In code: `sframe_add_references()`."),
       contents = c("sframe_reference", "read_bibtex", "sframe_add_references",
                    "sframe_get_references", "sframe_bibliography")),
  list(title = "Amendments", family = "Amendments functions",
       desc = paste(
         "Change an instrument mid-study, on the record: each amendment is",
         "logged with its reason and the hash it replaced.",
         "In SurveyStudio: the Amendments screen. In code: `amend_sframe()`."),
       contents = c("amend_sframe", "sframe_get_amendments",
                    "sframe_link_git_commit")),
  list(title = "Inspect", family = "Inspect functions",
       desc = paste(
         "Read parts of an instrument, a validation result or a report",
         "without reaching into the object, at any stage. Each accessor and",
         "as.data.frame method states the classes it accepts and what it",
         "returns."),
       contents = NULL),
  list(title = "Models and syntax", family = "Models and syntax functions",
       desc = paste(
         "Declare constructs, paths and covariances, and generate lavaan,",
         "seminr and psych syntax from the instrument."),
       contents = c("sframe_model_spec", "sframe_construct", "sframe_path",
                    "sframe_covariance", "sframe_indirect_effect",
                    "sframe_add_model", "sframe_validate_model",
                    "sframe_model_json", "sframe_model_outline",
                    "sframe_syntax_cfa", "sframe_syntax_efa",
                    "sframe_syntax_sem", "sframe_syntax_pls",
                    "sframe_syntax_result")),
  list(title = "Charts", family = "Chart functions",
       desc = "Opt-in ggplot2 charts for analysis results, and the package theme.",
       contents = NULL),
  list(title = "Decision analysis", family = "Decision analysis functions",
       desc = paste(
         "Multi-criteria decision analysis. The 10 methods run through the",
         "analysis plan like any other, so the functions here assemble their",
         "input and test how stable a ranking is."),
       contents = NULL),
  list(title = "Text analysis", family = "Text analysis functions",
       desc = paste(
         "Open-ended answers: term and n-gram frequency, keyword in context,",
         "and quote extraction."),
       contents = NULL),
  list(title = "Confidence intervals", family = "Confidence interval functions",
       desc = paste(
         "Base-R bootstrap and effect-size confidence intervals, reused",
         "across the inferential runners."),
       contents = NULL),
  list(title = "Demos", family = "Demo functions",
       desc = paste(
         "22 small teaching demos, each doing one job, and 2 larger reference",
         "datasets. Each comes with an instrument and response data, and the",
         "teaching demos with a codebook and the results surveyframe",
         "produced. See the \"Learn by example\" article."),
       contents = c("sframe_list_demos", "sframe_demo", "sframe_demo_qmd")),
  list(title = "Methods", family = "print, format and summary methods",
       desc = paste(
         "Print, format and summary methods, so every component prints and",
         "summarises cleanly at the console and inside reports."),
       contents = NULL),
  list(title = "For the report template",
       family = "SurveyStudio helpers",
       desc = paste(
         "The APA cell formatter the Quarto report template calls. Exported",
         "because Quarto renders against the installed package."),
       contents = c("sframe_apa_cells")),
  list(title = "Old names (superseded)", family = NULL,
       desc = paste(
         "Every name changed in 0.4.3, each still working, and what",
         "replaced it."),
       contents = "superseded")
)

# The index as it stood before this script, so a rerun starts from the same
# sections
y <- yaml::yaml.load(paste(system2("git", c("show", "fa5e120:_pkgdown.yml"),
                                  stdout = TRUE), collapse = "\n"))
old <- setNames(lapply(y$reference, function(s) unlist(s$contents)),
                vapply(y$reference, function(s) s$title, ""))
all_old <- unlist(old, use.names = FALSE)
title_of <- vapply(sections, function(s) s$title, "")

# Sections whose contents follow an old section, less what moved elsewhere
fill <- c(
  "Inspect" = "Accessors and coercion",
  "Charts" = "Plotting",
  "Decision analysis" = "Decision analysis",
  "Text analysis" = "Text analysis",
  "Confidence intervals" = "Confidence intervals",
  "Methods" = "Print, format, and summary methods")
named <- unlist(lapply(sections, function(s) s$contents), use.names = FALSE)
for (t in names(fill)) {
  i <- match(t, title_of)
  sections[[i]]$contents <- setdiff(old[[fill[[t]]]], named)
}

new_all <- unlist(lapply(sections, function(s) s$contents), use.names = FALSE)
dup <- new_all[duplicated(new_all)]
if (length(dup)) stop("In 2 sections: ", paste(dup, collapse = ", "))
lost <- setdiff(all_old, new_all)
if (length(lost)) stop("No section: ", paste(lost, collapse = ", "))
extra <- setdiff(new_all, all_old)
if (length(extra)) message("New to the index: ", paste(extra, collapse = ", "))

# _pkgdown.yml: replace the reference block, keep everything around it ------

lines <- readLines("_pkgdown.yml")
start <- grep("^reference:", lines)
after <- grep("^[A-Za-z]", lines)
end <- min(after[after > start]) - 1
quote_topic <- function(t) if (grepl("[^A-Za-z0-9_.-]", t)) paste0("\"", t, "\"") else t
block <- "reference:"
for (s in sections) {
  wrapped <- strwrap(s$desc, width = 72)
  block <- c(block,
             paste0("  - title: \"", s$title, "\""),
             "    desc: >",
             paste0("      ", wrapped),
             "    contents:",
             paste0("      - ", vapply(s$contents, quote_topic, "")),
             "")
}
writeLines(c(lines[seq_len(start - 1)], block, lines[(end + 1):length(lines)]),
           "_pkgdown.yml")

# @family tags --------------------------------------------------------------

blocks <- roxygen2::parse_package(".", env = NULL)
topic_of_block <- function(b) {
  tags <- vapply(b$tags, function(t) t$tag, "")
  if ("rdname" %in% tags) return(b$tags[[match("rdname", tags)]]$val)
  if ("name" %in% tags) return(b$tags[[match("name", tags)]]$val)
  # Parsed without evaluating, so the topic comes from the call itself:
  # `name <- function`, or "_PACKAGE"
  cl <- b$call
  if (is.character(cl) && identical(cl, "_PACKAGE")) return("surveyframe-package")
  if (is.call(cl) && as.character(cl[[1]]) %in% c("<-", "=")) {
    return(gsub("`", "", deparse(cl[[2]])))
  }
  NA_character_
}
`%||%` <- function(a, b) if (is.null(a)) b else a

family_of <- unlist(lapply(sections, function(s) {
  if (is.null(s$family)) return(NULL)
  setNames(rep(s$family, length(s$contents)), s$contents)
}))

# Remove the tags an earlier run wrote, then add 1 per topic
for (f in list.files("R", pattern = "\\.R$", full.names = TRUE)) {
  x <- readLines(f, warn = FALSE)
  keep <- !grepl("^#' @family ", x) | grepl("^#' @family superseded$", x)
  if (!all(keep)) writeLines(x[keep], f)
}
blocks <- roxygen2::parse_package(".", env = NULL)
done <- character()
inserts <- list()
for (b in blocks) {
  t <- topic_of_block(b)
  if (is.na(t) || !t %in% names(family_of) || t %in% done) next
  done <- c(done, t)
  inserts[[length(inserts) + 1]] <- list(file = b$file, line = b$line,
                                         tag = paste0("#' @family ", family_of[[t]]))
}
missed <- setdiff(names(family_of), done)
if (length(missed)) stop("No roxygen block for: ", paste(missed, collapse = ", "))

# Insert bottom-up per file so earlier line numbers stay right
by_file <- split(inserts, vapply(inserts, function(i) i$file, ""))
for (f in names(by_file)) {
  x <- readLines(f, warn = FALSE)
  ins <- by_file[[f]][order(-vapply(by_file[[f]], function(i) i$line, 0))]
  for (i in ins) {
    # b$line is the object's first line; walk back over blank lines to the
    # end of the roxygen comment
    at <- i$line - 1
    while (at > 0 && !grepl("^#'", x[at])) at <- at - 1
    x <- append(x, i$tag, after = at)
  }
  writeLines(x, f)
}
message(length(inserts), " @family tags written across ", length(by_file), " files")
