# Launch the surveyframe visual survey builder

Opens the SurveyBuilder, a self-contained HTML application for visual
survey design. The builder runs client-side without an R session or
Shiny server. Save instruments as `.sframe` files from the browser and
load them into R with
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md).

## Usage

``` r
launch_builder(open = TRUE, demo = NULL)
```

## Arguments

- open:

  Logical. When `TRUE` (the default), the builder HTML file is opened in
  the system's default web browser with
  [`utils::browseURL()`](https://rdrr.io/r/utils/browseURL.html). Set to
  `FALSE` to return the file path without opening it, which is useful
  for automated testing.

- demo:

  Optional. A demo name from
  [`sframe_list_demos()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_list_demos.md).
  The builder then opens from a temporary copy with that demo's
  questions, scales and analysis plan already loaded. `"input_types"`
  shows every input type the builder supports.

## Value

The path to the builder HTML file, invisibly: the bundled file, or the
temporary copy when `demo` is given.

## Details

The builder includes a three-mode interface.

- Build:

  An item editor with a persistent inspector panel, drag-to-reorder,
  undo/redo, and autosave to browser localStorage.

- Preview:

  The deployable survey, the page
  [`export_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_survey.md)
  writes with `preview = TRUE` and SurveyStudio's Preview screen shows.
  Answering, required checks and branching run as a respondent sees
  them, and nothing is collected: the collector endpoint and the
  completion redirect are removed.

- Plan:

  A role-based analysis planner with method-specific options, planned
  outputs, reporting references, and decision rules.

The builder includes a pure-JavaScript SHA-256 fallback for browsers or
security policies where `crypto.subtle` is unavailable on `file://`
origins. Saved `.sframe` files can be loaded and validated with
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md).

## See also

[`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md),
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md),
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)

Other Design functions:
[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md),
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md),
[`sframe_attention_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_attention_check.md),
[`sframe_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_branch.md),
[`sframe_choice_set()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_choice_set.md),
[`sframe_conjoint_design()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_conjoint_design.md),
[`sframe_get_study()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_study.md),
[`sframe_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_instrument.md),
[`sframe_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item.md),
[`sframe_sampling_methods()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_sampling_methods.md),
[`sframe_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_scale.md),
[`sframe_validation`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)

## Examples

``` r
# Retrieve the builder path for inspection without opening the browser
path <- launch_builder(open = FALSE)
file.exists(path)
#> [1] TRUE

# The same builder with a demo preloaded
path <- launch_builder(demo = "two_group", open = FALSE)
file.exists(path)
#> [1] TRUE
```
