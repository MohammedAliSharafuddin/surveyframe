# surveyframe: Survey Instrument Workflows for R

surveyframe defines a survey instrument as a first-class R object and
supports a complete workflow from questionnaire design through data
collection, quality checking, scoring, psychometric diagnostics, and
reproducible reporting. The package covers static HTML survey export, an
embeddable Shiny survey module, an interactive response dashboard, a
role-based analysis planner with pre-declared research questions, common
survey statistics with small-sample alternatives (Hodges-Lehmann,
pseudomedian, exact odds-ratio, and Firth logistic regression), multi-
criteria decision analysis (AHP, ANP, DEMATEL, VIKOR, MOORA, SMART,
WASPAS, PROMETHEE, ELECTRE, and TOPSIS), and model syntax planning for
EFA, CFA, CB-SEM, and PLS-SEM.

### Core workflow

1.  **Design** an instrument with
    [`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md)
    or
    [`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md)
    and its component constructors:
    [`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md),
    [`sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_choices.md),
    [`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md),
    [`sf_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_branch.md),
    [`sf_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_check.md).

2.  **Validate and save** with
    [`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
    and
    [`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md).
    [`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
    returns an `sframe_validation` diagnostic rather than the instrument
    itself. Recover a validated instrument with
    [`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md).

3.  **Deploy** a Shiny survey with
    [`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md).

4.  **Load responses** with
    [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
    or
    [`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md).

5.  **Check quality** with
    [`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md).

6.  **Score and analyse** with
    [`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md),
    [`descriptives_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/descriptives_report.md),
    [`missing_data_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/missing_data_report.md),
    [`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md),
    [`item_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/item_report.md),
    [`efa_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_report.md),
    [`cfa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_syntax.md),
    and
    [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
    which also runs any decision-analysis blocks in the plan.

7.  **Report** with
    [`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md),
    [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md),
    and
    [`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md).

### The instrument object

The workflow runs on an `sframe` object. It is the single source of
truth for item definitions, scale structure, reverse-coding keys,
branching rules, check specifications, analysis plans, and optional
model specifications. Accessors such as
[`sf_meta()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_meta.md),
[`sf_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_items.md),
[`sf_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scales.md),
[`sf_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_plan.md),
and
[`sf_models()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_models.md)
read its parts without reaching into the object directly.

Some helpers work on plain vectors, for use beside that workflow or on
their own: the text helpers such as
[`term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/term_frequency.md),
and the interval helpers
[`bootstrap_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/bootstrap_ci.md),
[`cohens_d_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cohens_d_ci.md),
[`cramers_v_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cramers_v_ci.md)
and
[`eta_sq_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/eta_sq_ci.md).

### A first session

[`sframe_demos()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demos.md)
lists 22 worked demos, each one instrument, its responses and the
results surveyframe produced. `sframe_demo("two_group")` loads one, and
`sframe_demo_qmd("two_group")` writes a notebook to edit.
[`vignette("learn-by-example")`](https://mohammedalisharafuddin.github.io/surveyframe/articles/learn-by-example.md)
teaches from the same library.

### How functions are named

Three families, which the prefix tells apart.

- `sf_` builds or reads the instrument object model: the constructors
  [`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md)
  and
  [`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md),
  the accessors
  [`sf_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_items.md)
  and
  [`sf_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_plan.md),
  and the replacement forms such as `sf_plan<-`.

- `sframe_` covers everything the package adds around that object: the
  plots such as
  [`sframe_plot_reliability()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_reliability.md),
  the demo library through
  [`sframe_demos()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demos.md),
  the decision helpers, and the builder's own state.

- The workflow verbs carry no prefix, because they name the step a
  researcher is taking:
  [`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
  [`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md),
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
  [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md),
  and the `_report()` family.

The prefixes group functions; they do not pair them. No name stem
appears under both, so there is no `sframe_` twin of an `sf_` function
to look for.

### File format

Instruments are stored as UTF-8 JSON files with the `.sframe` extension.
Each file includes a SHA-256 integrity hash for reproducibility
auditing.

## See also

Useful links:

- <https://mohammedalisharafuddin.github.io/surveyframe/>

- <https://github.com/MohammedAliSharafuddin/surveyframe>

- Report bugs at
  <https://github.com/MohammedAliSharafuddin/surveyframe/issues>

## Author

**Maintainer**: Mohammed Ali Sharafuddin <mohammedali.page@gmail.com>
([ORCID](https://orcid.org/0000-0001-5247-2964))

Authors:

- Mohammed Ali Sharafuddin <mohammedali.page@gmail.com>
  ([ORCID](https://orcid.org/0000-0001-5247-2964))
