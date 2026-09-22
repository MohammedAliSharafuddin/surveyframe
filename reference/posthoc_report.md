# Post-hoc and pairwise comparison report

Post-hoc and pairwise comparison report

## Usage

``` r
posthoc_report(
  data,
  method = c("anova", "kruskal_wallis", "chi_square", "cochran_q"),
  outcome = NULL,
  group = NULL,
  table_vars = NULL,
  measures = NULL,
  correction = c("holm", "bonferroni", "BH")
)
```

## Arguments

- data:

  A data.frame.

- method:

  Comparison family. Supports `"anova"`, `"kruskal_wallis"`,
  `"chi_square"`, and `"cochran_q"`.

- outcome:

  Outcome variable for group comparisons.

- group:

  Grouping variable for group comparisons.

- table_vars:

  Two categorical variables for chi-square residuals and pairwise
  proportion tests.

- measures:

  Repeated binary measures for pairwise McNemar tests.

- correction:

  Multiple-comparison correction.

## Value

An object of class `sframe_posthoc_report`.

## Examples

``` r
demo <- sframe_demo_data()
pr <- posthoc_report(demo$responses, method = "kruskal_wallis",
                      outcome = "sat_1", group = "visit_type")
pr$tables$pairwise_wilcox
#> 
#>  Pairwise comparisons using Wilcoxon rank sum test with continuity correction 
#> 
#> data:  x[ok] and g[ok] 
#> 
#>        first_time
#> repeat 0.73      
#> 
#> P value adjustment method: holm 
```
