# Run a pre-planned analysis from an instrument's analysis plan

Executes every analysis block defined in the instrument's
`analysis_plan` slot against the supplied response data. Each block
corresponds to one research question defined during instrument design in
the SurveyBuilder. Results include APA-formatted statistics, effect
sizes, interpretation prompts, and reporting references.

## Usage

``` r
run_analysis_plan(data, instrument, scored = TRUE, plots = FALSE)
```

## Arguments

- data:

  A `tibble` or `data.frame` of responses, typically produced by
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
  or
  [`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md).

- instrument:

  An `sframe` object containing an `analysis_plan`.

- scored:

  Logical. Whether to automatically score scales before running the
  analysis. Defaults to `TRUE`.

- plots:

  Logical. When `TRUE` and ggplot2 is installed, supported blocks gain a
  `$plot` element holding a brand-styled ggplot object: bar charts for
  frequency and chi-square blocks, scatter plots with a regression
  overlay for correlation and linear-regression blocks. Defaults to
  `FALSE`.

## Value

An object of class `sframe_analysis_results`, a list with one element
per analysis block. Each element contains the test result, APA string,
interpretation prompt, and reporting-reference metadata. Inferential
blocks also carry a `$table` data frame suitable for
[`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html). Pass to
[`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md)
to generate a formatted report.

## See also

[`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md),
[`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md)

## Examples

``` r
instr <- read_sframe(
  system.file("extdata", "tourism_services_demo.sframe",
              package = "surveyframe")
)
responses <- read_responses(
  system.file("extdata", "tourism_services_responses.csv",
              package = "surveyframe"),
  instr,
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  meta_cols = "started_at"
)
results <- run_analysis_plan(responses, instr)
print(results)
#> Analysis Results: 34 research question(s)
#> 
#> RQ 1: Is perceived digital marketing effectiveness associated with tourist satisfaction?
#>   Test: correlation_pearson
#>   APA:  r(118) = 0.54, p < .001
#> 
#> RQ 2: Do digital marketing, service quality, and sustainability perceptions predict satisfaction?
#>   Test: regression_linear
#>   APA:  R² = 0.383, F(3, 116) = 23.95, p < .001
#> 
#> RQ 3: Do first-time and repeat visitors differ in behavioural intention?
#>   Test: mann_whitney
#>   APA:  U = 1576, z = -0.98, p = 0.327, r = 0.09
#> 
#> RQ 4: What is the distribution of first-time and repeat visitors?
#>   Test: frequency
#>   APA:  Frequency distribution for visit_type (N = 120).
#> 
#> RQ 5: What are the central tendency and spread of all response items?
#>   Test: descriptives
#>   APA:  Descriptive statistics were computed for 12 variable(s).
#> 
#> RQ 6: What is the pattern of missing responses across items?
#>   Test: missing_data
#>   APA:  Missing-data diagnostics were computed for 12 variable(s).
#> 
#> RQ 7: Do respondents meet attention check and data quality thresholds?
#>   Test: quality
#>   APA:  
#> 
#> RQ 8: What are the mean, SD, and range of each composite scale?
#>   Test: descriptives
#>   APA:  Descriptive statistics were computed for 5 variable(s).
#> 
#> RQ 9: What is the Cronbach alpha internal consistency of each scale?
#>   Test: reliability_alpha
#>   APA:  
#> 
#> RQ 10: What is the McDonald omega reliability of each scale?
#>   Test: reliability_omega
#>   APA:  
#> 
#> RQ 11: Which items show low item-total correlations or reduce alpha on removal?
#>   Test: item_diagnostics
#>   APA:  
#> 
#> RQ 12: Does the inter-item correlation matrix support exploratory factor analysis?
#>   Test: efa_readiness
#>   APA:  
#> 
#> RQ 13: How many factors emerge from digital marketing and service quality items?
#>   Test: efa_solution
#>   APA:  
#> 
#> RQ 14: What is the lavaan CFA syntax for the five-factor measurement model?
#>   Test: cfa_lavaan_syntax
#>   APA:  CFA lavaan syntax generated.
#> 
#> RQ 15: What is the CB-SEM lavaan syntax for digital marketing predicting satisfaction and behavioural intention via service quality?
#>   Test: sem_lavaan_syntax
#>   APA:  CB-SEM lavaan syntax generated.
#> 
#> RQ 16: What is the PLS-SEM seminr syntax for the full structural model?
#>   Test: seminr_syntax
#>   APA:  PLS-SEM seminr syntax generated.
#> 
#> RQ 17: Is visitor type associated with attention check response level?
#>   Test: crosstab
#>   APA:  χ²(1, N = 120) = 4.31, p = 0.038, φ = 0.19
#> 
#> RQ 18: Is the distribution of satisfaction ratings different across visitor types?
#>   Test: crosstab
#>   APA:  χ²(4, N = 120) = 3.40, p = 0.494, V = 0.17
#> 
#> RQ 19: Is there an association between visitor type and behavioural intention rating?
#>   Test: fisher_exact
#>   APA:  Fisher's exact test, p = 0.454, Cramer's V = 0.17
#> 
#> RQ 20: Do first-time and repeat visitors differ in mean satisfaction score?
#>   Test: t_test_ind
#>   APA:  t(106.77) = 0.15, p = 0.878, d = 0.03
#> 
#> RQ 21: Do respondents rate the two satisfaction items differently?
#>   Test: t_test_pair
#>   APA:  t(119) = 0.82, p = 0.416, d_z = 0.07
#> 
#> RQ 22: Is there a significant distributional difference between the first two service quality items?
#>   Test: wilcoxon_pair
#>   APA:  V = 967, z = -1.17, p = 0.240, r = 0.11
#> 
#> RQ 23: Does satisfaction differ across visitor types?
#>   Test: kruskal_wallis
#>   APA:  H(1) = 0.00, p = 0.949, η² = 0.000
#> 
#> RQ 24: Does mean behavioural intention differ between visitor types?
#>   Test: anova_one
#>   APA:  F(1, 118) = 0.74, p = 0.391, η² = 0.006
#> 
#> RQ 25: Do visitor types differ in satisfaction after controlling for service quality?
#>   Test: ancova
#>   APA:  ANCOVA estimated group differences adjusted for covariates.
#> 
#> RQ 26: Do mean ratings differ across the three digital marketing items within respondents?
#>   Test: repeated_anova
#>   APA:  Repeated-measures ANOVA was estimated; inspect `fit_summary` for the within-subject effect.
#> 
#> RQ 27: Do ordinal ratings differ across the three service quality items within respondents?
#>   Test: friedman
#>   APA:  Friedman chi-square(2, N = 120) = 1.09, p = 0.580
#> 
#> RQ 28: Are service quality perceptions associated with sustainability perceptions?
#>   Test: correlation_spearman
#>   APA:  r_s(118) = 0.00, p = 0.984
#> 
#> RQ 29: Is sustainability perception associated with behavioural intention?
#>   Test: correlation_kendall
#>   APA:  tau(118) = 0.05, p = 0.519
#> 
#> RQ 30: Is digital marketing associated with behavioural intention after controlling for satisfaction?
#>   Test: partial_correlation
#>   APA:  partial r(117) = -0.09, p = 0.302
#> 
#> RQ 31: Do digital marketing and service quality perceptions predict visitor type?
#>   Test: regression_logistic_binary
#>   APA:  χ²(2) = 0.28, p = 0.869, McFadden R² = 0.002
#> 
#> RQ 32: Do digital marketing and sustainability perceptions predict ordered satisfaction?
#>   Test: regression_logistic_ordinal
#>   APA:  Ordinal logistic regression was estimated with 120 complete cases.
#> 
#> RQ 33: Does visitor type moderate the relationship between digital marketing and satisfaction?
#>   Test: moderation
#>   APA:  Moderation was tested with a linear interaction model.
#> 
#> RQ 34: Does satisfaction mediate the path from digital marketing to behavioural intention?
#>   Test: mediation
#>   APA:  Indirect effect = 0.365, 95% bootstrap CI [0.228, 0.533].
#> 
```
