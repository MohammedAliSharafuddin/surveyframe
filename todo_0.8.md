# todo_0.8.md — surveyframe v0.8: Provenance part one (SHA Layers 2-3)

Dev-only planning file, tracked on `dev` only. Its name is in `.gitignore`
and `.Rbuildignore`. Companion to `CLAUDE.md` and
`../portfolio-planner/development_instructions/07_v08_v09_implementation.md`
(the provenance guide, revised 2026-07-14 — closer to buildable than the
05/06 guides, but the serialisation notes below still correct it).

Last updated: 2026-07-25. Target CRAN submission: 2027-06-09. Theme:
instrument lifecycle (versioning, review, pilot) and response hashing.

**Cardinal rule (from the guide, still binding): no provenance feature
ships before 0.8, and Layers 2-5 are one contiguous chain across 0.8
and 0.9.** The SSR 6.0 paper (DOI 10.31235/osf.io/jmbv8_v1) cites these
exact function names; confirm alignment before renaming anything.

Anchors verified against `main` 2026-07-25; re-grep before editing.

---

## Source material and its status

The asrda-r repo (MohammedAliSharafuddin/asrda-r) holds the prototype
modules: `instrument_versioning.R` -> `R/sf_version.R`,
`expert_review.R` -> `R/sf_review.R`, `pilot_summary.R` ->
`R/sf_pilot.R` (its bundle/citation/report modules are 0.9). **asrda-r
is not cloned locally as of 2026-07-25**: first step is
`gh repo clone MohammedAliSharafuddin/asrda-r ../asrda-r`, then a
read-through noting every assumption each module makes about its
calling environment. Absorption is copy-and-adapt; asrda-r never
appears in DESCRIPTION.

## Hashing ground truth (verified, all in R/read_write_sframe.R)

- `sframe_serialization_payload(instrument, hash_value)` (line 8) builds
  the serialised list; the hash slot is `list(algo = "sha256", value)`.
- `sframe_canonical_payload(x)` (33) canonicalises for hashing;
  `sframe_hash_payload(payload)` (64) = `as.character(openssl::sha256(...))`
  over canonical JSON; `sframe_hash_value(instrument)` (76) is the
  public entry. There is also a `sframe_legacy_hash_payload()` (70) for
  old files — the version-chain work must not break legacy reads.
- `write_sframe()` (106), `read_sframe(path, validate = TRUE)` (388),
  parse-time checks in `sframe_validate_parsed_payload()` (334).
- Component restore functions (`sframe_restore_item()` 168 and
  neighbours) show the required pattern for restoring any new
  serialised structure.

## Design decision A (owner + lead, before any code): what the version
hash covers

The guide computes `sf_version()`'s hash over the full canonical
payload and also says the version chain is embedded in meta and hashed
by Layer 1. Those two rules are circular: appending version entry N
changes the payload, so entry N+1 hashes different content even when
the instrument itself is untouched, and entry N can never contain its
own hash. Resolve before coding. Recommended resolution:

- The **content hash** (what `sf_version()` stores and what reviews and
  pilots bind to) is computed over the canonical payload **excluding**
  `meta$version_chain`, `meta$reviews`, `meta$pilots` — an
  instrument-content identity that is stable while provenance
  accumulates.
- The **file hash** (Layer 1, unchanged behaviour) still covers
  everything serialised, provenance included, so a tampered chain still
  fails `read_sframe()`.
- Implement as `sframe_content_payload(instrument)` beside
  `sframe_canonical_payload()`, with tests proving: adding a version
  entry leaves the content hash unchanged; editing an item changes it.

Document the decision in the vignette and flag it to the owner for the
SSR 6.0 alignment check.

## Design decision B: where artefacts live

Guide: `sf$meta$version_chain`, `sf$meta$reviews`, `sf$meta$pilots`.
Keep that, and thread it through: `sframe_serialization_payload()`
gains the three fields, `read_sframe()` restores them via new
`sframe_restore_version()` / `sframe_restore_review()` /
`sframe_restore_pilot()` (classed objects re-classed on read, the same
way items are), and `sframe_validate_parsed_payload()` tolerates their
absence (every pre-0.8 file lacks them).

---

## 1. R/sf_version.R — Layer 2

Per the guide's code with corrections:

- `sf_version(instrument, state, parent_hash)` — argument named
  `instrument` (house convention), `sframe_check_instrument()` first,
  states `c("draft", "review", "pilot", "active", "archived")` (the
  guide's prose says "published" in one place and "active" in the code;
  standardise on **active**, matching the 0.9 bundle guide). Hash from
  design decision A. Typed conditions via the house pattern in
  `R/conditions.R` (`sframe_abort_validation()` neighbours; classes
  `sframe_invalid_state`, `sframe_no_version`, `sframe_state_mismatch`
  as in the guide).
- `transition_state(instrument, from, to)` per the guide, plus a
  transition-legality table (draft->review->pilot->active->archived,
  with review->draft and pilot->review allowed as rework loops; anything
  else errors). The guide allows any from/to; tighten it and document.
- `print.sf_version()` per the guide. Add `format()` and `summary()`
  for consistency with the 0.3.2 S3 completeness pass.
- `chain_valid` in the guide only checks nchar == 64; real validation
  (each parent_hash equals the previous hash) belongs in
  `validate_sframe()` (#4) — keep the constructor cheap.

## 2. R/sf_review.R and R/sf_pilot.R

Per the guide with corrections:

- Both take `instrument` first, `sframe_check_instrument()` first, and
  read the current version via the internal `.current_version()` (name
  it `sframe_current_version()`, house prefix, defined once in
  sf_version.R).
- `sf_review()`: validate `recommendation`, validate `date` as ISO
  8601, validate every `item_flags`/`scale_flags` name against the
  instrument's real item and scale ids (abort listing unknown ids —
  the artefact is worthless if it flags items that do not exist).
- `sf_pilot()`: validate `completion_rate` in [0,1], `n_pilot` positive
  integer, `flagged_items` against real item ids, `reliability` names
  against real scale ids.
- Attach helpers `add_review(instrument, review)` /
  `add_pilot(instrument, pilot)` appending to `meta$reviews` /
  `meta$pilots` after checking the artefact's `instrument_hash` matches
  the current content hash (follow the `add_model()` precedent,
  `R/model_layer.R:447`, for the attach-and-return-instrument idiom).
- print/format/summary methods for both classes.

## 3. Response hashing in read_responses() — Layer 3

`read_responses()` (`R/read_responses.R:43`) already handles matrix and
ranking expansion columns before returning. Hash the **returned** frame
(post-processing), not the raw file:

- The guide's `.hash_row(paste(row_vec, collapse = "|"))` via
  `apply(df, 1, ...)` is order- and formatting-fragile (`apply` coerces
  the frame to a character matrix, so numeric formatting and column
  order silently matter). Fix: hash a canonical per-row JSON —
  `jsonlite::toJSON(as.list(row), auto_unbox = TRUE)` with columns
  first sorted by name — implemented once as
  `sframe_hash_response_row()`, documented as the canonical response
  serialisation. Determinism test: same data, shuffled column order,
  same hashes.
- Attach as attributes per the guide: `row_hashes`, `response_hash`
  (sha256 over the concatenated row hashes, in row order),
  `instrument_hash` (from the instrument argument already present),
  `hash_timestamp` (UTC ISO 8601).
- `validate_response_hash(df)` exported per the guide (recompute,
  compare, typed abort `sframe_hash_mismatch` naming the first
  divergent row index; class `sframe_no_hash` when attributes absent).
- Attribute survival is fragile in R (subsetting drops attributes).
  Document loudly: validation applies to the frame as returned;
  a subset/mutated frame fails or loses the hash by design, because
  that is exactly what tamper-evidence means. Add a
  `sframe_rehash_responses()` internal for the studio path if the
  studio mutates frames before analysis (check
  `inst/shiny/app.R` response handling before deciding it is needed).

## 4. validate_sframe() extensions

`R/validate_sframe.R`: two new checks at the end, per the guide —
version-chain link integrity (each entry's parent_hash equals the
previous entry's hash, first entry parent NULL) and artefact binding
(every review/pilot `instrument_hash` matches the content hash of the
version it claims). Errors through `sframe_abort_validation()` with
the chain position in the message. Both checks skip silently when the
meta fields are absent (pre-0.8 files stay valid).

## 5. Round-trip and compatibility tests

- Full lifecycle round-trip: draft -> review (+sf_review) -> pilot
  (+sf_pilot) -> active, write_sframe, read_sframe, classes restored,
  chain validates, content hash stable throughout (decision A test).
- Legacy file test: every `inst/extdata/*.sframe` demo file still reads
  and validates (no version chain present).
- Response hashing: hash determinism, validate pass, single-cell
  corruption fails naming the row, `read_responses()` output for the
  bundled demo CSV carries all four attributes.

## 6. Vignette: vignettes/instrument-lifecycle.Rmd

The guide's 11-step outline is right; keep it. Add a short "what is
hashed" section explaining design decision A in user language. House
rules: WCAG style block, `lang: en-GB`, `fig.alt`, offline knit,
axe-core zero violations.

## 7. Exit checklist

- `sf_version()`, `transition_state()`, `sf_review()`, `sf_pilot()`,
  `add_review()`, `add_pilot()`, `validate_response_hash()` exported,
  documented, print/format/summary methods complete.
- Serialisation: three meta fields serialised, restored, legacy files
  unaffected, `sframe_content_payload()` tested per decision A.
- `validate_sframe()` chain and binding checks live.
- Lifecycle vignette knits clean, axe-core clean.
- `devtools::document()`; full suite; `R CMD check --as-cran`
  0/0/<=1 NOTE; win-builder both flavours; `cran-comments.md`; NEWS.md.
- SSR 6.0 function-name alignment confirmed against the preprint
  (owner review, listed as a named exit item).
- Owner reminders: Ethos Pro's approval workflow builds on these
  artefacts next cycle; 0.9 starts from this chain — do not merge
  anything here that 0.9's `sf_bundle()` contract (see todo_0.9.md)
  would have to undo.

---

## Delegation, model tiering, and token budget

Binding policy per `todo_0.4.md`.

### Build order and agent assignment

- **Lead (Fable/Opus):** clone asrda-r, module read-through notes,
  design decisions A and B with the owner, then implement
  `sframe_content_payload()` + `sf_version()` + serialisation threading
  as the reference diff — the hashing semantics are the release; do not
  delegate them.
- **Agent 1 (Sonnet):** `sf_review()` + `sf_pilot()` + attach helpers +
  S3 methods + tests (pure constructors on top of the landed reference).
- **Agent 2 (Sonnet):** response hashing (#3) + determinism and
  corruption tests. Independent of Agent 1.
- **Agent 3 (Sonnet):** `validate_sframe()` extensions (#4) + legacy
  compatibility tests, after the reference diff lands.
- **Agent 4 (Sonnet):** vignette after #1-#4.
- **Agent 5 (Haiku):** verification sweeps, document runs, the
  extdata legacy-file check, knit checks.

### Model tiering

- **Haiku:** sweeps, mechanical verification.
- **Sonnet:** constructors, response hashing, validation checks,
  vignette — all fully specified above.
- **Opus/Fable:** hashing semantics, serialisation threading, the
  asrda-r read, review of every delegated diff (special attention to
  anything that could change an existing file hash — that is a
  compatibility break, not a refactor).

### Token-saving rules (binding)

The same 6 rules as todo_0.4/todo_0.5. Addition: asrda-r is read once
by the lead; agents receive the module notes, never the repo.
