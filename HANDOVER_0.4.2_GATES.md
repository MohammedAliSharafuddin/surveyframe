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
| 4 | Static A1/A2/A3 in a real browser, asserting the stored row | **open** |
| 5 | Enforce and complete `analysis_syntax()`'s method coverage | **done**, `5feb7ee` |

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

## Gate 4, the open one

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

**Suggested shape.** A new `test-static-survey-browser.R`:

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

- **`R CMD check --as-cran` on a freshly built tarball.** Not run since the gate
  work started.
- **A fresh-clone install run** of `sframe_demo()` across the 22 demos,
  `launch_builder()`, and an `export_static_survey()` round trip.
- **win-builder**, R-release and R-devel.
- **Live-sheet verification** of the RAW write. Gate 1 makes the unsafe path
  unreachable, so what remains is confirming the RAW path stores `=1+1` as text
  with an empty formula field in a real deployed sheet. This one needs a Google
  account and cannot be done from here.
- **Tag `v0.4.2` at submission.** Two of the last three releases had to be
  reconstructed by tree hash.
- **The deferred `skip_on_cran()` count is 62**, not the 57 the build handover
  recorded and not the 61 the review counted. Whoever picks up that deferral
  should recount rather than trust any of the three.
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
