# A complete surveyframe workflow

## Purpose

`surveyframe` supports instrument-centred survey research. Each survey
is stored as a typed `sframe` object that you can validate, save, reuse,
link with response data, score, check for data quality, analyse for
reliability and item diagnostics, and pass to reporting or
syntax-generation functions.

The usual workflow is:

1.  Define or load an instrument.
2.  Validate the instrument.
3.  Collect or import response data.
4.  Check response quality.
5.  Score scales.
6.  Run descriptive, reliability, and item diagnostics.
7.  Generate syntax for EFA, CFA, CB-SEM, or PLS-SEM workflows.
8.  Render a reproducible report.

Two demonstration datasets are bundled. The tourism-services demo
supports examples for scale scoring, reliability, reporting, and syntax
generation. The input-types demo illustrates the main survey controls in
the builder, studio, and dashboard.

The tourism-services responses are synthetic. They are shaped around a
digital-marketing and tourism-services questionnaire so the examples
feel like a research workflow, while avoiding real respondent data and
internet access.

## Load the bundled demo instrument

``` r

demo <- sframe_demo_data()
instr <- demo$instrument
responses <- demo$responses

instr
#> <sframe>
#>   Title:      Tourism Services Experience Demo
#>   Version:    0.3.0
#>   Items:      15
#>   Scales:     5
#>   Status:     valid
```

## Inspect the instrument

An `sframe` object stores the questionnaire title, version, items,
choice sets, scales, checks, analysis plans, model specifications, and
rendering hints. Item IDs are important because response data columns
use the same names.

``` r

names(instr)
#> [1] "meta"          "items"         "choices"       "scales"       
#> [5] "branching"     "checks"        "analysis_plan" "models"       
#> [9] "render"

length(instr$items)
#> [1] 15
length(instr$scales)
#> [1] 5

vapply(instr$items[1:5], function(x) x$id, character(1))
#> [1] "visit_type" "dm_1"       "dm_2"       "dm_3"       "sq_1"
vapply(instr$items[1:5], function(x) x$type, character(1))
#> [1] "single_choice" "likert"        "likert"        "likert"       
#> [5] "likert"
```

## Validate the instrument

[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
checks whether the instrument structure is internally consistent. This
should be done before fieldwork, before response import, and before
reports are generated.

``` r

validation <- validate_sframe(instr, strict = FALSE)

validation$valid
#> [1] TRUE
length(validation$problems)
#> [1] 0
```

For a strict workflow, use:

``` r

instr <- validate_sframe(instr)
```

## Read responses

The demo helper already imported the bundled responses. The equivalent
manual call is:

``` r

responses <- read_responses(
  x = demo$responses_path,
  instrument = instr,
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  meta_cols = "started_at"
)

dim(responses)
#> [1] 120  18
head(responses[, 1:6])
#>   respondent_id         submitted_at           started_at visit_type dm_1 dm_2
#> 1          R001 2026-01-15T09:05:35Z 2026-01-15T09:01:23Z first_time    2    3
#> 2          R002 2026-01-15T09:07:10Z 2026-01-15T09:02:46Z first_time    3    3
#> 3          R003 2026-01-15T09:08:45Z 2026-01-15T09:04:09Z first_time    4    5
#> 4          R004 2026-01-15T09:10:20Z 2026-01-15T09:05:32Z     repeat    5    4
#> 5          R005 2026-01-15T09:11:55Z 2026-01-15T09:06:55Z first_time    3    3
#> 6          R006 2026-01-15T09:13:30Z 2026-01-15T09:08:18Z     repeat    5    3
```

## Check missing data

Missing-data checks are useful before scoring scales or running models.

``` r

missing <- missing_data_report(responses, instr)

missing
#> $method
#> [1] "missing_data"
#> 
#> $item_missing
#>              variable missing_n missing_pct valid_n
#> visit_type visit_type         0           0     120
#> dm_1             dm_1         0           0     120
#> dm_2             dm_2         0           0     120
#> dm_3             dm_3         0           0     120
#> sq_1             sq_1         0           0     120
#> sq_2             sq_2         0           0     120
#> sq_3             sq_3         0           0     120
#> sus_1           sus_1         0           0     120
#> sus_2           sus_2         0           0     120
#> sat_1           sat_1         0           0     120
#> sat_2           sat_2         0           0     120
#> bi_1             bi_1         0           0     120
#> bi_2             bi_2         0           0     120
#> attention   attention         0           0     120
#> comments     comments         0           0     120
#> 
#> $respondent_missing
#>     row missing_n missing_pct
#> 1     1         0           0
#> 2     2         0           0
#> 3     3         0           0
#> 4     4         0           0
#> 5     5         0           0
#> 6     6         0           0
#> 7     7         0           0
#> 8     8         0           0
#> 9     9         0           0
#> 10   10         0           0
#> 11   11         0           0
#> 12   12         0           0
#> 13   13         0           0
#> 14   14         0           0
#> 15   15         0           0
#> 16   16         0           0
#> 17   17         0           0
#> 18   18         0           0
#> 19   19         0           0
#> 20   20         0           0
#> 21   21         0           0
#> 22   22         0           0
#> 23   23         0           0
#> 24   24         0           0
#> 25   25         0           0
#> 26   26         0           0
#> 27   27         0           0
#> 28   28         0           0
#> 29   29         0           0
#> 30   30         0           0
#> 31   31         0           0
#> 32   32         0           0
#> 33   33         0           0
#> 34   34         0           0
#> 35   35         0           0
#> 36   36         0           0
#> 37   37         0           0
#> 38   38         0           0
#> 39   39         0           0
#> 40   40         0           0
#> 41   41         0           0
#> 42   42         0           0
#> 43   43         0           0
#> 44   44         0           0
#> 45   45         0           0
#> 46   46         0           0
#> 47   47         0           0
#> 48   48         0           0
#> 49   49         0           0
#> 50   50         0           0
#> 51   51         0           0
#> 52   52         0           0
#> 53   53         0           0
#> 54   54         0           0
#> 55   55         0           0
#> 56   56         0           0
#> 57   57         0           0
#> 58   58         0           0
#> 59   59         0           0
#> 60   60         0           0
#> 61   61         0           0
#> 62   62         0           0
#> 63   63         0           0
#> 64   64         0           0
#> 65   65         0           0
#> 66   66         0           0
#> 67   67         0           0
#> 68   68         0           0
#> 69   69         0           0
#> 70   70         0           0
#> 71   71         0           0
#> 72   72         0           0
#> 73   73         0           0
#> 74   74         0           0
#> 75   75         0           0
#> 76   76         0           0
#> 77   77         0           0
#> 78   78         0           0
#> 79   79         0           0
#> 80   80         0           0
#> 81   81         0           0
#> 82   82         0           0
#> 83   83         0           0
#> 84   84         0           0
#> 85   85         0           0
#> 86   86         0           0
#> 87   87         0           0
#> 88   88         0           0
#> 89   89         0           0
#> 90   90         0           0
#> 91   91         0           0
#> 92   92         0           0
#> 93   93         0           0
#> 94   94         0           0
#> 95   95         0           0
#> 96   96         0           0
#> 97   97         0           0
#> 98   98         0           0
#> 99   99         0           0
#> 100 100         0           0
#> 101 101         0           0
#> 102 102         0           0
#> 103 103         0           0
#> 104 104         0           0
#> 105 105         0           0
#> 106 106         0           0
#> 107 107         0           0
#> 108 108         0           0
#> 109 109         0           0
#> 110 110         0           0
#> 111 111         0           0
#> 112 112         0           0
#> 113 113         0           0
#> 114 114         0           0
#> 115 115         0           0
#> 116 116         0           0
#> 117 117         0           0
#> 118 118         0           0
#> 119 119         0           0
#> 120 120         0           0
#> 
#> $patterns
#>           pattern   n percent
#> 1 000000000000000 120       1
#> 
#> $deletion
#> $deletion$listwise_n
#> [1] 120
#> 
#> $deletion$pairwise_n
#> $deletion$pairwise_n$visit_type
#> visit_type       dm_1       dm_2       dm_3       sq_1       sq_2       sq_3 
#>        120        120        120        120        120        120        120 
#>      sus_1      sus_2      sat_1      sat_2       bi_1       bi_2  attention 
#>        120        120        120        120        120        120        120 
#>   comments 
#>        120 
#> 
#> $deletion$pairwise_n$dm_1
#> visit_type       dm_1       dm_2       dm_3       sq_1       sq_2       sq_3 
#>        120        120        120        120        120        120        120 
#>      sus_1      sus_2      sat_1      sat_2       bi_1       bi_2  attention 
#>        120        120        120        120        120        120        120 
#>   comments 
#>        120 
#> 
#> $deletion$pairwise_n$dm_2
#> visit_type       dm_1       dm_2       dm_3       sq_1       sq_2       sq_3 
#>        120        120        120        120        120        120        120 
#>      sus_1      sus_2      sat_1      sat_2       bi_1       bi_2  attention 
#>        120        120        120        120        120        120        120 
#>   comments 
#>        120 
#> 
#> $deletion$pairwise_n$dm_3
#> visit_type       dm_1       dm_2       dm_3       sq_1       sq_2       sq_3 
#>        120        120        120        120        120        120        120 
#>      sus_1      sus_2      sat_1      sat_2       bi_1       bi_2  attention 
#>        120        120        120        120        120        120        120 
#>   comments 
#>        120 
#> 
#> $deletion$pairwise_n$sq_1
#> visit_type       dm_1       dm_2       dm_3       sq_1       sq_2       sq_3 
#>        120        120        120        120        120        120        120 
#>      sus_1      sus_2      sat_1      sat_2       bi_1       bi_2  attention 
#>        120        120        120        120        120        120        120 
#>   comments 
#>        120 
#> 
#> $deletion$pairwise_n$sq_2
#> visit_type       dm_1       dm_2       dm_3       sq_1       sq_2       sq_3 
#>        120        120        120        120        120        120        120 
#>      sus_1      sus_2      sat_1      sat_2       bi_1       bi_2  attention 
#>        120        120        120        120        120        120        120 
#>   comments 
#>        120 
#> 
#> $deletion$pairwise_n$sq_3
#> visit_type       dm_1       dm_2       dm_3       sq_1       sq_2       sq_3 
#>        120        120        120        120        120        120        120 
#>      sus_1      sus_2      sat_1      sat_2       bi_1       bi_2  attention 
#>        120        120        120        120        120        120        120 
#>   comments 
#>        120 
#> 
#> $deletion$pairwise_n$sus_1
#> visit_type       dm_1       dm_2       dm_3       sq_1       sq_2       sq_3 
#>        120        120        120        120        120        120        120 
#>      sus_1      sus_2      sat_1      sat_2       bi_1       bi_2  attention 
#>        120        120        120        120        120        120        120 
#>   comments 
#>        120 
#> 
#> $deletion$pairwise_n$sus_2
#> visit_type       dm_1       dm_2       dm_3       sq_1       sq_2       sq_3 
#>        120        120        120        120        120        120        120 
#>      sus_1      sus_2      sat_1      sat_2       bi_1       bi_2  attention 
#>        120        120        120        120        120        120        120 
#>   comments 
#>        120 
#> 
#> $deletion$pairwise_n$sat_1
#> visit_type       dm_1       dm_2       dm_3       sq_1       sq_2       sq_3 
#>        120        120        120        120        120        120        120 
#>      sus_1      sus_2      sat_1      sat_2       bi_1       bi_2  attention 
#>        120        120        120        120        120        120        120 
#>   comments 
#>        120 
#> 
#> $deletion$pairwise_n$sat_2
#> visit_type       dm_1       dm_2       dm_3       sq_1       sq_2       sq_3 
#>        120        120        120        120        120        120        120 
#>      sus_1      sus_2      sat_1      sat_2       bi_1       bi_2  attention 
#>        120        120        120        120        120        120        120 
#>   comments 
#>        120 
#> 
#> $deletion$pairwise_n$bi_1
#> visit_type       dm_1       dm_2       dm_3       sq_1       sq_2       sq_3 
#>        120        120        120        120        120        120        120 
#>      sus_1      sus_2      sat_1      sat_2       bi_1       bi_2  attention 
#>        120        120        120        120        120        120        120 
#>   comments 
#>        120 
#> 
#> $deletion$pairwise_n$bi_2
#> visit_type       dm_1       dm_2       dm_3       sq_1       sq_2       sq_3 
#>        120        120        120        120        120        120        120 
#>      sus_1      sus_2      sat_1      sat_2       bi_1       bi_2  attention 
#>        120        120        120        120        120        120        120 
#>   comments 
#>        120 
#> 
#> $deletion$pairwise_n$attention
#> visit_type       dm_1       dm_2       dm_3       sq_1       sq_2       sq_3 
#>        120        120        120        120        120        120        120 
#>      sus_1      sus_2      sat_1      sat_2       bi_1       bi_2  attention 
#>        120        120        120        120        120        120        120 
#>   comments 
#>        120 
#> 
#> $deletion$pairwise_n$comments
#> visit_type       dm_1       dm_2       dm_3       sq_1       sq_2       sq_3 
#>        120        120        120        120        120        120        120 
#>      sus_1      sus_2      sat_1      sat_2       bi_1       bi_2  attention 
#>        120        120        120        120        120        120        120 
#>   comments 
#>        120 
#> 
#> 
#> 
#> $scale_missing_rules
#>                scale_id n_items min_valid
#> 1     digital_marketing       3         3
#> 2       service_quality       3         3
#> 3        sustainability       2         2
#> 4          satisfaction       2         2
#> 5 behavioural_intention       2         2
#>                               missing_rule
#> 1 Score when at least 3 item(s) are valid.
#> 2 Score when at least 3 item(s) are valid.
#> 3 Score when at least 2 item(s) are valid.
#> 4 Score when at least 2 item(s) are valid.
#> 5 Score when at least 2 item(s) are valid.
#> 
#> $mcar
#> $mcar$available
#> [1] FALSE
#> 
#> $mcar$warning
#> [1] "Little's MCAR test requires an optional package and was not run."
#> 
#> 
#> $apa
#> [1] "Missing-data diagnostics were computed for 15 variable(s)."
#> 
#> $prompt
#> [1] "Report item and respondent missingness, the missing-data pattern, and the deletion rule used for each analysis."
#> 
#> attr(,"class")
#> [1] "sframe_missing_data_report"
```

## Check response quality

[`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md)
evaluates data quality using the instrument definition. When attention
checks are present, they are checked against the pass values stored in
the instrument.

``` r

quality <- quality_report(
  data = responses,
  instrument = instr,
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  started_at = "started_at"
)

quality
#> Survey Data Quality Report
#>   Respondents:  120
#>   Items:        15
#>   Flagged:      109 (90.8%)
#> 
#> Attention checks:
#>   attention_agree      pass 95%  fail 6
#> 
#> Timing:
#>   Median completion time: 966.0 seconds
#> 
#> Missingness:  0.0% of respondents exceed 20% threshold
```

## Score scales

[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md)
applies the scale definitions in the instrument. This includes item
membership, reverse coding, minimum valid item rules, and the selected
scoring method.

``` r

scored <- score_scales(
  data = responses,
  instrument = instr,
  keep_items = TRUE,
  keep_meta = TRUE
)

scale_names <- vapply(instr$scales, function(x) x$id, character(1))
scale_names
#> [1] "digital_marketing"     "service_quality"       "sustainability"       
#> [4] "satisfaction"          "behavioural_intention"

head(scored[, intersect(scale_names, names(scored)), drop = FALSE])
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

## Descriptive statistics

Descriptive reports can be run on raw items or scored scale columns.

``` r

descriptives_report(
  scored,
  variables = intersect(scale_names, names(scored))
)
#> $method
#> [1] "descriptives"
#> 
#> $variables
#> [1] "digital_marketing"     "service_quality"       "sustainability"       
#> [4] "satisfaction"          "behavioural_intention"
#> 
#> $split_by
#> NULL
#> 
#> $weights
#> NULL
#> 
#> $table
#>                variable group   n valid_n missing_n     mean        sd median
#> 1     digital_marketing   All 120     120         0 3.152778 0.8576517   3.00
#> 2       service_quality   All 120     120         0 3.055556 0.8964432   3.00
#> 3        sustainability   All 120     120         0 3.187500 0.8226379   3.00
#> 4          satisfaction   All 120     120         0 3.291667 1.0443593   3.25
#> 5 behavioural_intention   All 120     120         0 3.100000 1.0504101   3.00
#>        iqr      min max    skewness   kurtosis         se   ci_low  ci_high
#> 1 1.000000 1.000000   5 -0.11828231 -0.1968503 0.07829253 2.997751 3.307805
#> 2 1.333333 1.333333   5  0.14528766 -0.5985009 0.08183369 2.893517 3.217594
#> 3 1.500000 1.500000   5  0.15770066 -0.3405926 0.07509623 3.038802 3.336198
#> 4 1.500000 1.000000   5 -0.03690984 -0.9403399 0.09533652 3.102891 3.480443
#> 5 1.125000 1.000000   5  0.02329631 -0.6542410 0.09588888 2.910130 3.289870
#>   weighted_mean
#> 1            NA
#> 2            NA
#> 3            NA
#> 4            NA
#> 5            NA
#> 
#> $apa
#> [1] "Descriptive statistics were computed for 5 variable(s)."
#> 
#> $prompt
#> [1] "Report central tendency, variability, missingness, and any skewed distributions before inferential tests."
#> 
#> attr(,"class")
#> [1] "sframe_descriptives_report"
```

## Reliability diagnostics

Reliability diagnostics use the scale definitions stored in the
instrument. Cronbach’s alpha and omega require the optional `psych`
package, so this chunk is evaluated only when that package is available.

``` r

reliability <- reliability_report(
  data = responses,
  instrument = instr,
  omega = FALSE
)

reliability
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

## Item diagnostics

[`item_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/item_report.md)
gives item-level diagnostics for scale items. This is useful before
retaining, removing, or rewriting items.

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

## Validity summary from standardised loadings

When a researcher has standardised loadings from CFA or PLS-SEM, the
loadings can be passed to
[`validity_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validity_report.md)
to prepare a compact construct-level validity summary.

``` r

example_loadings <- list(
  digital_marketing = c(dm_1 = .72, dm_2 = .78, dm_3 = .81),
  service_quality = c(sq_1 = .75, sq_2 = .80, sq_3 = .77)
)

validity_report(example_loadings)
#> $method
#> [1] "validity"
#> 
#> $loading_summary
#>           construct item loading
#> 1 digital_marketing dm_1    0.72
#> 2 digital_marketing dm_2    0.78
#> 3 digital_marketing dm_3    0.81
#> 4   service_quality sq_1    0.75
#> 5   service_quality sq_2    0.80
#> 6   service_quality sq_3    0.77
#> 
#> $reliability
#>                           construct composite_reliability       AVE n_items
#> digital_marketing digital_marketing             0.8142739 0.5943000       3
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

## EFA readiness

[`efa_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_report.md)
prepares EFA-readiness checks using the items stored in the instrument.
It should be read as a screening step before estimating and interpreting
factor solutions.

``` r

efa <- efa_report(responses, instr)
#> R was not square, finding R from data
#> Parallel analysis suggests that the number of factors =  4  and the number of components =  4

efa
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

## CFA syntax

[`cfa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_syntax.md)
and
[`cfa_lavaan_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_lavaan_syntax.md)
generate measurement-model syntax from the scale structure in the
instrument. The package does not need `lavaan` to generate syntax.

``` r

cat(cfa_syntax(instr))
#> # lavaan CFA syntax generated by surveyframe
#> # Model: Tourism Services Experience Demo CFA
#> # Recommended fitting option: std.lv = TRUE
#> # Fit with lavaan only when lavaan is installed.
#> 
#> # Digital marketing effectiveness (reflective)
#> digital_marketing =~ dm_1 + dm_2 + dm_3
#> 
#> # Service quality (reflective)
#> service_quality =~ sq_1 + sq_2 + sq_3
#> 
#> # Sustainability perception (reflective)
#> sustainability =~ sus_1 + sus_2
#> 
#> # Tourist satisfaction (reflective)
#> satisfaction =~ sat_1 + sat_2
#> 
#> # Behavioural intention (reflective)
#> behavioural_intention =~ bi_1 + bi_2
```

``` r

cat(cfa_lavaan_syntax(instr, ordered = TRUE))
#> # lavaan CFA syntax generated by surveyframe
#> # Model: Tourism Services Experience Demo CFA
#> # Recommended fitting option: std.lv = TRUE
#> # Ordered-item option: pass ordered = c(...) to lavaan::cfa()
#> # Fit with lavaan only when lavaan is installed.
#> 
#> # Digital marketing effectiveness (reflective)
#> digital_marketing =~ dm_1 + dm_2 + dm_3
#> 
#> # Service quality (reflective)
#> service_quality =~ sq_1 + sq_2 + sq_3
#> 
#> # Sustainability perception (reflective)
#> sustainability =~ sus_1 + sus_2
#> 
#> # Tourist satisfaction (reflective)
#> satisfaction =~ sat_1 + sat_2
#> 
#> # Behavioural intention (reflective)
#> behavioural_intention =~ bi_1 + bi_2
```

## CB-SEM and PLS-SEM syntax

`surveyframe` can also store model definitions and generate syntax for
downstream SEM software. surveyframe generates model syntax. Specialised
packages handle formal model estimation.

``` r

model <- sf_model(
  id = "demo_model",
  label = "Demo structural model",
  type = "cb_sem",
  constructs = list(
    sf_construct("DM", "Digital marketing", c("dm_1", "dm_2", "dm_3")),
    sf_construct("SQ", "Service quality", c("sq_1", "sq_2", "sq_3"))
  ),
  paths = list(
    sf_path("DM", "SQ")
  )
)

model_json(model)
#> {
#>   "id": "demo_model",
#>   "label": "Demo structural model",
#>   "type": "cb_sem",
#>   "engine": "lavaan",
#>   "measurement": {
#>     "constructs": [
#>       {
#>         "id": "DM",
#>         "label": "Digital marketing",
#>         "mode": "reflective",
#>         "items": ["dm_1", "dm_2", "dm_3"],
#>         "weights": null
#>       },
#>       {
#>         "id": "SQ",
#>         "label": "Service quality",
#>         "mode": "reflective",
#>         "items": ["sq_1", "sq_2", "sq_3"],
#>         "weights": null
#>       }
#>     ]
#>   },
#>   "structural": {
#>     "paths": [
#>       {
#>         "from": "DM",
#>         "to": "SQ",
#>         "label": null
#>       }
#>     ],
#>     "covariances": [],
#>     "indirect": []
#>   },
#>   "options": []
#> }
```

``` r

cat(sem_lavaan_syntax(model, instr))
#> # lavaan CB-SEM syntax generated by surveyframe
#> # Model: Demo structural model
#> # Recommended summary option: standardized = TRUE
#> 
#> DM =~ dm_1 + dm_2 + dm_3
#> SQ =~ sq_1 + sq_2 + sq_3
#> 
#> # Structural paths
#> SQ ~ DM
```

``` r

pls_model <- sf_model(
  id = "demo_pls",
  label = "Demo PLS model",
  type = "pls_sem",
  constructs = list(
    sf_construct("DM", "Digital marketing", c("dm_1", "dm_2", "dm_3"), mode = "composite"),
    sf_construct("SQ", "Service quality", c("sq_1", "sq_2", "sq_3"), mode = "composite")
  ),
  paths = list(
    sf_path("DM", "SQ")
  )
)

cat(seminr_syntax(pls_model))
#> # seminr PLS-SEM syntax generated by surveyframe
#> rlang::check_installed("seminr", reason = "to fit PLS-SEM models")
#> measurement_model <- constructs(
#>   composite("DM", multi_items("dm_", 1:3)),
#>   composite("SQ", multi_items("sq_", 1:3))
#> )
#> 
#> structural_model <- relationships(
#>   paths(from = "DM", to = c("SQ"))
#> )
#> 
#> pls_model <- estimate_pls(
#>   data = data,
#>   measurement_model = measurement_model,
#>   structural_model = structural_model
#> )
#> 
#> boot_model <- bootstrap_model(
#>   seminr_model = pls_model,
#>   nboot = 5000,
#>   cores = 1,
#>   seed = 123
#> )
#> 
#> reliability(pls_model)
#> ave(pls_model)
#> htmt(pls_model)
```

## Generate a codebook

The codebook comes from the instrument object, so it stays aligned with
item IDs, item labels, choice sets, and scale membership.

``` r

codebook <- codebook_report(instr)

codebook
#> Codebook: Tourism Services Experience Demo v0.3.0
#>   15 items  |  3 choice sets  |  5 scales
#> 
#> Items:
#>            id
#> 1  visit_type
#> 2        dm_1
#> 3        dm_2
#> 4        dm_3
#> 5        sq_1
#> 6        sq_2
#> 7        sq_3
#> 8       sus_1
#> 9       sus_2
#> 10      sat_1
#> 11      sat_2
#> 12       bi_1
#> 13       bi_2
#> 14  attention
#> 15   comments
#>                                                                  label
#> 1                                                         Visitor type
#> 2                 Digital content helped me discover tourism services.
#> 3           Social media information was useful for planning my visit.
#> 4           Online promotions improved my interest in the destination.
#> 5                             Tourism staff provided reliable service.
#> 6                        The service environment was easy to navigate.
#> 7                             The tourism service met my expectations.
#> 8  The tourism provider communicated sustainability practices clearly.
#> 9                  The visit encouraged responsible tourism behaviour.
#> 10               Overall, I was satisfied with the tourism experience.
#> 11                         The experience was worth the time and cost.
#> 12                   I would recommend this tourism service to others.
#> 13                     I intend to use similar tourism services again.
#> 14                           For quality control, please select Agree.
#> 15                     Optional comments about the tourism experience.
#>             type              scale_id reverse
#> 1  single_choice                         FALSE
#> 2         likert     digital_marketing   FALSE
#> 3         likert     digital_marketing   FALSE
#> 4         likert     digital_marketing   FALSE
#> 5         likert       service_quality   FALSE
#> 6         likert       service_quality   FALSE
#> 7         likert       service_quality   FALSE
#> 8         likert        sustainability   FALSE
#> 9         likert        sustainability   FALSE
#> 10        likert          satisfaction   FALSE
#> 11        likert          satisfaction   FALSE
#> 12        likert behavioural_intention   FALSE
#> 13        likert behavioural_intention   FALSE
#> 14 single_choice                         FALSE
#> 15      textarea                         FALSE
```

## Render a reproducible report

[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
combines the instrument, response data, quality checks, descriptive
summaries, codebook content, and other outputs into an HTML file. Store
the output with the study files.

``` r

render_report(
  instrument = instr,
  data = responses,
  output_file = "surveyframe-demo-report.html",
  include_codebook = TRUE,
  include_quality = TRUE,
  include_missing = TRUE,
  include_descriptives = TRUE,
  include_reliability = TRUE,
  include_models = TRUE
)
```

## GUI workflow

The package has three interactive entry points.

``` r

launch_builder()
launch_studio()
launch_dashboard()
```

Use them as follows:

- [`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md)
  opens the standalone questionnaire builder. It is best for creating or
  editing a `.sframe` file.
- [`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md)
  opens the full workflow interface. It is best for moving from an
  instrument to data checking, scoring, analysis planning, and reports.
- [`launch_dashboard()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard.md)
  opens a read-only response dashboard. It is best after responses have
  already been collected.

For package examples and training, the demo launchers are clearer:

``` r

launch_builder_demo()
launch_studio_demo()
launch_dashboard_demo()
```

## A compact script for a complete study

``` r

library(surveyframe)

instr <- read_sframe("my_survey.sframe")
instr <- validate_sframe(instr)

responses <- read_responses(
  "responses.csv",
  instr,
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  meta_cols = "started_at"
)

quality <- quality_report(responses, instr, respondent_id = "respondent_id")
scored <- score_scales(responses, instr)
reliability <- reliability_report(responses, instr, omega = FALSE)
codebook <- codebook_report(instr)

render_report(
  instrument = instr,
  data = responses,
  output_file = "survey-report.html",
  include_codebook = TRUE,
  include_quality = TRUE,
  include_missing = TRUE,
  include_descriptives = TRUE,
  include_reliability = TRUE
)
```

## Citation and reproducibility

When reporting results, cite the package and keep the `.sframe` file
with the analysis files. The `.sframe` file records the instrument
definition used to read, score, and report the responses.

``` r

citation("surveyframe")
```
