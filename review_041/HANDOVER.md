# Handover: the 0.4.1 review suite

Written 2026-08-28. Read `review_040/HANDOVER.md` first if you have not: the
file template, the comparison helpers, the token-saving rules, and its 16
reference-call traps all apply here unchanged and are not repeated.

---

## 1. What exists

| File | Covers |
|---|---|
| `_setup.R` | `review_040/_setup.R` plus the coverage ledger and the Quarto probes |
| `00_start_here.qmd` | index, what is new, how to run it |
| `01_function_coverage.qmd` | all 123 exports, smoke-called, with the gaps named |
| `02_quarto_reproducibility.qmd` | the 2 render engines, reproducibility, the audit chain |

Rendered `.html` is gitignored. Only the sources are tracked.

## 2. What the first run found

Three findings, all logged in `dogfeed.todo.md`.

**1. The rendered report is not reproducible.** `run_analysis_plan()` gives
different answers on identical inputs: 32 of 1768 values move between 2 runs.
Five bootstrap CI helpers (`R/analysis_plan.R` lines 315, 422, 492, 546, 653)
call `bootstrap_ci()` and its relatives without a seed, and `bootstrap_ci()`
defaults `seed = NULL`. The EFA path inherits `psych::fa.parallel()`'s own
unseeded simulation. The published confidence interval changes between
renders while the test statistic and p value stay put. This is the finding
that matters most, because it undercuts the report's standing as evidence.

**2. `render_report()` does not say which engine rendered it.** It prefers
Quarto and falls back to a base-R HTML writer, silently. The 2 artefacts are
5.8 MB and 1.9 MB from identical inputs. Both paths return the destination
path and nothing else, so a caller cannot tell which they got. `_setup.R`'s
`sf_report_engine()` works it out by reading the artefact, which is the only
route available from outside.

**3. `sframe_plot_quality()` returns `NULL` on the bundled demo, a
regression from a 0.4.1 fix.** `straightline_min_items` now defaults to 4,
correctly, and all 5 demo scales are 2 or 3 items, so every scale comes back
`checked = FALSE` with `flag_rate = NA`. The plot drops the NA rows, finds
none left, and returns `NULL`. The chart disappears from the report with
nothing said. Found on a function no test and no review file had ever called.

## 3. What is not covered yet

The suite covers breadth and the report. It does not repeat the per-method
accuracy work, which `review_040` still does correctly for the statistics and
`review_050` for text. Files that would complete it, in the order worth
writing them:

| File | Would cover | Why it matters |
|---|---|---|
| `03_branching.qmd` | every operator in `sf_branch()`, both value shapes, all 3 evaluators, driven in a browser | the `%in%` defect shipped for 3 releases and lived here |
| `04_collection_integrity.qmd` | the Apps Script collector against a mock Sheets API, including an instrument change mid-collection | the header-drift defect corrupted collected data silently |
| `05_generated_syntax.qmd` | lavaan and seminr syntax **fitted**, not parsed | a parse check passed the mediation defect for 3 releases |
| `06_can_it_say_no.qmd` | every exported function on empty, all-missing, and degenerate input | the recurring failure shape in this package, per `TESTING.md` |

Files 03 to 05 now have unit-test equivalents in `tests/testthat/`, added
2026-08-27 and 2026-08-28, so their value here is the reviewer-facing
narrative rather than first detection. File 06 has no equivalent anywhere and
is the highest-value one left.

## 4. The coverage ledger, and how not to fool it

`sf_coverage_ledger()` reads `getNamespaceExports()` at render time. That is
deliberate: a hard-coded list would drift, and a suite that reports full
coverage against a stale list is worse than one that reports none.

Two ways to get a dishonest green, both worth guarding against:

- **Passing `also_called_in` too widely.** It credits any function whose name
  appears followed by `(` in the scanned `.qmd` sources. That is a text match,
  not an execution. Use it for functions genuinely called in workflow chunks,
  not to paper over gaps.
- **Marking something `skip` to make the row go away.** A skip needs a reason
  in `note` that a reader can disagree with. "Needs a browser" and "starts a
  Shiny app" are reasons. "Hard to call" is not.

The ledger counts `ERROR` rows as needing attention, and on the first draft
of file 01 **8 of them were mine, not the package's**: wrong argument order,
an argument that does not exist, a `mode` value that is not accepted, and a
plot builder handed a report where it wanted a solution. Two more turned out
to be the package correctly refusing bad input, which is the behaviour you
want. Attribute before reporting, every time.

## 5. Quarto probes

| Helper | Use |
|---|---|
| `sf_quarto_available()`, `sf_quarto_version()` | is Quarto on PATH, and which |
| `sf_report_engine(path)` | which engine produced this artefact, read off the file |
| `sf_render_both_engines(inst, data)` | 1 row per engine: engine used, size, hash stamped, seconds |
| `sf_render_twice(inst, data, use_quarto)` | same inputs twice, raw and normalised comparison |

`sf_render_twice()` normalises timestamps, temp paths, and the render
directory before comparing. Normalising is itself a risk, so it reports the
raw comparison alongside. If you widen the normalisation, say why in the
chunk, because a silently loosened normaliser is how a real difference hides.

A render of the bundled demo takes roughly 39 seconds through Quarto and 25
through the fallback, so file 02 takes a few minutes. That is expected.

## 6. Release context

0.4.1 is not submitted. `DESCRIPTION` reads `0.4.0.9000` on `dev` and
`0.4.0` on `main`. Set both to `0.4.1` at release time.

The 3 findings above need owner decisions before this suite can be signed
off. Finding 1 in particular is not a quiet fix: seeding by default changes
confidence intervals the package has already printed for users, which puts it
in the same class as `review_040`'s finding 1.
