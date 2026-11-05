# inst/shiny/app.R
# SurveyStudio - build, edit, preview, and analyse surveyframe instruments.

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

tags <- shiny::tags
HTML <- shiny::HTML
fluidPage <- shiny::fluidPage
fluidRow <- shiny::fluidRow
column <- shiny::column
uiOutput <- shiny::uiOutput
renderUI <- shiny::renderUI
actionButton <- shiny::actionButton
checkboxInput <- shiny::checkboxInput
checkboxGroupInput <- shiny::checkboxGroupInput
dateInput <- shiny::dateInput
downloadButton <- shiny::downloadButton
downloadHandler <- shiny::downloadHandler
fileInput <- shiny::fileInput
numericInput <- shiny::numericInput
observe <- shiny::observe
observeEvent <- shiny::observeEvent
radioButtons <- shiny::radioButtons
reactive <- shiny::reactive
reactiveValues <- shiny::reactiveValues
req <- shiny::req
selectInput <- shiny::selectInput
showNotification <- shiny::showNotification
shinyApp <- shiny::shinyApp
tagList <- shiny::tagList
textAreaInput <- shiny::textAreaInput
textInput <- shiny::textInput
updateCheckboxGroupInput <- shiny::updateCheckboxGroupInput
updateSelectInput <- shiny::updateSelectInput
updateTextAreaInput <- shiny::updateTextAreaInput
updateTextInput <- shiny::updateTextInput
selectizeInput <- shiny::selectizeInput
updateSelectizeInput <- shiny::updateSelectizeInput
plotOutput <- shiny::plotOutput
reactiveVal <- shiny::reactiveVal

builder_empty_state <- sframe_builder_empty_state
builder_state_from_instrument <- sframe_builder_state_from_instrument
builder_validate_draft <- sframe_builder_validate_draft

status_badge <- function(ok, label_ok = "Ready", label_no = "Pending") {
  if (ok) {
    tags$span(class = "badge badge-ok", label_ok)
  } else {
    tags$span(class = "badge badge-wait", label_no)
  }
}

trim_or_null <- function(x) {
  x <- trimws(x %||% "")
  if (nzchar(x)) x else NULL
}

parse_lines <- function(text) {
  if (is.null(text) || !nzchar(text)) {
    return(character(0))
  }
  values <- trimws(unlist(strsplit(text, "\n", fixed = TRUE), use.names = FALSE))
  values[nzchar(values)]
}

# Hypothesis helpers for the plan editor. Placeholders are examples only and
# are never saved. Only text the researcher wrote becomes a hypothesis.
studio_old_hypothesis_text <- c(
  null = "No effect or association is present.",
  alternative = "An effect or association is present."
)

studio_hypothesis_placeholder <- function(method, which = c("null", "alternative")) {
  which <- match.arg(which)
  ex <- if (grepl("^t_test", method %||% "")) {
    c(null = "The mean of [outcome] does not differ between [group A] and [group B].",
      alternative = "The mean of [outcome] differs between [group A] and [group B].")
  } else if (grepl("correlation", method %||% "")) {
    c(null = "[X] and [Y] are not correlated.",
      alternative = "[X] and [Y] are correlated.")
  } else if (grepl("^(anova|kruskal)", method %||% "")) {
    c(null = "The mean of [outcome] is the same in every [group].",
      alternative = "The mean of [outcome] differs in at least one [group].")
  } else if (grepl("chi", method %||% "")) {
    c(null = "[X] and [Y] are independent.",
      alternative = "[X] and [Y] are associated.")
  } else {
    c(null = "Write what you expect if there is no effect.",
      alternative = "Write what you expect if there is an effect.")
  }
  unname(ex[[which]])
}

studio_build_hypotheses <- function(null, alternative) {
  out <- list()
  n <- trim_or_null(null)
  a <- trim_or_null(alternative)
  if (!is.null(n)) out$null <- n
  if (!is.null(a)) out$alternative <- a
  if (length(out) > 0) out else NULL
}

studio_block_hypothesis <- function(block, which = c("null", "alternative")) {
  which <- match.arg(which)
  text <- trimws(as.character(block$hypotheses[[which]] %||% "")[1])
  if (is.na(text) || identical(text, studio_old_hypothesis_text[[which]])) "" else text
}
# The interpretation a saved block already holds. One identical to the
# decision rule came from the old single-box editor, so it counts as unwritten.
studio_saved_interpretation <- function(block) {
  text <- trimws(as.character(block$interpretation %||% "")[1])
  rule <- trimws(as.character(block$decision_rule %||% "")[1])
  if (is.na(text) || identical(text, rule)) "" else text
}
# end studio plan helpers

parse_csv <- function(text) {
  if (is.null(text) || !nzchar(trimws(text))) {
    return(character(0))
  }
  values <- trimws(unlist(strsplit(text, ",", fixed = TRUE), use.names = FALSE))
  values[nzchar(values)]
}

parse_choice_values <- function(text) {
  values <- parse_lines(text)
  if (length(values) == 0) {
    return(values)
  }
  utils::type.convert(values, as.is = TRUE)
}

parse_branch_value <- function(text, operator) {
  raw <- trimws(text %||% "")
  if (!nzchar(raw)) {
    return(NULL)
  }
  if (identical(operator, "%in%")) {
    values <- parse_csv(raw)
    if (length(values) == 0) {
      return(NULL)
    }
    return(utils::type.convert(values, as.is = TRUE))
  }
  utils::type.convert(raw, as.is = TRUE)
}

parse_check_values <- function(text) {
  values <- parse_csv(text %||% "")
  if (length(values) == 0) {
    return(NULL)
  }
  utils::type.convert(values, as.is = TRUE)
}

sframe_upload_ext <- function(upload) {
  tolower(tools::file_ext(upload$name %||% ""))
}

sframe_validate_upload <- function(upload, extensions, max_size = 10 * 1024^2) {
  if (is.null(upload) || is.null(upload$datapath) || !file.exists(upload$datapath)) {
    stop("No file was uploaded. Select a .sframe file and try again.", call. = FALSE)
  }

  ext <- sframe_upload_ext(upload)
  if (!ext %in% extensions) {
    stop(
      paste0(
        "Unsupported file type '.", ext, "'. Expected: .",
        paste(extensions, collapse = ", ."), "."
      ),
      call. = FALSE
    )
  }

  size <- file.info(upload$datapath)$size
  if (is.na(size) || size <= 0 || size > max_size) {
    stop("Uploaded file is empty or too large.", call. = FALSE)
  }

  con <- file(upload$datapath, open = "rb")
  on.exit(close(con), add = TRUE)
  bytes <- readBin(con, what = "raw", n = min(size, 512))
  if (length(bytes) == 0 || any(bytes == as.raw(0))) {
    stop("Upload a .sframe or JSON text file.", call. = FALSE)
  }

  text_start <- sub("^\ufeff", "", rawToChar(bytes))
  if (identical(ext, "sframe") && !startsWith(trimws(text_start), "{")) {
    stop("Uploaded .sframe file must contain JSON.", call. = FALSE)
  }

  normalizePath(upload$datapath, mustWork = TRUE)
}

format_value <- function(x) {
  if (is.null(x) || length(x) == 0) {
    return("")
  }
  paste(as.character(x), collapse = ", ")
}

upsert_component <- function(components, component) {
  if (length(components) == 0) {
    return(list(component))
  }

  ids <- vapply(components, function(x) x$id, character(1))
  idx <- match(component$id, ids)
  if (is.na(idx)) {
    c(components, list(component))
  } else {
    components[[idx]] <- component
    components
  }
}

remove_component <- function(components, id) {
  if (length(components) == 0) {
    return(components)
  }
  Filter(function(component) !identical(component$id, id), components)
}

drop_item_from_builder <- function(builder, item_id) {
  builder$items <- remove_component(builder$items, item_id)

  if (length(builder$scales) > 0) {
    builder$scales <- Filter(function(scale) {
      scale$items <- setdiff(scale$items %||% character(0), item_id)
      scale$reverse_items <- intersect(scale$reverse_items %||% character(0), scale$items)
      length(scale$items) > 0
    }, builder$scales)
  }

  if (length(builder$branching) > 0) {
    builder$branching <- Filter(function(rule) {
      !identical(rule$item_id, item_id) && !identical(rule$depends_on, item_id)
    }, builder$branching)
  }

  if (length(builder$checks) > 0) {
    builder$checks <- Filter(function(check) !identical(check$item_id, item_id), builder$checks)
  }

  builder
}

optional_choices <- function(ids, none_label = "(None)") {
  choices <- stats::setNames(ids, ids)
  c(stats::setNames("", none_label), choices)
}

table_card <- function(title, headers, rows, empty_label, wide = FALSE) {
  tags$div(class = "card",
    tags$div(class = "card-title", title),
    if (length(rows) == 0) {
      tags$p(class = "hint", empty_label)
    } else {
      tags$table(class = if (wide) "sf-table sf-table-wide" else "sf-table",
        tags$thead(tags$tr(do.call(tagList, lapply(headers, tags$th)))),
        tags$tbody(rows)
      )
    }
  )
}

analysis_role <- function(id, label, min = 1, max = 1, levels = "any") {
  list(id = id, label = label, min = min, max = max, levels = levels)
}

analysis_registry <- local({
  role <- analysis_role
  list(
    frequency = list(
      family = "descriptive", label = "Frequency table",
      roles = list(role("variable", "Variables", max = 99, levels = c("nominal", "ordinal", "likert"))),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = character(0),
      output = "Counts, percentages, valid percentages, and missing values.",
      refs = character(0)
    ),
    descriptives = list(
      family = "descriptive", label = "Descriptives",
      roles = list(
        role("variables", "Variables", max = 99, levels = c("continuous", "scale", "ordinal", "likert")),
        role("split_by", "Split by", min = 0, max = 1, levels = c("nominal", "ordinal"))
      ),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = character(0),
      output = "N, valid N, missing N, mean, SD, median, IQR, range, skewness, kurtosis, SE, and CI.",
      refs = character(0)
    ),
    missing_data = list(
      family = "data_quality", label = "Missing values",
      roles = list(role("variables", "Variables", min = 0, max = 99, levels = "any")),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = character(0),
      output = "Item missingness, respondent missingness, missing patterns, and deletion summary.",
      refs = character(0)
    ),
    quality = list(
      family = "data_quality", label = "Quality report",
      roles = list(role("variables", "Variables", min = 0, max = 99, levels = "any")),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = character(0),
      output = "Attention checks, response quality flags, and quality summary.",
      refs = character(0)
    ),
    scale_descriptives = list(
      family = "descriptive", label = "Scale descriptives",
      roles = list(role("scales", "Scale scores", min = 0, max = 99, levels = "scale")),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = character(0),
      output = "Scale means, variability, missingness, and confidence intervals.",
      refs = character(0)
    ),
    crosstab = list(
      family = "categorical", label = "Cross-tab",
      roles = list(
        role("row", "Row variable", levels = c("nominal", "ordinal")),
        role("column", "Column variable", levels = c("nominal", "ordinal"))
      ),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = TRUE,
      assumptions = "Expected cell counts",
      output = "Cross-tabulation with association measures when run.",
      refs = "field_2018"
    ),
    chi_square = list(
      family = "categorical", label = "Chi-square",
      roles = list(
        role("row", "Variable X", levels = c("nominal", "ordinal")),
        role("column", "Variable Y", levels = c("nominal", "ordinal"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = "Expected-count check",
      output = "Chi-square, p value, Cramer's V or phi.",
      refs = c("field_2018", "cohen_1988")
    ),
    fisher_exact = list(
      family = "categorical", label = "Fisher's exact",
      roles = list(
        role("row", "Variable X", levels = c("nominal", "ordinal")),
        role("column", "Variable Y", levels = c("nominal", "ordinal"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = "Sparse-table handling",
      output = "Fisher's exact p value and odds ratio for 2 x 2 tables.",
      refs = "field_2018"
    ),
    mcnemar = list(
      family = "related_samples", label = "McNemar",
      roles = list(
        role("before", "Before or condition 1", levels = "nominal"),
        role("after", "After or condition 2", levels = "nominal")
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = FALSE,
      assumptions = "Paired binary categories",
      output = "McNemar chi-square and p value.",
      refs = "field_2018"
    ),
    cochran_q = list(
      family = "related_samples", label = "Cochran's Q",
      roles = list(role("measures", "Binary repeated measures", min = 2, max = 99, levels = "nominal")),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = FALSE,
      assumptions = "Related binary measures",
      output = "Cochran's Q and pairwise McNemar plan.",
      refs = "field_2018"
    ),
    mann_whitney = list(
      family = "group_comparison", label = "Mann-Whitney U",
      roles = list(
        role("group", "Grouping variable", levels = c("nominal", "ordinal")),
        role("outcome", "Outcome variable", levels = c("ordinal", "continuous", "scale", "likert"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = "Exactly two groups",
      output = "U statistic, p value, and rank-biserial effect size.",
      refs = c("mann_1947", "cohen_1988")
    ),
    t_test_ind = list(
      family = "group_comparison", label = "Independent t-test",
      roles = list(
        role("group", "Grouping variable", levels = "nominal"),
        role("outcome", "Outcome variable", levels = c("continuous", "scale"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = c("Normality", "Equal variance"),
      output = "t, df, p value, and Cohen's d.",
      refs = c("field_2018", "cohen_1988")
    ),
    t_test_pair = list(
      family = "related_samples", label = "Paired t-test",
      roles = list(
        role("before", "Measure 1", levels = c("continuous", "scale")),
        role("after", "Measure 2", levels = c("continuous", "scale"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = "Normality of differences",
      output = "Paired t, df, p value, and dz.",
      refs = "field_2018"
    ),
    wilcoxon_pair = list(
      family = "related_samples", label = "Wilcoxon signed-rank",
      roles = list(
        role("before", "Measure 1", levels = c("ordinal", "continuous", "scale", "likert")),
        role("after", "Measure 2", levels = c("ordinal", "continuous", "scale", "likert"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = "Paired ordinal or continuous measures",
      output = "V, p value, and r effect size.",
      refs = "cohen_1988"
    ),
    kruskal_wallis = list(
      family = "group_comparison", label = "Kruskal-Wallis",
      roles = list(
        role("group", "Grouping variable", levels = c("nominal", "ordinal")),
        role("outcome", "Outcome variable", levels = c("ordinal", "continuous", "scale", "likert"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = "Independent groups",
      output = "H, p value, eta-squared, and pairwise plan.",
      refs = c("kruskal_1952", "cohen_1988")
    ),
    anova_one = list(
      family = "group_comparison", label = "One-way ANOVA",
      roles = list(
        role("group", "Grouping variable", levels = "nominal"),
        role("outcome", "Outcome variable", levels = c("continuous", "scale"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = c("Normality", "Homogeneity of variance"),
      output = "F, p value, eta-squared, and post-hoc plan.",
      refs = c("field_2018", "cohen_1988")
    ),
    anova_two = list(
      family = "group_comparison", label = "Two-way ANOVA",
      roles = list(
        role("factor1", "Factor 1", levels = "nominal"),
        role("factor2", "Factor 2", levels = "nominal"),
        role("outcome", "Outcome", levels = c("continuous", "scale"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = c("Interaction interpretation", "Homogeneity of variance"),
      output = "Main effects, interaction, and partial eta-squared.",
      refs = c("field_2018", "cohen_1988")
    ),
    ancova = list(
      family = "group_comparison", label = "ANCOVA",
      roles = list(
        role("group", "Group", levels = "nominal"),
        role("covariates", "Covariates", min = 1, max = 99, levels = c("continuous", "scale")),
        role("outcome", "Outcome", levels = c("continuous", "scale"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = "Homogeneity of regression slopes",
      output = "Adjusted group effects and slope warning.",
      refs = "field_2018"
    ),
    repeated_anova = list(
      family = "related_samples", label = "Repeated-measures ANOVA",
      roles = list(role("measures", "Repeated measures", min = 2, max = 99, levels = c("continuous", "scale"))),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = "Within-subject design",
      output = "Within-subject ANOVA summary.",
      refs = "field_2018"
    ),
    friedman = list(
      family = "related_samples", label = "Friedman",
      roles = list(role("measures", "Repeated ordinal measures", min = 2, max = 99, levels = c("ordinal", "continuous", "scale", "likert"))),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = FALSE,
      assumptions = "Related measures",
      output = "Friedman chi-square and p value.",
      refs = "field_2018"
    ),
    correlation_pearson = list(
      family = "association", label = "Pearson correlation",
      roles = list(
        role("x", "Variable X", levels = c("continuous", "scale")),
        role("y", "Variable Y", levels = c("continuous", "scale"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = c("Linearity", "Bivariate normality"),
      output = "r, p value, and confidence interval where feasible.",
      refs = c("field_2018", "cohen_1988")
    ),
    correlation_spearman = list(
      family = "association", label = "Spearman correlation",
      roles = list(
        role("x", "Variable X", levels = c("ordinal", "continuous", "scale", "likert")),
        role("y", "Variable Y", levels = c("ordinal", "continuous", "scale", "likert"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = "Monotonic association",
      output = "rho and p value.",
      refs = c("spearman_1904", "cohen_1988")
    ),
    correlation_kendall = list(
      family = "association", label = "Kendall tau",
      roles = list(
        role("x", "Variable X", levels = c("ordinal", "likert")),
        role("y", "Variable Y", levels = c("ordinal", "likert"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = "Ordinal association",
      output = "tau and p value.",
      refs = "kendall_1938"
    ),
    partial_correlation = list(
      family = "association", label = "Partial correlation",
      roles = list(
        role("x", "Variable X", levels = c("continuous", "scale")),
        role("y", "Variable Y", levels = c("continuous", "scale")),
        role("controls", "Control variables", min = 1, max = 99, levels = c("continuous", "scale"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = "Linear control model",
      output = "Partial r and p value.",
      refs = "field_2018"
    ),
    regression_linear = list(
      family = "regression", label = "Linear regression",
      roles = list(
        role("dependent", "Dependent variable", levels = c("continuous", "scale")),
        role("predictors", "Predictors", min = 1, max = 99, levels = c("nominal", "ordinal", "continuous", "scale", "likert"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = c("Residual normality", "VIF", "Cook distance"),
      output = "Model fit, coefficients, and assumptions.",
      refs = "field_2018"
    ),
    regression_logistic_binary = list(
      family = "regression", label = "Binary logistic",
      roles = list(
        role("dependent", "Binary outcome", levels = "nominal"),
        role("predictors", "Predictors", min = 1, max = 99, levels = c("nominal", "ordinal", "continuous", "scale"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = c("Sparse cells", "Separation warning"),
      output = "Odds ratios, pseudo R-squared, and classification table.",
      refs = "hosmer_2013"
    ),
    regression_logistic_ordinal = list(
      family = "regression", label = "Ordinal logistic",
      roles = list(
        role("dependent", "Ordinal outcome", levels = c("ordinal", "likert")),
        role("predictors", "Predictors", min = 1, max = 99, levels = c("nominal", "ordinal", "continuous", "scale"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = "Ordered outcome",
      output = "MASS::polr model plan, odds ratios, and fit table.",
      refs = "hosmer_2013"
    ),
    regression_logistic_multinomial = list(
      family = "regression", label = "Multinomial logistic",
      roles = list(
        role("dependent", "Nominal outcome", levels = "nominal"),
        role("predictors", "Predictors", min = 1, max = 99, levels = c("nominal", "ordinal", "continuous", "scale"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = "Reference category",
      output = "nnet::multinom plan, odds ratios, and classification table.",
      refs = "hosmer_2013"
    ),
    firth_logistic = list(
      family = "regression", label = "Firth penalised logistic",
      roles = list(
        role("dependent", "Binary outcome", levels = "nominal"),
        role("predictors", "Predictors", min = 1, max = 99, levels = c("nominal", "ordinal", "continuous", "scale"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = c("Small sample", "Separation warning"),
      output = "Penalised odds ratios with profile-likelihood confidence intervals. Requires the logistf package.",
      refs = c("firth_1993", "heinze_2002")
    ),
    mediation = list(
      family = "regression", label = "Mediation",
      roles = list(
        role("predictor", "Predictor", levels = c("continuous", "scale", "nominal")),
        role("mediator", "Mediator", levels = c("continuous", "scale")),
        role("outcome", "Outcome", levels = c("continuous", "scale"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = c("Regression assumptions", "Bootstrap CI"),
      output = "Direct, indirect, total effects, and bootstrap CI.",
      refs = "mackinnon_2008"
    ),
    moderation = list(
      family = "regression", label = "Moderation",
      roles = list(
        role("predictor", "Predictor", levels = c("continuous", "scale")),
        role("moderator", "Moderator", levels = c("continuous", "scale")),
        role("outcome", "Outcome", levels = c("continuous", "scale"))
      ),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = "Interaction model",
      output = "Interaction coefficient and conditional effects.",
      refs = "aiken_1991"
    ),
    reliability_alpha = list(
      family = "measurement", label = "Reliability alpha",
      roles = list(role("items", "Scale items", min = 2, max = 99, levels = c("ordinal", "likert", "continuous"))),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = character(0),
      output = "Alpha, item-total correlations, and alpha if deleted.",
      refs = "cronbach_1951"
    ),
    reliability_omega = list(
      family = "measurement", label = "Reliability omega",
      roles = list(role("items", "Scale items", min = 2, max = 99, levels = c("ordinal", "likert", "continuous"))),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = character(0),
      output = "Omega estimate when the optional psych package is available.",
      refs = "cronbach_1951"
    ),
    item_diagnostics = list(
      family = "measurement", label = "Item diagnostics",
      roles = list(role("items", "Items", min = 1, max = 99, levels = c("ordinal", "likert", "continuous"))),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = character(0),
      output = "Item distributions, item-total correlations, and floor or ceiling checks.",
      refs = "field_2018"
    ),
    efa_readiness = list(
      family = "measurement", label = "EFA readiness",
      roles = list(role("items", "Items", min = 3, max = 99, levels = c("ordinal", "likert", "continuous"))),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = c("KMO", "Bartlett test"),
      output = "KMO, Bartlett, and parallel-analysis planning.",
      refs = "field_2018"
    ),
    efa_solution = list(
      family = "measurement", label = "EFA solution",
      roles = list(role("items", "Items", min = 3, max = 99, levels = c("ordinal", "likert", "continuous"))),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = c("Factor retention", "Cross-loadings"),
      output = "Loadings, communalities, uniqueness, and cross-loading flags.",
      refs = "field_2018"
    ),
    cfa_lavaan_syntax = list(
      family = "model", label = "CFA lavaan syntax",
      roles = list(role("model", "Saved model", min = 0, max = 1, levels = "model")),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = "Construct indicators",
      output = "lavaan measurement model syntax.",
      refs = "field_2018"
    ),
    sem_lavaan_syntax = list(
      family = "model", label = "CB-SEM lavaan syntax",
      roles = list(role("model", "Saved model", levels = "model")),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = "Measurement and structural paths",
      output = "lavaan measurement, structural, indirect, and total-effect syntax.",
      refs = "field_2018"
    ),
    seminr_syntax = list(
      family = "model", label = "PLS-SEM seminr syntax",
      roles = list(role("model", "Saved model", levels = "model")),
      show_alpha = TRUE, show_hypotheses = TRUE, show_effect_size = TRUE,
      assumptions = "Construct modes and bootstrapping",
      output = "seminr measurement, structural, bootstrap, reliability, AVE, and HTMT syntax.",
      refs = "field_2018"
    ),
    topsis = list(
      family = "decision", label = "TOPSIS",
      roles = list(
        role("performance_items", "Performance matrix items (one per criterion)", min = 1, max = 99, levels = "matrix"),
        role("weights_item", "Weights item", levels = c("pairwise_saaty", "criteria_weight"))
      ),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = c("Weights sum to 1 (renormalised if not)", "Criteria labelled benefit or cost"),
      output = "Ranking table (alternative, score, rank) by closeness to the ideal solution.",
      refs = "hwang_1981"
    ),
    vikor = list(
      family = "decision", label = "VIKOR",
      roles = list(
        role("performance_items", "Performance matrix items (one per criterion)", min = 1, max = 99, levels = "matrix"),
        role("weights_item", "Weights item", levels = c("pairwise_saaty", "criteria_weight"))
      ),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = c("Weights sum to 1 (renormalised if not)", "Criteria labelled benefit or cost"),
      output = "Compromise ranking (S, R, Q) with acceptable-advantage and acceptable-stability checks.",
      refs = character(0)
    ),
    moora = list(
      family = "decision", label = "MOORA",
      roles = list(
        role("performance_items", "Performance matrix items (one per criterion)", min = 1, max = 99, levels = "matrix"),
        role("weights_item", "Weights item", levels = c("pairwise_saaty", "criteria_weight"))
      ),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = c("Weights sum to 1 (renormalised if not)", "Criteria labelled benefit or cost"),
      output = "Ranking table (alternative, score, rank) by the ratio system.",
      refs = character(0)
    ),
    smart = list(
      family = "decision", label = "SMART",
      roles = list(
        role("performance_items", "Performance matrix items (one per criterion)", min = 1, max = 99, levels = "matrix"),
        role("weights_item", "Weights item", levels = c("pairwise_saaty", "criteria_weight"))
      ),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = c("Weights sum to 1 (renormalised if not)", "Criteria labelled benefit or cost"),
      output = "Ranking table (alternative, score, rank) by normalised weighted value.",
      refs = character(0)
    ),
    waspas = list(
      family = "decision", label = "WASPAS",
      roles = list(
        role("performance_items", "Performance matrix items (one per criterion)", min = 1, max = 99, levels = "matrix"),
        role("weights_item", "Weights item", levels = c("pairwise_saaty", "criteria_weight"))
      ),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = c("Weights sum to 1 (renormalised if not)", "Criteria labelled benefit or cost"),
      output = "Ranking table (alternative, score, rank) by the WSM/WPM blend.",
      refs = character(0)
    ),
    promethee = list(
      family = "decision", label = "PROMETHEE II",
      roles = list(
        role("performance_items", "Performance matrix items (one per criterion)", min = 1, max = 99, levels = "matrix"),
        role("weights_item", "Weights item", levels = c("pairwise_saaty", "criteria_weight"))
      ),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = c("Weights sum to 1 (renormalised if not)", "Criteria labelled benefit or cost"),
      output = "Ranking table (alternative, score, rank) by net preference flow.",
      refs = character(0)
    ),
    electre = list(
      family = "decision", label = "ELECTRE I",
      roles = list(
        role("performance_items", "Performance matrix items (one per criterion)", min = 1, max = 99, levels = "matrix"),
        role("weights_item", "Weights item", levels = c("pairwise_saaty", "criteria_weight"))
      ),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = c("Weights sum to 1 (renormalised if not)", "Criteria labelled benefit or cost"),
      output = "Outranking relation and best-effort ranking (ELECTRE I does not always produce a total order).",
      refs = character(0)
    ),
    ahp = list(
      family = "decision", label = "AHP",
      roles = list(role("pairwise", "Pairwise comparison item", levels = "pairwise_saaty")),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = c("Reciprocal pairwise matrix", "Consistency ratio below 0.10 recommended"),
      output = "Criterion weights and consistency ratio.",
      refs = "saaty_1980"
    ),
    anp = list(
      family = "decision", label = "ANP",
      roles = list(role("pairwise", "Pairwise comparison item", levels = "pairwise_saaty")),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = c("Reciprocal pairwise matrix", "Supermatrix must converge"),
      output = "Limiting priority weights from the supermatrix.",
      refs = character(0)
    ),
    dematel = list(
      family = "decision", label = "DEMATEL",
      roles = list(role("pairwise", "Influence comparison item", levels = "pairwise_influence")),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      assumptions = "Directed 0-4 influence matrix",
      output = "Cause-effect table (prominence, relation, role) and influence map.",
      refs = character(0)
    ),
    term_freq = list(
      family = "text", label = "Term frequency",
      roles = list(
        role("item", "Text item", levels = "text"),
        role("group", "Group by", min = 0, max = 1, levels = c("nominal", "ordinal"))
      ),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      show_wordcloud = TRUE, show_top_n = TRUE, default_top_n = 30L,
      assumptions = "At least 10 usable responses",
      output = "Top terms by frequency, optionally split by a group variable, and a bar chart or word cloud.",
      refs = character(0)
    ),
    co_occurrence = list(
      family = "text", label = "Co-occurrence",
      roles = list(role("item", "Text item", levels = "text")),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      show_top_n = TRUE, default_top_n = 20L,
      assumptions = c("At least 10 usable responses", "At least 1 co-occurring term pair"),
      output = "Pairwise within-response co-occurrence counts on the top terms, and a heatmap.",
      refs = character(0)
    ),
    ngram_freq = list(
      family = "text", label = "N-gram frequency",
      roles = list(role("item", "Text item", levels = "text")),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      show_ngram_n = TRUE, show_top_n = TRUE, default_top_n = 30L,
      assumptions = "At least 10 usable responses",
      output = "Top bigrams or trigrams by frequency, and a bar chart.",
      refs = character(0)
    ),
    term_context = list(
      family = "text", label = "Keyword in context",
      roles = list(role("item", "Text item", levels = "text")),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      show_term = TRUE,
      assumptions = c("At least 10 usable responses"),
      output = "A keyword-in-context concordance table (before/match/after) for a chosen term.",
      refs = character(0)
    ),
    co_occurrence_network = list(
      family = "text", label = "Co-occurrence network",
      roles = list(role("item", "Text item", levels = "text")),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      show_top_n = TRUE, default_top_n = 20L, show_seed = TRUE,
      assumptions = c("At least 10 usable responses",
                      "At least 5 distinct terms with 1 co-occurrence edge",
                      "Requires the optional igraph package"),
      output = "A Louvain-clustered, force-directed term co-occurrence network (node table plus edge list).",
      refs = c("blondel_2008", "fruchterman_1991")
    ),
    tidy_sentiment = list(
      family = "text", label = "Sentiment",
      roles = list(
        role("item", "Text item", levels = "text"),
        role("group", "Group by", min = 0, max = 1, levels = c("nominal", "ordinal"))
      ),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      show_wordcloud = TRUE,
      assumptions = c("At least 10 usable responses", "Requires the optional tidytext package"),
      output = paste("Positive/negative sentiment counts and proportion positive (bing lexicon),",
                     "optionally split by a group variable, and a diverging bar chart or a",
                     "positive/negative comparison cloud (options$wordcloud = TRUE)."),
      refs = character(0)
    ),
    quanteda_dfm = list(
      family = "text", label = "Document-feature matrix",
      roles = list(role("item", "Text item", levels = "text")),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      show_top_n = TRUE, default_top_n = 30L,
      assumptions = c("At least 10 usable responses", "Requires the optional quanteda package"),
      output = "Document-feature matrix summary: feature count, sparsity, and top features.",
      refs = character(0)
    ),
    topic_model_lda = list(
      family = "text", label = "Topic model (LDA)",
      roles = list(role("item", "Text item", levels = "text")),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      show_k = TRUE, default_k = 4L, show_seed = TRUE,
      assumptions = c("At least 10 usable responses", "Enough documents to support k topics",
                      "Requires the optional tidytext and topicmodels packages"),
      output = "Top terms per topic (LDA, Gibbs-free VEM) as a ranked table, and a faceted bar chart.",
      refs = character(0)
    ),
    stm_topics = list(
      family = "text", label = "Topic model (STM)",
      roles = list(role("item", "Text item", levels = "text")),
      show_alpha = FALSE, show_hypotheses = FALSE, show_effect_size = FALSE,
      show_k = TRUE, default_k = 3L, show_seed = TRUE,
      assumptions = c("At least 10 usable responses", "Enough documents to support k topics",
                      "Requires the optional stm and tidytext packages"),
      output = "Top terms per topic (structural topic model) as a ranked table, and a faceted bar chart.",
      refs = character(0)
    )
  )
})

analysis_method_choices <- function() {
  stats::setNames(names(analysis_registry), vapply(analysis_registry, function(x) x$label, character(1)))
}

studio_level_meta <- function(item = NULL, scale = NULL, ordered = FALSE) {
  if (!is.null(scale)) {
    return(list(level = "scale", code = "SCL", type = "scale score"))
  }
  type <- item$type %||% "text"
  if (identical(type, "likert")) {
    return(list(level = "likert", code = "LIK", type = type))
  }
  # A single-choice item on a set declared ordered is ordinal (0.4.3).
  if (identical(type, "single_choice") && isTRUE(ordered)) {
    return(list(level = "ordinal", code = "ORD", type = type))
  }
  if (type %in% c("single_choice", "multiple_choice")) {
    return(list(level = "nominal", code = "NOM", type = type))
  }
  if (identical(type, "ranking")) {
    return(list(level = "ordinal", code = "ORD", type = type))
  }
  if (type %in% c("numeric", "slider", "rating")) {
    return(list(level = "continuous", code = "CON", type = type))
  }
  if (type %in% c("text", "textarea")) {
    return(list(level = "text", code = "TXT", type = type))
  }
  # Decision-family items. The 2 comparison scales get separate levels because
  # they are not interchangeable: AHP and ANP read reciprocal Saaty importance,
  # DEMATEL reads a directed 0-4 influence matrix, and a weights source must
  # express importance rather than influence. The builder's varLevel() and
  # validate_sframe() enforce the same split.
  if (identical(type, "pairwise_comparison")) {
    influence <- identical(item$comparison_scale %||% "saaty", "influence")
    return(list(
      level = if (influence) "pairwise_influence" else "pairwise_saaty",
      code  = "PWC",
      type  = if (influence) "influence matrix" else "pairwise comparison"
    ))
  }
  if (identical(type, "criteria_weight")) {
    return(list(level = "criteria_weight", code = "WGT", type = "criteria weights"))
  }
  # A matrix item is how the rated performance matrix gets collected: one
  # matrix item per criterion, rows are the alternatives. That is what the 7
  # ranking methods read through their performance_items role, which declares
  # levels = "matrix". Without this branch a matrix item fell through to
  # "identifier", so nothing ever carried the level the role wanted and the
  # dropdown was empty for all 7 methods, leaving the whole rated-matrix path
  # unwirable here. Same failure shape as the decision item types before A6.
  if (identical(type, "matrix")) {
    return(list(level = "matrix", code = "MTX", type = type))
  }
  list(level = "identifier", code = "ID", type = type)
}

studio_variable_catalog <- function(instrument) {
  if (is.null(instrument)) {
    return(list())
  }
  # Display-only items are not response variables and must not appear as
  # analysis variables or role choices.
  question_items <- Filter(
    function(item) !(item$type %in% c("section_break", "text_block")),
    instrument$items %||% list()
  )
  item_rows <- lapply(question_items, function(item) {
    meta <- studio_level_meta(item = item,
                              ordered = sframe_choice_set_ordered(instrument, item$choice_set))
    scale_membership <- item$scale_id %||% ""
    if (!nzchar(scale_membership) && length(instrument$scales %||% list()) > 0) {
      hits <- vapply(instrument$scales, function(scale) item$id %in% (scale$items %||% character(0)), logical(1))
      scale_membership <- paste(vapply(instrument$scales[hits], function(scale) scale$id, character(1)), collapse = ", ")
    }
    list(
      id = item$id,
      label = item$label %||% item$id,
      kind = "item",
      level = meta$level,
      code = meta$code,
      type = meta$type,
      choice_set = item$choice_set %||% "",
      scale = scale_membership,
      required = isTRUE(item$required)
    )
  })
  scale_rows <- lapply(instrument$scales %||% list(), function(scale) {
    meta <- studio_level_meta(scale = scale)
    list(
      id = scale$id,
      label = scale$label %||% scale$id,
      kind = "scale",
      level = meta$level,
      code = meta$code,
      type = meta$type,
      choice_set = "",
      scale = scale$id,
      required = FALSE
    )
  })
  c(item_rows, scale_rows)
}

studio_role_choices <- function(role, catalog, models) {
  if ("model" %in% (role$levels %||% character(0))) {
    ids <- vapply(models %||% list(), function(model) model$id %||% "", character(1))
    labels <- vapply(models %||% list(), function(model) {
      paste0(model$id %||% "", " (", model$type %||% "model", ")")
    }, character(1))
    return(stats::setNames(ids[nzchar(ids)], labels[nzchar(ids)]))
  }
  keep <- vapply(catalog, function(v) {
    "any" %in% role$levels || v$level %in% role$levels || v$kind %in% role$levels
  }, logical(1))
  vars <- catalog[keep]
  ids <- vapply(vars, function(v) v$id, character(1))
  labels <- vapply(vars, function(v) paste0(v$id, " - ", substr(v$label, 1, 48)), character(1))
  stats::setNames(ids, labels)
}

studio_flatten_roles <- function(roles) {
  vals <- unlist(roles, use.names = FALSE)
  unique(vals[nzchar(vals)])
}

studio_validate_plan_roles <- function(method, roles) {
  reg <- analysis_registry[[method]] %||% list(roles = list())
  messages <- character(0)
  for (role in reg$roles %||% list()) {
    vals <- roles[[role$id]] %||% character(0)
    vals <- vals[nzchar(vals)]
    n <- length(vals)
    if (n < role$min) {
      messages <- c(messages, paste0("Select ", role$min, " ", tolower(role$label), "."))
    }
    if (!is.null(role$max) && n > role$max) {
      messages <- c(messages, paste0(role$label, " allows at most ", role$max, " selection(s)."))
    }
  }
  guidance <- switch(
    method,
    frequency = "Select one variable for the frequency table.",
    mann_whitney = "Mann-Whitney U requires one grouping variable and one ordinal or continuous outcome.",
    chi_square = "Chi-square requires categorical variables.",
    fisher_exact = "Fisher's exact test is intended for sparse categorical tables.",
    correlation_pearson = "Pearson correlation requires continuous or scale-score variables.",
    correlation_spearman = "Spearman is safer for ordinal or Likert variables.",
    correlation_kendall = "Kendall tau is safer for ordinal or Likert variables.",
    regression_linear = "Regression requires one dependent variable and at least one predictor.",
    reliability_alpha = "Reliability requires at least two items in a scale.",
    efa_readiness = "EFA readiness usually requires at least three indicators.",
    efa_solution = "EFA solution usually requires at least three indicators.",
    cfa_lavaan_syntax = "CFA requires a saved model or construct plan; constructs with fewer than three indicators should be justified.",
    sem_lavaan_syntax = "CB-SEM requires a saved model with measurement and structural paths.",
    seminr_syntax = "PLS-SEM requires at least one construct and one structural path.",
    topsis = ,
    vikor = ,
    moora = ,
    smart = ,
    waspas = ,
    promethee = ,
    electre = "Needs a performance matrix (either supplied directly or one matrix item per criterion) and a weights item or supplied weights.",
    ahp = ,
    anp = "Needs a pairwise comparison item (Saaty 1-9 scale) or a supplied reciprocal matrix.",
    dematel = "Needs a pairwise comparison item using the influence (0-4) scale, or a supplied directed matrix.",
    "Review compatibility before saving."
  )
  list(valid = length(messages) == 0, messages = messages, guidance = guidance)
}

studio_next_plan_id <- function(plan) {
  paste0("RQ", length(plan %||% list()) + 1L)
}

# Deterministic Shiny input id for a plan block's Export-screen
# interpretation field. The queue index keeps ids unique even when two
# sanitised block ids collide.
studio_interp_input_id <- function(i, block_id) {
  paste0("rpt_interp_", i, "_", studio_safe_id(block_id, prefix = "rq"))
}

# Embed a ggplot as a base64 PNG tag so result cards can carry their charts
# inside renderUI without registering one dynamic plot output per research
# question. Same sizing as the report's HTML fallback.
studio_ggplot_img <- function(gg, alt = "result chart") {
  if (is.null(gg) || !requireNamespace("ggplot2", quietly = TRUE)) {
    return(NULL)
  }
  tmp <- tempfile(fileext = ".png")
  ok <- tryCatch({
    ggplot2::ggsave(tmp, gg, width = 7.2, height = 4.2, dpi = 110, bg = "white")
    TRUE
  }, error = function(e) FALSE)
  if (!isTRUE(ok) || !file.exists(tmp)) {
    return(NULL)
  }
  raw <- readBin(tmp, "raw", file.info(tmp)$size)
  unlink(tmp)
  tags$img(alt = alt, style = "max-width:100%;height:auto",
           src = paste0("data:image/png;base64,", openssl::base64_encode(raw)))
}

# Render a result's $table data frame as the same APA-styled table used
# elsewhere in the studio, so the results canvas shows the actual numbers
# instead of just the prose APA string.
studio_result_table_tag <- function(tbl) {
  if (!is.data.frame(tbl) || nrow(tbl) == 0) {
    return(NULL)
  }
  num_cols <- vapply(tbl, is.numeric, logical(1))
  if (any(num_cols)) {
    tbl[num_cols] <- lapply(tbl[num_cols], function(col) round(col, 3))
  }
  header <- tags$tr(do.call(tagList, lapply(colnames(tbl), tags$th)))
  body_rows <- lapply(seq_len(nrow(tbl)), function(r) {
    tags$tr(do.call(tagList, lapply(tbl[r, , drop = TRUE], function(cell) {
      tags$td(as.character(cell))
    })))
  })
  tags$table(class = "sf-table", tags$thead(header), tags$tbody(do.call(tagList, body_rows)))
}

# The chart(s) attached to one analysis-plan result: the main chart, plus a
# regression's four diagnostic panels stacked beneath it, matching the
# report's table-plus-plot pairing.
# A result card's heading. "RQ 4" when the block id only repeats the
# number ("RQ4", "rq 4"), which printed as "RQ 4: RQ4". Any other id is shown.
studio_rq_heading <- function(i, block_id) {
  id <- trimws(if (is.null(block_id)) "" else as.character(block_id))
  if (!nzchar(id) ||
      identical(gsub("[^0-9A-Z]", "", toupper(id)), paste0("RQ", i))) {
    return(sprintf("RQ %d", i))
  }
  sprintf("RQ %d: %s", i, id)
}

studio_result_plot_tags <- function(result) {
  plot_tags <- list(studio_ggplot_img(result$plot))
  if (is.list(result$diagnostic_plots)) {
    plot_tags <- c(plot_tags,
      lapply(result$diagnostic_plots, studio_ggplot_img, alt = "regression diagnostic"))
  }
  Filter(Negate(is.null), plot_tags)
}

# The canvas's "Copy result" button: a JASP/jamovi output canvas lets you
# copy one output block without generating a whole report, so the same
# affordance belongs here. The click handler (window.studioCopyResultBlock,
# defined once in the page's <script> block) builds the clipboard content
# client-side from the block's live DOM, including the current
# interpretation text, the table, and the chart image, not just an APA
# string, so it survives a paste into Word or LibreOffice as a rich block.
studio_copy_result_btn <- function() {
  tags$button(
    type = "button", class = "btn sf-tertiary studio-copy-btn",
    onclick = "studioCopyResultBlock(this)",
    "Copy result"
  )
}

studio_safe_id <- function(x, prefix = "M") {
  x <- gsub("[^A-Za-z0-9_]", "_", trimws(x %||% ""))
  if (!nzchar(x)) {
    x <- prefix
  }
  if (!grepl("^[A-Za-z]", x)) {
    x <- paste0(prefix, "_", x)
  }
  x
}

studio_parse_paths <- function(text) {
  lines <- parse_lines(text %||% "")
  Filter(Negate(is.null), lapply(lines, function(line) {
    parts <- trimws(strsplit(line, "->", fixed = TRUE)[[1]])
    if (length(parts) != 2 || any(!nzchar(parts))) {
      return(NULL)
    }
    sframe_path(parts[1], parts[2])
  }))
}

studio_parse_covariances <- function(text) {
  lines <- parse_lines(text %||% "")
  Filter(Negate(is.null), lapply(lines, function(line) {
    parts <- trimws(strsplit(line, "~~", fixed = TRUE)[[1]])
    if (length(parts) != 2 || any(!nzchar(parts))) {
      return(NULL)
    }
    sframe_covariance(parts[1], parts[2])
  }))
}

studio_parse_indirect <- function(text) {
  lines <- parse_lines(text %||% "")
  Filter(Negate(is.null), lapply(lines, function(line) {
    parts <- trimws(strsplit(line, "->", fixed = TRUE)[[1]])
    if (length(parts) < 3 || any(!nzchar(parts))) {
      return(NULL)
    }
    sframe_indirect_effect(parts[1], parts[2:(length(parts) - 1)], parts[length(parts)])
  }))
}

INITIAL_INSTRUMENT <- shiny::getShinyOption("surveyframe_instrument", NULL)
INITIAL_RESPONSES <- shiny::getShinyOption("surveyframe_responses", NULL)
INITIAL_SCREEN <- shiny::getShinyOption("surveyframe_initial_screen", "auto")

if (is.null(INITIAL_SCREEN) || !nzchar(INITIAL_SCREEN)) {
  INITIAL_SCREEN <- "auto"
}

initial_builder <- if (inherits(INITIAL_INSTRUMENT, "sframe")) {
  builder_state_from_instrument(INITIAL_INSTRUMENT)
} else {
  builder_empty_state()
}

initial_tab <- INITIAL_SCREEN
if (identical(initial_tab, "data")) {
  initial_tab <- "responses"
}
if (identical(initial_tab, "auto")) {
  initial_tab <- if (!is.null(INITIAL_RESPONSES)) {
    "dashboard"
  } else if (inherits(INITIAL_INSTRUMENT, "sframe")) {
    "preview"
  } else {
    "design"
  }
}
# launch_studio() has already checked the screen.
if (!initial_tab %in% sframe_studio_screens()) {
  initial_tab <- if (inherits(INITIAL_INSTRUMENT, "sframe")) {
    "preview"
  } else {
    "design"
  }
}

tab_link_class <- function(tab) {
  if (identical(initial_tab, tab)) "active" else NULL
}

screen_class <- function(tab) {
  paste("screen", if (identical(initial_tab, tab)) "active")
}

studio_nav_entry <- function(tab, label) {
  tags$li(class = "studio-nav-item",
    tags$a(href = paste0("#", tab), `data-tab` = tab, class = tab_link_class(tab),
           `aria-current` = if (identical(initial_tab, tab)) "page", label))
}

studio_nav_heading <- function(label) {
  # A group heading folds its entries (item 12a), so it is a button.
  # No whitespace around the button, so the heading's text is its label.
  tags$li(class = "studio-nav-heading", `data-group` = tolower(label),
    tags$button(type = "button", class = "studio-nav-fold", `aria-expanded` = "true", label), .noWS = c("after-begin", "before-end"))
}

# The Report screen's local tabs (UX-07): a tab button and its pane. The
# panes are hidden, never redrawn, so their inputs keep their values.
# A screen's 1 primary action (item 12e): a link to its next step, drawn
# with the shared .sf-primary level in inst/builder/design_tokens.css.
studio_next_primary <- function(tab, label) {
  tags$a(href = paste0("#", tab), `data-tab` = tab, class = "btn btn-primary sf-primary", label)
}
studio_primary_file <- function(tag) {
  htmltools::tagQuery(tag)$find(".btn")$addClass("btn-primary sf-primary")$allTags()
}

# A version token for a file under sfbuilder/, from the package version and
# the first 8 characters of the file's MD5, so a browser that cached an
# older builder or field_tools.js fetches the new one after an upgrade or an
# edit (item 12g).
studio_asset_token <- function(file) {
  path <- system.file("builder", file, package = "surveyframe")
  hash <- if (nzchar(path)) substr(unname(tools::md5sum(path)), 1L, 8L) else "0"
  paste0(utils::packageVersion("surveyframe"), "-", hash)
}
studio_asset_src <- function(file, query = NULL) {
  paste0("sfbuilder/", file, "?", paste(c(query, paste0("v=", studio_asset_token(file))),
                                        collapse = "&"))
}

# A colour from the shared design tokens (UI-3, inst/builder/design_tokens.css),
# for the charts R draws, which cannot read a CSS variable. A token defined
# as another variable or a mix falls back to its plain hex value given here.
studio_token <- function(name, fallback) {
  path <- system.file("builder", "design_tokens.css", package = "surveyframe")
  css <- if (nzchar(path)) readLines(path, warn = FALSE) else character(0)
  hit <- regmatches(css, regexpr(paste0("^\\s*", name, ":\\s*#[0-9a-fA-F]{6}"), css))
  if (length(hit)) sub(".*(#[0-9a-fA-F]{6}).*", "\\1", hit[1]) else fallback
}
# The chart colours, from the tokens.
dash_theme <- studio_token("--sf-primary", "#0a6f6d")
dash_muted <- studio_token("--sf-text-3", "#5b6b80")
dash_danger <- studio_token("--sf-danger", "#dc2626")
dash_surface <- studio_token("--sf-surface", "#ffffff")

studio_report_tab <- function(id, label, on = FALSE) {
  tags$button(type = "button", id = paste0("rtab-", id),
    class = paste("report-tab", if (on) "active"), role = "tab",
    `aria-selected` = if (on) "true" else "false",
    `aria-controls` = paste0("rpane-", id), `data-rtab` = id, label)
}
studio_report_pane <- function(id, on, ...) {
  tags$div(id = paste0("rpane-", id), class = paste("report-pane", if (on) "active"),
    role = "tabpanel", `aria-labelledby` = paste0("rtab-", id), ...)
}

ui <- fluidPage(
  tags$head(
    tags$title("SurveyStudio"),
    tags$script(src = studio_asset_src("field_tools.js")),
    tags$link(rel = "stylesheet", href = studio_asset_src("design_tokens.css")),
    tags$style(HTML("
      body { font-family: var(--sf-font);
             background: var(--sf-canvas); color: var(--sf-ink); margin: 0; }
      .studio-shell { display: flex; min-height: 100vh; }
      .studio-sidebar {
        width: 240px; min-width: 240px; background: var(--sf-nav);
        color: var(--sf-nav-text); padding: 0; display: flex; flex-direction: column;
        position: fixed; top: 0; bottom: 0; left: 0; overflow-y: auto; z-index: 100;
      }
      .studio-logo {
        padding: 24px 20px 16px; font-size: 18px; font-weight: 700;
        color: var(--sf-surface); letter-spacing: 0.02em; border-bottom: 1px solid var(--sf-nav-line);
      }
      .studio-logo span { color: var(--sf-primary-on-dark); }
      .studio-logo img { height: 22px; margin-right: 8px; vertical-align: middle; }
      .studio-nav { list-style: none; margin: 0; padding: 12px 0; flex: 1; }
      .studio-nav-wrap { flex: 1; display: flex; flex-direction: column; }
      .studio-nav-item a {
        display: flex; align-items: center; gap: 10px;
        padding: 10px 20px; color: var(--sf-nav-muted); text-decoration: none;
        font-size: 14px; border-left: 3px solid transparent;
        transition: background 0.15s, color 0.15s;
      }
      /* Only the open screen has the teal bar and white text. Hover is a
         lighter tint, so the entry under the mouse is never mistaken for
         the selected one. */
      .studio-nav-item a:hover { background: color-mix(in srgb, var(--sf-nav-hover) 45%, var(--sf-nav)); color: var(--sf-nav-text); }
      .studio-nav-item a.active {
        background: var(--sf-nav-hover); color: var(--sf-white); border-left-color: var(--sf-primary-on-dark);
        font-weight: 700;
      }
      /* A group heading is a label, with nothing to click. */
      .studio-nav-heading {
        padding: 14px 20px 4px; font-size: 11px; font-weight: 600;
        letter-spacing: 0.08em; text-transform: uppercase; color: var(--sf-nav-muted);
        user-select: none;
      }
      .studio-nav-fold { background: none; border: none; padding: 0; width: 100%; text-align: left;
        font: inherit; letter-spacing: inherit; text-transform: inherit; color: inherit; cursor: pointer; }
      .studio-nav-fold::after { content: '\\25BE'; float: right; }
      .studio-nav-fold[aria-expanded='false']::after { content: '\\25B8'; }
      .studio-nav-item.folded { display: none; }
      /* Item 12c: each screen is 1 panel, its title and context line 1
         compact row at the top of it, in place of a band above the cards. */
      .screen.active { background: var(--sf-surface); border-radius: 10px; box-shadow: var(--sf-shadow-1); padding: 16px 20px; }
      .screen .card { box-shadow: none; border: 1px solid var(--sf-border); }
      .screen-head { display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
        padding-bottom: 10px; margin-bottom: 16px; border-bottom: 1px solid var(--sf-border); }
      .screen-head > :last-child:not(:first-child) { margin-left: auto; }
      .screen-head .hint { margin-top: 0; }
      .design-actions { display: flex; align-items: center; gap: 8px; }
      .btn.sf-tertiary.design-hist { min-width: 36px; min-height: 36px; justify-content: center; font-size: 18px; text-decoration: none; color: var(--sf-text-2); }
      .btn.sf-tertiary.design-hist:hover:not(:disabled) { background: var(--sf-canvas); color: var(--sf-ink); }
      .btn.sf-tertiary.design-hist:disabled { color: var(--sf-border-strong); }
      .design-save-state { font-size: 12px; }
      .report-tabs { display: flex; gap: 4px; border-bottom: 1px solid var(--sf-border); margin-bottom: 16px; flex-wrap: wrap; }
      .report-tab { background: none; border: none; border-bottom: 3px solid transparent; padding: 8px 14px; font-weight: 600; color: var(--sf-text-2); }
      .report-tab.active { border-bottom-color: var(--sf-ink); color: var(--sf-ink); }
      .screen.screen-gated > :not(.screen-title):not(.screen-head):not(.screen-gate) { display: none !important; }
      .screen.screen-gated > .screen-head > :not(.screen-title) { display: none !important; }
      .report-pane { display: none; }
      .report-pane.active { display: block; }
      .flag-list { margin-top: 12px; border-top: 1px solid var(--sf-border); padding-top: 8px; }
      .flag-head { font-weight: 600; margin-bottom: 4px; }
      .flag-row { display: flex; gap: 12px; align-items: center; justify-content: space-between; padding: 4px 0; }
      .studio-status {
        padding: 16px 20px; font-size: 12px;
        border-top: 1px solid var(--sf-nav-line); color: var(--sf-nav-muted);
      }
      .studio-main {
        margin-left: 240px; flex: 1; padding: 32px;
        min-height: 100vh; box-sizing: border-box;
        min-width: 0;
      }
      /* Narrow screens (UX-01, UX-08): below 800 px the sidebar is a drawer
         behind a labelled Menu button, cards stack, and a wide table or code
         block scrolls inside its own region, so no page is wider than the
         viewport. */
      .studio-menu-btn { display: none; }
      @media (max-width: 799px) {
        .studio-sidebar { transform: translateX(-100%); transition: transform .2s; visibility: hidden; }
        .studio-shell.drawer-open .studio-sidebar { transform: none; visibility: visible; box-shadow: var(--sf-shadow-2); }
        .studio-main { margin-left: 0; padding: 12px; width: 100%; }
        .studio-menu-btn { display: inline-flex; align-items: center; gap: 6px; position: sticky; top: 0; z-index: 90;
          margin: 0 0 12px; padding: 8px 14px; border: none; border-radius: 6px; background: var(--sf-nav); color: var(--sf-white); font-weight: 600; }
        .studio-main .row { margin-left: 0; margin-right: 0; }
        .studio-main .row > [class*='col-'] { width: 100%; float: none; padding-left: 0; padding-right: 0; }
        .opt-row, .stat-row, .screen-head, .flag-row { flex-direction: column; align-items: stretch; }
        .studio-main table { display: block; max-width: 100%; overflow-x: auto; }
        .studio-main pre, .studio-main .sf-code { max-width: 100%; overflow-x: auto; }
        .studio-main img, .studio-main iframe, .studio-main svg { max-width: 100%; }
        .studio-main .form-group, .studio-main .shiny-input-container { width: 100% !important; max-width: 100%; }
        .card { padding: 14px; }
        .modal-dialog { width: auto; margin: 8px; }
      }
      .screen { display: none; }
      .screen.active { display: block; }
      .card {
        background: var(--sf-surface); border-radius: 8px;
        box-shadow: var(--sf-shadow-1);
        padding: 24px; margin-bottom: 20px;
      }
      .card-title {
        font-size: 16px; font-weight: 600; margin: 0 0 16px;
        color: var(--sf-ink);
      }
      .card-actions {
        display: flex; gap: 10px; flex-wrap: wrap; margin-top: 12px;
      }
      .badge {
        display: inline-block; padding: 3px 10px; border-radius: 12px;
        font-size: 12px; font-weight: 600;
      }
      .badge-ok { background: var(--sf-success-tint); color: var(--sf-success-ink); }
      .badge-wait { background: var(--sf-warning-tint); color: var(--sf-warning-ink); }
      .badge-warn { background: var(--sf-danger-tint); color: var(--sf-danger-ink); }
      .filter-bar { background: var(--sf-surface); border-radius: 10px; padding: 14px 16px; box-shadow: var(--sf-shadow-1); margin-bottom: 16px; }
      .filter-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(210px, 1fr)); gap: 12px; align-items: end; }
      .filter-grid label { font-size: 12px; font-weight: 600; color: var(--sf-text-2); }
      .filter-note { font-size: 11px; color: var(--sf-text-3); margin-top: 8px; }
      .filter-head { display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap; margin-bottom: 8px; }
      .filter-head .card-title { margin-bottom: 0; }
      .dash-actions { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin-bottom: 12px; }
      .filter-head .dash-actions { margin-bottom: 0; }
      .dash-actions .hint { margin-top: 0; }
      .stat-row { display: flex; gap: 16px; flex-wrap: wrap; margin-bottom: 16px; }
      .stat-box {
        flex: 1; min-width: 120px; background: var(--sf-surface-2); border-radius: 8px;
        padding: 16px; text-align: center;
      }
      .stat-box .stat-val { font-size: 28px; font-weight: 700; color: var(--sf-ink); }
      .stat-box .stat-lbl { font-size: 12px; color: var(--sf-text-3); margin-top: 4px; }
      table.sf-table { width: 100%; border-collapse: collapse; font-size: 14px;
        display: block; overflow-x: auto; max-width: 100%; }
      /* Academic (APA) tables: horizontal rules only, no shading, no vertical lines */
      .sf-table th {
        background: none; text-align: left; padding: 8px 12px;
        font-weight: 700; color: var(--sf-ink);
        border-top: 2px solid var(--sf-ink); border-bottom: 1px solid var(--sf-ink);
      }
      .sf-table td { padding: 8px 12px; border: none; vertical-align: top; overflow-wrap: anywhere; }
      .sf-table tbody tr:last-child td { border-bottom: 2px solid var(--sf-ink); }
      /* A table of short ids beside long text, such as the saved analysis
         plans: words never break mid-word, so a narrow screen scrolls the
         table sideways and RQ1 stays on one line */
      .sf-table-wide td { overflow-wrap: break-word; min-width: 4em; }
      .sf-table-wide td:first-child { white-space: nowrap; min-width: 0; }
      /* Brand pill tabs (match the dashboard nav), used for the studio sub-tabs */
      .studio-tabs .shiny-options-group {
        display: flex; gap: 2px; flex-wrap: wrap; background: var(--sf-nav);
        padding: 6px; border-radius: 8px; margin: 4px 0 18px;
      }
      .studio-tabs .control-label { display: none; }
      .studio-tabs .radio-inline { margin: 0; padding: 0; }
      .studio-tabs .radio-inline input[type=radio] {
        position: absolute; opacity: 0; pointer-events: none;
      }
      .studio-tabs .radio-inline span {
        display: inline-block; padding: 7px 16px; border-radius: 6px;
        font-size: 12px; font-weight: 600; color: color-mix(in srgb, var(--sf-white) 60%, transparent);
        cursor: pointer; transition: all .15s;
      }
      .studio-tabs .radio-inline:hover span {
        background: color-mix(in srgb, var(--sf-white) 6%, transparent); color: color-mix(in srgb, var(--sf-white) 85%, transparent);
      }
      .studio-tabs .radio-inline input[type=radio]:checked + span {
        background: var(--sf-primary); color: var(--sf-surface);
      }
      h2.screen-title {
        font-size: 18px; font-weight: 700; margin: 0; color: var(--sf-ink);
      }
      .hint { font-size: 13px; color: var(--sf-text-3); margin-top: 6px; }
      .problem-list { margin: 0; padding-left: 18px; }
      .problem-list li { margin-bottom: 6px; }
      .sf-code {
        white-space: pre-wrap; background: var(--sf-surface-2); border: 1px solid var(--sf-border);
        border-radius: 6px; padding: 12px; overflow-x: auto;
      }
      .role-card { border: 1px solid var(--sf-border); border-radius: 8px; padding: 12px; margin-bottom: 12px; }
      .role-card label { font-size: 13px; font-weight: 600; color: var(--sf-ink); }
      .vmeta { border-bottom: 1px solid var(--sf-border); padding: 10px 0; }
      .vmeta:last-child { border-bottom: none; }
      .vmeta-id { font-size: 13px; font-weight: 700; color: var(--sf-ink); }
      .vmeta-lbl { font-size: 12px; color: var(--sf-text-2); margin: 2px 0 5px; display: block; }
      .result-canvas-block .sf-table { margin: 10px 0; }
      .result-canvas-block img { margin: 8px 0; border: 1px solid var(--sf-border); border-radius: 6px; }
      .result-canvas-block textarea {
        min-height: 160px; resize: vertical; font-size: 14px; line-height: 1.5;
      }
      .studio-copy-btn { margin: 10px 0; font-size: 13px; }
      details.result-canvas-block > summary { cursor: pointer; list-style: none; padding-left: 18px; position: relative; }
      details.result-canvas-block > summary::-webkit-details-marker { display: none; }
      details.result-canvas-block > summary::before {
        content: '\\25B8'; position: absolute; left: 0; top: 0; color: var(--sf-primary);
      }
      details.result-canvas-block[open] > summary::before { content: '\\25BE'; }
      details.result-canvas-block > summary .card-title { display: inline; margin: 0; }
      details.result-canvas-block > summary .hint { display: block; margin: 4px 0 0; }
      details.result-canvas-block[open] > summary { margin-bottom: 10px; }
      .opt-row { display: flex; flex-wrap: wrap; column-gap: 20px; }
      .opt-row > div { flex: 1 1 220px; }
      .opt-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); column-gap: 12px; }
      .opt-grid .checkbox, .opt-grid .form-group { margin: 2px 0; }
      details.opt-more > summary { cursor: pointer; font-weight: 600; margin: 10px 0; list-style: none; }
      details.opt-more > summary::-webkit-details-marker { display: none; }
      details.opt-more > summary::before { content: '\\25B8 '; color: var(--sf-primary); }
      details.opt-more[open] > summary::before { content: '\\25BE '; }
      .vbadge {
        display: inline-block; border: 1px solid var(--sf-border); border-radius: 999px;
        padding: 2px 7px; margin: 2px 3px 2px 0; font-size: 11px;
        color: var(--sf-text-2); background: var(--sf-surface-2);
      }
      .plan-msg { border-radius: 6px; padding: 10px; background: var(--sf-warning-tint); color: var(--sf-warning-ink); }
      .plan-msg.ok { background: var(--sf-success-tint); color: var(--sf-success-ink); }
      #survey_preview_frame {
        border: 1px solid var(--sf-border); border-radius: 8px; padding: 24px; background: var(--sf-surface);
      }
    "))
  ),
  tags$div(class = "studio-shell",
    tags$div(class = "studio-sidebar", id = "studio_sidebar",
      tags$div(class = "studio-logo",
        tags$img(src = "sfstudio/surveyframe-shiny-square-icon.png", alt = "surveyframe"),
        "Survey", tags$span("Studio")
      ),
      # The study's order, in groups under headings that cannot be clicked.
      # Plan is an entry, not a screen: it opens Design with the builder in
      # its Plan mode. The screen ids stay as they were for launch_studio().
      tags$nav(class = "studio-nav-wrap", `aria-label` = "Studio screens",
      tags$ul(class = "studio-nav",
        studio_nav_entry("open", "Open Instrument"),
        studio_nav_heading("Build"),
        studio_nav_entry("design", "Design"),
        tags$li(class = "studio-nav-item",
          tags$a(href = "#plan", `data-nav` = "plan", "Plan")),
        studio_nav_entry("preview", "Preview"),
        studio_nav_heading("Collect"),
        studio_nav_entry("collect", "Collect"),
        studio_nav_entry("responses", "Responses"),
        studio_nav_heading("Analyse"),
        studio_nav_entry("quality", "Quality"),
        studio_nav_entry("dashboard", "Explore"),
        studio_nav_entry("reliability", "Reliability"),
        studio_nav_entry("analysis", "Analyse"),
        studio_nav_heading("Report"),
        studio_nav_entry("export", "Report"),
        studio_nav_heading("Record"),
        studio_nav_entry("references", "References"),
        studio_nav_entry("amendments", "Amendments")
      )),
      tags$div(class = "studio-status", uiOutput("sidebar_status"))
    ),
    tags$div(class = "studio-main",
      tags$button(type = "button", id = "studio_menu_btn", class = "studio-menu-btn",
        `aria-controls` = "studio_sidebar", `aria-expanded` = "false",
        `aria-label` = "Menu: Studio screens", "Menu"),
      tags$script(HTML("
        // Screens are shown and hidden with CSS classes, which Shiny cannot
        // see. Shiny suspends an output while it is hidden, so the switch
        // fires the 'hidden' and 'shown' events Shiny listens for, and the
        // opened screen's outputs draw at once.
        // Plan is the Design screen with the builder in its Plan mode, and
        // the entry marked active is the one picked. Any other way to Design
        // opens the builder in Build mode.
        // Sidebar groups fold (item 12a). Each choice is kept in localStorage,
        // and the group holding the open screen always stays open.
        function studioGroupOf(a) { return $(a).closest('li').prevAll('.studio-nav-heading').first(); }
        function studioFold(h, open, save) {
          h = $(h);
          if (!open && h.nextUntil('.studio-nav-heading').find('a.active').length) open = true;
          h.find('.studio-nav-fold').attr('aria-expanded', open ? 'true' : 'false');
          h.nextUntil('.studio-nav-heading').toggleClass('folded', !open);
          if (save) try { localStorage.setItem('sfstudio-fold-' + h.data('group'), open ? '1' : '0'); } catch (e) {}
        }
        $(document).on('click', '.studio-nav-fold', function() {
          var h = $(this).closest('.studio-nav-heading');
          studioFold(h, $(this).attr('aria-expanded') !== 'true', true);
        });
        $(function() {
          $('.studio-nav-heading').each(function() {
            var v = null; try { v = localStorage.getItem('sfstudio-fold-' + $(this).data('group')); } catch (e) {}
            if (v === '0') studioFold(this, false, false);
          });
        });

        function studioShowScreen(link, tab, nav, fromHistory) {
          $('.studio-nav-item a').removeClass('active').removeAttr('aria-current');
          if (nav === 'plan') {
            $('.studio-nav-item a[data-nav=\"plan\"]').addClass('active').attr('aria-current', 'page');
          } else {
            $('.studio-nav-item a[data-tab=\"' + tab + '\"]').addClass('active').attr('aria-current', 'page');
          }
          $('.studio-nav-item a.active').each(function() { var h = studioGroupOf(this); if (h.length) studioFold(h, true, false); });
          if (tab === 'design') studioDesignSetMode(nav === 'plan' ? 'analyse' : 'build');
          $('.screen.active').not('#screen-' + tab)
            .removeClass('active').trigger('hidden');
          $('#screen-' + tab).addClass('active').trigger('shown');
          Shiny.setInputValue('current_tab', tab, {priority: 'event'});
          // Each screen is a fragment in the browser history, so Back and
          // Forward move between screens (UX-16).
          var key = nav === 'plan' ? 'plan' : tab;
          if (!fromHistory && location.hash !== '#' + key)
            history.pushState({tab: tab, nav: nav || null}, '', '#' + key);
        }

        // A screen the researcher picks wins over the launch screen, which
        // the server sends after the first flush and can arrive late.
        var studioPicked = false;
        function studioLaunchScreen(tab) {
          if (studioPicked) return;
          var link = $('[data-tab=\"' + tab + '\"]');
          if (link.length === 0) return;
          studioShowScreen(link, tab);
        }

        $(document).on('click', '[data-tab]', function(e) {
          e.preventDefault();
          studioPicked = true;
          studioShowScreen($(this), $(this).data('tab'));
        });
        // The drawer on narrow screens: the Menu button opens it, a choice
        // or Escape closes it, and focus goes back to the button.
        function studioDrawer(open) {
          $('.studio-shell').toggleClass('drawer-open', open);
          $('#studio_menu_btn').attr('aria-expanded', open ? 'true' : 'false');
          if (open) $('#studio_sidebar a.active, #studio_sidebar a').first().focus();
        }
        $(document).on('click', '#studio_menu_btn', function() {
          studioDrawer(!$('.studio-shell').hasClass('drawer-open'));
        });
        $(document).on('click', '#studio_sidebar a', function() {
          if ($('.studio-shell').hasClass('drawer-open')) { studioDrawer(false); $('#studio_menu_btn').focus(); }
        });
        $(document).on('keydown', function(e) {
          if (e.key === 'Escape' && $('.studio-shell').hasClass('drawer-open') && !$('.modal.in, .modal.show').length) {
            studioDrawer(false); $('#studio_menu_btn').focus();
          }
        });
        function studioFromHash() {
          var key = location.hash.replace(/^#/, '');
          if (key === 'plan') return {tab: 'design', nav: 'plan'};
          return $('#screen-' + key).length ? {tab: key, nav: null} : null;
        }
        window.addEventListener('popstate', function(e) {
          var s = (e.state && e.state.tab) ? e.state : studioFromHash();
          if (s) studioShowScreen(null, s.tab, s.nav, true);
        });
        // A fragment in the address opens that screen, as a pick does.
        $(document).on('shiny:connected', function() {
          var s = studioFromHash();
          if (s) { studioPicked = true; studioShowScreen(null, s.tab, s.nav, true); }
        });
        $(document).on('click', '[data-nav=\"plan\"]', function(e) {
          e.preventDefault();
          studioPicked = true;
          studioShowScreen($(this), 'design', 'plan');
        });

        // The Report screen's local tabs: arrows move between them, as a
        // tablist does, and a pane is only hidden, so its choices stay.
        function studioReportTab(id) {
          $('.report-tab').each(function() {
            var on = $(this).data('rtab') === id;
            $(this).toggleClass('active', on).attr('aria-selected', on ? 'true' : 'false')
              .attr('tabindex', on ? '0' : '-1');
          });
          $('.report-pane').each(function() { $(this).toggleClass('active', this.id === 'rpane-' + id); });
          $(window).trigger('resize');
        }
        $(document).on('click', '[data-rtab]', function() { studioReportTab($(this).data('rtab')); });
        $(document).on('keydown', '.report-tab', function(e) {
          if (e.key !== 'ArrowRight' && e.key !== 'ArrowLeft') return;
          var tabs = $('.report-tab'), k = tabs.index(this) + (e.key === 'ArrowRight' ? 1 : -1);
          var next = tabs.eq((k + tabs.length) % tabs.length);
          studioReportTab(next.data('rtab')); next.focus(); e.preventDefault();
        });

        // A gate that names the next stage replaces the screen's body, so no
        // editor sits live under it (UX-13). A gate that only warns, such as
        // Preview's validation list, leaves the body shown.
        function studioGate(el) {
          if (!el) return;
          var scr = $(el).addClass('screen-gate').closest('.screen');
          scr.toggleClass('screen-gated', $(el).find('.next-stage').length > 0);
        }
        $(document).on('shiny:value', function(e) {
          if (/_gate$/.test(e.name)) setTimeout(function() { studioGate(document.getElementById(e.name)); }, 0);
        });

        // The shared format toolbar and citation picker (UI-2's field_tools.js)
        // on Studio's long text fields, shown on focus and hidden on blur. Each
        // field opts in with data-cite, its label. The
        // references are the open instrument's only, sent by the server, so a
        // report never cites a source the .sframe does not record (UX-03).
        window.studioRefs = []; window.studioKnownKeys = []; window.studioPickers = {};
        Shiny.addCustomMessageHandler('studio-refs', function(m) {
          window.studioRefs = m.refs || []; window.studioKnownKeys = m.known || [];
          if (window.SurveyframeCitationPicker) SurveyframeCitationPicker.updateReferences(window.studioRefs);
        });
        function studioAttachPickers(root) {
          var P = window.SurveyframeCitationPicker;
          if (!P || !root) return;
          $(root).find('textarea[data-cite]').each(function() {
            var old = window.studioPickers[this.id];
            if (old) { if (old.element === this) return; old.destroy(); }
            window.studioPickers[this.id] = P.attach(this, function() { return window.studioRefs; }, {
              label: $(this).attr('data-cite'),
              knownKeys: function() { return window.studioKnownKeys; },
              onManage: function() { $('.studio-nav-item [data-tab=\"references\"]').first().click(); }
            });
          });
        }
        $(document).on('shiny:value', function(e) {
          setTimeout(function() { studioAttachPickers(document.getElementById(e.name)); }, 0);
        });
        $(function() { studioAttachPickers(document.body); });
        // A dialog is not an output, so its fields attach when it opens.
        $(document).on('shown.bs.modal', function(e) { studioAttachPickers(e.target); });

        Shiny.addCustomMessageHandler('surveyframe-launch-tab', studioLaunchScreen);

        // The Design screen holds the SurveyBuilder in an iframe on this
        // origin. Each side takes a message only from the other window, on
        // the same origin. Studio keeps the open instrument's text, for the
        // builder to ask for once it has loaded.
        var studioDesignText = null;
        // The builder mode Design should show, sent again once the builder
        // has loaded, since a click can come first.
        var studioDesignMode = 'build';
        function studioDesignSetMode(mode) {
          studioDesignMode = mode;
          // The head's title names the mode, as the sidebar entry does.
          $('#design_title').text(mode === 'analyse' ? 'Plan' : 'Design');
          studioDesignPost({type: 'mode', mode: mode});
        }
        $(document).on('click', '#design_undo, #design_redo, #design_save', function() {
          studioDesignPost({type: 'command', command: this.id.replace('design_', '')});
        });
        function studioDesignPost(msg) {
          var f = document.getElementById('design_frame');
          if (f && f.contentWindow) f.contentWindow.postMessage(msg, location.origin);
        }
        window.addEventListener('message', function(e) {
          var f = document.getElementById('design_frame');
          if (!f || e.source !== f.contentWindow || e.origin !== location.origin) return;
          var d = e.data || {};
          if (d.type === 'need-sframe') {
            if (studioDesignProblem) {
              studioDesignPost({type: 'sframe-blocked', message: studioDesignProblem});
            } else if (studioDesignText) {
              studioDesignPost({type: 'sframe', text: studioDesignText});
            }
            studioDesignPost({type: 'mode', mode: studioDesignMode});
          } else if (d.type === 'sframe' && typeof d.text === 'string') {
            Shiny.setInputValue('builder_sframe', d.text, {priority: 'event'});
          } else if (d.type === 'dirty') {
            $('#design_unsaved').toggle(d.dirty === true);
            $('#design_saved').toggle(d.dirty !== true);
          } else if (d.type === 'state') {
            $('#design_undo').prop('disabled', d.undo !== true);
            $('#design_redo').prop('disabled', d.redo !== true);
            $('#design_save').prop('disabled', d.saveDisabled === true);
          } else if (d.type === 'goto' && (d.screen === 'collect' || d.screen === 'references')) {
            // The builder's Google Sheets and References tabs and the picker's
            // Manage references open Studio's own screen (UI-2, 4949b18).
            studioPicked = true;
            studioShowScreen(null, d.screen);
          } else if (d.type === 'goto' && d.screen === 'plan') {
            // The builder's canvas offers Plan as the next step (UI-3 item 5),
            // and the sidebar's Plan entry picks the mode.
            studioPicked = true;
            $('.studio-nav a[data-nav=\"plan\"]').click();
          }
        });
        // An instrument Studio cannot send leaves the builder unable to save,
        // so nothing it holds replaces that instrument and its history.
        var studioDesignProblem = null;
        Shiny.addCustomMessageHandler('surveyframe-design-sframe', function(m) {
          studioDesignText = m.text || null;
          studioDesignProblem = m.problem || null;
          if (studioDesignProblem) {
            studioDesignPost({type: 'sframe-blocked', message: studioDesignProblem});
          } else if (!m.from_builder && studioDesignText) {
            studioDesignPost({type: 'sframe', text: studioDesignText});
          }
        });
        Shiny.addCustomMessageHandler('surveyframe-design-saved', function(m) {
          studioDesignPost({type: 'sframe-saved', ok: m.ok, message: m.message});
        });

        Shiny.addCustomMessageHandler('surveyframe-switch-tab', function(tab) {
          var link = $('[data-tab=\"' + tab + '\"]');
          if (link.length === 0) return;
          studioShowScreen(link, tab);
        });

        // Copies a whole result-canvas block (title, badges, APA line,
        // table, chart, decision rule, and the interpretation as currently
        // typed) as one rich-text unit, so pasting into Word/LibreOffice/
        // Google Docs brings the table and chart image over instead of a
        // flat text dump. Built client-side from the live DOM (not from a
        // string baked in at render time) so the interpretation textarea's
        // current value is included even though it was typed after the
        // page loaded.
        window.studioCopyResultBlock = function(btn) {
          var block = btn.closest('.result-canvas-block');
          if (!block) return;
          var clone = block.cloneNode(true);
          var cloneBtn = clone.querySelector('.studio-copy-btn');
          if (cloneBtn) cloneBtn.remove();
          var ta = block.querySelector('textarea');
          var taClone = clone.querySelector('textarea');
          if (ta && taClone) {
            var div = document.createElement('div');
            div.style.whiteSpace = 'pre-wrap';
            div.textContent = ta.value || '';
            taClone.parentNode.replaceChild(div, taClone);
          }
          var html = '<div>' + clone.innerHTML + '</div>';
          var text = clone.textContent || '';
          var restore = function() {
            var t = btn.textContent;
            btn.textContent = 'Copied';
            setTimeout(function() { btn.textContent = t; }, 1400);
          };
          if (window.ClipboardItem && navigator.clipboard && navigator.clipboard.write) {
            var item = new ClipboardItem({
              'text/html': new Blob([html], {type: 'text/html'}),
              'text/plain': new Blob([text], {type: 'text/plain'})
            });
            navigator.clipboard.write([item]).then(restore, function() {
              navigator.clipboard.writeText(text).then(restore);
            });
          } else {
            navigator.clipboard.writeText(text).then(restore);
          }
        };
      ")),

      # Design (0.4.3): the SurveyBuilder, served from this origin, in an
      # iframe. A save in it becomes the open instrument.
      tags$div(id = "screen-design", class = screen_class("design"),
        tags$div(class = "screen-head",
          tags$h2(class = "screen-title", id = "design_title", "Design"),
          uiOutput("design_status", inline = TRUE),
          # The builder reports its save state, undo and redo (UI-3 item 3),
          # and this row holds them, with Save to Studio at the far right.
          tags$span(id = "design_saved", class = "hint design-save-state", "Saved"),
          tags$span(id = "design_unsaved", class = "hint design-save-state", style = "display: none;",
                 "Unsaved changes"),
          tags$div(class = "design-actions",
            tags$button(type = "button", id = "design_undo", class = "btn sf-tertiary design-hist",
              title = "Undo (Ctrl+Z)", `aria-label` = "Undo", disabled = NA, HTML("&#8630;")),
            tags$button(type = "button", id = "design_redo", class = "btn sf-tertiary design-hist",
              title = "Redo (Ctrl+Y)", `aria-label` = "Redo", disabled = NA, HTML("&#8631;")),
            tags$button(type = "button", id = "design_save", class = "btn btn-primary sf-primary",
              title = "Make this survey the instrument Studio has open (Ctrl+S)", "Save to Studio"))),
        tags$iframe(id = "design_frame", title = "SurveyBuilder",
          src = studio_asset_src("survey_builder.html", "host=studio"),
          style = paste("width: 100%; height: calc(100vh - 150px); min-height: 600px;",
                        "border: 1px solid var(--sf-border); border-radius: 8px; background: var(--sf-surface);"))
      ),

      tags$div(id = "screen-open", class = screen_class("open"),
        tags$div(class = "screen-head", tags$h2(class = "screen-title", "Open Instrument")),
        tags$div(class = "card",
          tags$div(class = "card-title", "Load an existing .sframe"),
          studio_primary_file(fileInput("instr_file", NULL,
                    accept = ".sframe",
                    buttonLabel = "Browse .sframe file",
                    placeholder = "No file selected")),
          uiOutput("open_status")
        ),
        uiOutput("instrument_summary_card")
      ),

      tags$div(id = "screen-amendments", class = screen_class("amendments"),
        tags$div(class = "screen-head", tags$h2(class = "screen-title", "Amendments")),
        uiOutput("amend_gate"),
        tags$div(class = "card",
          tags$div(class = "card-title", "Change the instrument"),
          tags$p(class = "hint",
            "Studio keeps the open instrument as the version before. Edit it in Design and save, and Studio asks what changed and why before it records the amendment."),
          actionButton("amend_edit_design", "Edit in Design", class = "btn-primary sf-primary"),
          tags$details(class = "amend-import",
            tags$summary("Import an externally revised version"),
            tags$p(class = "hint",
              "A revised .sframe file made outside Studio. Studio shows what it changes, then asks for the amendment details."),
            fileInput("amend_revised_file", NULL,
                      accept = ".sframe",
                      buttonLabel = "Browse revised .sframe file",
                      placeholder = "No file selected")
          )
        ),
        tags$div(class = "card",
          tags$div(class = "card-title", "Amendment log"),
          uiOutput("amendment_version_line"),
          tags$p(class = "hint",
            "Every disclosed change to this instrument, oldest first. Saved into the .sframe file itself once you export it."),
          tags$p(class = "hint", id = "amend_put_back_note",
            "An item dropped under a result can be put back there while this session lasts. After the file is opened again, put the item back in Design, which records it as an amendment."),
          tags$div(style = "overflow-x:auto", shiny::tableOutput("amendment_log_table"))
        )
      ),

      # References (0.4.3): the works the instrument cites, carried in the
      # .sframe file and listed once at the end of the report.
      tags$div(id = "screen-references", class = screen_class("references"),
        tags$div(class = "screen-head", tags$h2(class = "screen-title", "References")),
        uiOutput("refs_gate"),
        uiOutput("refs_table"),
        tags$div(class = "card",
          tags$div(class = "card-title", "Add references"),
          tags$p(class = "hint",
            "Paste BibTeX from Google Scholar (Cite, then BibTeX), Zotero, Mendeley or a journal page. Citing a source needs no amendment, and each change applies to the open instrument at once. Export it to keep the references in the .sframe file."),
          textAreaInput("refs_bibtex", "BibTeX", rows = 6, width = "100%",
            placeholder = "@article{key, author = {Family, Given}, title = {...}, journal = {...}, year = {...}}"),
          selectizeInput("refs_cited_by", "Where is this source used?", choices = NULL, multiple = TRUE,
            options = list(placeholder = "The instrument as a whole")),
          tags$p(class = "hint", "Stored as the reference's cited by list in the .sframe file."),
          actionButton("refs_add_btn", "Add from BibTeX", class = "btn-primary sf-primary")
        ),
        tags$div(class = "card",
          tags$div(class = "card-title", "Remove a reference"),
          selectInput("refs_remove_id", "Citation key", choices = NULL),
          actionButton("refs_remove_btn", "Remove reference")
        )
      ),

      tags$div(id = "screen-preview", class = screen_class("preview"),
        tags$div(class = "screen-head", tags$h2(class = "screen-title", "Preview"),
          studio_next_primary("collect", "Share this survey")),
        uiOutput("preview_gate"),
        tags$div(id = "survey_preview_frame", uiOutput("survey_preview_items"))
      ),

      # Collect (0.4.3): the Google Sheets collector, the survey file to
      # deploy, and the way on to reading the responses.
      tags$div(id = "screen-collect", class = screen_class("collect"),
        tags$div(class = "screen-head", tags$h2(class = "screen-title", "Collect")),
        uiOutput("collect_gate"),
        tags$div(class = "card",
          tags$div(class = "card-title", "1. The Google Sheet and its collector"),
          tags$p(class = "hint",
            "Responses go to a Google Sheet you own, through an Apps Script collector bound to it. Keep the sheet private. The collector writes with your access, so the sheet needs no sharing."),
          textInput("collect_sheet_url", "Google Sheet URL", width = "100%",
                    placeholder = "https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID"),
          downloadButton("collect_gs_dl", "Download Apps Script (.gs)", class = "btn-outline sf-secondary"),
          tags$ol(
            tags$li("Create a Google Sheet, paste its URL above, and download the Apps Script."),
            tags$li("In the sheet, open Extensions, then Apps Script. Paste the whole file, replacing any code there."),
            tags$li("In the editor, open Services and add the Google Sheets API, with the identifier Sheets."),
            tags$li("Click Deploy, then New deployment, and pick Web app."),
            tags$li("Set Who has access to Anyone. This lets the survey submit to the web app. It gives no one access to the sheet."),
            tags$li("Copy the Web app URL into step 2.")
          )
        ),
        tags$div(class = "card",
          tags$div(class = "card-title", "2. The survey file"),
          tags$p(class = "hint",
            "One HTML file holds the whole survey. Put it on any web host, such as GitHub Pages or Netlify, or send the file itself. With a collector URL, each submission goes to your sheet. Without one, the survey runs but stores nothing."),
          textInput("collect_endpoint", "Web app address that receives the responses", width = "100%",
                    placeholder = "https://script.google.com/macros/s/.../exec"),
          downloadButton("collect_survey_dl", "Download survey (.html)", class = "btn-primary sf-primary")
        ),
        tags$div(class = "card",
          tags$div(class = "card-title", "3. Read the responses"),
          tags$p(class = "hint",
            "As responses arrive, read them from the sheet on the Responses screen, which takes the sheet URL from step 1."),
          tags$a(href = "#", `data-tab` = "responses", class = "btn btn-outline sf-secondary",
                 "Read from Google Sheet")
        )
      ),

      tags$div(id = "screen-responses", class = screen_class("responses"),
        tags$div(class = "screen-head", tags$h2(class = "screen-title", "Responses")),
        uiOutput("responses_gate"),
        # The planned workflow first (item 12f): the Google Sheet the survey
        # submits to, then a CSV file, then help for files from other tools.
        tags$div(class = "card",
          tags$div(class = "card-title", "Read responses from a deployed Google Sheet"),
          tags$p(class = "hint",
            "If the survey was deployed with the surveyframe Google Sheets collector, read the live responses straight from the sheet. This needs the googlesheets4 package and access to the sheet."),
          uiOutput("sheet_pkg_note"),
          textInput("sheet_url", "Google Sheet ID or URL",
                    placeholder = "https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID"),
          fluidRow(
            column(4, textInput("sheet_tab", "Sheet tab", value = "Responses")),
            column(4, textInput("sheet_id_col", "Column holding each response's ID", value = "respondent_id")),
            column(4, textInput("sheet_time_col", "Column holding the submission time", value = "submitted_at"))
          ),
          actionButton("load_sheet_btn", "Read from Google Sheet", class = "btn-primary sf-primary")
        ),
        tags$div(class = "card",
          tags$div(class = "card-title", "Response data"),
          fileInput("resp_file", NULL,
                    accept = ".csv",
                    buttonLabel = "Browse CSV file",
                    placeholder = "No file selected"),
          fluidRow(
            column(4, textInput("resp_id_col", "Column holding each response's ID", placeholder = "e.g. id")),
            column(4, textInput("resp_time_col", "Column holding the submission time", placeholder = "e.g. submitted_at")),
            column(4, checkboxInput("resp_strict", "Refuse a file with missing or unexpected columns (strict column check)", value = TRUE))
          ),
          actionButton("load_responses_btn", "Load responses", class = "btn-outline sf-secondary")
        ),
        tags$div(class = "card",
          tags$div(class = "card-title", "Loading responses collected elsewhere"),
          tags$p(class = "hint",
            "Responses can come from the exported surveyframe survey or from another tool (Microsoft Forms, Qualtrics, Google Forms, and similar). Export them to CSV, then:"),
          tags$ol(class = "hint", style = "margin: 0 0 12px; padding-left: 18px; line-height: 1.7",
            tags$li("Open the matching instrument on the Open Instrument screen. The .sframe carries the analysis plan, so it is still required."),
            tags$li("Make sure the CSV column names match the item IDs in that instrument (download the sample CSV below for the expected format)."),
            tags$li("Browse the CSV above, set the respondent-ID and submitted-at columns if present, then click Load responses.")
          ),
          downloadButton("download_sample_csv", "Download sample CSV format", class = "btn-outline sf-secondary"),
          actionButton("load_sample_btn", "Or load the bundled demo", class = "btn-outline sf-secondary")
        ),
        uiOutput("responses_summary_card"),
        uiOutput("responses_amend_card")
      ),

      tags$div(id = "screen-quality", class = screen_class("quality"),
        tags$div(class = "screen-head", tags$h2(class = "screen-title", "Quality"),
          studio_next_primary("reliability", "Check reliability")),
        uiOutput("quality_gate"),
        uiOutput("quality_output"),
        plotOutput("studio_quality_chart", height = "260px"),
        plotOutput("studio_missing_chart", height = "260px"),
        uiOutput("quality_amend_card")
      ),

      tags$div(id = "screen-reliability", class = screen_class("reliability"),
        tags$div(class = "screen-head", tags$h2(class = "screen-title", "Reliability"),
          studio_next_primary("analysis", "Run the declared analyses")),
        uiOutput("reliability_gate"),
        uiOutput("reliability_output"),
        plotOutput("studio_reliability_chart", height = "300px")
      ),

      tags$div(id = "screen-analysis", class = screen_class("analysis"),
        tags$div(class = "screen-head", tags$h2(class = "screen-title", "Analyse"),
          studio_next_primary("export", "Interpret and report")),
        uiOutput("analysis_gate"),
        uiOutput("analysis_declared_plan"),
        uiOutput("analysis_results_row")
      ),

      tags$div(id = "screen-dashboard", class = screen_class("dashboard"),
        tags$div(class = "screen-head", tags$h2(class = "screen-title", "Explore")),
        uiOutput("dashboard_gate"),
        tags$div(class = "studio-tabs",
          radioButtons(
            "dashboard_view", NULL,
            choices = c("Overview", "Items", "Scales", "Data"),
            selected = "Overview",
            inline = TRUE
          )
        ),
        uiOutput("dash_filter_bar"),
        uiOutput("studio_dashboard_content")
      ),

      tags$div(id = "screen-export", class = screen_class("export"),
        # Report (UX-07): 4 local tabs. Every pane stays in the page and is
        # only hidden, so a choice made in 1 survives a switch to another.
        # The .sframe download sits beside the title as "Download copy".
        tags$div(class = "screen-head",
          tags$h2(class = "screen-title", "Report"),
          tags$span(class = "screen-head-actions", uiOutput("export_sframe_ui", inline = TRUE),
            uiOutput("export_report_ui", inline = TRUE))),
        uiOutput("export_gate"),
        tags$div(class = "report-tabs", role = "tablist", `aria-label` = "Report",
          studio_report_tab("interpret", "Interpret", TRUE),
          studio_report_tab("configure", "Configure"),
          studio_report_tab("export", "Export report"),
          studio_report_tab("reproduce", "Reproduce")),
        studio_report_pane("interpret", TRUE,
          tags$div(class = "card",
            tags$div(class = "card-title", "Interpretations"),
            tags$p(class = "hint",
              "Open a research question to read its result and write what it means. The report shows each interpretation beside the pre-declared decision rule. Interpretations go into the report only, never into the instrument file."),
            uiOutput("export_interpretations_ui")
          )),
        # The options render_report() takes from a host (owner 2026-10-30).
        studio_report_pane("configure", FALSE,
          tags$div(class = "card",
            tags$div(class = "card-title", "Report options"),
            tags$div(class = "opt-row",
              textInput("rpt_title", "Title", placeholder = "The instrument's title"),
              textInput("rpt_authors", "Authors",
                        placeholder = "Separated by commas. The instrument's authors")
            ),
            tags$div(class = "opt-row",
              shiny::radioButtons(
                "rpt_palette", "Chart theme",
                choices = c(
                  "Colour (on-screen reading)" = "web",
                  "Black and white (print and journal submission)" = "print"
                ),
                selected = "web"
              ),
              tags$div(tags$label(class = "control-label", "Code"),
                checkboxInput("rpt_show_code", "Show the R code for each result", value = TRUE))
            ),
            tags$p(class = "hint", id = "rpt_refs_note",
              "The report cites only the references the instrument records. Type @ in an interpretation to cite one. ",
              tags$a(href = "#", `data-tab` = "references", id = "rpt_manage_refs", "Manage references")),
            tags$div(class = "ref-style",
              selectInput("rpt_style", "Reference style",
                choices = sframe_studio_style_choices(sframe_studio_quarto_note()$ok), selected = "apa"),
              if (!sframe_studio_quarto_note()$ok)
                tags$p(class = "hint", id = "rpt_style_note", "Other reference styles need Quarto."),
              shiny::conditionalPanel("input.rpt_style == 'other'",
                fileInput("rpt_csl", "Style file (.csl)", accept = ".csl"),
                tags$a(href = "https://www.zotero.org/styles", target = "_blank",
                       rel = "noopener noreferrer", id = "rpt_style_find",
                       "Find a style at zotero.org/styles"))),
            tags$label(class = "control-label", "Sections"),
            tags$div(class = "opt-grid",
              checkboxInput("rpt_codebook", "Codebook", value = TRUE),
              checkboxInput("rpt_quality", "Quality report", value = TRUE),
              checkboxInput("rpt_missing", "Missing-data report", value = TRUE),
              checkboxInput("rpt_descriptives", "Descriptives", value = TRUE),
              checkboxInput("rpt_reliability", "Reliability", value = TRUE),
              checkboxInput("rpt_analysis", "Results of the declared analyses", value = TRUE),
              checkboxInput("rpt_models", "Saved models and the R code that fits them", value = TRUE)
            ),
            tags$details(class = "opt-more",
              tags$summary("More options: figures"),
              tags$div(class = "opt-row",
                numericInput("rpt_fig_width", "Figure width (inches)", value = NA, min = 1, step = 0.5),
                numericInput("rpt_fig_height", "Figure height (inches)", value = NA, min = 1, step = 0.5),
                numericInput("rpt_fig_dpi", "Resolution (dpi)", value = NA, min = 72, step = 50),
                selectInput("rpt_fig_format", "Figure format",
                  choices = c("Each engine's own" = "default", "PNG" = "png", "SVG" = "svg"))
              ),
              tags$p(class = "hint", "Empty fields keep each engine's own figure size and resolution.")
            )
          )),
        studio_report_pane("export", FALSE,
          tags$div(class = "card",
            tags$div(class = "card-title", "Finished report"),
            uiOutput("export_engine_note"),
            shiny::radioButtons("rpt_format", "Format",
              choices = sframe_studio_report_formats(sframe_studio_quarto_note()$ok),
              selected = "html"),
            tags$p(class = "hint",
              "The survey file and the Google Sheets collector are on the Collect screen.")
          )),
        studio_report_pane("reproduce", FALSE,
          tags$div(class = "card",
            tags$div(class = "card-title", "Reproducible source"),
            tags$p(class = "hint",
              "A folder holding report.qmd, the .sframe file, the responses, the references and their style, the results record and a manifest, which lists every file with its checksum. Open report.qmd in RStudio or Positron and render it: it recomputes every number from the folder's files and checks them. Writing the folder needs no Quarto, and it uses the options on Configure."),
            uiOutput("export_source_ui")
          ))
      )
    )
  )
)

# What a screen with nothing to show yet says, with a link to each next
# stage, so the researcher is never left on an empty screen.
studio_stage_labels <- c(design = "Design", open = "Open Instrument",
                         collect = "Collect", responses = "Responses")
studio_next_stage <- function(message, tabs) {
  tags$div(class = "card next-stage",
    tags$p(message),
    tags$p(class = "next-stage-links", tags$span(class = "hint", "Next:"),
      lapply(tabs, function(tab) {
        tags$a(href = "#", `data-tab` = tab, class = "btn btn-outline sf-secondary",
               studio_stage_labels[[tab]])
      })))
}
no_instrument_next <- function(what) {
  studio_next_stage(paste("No instrument is open. Design one, or open a",
                          "file, to", paste0(what, ".")), c("design", "open"))
}
no_responses_next <- function(what) {
  studio_next_stage(paste("No responses are loaded. Collect them, or upload",
                          "a file of responses, to", paste0(what, ".")),
                    c("collect", "responses"))
}

server <- function(input, output, session) {
  rv <- reactiveValues(
    builder = initial_builder,
    instrument = INITIAL_INSTRUMENT,
    responses = INITIAL_RESPONSES,
    active_screen = initial_tab,
    # Where the open instrument came from: "r", "file", "design", or the
    # message of a failed check.
    open_verification = if (is.null(INITIAL_INSTRUMENT)) NULL else "r",
    # The instruments from before and after each Drop from scale recorded
    # in this session, keyed by the amendment's new hash, for Put back.
    drops = list()
  )

  set_builder_state <- function(state) {
    rv$builder <- state
    invisible(state)
  }

  if (!is.null(INITIAL_RESPONSES) && !is.data.frame(INITIAL_RESPONSES) &&
      !is.null(rv$instrument)) {
    tryCatch({
      rv$responses <- read_responses(INITIAL_RESPONSES, rv$instrument)
    }, error = function(e) NULL)
  }

  switch_tab <- function(tab) {
    session$sendCustomMessage("surveyframe-switch-tab", tab)
  }

  observeEvent(input$current_tab, {
    rv$active_screen <- input$current_tab
  }, ignoreInit = TRUE)

  sync_builder_inputs <- function(state) {
    updateTextInput(session, "draft_title", value = state$meta$title %||% "Untitled Survey")
    updateTextInput(session, "draft_version", value = state$meta$version %||% "0.1.0")
    updateTextAreaInput(session, "draft_description", value = state$meta$description %||% "")
    updateTextInput(session, "draft_authors", value = format_value(state$meta$authors))
    updateTextInput(session, "draft_languages", value = format_value(state$meta$languages))
  }

  builder_meta <- reactive({
    # Design now happens in the SurveyBuilder; the studio Build screen was
    # removed. Meta comes from the loaded instrument (rv$builder$meta); the
    # draft_* inputs no longer exist, so each field falls back to it.
    m <- rv$builder$meta %||% list()
    languages <- parse_csv(input$draft_languages %||% "")
    list(
      title = trimws(input$draft_title %||% m$title %||% "Untitled Survey"),
      version = trimws(input$draft_version %||% m$version %||% "0.1.0"),
      description = trim_or_null(input$draft_description) %||% (m$description %||% NULL),
      authors = {
        values <- parse_csv(input$draft_authors %||% "")
        if (length(values) == 0) (m$authors %||% NULL) else values
      },
      languages = if (length(languages) == 0) (m$languages %||% "en") else languages,
      # Carried from the loaded file. Without it the draft is stamped with the
      # time of the edit and an untouched file no longer matches its hash.
      created_at = m$created_at
    )
  })

  draft_result <- reactive({
    builder_validate_draft(
      meta = builder_meta(),
      choices = rv$builder$choices,
      items = rv$builder$items,
      scales = rv$builder$scales,
      branching = rv$builder$branching,
      checks = rv$builder$checks,
      analysis_plan = rv$builder$analysis_plan %||% list(),
      models = rv$builder$models %||% list(),
      render = rv$builder$render %||% list(),
      amendments = rv$builder$amendments %||% list(),
      designs = rv$builder$designs %||% list(),
      references = rv$builder$references %||% list(),
      study = rv$builder$study,
      origin = rv$builder$origin
    )
  })

  preview_instrument <- reactive({
    draft_result()$instrument
  })

  observe({
    if (draft_result()$valid) {
      rv$instrument <- draft_result()$instrument
    }
  })

  observe({
    choice_ids <- vapply(rv$builder$choices, function(choice) choice$id, character(1))
    updateSelectInput(
      session,
      "item_choice_set",
      choices = optional_choices(choice_ids),
      selected = if ((input$item_choice_set %||% "") %in% c("", choice_ids)) input$item_choice_set else ""
    )
    updateSelectInput(session, "remove_choice_id", choices = optional_choices(choice_ids, "(Select one)"))
  })

  observe({
    item_ids <- vapply(rv$builder$items, function(item) item$id, character(1))
    updateSelectInput(session, "remove_item_id", choices = optional_choices(item_ids, "(Select one)"))
    updateCheckboxGroupInput(
      session,
      "scale_items",
      choices = stats::setNames(item_ids, item_ids),
      selected = intersect(input$scale_items %||% character(0), item_ids)
    )
    current_scale_items <- intersect(input$scale_items %||% character(0), item_ids)
    updateCheckboxGroupInput(
      session,
      "scale_reverse_items",
      choices = stats::setNames(current_scale_items, current_scale_items),
      selected = intersect(input$scale_reverse_items %||% character(0), current_scale_items)
    )
    updateSelectInput(session, "branch_item_id", choices = optional_choices(item_ids, "(Select one)"))
    updateSelectInput(session, "branch_depends_on", choices = optional_choices(item_ids, "(Select one)"))
    branch_labels <- if (length(rv$builder$branching) == 0) {
      character(0)
    } else {
      vapply(
        rv$builder$branching,
        function(rule) paste(rule$item_id, rule$action, "when", rule$depends_on, rule$operator, format_value(rule$value)),
        character(1)
      )
    }
    branch_keys <- if (length(rv$builder$branching) == 0) character(0) else seq_along(rv$builder$branching)
    updateSelectInput(session, "remove_branch_key",
                      choices = c(stats::setNames("", "(Select one)"), stats::setNames(as.character(branch_keys), branch_labels)))
    updateSelectInput(session, "check_item_id", choices = optional_choices(item_ids, "(Select one)"))
  })

  observe({
    scale_ids <- vapply(rv$builder$scales, function(scale) scale$id, character(1))
    updateSelectInput(session, "remove_scale_id", choices = optional_choices(scale_ids, "(Select one)"))
  })

  observe({
    check_ids <- vapply(rv$builder$checks, function(check) check$id, character(1))
    updateSelectInput(session, "remove_check_id", choices = optional_choices(check_ids, "(Select one)"))
  })

  session$onFlushed(function() {
    session$sendCustomMessage("surveyframe-launch-tab",
                              shiny::isolate(rv$active_screen %||% initial_tab))
  }, once = TRUE)

  observeEvent(input$new_survey_btn, {
    rv$builder <- builder_empty_state()
    rv$instrument <- NULL
    rv$responses <- NULL
    sync_builder_inputs(rv$builder)
    showNotification("Cleared the loaded instrument.", type = "message")
    switch_tab("open")
  })

  observeEvent(input$go_preview_btn, {
    switch_tab("preview")
  })

  observeEvent(input$add_choice_btn, {
    choice_id <- trim_or_null(input$choice_id)
    values <- parse_choice_values(input$choice_values)
    labels <- parse_lines(input$choice_labels)

    if (is.null(choice_id)) {
      showNotification("Choice set ID is required.", type = "error")
      return()
    }
    if (length(values) == 0 || length(labels) == 0) {
      showNotification("Enter at least one value and label.", type = "error")
      return()
    }
    if (length(values) != length(labels)) {
      showNotification("Choice set values and labels must have the same length.", type = "error")
      return()
    }

    choice <- sframe_choice_set(
      id = choice_id,
      values = values,
      labels = labels,
      allow_other = isTRUE(input$choice_allow_other),
      randomise = isTRUE(input$choice_randomise)
    )
    existing <- choice_id %in% vapply(rv$builder$choices, function(x) x$id, character(1))
    state <- rv$builder
    state$choices <- upsert_component(state$choices, choice)
    set_builder_state(state)
    showNotification(
      if (existing) "Choice set updated." else "Choice set added.",
      type = "message"
    )
  })

  observeEvent(input$remove_choice_btn, {
    choice_id <- trim_or_null(input$remove_choice_id)
    if (is.null(choice_id)) {
      return()
    }
    in_use <- vapply(rv$builder$items, function(item) identical(item$choice_set, choice_id), logical(1))
    if (any(in_use)) {
      showNotification("That choice set is still used by one or more items.", type = "error")
      return()
    }
    state <- rv$builder
    state$choices <- remove_component(state$choices, choice_id)
    set_builder_state(state)
    showNotification("Choice set deleted.", type = "message")
  })

  observeEvent(input$add_item_btn, {
    item_id <- trim_or_null(input$item_id)
    item_label <- trim_or_null(input$item_label)
    item_type <- input$item_type %||% "text"
    choice_set <- trim_or_null(input$item_choice_set)

    if (is.null(item_id) || is.null(item_label)) {
      showNotification("Item ID and question text are required.", type = "error")
      return()
    }
    if (item_type %in% c("single_choice", "multiple_choice", "likert") && is.null(choice_set)) {
      showNotification("Choice items need a choice set.", type = "error")
      return()
    }

    edits <- list(
      id = item_id,
      label = item_label,
      type = item_type,
      required = isTRUE(input$item_required),
      choice_set = if (item_type %in% c("single_choice", "multiple_choice", "likert")) choice_set else NULL,
      help = trim_or_null(input$item_help),
      placeholder = if (item_type %in% c("text", "textarea")) trim_or_null(input$item_placeholder) else NULL
    )

    ids <- vapply(rv$builder$items, function(x) x$id, character(1))
    existing <- item_id %in% ids
    # An edit applies the form's fields to the item already there, so reverse
    # coding, scale membership, the page and type settings survive it.
    item <- if (existing) {
      sframe_builder_update_item(rv$builder$items[[match(item_id, ids)]], edits)
    } else {
      sframe_builder_as_item(edits)
    }
    state <- rv$builder
    state$items <- upsert_component(state$items, item)
    set_builder_state(state)
    showNotification(if (existing) "Item updated." else "Item added.", type = "message")
  })

  observeEvent(input$remove_item_btn, {
    item_id <- trim_or_null(input$remove_item_id)
    if (is.null(item_id)) {
      return()
    }
    rv$builder <- drop_item_from_builder(rv$builder, item_id)
    showNotification("Item deleted. Related scale membership, branching, and checks were updated.", type = "message")
  })

  observeEvent(input$add_scale_btn, {
    scale_id <- trim_or_null(input$scale_id)
    scale_label <- trim_or_null(input$scale_label)
    scale_items <- input$scale_items %||% character(0)
    min_valid <- suppressWarnings(as.integer(input$scale_min_valid))

    if (is.null(scale_id) || is.null(scale_label)) {
      showNotification("Scale ID and label are required.", type = "error")
      return()
    }
    if (length(scale_items) == 0) {
      showNotification("Select at least one item for the scale.", type = "error")
      return()
    }
    if (is.na(min_valid) || min_valid < 1) {
      min_valid <- NULL
    }
    if (!is.null(min_valid) && min_valid > length(scale_items)) {
      showNotification("Minimum valid items must be less than or equal to the number of scale items.", type = "error")
      return()
    }

    scale <- sframe_scale(
      id = scale_id,
      label = scale_label,
      items = scale_items,
      method = input$scale_method %||% "mean",
      min_valid = min_valid,
      reverse_items = input$scale_reverse_items %||% NULL
    )
    existing <- scale_id %in% vapply(rv$builder$scales, function(x) x$id, character(1))
    state <- rv$builder
    state$scales <- upsert_component(state$scales, scale)
    set_builder_state(state)
    showNotification(if (existing) "Scale updated." else "Scale added.", type = "message")
  })

  observeEvent(input$remove_scale_btn, {
    scale_id <- trim_or_null(input$remove_scale_id)
    if (is.null(scale_id)) {
      return()
    }
    state <- rv$builder
    state$scales <- remove_component(state$scales, scale_id)
    set_builder_state(state)
    showNotification("Scale deleted.", type = "message")
  })

  observeEvent(input$add_branch_btn, {
    target <- trim_or_null(input$branch_item_id)
    depends_on <- trim_or_null(input$branch_depends_on)
    operator <- input$branch_operator %||% "=="
    value <- parse_branch_value(input$branch_value, operator)

    if (is.null(target) || is.null(depends_on)) {
      showNotification("Select both a target item and a controlling item.", type = "error")
      return()
    }
    if (identical(target, depends_on)) {
      showNotification("Choose a different controlling item for this branching rule.", type = "error")
      return()
    }
    if (is.null(value)) {
      showNotification("Enter a match value for the branching rule.", type = "error")
      return()
    }

    rule <- sframe_branch(
      item_id = target,
      depends_on = depends_on,
      operator = operator,
      value = value,
      action = input$branch_action %||% "show"
    )

    branch_key <- paste(target, depends_on, operator, input$branch_action %||% "show", sep = "|")
    existing_keys <- if (length(rv$builder$branching) == 0) {
      character(0)
    } else {
      vapply(rv$builder$branching, function(x) {
        paste(x$item_id, x$depends_on, x$operator, x$action, sep = "|")
      }, character(1))
    }

    if (branch_key %in% existing_keys) {
      idx <- match(branch_key, existing_keys)
      state <- rv$builder
      state$branching[[idx]] <- rule
      set_builder_state(state)
      showNotification("Branching rule updated.", type = "message")
    } else {
      state <- rv$builder
      state$branching <- c(state$branching, list(rule))
      set_builder_state(state)
      showNotification("Branching rule added.", type = "message")
    }
  })

  observeEvent(input$remove_branch_btn, {
    branch_key <- suppressWarnings(as.integer(input$remove_branch_key %||% NA))
    if (is.na(branch_key) || branch_key < 1 || branch_key > length(rv$builder$branching)) {
      return()
    }
    state <- rv$builder
    state$branching <- state$branching[-branch_key]
    set_builder_state(state)
    showNotification("Branching rule deleted.", type = "message")
  })

  observeEvent(input$add_check_btn, {
    check_id <- trim_or_null(input$check_id)
    item_id <- trim_or_null(input$check_item_id)
    check_type <- input$check_type %||% "attention"
    pass_values <- parse_check_values(input$check_pass_values)

    if (is.null(check_id) || is.null(item_id)) {
      showNotification("Check ID and check item are required.", type = "error")
      return()
    }
    if (check_type %in% c("attention", "instructional") && is.null(pass_values)) {
      showNotification("Enter at least one pass value for this check.", type = "error")
      return()
    }

    check <- sframe_attention_check(
      id = check_id,
      item_id = item_id,
      type = check_type,
      pass_values = pass_values,
      fail_action = input$check_fail_action %||% "flag",
      label = trim_or_null(input$check_label),
      notes = trim_or_null(input$check_notes)
    )

    existing <- check_id %in% vapply(rv$builder$checks, function(x) x$id, character(1))
    state <- rv$builder
    state$checks <- upsert_component(state$checks, check)
    set_builder_state(state)
    showNotification(if (existing) "Check updated." else "Check added.", type = "message")
  })

  observeEvent(input$remove_check_btn, {
    check_id <- trim_or_null(input$remove_check_id)
    if (is.null(check_id)) {
      return()
    }
    state <- rv$builder
    state$checks <- remove_component(state$checks, check_id)
    set_builder_state(state)
    showNotification("Check deleted.", type = "message")
  })

  observeEvent(input$instr_file, {
    req(input$instr_file)
    tryCatch({
      path <- sframe_validate_upload(input$instr_file, "sframe")
      loaded <- read_sframe(path)
      rv$builder <- builder_state_from_instrument(loaded)
      rv$instrument <- loaded
      rv$responses <- NULL
      rv$open_verification <- "file"
      sync_builder_inputs(rv$builder)
      showNotification("Instrument loaded. Showing the survey preview.", type = "message")
      switch_tab("preview")
    }, error = function(e) {
      rv$open_verification <- paste("Integrity check failed:", conditionMessage(e))
      showNotification(paste("Error:", conditionMessage(e)), type = "error")
    })
  })

  # -- Design -----------------------------------------------------------------
  # The builder on the Design screen is sent the open instrument whenever it
  # changes. A change that is the builder's own save is not sent back.
  # An instrument Studio cannot write as it is is not sent, and the reason
  # shows above the builder.
  design_from_builder <- FALSE
  design_out <- reactive(sframe_studio_sframe_text(rv$instrument))
  observe({
    out <- design_out()
    from_builder <- design_from_builder
    design_from_builder <<- FALSE
    session$sendCustomMessage("surveyframe-design-sframe",
      list(text = out$text, problem = out$problem, from_builder = from_builder))
  })

  # A save in the builder is read and checked as a file would be, and
  # becomes the open instrument, as an opened file does. Loaded responses
  # stay while their item ids and choice codes still fit, and are cleared
  # with a message naming what changed when they do not.
  observeEvent(input$builder_sframe, {
    if (!is.null(design_out()$problem)) {
      session$sendCustomMessage("surveyframe-design-saved",
        list(ok = FALSE, message = design_out()$problem))
      return()
    }
    tryCatch({
      # The builder carries the log it was sent, so changed content reads
      # with a log that does not end at it, until the dialog records it.
      loaded <- suppressWarnings(read_sframe(text = input$builder_sframe),
                                 classes = "sframe_amendment_warning")
      # An instrument with a history (read from a file, or amended) that
      # changed goes through the amendment dialog (CX-12). Studio keeps the
      # open instrument as the version before.
      before <- rv$instrument
      tracked <- !is.null(before) &&
        (!is.null(attr(before, "sframe_origin")) || length(before$amendments) > 0)
      # A plan change once responses are loaded is a design amendment too,
      # with the blocks it changed in the deviation report (UX-02).
      plan_report <- if (!is.null(before) && !is.null(rv$responses))
        sframe_studio_plan_change_report(before, loaded)
      tracked <- tracked || !is.null(plan_report)
      if (tracked && !identical(sframe_content_hash(loaded), sframe_content_hash(before))) {
        amend_dlg$open(before, loaded,
          start_label = if (is.null(plan_report)) "Saved from Design. The open instrument is the version before."
            else "The plan changed after the responses were loaded, so this is a design amendment.",
          defaults = if (is.null(plan_report)) list() else
            list(reason_code = "model_respecification", deviation_report = plan_report),
          allow_new = TRUE,
          on_apply = function(new, how) {
            # Sent back to the builder, so it holds the log and version.
            design_from_builder <<- FALSE
            msg <- studio_apply_amended(new, how)
            rv$open_verification <- "design"
            session$sendCustomMessage("surveyframe-design-saved",
              list(ok = TRUE, message = msg))
          },
          on_cancel = function() {
            session$sendCustomMessage("surveyframe-design-saved",
              list(ok = FALSE, message = "Nothing was saved. The changes are still in Design."))
          })
        return(invisible(NULL))
      }
      design_from_builder <<- TRUE
      rv$builder <- builder_state_from_instrument(loaded)
      cleared <- if (!is.null(rv$responses) && !is.null(rv$instrument))
        sframe_studio_response_change(rv$instrument, loaded)
      rv$instrument <- loaded
      if (!is.null(cleared)) {
        rv$responses <- NULL
        showNotification(cleared, type = "warning", duration = 12)
      }
      rv$open_verification <- "design"
      sync_builder_inputs(rv$builder)
      session$sendCustomMessage("surveyframe-design-saved",
        list(ok = TRUE, message = "Saved to Studio as the open instrument."))
    }, error = function(e) {
      design_from_builder <<- FALSE
      session$sendCustomMessage("surveyframe-design-saved",
        list(ok = FALSE, message = paste("Studio could not open it:", conditionMessage(e))))
    })
  })

  output$design_status <- renderUI({
    ins <- rv$instrument
    problem <- design_out()$problem
    if (!is.null(problem)) {
      tags$div(class = "plan-msg", problem)
    } else if (is.null(ins)) {
      tags$p(class = "hint", paste(
        "No instrument is open. Build one here and save it to Studio, or open",
        "a file on the Open Instrument screen."))
    } else {
      tags$p(class = "hint", paste0(
        "Editing: ", ins$meta$title %||% "Untitled", " (",
        ins$meta$version %||% "", ")"))
    }
  })

  # -- Collect ----------------------------------------------------------------
  output$collect_gate <- renderUI({
    if (is.null(rv$instrument)) {
      no_instrument_next("collect responses for it")
    }
  })

  # The collector URL an instrument already carries fills step 2.
  observeEvent(rv$instrument, {
    updateTextInput(session, "collect_endpoint",
                    value = rv$instrument$render$google_sheets_endpoint %||% "")
  })

  # The sheet given in step 1 is the one the Responses screen reads.
  observeEvent(input$collect_sheet_url, {
    if (nzchar(trimws(input$collect_sheet_url))) {
      updateTextInput(session, "sheet_url", value = trimws(input$collect_sheet_url))
    }
  }, ignoreInit = TRUE)

  collect_file_stem <- function() {
    gsub("[^a-zA-Z0-9]", "_", rv$instrument$meta$title %||% "survey")
  }

  output$collect_survey_dl <- downloadHandler(
    filename = function() paste0(collect_file_stem(), ".html"),
    content = function(file) {
      req(rv$instrument)
      endpoint <- trimws(input$collect_endpoint %||% "")
      tmp <- tempfile(fileext = ".html")
      export_survey(rv$instrument, output_path = tmp, open = FALSE,
                    endpoint_url = if (nzchar(endpoint)) endpoint else NULL,
                    overwrite = TRUE)
      file.copy(tmp, file, overwrite = TRUE)
    }
  )

  output$collect_gs_dl <- downloadHandler(
    filename = function() paste0(collect_file_stem(), "_collector.gs"),
    content = function(file) {
      req(rv$instrument)
      dir <- tempfile("collector")
      dir.create(dir)
      path <- export_google_sheet(rv$instrument, trimws(input$collect_sheet_url %||% ""),
                                  output_dir = dir)
      file.copy(path, file, overwrite = TRUE)
    }
  )

  # -- References -------------------------------------------------------------
  # Edits rv$builder$references, which the draft sync composes into the open
  # instrument, so a reference added here is in everything exported.
  # The open instrument's references, for the citation picker in the page.
  observe({
    ins <- rv$instrument
    refs <- if (is.null(ins)) list() else unname(ins$references %||% list())
    session$sendCustomMessage("studio-refs", list(
      refs = lapply(refs, unclass),
      known = unname(vapply(.sframe_citations, function(c) c$key, character(1)))))
  })

  refs_targets <- reactive({
    ins <- rv$instrument
    if (is.null(ins)) return(character(0))
    ids <- function(x) vapply(x %||% list(), function(c) as.character(c$id)[1], character(1))
    items <- Filter(function(i) !(i$type %in% c("section_break", "text_block")), ins$items %||% list())
    # A block's hypotheses and the study are targets only once they are
    # written, as validate_sframe() requires.
    hyp <- ids(Filter(function(b) any(c("Null hypothesis (H0)", "Alternative hypothesis (H1)") %in%
      names(sframe_plan_declaration(b))), ins$analysis_plan %||% list()))
    c("The instrument as a whole" = "instrument",
      stats::setNames(paste0("item:", ids(items)), paste("Item:", ids(items))),
      stats::setNames(paste0("scale:", ids(ins$scales)), paste("Scale:", ids(ins$scales))),
      stats::setNames(paste0("plan:", ids(ins$analysis_plan)), paste("Plan:", ids(ins$analysis_plan))),
      stats::setNames(paste0("model:", ids(ins$models)), paste("Model:", ids(ins$models))),
      stats::setNames(paste0("hypothesis:", hyp), paste("Hypotheses:", hyp)),
      if (!is.null(ins$study)) c("The study (problem, objectives, sampling)" = "study"))
  })

  observe({
    updateSelectizeInput(session, "refs_cited_by", choices = refs_targets(), server = FALSE)
    keys <- vapply(rv$builder$references %||% list(), function(r) r$id, character(1))
    updateSelectInput(session, "refs_remove_id", choices = keys)
  })

  output$refs_gate <- renderUI({
    if (is.null(rv$instrument)) {
      no_instrument_next("manage its references")
    }
  })

  output$refs_table <- renderUI({
    refs <- rv$builder$references %||% list()
    rows <- lapply(refs, function(r) {
      who <- vapply(r$author %||% list(), function(a) a$family %||% a$literal %||% "", character(1))
      who <- if (length(who) > 2) paste(who[1], "et al.") else paste(who, collapse = " & ")
      year <- tryCatch(r$issued[["date-parts"]][[1]][[1]], error = function(e) NULL) %||%
        r$issued$literal %||% "n.d."
      tags$tr(
        tags$td(tags$code(r$id)),
        tags$td(paste0(who, " (", year, "). ", r$title %||% "")),
        tags$td(paste(r$cited_by %||% "instrument", collapse = ", "))
      )
    })
    table_card("References in this instrument", c("Key", "Reference", "Cited by"), rows,
               "No references yet. The report lists every work the instrument cites once, at the end.",
               wide = TRUE)
  })

  observeEvent(input$refs_add_btn, {
    req(rv$instrument)
    text <- input$refs_bibtex %||% ""
    if (!nzchar(trimws(text))) {
      showNotification("Paste a BibTeX entry first.", type = "error")
      return()
    }
    cited <- input$refs_cited_by
    if (!length(cited)) cited <- "instrument"
    tryCatch({
      found <- read_bibtex(text = text, cited_by = cited)
      if (!length(found)) stop("No BibTeX entry was found in that text.")
      current <- rv$builder$references %||% list()
      clash <- intersect(names(found), vapply(current, function(r) r$id, character(1)))
      if (length(clash)) stop("A reference with key ", paste(clash, collapse = ", "), " is already here.")
      state <- rv$builder
      state$references <- c(current, unname(found))
      set_builder_state(state)
      updateTextAreaInput(session, "refs_bibtex", value = "")
      showNotification(sprintf("%d reference%s added.", length(found),
                               if (length(found) == 1) "" else "s"), type = "message")
    }, error = function(e) showNotification(conditionMessage(e), type = "error"))
  })

  observeEvent(input$refs_remove_btn, {
    key <- input$refs_remove_id %||% ""
    req(nzchar(key))
    state <- rv$builder
    state$references <- Filter(function(r) !identical(r$id, key), state$references %||% list())
    set_builder_state(state)
    showNotification(paste("Removed", key), type = "message")
  })

  output$amend_gate <- renderUI({
    if (is.null(rv$instrument)) {
      studio_next_stage(paste(
        "Open the instrument to amend first. It becomes the \"previous\"",
        "version disclosed against."), c("design", "open"))
    }
  })

  # The 1 amendment dialog (UX-06, UX-19). Every start opens it, and it
  # hands back the instrument to make the open one.
  amend_dlg <- sframe_studio_amend_server("amend_dlg")

  # The amended or new instrument becomes the open one, as a save does.
  # Responses stay while their columns still fit.
  studio_apply_amended <- function(new, how, notify_builder = TRUE) {
    cleared <- if (!is.null(rv$responses) && !is.null(rv$instrument))
      sframe_studio_response_change(rv$instrument, new)
    rv$builder <- builder_state_from_instrument(new)
    rv$instrument <- new
    if (!is.null(cleared)) {
      rv$responses <- NULL
      showNotification(cleared, type = "warning", duration = 12)
    }
    sync_builder_inputs(rv$builder)
    msg <- if (identical(how, "amendment")) {
      n <- length(new$amendments)
      sprintf("Amendment %d recorded. Version %s. Export the .sframe to keep it on disk.",
              n, new$meta$version %||% "")
    } else {
      sprintf("Saved as a new instrument, version %s, with no amendment log.",
              new$meta$version %||% "")
    }
    showNotification(msg, type = "message", duration = 8)
    msg
  }

  # Quality and Responses: a bot removal or a data correction changes the
  # responses, not the instrument, and is recorded as a pipeline amendment
  # through the same dialog, so the log says what was done to the data.
  studio_data_amend_card <- function(button, lead) {
    if (is.null(rv$instrument) || is.null(rv$responses)) return(NULL)
    tags$div(class = "card",
      tags$div(class = "card-title", "Record a change to the data"),
      tags$p(class = "hint", lead),
      actionButton(button, "Record as amendment", class = "btn-outline sf-secondary"))
  }
  output$quality_amend_card <- renderUI(studio_data_amend_card("quality_amend_btn",
    "Removed bot or fraudulent responses after this check? Record what was removed and why, so the report discloses it."))
  output$responses_amend_card <- renderUI(studio_data_amend_card("responses_amend_btn",
    "Corrected or removed responses before loading them? Record what changed and why, so the report discloses it."))
  studio_open_data_amend <- function(code, label) {
    req(rv$instrument)
    amend_dlg$open(rv$instrument, rv$instrument, start_label = label,
      defaults = list(reason_code = code),
      on_apply = function(new, how) studio_apply_amended(new, how))
  }
  observeEvent(input$quality_amend_btn, studio_open_data_amend("bot_removal",
    "The responses change and the instrument does not. Say which responses were removed and why."))
  observeEvent(input$responses_amend_btn, studio_open_data_amend("data_correction",
    "The responses change and the instrument does not. Say which responses were corrected or removed and why."))

  observeEvent(input$amend_edit_design, {
    session$sendCustomMessage("surveyframe-switch-tab", "design")
  })

  observeEvent(input$amend_revised_file, {
    req(input$amend_revised_file, rv$instrument)
    tryCatch({
      path <- sframe_validate_upload(input$amend_revised_file, "sframe")
      rev <- suppressWarnings(read_sframe(path), classes = "sframe_amendment_warning")
      amend_dlg$open(rv$instrument, rev,
        start_label = paste0("Imported from ", input$amend_revised_file$name,
                             ". The open instrument is the version before."),
        on_apply = function(new, how) studio_apply_amended(new, how))
    }, error = function(e) {
      showNotification(paste("Error:", conditionMessage(e)), type = "error")
    })
  })

  output$amendment_version_line <- renderUI({
    req(rv$instrument)
    tags$p(class = "amend-version", id = "amend_version_line",
           paste0("Version ", sframe_studio_version_label(rv$instrument), "."))
  })

  output$amendment_log_table <- shiny::renderTable({
    req(rv$instrument)
    sframe_studio_amendment_history(rv$instrument) %||%
      data.frame(Status = "No amendments disclosed yet.")
  })

  observeEvent(input$load_responses_btn, {
    req(input$resp_file, rv$instrument)
    id_col <- trim_or_null(input$resp_id_col)
    time_col <- trim_or_null(input$resp_time_col)
    tryCatch({
      path <- sframe_validate_upload(input$resp_file, "csv")
      rv$responses <- read_responses(
        x = path,
        instrument = rv$instrument,
        respondent_id = id_col,
        submitted_at = time_col,
        strict = isTRUE(input$resp_strict)
      )
      showNotification(paste(nrow(rv$responses), "responses loaded."), type = "message")
      switch_tab("quality")
    }, error = function(e) {
      showNotification(paste("Error:", conditionMessage(e)), type = "error")
    })
  })

  observeEvent(input$load_sheet_btn, {
    req(rv$instrument)
    sheet <- trim_or_null(input$sheet_url)
    if (is.null(sheet)) {
      showNotification("Enter the Google Sheet ID or URL first.", type = "warning")
      return(invisible(NULL))
    }
    if (!requireNamespace("googlesheets4", quietly = TRUE)) {
      showNotification(
        "Reading from Google Sheets needs the googlesheets4 package. Install it, then try again.",
        type = "error", duration = NULL)
      return(invisible(NULL))
    }
    tryCatch({
      rv$responses <- read_sheet_responses(
        sheet_id      = sheet,
        instrument    = rv$instrument,
        sheet_name    = trim_or_null(input$sheet_tab) %||% "Responses",
        respondent_id = trim_or_null(input$sheet_id_col),
        submitted_at  = trim_or_null(input$sheet_time_col)
      )
      showNotification(paste(nrow(rv$responses), "responses read from the Google Sheet."),
                       type = "message")
      switch_tab("quality")
    }, error = function(e) {
      showNotification(paste("Google Sheet error:", conditionMessage(e)), type = "error")
    })
  })

  observeEvent(input$load_sample_btn, {
    tryCatch({
      demo <- sframe_demo("input_types")
      rv$builder <- builder_state_from_instrument(demo$instrument)
      rv$instrument <- demo$instrument
      rv$responses <- demo$responses
      sync_builder_inputs(rv$builder)
      showNotification(
        paste0("Sample loaded: ", nrow(demo$responses),
               " responses. Open Quality, Explore, Reliability and Analyse."),
        type = "message"
      )
      switch_tab("dashboard")
    }, error = function(e) {
      showNotification(paste("Could not load sample:", conditionMessage(e)), type = "error")
    })
  })

  output$download_sample_csv <- downloadHandler(
    filename = function() "surveyframe_input_types_responses.csv",
    content = function(file) {
      src <- system.file("extdata", "surveyframe_input_types_responses.csv",
                         package = "surveyframe")
      file.copy(src, file, overwrite = TRUE)
    }
  )

  output$sidebar_status <- renderUI({
    draft <- draft_result()
    tagList(
      tags$div(if (draft$valid) "Draft ready" else "Draft needs fixes"),
      tags$div(id = "status_instrument", if (!is.null(rv$instrument))
        paste0("Instrument ", sframe_studio_version_label(rv$instrument))
        else "No valid instrument"),
      tags$div(if (!is.null(rv$responses)) "Responses loaded" else "No responses")
    )
  })

  output$builder_summary_card <- renderUI({
    draft <- draft_result()
    tags$div(class = "card",
      tags$div(class = "card-title", draft$instrument$meta$title %||% "Survey draft"),
      tags$div(class = "stat-row",
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", length(rv$builder$choices)),
          tags$div(class = "stat-lbl", "Choice sets")),
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", length(rv$builder$items)),
          tags$div(class = "stat-lbl", "Items")),
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", length(rv$builder$scales)),
          tags$div(class = "stat-lbl", "Scales")),
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", length(rv$builder$analysis_plan %||% list())),
          tags$div(class = "stat-lbl", "Research questions")),
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", length(rv$builder$models %||% list())),
          tags$div(class = "stat-lbl", "Models")),
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", if (draft$valid) "Ready" else "Fix"),
          tags$div(class = "stat-lbl", "Status"))
      )
    )
  })

  output$builder_validation_card <- renderUI({
    draft <- draft_result()
    tags$div(class = "card",
      tags$div(class = "card-title", "Draft validation"),
      if (draft$valid) {
        tagList(
          tags$p(status_badge(TRUE, "Validated", "Needs fixes")),
          tags$p(class = "hint",
            "This draft can be previewed, saved as a .sframe, and used for downstream analysis.")
        )
      } else {
        tagList(
          tags$p(status_badge(FALSE, "Validated", "Needs fixes")),
          tags$ul(class = "problem-list",
            do.call(tagList, lapply(draft$problems, tags$li))
          )
        )
      }
    )
  })

  output$choices_table <- renderUI({
    rows <- lapply(rv$builder$choices, function(choice) {
      tags$tr(
        tags$td(choice$id),
        tags$td(length(choice$values)),
        tags$td(format_value(choice$labels)),
        tags$td(if (isTRUE(choice$allow_other)) "Yes" else "No"),
        tags$td(if (isTRUE(choice$randomise)) "Yes" else "No")
      )
    })
    table_card("Current choice sets",
      headers = c("ID", "Options", "Labels", "Other", "Randomise"),
      rows = rows,
      empty_label = "No choice sets yet.")
  })

  output$items_table <- renderUI({
    rows <- lapply(rv$builder$items, function(item) {
      tags$tr(
        tags$td(item$id),
        tags$td(item$type),
        tags$td(item$choice_set %||% ""),
        tags$td(if (isTRUE(item$required)) "Yes" else "No"),
        tags$td(item$label)
      )
    })
    table_card("Current items",
      headers = c("ID", "Type", "Choice set", "Required", "Label"),
      rows = rows,
      empty_label = "No items yet.")
  })

  output$scales_table <- renderUI({
    rows <- lapply(rv$builder$scales, function(scale) {
      tags$tr(
        tags$td(scale$id),
        tags$td(scale$label),
        tags$td(format_value(scale$items)),
        tags$td(scale$method),
        tags$td(scale$min_valid %||% ""),
        tags$td(format_value(scale$reverse_items))
      )
    })
    table_card("Current scales",
      headers = c("ID", "Label", "Items", "Method", "Min valid", "Reverse"),
      rows = rows,
      empty_label = "No scales yet.")
  })

  output$branching_table <- renderUI({
    rows <- lapply(rv$builder$branching, function(rule) {
      tags$tr(
        tags$td(rule$item_id),
        tags$td(rule$depends_on),
        tags$td(rule$operator),
        tags$td(format_value(rule$value)),
        tags$td(rule$action)
      )
    })
    table_card("Current branching rules",
      headers = c("Target", "Depends on", "Operator", "Value", "Action"),
      rows = rows,
      empty_label = "No branching rules yet.")
  })

  output$checks_table <- renderUI({
    rows <- lapply(rv$builder$checks, function(check) {
      tags$tr(
        tags$td(check$id),
        tags$td(check$item_id),
        tags$td(check$type),
        tags$td(format_value(check$pass_values)),
        tags$td(check$fail_action)
      )
    })
    table_card("Current checks",
      headers = c("ID", "Item", "Type", "Pass values", "Fail action"),
      rows = rows,
      empty_label = "No checks yet.")
  })

  output$open_status <- renderUI({
    tagList(studio_open_badge(),
      if (!is.null(rv$instrument)) tags$a(class = "open-version", href = "#", `data-tab` = "amendments",
        id = "open_status_version", sframe_studio_version_label(rv$instrument)))
  })

  # The integrity badge (UX-12), with the version and count beside it.
  studio_open_badge <- function() {
    message <- rv$open_verification
    if (is.null(message)) {
      status_badge(FALSE, "Integrity verified", "No file checked")
    } else if (identical(message, "file")) {
      tags$span(class = "badge badge-ok", "File checked: hash verified")
    } else if (identical(message, "design")) {
      # A Design save is read and its hash checked as an opened file is.
      tags$span(class = "badge badge-ok", "Saved from Design: hash verified")
    } else if (identical(message, "r")) {
      tags$span(class = "badge badge-wait", "Loaded from R")
    } else {
      tags$div(
        tags$span(class = "badge badge-warn", "Not verified"),
        tags$p(class = "hint", message),
        tags$p(class = "hint", id = "open_verify_remedy",
               "Record the change on Amendments, or open the file again.")
      )
    }
  }

  output$instrument_summary_card <- renderUI({
    req(rv$instrument)
    instr <- rv$instrument
    tags$div(class = "card",
      tags$div(class = "card-title", instr$meta$title),
      tags$div(class = "stat-row",
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", length(instr$items)),
          tags$div(class = "stat-lbl", "Items")),
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", length(instr$scales)),
          tags$div(class = "stat-lbl", "Scales")),
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", length(instr$analysis_plan %||% list())),
          tags$div(class = "stat-lbl", "Research questions")),
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", length(instr$models %||% list())),
          tags$div(class = "stat-lbl", "Models")),
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", id = "open_version", sframe_studio_version_label(instr)),
          tags$div(class = "stat-lbl", "Version")),
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", id = "open_schema_status",
                   if (isTRUE(instr$meta$validated)) "Schema valid" else "Draft"),
          if (isTRUE(instr$meta$validated)) tags$div(class = "stat-lbl", "Status")
          else tags$a(class = "stat-lbl", href = "#", `data-tab` = "design", id = "open_status_link", "Status: fix in Design"))
      )
    )
  })

  output$preview_gate <- renderUI({
    draft <- draft_result()
    if (length(draft$instrument$items) == 0) {
      # Questions are written on the Design screen, or come in an opened file.
      return(studio_next_stage(paste(
        "There are no questions yet, so there is nothing to preview. Design",
        "them, or open a file that has them."), c("design", "open")))
    }
    if (!draft$valid) {
      return(tags$div(class = "card",
        tags$p("The current draft has validation issues. Preview is still shown so you can inspect the question flow."),
        tags$ul(class = "problem-list", do.call(tagList, lapply(draft$problems, tags$li)))
      ))
    }
    NULL
  })

  output$survey_preview_items <- renderUI({
    instr <- preview_instrument()
    req(instr)
    # Render the exact deployable survey so the preview is identical to what
    # respondents see. Reuses the single static-survey template through
    # export_survey() instead of re-creating the layout with widgets.
    tmp <- tempfile(fileext = ".html")
    ok <- tryCatch({
      # preview = TRUE strips the collector and the redirect, so the promise
      # below is enforced by the export instead of trusted.
      suppressMessages(export_survey(
        instr, output_path = tmp, open = FALSE, overwrite = TRUE,
        preview = TRUE
      ))
      TRUE
    }, error = function(e) FALSE)
    if (!isTRUE(ok)) {
      return(tags$p(class = "hint",
        "Add at least one question and pass validation to preview the survey."))
    }
    html <- paste(readLines(tmp, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
    tagList(
      tags$p(class = "hint", style = "margin-bottom: 12px;",
        paste0("This is the deployable survey, exported with collection ",
               "switched off. Anything entered here goes nowhere: the ",
               "address that receives responses (the collector endpoint) and the completion redirect are both ",
               "removed from the preview.")),
      tags$iframe(
        srcdoc = html,
        style = "width:100%;height:78vh;border:1px solid var(--sf-border);border-radius:10px;background:var(--sf-surface);",
        title = "Survey preview"
      )
    )
  })

  # Reading a sheet needs googlesheets4, so without it the card says so.
  output$sheet_pkg_note <- renderUI({
    if (requireNamespace("googlesheets4", quietly = TRUE)) return(NULL)
    tags$p(class = "plan-msg", id = "sheet_pkg_missing",
      "The googlesheets4 package is not installed, so Studio cannot read a sheet yet. Install it with install.packages(\"googlesheets4\"), or download the sheet as a CSV file and load it below.")
  })

  output$responses_gate <- renderUI({
    if (is.null(rv$instrument)) {
      no_instrument_next("upload responses for it")
    }
  })

  output$responses_summary_card <- renderUI({
    req(rv$responses)
    tags$div(class = "card",
      tags$div(class = "card-title", "Loaded response data"),
      tags$div(class = "stat-row",
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", nrow(rv$responses)),
          tags$div(class = "stat-lbl", "Respondents")),
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", ncol(rv$responses)),
          tags$div(class = "stat-lbl", "Columns"))
      )
    )
  })

  output$quality_gate <- renderUI({
    if (is.null(rv$instrument)) {
      no_instrument_next("run quality checks")
    } else if (is.null(rv$responses)) {
      no_responses_next("run quality checks")
    }
  })

  quality_result <- reactive({
    req(rv$instrument, rv$responses)
    id_col <- trim_or_null(input$resp_id_col)
    # The collectors write respondent_id, so use it when no column was named.
    # Without an id the duplicate check cannot run.
    if (is.null(id_col) && "respondent_id" %in% names(rv$responses)) {
      id_col <- "respondent_id"
    }
    # Timing analysis needs the timestamp columns passed explicitly; detect
    # the standard collector columns so sheet imports get completion times.
    sub_col <- if ("submitted_at" %in% names(rv$responses)) "submitted_at"
    st_col  <- if ("started_at" %in% names(rv$responses)) "started_at"
    sframe_quality_results(rv$responses, rv$instrument,
                                respondent_id = id_col,
                                submitted_at = sub_col,
                                started_at = st_col)
  })

  output$quality_output <- renderUI({
    req(rv$instrument, rv$responses)
    qr <- quality_result()
    n <- qr$summary$n_respondents
    n_flag <- qr$summary$n_flagged %||% 0L
    stat_box <- function(v, l) tags$div(class = "stat-box",
      tags$div(class = "stat-val", v), tags$div(class = "stat-lbl", l))

    tagList(
      tags$div(class = "card",
        tags$div(class = "card-title", "Summary"),
        tags$div(class = "stat-row",
          stat_box(n, "Respondents"),
          stat_box(qr$summary$n_items, "Items"),
          stat_box(n - n_flag, "Clean"),
          stat_box(sprintf("%d (%.1f%%)", n_flag, qr$summary$flag_rate * 100), "Flagged")
        ),
        tags$p(class = "hint",
          "A respondent is flagged if caught by any check below: a failed attention check, straight-lining a scale, completing too fast, missing more than the threshold, or being a duplicate row.")
      ),

      if (length(qr$attention) > 0) {
        rows <- lapply(qr$attention, function(chk) {
          tags$tr(
            tags$td(chk$check_id),
            tags$td(chk$type),
            tags$td(chk$n_pass %||% NA),
            tags$td(chk$n_fail),
            tags$td(sprintf("%.1f%%", chk$pass_rate * 100))
          )
        })
        table_card("Attention checks",
          headers = c("Check ID", "Type", "n pass", "n fail", "Pass rate"),
          rows = rows,
          empty_label = "No checks.")
      },

      if (length(qr$straightline %||% list()) > 0) {
        rows <- lapply(qr$straightline, function(s) {
          tags$tr(
            tags$td(s$scale_id),
            tags$td(s$n_items),
            tags$td(length(s$flagged_rows %||% integer(0))),
            tags$td(sprintf("%.1f%%", (s$flag_rate %||% 0) * 100))
          )
        })
        table_card("Straight-lining by scale",
          headers = c("Scale", "Items", "Flagged", "Rate"),
          rows = rows,
          empty_label = "No multi-item scales.")
      },

      tags$div(class = "card",
        tags$div(class = "card-title", "Completion time"),
        if (isTRUE(qr$timing$available)) {
          tags$p(sprintf(
            "Median completion %.0f seconds. %d respondent(s) (%.1f%%) flagged as too fast.",
            qr$timing$median_sec %||% NA_real_,
            qr$timing$n_flagged %||% 0L,
            (qr$timing$flag_rate %||% 0) * 100))
        } else {
          tags$p(class = "hint",
            qr$timing$reason %||% "Timing analysis needs started_at and submitted_at columns.")
        }
      ),

      tags$div(class = "card",
        tags$div(class = "card-title", "Duplicates and missingness"),
        if (isTRUE(qr$duplicates$checked)) {
          tags$p(sprintf("%d duplicate response row(s) detected.",
                         qr$duplicates$n_duplicates %||% 0L))
        } else {
          tags$p(class = "hint",
            "Duplicates were not checked. Name the respondent ID column to check them.")
        },
        tags$p(sprintf(
          "%.1f%% of respondents exceed the %.0f%% missing threshold.",
          mean(qr$missing$respondent_miss > qr$missing$flagged_threshold, na.rm = TRUE) * 100,
          qr$missing$flagged_threshold * 100
        ))
      )
    )
  })

  output$reliability_gate <- renderUI({
    if (is.null(rv$instrument)) {
      no_instrument_next("compute reliability")
    } else if (is.null(rv$responses)) {
      no_responses_next("compute reliability")
    }
  })

  reliability_result <- reactive({
    req(rv$instrument, rv$responses)
    tryCatch(
      sframe_reliability_results(rv$responses, rv$instrument),
      error = function(e) NULL
    )
  })

  # plot() dispatches to plot.sframe_quality_report()/plot.sframe_reliability_report()
  # (ggplot2, guarded); returns NULL and draws nothing when ggplot2 is absent
  # or the report has no plottable rows, so these panels degrade quietly
  # rather than erroring.
  output$studio_quality_chart <- shiny::renderPlot({
    req(rv$instrument, rv$responses)
    gg <- tryCatch(graphics::plot(quality_result()), error = function(e) NULL)
    if (!is.null(gg)) print(gg)
  }, bg = dash_surface)

  output$studio_missing_chart <- shiny::renderPlot({
    req(rv$instrument, rv$responses)
    mr <- tryCatch(
      sframe_missing_data_results(rv$responses, rv$instrument),
      error = function(e) NULL
    )
    if (is.null(mr)) return()
    gg <- tryCatch(graphics::plot(mr), error = function(e) NULL)
    if (!is.null(gg)) print(gg)
  }, bg = dash_surface)

  # Scale-score correlation heatmap for the Dashboard tab's Scales view.
  # Scores are local row means per scale, on the filtered rows.
  output$studio_scale_cor_chart <- shiny::renderPlot({
    req(rv$instrument, rv$responses)
    resp <- dash_filtered_responses()
    if (!nrow(resp)) { plot.new(); text(.5, .5, "No responses match the filters.", col = dash_muted); return() }
    scs <- Filter(function(s) length(intersect(s$items, names(resp))) > 0,
                  rv$instrument$scales %||% list())
    if (length(scs) < 2) {
      plot.new(); text(.5, .5, "Define at least two scales to see correlations.", col = dash_muted)
      return()
    }
    scored <- as.data.frame(lapply(scs, function(sc) {
      nums <- lapply(resp[intersect(sc$items, names(resp))],
                     function(x) suppressWarnings(as.numeric(x)))
      rowMeans(do.call(cbind, nums), na.rm = TRUE)
    }))
    names(scored) <- vapply(scs, `[[`, character(1), "id")
    gg <- tryCatch(
      sframe_plot_correlation_matrix(scored, names(scored)),
      error = function(e) NULL
    )
    if (!is.null(gg)) { print(gg); return() }
    plot.new(); text(.5, .5, "Install ggplot2 to see the correlation heatmap.", col = dash_muted)
  }, bg = dash_surface)

  output$studio_reliability_chart <- shiny::renderPlot({
    req(rv$instrument, rv$responses)
    rr <- reliability_result()
    if (is.null(rr) || length(rr) == 0) return()
    gg <- tryCatch(graphics::plot(rr), error = function(e) NULL)
    if (!is.null(gg)) print(gg)
  }, bg = dash_surface)

  output$reliability_output <- renderUI({
    req(rv$instrument, rv$responses)
    rr <- reliability_result()
    if (is.null(rr) || length(rr) == 0) {
      return(tags$div(class = "card",
        "No scales with two or more items found in response data."))
    }

    cards <- lapply(rr, function(scale) {
      rows <- list(
        tags$tr(tags$td("Items"), tags$td(scale$n_items)),
        tags$tr(tags$td("N"), tags$td(scale$n))
      )
      if (!is.null(scale$alpha)) {
        rows <- c(rows, list(tags$tr(tags$td("Cronbach alpha"),
                                     tags$td(sprintf("%.3f", scale$alpha)))))
      }
      if (!is.null(scale$omega_h)) {
        rows <- c(rows, list(tags$tr(tags$td("Omega h"),
                                     tags$td(sprintf("%.3f", scale$omega_h)))))
      }
      if (!is.null(scale$omega_t)) {
        rows <- c(rows, list(tags$tr(tags$td("Omega total"),
                                     tags$td(sprintf("%.3f", scale$omega_t)))))
      }

      tags$div(class = "card",
        tags$div(class = "card-title", paste0(scale$label, " (", scale$scale_id, ")")),
        tags$table(class = "sf-table", tags$tbody(rows))
      )
    })

    do.call(tagList, cards)
  })

  output$analysis_gate <- renderUI({
    if (is.null(rv$instrument)) {
      return(no_instrument_next("plan analyses"))
    }
    NULL
  })

  # Analyse shows the declared plan read-only and runs it (UX-02). The
  # builder's Plan is the only plan editor, and "Change plan" opens it.
  output$analysis_declared_plan <- renderUI({
    req(rv$instrument)
    labels <- vapply(analysis_registry, function(r) as.character(r$label %||% "")[1], character(1))
    tbl <- sframe_studio_declared_plan(rv$instrument, labels)
    tags$div(class = "card", id = "declared_plan_card",
      tags$div(class = "card-title", "Declared plan"),
      tags$p(class = "hint", if (is.null(rv$responses))
        "The analyses declared in Plan. Load responses and Analyse runs them as declared."
        else "The analyses declared in Plan, run as declared against the loaded responses. A change to the plan now is recorded as a design amendment."),
      if (is.null(tbl)) tags$p(class = "hint", "No analyses are declared yet.")
      else tags$div(style = "overflow-x:auto",
        shiny::HTML(shiny::renderTable(tbl, rownames = FALSE)())),
      tags$a(href = "#", id = "analysis_change_plan", `data-nav` = "plan", class = "btn btn-outline sf-secondary", "Change plan"))
  })

  # One shared execution of the analysis plan (with charts when ggplot2 is
  # installed), reused by the Run result cards and the Report screen's
  # Interpretations card, so the plan does not run once per consumer.
  # Depends on input$rpt_palette so switching the Report screen's Chart
  # theme radio re-renders the preview charts in the chosen palette instead
  # of leaving them fixed at whatever palette was active on first run.
  analysis_results_r <- reactive({
    req(rv$instrument)
    if (is.null(rv$responses)) {
      return(NULL)
    }
    tryCatch(
      run_analysis_plan(
        rv$responses, rv$instrument,
        plots = requireNamespace("ggplot2", quietly = TRUE),
        plot_palette = input$rpt_palette %||% "web"
      ),
      error = function(e) e
    )
  })

  # Rendering a chart to an embeddable base64 PNG (studio_ggplot_img()) is
  # the expensive part of a results canvas with 30+ blocks, so it happens
  # once per result here and both the Run stage cards and the Export
  # screen's Interpretations canvas reuse the same tags instead of each
  # re-encoding every chart.
  analysis_result_plot_tags_r <- reactive({
    results <- analysis_results_r()
    if (is.null(results) || inherits(results, "error")) {
      return(list())
    }
    lapply(results, studio_result_plot_tags)
  })

  output$analysis_results_row <- renderUI({
    fluidRow(column(12, uiOutput("analysis_results_output")))
  })

  # Drop from scale and Put back under a result (UI-1). Each button sends 1
  # event input, as the amendment dialog's buttons do.
  studio_event_button <- function(input_id, label, value, cls = "btn-default sf-secondary") {
    tags$button(type = "button", class = paste("btn", cls),
      onclick = sprintf("Shiny.setInputValue('%s', %s, {priority: 'event'})",
        input_id, jsonlite::toJSON(c(value, at = "now"), auto_unbox = TRUE)),
      label)
  }
  studio_flag_section <- function(result) {
    flags <- sframe_studio_result_flags(result)
    block <- as.character(result$block_id %||% "")[1]
    hashes <- vapply(rv$instrument$amendments %||% list(),
                     function(a) as.character(a$new_hash %||% "")[1], character(1))
    dropped <- Filter(function(d) identical(d$block, block) && d$hash %in% hashes, rv$drops)
    if (!nrow(flags) && !length(dropped)) return(NULL)
    tags$div(class = "flag-list", `data-block` = block,
      if (nrow(flags)) tagList(
        tags$div(class = "flag-head", "Items past the usual cut-offs"),
        lapply(seq_len(nrow(flags)), function(k) tags$div(class = "flag-row",
          tags$span(flags$reason[k]),
          if (length(sframe_studio_drop_targets(rv$instrument, flags[k, ])))
            studio_event_button("flag_drop", "Drop from scale",
              list(block = block, item = flags$item[k]))))),
      lapply(dropped, function(d) tags$div(class = "flag-row",
        tags$span(sprintf("%s was dropped from %s in this session.", d$item,
                          paste(d$from, collapse = ", "))),
        studio_event_button("flag_put_back", "Put back", list(hash = d$hash)))))
  }

  observeEvent(input$flag_drop, {
    req(rv$instrument)
    results <- analysis_results_r()
    req(!is.null(results), !inherits(results, "error"))
    hit <- Filter(function(r) identical(as.character(r$block_id %||% "")[1],
                                        input$flag_drop$block), results)
    req(length(hit) > 0)
    flags <- sframe_studio_result_flags(hit[[1]])
    flag <- flags[flags$item == input$flag_drop$item, , drop = FALSE]
    req(nrow(flag) == 1)
    p <- tryCatch(sframe_studio_drop_proposal(rv$instrument, flag),
                  error = function(e) e)
    if (inherits(p, "error") || is.null(p)) {
      showNotification(if (inherits(p, "error")) conditionMessage(p) else
        paste(flag$item, "is in no scale or model, so there is nothing to drop."),
        type = "error", duration = 10)
      return()
    }
    before <- rv$instrument
    amend_dlg$open(before, p$after, start_label = p$start_label,
      defaults = p$defaults,
      on_apply = function(new, how) {
        h <- new$amendments[[length(new$amendments)]]$new_hash
        rv$drops[[h]] <- list(hash = h, item = p$item, from = p$from,
                              block = p$block, before = before, after = new)
        studio_apply_amended(new, how)
      })
  })

  observeEvent(input$flag_put_back, {
    req(rv$instrument)
    d <- rv$drops[[input$flag_put_back$hash]]
    req(!is.null(d))
    restored <- tryCatch(sframe_studio_put_back(rv$instrument, d),
                         error = function(e) e)
    if (inherits(restored, "error")) {
      showNotification(conditionMessage(restored), type = "error", duration = 10)
      return()
    }
    amend_dlg$open(rv$instrument, restored,
      start_label = sprintf("Put %s back in %s, as it was before the drop.",
                            d$item, paste(d$from, collapse = ", ")),
      defaults = list(reason_code = "model_respecification",
        reason_text = sprintf("Put %s back in %s.", d$item, paste(d$from, collapse = ", ")),
        deviation_report = sprintf("%s returned to %s, undoing the drop recorded earlier.",
                                   d$item, paste(d$from, collapse = ", "))),
      on_apply = function(new, how) {
        rv$drops[[d$hash]] <- NULL
        studio_apply_amended(new, how)
      })
  })

  output$analysis_results_output <- renderUI({
    req(rv$instrument)
    if (length(rv$instrument$analysis_plan %||% list()) == 0) {
      return(NULL)
    }
    if (is.null(rv$responses)) {
      return(tags$div(class = "card",
        tags$div(class = "card-title", "Run results"),
        tags$p(class = "hint", "Upload response data to run saved analysis plans.")))
    }

    results <- analysis_results_r()
    if (inherits(results, "error")) {
      return(tags$div(class = "card",
        tags$div(class = "card-title", "Run results"),
        tags$p(conditionMessage(results))))
    }

    all_plot_tags <- analysis_result_plot_tags_r()
    cards <- lapply(seq_along(results), function(i) {
      result <- results[[i]]
      # The chart sits inside its result card, directly under the APA
      # string, matching the report's table-plus-plot pairing. Regression
      # adds its four diagnostic panels beneath the main chart.
      plot_tags <- all_plot_tags[[i]] %||% list()
      tags$div(class = "card",
        tags$div(class = "card-title",
          studio_rq_heading(i, result$block_id)),
        tags$p(result$research_question %||% ""),
        tags$div(
          tags$span(class = "vbadge", result$test %||% result$method %||% ""),
          if (!is.null(result$effect_label)) {
            tags$span(class = "vbadge", paste(result$effect_label, "effect"))
          }
        ),
        if (!is.null(result$error)) {
          tags$p(class = "hint", paste("Error:", result$error))
        } else {
          tagList(
            tags$p(tags$strong("Result: "),
                   result$apa %||% "See the matching section of the report."),
            studio_result_table_tag(result$table),
            # A CFA/SEM/PLS-SEM syntax block has no table or chart: its
            # whole output is the generated syntax text.
            if (!is.null(result$syntax)) tags$pre(class = "sf-code", result$syntax),
            studio_flag_section(result)
          )
        },
        if (length(plot_tags) > 0) do.call(tagList, plot_tags)
      )
    })
    do.call(tagList, cards)
  })

  output$dashboard_gate <- renderUI({
    if (is.null(rv$instrument)) {
      return(no_instrument_next("open the dashboard"))
    }
    if (is.null(rv$responses)) {
      return(no_responses_next("open the dashboard"))
    }
    NULL
  })

  # Inline response dashboard, ported from launch_dashboard() and wired to the
  # studio's reactive instrument and responses (base-R charts, no new imports).
  dash_q_items <- reactive({
    Filter(function(i) !(i$type %in% c("section_break", "text_block")),
           rv$instrument$items %||% list())
  })
  dash_find <- function(components, id) {
    for (cp in components %||% list()) if (identical(cp$id, id)) return(cp)
    NULL
  }

  # The filter bar names each filter by its question and offers the choice
  # labels. Filters apply to the 4 dashboard views and the CSV download. The
  # Quality screen stays on every response.
  dash_date_col <- reactive(dashboard_date_column(rv$responses))
  dash_filter_cols <- reactive(dashboard_categorical_columns(rv$responses, rv$instrument))

  output$dash_filter_bar <- renderUI({
    req(rv$instrument)
    responses <- rv$responses
    instr <- rv$instrument
    date_col <- dash_date_col()
    cat_cols <- dash_filter_cols()
    if (is.null(responses) || nrow(responses) == 0) return(NULL)
    # Explore's 1 primary action (item 12e), on all 4 views. The CSV holds
    # the responses the filters keep.
    csv_btn <- tags$div(class = "dash-actions",
      downloadButton("dash_dl_csv", "Download CSV", class = "btn-primary sf-primary"),
      tags$span(class = "hint", "The CSV holds the responses the filters keep."))
    if (!length(cat_cols) && is.null(date_col)) return(csv_btn)
    labels <- sframe_label_lookup(instr)
    cats <- lapply(cat_cols, function(nm) {
      vals <- sort(unique(as.character(responses[[nm]][!is.na(responses[[nm]])])))
      if (!length(vals)) return(NULL)
      value_labels <- sframe_item_value_labels(instr, nm)
      shown <- ifelse(vals %in% names(value_labels), unname(value_labels[vals]), vals)
      tags$div(
        selectInput(
          paste0("dash_filter_", nm),
          if (nm %in% names(labels)) unname(labels[[nm]]) else nm,
          choices = stats::setNames(vals, shown),
          selected = character(0),
          multiple = TRUE,
          width = "100%"
        )
      )
    })
    cats <- Filter(Negate(is.null), cats)

    date_ui <- NULL
    if (!is.null(date_col)) {
      d <- dashboard_parse_date(responses[[date_col]])
      d <- d[!is.na(d)]
      if (length(d)) {
        date_ui <- tags$div(
          tags$label(date_col),
          shiny::dateRangeInput("dash_filter_date_range", NULL, start = min(d),
                                end = max(d), min = min(d), max = max(d),
                                width = "100%")
        )
      }
    }

    tags$div(
      class = "filter-bar",
      tags$div(class = "filter-head", tags$div(class = "card-title", "Filters"), csv_btn),
      tags$div(class = "filter-grid", c(cats, list(date_ui))),
      tags$div(class = "filter-note", "Leave a filter blank to include all responses.")
    )
  })

  # Drawn while Explore is hidden, so its 1 primary action is there the
  # moment the screen opens.
  shiny::outputOptions(output, "dash_filter_bar", suspendWhenHidden = FALSE)

  dash_filtered_responses <- reactive({
    out <- rv$responses
    if (is.null(out)) return(NULL)
    for (nm in dash_filter_cols()) {
      selected <- input[[paste0("dash_filter_", nm)]]
      if (length(selected)) {
        out <- out[as.character(out[[nm]]) %in% selected, , drop = FALSE]
      }
    }
    date_col <- dash_date_col()
    if (!is.null(date_col) && !is.null(input$dash_filter_date_range)) {
      d <- dashboard_parse_date(out[[date_col]])
      rng <- dashboard_parse_date(input$dash_filter_date_range)
      keep <- is.na(d) | (d >= rng[1] & d <= rng[2])
      out <- out[keep, , drop = FALSE]
    }
    out
  })

  output$studio_dashboard_content <- renderUI({
    req(rv$instrument)
    if (is.null(rv$responses)) return(NULL)
    view <- input$dashboard_view %||% "Overview"
    resp <- dash_filtered_responses()
    instr <- rv$instrument

    if (identical(view, "Overview")) {
      date_range <- "Not available"
      if ("submitted_at" %in% names(resp)) {
        dts <- suppressWarnings(as.Date(substr(as.character(resp$submitted_at), 1, 10)))
        dts <- dts[!is.na(dts)]
        if (length(dts) > 1) {
          date_range <- paste0(format(min(dts), "%d %b"), " to ",
                               format(max(dts), "%d %b %Y"))
        }
      }
      kpi <- function(v, l) tags$div(class = "stat-box",
        tags$div(class = "stat-val", v), tags$div(class = "stat-lbl", l))
      return(tagList(
        tags$div(class = "stat-row",
          kpi(nrow(rv$responses), "Responses"),
          tags$div(class = "stat-box", id = "dash_filtered_tile",
            tags$div(class = "stat-val", nrow(resp)),
            tags$div(class = "stat-lbl", "Filtered responses")),
          kpi(length(dash_q_items()), "Items"),
          kpi(length(instr$scales %||% list()), "Scales"),
          kpi(length(instr$checks %||% list()), "Checks"),
          kpi(date_range, "Date range")
        ),
        tags$div(class = "card",
          tags$div(class = "card-title", "Instrument summary"),
          tags$p(class = "hint", paste0(
            "Title: ", instr$meta$title %||% "Untitled",
            "  |  Version: ", instr$meta$version %||% "Not available",
            "  |  Mode: ", instr$render$mode %||% "standard"))
        )
      ))
    }

    if (identical(view, "Items")) {
      qi <- dash_q_items()
      if (!length(qi)) return(tags$div(class = "card", "No question items."))
      ch <- stats::setNames(
        vapply(qi, `[[`, character(1), "id"),
        vapply(qi, function(i) paste0(i$id, ": ", substr(i$label %||% "", 1, 40)),
               character(1)))
      return(tagList(
        selectInput("dash_item_sel", "Select item", choices = ch, width = "420px"),
        tags$div(class = "card",
          tags$div(class = "card-title", "Response distribution"),
          shiny::plotOutput("studio_item_chart", height = "300px")),
        uiOutput("studio_item_table")
      ))
    }

    if (identical(view, "Scales")) {
      scs <- instr$scales %||% list()
      if (!length(scs)) return(tags$div(class = "card", "No scales defined."))
      ch <- stats::setNames(
        vapply(scs, `[[`, character(1), "id"),
        vapply(scs, function(s) paste0(s$id, ": ", s$label), character(1)))
      def_rows <- lapply(scs, function(s) {
        tags$tr(
          tags$td(s$id),
          tags$td(s$label %||% ""),
          tags$td(s$method %||% s$scoring %||% "mean"),
          tags$td(paste(s$items, collapse = ", ")),
          tags$td(paste(s$reverse %||% character(0), collapse = ", "))
        )
      })
      return(tagList(
        selectInput("dash_scale_sel", "Select scale", choices = ch, width = "380px"),
        tags$div(class = "card",
          tags$div(class = "card-title", "Scale score distribution"),
          shiny::plotOutput("studio_scale_chart", height = "280px")),
        if (length(scs) >= 2) {
          tags$div(class = "card",
            tags$div(class = "card-title", "Scale score correlations"),
            shiny::plotOutput("studio_scale_cor_chart", height = "320px"))
        },
        table_card("Scale definitions",
          headers = c("ID", "Label", "Method", "Items", "Reverse items"),
          rows = def_rows, empty_label = "No scales defined.")
      ))
    }

    tags$div(class = "card",
      tags$div(class = "card-title", "Raw responses"),
      tags$p(class = "hint", paste0("Showing the first 200 of ", nrow(resp), " rows.")),
      tags$div(style = "overflow-x:auto", shiny::tableOutput("studio_raw_table"))
    )
  })

  output$studio_item_chart <- shiny::renderPlot({
    req(rv$instrument, rv$responses, input$dash_item_sel)
    resp <- dash_filtered_responses()
    if (!nrow(resp)) { plot.new(); text(.5, .5, "No responses match the filters.", col = dash_muted); return() }
    item <- dash_find(rv$instrument$items, input$dash_item_sel)
    if (is.null(item) || !input$dash_item_sel %in% names(resp)) {
      plot.new(); text(.5, .5, "No data for this item.", col = dash_muted); return()
    }
    col_data <- resp[[input$dash_item_sel]]
    t <- item$type
    cs <- dash_find(rv$instrument$choices, item$choice_set %||% "")
    gg <- tryCatch(sframe_plot_item_chart(item, col_data, cs), error = function(e) NULL)
    if (!is.null(gg)) { print(gg); return() }
    op <- par(mar = c(4, 9, 2, 1), bg = dash_surface); on.exit(par(op))
    if (t %in% c("likert", "single_choice", "multiple_choice")) {
      if (!is.null(cs)) {
        freq <- table(factor(col_data, levels = as.character(cs$values)))
        names(freq) <- cs$labels
      } else {
        freq <- table(col_data)
      }
      barplot(freq, horiz = TRUE, las = 1, col = dash_theme, border = NA,
              xlab = "Frequency", cex.names = .8, cex.axis = .8)
    } else if (t %in% c("numeric", "slider", "rating")) {
      num <- suppressWarnings(as.numeric(col_data)); num <- num[!is.na(num)]
      if (!length(num)) { plot.new(); text(.5, .5, "No numeric data."); return() }
      hist(num, col = dash_theme, border = dash_surface, main = NULL,
           xlab = item$label, ylab = "Count", las = 1, cex.axis = .8)
    } else {
      plot.new()
      text(.5, .5, paste0("Chart unavailable for type '", t, "'."), col = dash_muted)
    }
  }, bg = dash_surface)
  shiny::outputOptions(output, "studio_item_chart", suspendWhenHidden = FALSE)

  output$studio_item_table <- renderUI({
    req(rv$instrument, rv$responses, input$dash_item_sel)
    resp <- dash_filtered_responses()
    if (!nrow(resp)) return(tags$p(class = "hint", "No responses match the filters."))
    item <- dash_find(rv$instrument$items, input$dash_item_sel)
    if (is.null(item) || !input$dash_item_sel %in% names(resp)) return(NULL)
    col_data <- resp[[input$dash_item_sel]]
    if (item$type %in% c("likert", "single_choice", "multiple_choice")) {
      cs <- dash_find(rv$instrument$choices, item$choice_set %||% "")
      if (!is.null(cs)) {
        freq <- table(factor(col_data, levels = as.character(cs$values)))
        labs <- cs$labels
        vals <- as.character(cs$values)
      } else {
        freq <- table(col_data); labs <- names(freq); vals <- names(freq)
      }
      tot <- sum(freq)
      rows <- lapply(seq_along(freq), function(i) tags$tr(
        tags$td(vals[i]), tags$td(labs[i]), tags$td(as.integer(freq[i])),
        tags$td(if (tot > 0) sprintf("%.1f%%", 100 * freq[i] / tot) else "0%")
      ))
      table_card("Frequency counts",
        headers = c("Value", "Label", "Count", "Percent"),
        rows = rows, empty_label = "No responses.")
    } else if (item$type %in% c("numeric", "slider", "rating")) {
      num <- suppressWarnings(as.numeric(col_data)); num <- num[!is.na(num)]
      if (!length(num)) return(NULL)
      rows <- list(tags$tr(
        tags$td(length(num)), tags$td(round(mean(num), 2)), tags$td(round(stats::sd(num), 2)),
        tags$td(round(min(num), 2)), tags$td(round(stats::median(num), 2)), tags$td(round(max(num), 2))
      ))
      table_card("Summary statistics",
        headers = c("N", "Mean", "SD", "Min", "Median", "Max"),
        rows = rows, empty_label = "No numeric data.")
    } else {
      NULL
    }
  })
  shiny::outputOptions(output, "studio_item_table", suspendWhenHidden = FALSE)

  output$studio_scale_chart <- shiny::renderPlot({
    req(rv$instrument, rv$responses, input$dash_scale_sel)
    resp <- dash_filtered_responses()
    if (!nrow(resp)) { plot.new(); text(.5, .5, "No responses match the filters.", col = dash_muted); return() }
    sc <- dash_find(rv$instrument$scales, input$dash_scale_sel)
    if (is.null(sc)) return()
    cols <- intersect(sc$items, names(resp))
    if (!length(cols)) {
      plot.new(); text(.5, .5, "Scale items not in responses.", col = dash_muted); return()
    }
    nums <- lapply(resp[cols], function(x) suppressWarnings(as.numeric(x)))
    scores <- rowMeans(do.call(cbind, nums), na.rm = TRUE); scores <- scores[!is.na(scores)]
    if (!length(scores)) {
      plot.new(); text(.5, .5, "No valid scale scores.", col = dash_muted); return()
    }
    gg <- tryCatch(sframe_plot_scale_chart(scores, sc$label), error = function(e) NULL)
    if (!is.null(gg)) { print(gg); return() }
    op <- par(mar = c(4, 4, 2, 1), bg = dash_surface); on.exit(par(op))
    hist(scores, col = dash_theme, border = dash_surface, main = NULL,
         xlab = paste0(sc$label, " score"), ylab = "Count", las = 1, cex.axis = .8)
    abline(v = mean(scores), col = dash_danger, lwd = 2, lty = 2)
  }, bg = dash_surface)
  shiny::outputOptions(output, "studio_scale_chart", suspendWhenHidden = FALSE)

  output$studio_raw_table <- shiny::renderTable({
    req(rv$responses)
    head(dash_filtered_responses(), 200)
  }, striped = TRUE, hover = TRUE, bordered = FALSE, width = "100%", na = "")

  output$dash_dl_csv <- downloadHandler(
    filename = function() {
      paste0(gsub("[^a-zA-Z0-9]", "_", rv$instrument$meta$title %||% "survey"),
             "_responses.csv")
    },
    content = function(file) {
      utils::write.csv(dash_filtered_responses(), file, row.names = FALSE, na = "")
    }
  )

  output$export_gate <- renderUI({
    if (is.null(rv$instrument)) {
      no_instrument_next("export files")
    }
  })

  # A non-clickable placeholder shown when an export is not yet possible, so the
  # user cannot trigger a download that would error.
  export_disabled_btn <- function(label, hint, primary = FALSE) {
    tagList(
      tags$button(type = "button", class = if (primary) "btn btn-primary sf-primary" else "btn btn-outline", disabled = NA,
        style = "opacity: .5; cursor: not-allowed;",
        shiny::icon("download"), " ", label),
      tags$p(class = "hint", hint)
    )
  }

  output$export_sframe_ui <- renderUI({
    if (isTRUE(draft_result()$valid) && !is.null(draft_result()$revision_problem)) {
      # An edited file needs its change disclosed on the Amendments screen, or
      # an explicit decision to save it as a new instrument.
      tagList(
        tags$p(class = "hint", draft_result()$revision_problem),
        checkboxInput("export_as_new",
          "Save as a new instrument, without the previous amendment log", value = FALSE),
        downloadButton("download_sframe_btn", "Download copy", class = "btn-outline sf-secondary")
      )
    } else if (isTRUE(draft_result()$valid)) {
      downloadButton("download_sframe_btn", "Download copy", class = "btn-outline sf-secondary")
    } else {
      export_disabled_btn(
        "Download copy",
        "Open or build a valid instrument before downloading the .sframe file.")
    }
  })

  output$export_report_ui <- renderUI({
    if (!is.null(rv$instrument)) {
      downloadButton("download_report_btn", "Export report", class = "btn-primary sf-primary")
    } else {
      export_disabled_btn(
        "Export report",
        "Open or build a valid instrument before generating the report.", primary = TRUE)
    }
  })

  output$download_sframe_btn <- downloadHandler(
    filename = function() {
      title <- draft_result()$instrument$meta$title %||% "survey"
      paste0(gsub("[^a-zA-Z0-9]", "_", title), ".sframe")
    },
    content = function(file) {
      draft <- draft_result()
      if (!draft$valid) {
        stop("Draft validation must pass before exporting a .sframe file.")
      }
      tmp <- tempfile(fileext = ".sframe")
      instrument <- draft$instrument
      as_new <- !is.null(draft$revision_problem) && isTRUE(input$export_as_new)
      if (!is.null(draft$revision_problem) && !as_new) {
        stop(draft$revision_problem)
      }
      if (as_new) {
        instrument$amendments <- list()
        attr(instrument, "sframe_origin") <- NULL
      }
      write_sframe(instrument, tmp, overwrite = TRUE, new_instrument = as_new)
      file.copy(tmp, file, overwrite = TRUE)
    }
  )

  output$export_source_ui <- renderUI({
    if (!is.null(rv$instrument)) {
      downloadButton("download_source_btn", "Download source (.zip)", class = "btn-outline sf-secondary")
    } else {
      export_disabled_btn("Download source (.zip)",
        "Open or build a valid instrument before writing the source.")
    }
  })

  # The .qmd folder from render_report(format = "qmd"), zipped with the
  # folder at its root, so it unpacks as 1 folder for RStudio or Positron.
  output$download_source_btn <- downloadHandler(
    filename = function() paste0(
      gsub("[^a-zA-Z0-9]", "_", (rv$instrument$meta$title %||% "survey")), "_report_source.zip"),
    content = function(file) {
      tryCatch({
        dir <- file.path(tempfile("src-"), "report_source")
        dir.create(dirname(dir))
        do.call(render_report, c(studio_report_args(), list(format = "qmd", output_file = dir)))
        old <- setwd(dirname(dir))
        on.exit(setwd(old), add = TRUE)
        utils::zip(file, basename(dir), flags = "-r9Xq")
      }, error = function(e) {
        showNotification(paste("Source error:", conditionMessage(e)), type = "error")
      })
    }
  )

  # The Interpretations card is a JASP/JAMOVI-style output canvas: every
  # research question is one self-contained block in reading order (badges,
  # the APA line, the numbers table, the chart), the planned decision rule
  # sits directly above the box where you write the interpretation that
  # answers it, and a "Copy result" button gets one output out without
  # generating a whole report. This is the single place to read a result and
  # write about it, rather than switching between the Run stage (which has
  # the chart but no writing box) and a text-only interpretation list.
  output$export_interpretations_ui <- renderUI({
    req(rv$instrument)
    plan <- rv$instrument$analysis_plan %||% list()
    if (length(plan) == 0) {
      return(tags$p(class = "hint",
        "Declare the analyses in Plan to add interpretations."))
    }
    results <- NULL
    all_plot_tags <- list()
    if (!is.null(rv$responses)) {
      results <- analysis_results_r()
      if (inherits(results, "error")) {
        results <- NULL
      } else {
        all_plot_tags <- analysis_result_plot_tags_r()
      }
    }
    result_block_ids <- if (!is.null(results)) {
      vapply(results, function(r) r$block_id %||% "", character(1))
    } else {
      character(0)
    }
    fields <- lapply(seq_along(plan), function(i) {
      block <- plan[[i]]
      block_id <- block$id %||% ""
      fld <- studio_interp_input_id(i, block_id)
      result <- NULL
      plot_tags <- list()
      hit_idx <- match(block_id, result_block_ids)
      if (!is.na(hit_idx)) {
        result <- results[[hit_idx]]
        plot_tags <- all_plot_tags[[hit_idx]] %||% list()
      }
      # Each research question folds, so 36 of them read as a list.
      tags$details(class = "card result-canvas-block",
        tags$summary(
          tags$span(class = "card-title", studio_rq_heading(i, block_id)),
          tags$span(class = "hint", block$research_question %||% "")),
        tags$div(
          tags$span(class = "vbadge", block$method %||% block$test %||% ""),
          if (!is.null(result) && !is.null(result$effect_label)) {
            tags$span(class = "vbadge", paste(result$effect_label, "effect"))
          }
        ),
        if (is.null(result)) {
          tags$p(class = "hint",
            "Upload response data to see the result while you write.")
        } else if (!is.null(result$error)) {
          tags$p(class = "hint", paste("Error:", result$error))
        } else {
          tagList(
            tags$p(tags$strong("Result: "), result$apa %||% ""),
            studio_result_table_tag(result$table),
            if (!is.null(result$syntax)) tags$pre(class = "sf-code", result$syntax),
            do.call(tagList, plot_tags)
          )
        },
        studio_copy_result_btn(),
        if (nzchar(block$decision_rule %||% "")) {
          tags$p(class = "hint",
            paste("Planned decision rule:", block$decision_rule))
        },
        tags$label(class = "vmeta-lbl", "Interpretation"),
        sframe_studio_cite_field(textAreaInput(fld, NULL,
          value = shiny::isolate(input[[fld]] %||% ""),
          rows = 6, width = "100%",
          placeholder = "State what this result means for the research question."), sprintf("Interpretation of %s", block_id))
      )
    })
    do.call(tagList, fields)
  })

  # Collect the non-empty Export-screen interpretation fields as the named
  # list render_report() expects, keyed by plan block id.
  studio_collect_interpretations <- function() {
    plan <- rv$instrument$analysis_plan %||% list()
    out <- list()
    for (i in seq_along(plan)) {
      block_id <- plan[[i]]$id %||% ""
      if (!nzchar(block_id)) next
      text <- trim_or_null(input[[studio_interp_input_id(i, block_id)]])
      if (!is.null(text)) {
        out[[block_id]] <- text
      }
    }
    if (length(out) > 0) out else NULL
  }

  studio_report_authors <- function() {
    a <- trimws(strsplit(input$rpt_authors %||% "", ",", fixed = TRUE)[[1]])
    a <- a[nzchar(a)]
    if (length(a) > 0) a else NULL
  }

  # Only the figure settings given, so an empty field keeps the engine's own.
  studio_report_figures <- function() {
    f <- list(width = input$rpt_fig_width, height = input$rpt_fig_height,
              dpi = input$rpt_fig_dpi)
    f <- Filter(function(v) is.numeric(v) && length(v) == 1 && !is.na(v) && v > 0, f)
    if ((input$rpt_fig_format %||% "default") %in% c("png", "svg")) f$format <- input$rpt_fig_format
    if (length(f) > 0) f else NULL
  }

  # Which engine will write the report, and what the built-in one cannot do.
  output$export_engine_note <- renderUI({
    note <- sframe_studio_quarto_note()
    tags$p(id = "quarto_status", class = paste("plan-msg", if (note$ok) "ok"), note$text)
  })

  # The Export report pane is hidden until it is opened, and its link must
  # be ready before, as a hidden output is otherwise not drawn.
  for (o in c("export_report_ui", "export_engine_note", "export_source_ui"))
    outputOptions(output, o, suspendWhenHidden = FALSE)
  # The options on Configure, shared by the finished report and the source.
  studio_report_args <- function() list(
    instrument = rv$instrument,
    data = rv$responses,
    open = FALSE,
    include_codebook = isTRUE(input$rpt_codebook),
    include_quality = isTRUE(input$rpt_quality),
    include_missing = isTRUE(input$rpt_missing),
    include_descriptives = isTRUE(input$rpt_descriptives),
    include_reliability = isTRUE(input$rpt_reliability),
    include_analysis = isTRUE(input$rpt_analysis),
    include_models = isTRUE(input$rpt_models),
    plot_palette = input$rpt_palette %||% "web",
    interpretations = studio_collect_interpretations(),
    show_code = !isFALSE(input$rpt_show_code),
    title = trim_or_null(input$rpt_title),
    authors = studio_report_authors(),
    csl = sframe_studio_csl(input$rpt_style, input$rpt_csl),
    figures = studio_report_figures() %||% getOption("surveyframe.figures")
  )

  output$download_report_btn <- downloadHandler(
    filename = function() {
      paste0(
        gsub("[^a-zA-Z0-9]", "_", (rv$instrument$meta$title %||% "survey")),
        "_report.", input$rpt_format %||% "html"
      )
    },
    content = function(file) {
      tryCatch({
        do.call(render_report, c(studio_report_args(), list(format = input$rpt_format %||% "html", output_file = file)))
      }, error = function(e) {
        showNotification(paste("Report error:", conditionMessage(e)), type = "error")
      })
    }
  )
  outputOptions(output, "download_report_btn", suspendWhenHidden = FALSE)
  outputOptions(output, "download_source_btn", suspendWhenHidden = FALSE)
}

shinyApp(ui = ui, server = server)
