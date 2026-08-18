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
