# R/studio_report.R
#
# What SurveyStudio's Report screen says and offers about the engine and the
# reference style (UI-1). Studio runs in the package namespace and calls
# these, so they are tested without a browser.

# The engine line: Quarto as render_report() finds it, through
# sframe_quarto_find(), so a copy bundled with RStudio or Positron counts.
# Without Quarto it names the remedy. The built-in engine is a fallback, not
# a third choice.
sframe_studio_quarto_note <- function(found = sframe_quarto_find(),
                                      use_quarto = isTRUE(getOption("surveyframe.use_quarto", TRUE))) {
  builtin <- paste(
    "the built-in engine writes the report, with references in APA 7 only.",
    "Install Quarto from quarto.org, or open Studio from RStudio or Positron,",
    "which bring their own copy, for the other reference styles and the",
    "Word, ODT and Quarto source formats.")
  if (!use_quarto) {
    return(list(ok = FALSE, text = paste0(
      "Quarto is turned off by options(surveyframe.use_quarto = FALSE), so ", builtin)))
  }
  if (is.na(found$path %||% NA_character_)) {
    return(list(ok = FALSE, text = paste0("Quarto was not found, so ", builtin)))
  }
  list(ok = TRUE, text = paste0("Quarto ", sframe_quarto_label(found),
                                ", writes the report in any reference style."))
}

# The declared plan as the Analyse screen shows it, read-only (UX-02): the
# builder's Plan is the only plan editor, and Analyse runs what it declares.
# `labels` names each method Studio knows (its analysis registry). A block
# with no method says so, and a method Studio does not know is shown as
# written. A cross-tab gives the percentages it declares.
sframe_studio_declared_plan <- function(instrument, labels = character(0)) {
  plan <- instrument$analysis_plan %||% list()
  if (!length(plan)) return(NULL)
  tbl <- sframe_plan_table(instrument)
  method <- vapply(plan, function(b) as.character(b$method %||% b$test %||% "")[1], character(1))
  method[is.na(method)] <- ""
  shown <- ifelse(!nzchar(method), "No method declared",
           ifelse(method %in% names(labels), unname(labels[method]),
                  paste0(method, " (not a method Studio knows)")))
  pct <- vapply(plan, function(b) {
    m <- as.character(b$method %||% b$test %||% "")[1]
    if (!isTRUE(m %in% c("crosstab", "chi_square"))) return("")
    p <- as.character(b$options$percent %||% "")[1]
    if (is.na(p) || !nzchar(p)) "Counts only" else paste(tools::toTitleCase(p), "percentages")
  }, character(1))
  hyp <- vapply(plan, function(b) {
    d <- names(sframe_plan_declaration(b))
    if (any(c("Null hypothesis (H0)", "Alternative hypothesis (H1)") %in% d)) "Declared" else "None"
  }, character(1))
  runs <- vapply(plan, function(b) if (isFALSE(b$requires_data)) "Syntax only" else "Yes",
                 character(1))
  data.frame(ID = tbl$id, `Research question` = tbl$research_question,
             Method = shown, Variables = tbl$variables, Percentages = pct,
             Hypotheses = hyp, Runs = runs,
             check.names = FALSE, stringsAsFactors = FALSE)
}

# The deviation report pre-filled when the plan changes after the responses
# were loaded: the blocks and what happened to each, oldest order kept. The
# person adds the reason. NULL when no plan block changed.
sframe_studio_plan_change_report <- function(before, after) {
  ch <- sframe_component_changes(before$analysis_plan, after$analysis_plan)
  if (!length(ch)) return(NULL)
  paste0("Plan changed after the responses were loaded: ",
         paste(sprintf("%s %s", names(ch), unlist(ch)), collapse = ", "),
         ". Reason: ")
}

# The formats the Finished report offers (UX-20). Word and OpenDocument go
# through Quarto, so without it the choice is HTML and PDF, and the engine
# line names the remedy. The reproducible source is the Reproduce tab's job,
# so the .qmd folder is not a format here.
sframe_studio_report_formats <- function(quarto_ok) {
  if (isTRUE(quarto_ok)) {
    c("HTML" = "html", "PDF" = "pdf", "Word (.docx)" = "docx",
      "OpenDocument (.odt)" = "odt")
  } else {
    c("HTML" = "html", "PDF (needs pagedown and Chrome)" = "pdf")
  }
}
