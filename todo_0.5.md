# todo_0.5.md — surveyframe 0.5: Text and open-ended response analysis

> **Owner decision 2026-08-15: swapped with structural models.** This
> file was `todo_0.6.md` until today; the structural-model/semScreenR
> file was `todo_0.5.md`. Text analysis ships first because its scope is
> narrower and self-contained (no new item types, no serialisation work,
> a single new file), and the owner wants it out inside 15 days.
> Structural models moved to `todo_0.6.md`. The original 2027-04-25
> target below predates the swap and is superseded by the 15-day plan.
>
> **Owner decision 2026-08-16: scope expanded after a Voyant Tools /
> qcoder-RQDA gap review.** The original 6-id plan covered counting,
> sentiment, and topic modelling but no visualisation beyond a bar chart
> and a heatmap, and no way to compare groups. Added: a word cloud
> (plot only, no new id), n-gram frequency, a keyword-in-context
> concordance, a `group` role on `term_freq`/`tidy_sentiment`, and a
> VOSviewer-style co-occurrence network (Louvain clustering +
> force-directed layout via a new `igraph` Suggests dependency) — the
> most expensive addition, closer to a day's build, called out
> separately in the exit checklist and delegation sections below.
> **Explicitly out of scope, on purpose**: manual/inductive qualitative
> coding (qcoder/RQDA-style code-and-retrieve, memos, hierarchical code
> schemes). That is a different paradigm, human interpretation versus
> algorithmic counting/clustering, and building it would be closer to
> the 0.4.0 MCDM item-type addition in size than anything that fits
> this release. `extract_quotes()`'s output is deliberately kept clean
> enough to export for a researcher who wants to take it into RQDA or
> qcoder downstream, rather than surveyframe building a coding UI itself.

Dev-only planning file, tracked on `dev` only. Its name is in `.gitignore`
and `.Rbuildignore`. Companion to `CLAUDE.md`, `todo_0.4.md` (whose
"Architecture ground truth" section and integration checklist apply
verbatim here), and
`../portfolio-planner/development_instructions/06_v05_v07_implementation.md`
(v0.6 section — intent only, this file is the verified plan).

Last updated: 2026-08-15. Target CRAN submission: within 15 days
(practical target set 2026-08-15, superseding the 2027-04-25 slot this
file carried before the swap). Theme: structured analysis of open-ended
responses. Source approach: the Omani gateways JMR thematic analysis
(tidytext, quanteda, stm).

Anchors verified against `main` 2026-07-25; re-grep before editing given
the CRAN 0.4.0 work that landed since.

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
| `ngram_freq` | base R | none |
| `term_context` | base R | none |
| `co_occurrence` | base R | none |
| `co_occurrence_network` | igraph | `sframe_require_igraph()` |
| `tidy_sentiment` | tidytext | `sframe_require_tidytext()` |
| `topic_model_lda` | tidytext + topicmodels | guarded both |
| `stm_topics` | stm (+ tidytext for tokenising) | guarded both |
| `quanteda_dfm` | quanteda | guarded |

9 ids total (was 6). `term_freq` and `tidy_sentiment` additionally accept a
`group` role (optional, a nominal/ordinal item id) that splits their
`$table`/`$plot` by that covariate — see section 1a.

Every id goes through the full todo_0.4 integration checklist: switch
case in `sframe_run_one_block()` (`R/analysis_plan.R:1101`), roles
(`item` role: one text/textarea item id; `k` and `seed` in options),
default-roles fallback in `sframe_analysis_roles()`
(`R/statistics_reports.R:57`), `.sframe_citations` entries (harvest and
verify the references used in the Omani gateways manuscript and the
package docs of tidytext/stm/quanteda, plus Blondel et al. 2008 for
Louvain clustering and Fruchterman & Reingold 1991 for the
force-directed layout, both `co_occurrence_network`'s citations — no
unverified citations),
plot cases in `sframe_plot_for_result()` (`R/plots.R:636`), builder
`<optgroup label="Text">` + `ANALYSIS_REGISTRY` entries
(`inst/builder/survey_builder.html` ~969, ~2690), studio registry +
requirements strings (`inst/shiny/app.R` ~324, ~722), block-field
restore if any new field is added (`R/read_write_sframe.R:254` — `k`
and `seed` live in `options`, which already round-trips, so likely
none), tests, `render_results()` render check.

DESCRIPTION Suggests additions: `tidytext (>= 0.4.0)`,
`quanteda (>= 3.0.0)`, `stm (>= 1.3.0)`, `topicmodels`, `igraph (>=
1.5.0)`. All guarded via new `sframe_require_*()` helpers in
`R/conditions.R` (pattern line 26).

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
- `ngram_frequency(text, n = 2L, stop_words = NULL, top_n = 30L)`: same
  shape as `term_frequency()` (term, n, pct) but `term` holds the
  space-joined n-gram; `n = 2` (bigrams) default, `n = 3` (trigrams)
  supported. Base R only (no new tokeniser), built on the same cleaned
  token vector `term_frequency()` produces internally, factored out
  into a shared `.sframe_tokenise(text, stop_words)` helper so the two
  functions can't drift on cleaning rules.
- `term_context(text, term, window = 6L, max_matches = 20L)`: a
  keyword-in-context concordance. Case-insensitive whole-word match on
  `term` against the cleaned tokens, returns a data frame
  (respondent, before, match, after) capped at `max_matches`, `before`/
  `after` each up to `window` words. Base R only (`regmatches()`/
  `gregexpr()`). Renders as a table, no plot.
- Internal `.sframe_cooccurrence(text, top_n)`: pairwise within-response
  co-occurrence counts on the top terms, returning a long data frame
  (term_a, term_b, n) — renders as a table and feeds a heatmap plot, and
  is the edge list `co_occurrence_network` (section 2) builds on.

Runners `sframe_run_term_freq()`, `sframe_run_ngram_freq()`,
`sframe_run_term_context()`, `sframe_run_co_occurrence()` wrap these
into the runner contract (`$table`, `apa` with n_responses and top
term, `prompt`).

## 1a. Group role on `term_freq` and `tidy_sentiment`

Optional `group` role (a nominal/ordinal item id) on `sframe_run_term_freq()`
and `sframe_run_tidy_sentiment()`, resolved the same way `sframe_run_one_block()`
already resolves a `weights`/`weight` role into options
(`R/analysis_plan.R:1092`). When present: `$table` gains a `group`
column (one block of rows per group level), and the matching plot
(`sframe_plot_term_frequency()`/`sframe_plot_sentiment()`) facets by
group instead of drawing one panel. Absent `group`: identical output to
today, this is additive, not a breaking change to the existing 2 ids.
Minimum-response guard (section 2) applies per group, not just overall,
so a group with too few responses is flagged rather than silently
producing a 1-response "trend."

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
- `sframe_run_cooccurrence_network()`: builds an `igraph` graph from
  `.sframe_cooccurrence()`'s edge list (term_a, term_b, n as edge
  weight), runs `igraph::cluster_louvain()` for thematic clustering and
  `igraph::layout_with_fr()` for the force-directed layout, both seeded
  (`set.seed(options$seed %||% 42)`) since Louvain's tie-breaking is not
  deterministic across runs otherwise. `$table`: term, frequency,
  cluster, x, y (one row per node). `apa`: n terms, n edges, n clusters,
  modularity score. The `igraph` object is **stripped before
  serialisation** (same rule as the STM/lavaan fits) — keep only the
  plain data frame. Minimum-content guard: needs at least 5 distinct
  terms with at least 1 edge between them to be meaningful; below that,
  the same `list(test = id, error = ...)` shape as the response-count
  guard below, keyed on edge count instead of response count.
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

- `sframe_plot_term_frequency()`: horizontal bar, top 20 terms; facets
  by `group` when the `group` role (section 1a) is present. When
  `options$wordcloud = TRUE` (default `FALSE`, opt-in per the strict-scope
  principle already used elsewhere), draws a word cloud instead — same
  `term_frequency()` table, size mapped to frequency, base
  `ggplot2::geom_text()` positions (a simple spiral/grid layout, no new
  dependency; do not add a `wordcloud`/`ggwordcloud` package for this).
- `sframe_plot_ngram_frequency()`: horizontal bar, top 20 n-grams, same
  shape as `sframe_plot_term_frequency()` (shared internal helper, not a
  copy-paste).
- `sframe_plot_cooccurrence()`: tile heatmap of the top-term pairs.
- `sframe_plot_cooccurrence_network()`: points at the `x`/`y` layout
  coordinates from `sframe_run_cooccurrence_network()`, sized by
  frequency, edges as line segments, colour = cluster. The categorical
  palette needs a dataviz-skill check once real cluster counts are
  known — more than about 8 clusters needs an explicit fallback (e.g.
  "Other"), not hue cycling, per the palette formula's own rule.
- `sframe_plot_sentiment()`: diverging bar of sentiment counts (reuse
  the diverging-chart machinery from
  `sframe_draw_likert_diverging()` where sensible); facets by `group`
  when present.
- `sframe_plot_topics()`: faceted top-terms bars, one facet per topic
  (serves both LDA and STM results).

## 5. Vignette: vignettes/text-analysis.Rmd

Per the guide's outline (instrument with text items beside Likert
items, clean + term_frequency + ngram_frequency, term_context on one
keyword, co-occurrence + co_occurrence_network, a group-role example
on term_freq, STM with k = 3 guarded, quotes per topic, the rendered
report section). Simulated text via a seeded sampler over a small
phrase bank defined in the vignette. House rules: WCAG style block,
`lang: en-GB`, `fig.alt`, offline knit, axe-core zero violations. Every
guarded chunk knits cleanly when the engine is absent.

## 6. Exit checklist

- `clean_text_responses()`, `term_frequency()`, `ngram_frequency()`,
  `term_context()`, `extract_quotes()` exported and documented;
  internal runners for all 9 ids wired through every
  integration-checklist point including both JS registries.
- `term_freq`, `ngram_freq`, `term_context`, and `co_occurrence` fully
  functional with only hard Imports installed (verified in a
  no-Suggests library) — `co_occurrence_network` is the one base-family
  id that is NOT hard-Import-only, since it needs `igraph`; document
  this exception explicitly rather than letting the "5 base ids" count
  quietly include it.
- 5 Suggests added (tidytext, quanteda, stm, topicmodels, igraph), all
  guarded; `$fit`/`igraph` objects stripped before any serialisation.
- Minimum-response guard tested for every runner; minimum-edge guard
  tested for `co_occurrence_network`; `group`-role guard tested (a
  group below the response floor is flagged, not silently included);
  seed determinism tested for LDA, STM, and Louvain clustering (same
  seed, same top terms / same cluster assignment).
- Word cloud plot tested with a real `term_frequency()` table (label
  overlap at high term counts is the concrete failure mode to check
  for, not just "it renders").
- Vignette knits with and without engines, axe-core clean.
- `devtools::document()`; full suite; `R CMD check --as-cran`
  0/0/<=1 NOTE both with and without Suggests; win-builder both
  flavours; `cran-comments.md`; NEWS.md.
- Owner reminders: text methodology paper (per-release rule); ASRDA
  Part III ch 8 and Part VII ch 17 become real here; Ethos surfaces
  text analysis next cycle.

---

## Delegation, model tiering, and token budget

Binding policy per `todo_0.4.md`. Same conflict rule as 0.4: agents
deliver computations + runners + tests in `R/text_analysis.R` and plot
helpers in standalone diffs; the lead applies all shared-file wiring
(switch, plot dispatcher, JS registries, conditions helpers) in one
pass.

### Build order and agent assignment

- **Lead (Fable/Opus):** implement `term_freq` end to end as the
  reference diff (cleaning function, runner, plot including the word
  cloud, wiring, test), settle the `$quotes` rendering pattern against
  the real `.render_report_analysis_section()` code, and settle the
  `group`-role resolution pattern (section 1a) as its own small
  reference diff before Agent 1 builds on it.
- **Agent 1 (Sonnet):** `ngram_freq` + `term_context` + tests (shares
  `.sframe_tokenise()` with the reference diff, brief accordingly).
- **Agent 2 (Sonnet):** `co_occurrence` + its heatmap + tests, then
  `group`-role wiring into `tidy_sentiment` once the lead's reference
  pattern lands.
- **Agent 3 (Sonnet):** `tidy_sentiment` + `quanteda_dfm` + tests.
- **Agent 4 (Sonnet):** `topic_model_lda` + `stm_topics` +
  `extract_quotes()` + tests (one brief, shared tokenising machinery).
- **Agent 5 (Sonnet, reviewed closely by lead):**
  `co_occurrence_network` + its plot + tests — the most expensive
  single item, budget it as its own diff rather than folding it into
  Agent 2's co-occurrence work, since Louvain determinism and the
  cluster-count palette fallback are both genuine correctness/design
  risks, not routine wiring.
- **Agent 6 (Sonnet):** vignette after the runners land.
- **Agent 7 (Haiku):** verification sweeps; the no-Suggests library
  check run; seed-determinism test executions (LDA, STM, and Louvain).

### Model tiering

- **Haiku:** sweeps, document runs, knit checks, no-Suggests runs.
- **Sonnet:** all runners after the reference diff, plots, vignette.
- **Opus/Fable:** the reference diff, the quotes-rendering decision,
  the `group`-role resolution pattern, shared-file wiring, review of
  every delegated diff (STM tokenising, the respondent mapping, and the
  Louvain/layout determinism in `co_occurrence_network` are the
  correctness risks).

### Token-saving rules (binding)

The same 6 rules as todo_0.4. Addition: the phrase bank and
simulated-text sampler are written once in the vignette and copied into
test fixtures, not regenerated ad hoc by each agent.
