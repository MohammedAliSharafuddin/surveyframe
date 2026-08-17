# Handover: the 0.5 text-analysis review suite

Built 2026-08-17. **The suite is complete.** Both numbered files render with
0 errors, 0 DIFFERS, 0 CHECK, against the fixed code (2 real defects were
found in the first pass and are now fixed; see section 2).

---

## 1. What exists

| File | Covers | Comparisons |
|---|---|---|
| `00_start_here.qmd` | index, how to read a verdict, environment check | 0 (checkboxes only) |
| `01_base_text_methods.qmd` | `term_freq` (incl. `group` role, word cloud), `ngram_freq`, `term_context`, `co_occurrence` | 12 |
| `02_guarded_text_methods.qmd` | `tidy_sentiment`, `quanteda_dfm`, `co_occurrence_network` (seed determinism), `topic_model_lda` (skips, see below), `stm_topics`, `extract_quotes()` | 16 |

28 checked numbers across the 2 automated files. There is no file `03`:
this scope (1 new file, no new item types, no serialisation work) does not
need a third file, and padding the count to look more like `review_040`
would not add review value.

`_setup.R` is `review_040/_setup.R` with 2 changes: the "is this build
loaded" check now tests for `extract_quotes` (new in 0.5) instead of
`sensitivity_analysis` (new in 0.4.0), and the fallback load path is
`devtools::load_all("..")` from inside `review_050/` (the current `dev`
checkout, since this work has never been pushed or released) rather than a
sibling `../surveyframe-v0.5-dev` worktree. Every comparison helper
(`compare_row`, `compare_table`, `compare_report`, `sf_log`, `sf_verdict`,
`sf_both_routes`, `sf_html_route`, `sf_answer_template`, `sf_columns`,
`sf_fixture`) is unchanged from `review_040`.

### Running this suite

Always `cd review_050` first; `quarto render` fails with "No valid input
files" from the repo root. This suite has no installed-build fallback the
way `review_040` does (`remotes::install_github(...)` would not carry this
work, since it has never been pushed): `_setup.R` always
`devtools::load_all("..")`s the current checkout.

```bash
cd review_050 && timeout 900 quarto render 01_base_text_methods.qmd --to html 2>&1 | tail -5
cd review_050 && timeout 900 quarto render 02_guarded_text_methods.qmd --to html 2>&1 | tail -5
```

### File template

Identical to `review_040`'s: read `review_040/HANDOVER.md` section 3
rather than re-deriving it here. One deliberate scope reduction, explained
in `00_start_here.qmd`: neither file here runs `sf_both_routes()` in full
(both a static-HTML and a Shiny round trip). 0.5 adds no item type and
changes nothing about how a `text`/`textarea` item collects on either
route, so the routes were already proven by `review_040`'s own field-type
file; both files here still check the HTML route (`sf_html_route()`) as a
sanity confirmation that the item reaches the export.

---

## 2. The findings

Two, both real. **Both are now fixed** (commits `9d97ed2` and `3085dbb`),
verified by re-running this suite against the fixed code, and both files
are rewritten to check the fix rather than assert the defect. This
departs from the dogfeed protocol (log, don't fix) on the lead's judgement
that both were narrow, high-confidence corrections directly in the release
being reviewed, not a broader design question needing a separate decision.

| # | Finding | File | Severity | Status |
|---|---|---|---|---|
| 1 | `sframe_humanize_table()` silently relabelled free-text term/keyword/co-occurrence columns when a word happened to collide with an unrelated item's choice code | `01`, sections 4a, 5, 6 | Computation-adjacent: the underlying counts were correct, but the label attached to the top result was wrong and gave no error | **Fixed**, `9d97ed2` + `3085dbb` |
| 2 | `extract_quotes()` (not just its roxygen) treated the raw and `clean_text_responses()`-cleaned text vectors as interchangeable | `02`, section 9 | Silently misattributed a quote to the wrong respondent once any earlier response was dropped | **Fixed**, `9d97ed2` |

### Finding 1 in full

`run_analysis_plan()` (`R/analysis_plan.R`) used to apply
`sframe_humanize_table(result$table, sframe_label_lookup(instrument))` to
every block's result table, unconditionally. `sframe_label_lookup()`
(`R/utils.R`) builds one flat map covering every item id, scale id, and
every choice code across the **whole instrument**, and
`sframe_humanize_table()` substituted it into **every character column**
by exact string match, with no column-level awareness of what the column
actually held. That was correct for a `group` column (a genuine coded
value) and wrong for `term_freq`'s `term` column, `co_occurrence`'s
`term_a`/`term_b`, and `term_context`'s `match` column, all of which hold
free-text vocabulary that shares no semantic relationship with any item's
choice codes. When a respondent's own word was spelled exactly like some
other item's coded value anywhere in the instrument, the count or match
was silently attributed to that item's label instead of the word that was
actually found.

Confirmed with a mutation check in `01`'s section 4a: rebuilding the same
24 responses on an instrument whose choice codes were renamed away from
ordinary vocabulary (`"front_desk_dept"`/`"pool_dept"` instead of
`"front_desk"`/`"pool"`) made the same top term correctly read `"pool"`,
`n = 20`. Nothing about the counting was ever wrong; only the label was,
and only because of the incidental string collision. `ngram_freq` was
structurally far less exposed (a choice code would have to equal an exact
multi-word phrase to collide with a bigram) but not provably immune.

**The fix went through two attempts.** The first (`9d97ed2`) excluded a
text-family result's whole table from label substitution, which closed
the collision but also silently stopped humanising a genuinely coded
column on the *same* table (`term_freq`'s own `group` column) — caught
while re-verifying this fix against this exact review file, not by any
test, since the original regression test happened not to exercise a
grouped result. The second (`3085dbb`) made the exclusion column-scoped
instead of table-scoped: `sframe_humanize_table()` gained an
`exclude_cols` argument, and `.sframe_text_free_text_cols` in
`R/text_analysis.R` lists exactly which columns are free text per method
id (`term`, `term_a`/`term_b`, `before`/`match`/`after`), leaving every
other column, `group` included, humanising exactly as before. Section 4a
now also asserts the `group`-still-humanised half directly.

### Finding 2 in full

See `02`'s section 9. `extract_quotes()` used to index whatever `text` it
was given directly by the original-row respondent map:
`doc_texts <- as.character(text)[respondent_map]`. That was correct only
when `text` had exactly one entry per original data-frame row, which the
raw response vector does and the `clean_text_responses()`-cleaned vector
does not (cleaning drops blank/missing rows, compacting the vector).
Demonstrated with a 12-row fixture carrying 1 blank response at row 5:
calling `extract_quotes(model, fb_raw, ...)` correctly attributed
respondent 10's quote to `fb_raw[10]`; calling
`extract_quotes(model, cl_fixture, ...)` (the compacted cleaned vector)
silently attributed respondent 10's quote to `fb_raw[11]`, a different
respondent's text entirely, with no error.

**The fix (`9d97ed2`) is in the function, not just the docs.**
`extract_quotes()` now reads `attr(text, "respondent")` when present (a
`clean_text_responses()` vector carries it) to map each quote back to its
real position, and falls back to the old 1:1-by-row behaviour when the
attribute is absent (a raw vector). Both forms now return the same,
correctly-attributed quotes for the same respondent, re-verified above by
comparing the cleaned-vector call's respondent-10 entry against
`cl_fixture`'s own respondent-10 entry directly, and confirming it is
**not** `cl_fixture`'s respondent-11 entry (the exact shifted-by-one
failure mode the bug produced). The roxygen is rewritten to describe both
supported forms.

---

## 3. What skipped, and why that is expected

`topic_model_lda` (`02`, section 7) skips cleanly: `topicmodels` is not
installed in this environment
(`Rscript -e 'requireNamespace("topicmodels", quietly=TRUE)'` returns
`FALSE`), `sframe_run_topic_model_lda()` calls
`sframe_require_topicmodels()` before any LDA-specific code runs, and
`run_analysis_plan()` degrades to a `$error` result rather than throwing.
The guard chunk uses `eval = requireNamespace(...)`, the same pattern the
vignette uses. A reviewer with `topicmodels` installed should see the
section's first chunks execute and can extend the file with a
`tidytext::tidy(topicmodels::LDA(...), matrix = "beta")` reference built
directly, the same pattern already used for `stm_topics`.

---

## 4. Verified result field names for the 9 text-analysis methods

Derived by running each runner directly (`sframe_run_*()`) and printing
`names()`, in one batch rather than through render-cycle trial and error.

| Method | Runner | Fields |
|---|---|---|
| `term_freq` | `sframe_run_term_freq()` | `test variable n table apa prompt`; grouped adds `group`. `table` columns `term n pct` (plain) or `group term n pct note` (grouped) |
| `ngram_freq` | `sframe_run_ngram_freq()` | `test variable n table apa prompt`; `table` columns `term n pct` |
| `term_context` | `sframe_run_term_context()` | `test variable term table apa prompt`; `table` columns `respondent before match after` |
| `co_occurrence` | `sframe_run_co_occurrence()` | `test variable n table apa prompt`; `table` columns `term_a term_b n` |
| `co_occurrence_network` | `sframe_run_cooccurrence_network()` | `test variable n table edges apa prompt`; `table` columns `term frequency cluster x y`; `edges` columns `term_a term_b n` |
| `tidy_sentiment` | `sframe_run_tidy_sentiment()` | `test variable n table scores apa prompt`; grouped adds `group`. `table` columns `sentiment n prop` (plain) or `group sentiment n prop note` (grouped); `scores` columns `respondent positive negative score` |
| `quanteda_dfm` | `sframe_run_quanteda_dfm()` | `test variable n table top_features apa prompt`; `table` is a 1-row summary (`n_responses n_features sparsity`); `top_features` columns `term n` |
| `topic_model_lda` | `sframe_run_topic_model_lda()` | `test variable n table fit apa prompt`; `table` columns `topic term beta rank`; `fit` holds `model` (runtime-only) and `dtm_respondent` |
| `stm_topics` | `sframe_run_stm_topics()` | `test variable n table fit apa prompt`; `table` columns `topic proportion term beta rank`; `fit` holds `model` (runtime-only) and `respondent` |

Standalone functions (usable outside the analysis-plan dispatch):

```
clean_text_responses(data, item_id, lowercase, remove_punct, strip_numbers, instrument)
                                        # returns a character vector with an integer
                                        # "respondent" attribute = original row index;
                                        # COMPACTED, i.e. length < nrow(data) if any
                                        # response was blank/missing.
term_frequency(text, stop_words = NULL, top_n = 30L)     # term, n, pct
ngram_frequency(text, n = 2L, stop_words = NULL, top_n = 30L)  # term, n, pct
term_context(text, term, window = 6L, max_matches = 20L) # respondent, before, match, after
extract_quotes(model, text, n_quotes = 3L)                # topic, rank, respondent, quote
                                        # `model` must be a stm_topics result list
                                        # (i.e. run_analysis_plan()'s $fit-carrying
                                        # element, or sframe_run_stm_topics()'s own
                                        # return value directly), not the raw stm
                                        # object and not $fit alone.
```

### Plot dispatch (`sframe_plot_for_result()`)

```
term_freq              -> sframe_plot_term_frequency()   # bar, or word cloud if
                                                            # result$options$wordcloud
ngram_freq              -> sframe_plot_ngram_frequency()  # bar only, no group facet
co_occurrence            -> sframe_plot_cooccurrence()     # tile heatmap
co_occurrence_network    -> sframe_plot_cooccurrence_network()
tidy_sentiment            -> sframe_plot_sentiment()        # diverging bar
topic_model_lda, stm_topics -> sframe_plot_topics()         # shared, same table shape
term_context, quanteda_dfm  -> no plot (table only, by design)
```

`result$options$wordcloud` is read off `result$options`, which
`run_analysis_plan()` attaches from `block$options` after dispatch (`R/analysis_plan.R`
line ~1325); it is not read from the runner's own return value.

### Minimum-response guards

Every text runner shares one constant,
`.sframe_text_min_responses <- 10L` (`R/text_analysis.R`), below which it
returns `list(test = <id>, error = <message>)` rather than computing. This
matters for building a small fixture (as in `02`'s `extract_quotes()`
section): a fixture needs at least 10 **usable** (non-blank) responses
after `clean_text_responses()` drops blanks, not 10 raw rows.
`co_occurrence_network` additionally guards on
`.sframe_cooccurrence_min_terms <- 5L` distinct terms with at least 1 edge.

---

## 5. Reference-call traps found in this suite, not already in `review_040/HANDOVER.md`

| Trap | Correct handling |
|---|---|
| `term_frequency()`/`ngram_frequency()`/`.sframe_cooccurrence()` all share `.sframe_tokenise()`, an internal helper — calling it as the "reference" makes a comparison vacuous | Write an independent tokeniser inline in the `.qmd` (lower-case, strip non `[a-z0-9' ]`, split on whitespace) rather than calling `surveyframe:::.sframe_tokenise()`. Pass `stop_words = character(0)` on the surveyframe side so the independent reference does not also have to reproduce the built-in English stop-word list to agree |
| `sframe_humanize_table()`'s `exclude_cols` argument (added by finding 1's fix) is opt-in per column name, not automatic | A future text-family runner that adds a new free-text column must add its name to `.sframe_text_free_text_cols[[<test id>]]` in `R/text_analysis.R` itself, or that column silently regains the finding-1 exposure; there is no structural guard that catches a missing entry |
| `extract_quotes(model, text, ...)` now accepts either the raw or the `clean_text_responses()`-cleaned vector correctly (finding 2's fix), but a comparison built to demonstrate the *pre-fix* behaviour must compare respondent attribution, not literal quote text | The cleaned-vector call legitimately returns lower-cased, punctuation-stripped text, so it is never literally `identical()` to the raw string even when correct; compare against `clean_text_responses()`'s own respondent-indexed entry instead (see `02` section 9's `quotes-trap-cmp` chunk for the pattern) |
| STM needs `.sframe_text_min_responses` (10) **usable** responses to fit at all, and `K=2` throws a `stm::stm()` message ("K=2 is equivalent to a unidimensional scaling model") that is not an error | Build fixtures with at least 10 non-blank rows; treat the K=2 message as expected noise, not a finding, and suppress it with `warning: false` at the chunk-option level the way the rest of the suite already does |
| `igraph::cluster_louvain()` and `igraph::layout_with_fr()` both draw on R's RNG stream | Reseed with `set.seed()` immediately before each call, not once at the top of a chunk, mirroring `sframe_run_cooccurrence_network()`'s own approach, or a same-seed reproducibility check can pass by accident while the individual calls are not actually reseeded correctly |
| `quanteda::dfm(quanteda::tokens(x))`'s feature count depends on whether punctuation was already stripped | Build the reference dfm from the *same* `clean_text_responses()`-cleaned text the package's own runner uses (punctuation already removed there), not from raw survey text, or feature counts will disagree for a reason that has nothing to do with `quanteda_dfm`'s own correctness |
| `tidytext::get_sentiments("bing")` requires a one-time interactive download the first time it is called in a fresh R session (a `textdata`-style prompt) in some environments | Not encountered in this environment (already cached), but if a fresh CI runner hits this, it is an environment setup issue, not a package defect |

---

## 6. Release context

This suite reviews `R/text_analysis.R` and its wiring into
`R/analysis_plan.R`, `R/plots.R`, `R/conditions.R`, `R/statistics_reports.R`,
and `DESCRIPTION`, all present on `dev` at commit `a0add1e` ("Merge branch
'main' into dev"). This work has not been pushed to any remote and is not
on `main`. See `todo_0.5.md` for the full 9-method-id build plan and
`CLAUDE.md`'s "In flight" section for where 0.5 sits relative to the held
0.4.0 CRAN submission.
