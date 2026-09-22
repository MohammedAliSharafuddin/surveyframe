# Enrich a codebook's items table for display

Replaces `items_table`'s `choice_set` id with the choice set's actual
response options ("1 = Strongly disagree; 2 = Disagree; ...") and its
`scale_id` with the scale's label, so each row of the printed codebook
is self-contained.
[`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md)
itself keeps the raw ids, for joining `items_table` to
`choices_table`/`scales_table` programmatically. This enrichment is for
the rendered document, where a reader should not need to cross-reference
a separate table just to see what "1" means on a scale shared by many
items.

## Usage

``` r
sframe_codebook_items_display(cb)
```

## Arguments

- cb:

  An `sframe_codebook` object from
  [`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md).

## Value

A data.frame, `cb$items_table` with `choice_set` and `scale_id` replaced
by display text.

## See also

[`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md)

## Examples

``` r
demo <- sframe_demo_data()
cb <- codebook_report(demo$instrument)
head(sframe_codebook_items_display(cb))
#>           id                                                      label
#> 1 visit_type                                               Visitor type
#> 2       dm_1       Digital content helped me discover tourism services.
#> 3       dm_2 Social media information was useful for planning my visit.
#> 4       dm_3 Online promotions improved my interest in the destination.
#> 5       sq_1                   Tourism staff provided reliable service.
#> 6       sq_2              The service environment was easy to navigate.
#>            type
#> 1 single_choice
#> 2        likert
#> 3        likert
#> 4        likert
#> 5        likert
#> 6        likert
#>                                                                                           choice_set
#> 1                                           first_time = First-time visitor; repeat = Repeat visitor
#> 2 1 = Strongly disagree; 2 = Disagree; 3 = Neither agree nor disagree; 4 = Agree; 5 = Strongly agree
#> 3 1 = Strongly disagree; 2 = Disagree; 3 = Neither agree nor disagree; 4 = Agree; 5 = Strongly agree
#> 4 1 = Strongly disagree; 2 = Disagree; 3 = Neither agree nor disagree; 4 = Agree; 5 = Strongly agree
#> 5 1 = Strongly disagree; 2 = Disagree; 3 = Neither agree nor disagree; 4 = Agree; 5 = Strongly agree
#> 6 1 = Strongly disagree; 2 = Disagree; 3 = Neither agree nor disagree; 4 = Agree; 5 = Strongly agree
#>                          scale_id reverse required
#> 1                                   FALSE     TRUE
#> 2 Digital marketing effectiveness   FALSE     TRUE
#> 3 Digital marketing effectiveness   FALSE     TRUE
#> 4 Digital marketing effectiveness   FALSE     TRUE
#> 5                 Service quality   FALSE     TRUE
#> 6                 Service quality   FALSE     TRUE
```
