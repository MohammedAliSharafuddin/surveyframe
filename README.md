# surveyframe

<!-- badges: start -->
[![R-CMD-check](https://github.com/MohammedAliSharafuddin/surveyframe/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/MohammedAliSharafuddin/surveyframe/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/MohammedAliSharafuddin/surveyframe/branch/main/graph/badge.svg)](https://app.codecov.io/gh/MohammedAliSharafuddin/surveyframe?branch=main)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

**surveyframe** is an end-to-end survey research workflow package for R. The
package is built around one typed object, the `sframe`, which carries the full
survey definition from design through validation, deployment, collection,
quality checks, scoring, psychometric diagnostics, analysis execution, and
reproducible reporting.

## Scope

surveyframe is designed to cover the full life of a survey study inside R:

- typed instrument definition
- validation and `.sframe` serialisation with SHA-256 hashing
- browser-based builder
- Shiny survey rendering
- response loading and quality checks
- scale scoring and psychometric diagnostics
- pre-planned analysis execution
- reproducible HTML reporting

The package does not try to replace specialist modelling packages. `psych`,
`lavaan`, and other downstream tools remain appropriate where the workflow
needs them. surveyframe owns the instrument-centred pipeline.

## Current status

The current v0.2 line includes:

- thirteen item types
- reusable choice sets
- composite scales with reverse coding and weighted scoring
- single-condition branching and attention checks
- Google Sheets helper utilities
- SurveyBuilder and SurveyStudio
- Cronbach alpha, McDonald omega, item diagnostics, EFA readiness, and CFA
  syntax generation
- analysis-plan execution across eight tests with APA-style output
- HTML reporting with instrument hashing for reproducibility

The immediate focus is CRAN hardening rather than adding more surface area.

## Dependency model

The package now keeps hard imports deliberately small:

- `jsonlite`
- `rlang`
- `openssl`

Optional feature packages are loaded only when needed:

- `shiny` for `render_survey()` and `launch_studio()`
- `psych` for `reliability_report()` and `efa_report()`
- `googlesheets4` for `read_sheet_responses()`

Quarto is no longer a hard dependency. If the `quarto` R package and the
Quarto CLI are available locally, `render_report()` can use the bundled `.qmd`
template. If they are not available, surveyframe writes an internal HTML
fallback instead.

## Installation

The package is not yet on CRAN. Install the development version from GitHub:

```r
remotes::install_github("MohammedAliSharafuddin/surveyframe")
```

Install optional packages only for the features you plan to use:

```r
install.packages(c("shiny", "psych", "googlesheets4"))

# Optional for richer report rendering
install.packages("quarto")
```

## Minimal workflow

```r
library(surveyframe)

agree5 <- sf_choices(
  "agree5",
  values = 1:5,
  labels = c("Strongly disagree", "Disagree", "Neutral", "Agree", "Strongly agree")
)

items <- lapply(
  1:3,
  function(i) {
    sf_item(
      paste0("sat_", i),
      paste("Satisfaction item", i),
      type = "likert",
      choice_set = "agree5",
      scale_id = "sat"
    )
  }
)

scale <- sf_scale("sat", "Satisfaction", items = paste0("sat_", 1:3))

instr <- sf_instrument(
  title = "Customer Satisfaction Survey",
  components = c(list(agree5), items, list(scale))
)

instr <- validate_sframe(instr)
write_sframe(instr, "customer_satisfaction.sframe")

responses <- data.frame(
  id = c("r1", "r2", "r3"),
  sat_1 = c(4, 5, 3),
  sat_2 = c(5, 4, 3),
  sat_3 = c(4, 5, 2),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

resp <- read_responses(responses, instr, respondent_id = "id", strict = FALSE)
scored <- score_scales(resp, instr)
render_report(instr, data = resp, output_file = "report.html")
```

## Optional entry points

| Need | Entry point | Optional package |
|---|---|---|
| Visual instrument authoring | `launch_builder()` | none |
| Interactive survey deployment | `render_survey()` | `shiny` |
| Studio workflow shell | `launch_studio()` | `shiny` |
| Reliability and EFA readiness | `reliability_report()`, `efa_report()` | `psych` |
| Google Sheets response import | `read_sheet_responses()` | `googlesheets4` |
| Rich Quarto rendering | `render_report()` with local Quarto install | Quarto CLI |

## CRAN track

The package is being prepared for first submission. Current priorities are:

- keep the hard dependency set minimal
- run clean `R CMD check --as-cran` results across platforms
- replace broad `\\dontrun{}` usage on pure constructor examples with runnable
  examples
- finish the CRAN submission notes and reviewer-facing explanation of the
  bundled builder asset

## Citation

If you use surveyframe in published research, cite the package:

```r
citation("surveyframe")
```

A Journal of Statistical Software paper is planned as the primary methods
citation.

## License

MIT. See `LICENSE` for details.
