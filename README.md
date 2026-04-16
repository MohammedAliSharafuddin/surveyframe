# surveyframe

<!-- badges: start -->
[![R-CMD-check](https://github.com/MohammedAliSharafuddin/surveyframe/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/MohammedAliSharafuddin/surveyframe/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/MohammedAliSharafuddin/surveyframe/branch/main/graph/badge.svg)](https://app.codecov.io/gh/MohammedAliSharafuddin/surveyframe?branch=main)
[![CRAN status](https://www.r-pkg.org/badges/version/surveyframe)](https://CRAN.R-project.org/package=surveyframe)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

**surveyframe** defines a survey instrument as a first-class R object and
provides a complete workflow from instrument design through data collection,
quality checking, scoring, psychometric diagnostics, and reproducible
reporting. The **SurveyStudio** interface, launched with `launch_studio()`,
provides a visual shell for the full pipeline.

## The problem it solves

R has excellent tools for survey analysis (`psych`, `lavaan`, `semTools`) and
for survey rendering (`shinysurveys`). What is missing is a package that
connects instrument design to publishable output in one survey-native
workflow, where the instrument itself carries its own structure, scoring
rules, and quality checks through every stage.

surveyframe closes that gap. One `.sframe` file drives everything.

## Installation

```r
# Install from CRAN (once available)
install.packages("surveyframe")

# Or install the development version from GitHub
remotes::install_github("MohammedAliSharafuddin/surveyframe")
```

## A minimal example

```r
library(surveyframe)

# 1. Define
agree5 <- sf_choices("agree5", 1:5,
  c("Strongly disagree", "Disagree", "Neutral", "Agree", "Strongly agree"))

items <- lapply(1:3, function(i)
  sf_item(paste0("sat_", i), paste("Satisfaction item", i),
          type = "likert", choice_set = "agree5", scale_id = "sat"))

scale <- sf_scale("sat", "Satisfaction", items = paste0("sat_", 1:3))

instr <- sf_instrument(
  title      = "Customer Satisfaction Survey",
  components = c(list(agree5), items, list(scale))
)

# 2. Validate and save
instr <- validate_sframe(instr)
write_sframe(instr, "my_survey.sframe")

# 3. Deploy
render_survey(instr)                  # Shiny survey
launch_studio(instrument = instr)     # SurveyStudio interface

# 4. Load and check responses
responses <- read_responses("responses.csv", instr, respondent_id = "id")
qr        <- quality_report(responses, instr, respondent_id = "id")

# 5. Score and measure
scored <- score_scales(responses, instr)
rr     <- reliability_report(responses, instr)
syntax <- cfa_syntax(instr)

# 6. Report
render_report(instr, data = responses, output_file = "report.html")
```

## The workflow

| Stage | Functions |
|---|---|
| Design | `sf_instrument()`, `sf_item()`, `sf_choices()`, `sf_scale()`, `sf_branch()`, `sf_check()` |
| Validate and save | `validate_sframe()`, `write_sframe()`, `read_sframe()` |
| Deploy | `render_survey()`, `launch_studio()` |
| Collect | `read_responses()` |
| Quality | `quality_report()` |
| Score | `score_scales()` |
| Psychometrics | `reliability_report()`, `item_report()`, `efa_report()`, `cfa_syntax()` |
| Report | `codebook_report()`, `render_report()` |

## The .sframe file

Every instrument is saved as a UTF-8 JSON file with a SHA-256 integrity hash.
The file is human-readable, version-control friendly, and portable across
machines and R versions. The hash makes every fielded instrument auditable:
researchers can report the exact instrument hash in their supplementary
materials as a reproducibility record.

## SurveyStudio

`launch_studio()` opens the SurveyStudio interface, a six-screen Shiny
application that wraps the full pipeline visually:

1. Open instrument
2. Preview survey
3. Upload responses
4. Quality dashboard
5. Reliability dashboard
6. Download report

## Citation

If you use surveyframe in published research, please cite the package. A
formal publication is in preparation for the *Journal of Statistical
Software*.

```r
citation("surveyframe")
```

## License

MIT. See `LICENSE` for details.

## Author

Mohammed Ali Sharafuddin
Senior Lecturer, Qasim Ibrahim School of Business, Villa College, Maldives.
Doctoral candidate, PIMSAT Tamil Nadu.
[mas@flairmi.com](mailto:mas@flairmi.com)
