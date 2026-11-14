# R/plan_document.R
# The pre-analysis plan (Session 10, owner 2026-11-10, coordinator spec and
# ruling 2026-11-14): render_report(instrument) with no data writes a plan a
# student can submit to OSF, Zenodo or an ethics committee, not a results
# page. 1 document, built here as a list of blocks, written as Markdown for
# Quarto (HTML, PDF, Word, OpenDocument) and as HTML for the built-in
# fallback, so both engines say the same thing:
#   1 title page: title, authors, version, date, the hash and how to verify
#   2 study  3 participant information  4 the questionnaire, branching in
#   words  5 scales and scoring  6 the pre-declared analyses  7 models and
#   amendments  8 references  9 to complete before submission.

sframe_verify_url <- "https://surveyframe.org/verify"

# Item types in words.
sframe_type_words <- c(
  likert = "Rating scale", single_choice = "Single choice",
  multiple_choice = "Multiple choice", numeric = "Number",
  text = "Short text", textarea = "Long text", date = "Date",
  matrix = "Grid of rating scales", slider = "Slider", ranking = "Ranking",
  rating = "Star rating", pairwise_comparison = "Pairwise comparison",
  criteria_weight = "Criteria weights")

# Methods in plain words, for a reader who does not know the codes.
sframe_method_words <- function(method) {
  words <- c(
    frequency = "Frequencies and percentages", descriptives = "Descriptive statistics",
    missing_data = "Missing-data summary", quality = "Response quality checks",
    scale_descriptives = "Scale score descriptive statistics",
    reliability_alpha = "Cronbach's alpha (internal consistency)",
    reliability_omega = "McDonald's omega (internal consistency)",
    item_diagnostics = "Item diagnostics", crosstab = "Cross-tabulation",
    t_test_ind = "Independent samples t-test", mann_whitney = "Mann-Whitney U test",
    t_test_pair = "Paired samples t-test", wilcoxon_pair = "Wilcoxon signed-rank test",
    mcnemar = "McNemar test", anova_one = "One-way ANOVA",
    kruskal_wallis = "Kruskal-Wallis test", anova_two = "Two-way ANOVA",
    ancova = "Analysis of covariance (ANCOVA)", repeated_anova = "Repeated measures ANOVA",
    friedman = "Friedman test", chi_square = "Chi-square test of association",
    fisher_exact = "Fisher's exact test", correlation_pearson = "Pearson correlation",
    correlation_spearman = "Spearman rank correlation",
    correlation_kendall = "Kendall rank correlation", partial_correlation = "Partial correlation",
    regression_linear = "Linear regression", regression_logistic_binary = "Binary logistic regression",
    regression_logistic_ordinal = "Ordinal logistic regression",
    regression_logistic_multinomial = "Multinomial logistic regression",
    firth_logistic = "Firth logistic regression", cochran_q = "Cochran's Q test",
    efa_readiness = "Factorability checks (KMO and Bartlett's test)",
    efa_solution = "Exploratory factor analysis", cfa_lavaan_syntax = "Confirmatory factor analysis (lavaan syntax)",
    sem_lavaan_syntax = "Structural equation model (lavaan syntax)",
    seminr_syntax = "PLS structural equation model (seminr syntax)",
    pls_sem = "PLS structural equation model", mediation = "Mediation analysis",
    moderation = "Moderation analysis", term_freq = "Word frequencies",
    ngram_freq = "Phrase frequencies", term_context = "Words in context",
    co_occurrence = "Word co-occurrence", co_occurrence_network = "Word co-occurrence network",
    tidy_sentiment = "Sentiment analysis", quanteda_dfm = "Document-feature matrix",
    topic_model_lda = "Topic model (LDA)", stm_topics = "Structural topic model",
    ahp = "Analytic hierarchy process (AHP)", anp = "Analytic network process (ANP)",
    dematel = "DEMATEL", topsis = "TOPSIS", vikor = "VIKOR", moora = "MOORA",
    smart = "SMART", waspas = "WASPAS", promethee = "PROMETHEE", electre = "ELECTRE")
  if (method %in% names(words)) words[[method]] else sframe_method_label(method)
}

# --- blocks -----------------------------------------------------------------
# Each block is a list with a type. Text from the instrument is plain text and
# is escaped by each writer. md = TRUE marks text already in Markdown (the
# method references), which the HTML writer converts.
sframe_pb <- function(type, ...) list(type = type, ...)

sframe_plan_blocks <- function(instrument, title = NULL, authors = NULL,
                               references = NULL) {
  meta <- instrument$meta %||% list()
  out <- list()
  # The instrument's references, the caller's, and each planned method's,
  # so a [@key] in any text resolves to (Author, Year) and the list at the
  # end holds every work the plan relies on.
  ref_index <- sframe_reference_index(instrument, references)
  for (k in sframe_plan_method_keys(instrument)) {
    if (is.null(ref_index[[k]])) ref_index[[k]] <- sframe_builtin_reference(k)
  }
  # The resolver writes HTML entities, turned back into text here so each
  # writer escapes once.
  cite <- function(x) {
    if (!length(x) || !length(ref_index)) return(x)
    out <- sframe_resolve_citations(x, ref_index)
    ifelse(out == x, x, sframe_html_unescape(out))
  }
  add <- function(...) {
    b <- sframe_pb(...)
    if (!isTRUE(b$md)) {
      if (!is.null(b$text)) b$text <- cite(b$text)
      if (!is.null(b$items)) b$items <- cite(b$items)
    }
    out[[length(out) + 1L]] <<- b
  }
  hash <- sframe_hash_value(instrument)
  authors <- as.character(authors %||% meta$authors %||% character(0))
  authors <- authors[!is.na(authors) & nzchar(trimws(authors))]

  # 1 Title page
  add("title", text = title %||% sframe_plan_title(instrument))
  add("kv", label = "Instrument", text = meta$title %||% "Untitled")
  if (length(authors)) add("kv", label = "Authors", text = paste(authors, collapse = ", "))
  add("kv", label = "Version", text = as.character(meta$version %||% instrument$version %||% ""))
  add("kv", label = "Date", text = sframe_plan_date())
  # On its own line, as code, so a PDF neither hyphenates it nor runs it
  # past the margin.
  add("kv", label = "Instrument hash (SHA-256)", text = "")
  add("p", text = paste0("`", hash, "`"), md = TRUE)
  add("p", text = paste0("The hash identifies the instrument file this plan describes. ",
                         "Anyone can check that a .sframe file is the one planned by opening it at ",
                         sframe_verify_url, " or with read_sframe() in R."))

  # 2 Study
  add("h2", text = "Study")
  st <- instrument$study %||% list()
  if (nzchar(meta$description %||% "")) add("kv", label = "Purpose", text = meta$description)
  if (nzchar(st$problem %||% "")) add("kv", label = "Research problem", text = st$problem)
  objs <- st$objectives %||% list()
  trace <- sframe_report_study(instrument)$trace
  if (length(objs) && !(is.data.frame(trace) && nrow(trace))) {
    add("kv", label = "Objectives", text = "")
    add("list", items = vapply(objs, function(o) {
      paste0(o$id %||% "", if (nzchar(o$id %||% "")) ": ", o$text %||% o$objective %||% "")
    }, character(1)))
  }
  if (is.data.frame(trace) && nrow(trace)) {
    add("table", caption = "Objectives and the research questions that serve them", df = trace)
  }
  smp <- st$sampling %||% list()
  if (length(smp)) {
    method <- smp$method %||% ""
    if (identical(method, "other")) method <- smp$method_other %||% "other"
    if (nzchar(smp$population %||% "")) add("kv", label = "Population", text = smp$population)
    if (nzchar(method)) add("kv", label = "Sampling method", text = gsub("_", " ", method))
    if (length(smp$planned_n) == 1 && !is.na(smp$planned_n)) {
      add("kv", label = "Planned sample size", text = as.character(smp$planned_n))
    }
  }
  if (!nzchar(meta$description %||% "") && !length(st)) {
    add("p", text = "The instrument records no study description. Add the study's problem, objectives and sampling plan with sframe_set_study() or on SurveyBuilder's Study panel.")
  }

  # 3 Participant information
  add("h2", text = "Participant information")
  rd <- instrument$render %||% list()
  wl <- rd$welcome %||% list()
  if (nzchar(wl$title %||% "")) add("kv", label = "Welcome title", text = wl$title)
  if (nzchar(wl$intro_text %||% "")) add("kv", label = "Introduction", text = wl$intro_text)
  if (nzchar(wl$consent_text %||% "")) {
    add("kv", label = if (isTRUE(wl$consent_required)) "Consent (required to start)" else "Consent",
        text = wl$consent_text)
  }
  if (nzchar(rd$thankyou$message %||% "")) add("kv", label = "Thank-you message", text = rd$thankyou$message)
  if (!length(wl) && is.null(rd$thankyou$message)) {
    add("p", text = "The instrument holds no welcome, consent or thank-you text.")
  }

  # 4 The questionnaire
  add("h2", text = "The questionnaire")
  add("p", text = "The questions in the order respondents see them.")
  choices <- instrument$choices %||% list()
  names(choices) <- vapply(choices, function(cs) cs$id %||% "", character(1))
  items <- instrument$items %||% list()
  labels <- stats::setNames(vapply(items, function(it) it$label %||% it$id, character(1)),
                            vapply(items, function(it) it$id, character(1)))
  n <- 0L
  qs <- character(0)
  flush <- function() if (length(qs)) { add("olist", items = qs, start = n - length(qs) + 1L); qs <<- character(0) }
  for (it in items) {
    if (identical(it$type, "section_break")) {
      flush(); add("h3", text = it$label %||% "Section")
      if (nzchar(it$section_intro %||% "")) add("p", text = it$section_intro)
      next
    }
    if (identical(it$type, "text_block")) { flush(); add("p", text = it$label %||% ""); next }
    n <- n + 1L
    cs <- choices[[it$choice_set %||% ""]]
    opts <- if (!is.null(cs)) paste0(" Options: ", paste(cs$labels %||% cs$values, collapse = ", "), ".") else ""
    rules <- Filter(function(b) identical(b$item_id, it$id), instrument$branching %||% list())
    rule_txt <- paste(vapply(rules, sframe_branch_words, character(1), labels = labels, choices = choices,
                             items = items), collapse = " ")
    qs <- c(qs, paste0(it$label %||% it$id, " (", sframe_type_words[[it$type]] %||% it$type,
                       if (isTRUE(it$required)) ", required" else "", ").", opts,
                       if (nzchar(rule_txt)) paste0(" ", rule_txt)))
  }
  flush()

  # 5 Scales and scoring
  add("h2", text = "Scales and scoring")
  scales <- instrument$scales %||% list()
  if (length(scales)) {
    add("table", caption = "Scales and how they are scored", df = data.frame(
      Scale = vapply(scales, function(s) paste0(s$label %||% s$id, " (", s$id, ")"), character(1)),
      Items = vapply(scales, function(s) paste(unlist(s$items), collapse = ", "), character(1)),
      Reversed = vapply(scales, function(s) {
        r <- unlist(s$reverse_items %||% character(0)); if (length(r)) paste(r, collapse = ", ") else "none"
      }, character(1)),
      Score = vapply(scales, function(s) if (identical(s$method, "sum")) "sum" else "mean", character(1)),
      `Missing answers` = vapply(scales, function(s) {
        k <- s$min_valid %||% length(s$items)
        if (k >= length(s$items)) paste("all", length(s$items), "items needed")
        else paste("at least", k, "of", length(s$items), "items")
      }, character(1)),
      check.names = FALSE, stringsAsFactors = FALSE))
  } else {
    add("p", text = "The instrument declares no scales.")
  }

  # 6 Pre-declared analyses
  add("h2", text = "Pre-declared analysis plan")
  plan <- instrument$analysis_plan %||% list()
  if (!length(plan)) add("p", text = "The instrument declares no analyses yet.")
  for (i in seq_along(plan)) {
    b <- plan[[i]]
    m <- sframe_analysis_method(b)
    add("h3", text = paste0(b$id %||% paste0("RQ", i), ": ",
                            b$research_question %||% paste("Research question", i)))
    d <- sframe_plan_declaration(b)
    for (l in names(d)) add("kv", label = l, text = d[[l]])
    add("kv", label = "Method", text = sframe_method_words(m))
    vars <- sframe_analysis_vars(b)
    if (length(vars)) add("kv", label = "Variables", text = paste(vars, collapse = ", "))
    alpha <- b$options$alpha
    if (m %in% sframe_inferential_methods) {
      add("kv", label = "Significance level", text = if (is.numeric(alpha) && length(alpha) == 1) {
        paste0("alpha = ", alpha)
      } else "alpha = .05, the package default")
    }
    keys <- setdiff(sframe_method_citation_keys(m), c("r_core", "surveyframe"))
    if (length(keys)) {
      add("kv", label = "Method reference", text = paste0("[@", keys, "]", collapse = " "))
    }
  }

  # 6b The preregistration fields the study declares.
  pr <- instrument$study$preregistration %||% list()
  filled <- Filter(function(f) nzchar(trimws(as.character(pr[[f]] %||% "")[1])), sframe_preregistration_fields)
  alphas <- unique(unlist(lapply(plan, function(b) b$options$alpha)))
  if (length(filled) || length(alphas)) {
    add("h2", text = "Preregistration")
    for (f in filled) add("kv", label = sframe_prereg_labels[[f]], text = as.character(pr[[f]])[1])
    if (length(alphas)) add("kv", label = "Significance level", text = paste0("alpha = ", paste(alphas, collapse = ", ")))
  }
  # 7 Models and amendments
  models <- instrument$models %||% list()
  if (length(models)) {
    add("h2", text = "Models")
    add("list", items = vapply(models, function(md) {
      paste0(md$id %||% "model", " (", gsub("_", " ", md$type %||% ""), ")")
    }, character(1)))
  }
  add("h2", text = "Amendments")
  am <- sframe_report_amendments(instrument)
  if (!is.null(am)) {
    add("table", caption = "Amendments, in the order they were recorded",
        df = am[, c("Date", "Tier", "Reason", "What changed", "Author"), drop = FALSE])
    for (k in seq_len(nrow(am))) {
      if (nzchar(am$`Deviation report`[k])) {
        add("kv", label = sprintf("Deviation report, amendment %d", k), text = am$`Deviation report`[k])
      }
    }
  } else {
    add("p", text = "None. This is the instrument as first planned.")
  }

  # 8 References, with R and surveyframe, which every plan relies on
  for (k in c("r_core", "surveyframe")) ref_index[[k]] <- ref_index[[k]] %||% sframe_builtin_reference(k)
  ref_html <- vapply(ref_index, function(r) {
    sframe_format_reference_html(r) %||% sprintf(
      "Reference '%s' (type %s) could not be formatted. Add its details, or cite it as written.",
      htmltools_escape(r$id), htmltools_escape(r$type %||% "unknown"))
  }, character(1))
  ref_md <- vapply(ref_html, sframe_html_to_md, character(1))
  keep <- !duplicated(ref_md) & nzchar(ref_md)
  ord <- order(tolower(ref_md[keep]))
  add("h2", text = "References")
  add("refs", md = TRUE, items = unname(ref_md[keep][ord]), html = unname(ref_html[keep][ord]))

  # 9 A prompt and a blank line for each field the study does not declare.
  todo <- setdiff(sframe_preregistration_fields, filled)
  if (!length(alphas)) todo <- c(todo, "significance_level")
  if (length(todo)) {
    add("h2", text = "To complete before submission")
    add("p", text = "A preregistration also asks for these. Write each answer on its line before you submit the plan, or add it to the instrument's study.")
    for (f in todo) add("fill", label = sframe_prereg_labels[[f]], text = sframe_prereg_prompts[[f]])
  }
  out
}

# The methods that test a hypothesis against a significance level.
sframe_inferential_methods <- c(
  "crosstab", "t_test_ind", "mann_whitney", "t_test_pair", "wilcoxon_pair",
  "mcnemar", "anova_one", "kruskal_wallis", "anova_two", "ancova",
  "repeated_anova", "friedman", "chi_square", "fisher_exact",
  "correlation_pearson", "correlation_spearman", "correlation_kendall",
  "partial_correlation", "regression_linear", "regression_logistic_binary",
  "regression_logistic_ordinal", "regression_logistic_multinomial",
  "firth_logistic", "cochran_q", "mediation", "moderation")

# The built-in reference keys a method cites, and every planned method's.
sframe_method_citation_keys <- function(method) {
  keys <- vapply(Filter(function(cit) method %in% cit$use, .sframe_citations),
                 function(cit) cit$key, character(1))
  unname(keys[keys %in% names(.sframe_citation_csl)])
}

sframe_plan_method_keys <- function(instrument) {
  unique(unlist(lapply(instrument$analysis_plan %||% list(), function(b) {
    sframe_method_citation_keys(sframe_analysis_method(b))
  })))
}

# The preregistration fields as the plan names them, and the prompt each
# gets when the study does not declare it.
sframe_prereg_labels <- c(
  exclusion_rules = "Exclusion rules", stopping_rule = "Stopping rule",
  primary_outcomes = "Primary outcomes", secondary_outcomes = "Secondary outcomes",
  multiplicity = "Multiplicity", contingency = "Contingency decisions",
  significance_level = "Significance level")
sframe_prereg_prompts <- c(
  exclusion_rules = "which responses will be excluded, and why.",
  stopping_rule = "when data collection ends: a date, a sample size or another rule.",
  primary_outcomes = "the outcomes that answer the main question.",
  secondary_outcomes = "the secondary outcomes.",
  multiplicity = "how the tests are corrected for being run together, if at all.",
  contingency = "what you will do if an assumption fails or the planned sample is not reached.",
  significance_level = "the alpha each test is judged against.")

# The plan's date in words, 14 November 2026, as plan.qmd's title shows it.
sframe_plan_date <- function(date = Sys.Date()) {
  sub("^0", "", format(as.Date(date), "%d %B %Y"))
}

sframe_plan_title <- function(instrument) {
  paste0("Pre-analysis plan: ", instrument$meta$title %||% "Untitled")
}

# A branching rule in words, for the questionnaire section.
sframe_branch_words <- function(b, labels, choices, items) {
  dep <- b$depends_on %||% ""
  dep_item <- Filter(function(it) identical(it$id, dep), items)
  cs <- if (length(dep_item)) choices[[dep_item[[1]]$choice_set %||% ""]] else NULL
  vals <- as.character(unlist(b$value))
  if (!is.null(cs)) {
    lab <- stats::setNames(as.character(cs$labels %||% cs$values), as.character(cs$values))
    vals <- ifelse(vals %in% names(lab), lab[vals], vals)
  }
  op <- switch(b$operator %||% "==", "==" = "is", "!=" = "is not", "%in%" = "is one of",
               ">" = "is more than", "<" = "is less than", ">=" = "is at least",
               "<=" = "is at most", b$operator)
  what <- if (identical(b$action, "hide")) "Hidden when" else "Shown only when"
  paste0(what, " '", labels[[dep]] %||% dep, "' ", op, " ",
         paste(vals, collapse = if (length(vals) > 2) ", " else " or "), ".")
}

sframe_html_to_md <- function(h) {
  h <- gsub("</?(em|i)>", "*", h)
  sframe_html_unescape(gsub("<[^>]+>", "", h))
}

sframe_html_unescape <- function(h) {
  for (e in list(c("&ndash;", "\u2013"), c("&mdash;", "\u2014"), c("&nbsp;", " "),
                 c("&lt;", "<"), c("&gt;", ">"), c("&quot;", "\""), c("&#39;", "'"),
                 c("&amp;", "&"))) {
    h <- gsub(e[1], e[2], h, fixed = TRUE)
  }
  h
}

# --- writers ------------------------------------------------------------------
sframe_md_escape <- function(x) gsub("([\\\\`*_\\[\\]<>#|$])", "\\\\\\1", x, perl = TRUE)

sframe_plan_md <- function(blocks) {
  txt <- function(b) if (isTRUE(b$md)) b$text else sframe_md_escape(b$text)
  unlist(lapply(blocks, function(b) switch(b$type,
    title = character(0),
    h2 = c(paste("##", sframe_md_escape(b$text)), ""),
    h3 = c(paste("###", sframe_md_escape(b$text)), ""),
    p = c(txt(b), ""),
    kv = c(paste0("**", b$label, ":** ", txt(b)), ""),
    list = c(paste0("- ", if (isTRUE(b$md)) b$items else sframe_md_escape(b$items)), ""),
    refs = c(paste0("- ", b$items), ""),
    olist = c(paste0(seq(b$start, length.out = length(b$items)), ". ", sframe_md_escape(b$items)), ""),
    table = c(sframe_md_pipe_table(b$df), "", paste0(": ", b$caption), ""),
    fill = c(paste0("**", b$label, ":** ", sframe_md_escape(b$text)), "",
             if (is.null(b$value)) "\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_"
             else paste0("Declared in the instrument: ", sframe_md_escape(b$value)), ""))))
}

# A pipe table, escaped, with no knitr needed.
sframe_md_pipe_table <- function(df) {
  esc <- function(x) gsub("|", "\\|", sframe_md_escape(as.character(x)), fixed = TRUE)
  c(paste0("| ", paste(esc(names(df)), collapse = " | "), " |"),
    paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
    apply(df, 1, function(r) paste0("| ", paste(esc(r), collapse = " | "), " |")))
}

sframe_plan_html <- function(blocks) {
  e <- htmltools_escape
  md_html <- function(x) {
    x <- gsub("`([^`]+)`", "<code>\\1</code>", e(x))
    gsub("\\*([^*]+)\\*", "<em>\\1</em>", x)
  }
  txt <- function(b) if (isTRUE(b$md)) md_html(b$text) else e(b$text)
  paste(unlist(lapply(blocks, function(b) switch(b$type,
    title = character(0),
    h2 = sprintf("<h2>%s</h2>", e(b$text)),
    h3 = sprintf("<h3>%s</h3>", e(b$text)),
    p = sprintf("<p>%s</p>", txt(b)),
    kv = sprintf("<p><strong>%s:</strong> %s</p>", e(b$label), txt(b)),
    list = sprintf("<ul>%s</ul>", paste(sprintf("<li>%s</li>",
                   if (isTRUE(b$md)) md_html(b$items) else e(b$items)), collapse = "")),
    refs = sprintf("<div class=\"references\">%s</div>",
                   paste(sprintf("<div class=\"csl-entry\">%s</div>", b$html), collapse = "\n")),
    olist = sprintf("<ol start=\"%d\">%s</ol>", b$start, paste(sprintf("<li>%s</li>", e(b$items)), collapse = "")),
    table = .render_report_table(b$df, b$caption),
    fill = sprintf("<p><strong>%s:</strong> %s</p>%s", e(b$label), e(b$text),
                   if (is.null(b$value)) "<p class=\"sf-fill\">&nbsp;</p>"
                   else sprintf("<p>Declared in the instrument: %s</p>", e(b$value)))))),
    collapse = "\n")
}
