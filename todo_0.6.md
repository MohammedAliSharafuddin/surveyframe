# todo_0.6.md — surveyframe 0.6: Text and open-ended response analysis

Dev-only planning file, tracked on `dev` only. Its name is in `.gitignore`
and `.Rbuildignore`. Companion to `CLAUDE.md`, `todo_0.4.md` (whose
"Architecture ground truth" section and integration checklist apply
verbatim here), and
`../portfolio-planner/development_instructions/06_v05_v07_implementation.md`
(v0.6 section — intent only, this file is the verified plan).

Last updated: 2026-07-25. Target CRAN submission: 2027-04-25. Theme:
structured analysis of open-ended responses. Source approach: the Omani
gateways JMR thematic analysis (tidytext, quanteda, stm).

Anchors verified against `main` 2026-07-25; re-grep before editing.

---

## Ground truth specific to this release

- `"text"` and `"textarea"` item types already exist in the `sf_item()`
  enum (`R/sf_item.R:53-56`). No new item types, no serialisation work,
  no builder item-inspector work.
- The 06 guide proposes a `render_text_section()` in `R/reporting.R`.
  **Do not build it.** Since 0.3.4, `.render_report_analysis_section()`
  (`R/reporting.R:752`) renders any result generically from `$table`,
  `$plot`, `apa`, and the interpretation fields. Text runners that
  return a proper `$table` and `$plot` flow through the report, the
  studio Analyse cards, and `render_results()` with zero reporting-side
  code. Quote lists are the one shape that may not fit a table; check
  how `syntax` results render (`R/reporting.R`, the analysis section
  branch for `result$syntax`) and mirror that pattern for a
  `$quotes` field if needed — that is the only permissible reporting
  change.
- Central humanisation (`sframe_humanize_table()`) maps coded values to
  labels; free-text terms are not coded values, so text tables pass
  through unchanged. No work needed, just awareness.
- Base path must work with zero optional packages (jsonlite, rlang,
  openssl only).

## Method ids and their wiring

Family string `"text"` (metadata). Ids, per the 06 guide's table:

| id | Engine | Guard |
|---|---|---|
| `term_freq` | base R | none |
| `co_occurrence` | base R | none |
| `tidy_sentiment` | tidytext | `sframe_require_tidytext()` |
| `topic_model_lda` | tidytext + topicmodels | guarded both |
| `stm_topics` | stm (+ tidytext for tokenising) | guarded both |
| `quanteda_dfm` | quanteda | guarded |

Every id goes through the full todo_0.4 integration checklist: switch
case in `sframe_run_one_block()` (`R/analysis_plan.R:1101`), roles
(`item` role: one text/textarea item id; `k` and `seed` in options),
default-roles fallback in `sframe_analysis_roles()`
(`R/statistics_reports.R:57`), `.sframe_citations` entries (harvest and
verify the references used in the Omani gateways manuscript and the
package docs of tidytext/stm/quanteda — no unverified citations),
plot cases in `sframe_plot_for_result()` (`R/plots.R:636`), builder
`<optgroup label="Text">` + `ANALYSIS_REGISTRY` entries
(`inst/builder/survey_builder.html` ~969, ~2690), studio registry +
requirements strings (`inst/shiny/app.R` ~324, ~722), block-field
restore if any new field is added (`R/read_write_sframe.R:254` — `k`
and `seed` live in `options`, which already round-trips, so likely
none), tests, `render_results()` render check.

DESCRIPTION Suggests additions: `tidytext (>= 0.4.0)`,
`quanteda (>= 3.0.0)`, `stm (>= 1.3.0)`, `topicmodels`. All guarded via
new `sframe_require_*()` helpers in `R/conditions.R` (pattern line 26).

---

## 1. R/text_analysis.R — cleaning and base-R analysis

New file, house header comment. Exported:

- `clean_text_responses(data, item_id, lowercase = TRUE, remove_punct =
  TRUE, strip_numbers = FALSE)` per the guide, plus: validate `item_id`
  is a text/textarea item when an instrument is supplied (optional
  `instrument` arg), and keep a `respondent` attribute mapping cleaned
  entries back to row indices so quotes can cite a respondent id later.
- `term_frequency(text, stop_words = NULL, top_n = 30L)` per the guide
  (data frame: term, n, pct). Ship a small built-in English stop-word
  vector (base R constant, ~150 words, sourced and licence-checked) so
  the base path has sensible defaults without tidytext; `stop_words =
  NULL` means use it, `character(0)` means none.
- Internal `.sframe_cooccurrence(text, top_n)`: pairwise within-response
  co-occurrence counts on the top terms, returning a long data frame
  (term_a, term_b, n) — renders as a table and feeds a heatmap plot.

Runners `sframe_run_term_freq()`, `sframe_run_co_occurrence()` wrap
these into the runner contract (`$table`, `apa` with n_responses and
top term, `prompt`).

## 2. Guarded engines

- `sframe_run_tidy_sentiment()`: tidytext + a dictionary; default
  "bing" (shipped inside tidytext, no download). `$table`: sentiment
  counts and proportion positive; per-response scores kept in the
  result for the plot.
- `sframe_run_topic_model_lda()`: tokenise with tidytext, cast to a
  document-term matrix, `topicmodels::LDA(k, control = list(seed))`.
  `$table`: top 10 terms per topic with beta.
- `sframe_run_stm_topics()`: per the guide's sketch but with the
  tokenising corrected (the guide's `unnest_tokens` call passes bare
  symbols into a function context; write and test it properly), fixed
  `set.seed(options$seed %||% 42)` before fitting, `$table`: topic,
  proportion, top terms. Model object kept under `$fit` and **stripped
  before serialisation** (same rule as the 0.6 lavaan fits).
- `sframe_run_quanteda_dfm()`: dfm summary (features, sparsity, top
  features table).
- All runners return `list(test = id, error = ...)` when the item has
  fewer than a documented minimum of usable responses (suggest 10);
  small-n text analysis produces garbage silently otherwise.

## 3. extract_quotes()

Exported per the guide (`extract_quotes(model, text, n_quotes = 3L)`),
generalised: accept the `stm_topics` result object (not the raw stm
model) so it can read `$fit` and the respondent mapping from #1, and
return a data frame (topic, rank, respondent, quote) that renders as a
table. When the runner ran inside a plan, quotes attach to the result
as `$quotes` and render via the reporting pattern settled in the
ground-truth section.

## 4. Plots

In `R/plots.R`, ggplot2-guarded, both palettes, registered in
`sframe_plot_for_result()`:

- `sframe_plot_term_frequency()`: horizontal bar, top 20 terms.
- `sframe_plot_cooccurrence()`: tile heatmap of the top-term pairs.
- `sframe_plot_sentiment()`: diverging bar of sentiment counts (reuse
  the diverging-chart machinery from
  `sframe_draw_likert_diverging()` where sensible).
- `sframe_plot_topics()`: faceted top-terms bars, one facet per topic
  (serves both LDA and STM results).

## 5. Vignette: vignettes/text-analysis.Rmd

Per the guide's outline (instrument with text items beside Likert
items, clean + term_frequency, co-occurrence, STM with k = 3 guarded,
quotes per topic, the rendered report section). Simulated text via a
seeded sampler over a small phrase bank defined in the vignette. House
rules: WCAG style block, `lang: en-GB`, `fig.alt`, offline knit,
axe-core zero violations. Every guarded chunk knits cleanly when the
engine is absent.

## 6. Exit checklist

- `clean_text_responses()`, `term_frequency()`, `extract_quotes()`
  exported and documented; internal runners for all 6 ids wired through
  every integration-checklist point including both JS registries.
- `term_freq` and `co_occurrence` fully functional with only hard
  Imports installed (verified in a no-Suggests library).
- 4 Suggests added, all guarded; `$fit` objects stripped before any
  serialisation.
- Minimum-response guard tested for every runner; seed determinism
  tested for LDA and STM (same seed, same top terms).
- Vignette knits with and without engines, axe-core clean.
- `devtools::document()`; full suite; `R CMD check --as-cran`
  0/0/<=1 NOTE both with and without Suggests; win-builder both
  flavours; `cran-comments.md`; NEWS.md.
- Owner reminders: text methodology paper (per-release rule); ASRDA
  Part III ch 8 and Part VII ch 17 become real here; Ethos surfaces
  text analysis next cycle.

---

## Delegation, model tiering, and token budget

Binding policy per `todo_0.4.md`. Same conflict rule as 0.4/0.5: agents
deliver computations + runners + tests in `R/text_analysis.R` and plot
helpers in standalone diffs; the lead applies all shared-file wiring
(switch, plot dispatcher, JS registries, conditions helpers) in one
pass.

### Build order and agent assignment

- **Lead (Fable/Opus):** implement `term_freq` end to end as the
  reference diff (cleaning function, runner, plot, wiring, test), and
  settle the `$quotes` rendering pattern against the real
  `.render_report_analysis_section()` code.
- **Agent 1 (Sonnet):** `co_occurrence` + its heatmap + tests.
- **Agent 2 (Sonnet):** `tidy_sentiment` + `quanteda_dfm` + tests.
- **Agent 3 (Sonnet):** `topic_model_lda` + `stm_topics` +
  `extract_quotes()` + tests (one brief, shared tokenising machinery).
- **Agent 4 (Sonnet):** vignette after the runners land.
- **Agent 5 (Haiku):** verification sweeps; the no-Suggests library
  check run; seed-determinism test executions.

### Model tiering

- **Haiku:** sweeps, document runs, knit checks, no-Suggests runs.
- **Sonnet:** all runners after the reference diff, plots, vignette.
- **Opus/Fable:** the reference diff, the quotes-rendering decision,
  shared-file wiring, review of every delegated diff (STM tokenising
  and the respondent mapping are the correctness risks).

### Token-saving rules (binding)

The same 6 rules as todo_0.4/todo_0.5. Addition: the phrase bank and
simulated-text sampler are written once in the vignette and copied into
test fixtures, not regenerated ad hoc by each agent.
