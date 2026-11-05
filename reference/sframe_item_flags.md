# Items past the usual cut-offs in a measurement result

Lists the items, or for validity the constructs, whose statistics cross
the cut-off usually applied to them, with the value, the rule, its
source and a ready reason, such as "org_4: loading .21 in RQ3, below
.40". A flag is a prompt to review the item, not a rule to drop it: its
content, wording, reverse keying and the purpose of the model still
decide. Drop an item with
[`sframe_drop_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_drop_items.md)
and record it with
[`amend_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amend_sframe.md).

## Usage

``` r
sframe_item_flags(result, htmt = 0.85, all = FALSE, block = NULL)
```

## Arguments

- result:

  A result of one of the kinds above.

- htmt:

  The HTMT threshold: `0.85` for conceptually distinct constructs (the
  default) or `0.90` for similar ones. The value applied is kept as the
  attribute `htmt_threshold`.

- all:

  If `TRUE`, every row is returned, flagged or not.

- block:

  Character or `NULL`. The plan block named in the reasons. A plan
  result supplies its own.

## Value

A data frame with columns `result_type`, `block`, `group` (the scale,
factor, construct or construct pair), `item`, `statistic`, `value`,
`cutoff`, `direction`, `flagged`, `reason` and `source`.

## Details

The results read, and the rule applied to each:

- a reliability result
  ([`sframe_reliability_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reliability_results.md)):
  alpha if the item is deleted above the scale's alpha. Alpha can rise
  when a scale narrows, so the reason asks for the item-total
  correlation and the wording to be checked too.

- an item result
  ([`sframe_item_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item_results.md)):
  corrected item-total correlation below .30 (Nunnally and Bernstein,
  1994).

- an EFA readiness result
  ([`sframe_efa_readiness_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_efa_readiness_results.md)):
  item sampling adequacy (MSA) below .50 (Kaiser, 1974).

- an EFA solution
  ([`sframe_efa_solution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_efa_solution.md)):
  primary loading below .40 (Hair et al., 2019), and, with 2 or more
  factors, the 2 largest loadings less than .20 apart (Howard, 2016), as
  2 separate reasons.

- a CFA fitted with lavaan, as from the syntax
  [`sframe_syntax_cfa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_cfa.md)
  writes: standardised loading below .50 (Hair et al., 2019).

- a validity result
  ([`sframe_validity_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validity_results.md)):
  AVE below .50 (Fornell and Larcker, 1981), and HTMT above `htmt`
  (Henseler et al., 2015).

- a PLS model estimated with seminr: outer loading on the item's own
  construct below .708 (Hair et al., 2022). Below .40 the item is a
  strong removal candidate. From .40 to .708, check AVE and composite
  reliability before removing it.

A result from
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
for one of these methods is read the same way, and its reasons name the
block.

## References

Fornell, C., & Larcker, D. F. (1981). Evaluating structural equation
models with unobservable variables and measurement error. *Journal of
Marketing Research, 18*(1), 39-50.
[doi:10.1177/002224378101800104](https://doi.org/10.1177/002224378101800104)

Hair, J. F., Black, W. C., Babin, B. J., & Anderson, R. E. (2019).
*Multivariate data analysis* (8th ed.). Cengage.

Hair, J. F., Hult, G. T. M., Ringle, C. M., & Sarstedt, M. (2022). *A
primer on partial least squares structural equation modeling (PLS-SEM)*
(3rd ed.). Sage.

Henseler, J., Ringle, C. M., & Sarstedt, M. (2015). A new criterion for
assessing discriminant validity in variance-based structural equation
modeling. *Journal of the Academy of Marketing Science, 43*(1), 115-135.
[doi:10.1007/s11747-014-0403-8](https://doi.org/10.1007/s11747-014-0403-8)

Howard, M. C. (2016). A review of exploratory factor analysis decisions
and overview of current practices. *Journal of Business Research,
69*(1), 51-62.
[doi:10.1016/j.jbusres.2015.08.024](https://doi.org/10.1016/j.jbusres.2015.08.024)

Kaiser, H. F. (1974). An index of factorial simplicity. *Psychometrika,
39*(1), 31-36.
[doi:10.1007/BF02291575](https://doi.org/10.1007/BF02291575)

Nunnally, J. C., & Bernstein, I. H. (1994). *Psychometric theory* (3rd
ed.). McGraw-Hill.

Revelle, W. (2025). *psych: Procedures for psychological, psychometric,
and personality research* (R package). Northwestern University.
<https://CRAN.R-project.org/package=psych>

## See also

Other Amendments functions:
[`amend_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amend_sframe.md),
[`sframe_drop_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_drop_items.md),
[`sframe_get_amendments()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_amendments.md),
[`sframe_link_git_commit()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_link_git_commit.md)

## Examples

``` r
d <- sframe_demo("likert_scale")
if (requireNamespace("psych", quietly = TRUE)) {
  sframe_item_flags(sframe_item_results(d$responses, d$instrument), all = TRUE)
}
#>     result_type block        group  item              statistic     value
#> 1 item_analysis       organisation org_1 corrected_item_total_r 0.6992661
#> 2 item_analysis       organisation org_2 corrected_item_total_r 0.6934233
#> 3 item_analysis       organisation org_3 corrected_item_total_r 0.7429740
#> 4 item_analysis       organisation org_4 corrected_item_total_r 0.6107987
#>   cutoff direction flagged reason                        source
#> 1    0.3     below   FALSE        Nunnally and Bernstein (1994)
#> 2    0.3     below   FALSE        Nunnally and Bernstein (1994)
#> 3    0.3     below   FALSE        Nunnally and Bernstein (1994)
#> 4    0.3     below   FALSE        Nunnally and Bernstein (1994)
```
