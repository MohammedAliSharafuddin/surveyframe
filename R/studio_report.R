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
