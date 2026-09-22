# Independent review: surveyframe 0.4.2 before CRAN submission

Reviewed candidate: public `main` at
`dea93a0efbc5a23aa27b1a802076f6bba55c836b`.

Review date: 19 September 2026.

> **Superseded, 23 September 2026.** This review’s decision and
> checklist describe the `dea93a0` candidate, before any gate below was
> worked. All 5 gates this review and its follow-up raised are now
> closed; see
> [HANDOVER_0.4.2_GATES.md](https://mohammedalisharafuddin.github.io/surveyframe/HANDOVER_0.4.2_GATES.md)
> for the current status, the commits that closed each one, and what is
> still outstanding before submission (win-builder, live Google Sheets
> verification, `cran-comments.md`, tagging). This file is kept as the
> historical record of what was found and why, not edited to match the
> current tree. Do not read the unchecked boxes in its final checklist
> as the current state.

## Decision, as of the review date above

**Hold. Do not submit this candidate to CRAN.**

The release should proceed once the Google Sheets collector fails closed
when literal storage is unavailable, and the static survey stops
presenting an opaque `no-cors` send as a recorded response. These are
one connected release blocker in the highest-harm path: the package can
still alter or lose a participant’s answer and then let the participant
leave without a recoverable copy.

The minimum release gate is:

1.  Remove the `setValues()` fallback for response rows. If the Sheets
    advanced service is unavailable, refuse the online write and
    preserve the response in the page for retry or download. Do not
    return `{status: "ok"}` for that path.
2.  Treat every opaque `no-cors` completion as **sent, not confirmed
    stored**. Do not display the configured/default “recorded” message,
    auto-redirect, or offer “Submit another response” on that state.
    Keep the CSV available until storage is positively confirmed, or
    state clearly that confirmation is impossible and require the
    participant to save the copy.
3.  Add an end-to-end test that couples these two halves: simulate a
    collector response of `unmapped`, `error`, and missing Advanced
    Sheets service, then prove the respondent UI never claims recording
    and never discards its only recoverable copy. The present V8 tests
    exercise the collector and browser independently and therefore miss
    the broken contract between them.
4.  Correct `NEWS.md` so it does not say unconditionally that Sheets
    answers are stored exactly as submitted until every shipped path has
    that property.
5.  Run the static-export A1/A2/A3 scenarios in a real browser and
    assert the assembled/stored row. The named Chrome harness currently
    tests the Shiny collector, not the static survey.

The live-sheet check remains strongly desirable, but it is no longer the
only reason for the hold: the fallback defect is demonstrated by the
package’s own test and source.

## Findings

### 1. Blocks release: the shipped fallback knowingly changes participant data

The setup asks the researcher to add the Advanced Sheets service
(`inst/static_survey/collector_template.gs:5-12`), but the collector
treats its absence as recoverable. It formats the range as text, calls
`setValues()`, and returns `false`
(`inst/static_survey/collector_template.gs:121-141`). `doPost()` then
still returns `status: "ok"`; the only distinction is an unread warning
in the JSON response (`inst/static_survey/collector_template.gs:67-83`).

This is not hypothetical. The regression test deliberately disables the
service and proves that `=1+1` is mangled
(`tests/testthat/test-collector-formula-injection.R:124-137`). A green
test run therefore certifies that an unsafe production path remains
shipped. That contradicts the unconditional release notes that Google
Sheets responses “are stored as text” and answers “are now stored
exactly as submitted” (`NEWS.md:39-42`, `NEWS.md:137-141`).

The rationale that refusing the write could lose a live answer is
incomplete. The static survey already holds a CSV copy in
`window._lastCsv`; it can keep that copy reachable and tell the
participant the online collector is not available. Silently accepting a
write known to mutate data is the worse failure mode.

### 2. Blocks release: an opaque send is still presented as a recorded response

The static survey correctly documents that a `no-cors` response is
unreadable (`inst/static_survey/template.html:1104-1121`). Despite that,
after any resolved fetch it sets `deliveryState = 'sent'`, and the
thank-you screen uses the configured message or the default “Your
response has been recorded”
(`inst/static_survey/template.html:1283-1296`). It may then
auto-redirect (`inst/static_survey/template.html:1298-1303`).

This includes collector-side failures because Apps Script catches
exceptions and returns JSON rather than an HTTP failure
(`inst/static_survey/collector_template.gs:81-90`), and it includes the
`unmapped` route (`inst/static_survey/collector_template.gs:54-65`). The
browser cannot read either status. It also cannot read the warning from
finding 1.

The delivery test is unable to catch this claim. Its resolved-fetch case
checks only that the state is `sent` and that failure/retry wording is
absent; it never asserts that “recorded” wording, redirect, or
destructive restart controls are absent
(`tests/testthat/test-static-template-delivery.R:66-75`). Another test
explicitly expects redirect after an opaque send
(`tests/testthat/test-static-template-delivery.R:85-90`). This is the
clearest test in the candidate that passes while the user-facing
contract it describes is false.

### 3. Correctness evidence gap: the advertised A1/A2/A3 browser harness tests a different collector

The open-evidence list names A1 numeric entry, A2 zero-coded choices,
and A3 ranking order in the **static survey**, then points to
`test-shiny-respondent-browser.R`. That file launches
[`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md)
(`tests/testthat/test-shiny-respondent-browser.R:33-42`) and tests Shiny
answer persistence, untouched values, and keyboard ranking
(`tests/testthat/test-shiny-respondent-browser.R:95-171`). It never
opens an HTML file from
[`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md)
and does not exercise the static template’s row assembly or POST.

The V8 static-template tests are useful and materially stronger than
source matching. They do not close the specifically requested
real-browser evidence. This gap becomes a release gate because
collection regressions have already escaped non-browser tests in this
package.

### 4. Test-quality finding: `analysis_syntax()`’s coverage claim is not enforced

The generator declares 18 result methods covered
(`R/analysis_syntax.R:55-65`) and its header says every covered method
is run and compared (`R/analysis_syntax.R:11-17`). The tests numerically
exercise the two-group, correlation, rank, paired-t, one-way ANOVA,
linear-regression, and chi-square paths
(`tests/testthat/test-analysis-syntax.R:62-143`). They do not execute
and compare `anova_two`, `ancova`, `friedman`,
`regression_logistic_binary`, `fisher_exact`, `mcnemar`, or
`descriptives`.

The only set-level gate requires merely that at least one returned block
is covered and that returned text parses
(`tests/testthat/test-analysis-syntax.R:172-183`). It can stay green if
most declared methods lose their generator or generate statistically
different but parseable code. Add a table-driven assertion equating the
tested-method roster to `sframe_syntax_methods`, then compare each
supported method’s material outputs. Until then, the statement “for
every covered method” is unsupported.

This does not independently block 0.4.2 if the feature is described as
partial and the missing cases are added before release. It does make the
new feature’s principal safety claim weaker than the handover says.

### 5. Maintainability: the `skip_on_cran()` count in the deferral is already stale

There are 61 literal `skip_on_cran()` calls in `tests/testthat`, not 57.
The substance of the deferral remains reasonable only if a non-CRAN CI
route is a required release check and its result is retained. The count
should be updated so the deferred work has a reproducible baseline.

## Attack on the seven requested areas

### 1. Google Sheets formula handling

The RAW write is the right API-level remedy. The reasoning becomes thin
at the fallback: a path the tests prove unsafe remains an accepted
success, while the browser cannot read its warning. Real-sheet
verification should check both the RAW success case (literal displayed
value and empty formula field) and the missing-service case (no response
row written, recoverable CSV retained).

### 2. Guards added in this release

The centralised `finish()` path in
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
now applies strict abort and the validation stamp after the early shape
gate (`R/validate_sframe.R:289-333`). The instrument-level exception is
explicitly handled through `sframe_method_needs_variables()`
(`R/validate_sframe.R:102-120`, `R/validate_sframe.R:157-170`). I found
no new source-level bypass of those two repairs. The scale of the
validation rewrite still justifies treating the full-suite result as
necessary, not sufficient.

### 3. Quarto template and `sframe_result_supplement()`

Exporting the helper is defensible as a narrow compatibility choice,
though it creates public API surface for a rendering implementation
detail. The stronger long-term design is to have
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
precompute report payloads before starting Quarto, leaving the template
to render data instead of calling package internals. For 0.4.2, the
export is documented and preferable to `:::` or silent fallback. It is
not a release blocker.

The gate that actually renders Quarto is appropriately based on the
`engine` attribute
(`tests/testthat/test-report-distribution-coverage.R:155-180`). Its
installed-package compatibility skip is understandable during
development; the release run must use the just-built tarball so that
skip cannot hide stale installation state.

### 4. Collected data shape

The 0.4.1 compatibility exception is narrow: it allows only the
additional `respondent_id`, aligns to the existing header, and emits a
typed message (`R/render_survey.R:333-365`).
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
now declares the package’s four reserved metadata columns
(`R/read_responses.R:116-141`). This is a reasonable migration for an
active study.

The remaining same-columns/different-instrument identity risk is real
but need not block this patch if NEWS states it plainly and users are
told to start a new file whenever an instrument changes. A
response-level instrument revision should be designed once for CSV,
Sheets, static, Shiny, and Ethos.

### 5. Numbers that move

Correcting known wrong numbers is appropriate in a patch release,
especially where 0.4.1 is collecting or analysing live data. The
changelog identifies the major affected classes. The release record
should retain before/after fixtures and independent numerical oracles
for each statistical/MCDA correction; package self-comparison is weaker
evidence where both paths share helpers.

### 6. `analysis_syntax()` in this release

Shipping it is defensible only after closing finding 4. Seven updates in
six months is a reason to keep scope narrow, not a reason to withhold a
useful feature categorically. The feature is small in user surface but
high in trust: displayed code is evidence. A complete, mechanically
enforced coverage matrix is the appropriate admission price. If that
cannot be finished before the submission date, defer the export rather
than ship a claim broader than its tests.

### 7. Test quality

The suite has substantially improved and the mutation work is valuable.
The most important remaining weakness is contract fragmentation: the
collector test verifies the warning, while the browser test cannot
observe it; both pass although the participant sees a success screen.
The second is roster drift: the syntax test comments promise all methods
without asserting equality to the declared roster. These are structural
test defects, not requests for more assertion volume.

## Deferred findings

I do not promote the mediation diagram, slope standard errors,
plot-family refactor, export-to-test map, narrow researcher layouts, or
downstream Ethos adapter work to release blockers. The browser-storage
recovery decision is also defensible as deferred if failed/uncertain
delivery always leaves a download available and never invites the
participant to discard it; the current opaque success path fails that
condition and is covered by findings 1 and 2.

The response-level instrument identifier is important provenance work,
but a coherent cross-collector design is preferable to adding another
mid-release column. The package must meanwhile say that equal headers do
not prove equal instrument semantics.

## Evidence provenance

### Verified by running code on `dea93a0`

- `NOT_CRAN=true` execution of the real-Chrome Shiny respondent test
  file: all four tests completed without failure. This verifies the
  Shiny A10, A6, A5 and A7 scenarios in that file; it does not verify
  static-export A1-A3.
- The complete default local test suite finished with no failures: 8
  skips and 43 warnings. Four real-Chrome Shiny respondent tests ran
  within it. The skips included the source-tree Quarto test because the
  older package installed in the default library lacked the two new
  exports, the external schema profile because its repository was not
  beside this worktree, and four topic-model tests because
  `{topicmodels}` could not be loaded.
- `R CMD build .` completed and produced `surveyframe_0.4.2.tar.gz`.
- The tarball installed into an empty temporary R library. From that
  installed package, all 22 named demos loaded as `sframe` instruments,
  `launch_builder(open = FALSE)` returned an existing asset, and
  [`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md)
  produced a non-empty HTML file.
- With the temporary library exported through `R_LIBS` so Quarto’s
  separate R process loaded the just-built package,
  [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
  completed with `engine = "quarto"`. A first diagnostic run that
  changed [`.libPaths()`](https://rdrr.io/r/base/libPaths.html) only in
  the parent process fell back because Quarto loaded the older default
  installation; that was an environment artifact and is not a finding.
- Mechanical count: 61 literal `skip_on_cran()` calls under
  `tests/testthat`.

### Inferred from source and tests

- Findings 1 and 2 follow directly from the collector fallback, the
  opaque browser POST, the success-screen renderer, and their tests. No
  live Google Sheet was available, so RAW storage itself was not
  independently verified.
- The validation, report-template, response-shape, deferral, and
  syntax-coverage assessments are source-derived unless explicitly
  listed above.
- Win-builder on R-release and R-devel was not run in this review.

## Final release checklist

Left as originally written, since this is the historical record. Current
status of each item, as of 23 September 2026, is in
[HANDOVER_0.4.2_GATES.md](https://mohammedalisharafuddin.github.io/surveyframe/HANDOVER_0.4.2_GATES.md).

Remove/refuse the unsafe Sheets fallback. (gate 1, `a350ce9`)

Make opaque sends visibly unconfirmed and non-destructive. (gate 2,
`d1f6687`, reopened and closed again `18427dd`)

Add the coupled collector-to-respondent failure tests. (gate 3,
`d1f6687`)

Run static A1/A2/A3 in real Chrome and assert stored rows (2026-09-21).

Enforce and complete the
[`analysis_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/analysis_syntax.md)
method coverage roster. (gate 5, `5feb7ee`)

Install the built tarball into an empty temporary library; load all 22
demos, obtain `launch_builder(open = FALSE)`, and complete a static
export.

Run `R CMD check --as-cran` on that tarball. Status 1 NOTE (submission
frequency), 0 errors, 0 warnings, run repeatedly as the tree changed.

Run win-builder on R-release and R-devel. **Still open.**

Tag the exact accepted tree at submission. **Not yet — no commit has
been tagged, and the working tree this review’s gates were fixed against
is still uncommitted.** Do this only once a commit is chosen as final.
