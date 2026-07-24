# todo_0.5.md — surveyframe v0.5: MCDM and DEMATEL

Dev-only planning file, tracked on `dev` only. Its name is in `.gitignore`
and `.Rbuildignore`. Companion to `CLAUDE.md`, `todo_0.4.md`, and
`../portfolio-planner/development_instructions/06_v05_v07_implementation.md`
(the original guide, v0.5 section — treat it as intent, this file as the
verified plan).

Last updated: 2026-07-25. Target CRAN submission: 2027-01-25
(`../portfolio-planner/master_roadmap.md`). Do not start before 0.4 ships
and 0.4.1 (2026-12-11) is done or explicitly waived by the owner.

**Decision gate 2026-10-15 (recorded 2026-07-25 in
`../portfolio-planner/decisions.md`):** if the small-sample preprint DOI
is not live by 2026-10-15, 0.4 merges into this release as an added
small-sample track (`todo_0.4.md` folds in here, 0.4.1 renumbers to
0.5.1, same 2027-01-25 target). If the DOI is live, 0.4 ships separately
on schedule and the start-condition paragraph above stands. Either way,
the 0.5 data-contract work (section 1) may start early on a branch
during the 0.4 cycle — that is the sanctioned way to buy MCDM more time,
merge or no merge.

All file/line anchors below were verified against `main` on 2026-07-25
(0.3.4 feature-complete). Line numbers will drift: **re-grep every anchor
before editing**, the function names are the stable reference.

---

## Architecture ground truth (verified, corrects the 06 guide)

The guide assumes a method registry table with
`list(id=, fn=, required_n=, small_sample=)` entries. **No such registry
exists in R.** The real architecture:

- Dispatch is a plain `switch(test, ...)` inside
  `sframe_run_one_block()` at `R/analysis_plan.R:1101`. `family` is
  descriptive metadata on the block (`block$family`), never dispatched on.
- Runners are `sframe_run_<id>(data, vars)` or
  `sframe_run_<id>(data, roles, options)` returning a flat named list:
  `test` (the method id), `apa` string, `prompt` string, effect-size
  fields where they exist, and `error` string on any failure (never
  `stop()` — the switch is wrapped in `tryCatch()` but runners handle
  their own expected failures).
- Tables are humanised centrally: `sframe_run_one_block()` passes every
  `$table` through `sframe_humanize_table(sframe_label_lookup(instrument))`
  (`R/analysis_plan.R:1180`). Runners emit raw ids and coded values.
- Missing `$table` is backfilled by `sframe_result_table()`
  (`R/analysis_plan.R:845`, a switch on test id).
- Plots attach centrally via `sframe_plot_for_result()`
  (`R/plots.R:636`, a switch on test id mapping to `sframe_plot_*()`
  helpers built on `theme_surveyframe()` with `palette = c("web","print")`).
- Citations come from `.sframe_citations` (`R/analysis_plan.R:9`), a list
  whose entries carry a `use` vector of method ids;
  `sframe_citations_for_test()` (`R/analysis_plan.R:92`) filters on it.
- **Two JS/Shiny registries mirror the method list and must be updated in
  lockstep:** the builder's `ANALYSIS_REGISTRY`
  (`inst/builder/survey_builder.html` ~line 2690) plus its method
  `<optgroup>` dropdown (~line 969), and the studio's registry in
  `inst/shiny/app.R` (~line 324, built with a local `role()` helper) plus
  its requirements strings (~line 722).
- Plan blocks round-trip through `sframe_restore_analysis_block()`
  (`R/read_write_sframe.R:254`). **Any new block field not restored there
  silently drops on write_sframe()/read_sframe().**
- Missing optional packages use `sframe_require_<pkg>()` helpers in
  `R/conditions.R` wrapping `rlang::check_installed()` (pattern:
  `sframe_require_psych`, `R/conditions.R:26`).

## Integration checklist for every new method (all 10 MCDM runners)

1. Runner `sframe_run_<id>(data, roles, options)` in `R/decision_methods.R`.
2. `switch()` case in `sframe_run_one_block()` (`R/analysis_plan.R:1101`).
3. Roles: decision methods are roles-based (a matrix item id plus
   options), so no `sframe_vars_for_method()` entry is needed unless a
   method takes plain variables. Add a default-roles fallback in
   `sframe_analysis_roles()` (`R/statistics_reports.R:57`) mapping
   `variables[1]` to the matrix-item role for blocks declared without
   roles.
4. Citation entries in `.sframe_citations` with the method id in `use`.
   Harvest the reference list from the mcdm repo and verify each one
   before adding (standing no-unverified-references rule).
5. `$table` returned by the runner (the ranking or cause-effect frame).
6. Plot case in `sframe_plot_for_result()` plus the helper in `R/plots.R`.
7. Builder: `<optgroup label="Decision">` in the method dropdown plus an
   `ANALYSIS_REGISTRY` entry per method (copy the `mann_whitney` entry
   shape: family, label, roles with min/max/levels, showAlpha,
   showHypotheses, showEffectSize, assumptions, output, refs).
8. Studio: registry entry (~app.R:324 shape) and requirements string.
9. Matrix, weights, labels, and `criteria_types` all live inside
   `options` (see the 1g sample), which
   `sframe_restore_analysis_block()` already round-trips generically —
   no restore work needed, only `sframe_decision_options()` validation
   (1e). Do not add top-level block fields.
10. testthat file per method group; `render_results()`
    (`R/analysis_plan.R:1348`) renders each result without error.

---

## 0. Pre-work (lead, before any agent is spawned)

1. **Clone the source repo — it is not local as of 2026-07-25:**
   `gh repo clone MohammedAliSharafuddin/mcdm ../mcdm`
2. Harvest audit: for each of the 10 methods, record in a table appended
   to this file: source file, computation function name, pure-R yes/no,
   Shiny entanglement, rework estimate, citation keys used. The audit
   table becomes the only thing later agents read from mcdm — no agent
   re-reads the mcdm app afterwards.
3. Decide the two design questions in section 1 and 2 with the owner
   before implementation starts.

## 1. The MCDM data contract: input structure, storage, assembly

This is the hard half of the release. The computation layer (#3) is
textbook maths; getting judgement data from a phone screen into a
square reciprocal matrix is where MCDM implementations fail. Settle
this section with the owner before any runner is written.

### 1a. Two matrix kinds — never conflated

- **Judgement matrices** (criteria x criteria): AHP/ANP pairwise ratios
  and the DEMATEL direct-relation matrix. These are respondent
  opinions, one matrix per respondent, and are the survey-collectable
  kind. AHP matrices are reciprocal (m[b,a] = 1/m[a,b], diagonal 1);
  DEMATEL matrices are **not** reciprocal (influence of a on b is
  independent of b on a) and have a 0 diagonal.
- **Performance matrices** (alternatives x criteria): the decision
  matrix TOPSIS, VIKOR, MOORA, PROMETHEE, ELECTRE, SMART, and WASPAS
  rank from. These are measurements or expert scores of real
  alternatives (price, capacity, rating), not typically collected from
  survey respondents. They are researcher-supplied in the plan block.
- **The realistic pipeline combines both:** weights are collected
  (pairwise AHP or a `criteria_weight` item, aggregated across
  respondents), the performance matrix is supplied, and a ranking
  method consumes supplied matrix + collected weights. Every ranking
  runner therefore resolves its two inputs independently:
  matrix from `options$matrix`, weights from `options$weights` OR from
  a `weights_item` role pointing at a collected item. Record the
  provenance of each in the result (`weights_source`,
  `matrix_source`) so the report can say where numbers came from.

### 1b. Respondent input structure (per item type, per surface)

**`pairwise_comparison` (AHP/ANP variant).** Never render an n x n
grid — it is unusable below tablet width and invites inconsistency.
Render the n(n-1)/2 unordered pairs as one comparison row each: left
label, a bipolar 17-point Saaty strip (9 8 7 6 5 4 3 2 | 1 | 2 3 4 5 6
7 8 9), right label. Desktop: a radio strip (the matrix-table radio
styling at `inst/static_survey/template.html` ~lines 159-170 is the
precedent). Mobile (< 600px): reuse the matrix reflow pattern
(template.html ~lines 213-229, one stacked card per pair) with a
`<select>` listing the 17 verbal anchors ("A extremely more important"
... "Equal" ... "B extremely more important"). 4 criteria = 6 rows,
7 criteria = 21 rows; `validate_sframe()` warns above 7
`comparison_items` (respondent burden and the RI table both degrade)
and errors above 10.

**`pairwise_comparison` (DEMATEL variant, `comparison_scale =
"influence"`).** Ordered pairs, so n(n-1) rows ("How strongly does A
influence B?", then B on A separately), each a 5-point unipolar strip
(0 none - 4 very high). Same reflow. Warn above 6 comparison items
(30 rows).

**`criteria_weight`.** Constant-sum allocation: one numeric input per
criterion, a live running total, and page advance blocked until the
total is exactly 100 (extend `validatePage()` in the static template —
the date-bounds check added 2026-07-17 is the precedent for
per-type validation there). The builder inspector gets the same
criteria-list editor the matrix type already has for rows.

All three surfaces must agree: static template, Shiny renderer
(`R/render_survey.R` + `R/survey_module.R`), and the builder preview.
After editing the static template, re-run `inline_static_template.R`
(0.3.4 established this step). The WCAG bar from 0.3.4 applies: the
strips are radio groups with accessible names per pair, 44px targets,
keyboard operable.

### 1c. Column encoding (export contract)

Follows the `item__sub` expansion convention already accepted by
`read_responses()` (`R/read_responses.R:97-105` builds the expansion
whitelist per item type — extend that switch for the two new types):

- AHP pairwise: one column per unordered pair, `item__a__vs__b`
  (ids joined with the existing double-underscore convention), value a
  **signed integer** in {-9..-2, 1, 2..9}: positive means the first
  (alphabetically first declared) side is preferred by that Saaty
  degree, negative means the second side, 1 means equal. Signed
  integers keep the CSV and Google Sheet free of fractions (never
  store 1/7 as 0.142857...); reciprocals are reconstructed at
  assembly, not stored.
- DEMATEL: one column per ordered pair, `item__a__to__b`, integer 0-4.
- `criteria_weight`: one column per criterion, `item__crit`, integer
  0-100, row-sum 100.
- The static template's submit serialiser and the Google Sheets Apps
  Script generator (`R/google_sheets.R`) must both emit these columns —
  the multi-select one-column-per-option export from 0.3.3 is the
  precedent to copy. Round-trip test: static survey fixture -> collector
  CSV -> `read_responses()` -> assembled matrix.

### 1d. Assembly and aggregation — new file R/decision_data.R

The data layer between response frames and the computation layer, unit
tested on its own:

- `sframe_assemble_pairwise(data, instrument, item_id)`: per
  respondent, build the n x n matrix from the pair columns (fill
  reciprocals for AHP: +5 in `a__vs__b` gives m[a,b] = 5,
  m[b,a] = 1/5; DEMATEL fills directed cells, diagonal 0). Validation
  per respondent: all pairs answered, values in range. Respondents
  with any missing pair are dropped and counted (Harker-style
  completion of partial matrices is out of scope — a documented
  decision, revisit only if field data demands it).
- `sframe_aggregate_judgements(matrices, method = c("geometric",
  "arithmetic"))`: element-wise geometric mean for AHP (the standard
  AIJ aggregation — it is the one that preserves reciprocity;
  arithmetic means do not), arithmetic mean for DEMATEL. Result
  carries `n_respondents`, `n_dropped`.
- AHP consistency screening across respondents:
  `options$cr_filter = TRUE` drops individual matrices with CR >= 0.10
  before aggregation; default FALSE, but the per-respondent CR
  distribution (min/median/max, share above 0.10) is always computed
  and reported — reviewers ask for it.
- `sframe_collected_weights(data, instrument, item_id)`: for
  `criteria_weight` items, per-respondent renormalisation to sum 1,
  then the arithmetic mean vector; for pairwise items, the aggregated
  matrix's principal-eigenvector weights. Both return the same shape
  so runners are source-agnostic.
- Runner resolution order, uniform across all 10:
  `options$matrix`/`options$weights` first (researcher-supplied),
  collected item roles second, typed error naming what is missing
  third.

### 1e. Serialisation of matrix-valued options

`options` already round-trips through
`sframe_restore_analysis_block()` (`R/read_write_sframe.R:254`) as a
generic list, but jsonlite turns a numeric matrix into a list of rows
and drops dimnames. Contract: `options$matrix` is stored as a list of
numeric row vectors plus `options$alternatives` and
`options$criteria` character vectors; a new
`sframe_decision_options()` normaliser (called by the runners and by
`validate_sframe()` for decision blocks) rebuilds the matrix, checks
`length(alternatives) == nrow`, `length(criteria) == ncol ==
length(weights) == length(criteria_types)`, and errors with the exact
mismatch. Round-trip test: block with a 5x4 matrix survives
write_sframe/read_sframe with values, dims, and labels intact and the
instrument hash stable.

### 1f. CRAN prior art (read 2026-07-25, reference manuals verified)

What the existing packages expect as input, and what surveyframe must
therefore be able to produce from a survey:

| Package | Entry point and input structure | Lesson for surveyframe |
|---|---|---|
| topsis 1.0 | `topsis(decision, weights, impacts)`: numeric matrix m alternatives x n criteria, numeric weight vector, character vector of `"+"`/`"-"`. Returns data frame `alt.row`, `score`, `rank` | The minimal runner contract. Our `criteria_types = c("benefit","cost")` maps 1:1 to `impacts`; our `$table` (Alternative, Score, Rank) matches its return shape |
| dematel 0.1.0 | `execute_dematel(x)` and stepwise functions (`normalize_data`, `total_relationship_matrix`, `threshold_value`, `compare_criteria`): one plain numeric square matrix, already aggregated across experts (its bundled `hospitaldata`/`nurseselection` are 10x10 frames with named criteria K1..K5...). Returns a list of matrices, the threshold, and the over-threshold relation pairs | Expert aggregation happens **before** the package is called and is undocumented there — exactly the gap `sframe_assemble_pairwise()` + `sframe_aggregate_judgements()` (1d) close. Criteria names travel as dimnames, so ours must too |
| ahptopsis2n 0.2.0 | `ahptopsis2n(decision, criteria, minmax)`: the decision matrix, a **full n x n AHP pairwise matrix with literal reciprocals** (`1/3`, `1/5` in the example), and `c("max","min")` per criterion. Returns CR plus ranked frames | Confirms the hybrid pipeline in 1a (pairwise -> weights -> ranking) as an established published pattern, and confirms reciprocal fractions appear the moment users hand-build matrices — our signed-integer column encoding (1c) exists precisely so collected data never carries fractions |
| IFMCDM 0.1.17 | `IFconversion(primary)` takes **raw per-respondent ordinal survey data** (first column = object name, repeated rows per respondent, one Likert column per criterion; example: 26 objects x 13 respondents x 8 criteria) and aggregates to an intuitionistic fuzzy decision matrix (m x n*3: mu, nu, pi per criterion); `IFSM()`/`IFTOPSIS()` then rank with crisp `w` and `z = "b"/"c"` | The closest published analogue to our whole problem: the decision matrix is **built from survey responses by aggregation**. This validates collection path C below and shows a third weight/type encoding (`"b"/"c"`) — ours stays `benefit`/`cost`, translated per engine |

Direct consequence missed by the earlier draft: alongside the two
collection paths in 1a there is a **path C, the rated performance
matrix** (the IFMCDM pattern) — respondents rate each alternative on
each criterion with ordinary Likert/rating items, and the decision
matrix is the per-cell aggregate (mean, or IF conversion later). This
needs no new item type: one existing `matrix` item per criterion
(rows = alternatives) already collects it. Add to `R/decision_data.R`:
`sframe_rated_matrix(data, instrument, items, statistic = "mean")`
building the m x n matrix from the `item__alternative` expansion
columns of n matrix items, with per-cell n and SD kept for the report.

### 1g. Sample sframe (the design target — this must build, validate, round-trip, and run)

The worked example for the whole release: hotel supplier selection, 5
vendors, 4 criteria (service quality and location = benefit, price =
cost, delivery time = cost). It exercises every data path: pairwise
weights (A), constant-sum weights, rated performance matrix (C),
researcher-supplied matrix, and DEMATEL. Uses only the real 0.3.x API
plus the additions this file specifies.

```r
crits   <- c("service", "location", "price", "delivery")
vendors <- c("Alpha", "Basilica", "Coral", "Dhoni", "Equator")

components <- list(
  # Path A: criteria pairwise comparison (6 pair rows rendered, 1b)
  sf_item("crit_pairs", "Compare the importance of each pair of criteria",
          type = "pairwise_comparison",
          comparison_items = crits,
          comparison_scale = "saaty",
          required = TRUE),

  # Constant-sum weights (alternative weight source, 1b)
  sf_item("crit_points", "Divide 100 points across the criteria",
          type = "criteria_weight",
          comparison_items = crits,
          required = TRUE),

  # Path C: rated performance matrix - one matrix item per criterion,
  # rows = vendors (IFMCDM pattern, no new item type needed)
  sf_choices("q5", values = 1:5,
             labels = c("Very poor", "Poor", "Fair", "Good", "Excellent")),
  sf_item("rate_service",  "Rate each supplier: service quality",
          type = "matrix", matrix_items = vendors, choice_set = "q5"),
  sf_item("rate_location", "Rate each supplier: location",
          type = "matrix", matrix_items = vendors, choice_set = "q5"),
  sf_item("rate_price",    "Rate each supplier: value for money",
          type = "matrix", matrix_items = vendors, choice_set = "q5"),
  sf_item("rate_delivery", "Rate each supplier: delivery speed",
          type = "matrix", matrix_items = vendors, choice_set = "q5"),

  # DEMATEL: directed influence among criteria (12 ordered pairs, 1b)
  sf_item("crit_influence", "How strongly does each factor influence the others?",
          type = "pairwise_comparison",
          comparison_items = crits,
          comparison_scale = "influence")
)

study <- sf_instrument(
  title      = "Hotel supplier selection",
  version    = "1.0.0",
  components = components,
  analysis_plan = list(
    list(id = "RQ1",
         research_question = "What weight does each criterion carry?",
         family  = "decision", method = "ahp",
         roles   = list(pairwise = "crit_pairs"),
         options = list(cr_filter = FALSE)),
    list(id = "RQ2",
         research_question = "Which supplier ranks best on the audited figures?",
         family  = "decision", method = "topsis",
         roles   = list(weights_item = "crit_pairs"),
         options = list(
           # researcher-supplied performance matrix (audited data),
           # stored per 1e: list of rows + label vectors
           matrix = list(c(4.1, 3.0, 210, 36),
                         c(3.6, 4.5, 180, 48),
                         c(4.8, 2.5, 260, 24),
                         c(3.9, 4.0, 150, 72),
                         c(4.4, 3.8, 230, 30)),
           alternatives   = vendors,
           criteria       = crits,
           criteria_types = c("benefit", "benefit", "cost", "cost"))),
    list(id = "RQ3",
         research_question = "Which supplier do staff rate best overall?",
         family  = "decision", method = "topsis",
         roles   = list(performance_items = c("rate_service", "rate_location",
                                              "rate_price", "rate_delivery"),
                        weights_item = "crit_points"),
         options = list(criteria_types = c("benefit", "benefit",
                                           "benefit", "benefit"))),
    list(id = "RQ4",
         research_question = "Which criteria drive the others?",
         family  = "decision", method = "dematel",
         roles   = list(pairwise = "crit_influence"))
  )
)
```

What this sample pins down, and what each runner receives:

- **Role vocabulary for the decision family** (this is the spec):
  `pairwise` (a pairwise_comparison item id), `weights_item` (a
  pairwise_comparison OR criteria_weight item — both resolve through
  `sframe_collected_weights()`, 1d), `performance_items` (ordered
  vector of matrix items, one per criterion, path C). Register these
  in `sframe_analysis_roles()` and the two UI registries with exactly
  these names.
- **RQ1 (ahp)** receives the aggregated reciprocal 4x4 from
  `sframe_assemble_pairwise()` + AIJ; returns weights, CR, the
  consistency warning path, weights bar chart.
- **RQ2 (topsis, hybrid)** receives the supplied 5x4 matrix rebuilt by
  `sframe_decision_options()` and weights from the collected
  `crit_pairs` — the ahptopsis2n pipeline, split across declared
  sources with provenance recorded. Note `criteria_types` mixes
  benefit and cost here because the audited figures are raw magnitudes.
- **RQ3 (topsis, fully collected)** builds the 5x4 from
  `sframe_rated_matrix()` over the 4 matrix items' `item__vendor`
  columns; all 4 criteria are `benefit` because the price question was
  asked as value-for-money (higher = better) — the vignette must spell
  out this reframing trap (a raw "price" rating collected as
  higher = more expensive would be a `cost`).
- **RQ4 (dematel)** receives the arithmetic-mean 4x4 directed matrix
  (0 diagonal, no reciprocity) and returns the cause-effect table plus
  influence map.
- **Respondent export columns** this instrument produces (the 1c
  contract made concrete): 6 `crit_pairs__a__vs__b` signed columns, 4
  `crit_points__crit` 0-100 columns, 20 `rate_*__vendor` columns, 12
  `crit_influence__a__to__b` columns.
- **Interplay with the existing engine**: no scales are declared, so
  `run_analysis_plan(scored = TRUE)` must pass through unchanged;
  `quality_report()`'s straightlining and speeding checks must not
  treat the pairwise columns as a Likert battery (check and, if
  needed, exempt the new types there); `missing_data_report()` sees
  the expansion columns like any matrix item's.
- The sample (with seeded simulated responses for ~12 respondents)
  becomes `tests/testthat/` fixtures and the spine of the vignette
  (#7). Exit criterion: every block above returns a table and a chart
  with no error field, and the whole instrument round-trips with a
  stable hash.

## 2. New item types: pairwise_comparison and criteria_weight

There is no `R/item_types.R`. The enum lives inline in the `sf_item()`
signature at `R/sf_item.R:53-56`, validated by `rlang::arg_match()` at
line 74. Touch points:

- `R/sf_item.R`: add `"pairwise_comparison"`, `"criteria_weight"` to the
  `type` default vector; new params `comparison_items` (character vector
  of things being compared, reusing the `matrix_items` pattern at line
  63) and `comparison_scale = c("saaty", "influence")` selecting the
  AHP bipolar 1-9 or DEMATEL unipolar 0-4 input from section 1b.
  Validate like `sframe_check_date_bound()` does for dates, including
  the 1b size limits (warn > 7 saaty / > 6 influence items, error > 10).
- `R/read_write_sframe.R`: restore the new fields in
  `sframe_restore_item()` (line 168), same `sframe_as_vector()` idiom as
  `matrix_items`.
- `R/validate_sframe.R`: `pairwise_comparison` requires `comparison_items`
  length >= 2 and `choice_set` NULL. Use `sframe_abort_validation()`
  (`R/conditions.R:45`).
- `R/read_responses.R`: extend the expansion-whitelist switch (lines
  97-105) with the three column patterns from section 1c
  (`item__a__vs__b`, `item__a__to__b`, `item__crit`).
- Round-trip test: sf_item with both types survives
  write_sframe()/read_sframe() with fields intact (hash equality).
- Rendering surfaces: implement the section 1b input structures in all
  three places — the static template (+ `validatePage()` checks: all
  pairs answered when the item is required, constant-sum total = 100;
  then re-run `inline_static_template.R`), the Shiny renderer
  (`R/render_survey.R` + `R/survey_module.R`), and the builder
  (inspector editor for `comparison_items`/`comparison_scale`, Theme B
  preview parity). An instrument carrying either type must never
  render a broken or blank question on any surface.

## 3. Computation layer: R/decision_methods.R

One new file, header comment `# R/decision_methods.R` per house style.
Pure base-R computation helpers, one per method, taking
`(matrix, weights, criteria_types)` and returning the method's raw
outputs. These are internal (not exported), unit-tested directly against
known-value fixtures.

- Shared validator `sframe_check_decision_input()`: numeric matrix, no
  NA, weights sum to 1 within 1e-6 (renormalise with a note, do not
  error), `length(weights) == ncol(matrix)`, `criteria_types` all in
  c("benefit", "cost"). Tested once, called by every runner.
- `.ahp_cr()` as in the 06 guide (principal eigenvector, CR = CI/RI,
  Saaty RI vector). RI covers n <= 10 only: return `error` beyond that.
  CR >= 0.10 sets a `consistency_warning` field. Advise, never abort.
- `.dematel_classify()` as in the guide: total-relation matrix
  T = N(I-N)^-1 from the normalised direct matrix, D+R prominence,
  D-R relation, arithmetic-mean threshold, cause/effect role column.
- TOPSIS: vector normalisation, weighted ideal/anti-ideal separation,
  closeness coefficient. VIKOR: S, R, Q with v = 0.5 default and the
  two acceptance conditions evaluated. MOORA: ratio system plus
  reference-point. PROMETHEE II: usual preference function (type 1) by
  default, net flow. ELECTRE I: concordance/discordance matrices with
  standard thresholds in options. SMART: normalised weighted value.
  WASPAS: lambda = 0.5 WSM/WPM blend. ANP: supermatrix limit by power
  iteration with a convergence guard (max 1000 iterations, else error).
- Every numeric fixture in tests carries expected values computed
  by hand or reproduced from the mcdm app, stored as literals with a
  comment naming the source.

## 4. Runners and wiring

Method ids: `topsis`, `vikor`, `ahp`, `dematel`, `moora`, `promethee`,
`electre`, `smart`, `waspas`, `anp`. Family string: `"decision"`
(metadata only). Each runner:

- resolves its inputs through the section 1d order (researcher-supplied
  options first, collected roles via `sframe_assemble_pairwise()` /
  `sframe_collected_weights()` second, typed error third; provenance
  fields recorded), builds `$table` (ranking frame: Alternative, Score,
  Rank — or the DEMATEL cause-effect frame), `apa` (one sentence with
  the top alternative and the key statistic), `prompt` (interpretation
  guidance), and the method-specific raw fields (weights, CR, flows,
  Q values, and the rest).
- AHP additionally returns `cr` and `consistency_warning`; the report
  path renders the warning prominently (check how `error` renders in
  `.render_report_analysis_section()`, `R/reporting.R:752`, and give
  the warning similar visibility).
- Plots: one shared `sframe_plot_decision_ranking()` (horizontal bar of
  scores) for the 7 ranking methods, `sframe_plot_dematel_influence()`
  (prominence vs relation scatter with quadrant lines) for DEMATEL, and
  the ranking bar reused for AHP global weights. Register all in
  `sframe_plot_for_result()`.

## 5. sensitivity_analysis()

New exported function in `R/decision_sensitivity.R` per the 06 guide's
grid logic (perturb each weight by delta = 0.05, renormalise, rerun,
Spearman correlation between base and perturbed rankings). Changes to
the guide: return a classed object `sframe_sensitivity` with `$table`
(criterion, direction, rho, rank_changed) and a `plot()` S3 method
(follow the `plot.sframe_validity_report()` pattern, `R/plots.R:1059`),
plus a print method. Use `rlang`'s `%||%` (already imported). It is also
callable from a plan block via `options$sensitivity = TRUE` on any
ranking method, attaching `$sensitivity` to that result.

## 6. sf_conjoint_design()

Carried in from the mas_review_033.md sf_choices assessment (good fit,
scheduled v0.5). Re-read that assessment first. Scope: a declared
choice-experiment design generator (attributes, levels, fractional
factorial or random subset, declared block count) stored on the
instrument, not an estimator. Analysis of conjoint responses is out of
scope for 0.5 (no runner). If the 45-day window tightens, this is the
first deferral, recorded in `../portfolio-planner/decisions.md`.

## 7. Vignette: vignettes/mcdm-analysis.Rmd

Worked example: 5 hotel vendors, 4 criteria. Researcher-supplied matrix
path plus one collected-weights AHP block assembled from simulated
pairwise columns (so the vignette exercises both halves of the section
1 pipeline). TOPSIS and AHP blocks, sensitivity on
the TOPSIS weights, DEMATEL cause-effect table and influence map in the
rendered report. House rules from 0.3.4: shared WCAG style block,
`lang: en-GB`, `fig.alt` on every chart, offline knit, `set.seed()`.
Check `_pkgdown.yml` for an explicit vignette listing and add it.
axe-core pass through chromote at zero violations (same harness as the
0.3.4 vignette pass).

## 8. Exit checklist

- 10 runners + wiring per the integration checklist, every box, every
  method. The two JS registries updated in lockstep and verified by
  loading the builder and studio and creating one block per method.
- **The section 1g sample sframe is the release gate:** it builds with
  the shipped constructors, validates, round-trips with a stable hash,
  renders on all three survey surfaces, its simulated responses export
  the exact 42 expansion columns listed there, and all 4 plan blocks
  (ahp, hybrid topsis, fully-collected topsis via
  `sframe_rated_matrix()`, dematel) return a table and chart with no
  error field. It ships as the test fixture and the vignette spine.
- Known-value unit tests for all 10 computations; AHP CR both branches;
  DEMATEL threshold and role assignment; input-validator edge cases.
- Data contract (section 1) verified end to end: pairwise and
  constant-sum inputs render on all three surfaces (desktop strip,
  mobile reflow, WCAG-checked), export the section 1c columns from the
  static template and the Sheets collector, read back through
  `read_responses()`, assemble into correct matrices (reciprocal fill
  for AHP, directed cells for DEMATEL), and aggregate (geometric AIJ /
  arithmetic) with drop counts and the per-respondent CR distribution
  reported. Constant-sum totals enforced at entry; incomplete pairwise
  respondents dropped and counted.
- Round-trip: an instrument with both new item types, a decision block
  carrying a 5x4 `options$matrix` with labels, weights, and
  criteria_types, write/read, hash intact, dims and block fields intact
  (`sframe_decision_options()` tests).
- `sensitivity_analysis()` exported, documented, plotted, tested.
- `sf_conjoint_design()` shipped or formally deferred.
- Vignette knits clean offline, axe-core zero violations.
- No new hard Imports. No new Suggests either (all computation base R).
- `devtools::document()` clean; full suite green locally;
  `R CMD check --as-cran` 0/0/<=1 NOTE; win-builder release and devel
  clean; `cran-comments.md` updated; NEWS.md entry written as a clean
  changelog.
- Owner reminders (not engineering): MCDM methodology paper kickoff;
  ASRDA Part XII ch 34-35 revision once the API is final; Ethos
  surfaces MCDM in the following cycle.

---

## Delegation, model tiering, and token budget

Binding policy, same as `todo_0.4.md`. The computation layer is the most
parallelisable work in the roadmap; the wiring is not (single switch,
single plot dispatcher, two JS registries — merge conflicts live there).

### Build order and agent assignment

Phase 1 (lead, Fable/Opus): clone + harvest audit, owner sign-off on
the section 1 data contract (input structures, column encoding,
aggregation defaults), then implement TOPSIS end to end (computation,
runner, wiring, builder/studio entries, tests) as the reference diff
every agent copies, and `R/decision_data.R` (assembly, aggregation,
collected weights) with its full test file — the data layer is the
correctness core of the release and is never delegated.

Phase 2 (parallel, after the reference diff lands):
- **Agent 1 (Sonnet):** AHP + ANP computations and runners (shared
  eigen/supermatrix machinery) + tests.
- **Agent 2 (Sonnet):** DEMATEL computation, runner, influence-map plot
  helper + tests.
- **Agent 3 (Sonnet):** VIKOR, MOORA, SMART, WASPAS + tests (4 similar
  ranking methods, one brief).
- **Agent 4 (Sonnet):** PROMETHEE + ELECTRE + tests (highest-rework per
  the audit; brief includes their audit rows).
- **Agents write computation + runner + tests only.** They do not touch
  `sframe_run_one_block()`, `sframe_plot_for_result()`, or the two JS
  registries — the lead applies all shared-file wiring in one pass after
  the agent diffs land, precisely to avoid 4-way conflicts on the same
  switch statements.
- **Agent 5 (Sonnet):** item types (#2) including the three rendering
  surfaces and their `validatePage()` checks — independent of the
  runners, briefed with section 1b/1c verbatim.
- **Agent 6 (Haiku):** after integration, verification sweeps: run each
  new test file, `devtools::document()`, knit check, NAMESPACE diff.

Phase 3 (lead + one Sonnet agent): sensitivity (#5), conjoint (#6),
vignette (#7), exit checklist. Vignette drafting is delegable; the exit
checklist is not.

### Model tiering

- **Haiku:** test execution, document runs, knit checks, mechanical
  verification, audit-table transcription.
- **Sonnet:** all pattern-following computations/runners/tests, the
  vignette draft, the item-type edits (fully specified above).
- **Opus/Fable:** harvest audit judgement, design decisions, the
  reference implementation, all shared-file wiring, review of every
  delegated diff before merge.

### Token-saving rules (binding)

- Grep for the target function, read only its range. Never read
  `analysis_plan.R` (1500+ lines) or `survey_builder.html` (3000+
  lines) end to end.
- The mcdm repo is read once (audit). The audit table is the sole
  downstream source.
- Agent reports: what changed, file:line, test summary line, surprises.
  Under 15 lines unless something failed.
- No re-reads of unchanged files; batch independent tool calls; Explore
  agents for any search wider than 5 files.
- One `testthat::test_file()` per change; `devtools::test()` full suite
  only at integration and before the tarball build.
