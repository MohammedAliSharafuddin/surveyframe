# Shiny module server for an embedded survey

Draws the survey and collects the respondent's answers. Returns a
`reactive` holding `NULL` until the survey has been submitted and saved.

## Usage

``` r
survey_module_server(id, instrument, on_submit = NULL)
```

## Arguments

- id:

  A character string matching the `id` passed to
  [`survey_module_ui()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_ui.md).

- instrument:

  An `sframe` object, or a `reactive` that returns one.

- on_submit:

  Optional function of one argument, called with the response list
  before the survey is marked complete. Use it to store the response. An
  error it raises is shown to the respondent, and the survey stays open
  for another attempt.

## Value

A `reactive` that returns `NULL` until a response is submitted and
`on_submit`, when supplied, has returned. After that it returns the
response list.

## Supported item types

Every item type is supported, with the same controls
[`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md)
uses: likert, single choice, multiple choice, numeric, text, text area,
date, slider, rating, ranking, matrix, pairwise comparison and criteria
weight, plus section breaks and text blocks.

## What is submitted

The response is a named list. It starts with `response_id`, `started_at`
and `submitted_at`, followed by one element per response column, named
as
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
expects. A multi-column item contributes one element per column:
`item__row` for a matrix, `item__option` for ranking and multiple
choice, and one element per pair or criterion for decision items. Values
are character.

An item hidden by branching is `NA`, so an answer given before branching
hid its item is never submitted. An unanswered item is `NA` too. A
slider counts as answered once the respondent moves it, and a ranking
once the respondent reorders it or chooses "Keep this order". Date
questions start empty.

## Saving, and a failed save

`on_submit` is called with the response before the survey is marked
complete. If it raises an error, the respondent sees a message and stays
on the last page, can submit again, and the returned reactive stays
`NULL`. The thank-you screen appears only after `on_submit` returns.

## Changing the instrument

When `instrument` is a reactive and its value changes, the survey
returns to the welcome screen, the returned reactive goes back to
`NULL`, and no answer given to the previous instrument carries into the
new one.

## See also

[`survey_module_ui()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_ui.md),
[`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md),
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)

## Examples

``` r
# \donttest{
# survey_module_ui() has a complete example, including on_submit.
# }
```
