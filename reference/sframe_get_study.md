# The study an instrument serves

Returns the instrument's `study`: the problem statement, the objectives
(each with an `id` such as `"O1"` and its `text`), and the sampling plan
(`population`, `method` from
[`sframe_sampling_methods()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_sampling_methods.md),
`method_other` describing an `"other"` method, and `planned_n`). Set it
with `sframe_instrument(study = )` or by assigning `instrument$study`.
Each plan block may name the objective it serves in its `objective`
field. The study is never shown to respondents, since telling them the
aims can bias their answers.

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

A list with `problem`, `objectives` and `sampling`, each `NULL` when not
declared.

## Details

[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
refuses a malformed study, an objective id used twice and a plan block
naming an objective that does not exist. It notes, without failing, an
objective no research question serves, a research question that names no
objective, and a problem statement over 150 words.

## See also

Other Design functions:
[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md),
[`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md),
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md),
[`sframe_attention_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_attention_check.md),
[`sframe_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_branch.md),
[`sframe_choice_set()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_choice_set.md),
[`sframe_conjoint_design()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_conjoint_design.md),
[`sframe_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_instrument.md),
[`sframe_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item.md),
[`sframe_sampling_methods()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_sampling_methods.md),
[`sframe_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_scale.md),
[`sframe_validation`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)

## Examples

``` r
ins <- sframe_instrument("Study", components = list(sframe_item("q1", "Q?", "text")),
  study = list(problem = "Why do students leave the course?",
               objectives = list(list(id = "O1", text = "Describe the reasons."))))
sframe_get_study(ins)$objectives
#> [[1]]
#> [[1]]$id
#> [1] "O1"
#> 
#> [[1]]$text
#> [1] "Describe the reasons."
#> 
#> 
```
