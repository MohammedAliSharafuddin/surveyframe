# R/plan_declaration.R
#
# What a plan block declared before the data, and what was written after the
# results (D12). Every report prints the declaration before the result and
# the interpretation after it, under labels that say which is which, so the
# reader can tell the prospective contract from the narrative.

# The 2 sentences SurveyBuilder and SurveyStudio saved for every
# hypothesis-testing block before 0.4.3. No researcher wrote them, so they
# are no declaration.
sframe_unwritten_hypotheses <- c("No effect or association is present.",
                                 "An effect or association is present.")

sframe_interpretation_label <- "Interpretation (written after the results)"

sframe_written_text <- function(x) {
  if (is.character(x) && length(x) == 1 && !is.na(x)) trimws(x) else ""
}

# The declaration as label = text, holding only what was written. Accepts a
# plan block or a run_analysis_plan() result, which carries the same fields.
sframe_plan_declaration <- function(block) {
  hyp <- if (is.list(block$hypotheses)) block$hypotheses else list()
  h0 <- sframe_written_text(hyp$null)
  h1 <- sframe_written_text(hyp$alternative)
  if (h0 %in% sframe_unwritten_hypotheses) h0 <- ""
  if (h1 %in% sframe_unwritten_hypotheses) h1 <- ""
  out <- c("Null hypothesis (H0)" = h0,
           "Alternative hypothesis (H1)" = h1,
           "Planned decision rule" = sframe_written_text(block$decision_rule))
  out[nzchar(out)]
}

# The interpretation passed to the report for this block, else the one the
# block holds. One identical to the decision rule was copied from it by an
# earlier interface, and is no interpretation.
sframe_written_interpretation <- function(block, interpretations = list()) {
  id <- as.character(block$block_id %||% block$id %||% "")[1]
  text <- if (nzchar(id) && id %in% names(interpretations)) {
    sframe_written_text(interpretations[[id]])
  } else ""
  if (!nzchar(text)) text <- sframe_written_text(block$interpretation)
  if (identical(text, sframe_written_text(block$decision_rule))) "" else text
}

# The declaration as HTML paragraphs, one per field written, or "".
sframe_declaration_html <- function(block) {
  d <- sframe_plan_declaration(block)
  if (length(d) == 0) return("")
  paste(sprintf("<p><strong>%s:</strong> %s</p>", names(d),
                vapply(d, htmltools_escape, character(1))), collapse = "\n")
}

# Every block's declaration and written interpretation, keyed by block id,
# for the Quarto template, with the label the interpretation prints under.
sframe_plan_declarations <- function(instrument, interpretations = list()) {
  plan <- instrument$analysis_plan %||% list()
  blocks <- lapply(plan, function(b) {
    list(declaration = sframe_plan_declaration(b),
         interpretation = sframe_written_interpretation(b, interpretations))
  })
  names(blocks) <- vapply(plan, function(b) as.character(b$id %||% "")[1], character(1))
  list(interpretation_label = sframe_interpretation_label, blocks = blocks)
}

# Planned or exploratory (owner 2026-11-04). A result carries a significance
# test when its APA line gives a p value or its table has a p column. One
# that does, from a block that declared no H0 and no H1 before the data, is
# exploratory, and both reports say so before the result. The 2 placeholder
# sentences count as not declared. A missing hypothesis stays valid.
sframe_exploratory_label <- "Exploratory: no hypothesis declared before the data"

sframe_result_has_p <- function(result) {
  apa <- paste(as.character(result$apa %||% ""), collapse = " ")
  if (grepl("(^|[^A-Za-z])p [<=>]", apa)) return(TRUE)
  tbl <- result$table
  is.data.frame(tbl) && any(grepl("^p$|^p\\.value$|^p_value$|^Pr\\(>", names(tbl), ignore.case = TRUE))
}

sframe_result_exploratory <- function(result) {
  if (!is.list(result) || !is.null(result$error)) return(FALSE)
  d <- sframe_plan_declaration(result)
  declared <- any(c("Null hypothesis (H0)", "Alternative hypothesis (H1)") %in% names(d))
  sframe_result_has_p(result) && !declared
}

