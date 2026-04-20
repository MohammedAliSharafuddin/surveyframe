# analysis_plan.R
# Functions for running pre-planned research-question-driven analyses
# and generating APA-formatted results with interpretation prompts.

# ---------------------------------------------------------------------------
# Citation library
# ---------------------------------------------------------------------------

.sframe_citations <- list(
  field_2018 = list(
    key  = "field_2018",
    apa  = "Field, A. (2018). *Discovering statistics using IBM SPSS statistics* (5th ed.). SAGE.",
    use  = c("chi_square", "fisher_exact", "t_test_ind", "t_test_pair",
             "anova_one", "correlation_pearson", "regression_linear")
  ),
  cohen_1988 = list(
    key  = "cohen_1988",
    apa  = "Cohen, J. (1988). *Statistical power analysis for the behavioral sciences* (2nd ed.). Lawrence Erlbaum.",
    use  = c("chi_square", "t_test_ind", "mann_whitney", "anova_one",
             "correlation_pearson", "correlation_spearman", "kruskal_wallis")
  ),
  mann_1947 = list(
    key  = "mann_1947",
    apa  = "Mann, H. B., & Whitney, D. R. (1947). On a test of whether one of two random variables is stochastically larger than the other. *Annals of Mathematical Statistics*, *18*(1), 50-60.",
    use  = "mann_whitney"
  ),
  kruskal_1952 = list(
    key  = "kruskal_1952",
    apa  = "Kruskal, W. H., & Wallis, W. A. (1952). Use of ranks in one-criterion variance analysis. *Journal of the American Statistical Association*, *47*(260), 583-621.",
    use  = "kruskal_wallis"
  ),
  spearman_1904 = list(
    key  = "spearman_1904",
    apa  = "Spearman, C. (1904). The proof and measurement of association between two things. *The American Journal of Psychology*, *15*(1), 72-101.",
    use  = "correlation_spearman"
  ),
  cronbach_1951 = list(
    key  = "cronbach_1951",
    apa  = "Cronbach, L. J. (1951). Coefficient alpha and the internal structure of tests. *Psychometrika*, *16*(3), 297-334.",
    use  = c("reliability_alpha", "reliability_omega")
  ),
  mcdonald_1999 = list(
    key  = "mcdonald_1999",
    apa  = "McDonald, R. P. (1999). *Test theory: A unified treatment*. Lawrence Erlbaum.",
    use  = "reliability_omega"
  ),
  hosmer_2013 = list(
    key  = "hosmer_2013",
    apa  = "Hosmer, D. W., Lemeshow, S., & Sturdivant, R. X. (2013). *Applied logistic regression* (3rd ed.). Wiley.",
    use  = c("regression_logistic_binary", "regression_logistic_ordinal")
  ),
  r_core = list(
    key  = "r_core",
    apa  = sprintf("R Core Team. (%s). *R: A language and environment for statistical computing*. R Foundation for Statistical Computing.", format(Sys.Date(), "%Y")),
    use  = "all"
  ),
  surveyframe = list(
    key  = "surveyframe",
    apa  = "Sharafuddin, M. A. (2026). *surveyframe: A survey instrument workflow for R* (Version 0.2.0) [Computer software]. https://github.com/MohammedAliSharafuddin/surveyframe",
    use  = "all"
  )
)

sframe_citations_for_test <- function(test) {
  matching <- Filter(function(cit) {
    "all" %in% cit$use || test %in% cit$use
  }, .sframe_citations)
  lapply(matching, function(cit) cit$apa)
}

# ---------------------------------------------------------------------------
# Effect size helpers
# ---------------------------------------------------------------------------

sframe_cohens_d <- function(x, y) {
  nx <- length(x[!is.na(x)])
  ny <- length(y[!is.na(y)])
  if (nx < 2 || ny < 2) return(NA_real_)
  pooled_sd <- sqrt(((nx - 1) * stats::var(x, na.rm = TRUE) +
                     (ny - 1) * stats::var(y, na.rm = TRUE)) / (nx + ny - 2))
  if (pooled_sd == 0) return(NA_real_)
  abs(mean(x, na.rm = TRUE) - mean(y, na.rm = TRUE)) / pooled_sd
}

sframe_effect_label <- function(d, type = "d") {
  if (is.na(d)) return("could not be computed")
  if (type == "d") {
    if (d < 0.2) return("negligible")
    if (d < 0.5) return("small")
    if (d < 0.8) return("medium")
    return("large")
  }
  if (type == "r") {
    if (d < 0.1) return("negligible")
    if (d < 0.3) return("small")
    if (d < 0.5) return("medium")
    return("large")
  }
  if (type == "eta2") {
    if (d < 0.01) return("negligible")
    if (d < 0.06) return("small")
    if (d < 0.14) return("medium")
    return("large")
  }
  "unknown"
}

sframe_p_string <- function(p) {
  if (is.na(p)) return("= NA")
  if (p < .001) return("< .001")
  sprintf("= %s", formatC(p, digits = 3, format = "f"))
}

# ---------------------------------------------------------------------------
# Individual test runners
# ---------------------------------------------------------------------------

sframe_run_frequency <- function(data, vars) {
  col <- vars[1]
  vals <- data[[col]]
  tbl <- sort(table(vals, useNA = "ifany"), decreasing = TRUE)
  pct <- round(prop.table(tbl) * 100, 1)
  list(
    test      = "frequency",
    variable  = col,
    n         = length(vals[!is.na(vals)]),
    table     = data.frame(
      Value     = names(tbl),
      Frequency = as.integer(tbl),
      Percent   = as.numeric(pct),
      stringsAsFactors = FALSE
    ),
    apa       = sprintf("Frequency distribution for %s (N = %d).", col, sum(tbl)),
    prompt    = "Describe the distribution. Note any dominant category and whether the distribution was expected."
  )
}

sframe_run_crosstab <- function(data, vars) {
  r <- data[[vars[1]]]
  c <- data[[vars[2]]]
  complete <- !is.na(r) & !is.na(c)
  r <- r[complete]; c <- c[complete]
  tbl <- table(r, c)
  ct <- tryCatch(
    suppressWarnings(stats::chisq.test(tbl, correct = FALSE)),
    error = function(e) NULL
  )
  if (is.null(ct)) {
    return(list(test = "crosstab", error = "Chi-square could not be computed."))
  }
  n <- sum(tbl)
  phi <- sqrt(ct$statistic / n)
  list(
    test     = "crosstab",
    vars     = vars,
    n        = n,
    table    = as.data.frame.matrix(tbl),
    chi_sq   = unname(ct$statistic),
    df       = unname(ct$parameter),
    p        = ct$p.value,
    phi      = unname(phi),
    effect_label = sframe_effect_label(phi, "r"),
    apa      = sprintf(
      "\u03c7\u00b2(%d, N = %d) = %.2f, p %s, \u03c6 = %.2f",
      ct$parameter, n, ct$statistic, sframe_p_string(ct$p.value), phi
    ),
    prompt   = sprintf(
      "The chi-square test %s a significant association between %s and %s (\u03c6 = %.2f, %s effect). Describe the pattern in the cross-tabulation.",
      if (ct$p.value < .05) "revealed" else "did not reveal",
      vars[1], vars[2], phi, sframe_effect_label(phi, "r")
    )
  )
}

sframe_run_mann_whitney <- function(data, vars) {
  group_col <- vars[1]
  outcome_col <- vars[2]
  groups <- unique(data[[group_col]][!is.na(data[[group_col]])])
  if (length(groups) != 2) {
    return(list(test = "mann_whitney",
                error = "Mann-Whitney requires exactly two groups."))
  }
  g1 <- suppressWarnings(as.numeric(data[[outcome_col]][data[[group_col]] == groups[1]]))
  g2 <- suppressWarnings(as.numeric(data[[outcome_col]][data[[group_col]] == groups[2]]))
  g1 <- g1[!is.na(g1)]; g2 <- g2[!is.na(g2)]
  wt <- tryCatch(stats::wilcox.test(g1, g2, exact = FALSE), error = function(e) NULL)
  if (is.null(wt)) return(list(test = "mann_whitney", error = "Test failed."))
  n <- length(g1) + length(g2)
  z <- stats::qnorm(wt$p.value / 2)
  r <- abs(z) / sqrt(n)
  list(
    test     = "mann_whitney",
    vars     = vars,
    groups   = as.character(groups),
    n1       = length(g1), n2 = length(g2),
    median1  = stats::median(g1), median2 = stats::median(g2),
    U        = unname(wt$statistic),
    z        = z, p = wt$p.value, r = r,
    effect_label = sframe_effect_label(r, "r"),
    apa      = sprintf(
      "U = %.0f, z = %.2f, p %s, r = %.2f",
      wt$statistic, z, sframe_p_string(wt$p.value), r
    ),
    prompt   = sprintf(
      "The Mann-Whitney test %s a significant difference between %s (Mdn = %.2f) and %s (Mdn = %.2f), U = %.0f, p %s, r = %.2f (%s effect). Interpret the direction and practical significance.",
      if (wt$p.value < .05) "revealed" else "did not reveal",
      groups[1], stats::median(g1),
      groups[2], stats::median(g2),
      wt$statistic, sframe_p_string(wt$p.value),
      r, sframe_effect_label(r, "r")
    )
  )
}

sframe_run_t_test <- function(data, vars) {
  group_col <- vars[1]
  outcome_col <- vars[2]
  groups <- unique(data[[group_col]][!is.na(data[[group_col]])])
  if (length(groups) != 2) {
    return(list(test = "t_test_ind",
                error = "Independent t-test requires exactly two groups."))
  }
  g1 <- suppressWarnings(as.numeric(data[[outcome_col]][data[[group_col]] == groups[1]]))
  g2 <- suppressWarnings(as.numeric(data[[outcome_col]][data[[group_col]] == groups[2]]))
  g1 <- g1[!is.na(g1)]; g2 <- g2[!is.na(g2)]
  tt <- tryCatch(stats::t.test(g1, g2), error = function(e) NULL)
  if (is.null(tt)) return(list(test = "t_test_ind", error = "Test failed."))
  d <- sframe_cohens_d(g1, g2)
  list(
    test     = "t_test_ind",
    vars     = vars,
    groups   = as.character(groups),
    n1       = length(g1), n2 = length(g2),
    mean1    = mean(g1), mean2 = mean(g2),
    sd1      = stats::sd(g1), sd2 = stats::sd(g2),
    t        = unname(tt$statistic),
    df       = unname(tt$parameter),
    p        = tt$p.value, d = d,
    effect_label = sframe_effect_label(d, "d"),
    apa      = sprintf(
      "t(%.2f) = %.2f, p %s, d = %.2f",
      tt$parameter, tt$statistic, sframe_p_string(tt$p.value), d
    ),
    prompt   = sprintf(
      "The independent-samples t-test %s a significant difference between %s (M = %.2f, SD = %.2f) and %s (M = %.2f, SD = %.2f), t(%.2f) = %.2f, p %s, d = %.2f (%s effect). Discuss the direction and magnitude.",
      if (tt$p.value < .05) "revealed" else "did not reveal",
      groups[1], mean(g1), stats::sd(g1),
      groups[2], mean(g2), stats::sd(g2),
      tt$parameter, tt$statistic,
      sframe_p_string(tt$p.value), d, sframe_effect_label(d, "d")
    )
  )
}

sframe_run_kruskal <- function(data, vars) {
  group_col <- vars[1]
  outcome_col <- vars[2]
  outcome <- suppressWarnings(as.numeric(data[[outcome_col]]))
  group   <- data[[group_col]]
  complete <- !is.na(outcome) & !is.na(group)
  kt <- tryCatch(
    stats::kruskal.test(outcome[complete] ~ as.factor(group[complete])),
    error = function(e) NULL
  )
  if (is.null(kt)) return(list(test = "kruskal_wallis", error = "Test failed."))
  n <- sum(complete)
  eta2 <- (kt$statistic - length(unique(group[complete])) + 1) / (n - length(unique(group[complete])))
  eta2 <- max(0, unname(eta2))
  list(
    test     = "kruskal_wallis",
    vars     = vars,
    H        = unname(kt$statistic),
    df       = unname(kt$parameter),
    p        = kt$p.value,
    eta2     = eta2,
    effect_label = sframe_effect_label(eta2, "eta2"),
    apa      = sprintf(
      "H(%d) = %.2f, p %s, \u03b7\u00b2 = %.3f",
      kt$parameter, kt$statistic, sframe_p_string(kt$p.value), eta2
    ),
    prompt   = sprintf(
      "The Kruskal-Wallis test %s a significant difference across groups, H(%d) = %.2f, p %s, \u03b7\u00b2 = %.3f (%s effect). If significant, describe which groups differed and in what direction.",
      if (kt$p.value < .05) "revealed" else "did not reveal",
      kt$parameter, kt$statistic,
      sframe_p_string(kt$p.value), eta2, sframe_effect_label(eta2, "eta2")
    )
  )
}

sframe_run_correlation <- function(data, vars, method = "pearson") {
  x <- suppressWarnings(as.numeric(data[[vars[1]]]))
  y <- suppressWarnings(as.numeric(data[[vars[2]]]))
  complete <- !is.na(x) & !is.na(y)
  n <- sum(complete)
  ct <- tryCatch(
    suppressWarnings(stats::cor.test(x[complete], y[complete], method = method)),
    error = function(e) NULL
  )
  if (is.null(ct)) return(list(test = paste0("correlation_", method), error = "Test failed."))
  r <- unname(ct$estimate)
  sym <- if (method == "pearson") "r" else "r_s"
  list(
    test     = paste0("correlation_", method),
    vars     = vars,
    method   = method,
    n        = n,
    r        = r,
    df       = n - 2,
    p        = ct$p.value,
    effect_label = sframe_effect_label(abs(r), "r"),
    apa      = sprintf(
      "%s(%d) = %.2f, p %s",
      sym, n - 2, r, sframe_p_string(ct$p.value)
    ),
    prompt   = sprintf(
      "There was a %s, %s %s correlation between %s and %s, %s(%d) = %.2f, p %s. Explain what this means for your research question.",
      if (r > 0) "positive" else "negative",
      sframe_effect_label(abs(r), "r"),
      if (ct$p.value < .05) "significant" else "non-significant",
      vars[1], vars[2],
      sym, n - 2, r, sframe_p_string(ct$p.value)
    )
  )
}

sframe_run_regression <- function(data, vars) {
  outcome <- suppressWarnings(as.numeric(data[[vars[length(vars)]]]))
  predictors <- vars[-length(vars)]
  pred_data <- as.data.frame(lapply(data[predictors], function(x) {
    suppressWarnings(as.numeric(x))
  }))
  pred_data[[vars[length(vars)]]] <- outcome
  complete <- complete.cases(pred_data)
  n <- sum(complete)
  formula_str <- paste(vars[length(vars)], "~",
                       paste(predictors, collapse = " + "))
  fit <- tryCatch(
    stats::lm(stats::as.formula(formula_str), data = pred_data[complete, ]),
    error = function(e) NULL
  )
  if (is.null(fit)) return(list(test = "regression_linear", error = "Regression failed."))
  s <- summary(fit)
  f_stat <- s$fstatistic
  p_val  <- stats::pf(f_stat[1], f_stat[2], f_stat[3], lower.tail = FALSE)
  list(
    test     = "regression_linear",
    vars     = vars,
    n        = n,
    r2       = s$r.squared,
    adj_r2   = s$adj.r.squared,
    F        = unname(f_stat[1]),
    df1      = unname(f_stat[2]),
    df2      = unname(f_stat[3]),
    p        = p_val,
    coefficients = as.data.frame(s$coefficients),
    apa      = sprintf(
      "R\u00b2 = %.3f, F(%d, %d) = %.2f, p %s",
      s$r.squared, f_stat[2], f_stat[3], f_stat[1], sframe_p_string(p_val)
    ),
    prompt   = sprintf(
      "The regression model %s (R\u00b2 = %.3f, F(%d, %d) = %.2f, p %s). Interpret the direction and significance of each predictor and discuss the variance explained.",
      if (p_val < .05) "was statistically significant" else "was not statistically significant",
      s$r.squared, f_stat[2], f_stat[3], f_stat[1], sframe_p_string(p_val)
    )
  )
}

# ---------------------------------------------------------------------------
# Dispatcher
# ---------------------------------------------------------------------------

sframe_run_one_block <- function(block, data) {
  test <- block$test
  vars <- block$variables

  result <- tryCatch({
    switch(test,
      frequency          = sframe_run_frequency(data, vars),
      crosstab           = sframe_run_crosstab(data, vars),
      chi_square         = sframe_run_crosstab(data, vars),
      mann_whitney       = sframe_run_mann_whitney(data, vars),
      t_test_ind         = sframe_run_t_test(data, vars),
      kruskal_wallis     = sframe_run_kruskal(data, vars),
      correlation_pearson  = sframe_run_correlation(data, vars, "pearson"),
      correlation_spearman = sframe_run_correlation(data, vars, "spearman"),
      regression_linear    = sframe_run_regression(data, vars),
      list(test = test, error = paste0("Test '", test, "' is not yet implemented."))
    )
  }, error = function(e) {
    list(test = test, error = conditionMessage(e))
  })

  result$research_question <- block$research_question
  result$block_id          <- block$id
  result$interpretation    <- block$interpretation %||% ""
  result$citations         <- sframe_citations_for_test(test)
  result
}

#' Run a pre-planned analysis from an instrument's analysis plan
#'
#' Executes every analysis block defined in the instrument's `analysis_plan`
#' slot against the supplied response data. Each block corresponds to one
#' research question defined during instrument design in the SurveyBuilder.
#' Results include APA-formatted statistics, effect sizes, interpretation
#' prompts, and pre-populated citations.
#'
#' @param data A `tibble` or `data.frame` of responses, typically produced by
#'   [read_responses()] or [read_sheet_responses()].
#' @param instrument An `sframe` object containing an `analysis_plan`.
#' @param scored Logical. Whether to automatically score scales before running
#'   the analysis. Defaults to `TRUE`.
#'
#' @return An object of class `sframe_analysis_results`, a list with one
#'   element per analysis block. Each element contains the test result,
#'   APA string, interpretation prompt, and citations. Pass to
#'   [render_results()] to generate a formatted report.
#' @export
#' @seealso [render_results()], [read_sheet_responses()]
#'
#' @examples
#' \dontrun{
#' responses <- read_sheet_responses("your-sheet-id", instr)
#' results   <- run_analysis_plan(responses, instr)
#' render_results(results, instr, output_file = "results.html")
#' }
run_analysis_plan <- function(data, instrument, scored = TRUE) {
  stopifnot(inherits(instrument, "sframe"))
  stopifnot(is.data.frame(data))

  plan <- instrument$analysis_plan
  if (is.null(plan) || length(plan) == 0) {
    rlang::abort(
      "No analysis plan found in this instrument. Define research questions in the SurveyBuilder Analyse menu before running.",
      class = "sframe_error"
    )
  }

  # Score scales first if requested
  if (scored && length(instrument$scales) > 0) {
    data <- tryCatch(
      score_scales(data, instrument, keep_items = TRUE, keep_meta = TRUE),
      error = function(e) {
        sframe_warn_scoring("Scale scoring failed before analysis: skipping.")
        data
      }
    )
  }

  results <- lapply(plan, sframe_run_one_block, data = data)
  structure(results, class = "sframe_analysis_results")
}

#' @exportS3Method print sframe_analysis_results
print.sframe_analysis_results <- function(x, ...) {
  cat(sprintf("Analysis Results: %d research question(s)\n\n", length(x)))
  for (i in seq_along(x)) {
    r <- x[[i]]
    cat(sprintf("RQ %d: %s\n", i, r$research_question %||% "(untitled)"))
    if (!is.null(r$error)) {
      cat(sprintf("  Error: %s\n\n", r$error))
    } else {
      cat(sprintf("  Test: %s\n", r$test))
      cat(sprintf("  APA:  %s\n\n", r$apa %||% ""))
    }
  }
  invisible(x)
}

#' Render analysis results to a formatted HTML report
#'
#' Generates a self-contained HTML report from the output of
#' [run_analysis_plan()]. Each section corresponds to one research question
#' and includes the APA-formatted statistical result, an interpretation space,
#' and a reference list.
#'
#' @param results An `sframe_analysis_results` object from [run_analysis_plan()].
#' @param instrument An `sframe` object.
#' @param output_file Character or NULL. Path to the output HTML file. When
#'   NULL, a temporary file is written and its path returned.
#' @param output_path Character or NULL. Alias for `output_file`.
#' @param citation_format Character. Reference format. One of `"apa"`,
#'   `"ama"`, or `"vancouver"`. Defaults to `"apa"`.
#' @param title Character or NULL. Report title. Defaults to the instrument
#'   title with " -- Results" appended.
#'
#' @return The output file path, invisibly.
#' @export
#' @seealso [run_analysis_plan()], [render_report()]
#'
#' @examples
#' \dontrun{
#' results <- run_analysis_plan(responses, instr)
#' render_results(results, instr, output_file = "results.html")
#' }
render_results <- function(
    results         = NULL,
    instrument,
    output_file     = NULL,
    output_path     = NULL,
    citation_format = c("apa", "ama", "vancouver"),
    title           = NULL
) {
  stopifnot(inherits(instrument, "sframe"))
  citation_format <- rlang::arg_match(citation_format)

  dest <- output_file %||% output_path %||% tempfile(fileext = ".html")

  # If called with instrument only (no pre-computed results), delegate
  if (is.null(results)) {
    return(render_report(instrument, output_file = dest))
  }

  stopifnot(inherits(results, "sframe_analysis_results"))
  report_title <- title %||% paste0(instrument$meta$title, " -- Results")

  # Collect all unique citations
  all_citations <- list()
  for (r in results) {
    for (cit_key in names(r$citations %||% list())) {
      all_citations[[cit_key]] <- r$citations[[cit_key]]
    }
  }

  # Build HTML sections
  sections_html <- paste(vapply(seq_along(results), function(i) {
    r <- results[[i]]
    rq <- htmltools_escape(r$research_question %||% paste("Research Question", i))
    apa_str <- r$apa %||% ""
    prompt  <- r$interpretation_prompt %||% r$prompt %||% ""
    interp  <- r$interpretation %||% ""
    cits    <- paste(unlist(r$citations), collapse = "<br>")

    if (!is.null(r$error)) {
      return(sprintf(
        '<section class="rq-block"><h2>RQ %d: %s</h2>
         <div class="error-box">Error: %s</div></section>',
        i, rq, htmltools_escape(r$error)
      ))
    }

    # Build results table
    tbl_html <- ""
    if (!is.null(r$table) && is.data.frame(r$table)) {
      rows <- paste(apply(r$table, 1, function(row) {
        cells <- paste(sprintf("<td>%s</td>", htmltools_escape(as.character(row))),
                      collapse = "")
        sprintf("<tr>%s</tr>", cells)
      }), collapse = "")
      headers <- paste(sprintf("<th>%s</th>", htmltools_escape(colnames(r$table))),
                      collapse = "")
      tbl_html <- sprintf(
        '<table class="results-table"><thead><tr>%s</tr></thead><tbody>%s</tbody></table>',
        headers, rows
      )
    }

    effect_badge <- ""
    if (!is.null(r$effect_label)) {
      effect_badge <- sprintf(
        '<span class="effect-badge effect-%s">%s effect</span>',
        r$effect_label, r$effect_label
      )
    }

    sprintf(
      '<section class="rq-block">
        <div class="rq-header">
          <span class="rq-number">RQ %d</span>
          <h2>%s</h2>
        </div>
        <div class="result-box">
          <div class="apa-string">%s %s</div>
          %s
        </div>
        <div class="interpretation-section">
          <h3>Interpretation</h3>
          <div class="prompt-box">%s</div>
          <div class="interp-text">%s</div>
        </div>
        <div class="citations-section">
          <h4>References</h4>
          <div class="citation-list">%s</div>
        </div>
      </section>',
      i, rq, htmltools_escape(apa_str), effect_badge,
      tbl_html,
      htmltools_escape(prompt),
      if (nzchar(interp)) htmltools_escape(interp) else
        '<span class="empty-interp">Your interpretation will appear here.</span>',
      cits
    )
  }, character(1)), collapse = "\n")

  references_html <- if (length(all_citations) > 0) {
    items <- paste(sprintf('<li>%s</li>', unlist(all_citations)), collapse = "\n")
    sprintf('<section class="references"><h2>References</h2><ol>%s</ol></section>', items)
  } else ""

  html <- sprintf('<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>%s</title>
<style>
  body { font-family: "Helvetica Neue", Arial, sans-serif; max-width: 860px;
         margin: 0 auto; padding: 32px 24px; color: #1a1a2e; line-height: 1.6; }
  h1 { font-size: 26px; border-bottom: 3px solid #1a1a2e; padding-bottom: 12px; }
  h2 { font-size: 19px; color: #1a1a2e; margin-top: 0; }
  h3 { font-size: 15px; color: #444; margin: 16px 0 8px; }
  h4 { font-size: 13px; color: #666; margin: 12px 0 6px; }
  .rq-block { background: #fff; border: 1px solid #e0e3ea; border-radius: 10px;
               padding: 28px; margin-bottom: 28px;
               box-shadow: 0 1px 4px rgba(0,0,0,.07); }
  .rq-header { display: flex; align-items: flex-start; gap: 14px; margin-bottom: 20px; }
  .rq-number { background: #1a1a2e; color: #fff; border-radius: 20px;
                padding: 4px 12px; font-size: 12px; font-weight: 700;
                white-space: nowrap; margin-top: 3px; }
  .result-box { background: #f0f4ff; border-left: 4px solid #5b8dee;
                 padding: 14px 18px; border-radius: 0 8px 8px 0; margin-bottom: 18px; }
  .apa-string { font-family: "Georgia", serif; font-size: 15px; color: #1a1a2e; }
  .effect-badge { display: inline-block; margin-left: 10px; padding: 2px 9px;
                   border-radius: 12px; font-size: 12px; font-weight: 600; }
  .effect-negligible { background: #f5f5f5; color: #666; }
  .effect-small      { background: #e8f5e9; color: #2e7d32; }
  .effect-medium     { background: #fff3e0; color: #e65100; }
  .effect-large      { background: #fce4ec; color: #c62828; }
  .interpretation-section { margin-bottom: 16px; }
  .prompt-box { background: #fffde7; border: 1px solid #f9a825;
                 border-radius: 6px; padding: 10px 14px; font-size: 13px;
                 color: #5d4037; margin-bottom: 10px; }
  .prompt-box::before { content: "Writing prompt: "; font-weight: 700; }
  .interp-text { font-size: 15px; color: #333; padding: 8px 0; }
  .empty-interp { color: #aaa; font-style: italic; }
  .citations-section { border-top: 1px solid #eee; padding-top: 12px; }
  .citation-list { font-size: 13px; color: #555; line-height: 1.8; }
  .results-table { width: 100%%; border-collapse: collapse; font-size: 14px;
                    margin: 12px 0; }
  .results-table th { background: #1a1a2e; color: #fff; padding: 8px 12px;
                       text-align: left; }
  .results-table td { padding: 7px 12px; border-bottom: 1px solid #eee; }
  .results-table tr:nth-child(even) td { background: #f7f8fa; }
  .error-box { background: #fde8e8; border-left: 4px solid #b91c1c;
                padding: 10px 14px; border-radius: 0 6px 6px 0; color: #7f1d1d; }
  .references { margin-top: 40px; border-top: 2px solid #eee; padding-top: 20px; }
  .references ol { padding-left: 20px; }
  .references li { font-size: 14px; margin-bottom: 8px; color: #333; }
  .meta { color: #777; font-size: 13px; margin-bottom: 32px; }
</style>
</head>
<body>
<h1>%s</h1>
<div class="meta">
  Instrument: %s v%s &nbsp;|&nbsp;
  Generated: %s &nbsp;|&nbsp;
  surveyframe package
</div>
%s
%s
</body>
</html>',
    report_title, report_title,
    instrument$meta$title, instrument$meta$version,
    format(Sys.Date(), "%B %d, %Y"),
    sections_html, references_html
  )

  writeLines(html, dest)
  invisible(dest)
}

# Simple HTML escaping without htmltools dependency
htmltools_escape <- function(x) {
  if (length(x) == 0) return("")
  x <- as.character(x)
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub('"', "&quot;", x, fixed = TRUE)
  paste(x, collapse = " ")
}
