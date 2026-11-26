# The study an instrument serves

Returns the instrument's `study`: the problem statement, the objectives
(each with an `id` such as `"O1"` and its `text`), and the sampling plan
(`population`, `method` from
[`sframe_sampling_methods()`](https://surveyframe.org/reference/sframe_sampling_methods.md),
`method_other` describing an `"other"` method, and `planned_n`), and the
preregistration fields a plan states beyond its blocks
(`preregistration`, with `exclusion_rules`, `stopping_rule`,
`primary_outcomes`, `secondary_outcomes`, `multiplicity` and
`contingency`, each an optional text). The study is inside the hash, so
on a published instrument a change to any of these is a design
amendment, recorded with
[`amend_sframe()`](https://surveyframe.org/reference/amend_sframe.md).
Set it with `sframe_instrument(study = )` or by assigning
`instrument$study`. Each plan block may name the objective it serves in
its `objective` field. The study is never shown to respondents, since
telling them the aims can bias their answers.

## Usage

``` r
sframe_get_study(x, ...)
```

## Arguments

- x:

  An `sframe` object.

- ...:

  Ignored.

## Value

A list with `problem`, `objectives`, `sampling` and `preregistration`,
each `NULL` when not declared.

## Details

[`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md)
refuses a malformed study, an objective id used twice and a plan block
naming an objective that does not exist. It notes, without failing, an
objective no research question serves, a research question that names no
objective, and a problem statement over 150 words.

## See also

Other Design functions:
[`as_sframe()`](https://surveyframe.org/reference/as_sframe.md),
[`launch_builder()`](https://surveyframe.org/reference/launch_builder.md),
[`read_sframe()`](https://surveyframe.org/reference/read_sframe.md),
[`sframe_attention_check()`](https://surveyframe.org/reference/sframe_attention_check.md),
[`sframe_branch()`](https://surveyframe.org/reference/sframe_branch.md),
[`sframe_choice_set()`](https://surveyframe.org/reference/sframe_choice_set.md),
[`sframe_conjoint_design()`](https://surveyframe.org/reference/sframe_conjoint_design.md),
[`sframe_instrument()`](https://surveyframe.org/reference/sframe_instrument.md),
[`sframe_item()`](https://surveyframe.org/reference/sframe_item.md),
[`sframe_sampling_methods()`](https://surveyframe.org/reference/sframe_sampling_methods.md),
[`sframe_scale()`](https://surveyframe.org/reference/sframe_scale.md),
[`sframe_validation`](https://surveyframe.org/reference/sframe_validation.md),
[`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md),
[`write_sframe()`](https://surveyframe.org/reference/write_sframe.md)

## Examples

``` r
ins <- sframe_instrument("Study", components = list(sframe_item("q1", "Q?", "text")),
  study = list(problem = "Why do students leave the course?",
               objectives = list(list(id = "O1", text = "Describe the reasons."))))
sframe_get_study(ins)$objectives
```
