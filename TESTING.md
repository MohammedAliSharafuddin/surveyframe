# TESTING.md, what the suite can and cannot catch

Written 2026-08-28, after asking why every release ships defects. This is a
diagnosis of surveyframe's own record, not general testing advice, and the
practices it recommends are the ones that actually found the defects.

Tasks derived from it are T1 to T4 in `todo_0.4.1.md`.

---

## The finding

Across roughly 20 significant defects logged for 0.3.3 through 0.4.1, **none
is recorded as having been found by the test suite.** The planning files say
so in as many words: "not caught by any test suite", "found in a live builder
session rather than by any suite", "nothing ever said a word".

Over the same period the suite grew from 368 tests to 2034. The 2 defects
found on 2026-08-27 shipped through 1991 of them.

| How it was actually found | Defects |
|---|---|
| An independent oracle | item-rest correlation (`psych`), repeated-ANOVA stratum (`jmv`), WASPAS using SMART's normalisation (`RMCDA`) |
| Driving the real artefact | builder decision items, `known_vars` expansion, pairwise scale mismatch, `%in%` branching, collector header drift |
| A human working a whole workflow | the 8 `review_040` defects, ELECTRE's empty relation, the unwirable rated matrix, the Shiny collector's joined columns |
| Writing a second implementation | `write_sframe()` `digits = NA`, caught by the standalone browser verifier |
| Using the package on real research | straight-lining on short scales, and both 2026-08-27 defects |

This is not an argument against the suite. It is a statement about what a
suite of this shape can see.

---

## Why the suite does not catch them

### 1. A test encodes the belief that produced the bug

Every defect above is a wrong belief, not a slip in execution:

- "`rowMeans()` is the item-rest correlation"
- "a branch rule's `value` is a comma-separated string"
- "the sheet's header is stable across a redeploy"
- "an empty outranking relation means every alternative is best"

A test written by the same person, at the same moment, from the same
assumption asserts the belief rather than checking it. That is why oracles
and second implementations find things unit tests cannot: they are the only
techniques that bring an *independent* belief to the comparison.

### 2. The defects sit on boundaries

Not inside a function, but between 2 artefacts tested separately and never
together: R to JS, R to Apps Script, R to the builder, `main` to `dev`. Each
side passes alone. Nothing crossed the contract.

surveyframe generates 4 artefacts it never executes:

| Artefact | Executed by a test? |
|---|---|
| `inst/static_survey/template.html` | yes, since 2026-08-27 (chromote) |
| `inst/static_survey/collector_template.gs` | yes, since 2026-08-27 (V8) |
| lavaan and seminr syntax | yes, since 2026-08-28 (fitted) |
| `inst/builder/survey_builder.html` | **no**, 3698 lines asserted on as text |

### 3. The failure mode is a plausible answer, not a crash

A crash any test catches. A wrong number under a right-looking heading only
an oracle catches. Almost every defect in this project's record is silent.

**The target is not zero defects. It is zero silent ones.**

---

## The 4 practices

### 1. Execute every artefact you generate

Assert on behaviour, never on generated text. A substring assertion passes
whenever the string is unchanged, including when the string was always wrong.

**Parsing is not running.** The mediation defect, logged 2026-08-04 as
review defect 5 and fixed 2026-08-28, produced syntax that
`lavaan::lavParseModelString()` accepts and `lavaan::sem()` rejects:
`sem_lavaan_syntax()` wrote `indirect_A_B_C := A__B*B__C` while emitting the
structural paths unlabelled, so the labels the definition multiplied were
never defined. A parse test would have passed it indefinitely. Run generated
code the way a user runs it.

Current techniques, all in the suite now:

- `chromote` for the exported survey, driven by clicking the real control.
  Reading the DOM without driving it is not enough, and a browser reading of
  a Shiny widget is unreliable, since selectize.js hides the real `<select>`.
- `V8` for the Apps Script collector, against a small mock of the Sheets API
  it calls.
- `lavaan::sem()` and `seminr::estimate_pls()` for generated syntax, on
  simulated data with a known structure, so a fit that runs can also be
  checked for having estimated something sensible.

### 2. Test differentially against an oracle

`psych`, `jmv`, `RMCDA`, `lavaan`, and `boot` are already in Suggests as
test-time oracles. Every exported statistic that has one should have a test
comparing against it. Where no oracle exists, record that in this file, so
the gap is visible rather than merely absent.

Two traps, both hit before:

- **A mismatched reference looks exactly like a defect.** An apparent ninth
  review finding was surveyframe reporting the b1 and b2 skewness estimators,
  which is `psych`'s own default.
- **A field that does not exist compares equal to itself.** Review file 13's
  hash gate read `hotel$integrity$hash` twice, and there is no `$integrity`
  element, so it compared `NULL` to `NULL` and reported a match.

### 3. Ask whether each function can say no

The recurring shape here is software returning something plausible instead
of reporting that it has no answer. Logged instances: ELECTRE calling an
empty outranking relation "all 9 alternatives jointly best" and
`sensitivity_analysis()` then calling that stable, `assumption_report()`
reporting checks that never ran, missingness reporting 0 percent for a
respondent who skipped an entire battery, and `render_results(citation_format =)`
validated and then ignored.

For every exported function, ask what it returns on empty input, all-missing
input, a degenerate case, and an argument that is validated then unused.
Where the honest answer is "cannot compute", say so in the shape
`quality_report()`'s `straightline_min_items` uses: `checked = FALSE` with an
empty result, distinguishable from a clean pass. Then test the degenerate
case.

### 4. Use it on real research before the release

Re-platforming 1 real study on 2026-08-27 found 2 defects, 1 of them silent
corruption of already-collected data. That afternoon out-yielded 2034 tests.
Doing it after the release is how 0.3.0 through 0.4.0 all shipped the `%in%`
defect.

---

## Two rules that already apply, and why

Both were learnt the hard way and are recorded in `CLAUDE.md`. They belong
here too.

**Every new claim needs a mutation check.** Revert the thing being tested and
confirm the test fails, then restore it. A check that cannot fail is not a
check. This has caught vacuous tests twice.

**Attribute a surprising failure before reporting it.** Roughly 6 harness
errors in one 2026-08-02 session initially looked like package bugs. On
2026-08-27 an end-to-end run reported the fix had not worked, and the cause
was the harness calling a `render()` that does not exist. Check your own
instrument first.

---

## Process defects ship code defects

These are not bugs, and they have put real defects in front of users:

- The accessor work sat on `dev` and never reached `main` for 8 days, found
  only during release prep, after `main` had already passed a full CRAN check
  without it.
- `dev` fell 20 commits behind `main` and was still carrying the
  `write_sframe()` `digits = NA` defect that `main` had fixed 8 days earlier.
- `.gitignore` and `.Rbuildignore` drifted between the branches, leaving 23
  dev-only files unignored on `main`, which is the branch pkgdown builds from.
- A commit reached `public/main` and never `origin/main`, so the 2 remotes
  disagreed for a day.
- 2 releases had to be reconstructed after the fact because they were not
  tagged when they shipped.

Before calling a release feature-complete, confirm each headline feature is
present **in the branch being shipped** and in the changelog describing it.
`dev` having a commit is not evidence `main` does.
