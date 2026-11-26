# Plan, run and report survey research

Design your questionnaire, plan your analysis and prepare an APA 7
report. Work visually in SurveyStudio or use R.

For people conducting, supervising, reviewing or planning survey
research.

[Explore templates](https://surveyframe.org/articles/templates.md) [Get
started](https://surveyframe.org/articles/start.md)

SurveyStudio opens through R. The [setup
guide](https://surveyframe.org/articles/start.md) explains installing
the required software and opening your first study.

[![CRAN
status](https://www.r-pkg.org/badges/version/surveyframe)](https://CRAN.R-project.org/package=surveyframe)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/grand-total/surveyframe)](https://CRAN.R-project.org/package=surveyframe)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Conducting a survey for your studies?

Plan your research, create your questionnaire, analyse responses and
prepare your report. [Guidance for survey
students](https://surveyframe.org/articles/learn/for-students.md)

## Supervising students conducting survey research?

Review each student’s analysis plan, compare it with the completed
report and follow recorded amendments and their reasons. [Guidance for
supervisors](https://surveyframe.org/articles/learn/for-supervisors.md)

## Reviewing a survey study as an ethics committee?

Examine the proposed study documentation, then review the completed
study and its recorded changes. [Guidance for ethics
committees](https://surveyframe.org/articles/learn/for-ethics-committees.md)

## Planning survey research for an NGO or research organisation?

Prepare a pre-analysis plan and keep the questionnaire, analysis
decisions and reporting connected. [Guidance for NGOs and research
organisations](https://surveyframe.org/articles/learn/for-research-organisations.md)

## Keep your questionnaire and analysis plan connected

Save your questions, scoring rules, analysis plan and references in a
portable `.sframe` file. Collect responses using your chosen setup,
check their quality and prepare a report that presents the planned
analyses alongside the results and your interpretation.

Record later changes with their reasons so readers can follow the
study’s development.

**Plan your study before collecting responses.** Record your research
questions, hypotheses and analysis choices alongside the questionnaire.
[How to write the analysis
plan](https://surveyframe.org/articles/learn/analysis-plan.md).

**Move from responses to a research report.** Check the collected
responses, run the planned analyses and prepare APA 7 tables, figures
and references for supported methods. [See the report
stage](https://surveyframe.org/articles/run-a-study-in-surveystudio.html#report).

**Keep a record of your research design.** Preserve the questionnaire
version, sources and disclosed amendments with the design file. [Verify
a `.sframe` file](https://surveyframe.org/verify/) to check that it
matches the hash recorded when it was saved.

For example, start with the [course evaluation
survey](https://surveyframe.org/articles/templates/course-evaluation-survey.md),
plan how you will summarise the ratings, collect responses and prepare a
report for the teaching team. It is an example to adapt to your own
course and questions.

## Start from a template

Each template holds a questionnaire and an example analysis plan to
adapt to your own study.

**Psychology and measurement.** [Likert scale
questionnaire](https://surveyframe.org/articles/templates/likert-scale-questionnaire.md),
[Measurement model questionnaire (CFA and
SEM)](https://surveyframe.org/articles/templates/measurement-model-questionnaire.md).

**Education.** [Course evaluation
survey](https://surveyframe.org/articles/templates/course-evaluation-survey.md),
[Training evaluation before and
after](https://surveyframe.org/articles/templates/training-evaluation-before-and-after.md).

**Business.** [Customer satisfaction
survey](https://surveyframe.org/articles/templates/customer-satisfaction-survey.md),
[Employee engagement
survey](https://surveyframe.org/articles/templates/employee-engagement-survey.md),
[Supplier and venue selection (decision
making)](https://surveyframe.org/articles/templates/supplier-and-venue-selection.md).

**Events and tourism.** [Open-ended feedback
survey](https://surveyframe.org/articles/templates/open-ended-feedback-survey.md).

**Research methods.** [Pilot survey with a small
sample](https://surveyframe.org/articles/templates/pilot-survey-small-sample.md),
[Preparing a survey study for
preregistration](https://surveyframe.org/articles/templates/pre-registered-survey-sealed-and-amended.md).

[All questionnaire
templates](https://surveyframe.org/articles/templates.md)

## How a study runs

1.  **Design** the questionnaire and write the analysis plan, with
    hypotheses and decision rules, before collecting responses.
2.  **Collect** responses with a survey web page, stored where you
    choose, such as a Google Sheet you own.
3.  **Check** responses for failed attention checks, speeding, identical
    answers across a scale and missing answers.
4.  **Analyse** the responses with the plan as written. A later change
    is recorded as an amendment with its reason.
5.  **Report** in APA 7, as HTML, Word, PDF or OpenDocument.

[Run a study in
SurveyStudio](https://surveyframe.org/articles/run-a-study-in-surveystudio.md)
shows each stage by point and click, and [Run a study in
R](https://surveyframe.org/articles/run-a-study-in-r.md) shows the same
stages in R.

Already use R? Open a first study from the Console

``` r

install.packages("surveyframe")
library(surveyframe)
d <- sframe_demo("first_survey")
```

Then read the [R reference](https://surveyframe.org/reference/index.md),
the [worked
examples](https://surveyframe.org/articles/learn-by-example.md) and the
[changelog](https://surveyframe.org/news/index.md).
