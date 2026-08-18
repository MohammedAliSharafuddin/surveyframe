# Record a disclosed amendment to an instrument

Appends a structured, disclosed-revision entry to an instrument's
amendment log, comparing `previous` against `instrument` to record what
changed and why. This is the path around
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)'s
hash check for *legitimate* revision: a data-entry correction,
bot-response removal, or a documented model respecification. It does not
weaken that check –
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)
still hard-aborts on any edit that never went through `amend_sframe()`.
What it adds is a place for a disclosed change to be recorded inside the
file itself, alongside the content it explains, rather than only in an
email or a lab notebook.

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
  `reason_code`: `data_correction`/`bot_removal` default to
  `"pipeline"`; everything else defaults to `"design"`. Pass explicitly
  to override the default in either direction.

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

Amendments come in two tiers. A `"pipeline"` amendment (data
corrections, bot removal) is expected researcher behaviour and needs
only a reason. A `"design"` amendment (anything touching the analysis
plan or a measurement or structural model) is exactly the kind of
post-hoc change the design-time analysis plan exists to guard against,
so it additionally requires a `deviation_report` describing what changed
in the research question, method, or model and why. `second_signoff` is
optional at either tier; when omitted, the log entry records
`signoff = "none"` rather than leaving the field blank, so the absence
of independent review is visible to anyone auditing the log later.

`previous_hash` and `new_hash` on each entry are a **content**
fingerprint (a SHA-256 over the instrument's substantive fields – items,
choices, scales, branching, checks, analysis plan, models, designs –
with the `hash` and `amendments` fields themselves excluded), not the
`.sframe` file's own integrity hash from
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md).
The two serve different purposes: the file hash (via
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md))
proves the file on disk is byte-identical to what was written; an
amendment's content hash proves what the instrument's substance was
immediately before and after this specific, disclosed change.

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
