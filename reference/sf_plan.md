# Get the pre-declared analysis plan

Returns the ordered analysis blocks attached to an instrument or
codebook.

## Usage

``` r
sf_plan(x, ...)
```

## Arguments

- x:

  A surveyframe object.

- ...:

  Passed to methods.

## Value

A list of analysis blocks for an instrument or a plan data frame for a
codebook.

## See also

[sf_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md),
sf_plan\<-

## Examples

``` r
sf_plan(sframe_demo_data()$instrument)
#> [[1]]
#> [[1]]$id
#> [1] "rq_dm_sat"
#> 
#> [[1]]$research_question
#> [1] "Is perceived digital marketing effectiveness associated with tourist satisfaction?"
#> 
#> [[1]]$variables
#> [1] "digital_marketing" "satisfaction"     
#> 
#> [[1]]$test
#> [1] "correlation_pearson"
#> 
#> [[1]]$alpha
#> [1] 0.05
#> 
#> [[1]]$interpretation
#> [1] "Use the direction and size of the correlation to describe the relationship."
#> 
#> [[1]]$citations
#> character(0)
#> 
#> [[1]]$family
#> [1] ""
#> 
#> [[1]]$method
#> [1] "correlation_pearson"
#> 
#> [[1]]$roles
#> list()
#> 
#> [[1]]$options
#> list()
#> 
#> [[1]]$decision_rule
#> [1] "Use the direction and size of the correlation to describe the relationship."
#> 
#> [[1]]$reporting_references
#> character(0)
#> 
#> [[1]]$status
#> [1] "draft"
#> 
#> [[1]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[2]]
#> [[2]]$id
#> [1] "rq_predict_sat"
#> 
#> [[2]]$research_question
#> [1] "Do digital marketing, service quality, and sustainability perceptions predict satisfaction?"
#> 
#> [[2]]$variables
#> [1] "digital_marketing" "service_quality"   "sustainability"   
#> [4] "satisfaction"     
#> 
#> [[2]]$test
#> [1] "regression_linear"
#> 
#> [[2]]$alpha
#> [1] 0.05
#> 
#> [[2]]$interpretation
#> [1] "Compare the regression coefficients to identify the strongest predictor."
#> 
#> [[2]]$citations
#> character(0)
#> 
#> [[2]]$family
#> [1] ""
#> 
#> [[2]]$method
#> [1] "regression_linear"
#> 
#> [[2]]$roles
#> list()
#> 
#> [[2]]$options
#> list()
#> 
#> [[2]]$decision_rule
#> [1] "Compare the regression coefficients to identify the strongest predictor."
#> 
#> [[2]]$reporting_references
#> character(0)
#> 
#> [[2]]$status
#> [1] "draft"
#> 
#> [[2]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[3]]
#> [[3]]$id
#> [1] "rq_visit_bi"
#> 
#> [[3]]$research_question
#> [1] "Do first-time and repeat visitors differ in behavioural intention?"
#> 
#> [[3]]$variables
#> [1] "visit_type"            "behavioural_intention"
#> 
#> [[3]]$test
#> [1] "mann_whitney"
#> 
#> [[3]]$alpha
#> [1] 0.05
#> 
#> [[3]]$interpretation
#> [1] "Report whether behavioural intention differs by visitor type."
#> 
#> [[3]]$citations
#> character(0)
#> 
#> [[3]]$family
#> [1] ""
#> 
#> [[3]]$method
#> [1] "mann_whitney"
#> 
#> [[3]]$roles
#> list()
#> 
#> [[3]]$options
#> list()
#> 
#> [[3]]$decision_rule
#> [1] "Report whether behavioural intention differs by visitor type."
#> 
#> [[3]]$reporting_references
#> character(0)
#> 
#> [[3]]$status
#> [1] "draft"
#> 
#> [[3]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[4]]
#> [[4]]$id
#> [1] "rq_freq"
#> 
#> [[4]]$research_question
#> [1] "What is the distribution of first-time and repeat visitors?"
#> 
#> [[4]]$variables
#> [1] "visit_type"
#> 
#> [[4]]$test
#> [1] "frequency"
#> 
#> [[4]]$method
#> [1] "frequency"
#> 
#> [[4]]$alpha
#> [1] 0.05
#> 
#> [[4]]$family
#> [1] "descriptive"
#> 
#> [[4]]$roles
#> list()
#> 
#> [[4]]$options
#> list()
#> 
#> [[4]]$decision_rule
#> [1] "Report absolute and relative frequencies."
#> 
#> [[4]]$interpretation
#> [1] "Report absolute and relative frequencies."
#> 
#> [[4]]$citations
#> character(0)
#> 
#> [[4]]$reporting_references
#> character(0)
#> 
#> [[4]]$status
#> [1] "valid_plan"
#> 
#> [[4]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[5]]
#> [[5]]$id
#> [1] "rq_desc"
#> 
#> [[5]]$research_question
#> [1] "What are the central tendency and spread of all response items?"
#> 
#> [[5]]$variables
#>  [1] "dm_1"  "dm_2"  "dm_3"  "sq_1"  "sq_2"  "sq_3"  "sus_1" "sus_2" "sat_1"
#> [10] "sat_2" "bi_1"  "bi_2" 
#> 
#> [[5]]$test
#> [1] "descriptives"
#> 
#> [[5]]$method
#> [1] "descriptives"
#> 
#> [[5]]$alpha
#> [1] 0.05
#> 
#> [[5]]$family
#> [1] "descriptive"
#> 
#> [[5]]$roles
#> list()
#> 
#> [[5]]$options
#> list()
#> 
#> [[5]]$decision_rule
#> [1] "Inspect mean, SD, skewness, and kurtosis for each item."
#> 
#> [[5]]$interpretation
#> [1] "Inspect mean, SD, skewness, and kurtosis for each item."
#> 
#> [[5]]$citations
#> character(0)
#> 
#> [[5]]$reporting_references
#> character(0)
#> 
#> [[5]]$status
#> [1] "valid_plan"
#> 
#> [[5]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[6]]
#> [[6]]$id
#> [1] "rq_missing"
#> 
#> [[6]]$research_question
#> [1] "What is the pattern of missing responses across items?"
#> 
#> [[6]]$variables
#>  [1] "dm_1"  "dm_2"  "dm_3"  "sq_1"  "sq_2"  "sq_3"  "sus_1" "sus_2" "sat_1"
#> [10] "sat_2" "bi_1"  "bi_2" 
#> 
#> [[6]]$test
#> [1] "missing_data"
#> 
#> [[6]]$method
#> [1] "missing_data"
#> 
#> [[6]]$alpha
#> [1] 0.05
#> 
#> [[6]]$family
#> [1] "descriptive"
#> 
#> [[6]]$roles
#> list()
#> 
#> [[6]]$options
#> list()
#> 
#> [[6]]$decision_rule
#> [1] "Flag items with more than 10 per cent missing."
#> 
#> [[6]]$interpretation
#> [1] "Flag items with more than 10 per cent missing."
#> 
#> [[6]]$citations
#> character(0)
#> 
#> [[6]]$reporting_references
#> character(0)
#> 
#> [[6]]$status
#> [1] "valid_plan"
#> 
#> [[6]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[7]]
#> [[7]]$id
#> [1] "rq_quality"
#> 
#> [[7]]$research_question
#> [1] "Do respondents meet attention check and data quality thresholds?"
#> 
#> [[7]]$test
#> [1] "quality"
#> 
#> [[7]]$method
#> [1] "quality"
#> 
#> [[7]]$alpha
#> [1] 0.05
#> 
#> [[7]]$family
#> [1] "data_quality"
#> 
#> [[7]]$roles
#> list()
#> 
#> [[7]]$options
#> list()
#> 
#> [[7]]$decision_rule
#> [1] "Exclude respondents who fail the attention check or complete in under 60 seconds."
#> 
#> [[7]]$interpretation
#> [1] "Exclude respondents who fail the attention check or complete in under 60 seconds."
#> 
#> [[7]]$citations
#> character(0)
#> 
#> [[7]]$reporting_references
#> character(0)
#> 
#> [[7]]$status
#> [1] "valid_plan"
#> 
#> [[7]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[8]]
#> [[8]]$id
#> [1] "rq_scale_desc"
#> 
#> [[8]]$research_question
#> [1] "What are the mean, SD, and range of each composite scale?"
#> 
#> [[8]]$test
#> [1] "scale_descriptives"
#> 
#> [[8]]$method
#> [1] "scale_descriptives"
#> 
#> [[8]]$alpha
#> [1] 0.05
#> 
#> [[8]]$family
#> [1] "descriptive"
#> 
#> [[8]]$roles
#> list()
#> 
#> [[8]]$options
#> list()
#> 
#> [[8]]$decision_rule
#> [1] "Report scale-level descriptives alongside item-level results."
#> 
#> [[8]]$interpretation
#> [1] "Report scale-level descriptives alongside item-level results."
#> 
#> [[8]]$citations
#> character(0)
#> 
#> [[8]]$reporting_references
#> character(0)
#> 
#> [[8]]$status
#> [1] "valid_plan"
#> 
#> [[8]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[9]]
#> [[9]]$id
#> [1] "rq_alpha"
#> 
#> [[9]]$research_question
#> [1] "What is the Cronbach alpha internal consistency of each scale?"
#> 
#> [[9]]$test
#> [1] "reliability_alpha"
#> 
#> [[9]]$method
#> [1] "reliability_alpha"
#> 
#> [[9]]$alpha
#> [1] 0.05
#> 
#> [[9]]$family
#> [1] "reliability"
#> 
#> [[9]]$roles
#> list()
#> 
#> [[9]]$options
#> list()
#> 
#> [[9]]$decision_rule
#> [1] "Flag any scale with alpha below 0.70 as requiring revision."
#> 
#> [[9]]$interpretation
#> [1] "Flag any scale with alpha below 0.70 as requiring revision."
#> 
#> [[9]]$citations
#> character(0)
#> 
#> [[9]]$reporting_references
#> character(0)
#> 
#> [[9]]$status
#> [1] "valid_plan"
#> 
#> [[9]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[10]]
#> [[10]]$id
#> [1] "rq_omega"
#> 
#> [[10]]$research_question
#> [1] "What is the McDonald omega reliability of each scale?"
#> 
#> [[10]]$test
#> [1] "reliability_omega"
#> 
#> [[10]]$method
#> [1] "reliability_omega"
#> 
#> [[10]]$alpha
#> [1] 0.05
#> 
#> [[10]]$family
#> [1] "reliability"
#> 
#> [[10]]$roles
#> list()
#> 
#> [[10]]$options
#> list()
#> 
#> [[10]]$decision_rule
#> [1] "Compare omega to alpha; prefer omega when item loadings are unequal."
#> 
#> [[10]]$interpretation
#> [1] "Compare omega to alpha; prefer omega when item loadings are unequal."
#> 
#> [[10]]$citations
#> character(0)
#> 
#> [[10]]$reporting_references
#> character(0)
#> 
#> [[10]]$status
#> [1] "valid_plan"
#> 
#> [[10]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[11]]
#> [[11]]$id
#> [1] "rq_item_diag"
#> 
#> [[11]]$research_question
#> [1] "Which items show low item-total correlations or reduce alpha on removal?"
#> 
#> [[11]]$test
#> [1] "item_diagnostics"
#> 
#> [[11]]$method
#> [1] "item_diagnostics"
#> 
#> [[11]]$alpha
#> [1] 0.05
#> 
#> [[11]]$family
#> [1] "reliability"
#> 
#> [[11]]$roles
#> list()
#> 
#> [[11]]$options
#> list()
#> 
#> [[11]]$decision_rule
#> [1] "Consider removing items with corrected item-total correlation below 0.30."
#> 
#> [[11]]$interpretation
#> [1] "Consider removing items with corrected item-total correlation below 0.30."
#> 
#> [[11]]$citations
#> character(0)
#> 
#> [[11]]$reporting_references
#> character(0)
#> 
#> [[11]]$status
#> [1] "valid_plan"
#> 
#> [[11]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[12]]
#> [[12]]$id
#> [1] "rq_efa_ready"
#> 
#> [[12]]$research_question
#> [1] "Does the inter-item correlation matrix support exploratory factor analysis?"
#> 
#> [[12]]$variables
#> [1] "dm_1"  "dm_2"  "dm_3"  "sq_1"  "sq_2"  "sq_3"  "sus_1" "sus_2"
#> 
#> [[12]]$test
#> [1] "efa_readiness"
#> 
#> [[12]]$method
#> [1] "efa_readiness"
#> 
#> [[12]]$alpha
#> [1] 0.05
#> 
#> [[12]]$family
#> [1] "measurement"
#> 
#> [[12]]$roles
#> list()
#> 
#> [[12]]$options
#> list()
#> 
#> [[12]]$decision_rule
#> [1] "Proceed with EFA if KMO exceeds 0.60 and Bartlett test is significant."
#> 
#> [[12]]$interpretation
#> [1] "Proceed with EFA if KMO exceeds 0.60 and Bartlett test is significant."
#> 
#> [[12]]$citations
#> character(0)
#> 
#> [[12]]$reporting_references
#> character(0)
#> 
#> [[12]]$status
#> [1] "valid_plan"
#> 
#> [[12]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[13]]
#> [[13]]$id
#> [1] "rq_efa_sol"
#> 
#> [[13]]$research_question
#> [1] "How many factors emerge from digital marketing and service quality items?"
#> 
#> [[13]]$variables
#> [1] "dm_1"  "dm_2"  "dm_3"  "sq_1"  "sq_2"  "sq_3"  "sus_1" "sus_2"
#> 
#> [[13]]$test
#> [1] "efa_solution"
#> 
#> [[13]]$method
#> [1] "efa_solution"
#> 
#> [[13]]$alpha
#> [1] 0.05
#> 
#> [[13]]$family
#> [1] "measurement"
#> 
#> [[13]]$roles
#> list()
#> 
#> [[13]]$options
#> [[13]]$options$nfactors
#> [1] 2
#> 
#> 
#> [[13]]$decision_rule
#> [1] "Retain factors with eigenvalue above 1 and inspect the scree plot."
#> 
#> [[13]]$interpretation
#> [1] "Retain factors with eigenvalue above 1 and inspect the scree plot."
#> 
#> [[13]]$citations
#> character(0)
#> 
#> [[13]]$reporting_references
#> character(0)
#> 
#> [[13]]$status
#> [1] "valid_plan"
#> 
#> [[13]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[14]]
#> [[14]]$id
#> [1] "rq_cfa_syntax"
#> 
#> [[14]]$research_question
#> [1] "What is the lavaan CFA syntax for the five-factor measurement model?"
#> 
#> [[14]]$test
#> [1] "cfa_lavaan_syntax"
#> 
#> [[14]]$method
#> [1] "cfa_lavaan_syntax"
#> 
#> [[14]]$alpha
#> [1] 0.05
#> 
#> [[14]]$family
#> [1] "measurement"
#> 
#> [[14]]$roles
#> [[14]]$roles$model
#> [[14]]$roles$model[[1]]
#> [1] "tourism_cfa"
#> 
#> 
#> 
#> [[14]]$options
#> list()
#> 
#> [[14]]$decision_rule
#> [1] "Inspect syntax before fitting; confirm indicator counts meet CFA identification rules."
#> 
#> [[14]]$interpretation
#> [1] "Inspect syntax before fitting; confirm indicator counts meet CFA identification rules."
#> 
#> [[14]]$citations
#> character(0)
#> 
#> [[14]]$reporting_references
#> character(0)
#> 
#> [[14]]$status
#> [1] "valid_plan"
#> 
#> [[14]]$requires_data
#> [1] FALSE
#> 
#> 
#> [[15]]
#> [[15]]$id
#> [1] "rq_sem_syntax"
#> 
#> [[15]]$research_question
#> [1] "What is the CB-SEM lavaan syntax for digital marketing predicting satisfaction and behavioural intention via service quality?"
#> 
#> [[15]]$test
#> [1] "sem_lavaan_syntax"
#> 
#> [[15]]$method
#> [1] "sem_lavaan_syntax"
#> 
#> [[15]]$alpha
#> [1] 0.05
#> 
#> [[15]]$family
#> [1] "measurement"
#> 
#> [[15]]$roles
#> [[15]]$roles$model
#> [[15]]$roles$model[[1]]
#> [1] "tourism_sem"
#> 
#> 
#> 
#> [[15]]$options
#> list()
#> 
#> [[15]]$decision_rule
#> [1] "Review structural paths before fitting to confirm the model is identified."
#> 
#> [[15]]$interpretation
#> [1] "Review structural paths before fitting to confirm the model is identified."
#> 
#> [[15]]$citations
#> character(0)
#> 
#> [[15]]$reporting_references
#> character(0)
#> 
#> [[15]]$status
#> [1] "valid_plan"
#> 
#> [[15]]$requires_data
#> [1] FALSE
#> 
#> 
#> [[16]]
#> [[16]]$id
#> [1] "rq_pls_syntax"
#> 
#> [[16]]$research_question
#> [1] "What is the PLS-SEM seminr syntax for the full structural model?"
#> 
#> [[16]]$test
#> [1] "seminr_syntax"
#> 
#> [[16]]$method
#> [1] "seminr_syntax"
#> 
#> [[16]]$alpha
#> [1] 0.05
#> 
#> [[16]]$family
#> [1] "measurement"
#> 
#> [[16]]$roles
#> [[16]]$roles$model
#> [[16]]$roles$model[[1]]
#> [1] "tourism_pls"
#> 
#> 
#> 
#> [[16]]$options
#> list()
#> 
#> [[16]]$decision_rule
#> [1] "Use seminr syntax only when the seminr package is installed."
#> 
#> [[16]]$interpretation
#> [1] "Use seminr syntax only when the seminr package is installed."
#> 
#> [[16]]$citations
#> character(0)
#> 
#> [[16]]$reporting_references
#> character(0)
#> 
#> [[16]]$status
#> [1] "valid_plan"
#> 
#> [[16]]$requires_data
#> [1] FALSE
#> 
#> 
#> [[17]]
#> [[17]]$id
#> [1] "rq_chisq"
#> 
#> [[17]]$research_question
#> [1] "Is visitor type associated with attention check response level?"
#> 
#> [[17]]$variables
#> [1] "visit_type" "attention" 
#> 
#> [[17]]$test
#> [1] "chi_square"
#> 
#> [[17]]$method
#> [1] "chi_square"
#> 
#> [[17]]$alpha
#> [1] 0.05
#> 
#> [[17]]$family
#> [1] "categorical"
#> 
#> [[17]]$roles
#> list()
#> 
#> [[17]]$options
#> list()
#> 
#> [[17]]$decision_rule
#> [1] "Report chi-square, degrees of freedom, p value, and Cramer V."
#> 
#> [[17]]$interpretation
#> [1] "Report chi-square, degrees of freedom, p value, and Cramer V."
#> 
#> [[17]]$citations
#> character(0)
#> 
#> [[17]]$reporting_references
#> character(0)
#> 
#> [[17]]$status
#> [1] "valid_plan"
#> 
#> [[17]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[18]]
#> [[18]]$id
#> [1] "rq_crosstab"
#> 
#> [[18]]$research_question
#> [1] "Is the distribution of satisfaction ratings different across visitor types?"
#> 
#> [[18]]$variables
#> [1] "visit_type" "sat_1"     
#> 
#> [[18]]$test
#> [1] "crosstab"
#> 
#> [[18]]$method
#> [1] "crosstab"
#> 
#> [[18]]$alpha
#> [1] 0.05
#> 
#> [[18]]$family
#> [1] "categorical"
#> 
#> [[18]]$roles
#> list()
#> 
#> [[18]]$options
#> list()
#> 
#> [[18]]$decision_rule
#> [1] "Inspect row percentages across visitor types and report the effect size."
#> 
#> [[18]]$interpretation
#> [1] "Inspect row percentages across visitor types and report the effect size."
#> 
#> [[18]]$citations
#> character(0)
#> 
#> [[18]]$reporting_references
#> character(0)
#> 
#> [[18]]$status
#> [1] "valid_plan"
#> 
#> [[18]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[19]]
#> [[19]]$id
#> [1] "rq_fisher"
#> 
#> [[19]]$research_question
#> [1] "Is there an association between visitor type and behavioural intention rating?"
#> 
#> [[19]]$variables
#> [1] "visit_type" "bi_1"      
#> 
#> [[19]]$test
#> [1] "fisher_exact"
#> 
#> [[19]]$method
#> [1] "fisher_exact"
#> 
#> [[19]]$alpha
#> [1] 0.05
#> 
#> [[19]]$family
#> [1] "categorical"
#> 
#> [[19]]$roles
#> list()
#> 
#> [[19]]$options
#> list()
#> 
#> [[19]]$decision_rule
#> [1] "Use Fisher p value when expected cell counts fall below 5."
#> 
#> [[19]]$interpretation
#> [1] "Use Fisher p value when expected cell counts fall below 5."
#> 
#> [[19]]$citations
#> character(0)
#> 
#> [[19]]$reporting_references
#> character(0)
#> 
#> [[19]]$status
#> [1] "valid_plan"
#> 
#> [[19]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[20]]
#> [[20]]$id
#> [1] "rq_ttest_ind"
#> 
#> [[20]]$research_question
#> [1] "Do first-time and repeat visitors differ in mean satisfaction score?"
#> 
#> [[20]]$variables
#> [1] "visit_type"   "satisfaction"
#> 
#> [[20]]$test
#> [1] "t_test_ind"
#> 
#> [[20]]$method
#> [1] "t_test_ind"
#> 
#> [[20]]$alpha
#> [1] 0.05
#> 
#> [[20]]$family
#> [1] "group_comparison"
#> 
#> [[20]]$roles
#> list()
#> 
#> [[20]]$options
#> list()
#> 
#> [[20]]$decision_rule
#> [1] "Report t, degrees of freedom, p value, and Cohen d."
#> 
#> [[20]]$interpretation
#> [1] "Report t, degrees of freedom, p value, and Cohen d."
#> 
#> [[20]]$citations
#> character(0)
#> 
#> [[20]]$reporting_references
#> character(0)
#> 
#> [[20]]$status
#> [1] "valid_plan"
#> 
#> [[20]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[21]]
#> [[21]]$id
#> [1] "rq_ttest_pair"
#> 
#> [[21]]$research_question
#> [1] "Do respondents rate the two satisfaction items differently?"
#> 
#> [[21]]$variables
#> [1] "sat_1" "sat_2"
#> 
#> [[21]]$test
#> [1] "t_test_pair"
#> 
#> [[21]]$method
#> [1] "t_test_pair"
#> 
#> [[21]]$alpha
#> [1] 0.05
#> 
#> [[21]]$family
#> [1] "group_comparison"
#> 
#> [[21]]$roles
#> list()
#> 
#> [[21]]$options
#> list()
#> 
#> [[21]]$decision_rule
#> [1] "Report the mean difference, paired t statistic, and p value."
#> 
#> [[21]]$interpretation
#> [1] "Report the mean difference, paired t statistic, and p value."
#> 
#> [[21]]$citations
#> character(0)
#> 
#> [[21]]$reporting_references
#> character(0)
#> 
#> [[21]]$status
#> [1] "valid_plan"
#> 
#> [[21]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[22]]
#> [[22]]$id
#> [1] "rq_wilcoxon"
#> 
#> [[22]]$research_question
#> [1] "Is there a significant distributional difference between the first two service quality items?"
#> 
#> [[22]]$variables
#> [1] "sq_1" "sq_2"
#> 
#> [[22]]$test
#> [1] "wilcoxon_pair"
#> 
#> [[22]]$method
#> [1] "wilcoxon_pair"
#> 
#> [[22]]$alpha
#> [1] 0.05
#> 
#> [[22]]$family
#> [1] "group_comparison"
#> 
#> [[22]]$roles
#> list()
#> 
#> [[22]]$options
#> list()
#> 
#> [[22]]$decision_rule
#> [1] "Report W statistic, p value, and rank-biserial correlation."
#> 
#> [[22]]$interpretation
#> [1] "Report W statistic, p value, and rank-biserial correlation."
#> 
#> [[22]]$citations
#> character(0)
#> 
#> [[22]]$reporting_references
#> character(0)
#> 
#> [[22]]$status
#> [1] "valid_plan"
#> 
#> [[22]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[23]]
#> [[23]]$id
#> [1] "rq_kruskal"
#> 
#> [[23]]$research_question
#> [1] "Does satisfaction differ across visitor types?"
#> 
#> [[23]]$variables
#> [1] "visit_type"   "satisfaction"
#> 
#> [[23]]$test
#> [1] "kruskal_wallis"
#> 
#> [[23]]$method
#> [1] "kruskal_wallis"
#> 
#> [[23]]$alpha
#> [1] 0.05
#> 
#> [[23]]$family
#> [1] "group_comparison"
#> 
#> [[23]]$roles
#> list()
#> 
#> [[23]]$options
#> list()
#> 
#> [[23]]$decision_rule
#> [1] "Report H statistic, degrees of freedom, p value, and eta-squared."
#> 
#> [[23]]$interpretation
#> [1] "Report H statistic, degrees of freedom, p value, and eta-squared."
#> 
#> [[23]]$citations
#> character(0)
#> 
#> [[23]]$reporting_references
#> character(0)
#> 
#> [[23]]$status
#> [1] "valid_plan"
#> 
#> [[23]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[24]]
#> [[24]]$id
#> [1] "rq_anova1"
#> 
#> [[24]]$research_question
#> [1] "Does mean behavioural intention differ between visitor types?"
#> 
#> [[24]]$variables
#> [1] "visit_type"            "behavioural_intention"
#> 
#> [[24]]$test
#> [1] "anova_one"
#> 
#> [[24]]$method
#> [1] "anova_one"
#> 
#> [[24]]$alpha
#> [1] 0.05
#> 
#> [[24]]$family
#> [1] "group_comparison"
#> 
#> [[24]]$roles
#> list()
#> 
#> [[24]]$options
#> list()
#> 
#> [[24]]$decision_rule
#> [1] "Report F, degrees of freedom, p value, and partial eta-squared."
#> 
#> [[24]]$interpretation
#> [1] "Report F, degrees of freedom, p value, and partial eta-squared."
#> 
#> [[24]]$citations
#> character(0)
#> 
#> [[24]]$reporting_references
#> character(0)
#> 
#> [[24]]$status
#> [1] "valid_plan"
#> 
#> [[24]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[25]]
#> [[25]]$id
#> [1] "rq_ancova"
#> 
#> [[25]]$research_question
#> [1] "Do visitor types differ in satisfaction after controlling for service quality?"
#> 
#> [[25]]$test
#> [1] "ancova"
#> 
#> [[25]]$method
#> [1] "ancova"
#> 
#> [[25]]$alpha
#> [1] 0.05
#> 
#> [[25]]$family
#> [1] "group_comparison"
#> 
#> [[25]]$roles
#> [[25]]$roles$group
#> [[25]]$roles$group[[1]]
#> [1] "visit_type"
#> 
#> 
#> [[25]]$roles$covariate
#> [[25]]$roles$covariate[[1]]
#> [1] "service_quality"
#> 
#> 
#> [[25]]$roles$outcome
#> [[25]]$roles$outcome[[1]]
#> [1] "satisfaction"
#> 
#> 
#> 
#> [[25]]$options
#> list()
#> 
#> [[25]]$decision_rule
#> [1] "Report adjusted group means and the F test for the group factor after covariate removal."
#> 
#> [[25]]$interpretation
#> [1] "Report adjusted group means and the F test for the group factor after covariate removal."
#> 
#> [[25]]$citations
#> character(0)
#> 
#> [[25]]$reporting_references
#> character(0)
#> 
#> [[25]]$status
#> [1] "valid_plan"
#> 
#> [[25]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[26]]
#> [[26]]$id
#> [1] "rq_rep_anova"
#> 
#> [[26]]$research_question
#> [1] "Do mean ratings differ across the three digital marketing items within respondents?"
#> 
#> [[26]]$variables
#> [1] "dm_1" "dm_2" "dm_3"
#> 
#> [[26]]$test
#> [1] "repeated_anova"
#> 
#> [[26]]$method
#> [1] "repeated_anova"
#> 
#> [[26]]$alpha
#> [1] 0.05
#> 
#> [[26]]$family
#> [1] "group_comparison"
#> 
#> [[26]]$roles
#> list()
#> 
#> [[26]]$options
#> list()
#> 
#> [[26]]$decision_rule
#> [1] "Report the within-subject F, degrees of freedom, p value, and partial eta-squared."
#> 
#> [[26]]$interpretation
#> [1] "Report the within-subject F, degrees of freedom, p value, and partial eta-squared."
#> 
#> [[26]]$citations
#> character(0)
#> 
#> [[26]]$reporting_references
#> character(0)
#> 
#> [[26]]$status
#> [1] "valid_plan"
#> 
#> [[26]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[27]]
#> [[27]]$id
#> [1] "rq_friedman"
#> 
#> [[27]]$research_question
#> [1] "Do ordinal ratings differ across the three service quality items within respondents?"
#> 
#> [[27]]$variables
#> [1] "sq_1" "sq_2" "sq_3"
#> 
#> [[27]]$test
#> [1] "friedman"
#> 
#> [[27]]$method
#> [1] "friedman"
#> 
#> [[27]]$alpha
#> [1] 0.05
#> 
#> [[27]]$family
#> [1] "group_comparison"
#> 
#> [[27]]$roles
#> list()
#> 
#> [[27]]$options
#> list()
#> 
#> [[27]]$decision_rule
#> [1] "Report Friedman chi-square, degrees of freedom, and p value."
#> 
#> [[27]]$interpretation
#> [1] "Report Friedman chi-square, degrees of freedom, and p value."
#> 
#> [[27]]$citations
#> character(0)
#> 
#> [[27]]$reporting_references
#> character(0)
#> 
#> [[27]]$status
#> [1] "valid_plan"
#> 
#> [[27]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[28]]
#> [[28]]$id
#> [1] "rq_spearman"
#> 
#> [[28]]$research_question
#> [1] "Are service quality perceptions associated with sustainability perceptions?"
#> 
#> [[28]]$variables
#> [1] "service_quality" "sustainability" 
#> 
#> [[28]]$test
#> [1] "correlation_spearman"
#> 
#> [[28]]$method
#> [1] "correlation_spearman"
#> 
#> [[28]]$alpha
#> [1] 0.05
#> 
#> [[28]]$family
#> [1] "correlation"
#> 
#> [[28]]$roles
#> list()
#> 
#> [[28]]$options
#> list()
#> 
#> [[28]]$decision_rule
#> [1] "Report rho, sample size, and p value."
#> 
#> [[28]]$interpretation
#> [1] "Report rho, sample size, and p value."
#> 
#> [[28]]$citations
#> character(0)
#> 
#> [[28]]$reporting_references
#> character(0)
#> 
#> [[28]]$status
#> [1] "valid_plan"
#> 
#> [[28]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[29]]
#> [[29]]$id
#> [1] "rq_kendall"
#> 
#> [[29]]$research_question
#> [1] "Is sustainability perception associated with behavioural intention?"
#> 
#> [[29]]$variables
#> [1] "sustainability"        "behavioural_intention"
#> 
#> [[29]]$test
#> [1] "correlation_kendall"
#> 
#> [[29]]$method
#> [1] "correlation_kendall"
#> 
#> [[29]]$alpha
#> [1] 0.05
#> 
#> [[29]]$family
#> [1] "correlation"
#> 
#> [[29]]$roles
#> list()
#> 
#> [[29]]$options
#> list()
#> 
#> [[29]]$decision_rule
#> [1] "Report tau, sample size, and p value."
#> 
#> [[29]]$interpretation
#> [1] "Report tau, sample size, and p value."
#> 
#> [[29]]$citations
#> character(0)
#> 
#> [[29]]$reporting_references
#> character(0)
#> 
#> [[29]]$status
#> [1] "valid_plan"
#> 
#> [[29]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[30]]
#> [[30]]$id
#> [1] "rq_partial"
#> 
#> [[30]]$research_question
#> [1] "Is digital marketing associated with behavioural intention after controlling for satisfaction?"
#> 
#> [[30]]$test
#> [1] "partial_correlation"
#> 
#> [[30]]$method
#> [1] "partial_correlation"
#> 
#> [[30]]$alpha
#> [1] 0.05
#> 
#> [[30]]$family
#> [1] "correlation"
#> 
#> [[30]]$roles
#> [[30]]$roles$predictor
#> [[30]]$roles$predictor[[1]]
#> [1] "digital_marketing"
#> 
#> 
#> [[30]]$roles$outcome
#> [[30]]$roles$outcome[[1]]
#> [1] "behavioural_intention"
#> 
#> 
#> [[30]]$roles$control
#> [[30]]$roles$control[[1]]
#> [1] "satisfaction"
#> 
#> 
#> 
#> [[30]]$options
#> list()
#> 
#> [[30]]$decision_rule
#> [1] "Report partial r, degrees of freedom, and p value."
#> 
#> [[30]]$interpretation
#> [1] "Report partial r, degrees of freedom, and p value."
#> 
#> [[30]]$citations
#> character(0)
#> 
#> [[30]]$reporting_references
#> character(0)
#> 
#> [[30]]$status
#> [1] "valid_plan"
#> 
#> [[30]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[31]]
#> [[31]]$id
#> [1] "rq_logit_bin"
#> 
#> [[31]]$research_question
#> [1] "Do digital marketing and service quality perceptions predict visitor type?"
#> 
#> [[31]]$variables
#> [1] "digital_marketing" "service_quality"   "visit_type"       
#> 
#> [[31]]$test
#> [1] "regression_logistic_binary"
#> 
#> [[31]]$method
#> [1] "regression_logistic_binary"
#> 
#> [[31]]$alpha
#> [1] 0.05
#> 
#> [[31]]$family
#> [1] "regression"
#> 
#> [[31]]$roles
#> list()
#> 
#> [[31]]$options
#> list()
#> 
#> [[31]]$decision_rule
#> [1] "Report odds ratios with 95 per cent confidence intervals and Nagelkerke R-squared."
#> 
#> [[31]]$interpretation
#> [1] "Report odds ratios with 95 per cent confidence intervals and Nagelkerke R-squared."
#> 
#> [[31]]$citations
#> character(0)
#> 
#> [[31]]$reporting_references
#> character(0)
#> 
#> [[31]]$status
#> [1] "valid_plan"
#> 
#> [[31]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[32]]
#> [[32]]$id
#> [1] "rq_logit_ord"
#> 
#> [[32]]$research_question
#> [1] "Do digital marketing and sustainability perceptions predict ordered satisfaction?"
#> 
#> [[32]]$variables
#> [1] "digital_marketing" "sustainability"    "sat_1"            
#> 
#> [[32]]$test
#> [1] "regression_logistic_ordinal"
#> 
#> [[32]]$method
#> [1] "regression_logistic_ordinal"
#> 
#> [[32]]$alpha
#> [1] 0.05
#> 
#> [[32]]$family
#> [1] "regression"
#> 
#> [[32]]$roles
#> [[32]]$roles$predictors
#> [[32]]$roles$predictors[[1]]
#> [1] "digital_marketing"
#> 
#> [[32]]$roles$predictors[[2]]
#> [1] "sustainability"
#> 
#> 
#> [[32]]$roles$outcome
#> [[32]]$roles$outcome[[1]]
#> [1] "sat_1"
#> 
#> 
#> 
#> [[32]]$options
#> list()
#> 
#> [[32]]$decision_rule
#> [1] "Report proportional odds ratios and model fit indices."
#> 
#> [[32]]$interpretation
#> [1] "Report proportional odds ratios and model fit indices."
#> 
#> [[32]]$citations
#> character(0)
#> 
#> [[32]]$reporting_references
#> character(0)
#> 
#> [[32]]$status
#> [1] "valid_plan"
#> 
#> [[32]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[33]]
#> [[33]]$id
#> [1] "rq_moderation"
#> 
#> [[33]]$research_question
#> [1] "Does visitor type moderate the relationship between digital marketing and satisfaction?"
#> 
#> [[33]]$test
#> [1] "moderation"
#> 
#> [[33]]$method
#> [1] "moderation"
#> 
#> [[33]]$alpha
#> [1] 0.05
#> 
#> [[33]]$family
#> [1] "regression"
#> 
#> [[33]]$roles
#> [[33]]$roles$predictor
#> [[33]]$roles$predictor[[1]]
#> [1] "digital_marketing"
#> 
#> 
#> [[33]]$roles$moderator
#> [[33]]$roles$moderator[[1]]
#> [1] "service_quality"
#> 
#> 
#> [[33]]$roles$outcome
#> [[33]]$roles$outcome[[1]]
#> [1] "satisfaction"
#> 
#> 
#> 
#> [[33]]$options
#> list()
#> 
#> [[33]]$decision_rule
#> [1] "Report the interaction coefficient, p value, and simple slopes."
#> 
#> [[33]]$interpretation
#> [1] "Report the interaction coefficient, p value, and simple slopes."
#> 
#> [[33]]$citations
#> character(0)
#> 
#> [[33]]$reporting_references
#> character(0)
#> 
#> [[33]]$status
#> [1] "valid_plan"
#> 
#> [[33]]$requires_data
#> [1] TRUE
#> 
#> 
#> [[34]]
#> [[34]]$id
#> [1] "rq_mediation"
#> 
#> [[34]]$research_question
#> [1] "Does satisfaction mediate the path from digital marketing to behavioural intention?"
#> 
#> [[34]]$test
#> [1] "mediation"
#> 
#> [[34]]$method
#> [1] "mediation"
#> 
#> [[34]]$alpha
#> [1] 0.05
#> 
#> [[34]]$family
#> [1] "regression"
#> 
#> [[34]]$roles
#> [[34]]$roles$x
#> [[34]]$roles$x[[1]]
#> [1] "digital_marketing"
#> 
#> 
#> [[34]]$roles$mediator
#> [[34]]$roles$mediator[[1]]
#> [1] "satisfaction"
#> 
#> 
#> [[34]]$roles$y
#> [[34]]$roles$y[[1]]
#> [1] "behavioural_intention"
#> 
#> 
#> 
#> [[34]]$options
#> list()
#> 
#> [[34]]$decision_rule
#> [1] "Report direct, indirect, and total effects with bootstrap confidence intervals."
#> 
#> [[34]]$interpretation
#> [1] "Report direct, indirect, and total effects with bootstrap confidence intervals."
#> 
#> [[34]]$citations
#> character(0)
#> 
#> [[34]]$reporting_references
#> character(0)
#> 
#> [[34]]$status
#> [1] "valid_plan"
#> 
#> [[34]]$requires_data
#> [1] TRUE
#> 
#> 
```
