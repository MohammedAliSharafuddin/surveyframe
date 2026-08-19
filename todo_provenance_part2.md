# todo_provenance_part2.md: surveyframe 0.6, provenance SHA layers, part two

> **Renamed 2026-08-20 from `todo_0.8.md`. 0.8 is retired and no longer
> exists.** The 2026-08-19 renumbering merged the former 0.7, 0.8, 0.9,
> and 1.0 into a single terminal release, **0.6**. This file's content
> folds into that release. Its SHA Layers 4 and 5 scope is unchanged and
> still real. Its predecessor is now `todo_provenance_part1.md`, and the
> chain stays contiguous inside the one 0.6 release.

> **Filenames on this branch are themed, not numbered, since 2026-08-20.**
> The numbered names churned 3 times (renumbered 2026-07-30, shifted by
> 0.1 on 2026-08-15, swapped later that same day) and then contradicted
> the 2026-08-19 renumbering outright. A themed name cannot go stale when
> a version moves. The canonical version table lives in
> `../portfolio-planner/CLAUDE.md` and overrides any number written here.

Dev-only planning file, tracked on `dev` only. Its name is in `.gitignore`
and `.Rbuildignore`. Companion to `CLAUDE.md`, `todo_0.7.md` (must be
shipped first — the chain is contiguous), and
`../portfolio-planner/development_instructions/07_v08_v09_implementation.md`
(v0.8 section, including the 2026-07-14 Layer 5 chaining revision).

Last updated: 2026-07-25. Target CRAN submission: 2027-07-24. Theme:
tamper-evident bundles, the Derivative Citation Model, and the sfReport
companion package. The SSR 6.0 paper submits immediately after this
release, then MethodsX (schema) and JOI, in that order.

Anchors verified against `main` 2026-07-25; re-grep before editing.

---

## Non-negotiable design points (settled 2026-07-14, do not reopen)

- **Layer 5 is a hash chain, not a sorted concatenation.** Components
  chain in fixed order (instrument -> responses -> analysis -> report
  -> extras), each step `sha256(prev_hash + component_hash)` seeded
  from `sha256("sframe-manifest-genesis")`. The root encodes sequence.
- `verify_bundle()` returns a named logical vector (per-component drift
  attribution plus `manifest_root`), aborting on failure only when
  `strict = TRUE` (default).
- The Derivative Citation Model ships here: an instrument never carries
  its own DOI; identity is the manifest root hash; the only DOI in
  citation output is the parent package's. Incomplete chains render as
  `[DRAFT]` / NOT FULLY CITABLE, never silently as finished.
- `register_citation()` is **deferred by decision** — external API side
  effects need their own design pass. Not in this release, not in its
  exit checklist.
- The Merkle-root extension is 1.0, not 0.9. Ship the linear chain.

## Verified implementation notes the guide misses

- `openssl::sha256()` returns a hash object; every stored hash must be
  `as.character()`-ed (the existing `sframe_hash_payload()`,
  `R/read_write_sframe.R:64`, shows the pattern). The guide's snippets
  skip this; `identical()` comparisons will fail on raw hash objects.
- **The analysis hash is a trap.** `run_analysis_plan()` results carry
  ggplot objects (`$plot`, `$diagnostic_plots`), classed report objects
  (`$report_obj`), and from 0.6 possibly `$fit` — none serialise
  deterministically through `toJSON(force = TRUE)`, and environments in
  them can differ run to run. Define
  `sframe_analysis_payload(results)`: strips `plot`,
  `diagnostic_plots`, `report_obj`, `fit`, `screening`, keeps the
  statistical content (test, apa, tables coerced to plain lists,
  effect sizes, CIs, options, block ids), canonicalises with the same
  discipline as `sframe_canonical_payload()` (33), and is the
  documented Layer 4 serialisation. Determinism test: two identical
  runs hash identically; `plots = TRUE` vs `FALSE` hash identically.
- Bundle serialisation: decide and document (the guide leaves it open).
  Recommendation: `write_bundle(bundle, path)` / `read_bundle(path)` as
  plain JSON beside the `.sframe`, since a bundle references artefacts
  rather than containing them; the manifest JSON export then lives in
  sfReport per the guide.
- `as_bibtex()` needs a generic — none exists in the package. Export
  `as_bibtex(x, ...)` as a new S3 generic with the sframe method, and
  check no Suggests package already defines a clashing generic.
- The citation key and BibTeX assembly are base R string building;
  `citations.json` uses jsonlite. No new dependencies anywhere in 0.9
  (surveyframe side).

---

## 1. R/sf_bundle.R — sf_bundle() and verify_bundle()

Per the guide's revised code, with the notes above applied:

- `sf_bundle(instrument, responses, analysis_result, report_path =
  NULL, extras = list())`: instrument content hash (0.8 decision A) and
  file hash both recorded; `response_hash` attribute required (typed
  `sframe_no_hash` abort otherwise); analysis hash via
  `sframe_analysis_payload()`; report and extras hashed from file bytes
  (missing extra file aborts, `sframe_missing_file`); chained root per
  the fixed order; timestamp UTC; `surveyframe_version` recorded as
  character.
- Class `sf_bundle`, print/format/summary methods.
- `verify_bundle(bundle, instrument, responses, analysis_result,
  report_path = NULL, extras = list(), strict = TRUE)`: rebuild fresh,
  compare per component, named logical return, strict abort listing
  divergent components. Chain property test: corrupt the instrument
  only, verify that `instrument` AND `manifest_root` report FALSE while
  later component hashes individually still match — this is the
  demonstration the sorted design could not make, and it goes in both
  a test and the vignette.
- `write_bundle()` / `read_bundle()` per the serialisation decision,
  with a round-trip test.

## 2. R/citation_model.R — Derivative Citation Model

- `as_bibtex()` generic + `as_bibtex.sframe(x, format = c("bibtex",
  "biblatex"))`: deterministic key (author + year + first 12 hash
  chars), layer status from the bundle/chain (named logical, the same
  shape `verify_bundle()` returns), `[DRAFT]`/NOT FULLY CITABLE marker
  when incomplete, parent package citation read from the installed
  `inst/CITATION` via `utils::citation("surveyframe")` (the guide says
  CITATION.cff; the R-native source of truth is inst/CITATION — use
  that, and note the divergence for the MethodsX schema text).
  biblatex output links the parent via `related`/`relatedtype =
  "isversionof"`.
- `export_citations(x, path, format = "bibtex")` for a list of
  instruments: dedupe on manifest root hash, parent entry written once,
  and write `citations.json` beside the `.bib` (fields per the guide:
  bibkey, title, hash, lifecycle_stage, layers_verified,
  parent_citation_key, source_file, plus the `deduplicated` array).
  The JSON shape must match the `sframe-schema` repo's citation schema
  — update that repo in the same cycle (exit item).
- Tests: draft vs complete marker, dedupe behaviour, stable keys, valid
  BibTeX parsed back by a regex-level sanity check (no new dependency
  for parsing).

## 3. sfReport — separate CRAN package, separate repo

Not in this source tree. Create `MohammedAliSharafuddin/sfReport` from
the guide's DESCRIPTION sketch (Imports: surveyframe (>= 0.9.0),
quarto, jsonlite, rlang). Its own repo gets its own CLAUDE.md and todo,
seeded from the guide: `sf_report(bundle, output_file, format)` over a
`inst/templates/sf_report.qmd` params-driven template (study metadata,
results tables and figures, defensibility appendix with all five
hashes and the verify command, ASRDA chapter citation block via
`sf_cite_asrda(method_id)` keyed to the method ids in
`sframe_run_one_block()`'s switch), plus `export_manifest(bundle,
path)` writing the guide's manifest JSON. The asrda-r modules
`citation_block.R` and `report_render.R` are its source material
(asrda-r cloned during 0.8). surveyframe 0.9 must not depend on
sfReport in any direction; the vignette uses it under
`skip_if_not_installed`-style guards only.

## 4. Vignette: vignettes/defensible-reporting.Rmd

Per the guide's 8-step outline, including the corruption
demonstration (#1's chain property) and the manifest JSON inspection.
House rules: WCAG style block, `lang: en-GB`, `fig.alt`, offline knit,
axe-core zero violations. sfReport steps guarded so the vignette knits
without it.

## 5. Exit checklist

- `sf_bundle()`, `verify_bundle()`, `write_bundle()`, `read_bundle()`,
  `as_bibtex()`, `export_citations()` exported, documented, tested.
- Chained root verified; per-component drift attribution verified; the
  early-corruption demonstration in tests and vignette.
- `sframe_analysis_payload()` determinism tests pass (identical runs,
  plots on/off).
- Citation output: no instrument DOI ever; parent DOI only; draft
  marker on incomplete chains; `citations.json` schema matches
  `sframe-schema` (repo bumped to its stable 1.0 in the same cycle).
- `register_citation()` absent by design.
- sfReport exists in its own repo, builds, renders a clean report from
  a test bundle, `export_manifest()` writes valid JSON, submitted to
  CRAN independently.
- `devtools::document()`; full suite; `R CMD check --as-cran` on
  surveyframe 0/0/<=1 NOTE; win-builder both flavours; sfReport checked
  separately; `cran-comments.md`; NEWS.md.
- Owner submissions after acceptance: SSR 6.0 first, then MethodsX,
  then JOI (order fixed in 12_publications_citations.md).

---

## Delegation, model tiering, and token budget

Binding policy per `todo_0.4.md`.

### Build order and agent assignment

- **Lead (Fable/Opus):** `sframe_analysis_payload()` and the chain
  construction in `sf_bundle()` — the two correctness-critical pieces —
  plus the bundle serialisation decision. Reference diff includes the
  early-corruption test.
- **Agent 1 (Sonnet):** `verify_bundle()` + write/read_bundle +
  remaining bundle tests, from the landed reference.
- **Agent 2 (Sonnet):** the citation model (#2) + tests. Independent of
  Agent 1 once the layer-status shape is fixed by the reference.
- **Agent 3 (Sonnet, separate worktree or the sfReport repo directly):**
  sfReport scaffold (#3) — package skeleton, template, export_manifest,
  its own check. Fully independent.
- **Agent 4 (Sonnet):** vignette (#4) after #1-#2 land.
- **Agent 5 (Haiku):** verification sweeps on both packages, document
  runs, knit checks, determinism test executions.

### Model tiering

- **Haiku:** sweeps, mechanical verification, both-package check runs.
- **Sonnet:** #1-remainder, #2, #3 scaffold, #4.
- **Opus/Fable:** analysis payload canonicalisation, chain
  construction, serialisation decision, review of every delegated diff
  (hash-bearing code gets line-by-line review, not spot checks).

### Token-saving rules (binding)

The same 6 rules as todo_0.4/todo_0.5. Addition: sfReport work happens
in its own repo context; never load both repos into one agent's context
beyond the integration-test step.
