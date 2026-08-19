# todo_integration_launch.md: surveyframe 0.6, integration contract, AI layer, launch

> **Renamed 2026-08-20 from `todo_1.0.md`. There is no 1.0 any more.**
> The 2026-08-19 renumbering merged the former 0.8, 0.9, and 1.0 into a
> single terminal release, **0.6**, which is now the last version on this
> track and the launch gate for Ethos, Ethos Pro, and the ASRDA complete
> edition. The note below arguing that 1.0 should keep its number is
> superseded: the launch gate moved to 0.6 rather than the number moving
> to the launch. The 2027-10-22 date is also retired and awaits
> re-estimation.

> **Filenames on this branch are themed, not numbered, since 2026-08-20.**
> The numbered names churned 3 times (renumbered 2026-07-30, shifted by
> 0.1 on 2026-08-15, swapped later that same day) and then contradicted
> the 2026-08-19 renumbering outright. A themed name cannot go stale when
> a version moves. The canonical version table lives in
> `../portfolio-planner/CLAUDE.md` and overrides any number written here.

> **Kept at `1.0`, not shifted, in the 2026-08-15 renumbering that moved
> every other `todo_0.5.md` through `todo_0.9.md` file down by 0.1 to
> match CRAN version numbers directly.** 1.0 is an external launch gate
> (Ethos GA, Ethos Pro GA, the ASRDA complete edition), not a slot in the
> sequential feature track, so it does not participate in that shift.
> The file formerly named `todo_0.9.md` is now `todo_0.8.md`; references
> below are updated to match.

Dev-only planning file, tracked on `dev` only. Its name is in `.gitignore`
and `.Rbuildignore`. Companion to `CLAUDE.md`, `todo_0.8.md`, and
`../portfolio-planner/development_instructions/08_v10_ai_layer.md` plus
`09_ethos_database_schema.md`/`10_ethos_architecture.md` (Ethos side).

Last updated: 2026-07-25. Target: 2027-10-22, two 45-day cycles (the
one planned double-length release). Launch gate for Ethos public GA,
Ethos Pro institutional GA, and the ASRDA complete edition. After this
release the API is frozen under semantic versioning.

Anchors verified against `main` 2026-07-25; re-grep before editing.
This file is the surveyframe-repo view; Ethos-side deliverables are
listed only where surveyframe must expose something for them.

---

## Two tracks, both complete before the CRAN submission

**Track A — integration and stability:** weighting, JASP/jamovi export,
Merkle root, DOI archival deposit, integration contract, JSS CITATION,
documentation pass.

**Track B — AI and agentic layer:** JSON schema in the package, MCP
server (separate repo), ai_log in the bundle. The authoring flow,
narrative generation, and the governed agentic loop are **Ethos-side**
(guide section headings "In Ethos") — nothing of them enters the CRAN
package, which must never require internet or an API key.

## Verified starting points

- Weights already exist in embryo: `sframe_run_frequency()` takes a
  `weights` argument and `sframe_run_one_block()` lifts a
  `weights`/`weight` role into options (`R/analysis_plan.R:1092`).
  The weighting work generalises this, it does not invent it.
- The **sframe-schema repo already exists locally**
  (`../sframe-schema`, created 2026-07-14 as v0.1-draft, bumped to a
  stable 1.0 during 0.8 per todo_0.8.md). `inst/schema/sframe_v1.json`
  in the package is generated from or verified against that repo —
  single source of truth, do not hand-maintain two copies. The MethodsX
  paper describes this schema.
- The method-id list the MCP `get_method_registry` tool returns is the
  `switch()` in `sframe_run_one_block()` plus the builder
  `ANALYSIS_REGISTRY` metadata. Decide the export shape once: a new
  exported `sframe_method_registry()` returning a data frame (id,
  family, label, roles, engine, guarded) built from a single internal
  table that the builder JS is **generated from or checked against** —
  by 1.0 the drift risk between the R switch and two JS registries
  (accumulated across 0.5-0.7) must be closed by a consistency test at
  minimum.
- `.sframe_citations` (`R/analysis_plan.R:9`) backs `get_citation`.

## Guide corrections

- **Merkle extension:** the 08 guide's `.merkle_root()` snippet sorts
  the component hashes, silently reintroducing the order-erasure the
  2026-07-14 revision removed from Layer 5. Build the Merkle tree over
  the components in their **fixed chain order** (instrument, responses,
  analysis, report, extras, ai_disclosure), unsorted. Keep
  `verify_bundle()`'s per-component attribution; record in the manifest
  which algorithm produced the root (`"chain-v1"` from 0.9 or
  `"merkle-v1"`) so 0.9 bundles still verify — verification dispatches
  on that field. Both algorithms tested side by side.
- The guide's weighting sketch aborts on `design_type = "calibrated"`;
  implement calibration via `survey::calibrate()` or drop the option
  value entirely — do not ship an exported argument value whose only
  behaviour is an error.
- `zip()` in `export_jamovi()`: use `utils::zip()` explicitly and note
  it shells out; check availability on win-builder, fall back to a
  clear error naming the requirement.

---

## Track A

### A1. Complex-survey weighting

`DESCRIPTION`: `survey (>= 4.0)` to Suggests; `sframe_require_survey()`
in `R/conditions.R`. New `R/survey_weighting.R`:

- `apply_survey_design(instrument, data, weight_col, design_type =
  c("simple", "stratified", "cluster", "calibrated"), ...)` per the
  guide, strata/cluster columns from `instrument$meta$sampling_design`
  (new meta block: declared at design time like everything else —
  serialised, restored, validated; this is the contract-worthy part).
- Routing: `run_analysis_plan()` accepts the design object as `data`;
  a capability map declares which method ids have weighted analogues
  (svymean/svytable/svychisq/svyglm and the rest of the survey-package
  surface); weighted runners produce the same result contract
  (`$table`, `apa` noting the design, `prompt`); methods without an
  analogue run unweighted with an explicit note field, never silently.
- Tests against `survey`'s own worked examples (api dataset) for at
  least mean, proportion, chi-square, and one glm.

### A2. JASP and jamovi exports

New `R/export_formats.R` per the guide: `export_jasp()` (CSV +
`_meta.json` sidecar), `export_jamovi()` (.omvz zip of data.csv +
xdata.json), shared internal `.sframe_column_metadata(instrument)`
mapping every item and scale score column to measurement level
(scale/ordinal/nominal — derive from item type and choice set) and
label. Round-trip smoke test: export, unzip, re-read, columns and
levels intact. Manual verification step in real JASP and jamovi
installs goes on the exit checklist (cannot be automated).

### A3. Merkle root and archival deposit

Per the guide corrected above, in `R/sf_bundle.R` (Merkle) and
`R/export_formats.R` (`prepare_archival_deposit(bundle, instrument,
dir)` writing instrument.sframe, verification_manifest.json,
README.txt). The DOI itself is minted by the repository (Zenodo/OSF)
at deposit time — surveyframe prepares, never uploads (that was the
deferred `register_citation()` scope and stays deferred).

### A4. Integration contract

- `inst/integration_contract.json`: frozen argument names/types and
  return shapes for the guide's 11-function table (sf_instrument,
  write/read_sframe, validate_sframe, run_analysis_plan, sf_version,
  sf_review, sf_pilot, sf_bundle, verify_bundle, export_manifest —
  note export_manifest lives in sfReport; record it there or move it,
  decide with the owner and Ethos).
- Internal `verify_contract()`: compares the JSON against live
  `formals()` at test time (a testthat test, not a load-time hook —
  load-time warnings would hit end users; the guide says load time,
  override it). Any drift fails the suite.
- The contract freeze is the API-stability declaration: NEWS.md entry
  stating semantic-versioning guarantees begin at 1.0.

### A5. CITATION, docs, pkgdown

- `inst/CITATION`: replace the Manual entry with the JSS Article entry
  (final DOI — **blocked on JSS acceptance**, hard external
  dependency; do not submit 1.0 without it per the launch plan), keep
  the smallsamplelab and small-sample-paper entries from 0.4.
- Full documentation pass: every exported function has a runnable
  example; pkgdown reference pages inspected; hero section on the
  five-layer integrity system and the MCP server; README 1.0 badge,
  citation, MCP quick start. pkgdown builds from `main` only (standing
  rule).

## Track B

### B1. inst/schema/sframe_v1.json

Generated from/verified against `../sframe-schema` 1.0. Ships in the
tarball. A testthat test validates every bundled demo `.sframe` and a
freshly built instrument against it (jsonlite-based structural check
or a Suggests-guarded jsonvalidate — decide by what CRAN tolerates;
jsonvalidate is on CRAN and can sit in Suggests).

### B2. surveyframe-mcp (separate repo, Node.js)

Per the guide: the 9 read-only tools (create_instrument,
validate_instrument, get_item_types, get_method_registry,
run_analysis_plan, get_analysis_result, get_citation,
get_instrument_hash, verify_bundle) over a spawned R subprocess,
JSON-schema-validated inputs, localhost only, no filesystem writes
without explicit confirmation. surveyframe-side prerequisites, all in
this repo: `sframe_method_registry()` (see Verified starting points),
a documented `--vanilla` R invocation pattern, and JSON-safe output for
every tool-facing function (no environments, no closures — the 0.9
`sframe_analysis_payload()` does this for results). The MCP repo gets
its own CLAUDE.md and todo; tag 1.0.0 at launch. Model standard is
Claude via tool use and MCP (roadmap decision).

### B3. ai_log in sf_bundle()

Per the guide: optional `ai_log` parameter, hashed
(`as.character(openssl::sha256(toJSON(...)))`) into the component
chain/Merkle as `ai_disclosure`, so undisclosed AI use breaks
verification. Validate the record shape (type, model, timestamp,
action, accepted, edited) with a documented schema in sframe-schema.
Absent ai_log = no component, verification unaffected (pre-AI bundles
stay valid). Tests: with/without, tamper detection.

### B4. Ethos-side (not this repo — tracked here as launch gates only)

AI authoring flow, plan-bounded narrative generation (its prompt is in
the guide; UK spelling rule already embedded), governed agentic loop
with permission gates, visual branching preview, dashboard filters,
interactive assumption plots. surveyframe's only obligations: the
schema (B1), the registry export (B2), stable JSON output, and the
ai_log contract (B3).

## Launch checklist (from the guide, kept in full as the gate)

- Track A and B complete; `R CMD check --as-cran` 0/0; win-builder
  clean; `verify_contract()` green; pkgdown clean; CITATION carries the
  published JSS DOI.
- sfReport 1.0 on CRAN, citing surveyframe 1.0.
- Ethos public GA same day: R bridge on surveyframe 1.0, MCP server
  tagged 1.0.0, all contract functions passing in Ethos's suite.
- Ethos Pro institutional GA: approval workflow, reviewer roles,
  audit-log export, org admin, licence server complete (file 10).
- ASRDA complete edition published, function references verified,
  sfReport cited in the reproducibility appendix; textbook retitle per
  the roadmap.
- JSS paper published; SSR 6.0 submitted/in review; small-sample
  preprint DOI live.

---

## Delegation, model tiering, and token budget

Binding policy per `todo_0.4.md`. Two cycles, two tracks, three repos
(surveyframe, surveyframe-mcp, sfReport final polish) — this is the
release where multi-agent work pays most, and where the shared-file
conflict rule matters most (A1 and B2 both touch the analysis engine).

### Build order and agent assignment

Cycle 1:
- **Lead (Fable/Opus):** integration contract (A4) first — it
  constrains everything else — then the registry unification
  (`sframe_method_registry()` + drift test), then the weighting design
  (meta block + capability map) as the reference diff.
- **Agent 1 (Sonnet):** weighted runner analogues + survey-package
  tests, from the reference.
- **Agent 2 (Sonnet):** A2 exports + tests.
- **Agent 3 (Sonnet):** A3 Merkle (both-algorithm verification) + B3
  ai_log + tests — one brief, both touch sf_bundle.
- **Agent 4 (Sonnet, separate repo):** B2 MCP server scaffold against
  the frozen contract.

Cycle 2:
- **Agent 5 (Sonnet):** B1 schema test harness; docs pass legwork
  (examples audit) — mechanical parts to Haiku where possible.
- **Agent 6 (Haiku):** examples run-check sweep, pkgdown build checks,
  cross-platform check orchestration, contract-drift test runs.
- **Lead:** release-candidate checks across platforms, launch
  checklist, everything blocked on external events (JSS DOI), final
  review of all diffs.

### Model tiering

- **Haiku:** sweeps, examples checks, build verification, mechanical
  JSON fixture generation.
- **Sonnet:** weighted analogues, exports, Merkle/ai_log, MCP scaffold,
  schema tests, vignette/docs drafts.
- **Opus/Fable:** the contract, registry unification, weighting
  design, anything hash-bearing, all cross-repo integration, every
  delegated-diff review. The API freeze review is lead-only and
  line-by-line: after 1.0 nothing exported can change without a major
  bump.

### Token-saving rules (binding)

The same 6 rules as todo_0.4/todo_0.5. Additions: one repo per agent
context; the integration contract JSON is the interface document
agents receive instead of reading each other's diffs; the launch
checklist is verified from artefacts (check logs, CRAN pages, tags),
never from memory.
