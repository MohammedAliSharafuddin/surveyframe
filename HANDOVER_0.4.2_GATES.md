# 0.4.2 release gates, from the pre-publication review

State file for the five gates the independent review set before 0.4.2 can go to
CRAN. Branch `fix/0.4.2-review-gates`, cut from `main` at `181ddaa`.

The review itself is `REVIEW_0.4.2.md`. All five findings were verified against
the source before any work started, and all five held.

## Status

| Gate | What it requires | State |
|---|---|---|
| 1 | Refuse a Sheets response row that cannot be stored literally | **done**, `a350ce9` |
| 2 | An opaque send is visibly unconfirmed and non-destructive | **done**, `d1f6687` |
| 3 | A test coupling collector outcome to what the respondent is told | **done**, `d1f6687` |
| 4 | Static A1/A2/A3 in a real browser, asserting the stored row | **done**, real Chrome 2026-09-21 |
| 5 | Enforce and complete `analysis_syntax()`'s method coverage | **done**, `5feb7ee` |

Gate 2 was reopened once and closed again in `18427dd`, see below. The original
gate-branch suite passed with environment and warning debt; the 2026-09-21
release pass below exercises or precisely asserts those paths instead.

`NEWS.md` is corrected for gates 1 and 2, so it no longer claims unconditionally
that a Sheets answer is stored as submitted, and it records the thank-you screen
change.

## What changed, per gate

### Gate 1

`appendRowAsText_()` became `appendResponseRow_()` and throws when the Sheets
advanced service is absent. `doPost()` returns that as `status: "error"` with a
message naming the Services step, and writes nothing. The `stored` field is
always `"raw"`, because one write path ships and it is the literal one.

`appendDiagnosticRow_()` keeps the best-effort write for the unmapped sheet,
where the row is a preserved copy of a submission that could not be filed.

The setup comment at the top of the collector, `NEWS.md`, and the builder's
inlined copy all moved together. `data-raw/inline_static_template.R` regenerates
the inlined copy and `test-builder-template-sync.R` fails on drift.

### Gates 2 and 3

`renderThankyou()` gained `unconfirmed = deliveryState === 'sent' && !!ENDPOINT`.
On that state the screen reports the answers were sent and that receipt cannot be
confirmed, keeps the download whatever the designer chose, and does not
auto-redirect. The Continue link stays. `restartSurvey()` asks before a reload
that would drop `window._lastCsv`.

**Reopened once.** The first pass changed only the default message, reasoning
that a designer's own wording was their claim to make. A reviewer executed the
exported JavaScript and found a custom "your response has been recorded" sitting
beside "cannot confirm", with the restart button still offered. Both are closed:
the package's status wins on a failed or unconfirmed send, a custom message shows
only on a download-only survey, and the restart is withheld on both states as it
already was on failure. The lesson is that the page must not relay a claim about
storage from text written before delivery was attempted.

`test-collector-respondent-contract.R` is the new coupled file. Its rule: every
claim the page makes must be true under the weakest outcome the collector can
return, since the page can read none of them. It drives all three reachable
outcomes and asserts two of them store nothing.

### Gate 5

`test-analysis-syntax.R` now holds `syntax_cases`, one execution case per method,
asserted `expect_setequal()` against `sframe_syntax_methods`. Each case carries
`want` and `have` functions, and a separate test asserts both are functions, so a
case cannot join the roster asserting nothing.

Running it found a real defect: the `descriptives` generator read `result$vars`,
which that runner does not set, and emitted `vars <- c()`. The displayed code
summarised nothing. Fixed with a fallback to `result$variables`.

## Gate 4

**Requirement.** Run the three static-survey collection scenarios in real Chrome
and assert the assembled or stored row, not a screenshot.

- **A1** numeric entry: clearing a field with `min="1"` must leave it empty, and
  must not enter `1`. `2.5` must not become `25`.
- **A2** a zero-coded option: selecting a value of `0` must store `"0"`, and must
  clear the required-field check.
- **A3** ranking order: the submitted order must equal the displayed order after
  a drag, and an untouched optional ranking must not submit the declared order.

**Why the existing harness does not cover it.** The handover pointed at
`test-shiny-respondent-browser.R`, which drives `render_survey()` at line 40.
That is the Shiny collector. Nothing opens an `export_static_survey()` file in a
browser.

**Runtime evidence.** The exported static survey was driven in real headless
Chrome on 2026-09-21 and the submitted row was read back from the page:

- an out-of-range numeric value remained exactly as typed;
- the zero-coded required option stored `"0"` and passed validation; and
- the displayed ranking order matched both `window._lastRow` and the CSV row.

This closes the release gate. A permanent `test-static-survey-browser.R` would
still be useful regression infrastructure, following this shape:

1. `export_static_survey(instr, output_path = tempfile(fileext = ".html"))`.
2. `chromote::ChromoteSession$new()`, then `Page.navigate` to `file://` that path.
3. Drive the widgets through `Runtime.evaluate`.
4. **Assert on the row the page would submit, read back from the page**, rather
   than on pixels. The page holds it: `window._lastRow` after `doSubmit()`, and
   `window._lastCsv` for the CSV form. Read those over CDP.
5. `skip_on_cran()`, and skip when chromote or Chrome is absent, following the
   pattern already in `test-shiny-respondent-browser.R`.

Reading `window._lastRow` is the point. This project has been misled twice by
reading a browser's rendering of a widget, and once by 17 screenshots of a
landing page. The V8 tests already cover the logic; what gate 4 adds is proof
that a real browser's event handling reaches the same row.

## Also outstanding, beyond the gates

- **`R CMD check --as-cran`: done against a committed tree, finally.** Every
  earlier run in this file checked the uncommitted working tree, which cannot
  be tagged or rebuilt by anyone else. The tree is now committed at `872e60d`
  on `fix/0.4.2-review-gates`. Rebuilt from that commit and rechecked:
  **Status: 1 NOTE** (submission frequency), 0 errors, 0 warnings, tests
  (205s), examples, `--run-donttest`, and vignette re-rendering all OK.
  Tarball SHA-256 `38cc2caf51bff95529370a15f44e61e5a4a04f6c6828210b32c5810fcfe09bae`,
  recorded in `cran-comments.md`. This number is only valid for `872e60d`; if
  the tree changes again before submission, rebuild and re-hash rather than
  trust this line.
- **An isolated-library install of the candidate tarball: done.** The Quarto
  integration test ran against installed 0.4.2 and passed. A literal fresh
  clone plus manual `launch_builder()` smoke test remains useful release
  hygiene, but is no longer evidence for an unfixed package defect.
- **win-builder**, R-release and R-devel. **Not run.** This needs uploading to
  win-builder.r-project.org and reading the emailed result; I have no path to
  do that from here.
- **Live-sheet verification** of the RAW write. Gate 1 makes the unsafe path
  unreachable, so what remains is confirming the RAW path stores `=1+1` as text
  with an empty formula field in a real deployed sheet, plus `+123`, `-123`,
  `@value`, leading zeros, dates, decimals, Unicode text, and an empty answer.
  Verify the stored cell's value and formula through the Sheets API, not its
  rendering. This needs a Google account and cannot be done from here.
- **`cran-comments.md`: drafted.** States the corrective-release rationale, the
  2 defect classes, the 2 new exports, and the incoming-feasibility NOTE.
  Its test-environment table needs win-builder's results before submission.
- **`REVIEW_0.4.2.md` reconciled with this file.** It described `dea93a0`,
  before any gate was worked, and its "Hold" decision and unchecked boxes had
  no note saying they were stale. It now carries a banner and an updated
  checklist pointing here, with the original text kept as the historical
  record rather than rewritten.
- **The working tree is committed as of this pass**, on `fix/0.4.2-review-gates`.
  It was not before: 45 modified and 31 untracked files, mostly the review's
  own gate-3 comparators regenerating documentation (16 new per-method
  `as.data.frame` topics closing batch 8's G1) and the demo-notebook and test
  hardening described below, had accumulated with no commit. `R CMD check` had
  been run against that uncommitted tree, which is not the same claim as
  checking a commit that can be tagged and rebuilt.
- **Tag `v0.4.2` at submission — still not done, deliberately.** Two of the
  last three releases had to be reconstructed by tree hash. Tag only once a
  commit is chosen as the actual submission candidate; do not tag a
  provisional commit made mid-review.
- **The former local 7-skip/43-warning run was cleaned up.** Deprecated ggplot2
  calls were replaced; expected warnings are asserted; incomplete repeated
  measures use a documented complete-respondent contract; optional-package
  branches and the quality plot now execute; and `topicmodels` was rebuilt
  against the installed GSL. The one source-tree Quarto skip runs and passes
  when the candidate tarball is installed, which is its intended context.
- **Two mocks of the same collector.** `helper-apps-script.R` and
  `test-collector-header-drift.R` each model Sheets. Gate 1 broke the second one,
  which is how the duplication surfaced. They should be one file.
- **26 September is provisional.** It was set before this review existed, and
  win-builder turnaround is outside our control.

## A process note worth keeping

While mutation-checking gate 5 I ran `git checkout -- tests/testthat/test-analysis-syntax.R`
to undo the mutation. The roster work in that file was **uncommitted**, so the
checkout restored HEAD and destroyed it. It was rebuilt from scratchpad copies
with no loss, and the commit went in before the next mutation check.

`CLAUDE.md` already warns against `git checkout <branch> -- .` for exactly this
reason. The rule needs widening: **commit before mutation-checking, and restore a
mutation from a scratchpad copy, never from git, while anything in the file is
uncommitted.**
