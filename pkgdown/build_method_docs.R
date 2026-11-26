# pkgdown/build_method_docs.R
# The Docs section's method-family pages: 1
# page per family of analysis methods, each method a section with its Plan
# dialog in SurveyStudio (roles, alpha, hypotheses and decision rule), what it
# answers, the family's assumptions, the plan excerpt, a report shell with no
# numbers, and its references. Screenshots go to pkgdown/assets/docs/methods/
# (site only), pages to vignettes/articles/docs/methods/<family>.Rmd, and the
# family list is appended to the Docs landing page. Separate pages per method
# are 0.4.4, from this script.
#
# Run from the repository root, after build_docs.R:  Rscript pkgdown/build_method_docs.R

pkg_root <- normalizePath(".")
pkgload::load_all(pkg_root, quiet = TRUE)
stopifnot(requireNamespace("chromote", quietly = TRUE))

families <- list(
  "group-comparisons" = list(title = "Compare groups",
    plan = "Set the outcome, a numeric answer, and the grouping variable, a single-choice answer. Two-way ANOVA takes a second grouping variable, and ANCOVA a numeric covariate.",
    answers = "These methods test whether an outcome differs between 2 or more groups of respondents.",
    assumptions = "Use responses from independent respondents. The t-test and ANOVA assume a roughly normal outcome in each group and similar spread, the rank-based tests do not. ANCOVA adds a straight-line relation with the covariate.",
    methods = c("t_test_ind", "mann_whitney", "anova_one", "kruskal_wallis", "anova_two", "ancova")),
  "repeated-measures" = list(title = "Compare the same people over time",
    plan = "Set 2 or more measurements of the same respondents, each its own question, such as a rating before and after.",
    answers = "These methods test whether answers change between 2 or more measurements of the same respondents.",
    assumptions = "Measure each respondent every time. The paired t-test and repeated measures ANOVA assume roughly normal differences, the rank-based tests do not. McNemar and Cochran's Q take yes or no answers.",
    methods = c("t_test_pair", "wilcoxon_pair", "mcnemar", "repeated_anova", "friedman", "cochran_q")),
  "associations" = list(title = "Test an association between categories",
    plan = "Set 2 single-choice answers, 1 for the rows of the table and 1 for its columns.",
    answers = "These methods test whether 2 categorical answers go together.",
    assumptions = "Use responses from independent respondents. The chi-square test needs expected counts of about 5 or more per cell, Fisher's exact test does not.",
    methods = c("crosstab", "chi_square", "fisher_exact")),
  "correlations" = list(title = "Measure how answers go together",
    plan = "Set 2 numeric or ordered answers. Partial correlation takes a third answer to hold constant.",
    answers = "These methods measure how strongly 2 numeric or ordered answers move together, and whether that holds with a third held constant.",
    assumptions = "Pearson's r assumes a straight-line relation, the rank correlations a steady direction. A correlation shows association, and a claim of cause needs a design that tests it.",
    methods = c("correlation_pearson", "correlation_spearman", "correlation_kendall", "partial_correlation")),
  "regression" = list(title = "Predict an outcome",
    plan = "Set the outcome and 1 or more predictors. The outcome picks the model: a number for linear regression, a yes or no for binary logistic, an ordered rating for ordinal logistic, and a choice of 3 or more categories for multinomial logistic.",
    answers = "These methods estimate how much predictors explain a numeric outcome, or how they change the odds of a yes, an ordered rating or a choice.",
    assumptions = "Use independent respondents and predictors that are only loosely related to each other. For linear regression, use a straight-line relation with roughly normal residuals. Firth's correction suits small samples and rare outcomes.",
    methods = c("regression_linear", "regression_logistic_binary", "regression_logistic_ordinal",
                "regression_logistic_multinomial", "firth_logistic")),
  "scales-reliability" = list(title = "Score a scale and check its reliability",
    plan = "Choose the scale. Its items, shared answer set and reverse-scored items come from the scale defined on the Design screen.",
    answers = "These methods give a scale's score and test whether its items hold together.",
    assumptions = "Use items that measure 1 idea, with reverse-worded items scored back. Alpha assumes items contribute equally, omega does not.",
    methods = c("scale_descriptives", "reliability_alpha", "reliability_omega", "item_diagnostics")),
  "factor-models" = list(title = "Check structure and write model syntax",
    plan = "For factor analysis, set the items. For model syntax, choose the saved model. For mediation and moderation, set the predictor, the mediator or moderator, and the outcome.",
    answers = "These methods check whether items measure the factors assumed, write the lavaan or seminr syntax for a declared model, and estimate mediation and moderation.",
    assumptions = "Use enough respondents for the number of items, and use items that correlate. surveyframe writes the CFA, SEM and PLS-SEM syntax, and you fit it in lavaan or seminr. It estimates factor analysis, mediation and moderation itself.",
    methods = c("efa_readiness", "efa_solution", "cfa_lavaan_syntax", "sem_lavaan_syntax", "seminr_syntax",
                "pls_sem", "mediation", "moderation")),
  "describing-data" = list(title = "Describe the answers and their quality",
    plan = "Set the answers to describe. Missing data and quality checks cover the whole response set.",
    answers = "These methods describe who answered what, how complete the answers are, and which responses the quality checks flag.",
    assumptions = "None beyond the data: these describe, they do not test.",
    methods = c("frequency", "descriptives", "missing_data", "quality")),
  "text-analysis" = list(title = "Analyse open answers",
    plan = "Set the text question. A comparison of groups takes a grouping variable, and keyword in context a key word.",
    answers = "These methods find the words, phrases, contexts, tones and topics in open answers.",
    assumptions = "Use enough text per answer for the method. Topic models need many answers.",
    methods = c("term_freq", "ngram_freq", "term_context", "co_occurrence", "co_occurrence_network",
                "tidy_sentiment", "quanteda_dfm", "topic_model_lda", "stm_topics")),
  "decisions" = list(title = "Choose between options",
    plan = "Set the criteria weight or pairwise comparison question for the weights, and each option\x27s score on each criterion for the ranking.",
    answers = "These methods weigh each criterion and rank the options.",
    assumptions = "Use consistent pairwise judgements, with a consistency ratio below .10, and give each option a performance score on each criterion.",
    methods = c("ahp", "anp", "dematel", "topsis", "vikor", "moora", "smart", "waspas", "promethee", "electre"))
)

# Methods that return model syntax to fit elsewhere, not estimates (R/analysis_plan.R).
syntax_methods <- c("cfa_lavaan_syntax", "sem_lavaan_syntax", "seminr_syntax", "pls_sem")
shot_dir <- file.path("pkgdown", "assets", "docs", "methods")
page_dir <- file.path("vignettes", "articles", "docs", "methods")
dir.create(shot_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(page_dir, recursive = TRUE, showWarnings = FALSE)
js <- function(b, code) b$Runtime$evaluate(code, returnByValue = TRUE)$result$value
wait_for <- function(b, cond, secs = 30) {
  for (i in seq_len(secs * 5)) {
    if (isTRUE(tryCatch(js(b, cond), error = function(e) FALSE))) return(TRUE)
    Sys.sleep(0.2)
  }
  stop("Timed out waiting for: ", cond)
}

# The first demo block that declares each method.
where <- list()
for (nm in sframe_list_demos()$name) {
  ins <- sframe_demo(nm, preview = FALSE)$instrument
  for (b in ins$analysis_plan) {
    m <- sframe_analysis_method(b)
    if (is.null(where[[m]])) where[[m]] <- list(demo = nm, block = b, instrument = ins)
  }
}

# The Plan dialogs are taken in SurveyStudio's Plan screen, 1280 by 1500 so
# the whole dialog shows, from the research question to the decision rule.
source(file.path("pkgdown", "studio_capture.R"))
PLAN_H <- 1500L
# 1 SurveyStudio at a time, reopened only when the demo changes: each is a
# background R process, and holding 1 per demo ran out of time and memory.
current <- NULL
current_demo <- ""
open_studio_plan <- function(demo) {
  if (identical(demo, current_demo)) return(current)
  if (!is.null(current)) studio_close(current)
  current <<- studio_open(pkg_root, demo, height = PLAN_H)
  current_demo <<- demo
  studio_to_plan(current$b)
  current
}

for (fam in names(families)) {
  f <- families[[fam]]
  cat(fam, "\n")
  sections <- character(0)
  for (m in f$methods) {
    w <- where[[m]]
    words <- sframe_method_words(m)
    # pls_sem returns the seminr syntax, as seminr_syntax does.
    if (m %in% syntax_methods && !grepl("syntax", words)) words <- paste(words, "syntax")
    refs <- unlist(sframe_citations_for_test(m))
    refs <- refs[!grepl("^R Core Team|^Sharafuddin", refs)]
    shot_md <- character(0)
    excerpt <- character(0)
    if (!is.null(w)) {
      s <- open_studio_plan(w$demo)
      builder_js(s$b, sprintf("try{closeModal('m-rq')}catch(e){}; openRQModal('%s'); true", w$block$id))
      studio_wait(s$b, "(function(){var m=document.getElementById('m-rq');return !!m&&getComputedStyle(m).display!=='none';})()", secs = 30, frame = TRUE)
      studio_blur(s$b)
      Sys.sleep(1)
      out <- file.path(shot_dir, paste0(m, ".png"))
      s$b$screenshot(filename = out, cliprect = c(0, 0, STUDIO_W, PLAN_H))
      studio_shrink(out, colors = 128L)
      shot_md <- c(sprintf("![SurveyStudio's Plan screen with the Edit Analysis Plan dialog for a %s research question, from the `%s` demo.](../../../docs/methods/%s.png){width=90%%}",
                           words, w$demo, m), "")
      d <- sframe_plan_declaration(w$block)
      excerpt <- c(sprintf("> **%s.** %s", w$block$id, w$block$research_question),
                   if (length(d)) sprintf("> **%s:** %s", names(d), d), "")
    }
    sections <- c(sections,
      sprintf("## %s", words), "",
      shot_md,
      if (length(excerpt)) c("In the pre-analysis plan:", "", excerpt),
      if (m %in% syntax_methods) "In the report: the model syntax, ready for you to fit in lavaan or seminr." else "In the report: the APA 7 sentence and a table, with a chart where the method has one, each titled with the research question.", "",
      if (length(refs)) c(paste0("References: ", paste(refs, collapse = " ")), ""))
  }
  rmd <- c("---", sprintf("title: \"%s\"", f$title), sprintf("description: \"%s\"", f$answers), "---", "",
           "[Documentation](../../docs.html) / [Methods](../../docs.html#methods)", "",
           f$answers, "",
           paste0("**Assumptions.** ", f$assumptions), "",
           paste("In SurveyStudio, open **Plan** on the Design screen, add a research question and choose the method.", f$plan, "Declare the hypotheses and the decision rule before collecting responses."), "",
           sections)
  writeLines(rmd, file.path(page_dir, paste0(fam, ".Rmd")))
}
if (!is.null(current)) studio_close(current)

landing <- file.path("vignettes", "articles", "docs.Rmd")
lines <- readLines(landing)
cut <- grep("^## Methods", lines)
if (length(cut)) lines <- lines[seq_len(cut[1] - 1)]
lines <- c(lines, sprintf("## Methods (%d pages) {#methods}", length(families)), "",
           "Not sure which? [Choose a method](docs/methods/choose-a-method.html) goes from the research question to the method.", "",
           vapply(names(families), function(k) sprintf("- [%s](docs/methods/%s.html)", families[[k]]$title, k), character(1)), "")
writeLines(lines, landing)
cat("Wrote", length(families), "method-family pages.\n")
