# Scale reliability and validity

Measurement quality is part of the research design. This vignette works
through the reliability and validity evidence from the published
Thailand digital marketing study (Sharafuddin, Madhavan, and Wangtueai
2024). The reliability and item reports read scale definitions from an
instrument, so they are shown on the bundled tourism demo, a synthetic
companion to the study. The validity summary runs on the loadings the
paper reported, which needs no raw data.

## Reliability from the instrument

[`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md)
reads the scale definitions and reports Cronbach’s alpha and, with the
optional `psych` package, McDonald’s omega. The published study reported
strong reliability for every construct. At the higher-order level the
alpha and composite reliability were 0.828 and 0.883 for digital
marketing effectiveness, 0.792 and 0.906 for service quality, 0.769 and
0.843 for sustainability quality, 0.897 and 0.936 for satisfaction, and
0.921 and 0.950 for behavioural intention.

``` r

demo      <- sframe_demo_data()
instr     <- demo$instrument
responses <- demo$responses

rr <- reliability_report(responses, instr, omega = TRUE)
rel_df <- do.call(rbind, lapply(rr, function(s) data.frame(
  Scale   = paste0(s$label, " (", s$scale_id, ")"),
  Items   = s$n_items,
  N       = s$n,
  Alpha   = if (!is.null(s$alpha))   sprintf("%.2f", s$alpha)   else "n/a",
  Omega_h = if (!is.null(s$omega_h)) sprintf("%.2f", s$omega_h) else "n/a",
  Omega_t = if (!is.null(s$omega_t)) sprintf("%.2f", s$omega_t) else "n/a",
  stringsAsFactors = FALSE)))
kable(rel_df, row.names = FALSE,
      col.names = c("Scale", "Items", "N", "Alpha", "Omega h", "Omega total"),
      align = c("l", "c", "c", "r", "r", "r"),
      caption = "Scale reliability statistics")
```

| Scale | Items | N | Alpha | Omega h | Omega total |
|:---|:--:|:--:|---:|---:|---:|
| Digital marketing effectiveness (digital_marketing) | 3 | 120 | 0.84 | 0.84 | 0.84 |
| Service quality (service_quality) | 3 | 120 | 0.84 | 0.84 | 0.84 |
| Sustainability perception (sustainability) | 2 | 120 | 0.77 | n/a | n/a |
| Tourist satisfaction (satisfaction) | 2 | 120 | 0.82 | n/a | n/a |
| Behavioural intention (behavioural_intention) | 2 | 120 | 0.84 | n/a | n/a |

Scale reliability statistics {.table style="width:100%;"}

## Item diagnostics

Item diagnostics identify sparse items, weak item-total relationships,
and floor or ceiling effects. These are the item-level facts behind a
retention decision.

``` r

demo      <- sframe_demo_data()
instr     <- demo$instrument
responses <- demo$responses

items <- item_report(responses, instr)
first  <- items[[1]]
kable(first$diagnostics, digits = 2,
      caption = paste0("Item diagnostics: ", first$label, " (", first$scale_id, ")"))
```

| item_id | mean |   sd | item_rest_r | floor_pct | ceiling_pct | n_missing |
|:--------|-----:|-----:|------------:|----------:|------------:|----------:|
| dm_1    | 3.14 | 1.00 |       -0.51 |      0.05 |        0.10 |         0 |
| dm_2    | 3.12 | 0.97 |       -0.46 |      0.05 |        0.07 |         0 |
| dm_3    | 3.19 | 1.00 |       -0.51 |      0.06 |        0.08 |         0 |

Item diagnostics: Digital marketing effectiveness (digital_marketing)
{.table}

## EFA readiness

[`efa_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_report.md)
reports the Kaiser-Meyer-Olkin measure and Bartlett’s test as a
screening step before a confirmatory model.

``` r

efa_report(responses, instr)
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

## Convergent validity from the published loadings

This step needs no raw data.
[`validity_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validity_report.md)
computes composite reliability and average variance extracted from
standardised loadings. Feeding the outer loadings reported in the paper
reproduces its convergent validity, which is a direct check of the
measurement model.

``` r

published_loadings <- list(
  DMRE = c(dmre_1 = .815, dmre_2 = .899, dmre_3 = .668, dmre_4 = .838),
  DMAU = c(dmau_1 = .843, dmau_2 = .915, dmau_3 = .920),
  DMEU = c(dmeu_1 = .897, dmeu_2 = .929, dmeu_3 = .932),
  DMPV = c(dmpv_1 = .818, dmpv_2 = .916, dmpv_3 = .900, dmpv_4 = .863),
  DSQA = c(dsqa_1 = .904, dsqa_2 = .920, dsqa_3 = .869),
  DSQT = c(dsqt_1 = .778, dsqt_2 = .883, dsqt_3 = .879, dsqt_4 = .811, dsqt_5 = .713),
  DSUQ = c(dsuq_1 = .780, dsuq_2 = .855, dsuq_3 = .845, dsuq_4 = .551, dsuq_5 = .529),
  TS   = c(ts_1 = .912, ts_2 = .950, ts_3 = .869),
  BI   = c(bi_1 = .937, bi_2 = .911, bi_3 = .940)
)

validity <- validity_report(published_loadings)
kable(validity$reliability, digits = 2,
      caption = "Composite reliability and average variance extracted")
```

|      | construct | composite_reliability |  AVE | n_items |
|:-----|:----------|----------------------:|-----:|--------:|
| BI   | BI        |                  0.95 | 0.86 |       3 |
| DMAU | DMAU      |                  0.92 | 0.80 |       3 |
| DMEU | DMEU      |                  0.94 | 0.85 |       3 |
| DMPV | DMPV      |                  0.93 | 0.77 |       4 |
| DMRE | DMRE      |                  0.88 | 0.66 |       4 |
| DSQA | DSQA      |                  0.93 | 0.81 |       3 |
| DSQT | DSQT      |                  0.91 | 0.66 |       5 |
| DSUQ | DSUQ      |                  0.84 | 0.53 |       5 |
| TS   | TS        |                  0.94 | 0.83 |       3 |

Composite reliability and average variance extracted {.table}

The average variance extracted exceeds 0.5 for every construct, and the
composite reliability exceeds 0.7, so each construct explains more than
half the variance in its items. The sustainability construct sits
lowest, in line with the two weaker items the paper flagged (DSUQ4 and
DSUQ5).

## Discriminant validity

The study assessed discriminant validity in two ways. The
Fornell-Larcker criterion compares the square root of a construct’s AVE
with its correlations with the others. The square roots, 0.810 for
digital marketing effectiveness, 0.910 for service quality, 0.726 for
sustainability quality, 0.911 for satisfaction, and 0.930 for
behavioural intention, each exceeded the off-diagonal correlations. The
Heterotrait-Monotrait ratios were all below the 0.90 threshold, the
highest being 0.766 between ease of use and accessibility. Both results
support discriminant validity.

When construct scores are available,
[`validity_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validity_report.md)
returns the Fornell-Larcker matrix and the HTMT matrix directly.

``` r

validity_report(published_loadings, construct_scores = scored_constructs)
```

## Collinearity

The study reported variance inflation factors below 5 for every
indicator, which indicates no severe multicollinearity.
[`assumption_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/assumption_report.md)
returns variance inflation factors when a regression is specified, which
is shown in the analysing-responses vignette.

## Cautious interpretation

Reliability and validity summaries are diagnostics, not automatic
decisions. Read them with the questionnaire wording, the sampling
context, the construct definitions, and the planned model in view.
