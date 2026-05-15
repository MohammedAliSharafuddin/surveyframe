# Scale reliability and validity

This vignette focuses on measurement-quality checks. The examples use
the tourism-services demo because it has coherent Likert constructs.

``` r

demo <- sframe_demo_data()
instr <- demo$instrument
responses <- demo$responses
```

## Construct-to-item mapping

Scale definitions are stored in the instrument. They define which items
form each construct and how scores should be computed.

``` r

lapply(instr$scales, function(scale) {
  list(
    id = scale$id,
    label = scale$label,
    items = scale$items,
    method = scale$method,
    min_valid = scale$min_valid,
    reverse_items = scale$reverse_items
  )
})
#> [[1]]
#> [[1]]$id
#> [1] "digital_marketing"
#> 
#> [[1]]$label
#> [1] "Digital marketing effectiveness"
#> 
#> [[1]]$items
#> [1] "dm_1" "dm_2" "dm_3"
#> 
#> [[1]]$method
#> [1] "mean"
#> 
#> [[1]]$min_valid
#> NULL
#> 
#> [[1]]$reverse_items
#> NULL
#> 
#> 
#> [[2]]
#> [[2]]$id
#> [1] "service_quality"
#> 
#> [[2]]$label
#> [1] "Service quality"
#> 
#> [[2]]$items
#> [1] "sq_1" "sq_2" "sq_3"
#> 
#> [[2]]$method
#> [1] "mean"
#> 
#> [[2]]$min_valid
#> NULL
#> 
#> [[2]]$reverse_items
#> NULL
#> 
#> 
#> [[3]]
#> [[3]]$id
#> [1] "sustainability"
#> 
#> [[3]]$label
#> [1] "Sustainability perception"
#> 
#> [[3]]$items
#> [1] "sus_1" "sus_2"
#> 
#> [[3]]$method
#> [1] "mean"
#> 
#> [[3]]$min_valid
#> NULL
#> 
#> [[3]]$reverse_items
#> NULL
#> 
#> 
#> [[4]]
#> [[4]]$id
#> [1] "satisfaction"
#> 
#> [[4]]$label
#> [1] "Tourist satisfaction"
#> 
#> [[4]]$items
#> [1] "sat_1" "sat_2"
#> 
#> [[4]]$method
#> [1] "mean"
#> 
#> [[4]]$min_valid
#> NULL
#> 
#> [[4]]$reverse_items
#> NULL
#> 
#> 
#> [[5]]
#> [[5]]$id
#> [1] "behavioural_intention"
#> 
#> [[5]]$label
#> [1] "Behavioural intention"
#> 
#> [[5]]$items
#> [1] "bi_1" "bi_2"
#> 
#> [[5]]$method
#> [1] "mean"
#> 
#> [[5]]$min_valid
#> NULL
#> 
#> [[5]]$reverse_items
#> NULL
```

## Reverse coding and minimum valid item rules

[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md)
applies reverse coding and minimum valid item rules before returning
scale scores.

``` r

scored <- score_scales(
  responses,
  instr,
  keep_items = TRUE,
  keep_meta = TRUE
)

scale_ids <- vapply(instr$scales, function(scale) scale$id, character(1))
head(scored[, intersect(scale_ids, names(scored)), drop = FALSE])
#>   digital_marketing service_quality sustainability satisfaction
#> 1          2.666667        3.666667            5.0          3.5
#> 2          3.000000        2.666667            3.0          1.5
#> 3          4.666667        3.333333            3.5          4.5
#> 4          4.333333        4.000000            5.0          4.5
#> 5          3.000000        3.666667            4.0          3.0
#> 6          3.666667        3.666667            2.5          3.5
#>   behavioural_intention
#> 1                   4.5
#> 2                   2.5
#> 3                   2.5
#> 4                   5.0
#> 5                   3.5
#> 6                   3.0
```

## Reliability

Cronbach’s alpha and omega use the optional `psych` package. Interpret
these statistics together with item wording, dimensionality, and study
design.

``` r

alpha_only <- reliability_report(
  responses,
  instr,
  omega = FALSE
)

alpha_only
#> Reliability Report
#> 
#> Scale: digital_marketing (Digital marketing effectiveness)
#>   Items: 3   N: 120
#>   Alpha:   0.837
#> 
#> Scale: service_quality (Service quality)
#>   Items: 3   N: 120
#>   Alpha:   0.844
#> 
#> Scale: sustainability (Sustainability perception)
#>   Items: 2   N: 120
#>   Alpha:   0.772
#> 
#> Scale: satisfaction (Tourist satisfaction)
#>   Items: 2   N: 120
#>   Alpha:   0.816
#> 
#> Scale: behavioural_intention (Behavioural intention)
#>   Items: 2   N: 120
#>   Alpha:   0.844
```

``` r

omega_report <- reliability_report(
  responses,
  instr,
  alpha = FALSE,
  omega = TRUE
)
#> Loading required namespace: GPArotation
#> Omega_h for 1 factor is not meaningful, just omega_t
#> Warning in schmid(m, nfactors, fm, digits, rotate = rotate, n.obs = n.obs, :
#> Omega_h and Omega_asymptotic are not meaningful with one factor
#> Warning in cov2cor(t(w) %*% r %*% w): diag(V) had non-positive or NA entries;
#> the non-finite result may be dubious
#> Omega_h for 1 factor is not meaningful, just omega_t
#> Warning in schmid(m, nfactors, fm, digits, rotate = rotate, n.obs = n.obs, :
#> Omega_h and Omega_asymptotic are not meaningful with one factor
#> Warning in schmid(m, nfactors, fm, digits, rotate = rotate, n.obs = n.obs, :
#> diag(V) had non-positive or NA entries; the non-finite result may be dubious
#> Omega_h for 1 factor is not meaningful, just omega_t
#> Warning in schmid(m, nfactors, fm, digits, rotate = rotate, n.obs = n.obs, :
#> Omega_h and Omega_asymptotic are not meaningful with one factor
#> Warning in schmid(m, nfactors, fm, digits, rotate = rotate, n.obs = n.obs, :
#> diag(V) had non-positive or NA entries; the non-finite result may be dubious
#> Omega_h for 1 factor is not meaningful, just omega_t
#> Warning in schmid(m, nfactors, fm, digits, rotate = rotate, n.obs = n.obs, :
#> Omega_h and Omega_asymptotic are not meaningful with one factor
#> Warning in schmid(m, nfactors, fm, digits, rotate = rotate, n.obs = n.obs, :
#> diag(V) had non-positive or NA entries; the non-finite result may be dubious
#> Omega_h for 1 factor is not meaningful, just omega_t
#> Warning in schmid(m, nfactors, fm, digits, rotate = rotate, n.obs = n.obs, :
#> Omega_h and Omega_asymptotic are not meaningful with one factor
#> Warning in schmid(m, nfactors, fm, digits, rotate = rotate, n.obs = n.obs, :
#> diag(V) had non-positive or NA entries; the non-finite result may be dubious

omega_report
#> Reliability Report
#> 
#> Scale: digital_marketing (Digital marketing effectiveness)
#>   Items: 3   N: 120
#>   Omega h: 0.837
#>   Omega t: 0.837
#> 
#> Scale: service_quality (Service quality)
#>   Items: 3   N: 120
#>   Omega h: 0.845
#>   Omega t: 0.845
#> 
#> Scale: sustainability (Sustainability perception)
#>   Items: 2   N: 120
#>   Omega h: 0.773
#>   Omega t: 0.773
#> 
#> Scale: satisfaction (Tourist satisfaction)
#>   Items: 2   N: 120
#>   Omega h: 0.817
#>   Omega t: 0.817
#> 
#> Scale: behavioural_intention (Behavioural intention)
#>   Items: 2   N: 120
#>   Omega h: 0.844
#>   Omega t: 0.844
```

## Item diagnostics

Item diagnostics help identify sparse items, poor item-total
relationships, and floor or ceiling issues.

``` r

items <- item_report(responses, instr)

names(items)
#> [1] "digital_marketing"     "service_quality"       "sustainability"       
#> [4] "satisfaction"          "behavioural_intention"
items[[1]]
#> $scale_id
#> [1] "digital_marketing"
#> 
#> $label
#> [1] "Digital marketing effectiveness"
#> 
#> $diagnostics
#>   item_id     mean        sd item_rest_r  floor_pct ceiling_pct n_missing
#> 1    dm_1 3.141667 0.9982828  -0.5118417 0.05000000  0.10000000         0
#> 2    dm_2 3.125000 0.9663455  -0.4619588 0.05000000  0.07500000         0
#> 3    dm_3 3.191667 0.9982828  -0.5122414 0.05833333  0.08333333         0
```

## EFA readiness

[`efa_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_report.md)
is a screening step. Interpret it alongside item wording, sample size,
theory, and the study context.

``` r

efa_report(responses, instr)
#> R was not square, finding R from data
#> Parallel analysis suggests that the number of factors =  4  and the number of components =  4
#> EFA Readiness Diagnostics
#> 
#>   Items:          12
#>   Complete cases: 120
#>   KMO overall:    0.761
#>   Bartlett chi-sq: 665.84  df: 66  p: 0.0000
#>   Suggested factors (parallel analysis): 4
#>   Planned rotation: oblimin
#> 
#> Note: estimate the EFA solution with a dedicated modelling package.
```

## Validity summary from supplied loadings

When standardised loadings are available from a CFA or PLS-SEM workflow,
they can be summarised with
[`validity_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validity_report.md).

``` r

loadings <- list(
  digital_marketing = c(dm_1 = .72, dm_2 = .78, dm_3 = .81),
  service_quality = c(sq_1 = .75, sq_2 = .80, sq_3 = .77),
  satisfaction = c(sat_1 = .76, sat_2 = .82)
)

validity <- validity_report(loadings)

validity
#> $method
#> [1] "validity"
#> 
#> $loading_summary
#>           construct  item loading
#> 1 digital_marketing  dm_1    0.72
#> 2 digital_marketing  dm_2    0.78
#> 3 digital_marketing  dm_3    0.81
#> 4   service_quality  sq_1    0.75
#> 5   service_quality  sq_2    0.80
#> 6   service_quality  sq_3    0.77
#> 7      satisfaction sat_1    0.76
#> 8      satisfaction sat_2    0.82
#> 
#> $reliability
#>                           construct composite_reliability       AVE n_items
#> digital_marketing digital_marketing             0.8142739 0.5943000       3
#> satisfaction           satisfaction             0.7689749 0.6250000       2
#> service_quality     service_quality             0.8171246 0.5984667       3
#> 
#> $fornell_larcker
#> NULL
#> 
#> $htmt
#> NULL
#> 
#> $inter_construct_correlations
#> NULL
#> 
#> $apa
#> [1] "Construct validity summaries were computed from supplied loadings."
#> 
#> $prompt
#> [1] "Report composite reliability, AVE, Fornell-Larcker, HTMT, and the inter-construct correlation matrix."
#> 
#> attr(,"class")
#> [1] "sframe_validity_report"
```

## Cautious interpretation

Reliability and validity summaries are diagnostics, not automatic
decisions. They should be interpreted with the questionnaire wording,
sampling context, construct definitions, and planned statistical model.
