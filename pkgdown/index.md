# Plan, run and report survey research

Design your questionnaire, plan your analysis and prepare an APA 7 report.
Work visually in SurveyStudio or use R.

For people conducting, supervising, reviewing or planning survey research.

<p class="home-actions">
<a class="btn btn-primary" href="articles/templates.html">Explore templates</a>
<a class="btn btn-outline-primary" href="articles/start.html">Get started</a>
</p>

SurveyStudio opens through R. The [setup guide](articles/start.html) explains
installing the required software and opening your first study.

[![CRAN status](https://www.r-pkg.org/badges/version/surveyframe)](https://CRAN.R-project.org/package=surveyframe)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/grand-total/surveyframe)](https://CRAN.R-project.org/package=surveyframe)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Conducting a survey for your studies?

Plan your research, create your questionnaire, analyse responses and prepare
your report.
[Guidance for survey students](articles/learn/for-students.html)

## Supervising students conducting survey research?

Review each student's analysis plan, compare it with the completed report and
follow recorded amendments and their reasons.
[Guidance for supervisors](articles/learn/for-supervisors.html)

## Reviewing a survey study as an ethics committee?

Examine the proposed study documentation, then review the completed study and
its recorded changes.
[Guidance for ethics committees](articles/learn/for-ethics-committees.html)

## Planning survey research for an NGO or research organisation?

Prepare a pre-analysis plan and keep the questionnaire, analysis decisions and
reporting connected.
[Guidance for NGOs and research organisations](articles/learn/for-research-organisations.html)

## Keep your questionnaire and analysis plan connected

Save your questions, scoring rules, analysis plan and references in a portable
`.sframe` file. Collect responses using your chosen setup, check their quality
and prepare a report that presents the planned analyses alongside the results
and your interpretation.

Record later changes with their reasons so readers can follow the study's
development.

**Plan your study before collecting responses.** Record your research
questions, hypotheses and analysis choices alongside the questionnaire.
[How to write the analysis plan](articles/learn/analysis-plan.html).

**Move from responses to a research report.** Check the collected responses,
run the planned analyses and prepare APA 7 tables, figures and references for
supported methods.
[See the report stage](articles/run-a-study-in-surveystudio.html#report).

**Keep a record of your research design.** Preserve the instrument version,
sources and disclosed amendments with the design file.
[Verify a `.sframe` file](https://surveyframe.org/verify/) to check that it
matches the hash recorded when it was saved.

For example, start with the
[course evaluation survey](articles/templates/course-evaluation-survey.html),
plan how you will summarise the ratings, collect responses and prepare a
report for the teaching team. It is an example to adapt to your own course
and questions.

## Start from a template

Each template holds a questionnaire and an example analysis plan to adapt to
your own study.

**Psychology and measurement.**
[Likert scale questionnaire](articles/templates/likert-scale-questionnaire.html),
[Measurement model questionnaire (CFA and SEM)](articles/templates/measurement-model-questionnaire.html).

**Education.**
[Course evaluation survey](articles/templates/course-evaluation-survey.html),
[Training evaluation before and after](articles/templates/training-evaluation-before-and-after.html).

**Business.**
[Customer satisfaction survey](articles/templates/customer-satisfaction-survey.html),
[Employee engagement survey](articles/templates/employee-engagement-survey.html),
[Supplier and venue selection (decision making)](articles/templates/supplier-and-venue-selection.html).

**Events and tourism.**
[Open-ended feedback survey](articles/templates/open-ended-feedback-survey.html).

**Research methods.**
[Pilot survey with a small sample](articles/templates/pilot-survey-small-sample.html),
[Pre-registered survey sealed and amended](articles/templates/pre-registered-survey-sealed-and-amended.html).

[All questionnaire templates](articles/templates.html)

## How a study runs

1. **Design** the questionnaire and write the analysis plan, with hypotheses
   and decision rules, before collecting responses.
2. **Collect** responses with a survey web page, stored where you choose,
   such as a Google Sheet you own.
3. **Check** responses for failed attention checks, speeding, identical
   answers across a scale and missing answers.
4. **Analyse** the responses with the plan as written. A later change is
   recorded as an amendment with its reason.
5. **Report** in APA 7, as HTML, Word, PDF or OpenDocument.

[Run a study in SurveyStudio](articles/run-a-study-in-surveystudio.html) shows
each stage by point and click, and [Run a study in R](articles/run-a-study-in-r.html)
shows the same stages in R.

<details>
<summary>Already use R? Open a first study from the Console</summary>

```r
install.packages("surveyframe")
library(surveyframe)
d <- sframe_demo("first_survey")
```

Then read the [R reference](reference/index.html), the
[worked examples](articles/learn-by-example.html) and the
[changelog](news/index.html).

</details>
