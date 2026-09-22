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
  second_signoff = NULL
)
```

## Arguments

- previous:

  An `sframe` object: the instrument's state before this amendment.

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
  analysis plan, a model or a conjoint design is always `"design"`, and
  asking for `"pipeline"` on one is an error.

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
itself: an amendment that changes the analysis plan, a model or a
conjoint design is always design tier, whatever `reason_code` or `tier`
says. `second_signoff` is optional. When omitted, the entry records
`signoff = "none"`, so the absence of a named reviewer is visible. The
tier, report and signoff are what the author records. None of them is
independent approval.

`previous_hash` and `new_hash` on each entry are a content fingerprint:
a SHA-256 over a canonical serialisation of the instrument, with the
`hash` and `amendments` fields excluded, taken after validation, so
`new_hash` is the content that is written. It is distinct from the
file's own integrity hash from
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md),
which also covers the amendment log. Both identify content. Neither is
byte identity.

## See also

[`amendment_log()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amendment_log.md),
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md),
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)

## Examples

``` r
item  <- sf_item("q1", "How satisfied are you?", type = "text")
instr <- sf_instrument("Demo", components = list(item))
item2 <- sf_item("q1", "How satisfied are you overall?", type = "text")
revised <- sf_instrument("Demo", components = list(item2))
amended <- amend_sframe(
  instr, revised,
  reason_code = "instrument_revision",
  reason_text = "Clarified item wording after a pilot round.",
  deviation_report = "Wording only; no change to the construct measured."
)
nrow(amendment_log(amended))
#> [1] 1
```
