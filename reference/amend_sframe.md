# Record a disclosed amendment to an instrument

Appends a structured, disclosed-revision entry to an instrument's
amendment log, comparing `previous` against `instrument` to record what
changed and why: a data-entry correction, bot-response removal, or a
documented model respecification. The record is kept inside the file,
beside the content it explains.

## Usage

``` r
amend_sframe(
  previous,
  instrument,
  reason_code,
  reason_text,
  tier = NULL,
  author = NULL,
  deviation_report = NULL,
  second_signoff = NULL,
  version = NULL
)
```

## Arguments

- previous:

  An `sframe` object: the instrument's state before this amendment. Read
  from a file, it must still match that file, or its last recorded
  amendment, so the log starts from a state a file held. An edit made to
  it after reading is refused, and so is one read with `verify = FALSE`
  that failed its integrity check.

- instrument:

  An `sframe` object: the instrument's state after the change this call
  discloses.

- reason_code:

  One of `"data_correction"`, `"bot_removal"`,
  `"model_respecification"`, `"instrument_revision"`, `"other"`.

- reason_text:

  Character. A free-text explanation. Required and must be non-empty
  regardless of `reason_code`.

- tier:

  `"pipeline"` or `"design"`. When `NULL` (the default), inferred from
  `reason_code`: `data_correction` and `bot_removal` default to
  `"pipeline"`, and everything else to `"design"`. A change to the
  analysis plan, a model, a conjoint design or a scale's scoring is
  always `"design"`, and asking for `"pipeline"` on one is an error.

- author:

  Character or `NULL`. Who made the change.

- deviation_report:

  Character or `NULL`. Required when `tier` is `"design"`: what changed
  in the research question, method, or model, and why. Ignored (may be
  `NULL`) for `"pipeline"` amendments.

- second_signoff:

  Character or `NULL`. A second reviewer's name or identifier (an ethics
  board reference, a co-author). When omitted, the entry records
  `signoff = "none"`.

- version:

  Character or `NULL`. The instrument's version after the amendment,
  written to `meta$version` and covered by the recorded content. `NULL`
  keeps the version `instrument` has. When that is still the version of
  `previous`, a message of class `sframe_version_suggestion` suggests
  the next one: the minor number for a design amendment (1.0.0 to
  1.1.0), the patch number for a pipeline amendment (1.0.0 to 1.0.1).

## Value

The amended `sframe` object, with the new entry appended to its
amendment log. Call
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
to persist it.

## Details

[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
refuses to write an instrument read from a file whose content has
changed with no amendment recorded, one that changed after its last
amendment, and one whose amendment log was shortened or reordered.
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)
refuses a file edited on disk without its hash being recomputed. These
checks are local and the hashes are unsigned: someone who rewrites both
a file and its log, and recomputes the hashes, is not detected, and
nothing here establishes who made a change or when.

Amendments come in two tiers. A `"pipeline"` amendment (data
corrections, bot removal) needs only a reason. A `"design"` amendment
also requires a `deviation_report` describing what changed in the
research question, method or model, and why. The tier follows the change
itself: an amendment that changes the analysis plan, a model, a conjoint
design or how a scale is scored (its items, reverse keys, weights,
method or minimum answered) is always design tier, whatever
`reason_code` or `tier` says. So is a change to an item's own `reverse`
or `scale_id`, to the choice codes of an item a scale scores, or to what
an attention check tests and its pass values, since each moves scale
scores or who is flagged. `second_signoff` is optional. When omitted,
the entry records `signoff = "none"`, so the absence of a named reviewer
is visible. The tier, report and signoff are what the author records.
None of them is independent approval.

`previous_hash` and `new_hash` on each entry are a content fingerprint:
a SHA-256 over a canonical serialisation of the instrument, with the
`hash`, `amendments` and `references` fields excluded, taken after
validation, so `new_hash` is the content that is written. It is distinct
from the file's own integrity hash from
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md),
which also covers the amendment log. Both identify content. Neither is
byte identity.

The amendment is sealed when the file is written:
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
hashes the object as it stands then, so a change made to the returned
object before it is written is part of the author's new version, covered
by the file's hash but not by this entry's `new_hash`.

The check that a change read from a file was recorded here rests on an
attribute, `sframe_origin`, which
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)
sets and the package's own functions keep. Base R that builds a new list
from the parts, such as `x[names(x)]`, `c(x)` or
[`lapply()`](https://rdrr.io/r/base/lapply.html) over the fields, drops
it, and the result is written as an instrument read from no file, with
no amendment asked for. See the Revisions section of
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md).

## Wording on the participant's screens

The welcome, consent and thank-you wording lives in `render`, and both
hashes cover `render`, so editing that wording changes the instrument as
much as editing an item does. On a published instrument, record it as a
pipeline-tier amendment with `reason_code = "other"` and a `reason_text`
saying what was reworded, then write the file with
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md).
This is the intended path for a host that lets researchers edit these
screens. A file whose JSON is edited directly fails
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)'s
hash check.

    revised <- instrument
    revised$render$welcome$consent_text <- "I agree to take part."
    revised <- amend_sframe(instrument, revised, "other",
                            "Consent wording shortened", tier = "pipeline")
    write_sframe(revised, "study.sframe", overwrite = TRUE)

## See also

[`sframe_get_amendments()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_amendments.md),
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md),
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)

Other Amendments functions:
[`sframe_drop_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_drop_items.md),
[`sframe_get_amendments()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_amendments.md),
[`sframe_item_flags()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item_flags.md),
[`sframe_link_git_commit()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_link_git_commit.md)

## Examples

``` r
item  <- sframe_item("q1", "How satisfied are you?", type = "text")
instr <- sframe_instrument("Demo", components = list(item))
item2 <- sframe_item("q1", "How satisfied are you overall?", type = "text")
revised <- sframe_instrument("Demo", components = list(item2))
amended <- amend_sframe(
  instr, revised,
  reason_code = "instrument_revision",
  reason_text = "Clarified item wording after a pilot round.",
  deviation_report = "Wording only; no change to the construct measured."
)
#> The version stays 0.1.0. Suggested next version: 0.2.0. A design amendment changes what is measured or analysed, so the minor number moves. Set it with `version = "0.2.0"`.
nrow(sframe_get_amendments(amended))
#> [1] 1
```
