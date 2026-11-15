# Launch the surveyframe visual survey builder

Opens the SurveyBuilder, a self-contained HTML application for visual
survey design. The builder runs client-side without an R session or
Shiny server. Save instruments as `.sframe` files from the browser and
load them into R with
[`read_sframe()`](https://surveyframe.org/reference/read_sframe.md).

## Usage

``` r
launch_builder(open = TRUE, demo = NULL, instrument = NULL)
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
  [`sframe_list_demos()`](https://surveyframe.org/reference/sframe_list_demos.md).
  The builder then opens from a temporary copy with that demo's
  questions, scales and analysis plan already loaded. `"input_types"`
  shows every input type the builder supports.

- instrument:

  Optional. An `sframe` instrument. The builder then opens from a
  temporary copy with this instrument loaded, as if it had been opened
  with the builder's Open button, so its study, designs, amendments and
  references are kept on the next save. Supply `demo` or `instrument`,
  not both.

## Value

The path to the builder HTML file, invisibly: the bundled file, or the
temporary copy when `demo` or `instrument` is given.

## Details

The builder includes a 3-mode interface.

- Build:

  An item editor with a persistent inspector panel, drag-to-reorder,
  undo/redo, and autosave to browser localStorage.

- Preview:

  The deployable survey, the page
  [`export_survey()`](https://surveyframe.org/reference/export_survey.md)
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
[`read_sframe()`](https://surveyframe.org/reference/read_sframe.md).

## See also

[`launch_studio()`](https://surveyframe.org/reference/launch_studio.md),
[`read_sframe()`](https://surveyframe.org/reference/read_sframe.md),
[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md)

Other Design functions:
[`as_sframe()`](https://surveyframe.org/reference/as_sframe.md),
[`read_sframe()`](https://surveyframe.org/reference/read_sframe.md),
[`sframe_attention_check()`](https://surveyframe.org/reference/sframe_attention_check.md),
[`sframe_branch()`](https://surveyframe.org/reference/sframe_branch.md),
[`sframe_choice_set()`](https://surveyframe.org/reference/sframe_choice_set.md),
[`sframe_conjoint_design()`](https://surveyframe.org/reference/sframe_conjoint_design.md),
[`sframe_get_study()`](https://surveyframe.org/reference/sframe_get_study.md),
[`sframe_instrument()`](https://surveyframe.org/reference/sframe_instrument.md),
[`sframe_item()`](https://surveyframe.org/reference/sframe_item.md),
[`sframe_sampling_methods()`](https://surveyframe.org/reference/sframe_sampling_methods.md),
[`sframe_scale()`](https://surveyframe.org/reference/sframe_scale.md),
[`sframe_validation`](https://surveyframe.org/reference/sframe_validation.md),
[`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md),
[`write_sframe()`](https://surveyframe.org/reference/write_sframe.md)

## Examples

``` r
# Retrieve the builder path for inspection without opening the browser
path <- launch_builder(open = FALSE)
sframe_show(path)

# The same builder with a demo preloaded
path <- launch_builder(demo = "two_group", open = FALSE)
sframe_show(path)

# Or with an instrument of your own
ins <- sframe_demo("likert_scale", preview = FALSE)$instrument
path <- launch_builder(instrument = ins, open = FALSE)
sframe_show(path)
```
