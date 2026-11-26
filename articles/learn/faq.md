# Frequently asked questions

## Can I use surveyframe for my thesis?

Yes. Start from one of the [questionnaire
templates](https://surveyframe.org/articles/templates.md), replace its
questions with yours, and submit the pre-analysis plan to your
supervisor or ethics committee before you collect data. The report
follows APA 7.

## Can I run the whole study in SurveyStudio?

Yes. After `install.packages("surveyframe")`, everything runs in
SurveyStudio, opened from RStudio’s Addins menu. See [Get
started](https://surveyframe.org/articles/start.md).

## How do I preregister my analysis plan on OSF?

Write the pre-analysis plan from SurveyStudio, or with
[`render_report()`](https://surveyframe.org/reference/render_report.md)
and no data, and upload it to OSF or Zenodo with the `.sframe` file. The
plan names the file’s hash, so the registration identifies the exact
instrument.

## Does planning the analysis first limit creative thinking?

No. Planning first separates what you predicted from what you
discovered, and you keep both. Any analysis you add after the data
arrive still runs, and the report labels its result “Exploratory: no
hypothesis declared before the data”, so a reader sees it as a finding
to test next. If your plan changes after sealing, record the change with
[`amend_sframe()`](https://surveyframe.org/reference/amend_sframe.md).
Each amendment keeps its reason and points to the hash it replaces, and
the [verify page](https://surveyframe.org/verify/) lists it.

The creative work moves earlier, into the questions, the hypotheses and
the design, where a weak idea costs the least to change. You still make
every analytical decision. surveyframe keeps the record of those
decisions, and writes the formatting and the codebook for you.

## How are answers collected?

Export the questionnaire from SurveyStudio’s Collect screen as 1 HTML
file, and choose how to host it, such as on your institution’s web
space. To collect responses in a Google Sheet you own, configure the
Apps Script collector, as the Collect screen’s steps show.

## How does a reader check which questionnaire was used?

Open the `.sframe` file at
[surveyframe.org/verify](https://surveyframe.org/verify/). The page
checks whether the file matches the hash recorded when it was saved, and
shows its recorded amendments. To identify a registered version, compare
the hash with the one in the independently preserved registration, such
as on OSF.

## Are the demo data real?

No. The demos’ responses are simulated. Each respondent id starts with
`DEMO-`, and every result and report made from them says “demonstration
data”.

## How do I cite surveyframe?

See [Cite surveyframe](https://surveyframe.org/articles/cite.md).
