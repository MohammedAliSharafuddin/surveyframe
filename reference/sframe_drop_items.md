# Drop items from scales or models

Takes items out of the named scales or models, and out of any plan block
role that lists them with other variables, such as the item list of a
reliability or factor analysis block. The questions stay in the
instrument and their answers stay in the data. Nothing is recorded:
record the change with
[`amend_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amend_sframe.md),
where a change to how a scale is scored is a design-tier amendment and
needs a deviation report.

## Usage

``` r
sframe_drop_items(instrument, items, from)
```

## Arguments

- instrument:

  An `sframe` object.

- items:

  Character. The item ids to drop.

- from:

  Character. The ids of the scales or models to drop them from.

## Value

The changed `sframe` object, with a message of class
`sframe_drop_items_message` saying what changed.

## Details

A role that names only the dropped item, such as the variable of a
frequency table, keeps it, since that block analyses the item itself. A
scale's reverse keys and weights follow its items, and a dropped item no
longer names the scale (`scale_id`) or carries its reverse flag. A model
drops the item from every construct that measures it.

## See also

[`sframe_item_flags()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item_flags.md)
to find the items past the usual cut-offs,
[`amend_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amend_sframe.md)
to record the drop.

Other Amendments functions:
[`amend_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amend_sframe.md),
[`sframe_get_amendments()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_amendments.md),
[`sframe_item_flags()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item_flags.md),
[`sframe_link_git_commit()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_link_git_commit.md)

## Examples

``` r
ins <- sframe_demo("likert_scale")$instrument
revised <- sframe_drop_items(ins, "org_4", from = "organisation")
#> Dropped org_4 from scale organisation. The questions and their answers stay. Record it with amend_sframe().
revised$scales[[1]]$items
#> [1] "org_1" "org_2" "org_3"
```
