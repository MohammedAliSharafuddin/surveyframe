# R/analysis_role_aliases.R
# The role aliases an analysis plan block may use, by method. R reads some
# roles under more than one name (a mediation's `x` is its `predictor`, its
# `y` the `outcome`), so a plan written in R may use either. The names on the
# left are the ones SurveyBuilder's role editor uses, the vectors the other
# names R accepts for the same role. data-raw/inline_role_aliases.R inlines
# this table into the builder, and tests/testthat/test-builder-role-aliases.R
# fails if the two differ or if sframe_vars_for_method() reads a name that is
# missing here.

sframe_role_aliases <- function() {
  outcome_dep <- list(outcome = "dependent")
  dep_outcome <- list(dependent = "outcome", predictors = "covariates")
  paired <- list(before = "x", after = "y")
  repeated <- list(measures = "variables")
  items <- list(items = "variables")
  list(
    frequency = list(variable = "variables"),
    descriptives = list(variables = c("items", "scales")),
    missing_data = list(variables = "items"),
    cochran_q = repeated,
    mann_whitney = outcome_dep,
    t_test_ind = outcome_dep,
    t_test_pair = paired,
    wilcoxon_pair = paired,
    kruskal_wallis = outcome_dep,
    anova_one = outcome_dep,
    anova_two = list(factor1 = "factor_a", factor2 = "factor_b",
                     outcome = "dependent"),
    ancova = list(group = "factor", covariates = "covariate",
                  outcome = "dependent"),
    repeated_anova = repeated,
    friedman = repeated,
    partial_correlation = list(x = "predictor",
                               y = c("outcome", "dependent"),
                               controls = c("control", "covariates")),
    regression_linear = dep_outcome,
    regression_logistic_binary = dep_outcome,
    regression_logistic_ordinal = dep_outcome,
    regression_logistic_multinomial = dep_outcome,
    firth_logistic = dep_outcome,
    mediation = list(predictor = "x", outcome = c("dependent", "y")),
    moderation = outcome_dep,
    efa_solution = items
  )
}

# The table as the JSON line the builder carries. Every alias vector stays an
# array, so the builder never meets a bare string.
sframe_role_aliases_json <- function() {
  tab <- lapply(sframe_role_aliases(), function(m) lapply(m, as.list))
  as.character(jsonlite::toJSON(tab, auto_unbox = TRUE))
}
