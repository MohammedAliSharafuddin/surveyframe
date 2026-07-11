# surveyframe dogfeed log + 0.3.3/0.3.4 build runbook

Excluded from the CRAN build (via .Rbuildignore) and from the public repo
(via .gitignore). Lives only in the dev workspace.

This file has two jobs now. It is still the running dogfeed log (real-user
feedback on the SurveyBuilder, captured 2026-07-06 to 2026-07-08). It is also
a build runbook, assembled 2026-07-08 for an automated session (assigned to
Fable 5) that is meant to take both v0.3.3 and v0.3.4 to ship-ready in one
pass. Read the "Read this first" section before doing anything else — the
two version scopes in `roadmap.md` do not fully overlap with what got
dogfooded in this session, and that gap has to be closed by Fable 5, not
assumed away.

Status key for individual items: `open` (raised, not yet triaged), `planned`
(assigned to a version in roadmap.md), `fixed` (done, needs a note in
NEWS.md), `wontfix` (decided against, with reason).

---

## Read this first (Fable 5)

**Do not start editing source until the project owner has explicitly said
"dogfeed is complete."** Per `CLAUDE.md`, no source file (`R/`, `inst/`,
tests, vignettes) is touched while a dogfeed session is open. This runbook
does not itself close the session.

**The three bodies of work below are not the same thing, and this dogfeed
session only actually covered one of them:**

1. **v0.3.3 as scoped in `roadmap.md`** is real-world hardening of the
   AIC-RSAM room-service mobile static survey (from the local
   `AI_Room_service/` prototype) plus the first live end-to-end verification
   of the Google Sheets collector. **This dogfeed session never opened or
   tested that instrument.** Everything logged here is from clicking around
   `surveyframe::launch_builder()` on desktop. Phase A below tells you how to
   actually do the 0.3.3 work; you cannot mark 0.3.3 exit criteria met just
   by fixing the items in Phase B.
2. **v0.3.4 as scoped in `roadmap.md`** is the ggplot2 visualisation layer:
   a brand theme, `plots = TRUE` on the analysis runners, the first family
   of plots, and a `$table` slot on inferential runners. **Nothing in this
   dogfeed session touched that code path either** — the SurveyBuilder is a
   client-side HTML/JS app with no ggplot2 involvement. Phase C below is a
   fresh task breakdown from the roadmap deliverables, not derived from
   dogfeeding.
3. **What this dogfeed session actually produced** is a batch of SurveyBuilder
   desktop-UI bugs, logic gaps, and a UX redesign proposal (Phase B). Some of
   these are small, patch-safe logic/text fixes that plausibly ride along
   with 0.3.3's "UI/UX fixes from the ICSRI presentation audience" deliverable.
   Others (the design-system rework, the editable report writer) are new
   capability that does not fit either version's scope as roadmap.md defines
   it today and should not be silently bundled in. Each item in Phase B is
   tagged with a recommended lane; don't override the tag without checking
   with the project owner first, since `roadmap.md` is the canonical schedule
   and this file is not authorised to silently amend it.

**Session scope, confirmed 2026-07-08:** this session targets v0.3.3 and
v0.3.4 only. **v0.3.5 through v0.4 are explicitly out of scope for this
session** — the project owner confirmed this after being asked whether to
push further. That arc (six ~21-day patches plus a 0.4 minor) is real,
scoped, months of work in `roadmap.md`; don't start any of it here. Treat
"After this session" at the bottom of this file as the actual handoff point,
not a suggestion.

**v0.3.3's A6 deliverable is blocked, not merely deferred — exclude it from
this session's exit criteria.** "UI/UX fixes from the ICSRI presentation
audience" depends on feedback from a conference that happens 8-9 August
2026, which has not occurred yet (this runbook was written 2026-07-08). No
amount of session time closes that gap. Ship v0.3.3 against A1-A5 and A7 only,
and either (a) hold the release until real ICSRI feedback exists and file A6
as a follow-up patch, or (b) get the project owner to explicitly drop A6 from
this release's exit criteria and amend `roadmap.md` accordingly — don't
invent placeholder "audience feedback" to check the box.

**Execution order for a single session covering both versions:**

1. Phase A (v0.3.3, roadmap-scoped, A6 excluded per above) — do this first;
   it is the version closest to shipping and has external, physical exit
   criteria (a phone test, a live Google Sheets round trip) that need the
   most lead time.
2. Phase B (SurveyBuilder findings from this dogfeed session) — patch-safe
   items only (tagged `lane: 0.3.3-safe` below) ride along with Phase A.
   Items tagged `lane: defer` should become their own tracked
   `roadmap.md` entry, not get built in this session.
3. Phase C (v0.3.4, roadmap-scoped) — start only once Phase A's exit
   criteria (A1-A5, A7) are met and 0.3.3 is ready to tag.
4. Ship checklist — run once after 0.3.3 tags, and again after 0.3.4 tags.
   Do not batch both versions into one tag/release; `DESCRIPTION`'s `Version:`
   field only ever holds one version at a time, and `roadmap.md` tracks them
   as separate dated releases.
5. Stop. Do not continue into v0.3.5. Leave anything unfinished, deferred, or
   out of scope in "After this session" for the project owner to re-scope.

---

## Session log

### 2026-07-06 — session opened

Fresh dogfeed session started via `surveyframe::launch_builder()`. Source
files are not to be edited until this session is declared complete; items are
logged only.

### 2026-07-08 — session continued, then reframed as a build runbook

Resumed the same dogfeed session, still `surveyframe::launch_builder()`. Same
no-source-edit rule in force.

Two interactions manually re-checked and confirmed working, no item needed:

- **Item list drag-to-reorder** (Build tab, left sidebar) — works fine as of
  now. Re-verify after Phase B's design-improvement arc lands, since that
  work touches the same item-list markup/CSS.
- **Undo/redo** (Ctrl+Z / Ctrl+Y, header toolbar buttons) — works fine.

A full read of `R/builder.R` and `inst/builder/survey_builder.html` (2,358
lines) was done to compare against what had actually been dogfooded so far,
producing the "Flagged for review" inventory folded into Phase B.

Later the same day, the file was restructured a second time into this
runbook after the project owner asked for something comprehensive enough for
Fable 5 to execute v0.3.3 and v0.3.4 together in one session. `roadmap.md`
was re-read in full for both versions' deliverables and exit criteria to
ground Phases A and C accurately (see "Read this first" above for why they
don't map cleanly onto the dogfeed findings).

### 2026-07-09 — live AIC-RSAM deployment reviewed (Fable 5 build session)

The AI_Room_service repo shows the instrument is already deployed and
collecting real responses: hosted at
https://mohammedalisharafuddin.github.io/live-surveys/aic-rsam.html, posting
to a live Google Sheet (ID 18Puv8W2Q5Uj5UTKvjtYkclvOxMKw8GjxaaWAaSMIQMo).
Its `export_survey.R` needed four manual splices, reviewed as 0.3.3
evidence:

- **Splice D (CORS) — real package bug, fixed in 0.3.3.** The stock template
  POSTs with `Content-Type: application/json`, which triggers a CORS
  preflight Apps Script never answers, so every hosted submission is
  silently blocked. Fixed to `mode: no-cors` + `text/plain`, with a
  regression test. After 0.3.3 the deployment can drop this splice.
- **Page-map patch (1b) — not reproducible as described.** Pages survive
  `sf_item(page =)`, post-assembly `instr$items[[i]]$page <-`, the .sframe
  round trip, and export, on both 0.3.2 and 0.3.3 code. The likely cause was
  modifying the standalone item objects after assembly (R copy semantics).
  A regression test now pins the working behaviour; the deployment can
  drop the regex patch by using either supported pattern.
- Splices A/B (iframe srcdoc embedding) and C (sessionStorage booking-state
  bridge) are app-specific integration, not package concerns. C's note
  about manually extending EXPECTED_COLUMNS stands as a future
  `export_google_sheet(extra_columns =)` candidate — not built this session.

A7 status: **verified end to end 2026-07-09 against the live deployment.**
After a local `gs4_auth()`, the 8 real responses collected so far were read
back through `read_sheet_responses()` (correct columns and values,
`quality_report()` runs) and through SurveyStudio's Google Sheet import
card (responses load, Quality Dashboard renders, completion-time analysis
shows a 163-second median after the timing fix below). Two fixes came out
of it, both in NEWS.md: `read_sheet_responses()` gained a `meta_cols`
passthrough so the deployment's `bk_*` bridge columns can be declared, and
SurveyStudio now passes `started_at`/`submitted_at` to `quality_report()`
so timing analysis works at all in the studio.

One usage note, no code change: importing sheet responses against the full
eligibility instrument flags 100 percent of respondents for missingness,
because the seven `elig_*` items are answered inside the booking prototype
and never reach the sheet. Import against the post-use instrument (the one
actually deployed) and the missingness numbers are meaningful. Worth a
mention in the Google Sheets vignette section in a future patch.

### 2026-07-11 — owner decisions from the review

The live AIC-RSAM deployment stays on the hand-patched 0.3.2 export until
collection ends; it is republished with 0.3.3 afterwards. The lead
vignette gains the plots = TRUE example in this release (added and
knit-verified). Win-builder submission is manual by the owner.

### 2026-07-11 — instrumented review execution and WCAG 2.2 pass

All runnable mas_review_033.qmd chunks executed headlessly; results ticked
in the checklist. An instrumented WCAG 2.2 audit of the exported survey now
reports zero findings across all pages (accessible names, focus visibility,
target sizes, contrast, error and required semantics, headings, keyboard
reordering for ranking). Builder quick wins applied: inspector labels are
programmatically associated and field hints meet contrast. Two real bugs
found and fixed: branching rules had no effect on section breaks and text
blocks (screen-out messages and branched section headings now work), and
`esc(0)` blanking zero-valued attributes. Known divergence recorded: the
Shiny survey renderer (`render_survey()`/`survey_module_ui()`) does not
carry Theme B or the accessibility pass; it converges in the 0.3.4 builder
rework.

### 2026-07-10 — releases merged: 0.3.4 folded into 0.3.3

Owner decision: since neither version had been pushed or submitted, the
planned 0.3.4 (visualisation foundation) and the Theme B survey redesign
merge into 0.3.3 as one release. Version stays 0.3.3, the NEWS entries are
combined, the v0.3.3 tag moves to the final commit, and the remaining
visualisation arc renumbers 0.3.4 to 0.3.8 (breadth, surfaces, effect-size
CIs, psychometric depth, PDF report). The runbook's original "two separate
tags" instruction is superseded by this decision.

### 2026-07-09 — Phase C (v0.3.4) executed after 0.3.3 tagged

v0.3.3 was tagged locally (v0.3.3 on main; pushes pending the project
owner). Phase C then ran to completion in the same session: C1 to C5 all
implemented, tested (519/519), and the plots verified visually against the
AIC-RSAM simulated data. One extra fix rode along, surfaced by looking at
the rendered charts: the frequency and cross-tab runners counted empty
strings as a real category, so partially completed sheet responses showed
as a phantom unnamed bar. They now count as missing. The categorical series
palette was validated programmatically for colour-vision-deficiency
separation and surface contrast rather than picked by eye; the validated
order is documented in `R/plots.R`.

---

## Phase A — v0.3.3: real-world embedding and conference feedback (target 2026-07-25)

Source of truth: `roadmap.md` lines ~130-158. Strict patch scope — **no new
analytical features.** Evidence sources are the AIC-RSAM room-service AI
prototype (local repo: `/home/maxx/Documents/GitHub/AI_Room_service/`, a
QR-accessed mobile static HTML survey with eligibility skip logic and a
six-construct, nine-path model — see `app.js`, `index.html`,
`questionnaire.md`, `research_design.md` there) and the ICSRI 2026
presentation at Villa College, 8-9 August 2026.

### A1. Reproduce the AIC-RSAM instrument as a dev-branch regression fixture

Not started. Read `AI_Room_service/questionnaire.md` and
`AI_Room_service/research_design.md` to rebuild the six-construct, nine-path
instrument as an `sframe` object (or export from surveyframe's builder to
match it), matching its eligibility skip logic. This becomes the fixture the
rest of Phase A is tested against. This mirrors the continuation prompt
already written for this work in `CLAUDE.md` ("Start the 0.3.3 real-world
feedback release").

### A2. Mobile static survey hardening

Not started. Deploy the reproduced instrument as a static HTML survey
(`inst/static_survey/template.html` path) and test on an actual phone-width
viewport (not just a resized desktop browser — check touch target size,
tap-and-hold text selection, on-screen keyboard covering inputs). Fix layout,
touch-target sizing, and progress-bar behaviour on narrow screens.

- **Where:** `inst/static_survey/template.html`, and whatever CSS it shares
  with `inst/builder/survey_builder.html`'s exported-survey template
  (`exportSurveyHtml()` — see Phase B's "Flagged for review" list, this is
  the same export path).
- **Exit signal:** the instrument is usable end to end on a real or
  accurately-emulated phone screen with no layout breakage, no unreachable
  buttons, no keyboard-covers-input issues.

### A3. Branching and skip-logic fixes surfaced by the room-service embedding

Not started — depends on A1 reproducing the instrument first. The AIC-RSAM
instrument has eligibility skip logic; exercise every branch path and fix
whatever the branching engine (`R.render` branching evaluator in the static
template, and the Branching Rule modal in the builder — see Phase B) gets
wrong for this specific instrument's rules.

### A4. Six-construct model syntax correctness checks

Not started — depends on A1. Once the instrument is reproduced, generate its
model syntax (`cfa_syntax()` / model layer) for the six constructs and
nine paths and confirm the syntax is correct lavaan/seminr syntax matching
the intended model. This is a correctness check on existing model-syntax
generation, not new modelling capability.

### A5. Report legibility fixes surfaced by the conference presentation

Not started — this needs an actual `render_report()` run on the AIC-RSAM
data (real or simulated) reviewed at presentation size/projector
resolution, not just a laptop screen. Fix whatever is illegible (font size,
table column width, contrast) in `inst/templates/report.qmd` /
`R/reporting.R` output.

### A6. UI/UX fixes from the ICSRI presentation audience — BLOCKED, excluded from this session

Confirmed 2026-07-08: **do not attempt this deliverable in this session.** It
depends on audience feedback from the 8-9 August 2026 presentation, which has
not happened yet. This isn't a sequencing choice, it's a hard external
blocker — no amount of session time produces real feedback from an event
that hasn't occurred. Do not invent placeholder "audience feedback" to check
this box.

v0.3.3 in this session ships against A1-A5 and A7 only. A6 becomes a
follow-up patch once real ICSRI feedback exists, tracked separately (or
folded into whichever future patch is live at that point) — file it in
`roadmap.md` then, not now. Small, patch-safe SurveyBuilder text/logic fixes
from Phase B tagged `lane: 0.3.3-safe` can still ride with A1-A5/A7 in this
session; they just don't depend on A6's ICSRI feedback to justify inclusion.

### A7. Google Sheets collection verified end to end — highest priority in Phase A

Not started; this is the one item in Phase A that is fully actionable right
now without waiting on external events, and it's explicitly flagged in
`CLAUDE.md` as not yet exercised since 0.3.2 shipped.

- **Where:** `inst/shiny/app.R` (SurveyStudio's Google Sheet response-import
  card), `R/read_sheet_responses.R` (or wherever `read_sheet_responses()`
  lives — confirm exact path), and the builder's Google Sheets settings tab
  / `exportSheetsCollector()` in `inst/builder/survey_builder.html` (also
  listed under Phase B's "Flagged for review", since this dogfeed session
  never opened that settings tab either).
- **What to do:** deploy the AIC-RSAM survey (or any survey) with the
  generated Apps Script collector (.gs file) to a live Google Sheet, submit
  real responses through the deployed static survey, then read them back
  both through SurveyStudio's import card and through
  `read_sheet_responses()` in R. Fix anything broken in that round trip.
- **Exit signal:** a response submitted through the deployed survey is
  correctly readable both in SurveyStudio and via `read_sheet_responses()`
  in R, with no manual data-massaging required.

### Phase A exit criteria (from roadmap.md, verbatim intent)

The room-service instrument deploys and collects responses on a phone
without layout or logic errors, including the Google Sheets collector read
back through SurveyStudio and `read_sheet_responses()`. The rendered report
is readable at conference presentation size.

**None of these can be verified by reading code alone** — A2, A5, and A7 all
require actually running the instrument/report and looking at the result on
the target medium (phone, projector-size render, live spreadsheet). Budget
session time for that, not just for code changes.

---

## Phase B — SurveyBuilder findings from this dogfeed session

Everything below was actually dogfooded (2026-07-06 to 2026-07-08) against
`surveyframe::launch_builder()` / `inst/builder/survey_builder.html`. Each
item has a **lane** tag:

- `lane: 0.3.3-safe` — a bug/logic/text fix, no new capability, small
  enough to plausibly ride with Phase A's "UI/UX fixes" deliverable if the
  project owner agrees. Build these after Phase A's A1-A5 are underway, not
  instead of them.
- `lane: defer` — new capability or a large redesign. Do not build this in
  the same session as Phase A/C without the project owner explicitly
  re-scoping `roadmap.md`. Log it there instead (see "After this session"
  at the bottom of this file) and stop.

### [fixed] `lane: 0.3.3-safe` — Section item's inspector panel mislabels its text field "Question text" instead of a section-appropriate label

Fixed in 0.3.3 (see NEWS.md): the field reads "Section header" for section breaks and "Block text" for text blocks.

- **Where:** SurveyBuilder (`launch_builder()`), Build tab, right-hand item panel, Identity section, for an item of type "Section" (e.g. `sec_1`). Likely `inst/builder/survey_builder.html`, in the inspector field-rendering logic (`renderInspBody()` / field labels keyed by item type).
- **What happened:** When a Section-break item is selected, its inspector shows the field labelled "Question text" (pre-filled with "New section") even though a section break isn't a question — it's a layout/divider element with a header and an introduction text.
- **Expected:** Rename the label for this field to something section-appropriate (e.g. "Section header") when the selected item's type is `section_break`, rather than reusing the generic "Question text" label. Text-only fix, no logic change.
- **Acceptance check:** select a Section item in the Build panel; the field label reads something other than "Question text".

### [open] `lane: defer` — Report writer is static; needs an editable step before exporting to Word/PDF/HTML

- **Where:** `render_report()` in `R/reporting.R` (lines ~192-290) and its Quarto template `inst/templates/report.qmd`. Currently `render_report()`'s `format` argument only accepts `"html"` (`format = c("html")`, `rlang::arg_match(format)`), rendered non-interactively via `quarto render` (or an R Markdown fallback when Quarto isn't installed) straight to a fixed `report.html`. There is no Word/`.docx` or PDF output path and no step where a user can edit content before export.
- **What happened:** The report writer is a one-shot, non-interactive pipeline: instrument + data go in, a fixed HTML report comes out. The user cannot review, edit, reorder, or annotate report content (text, table selection, plot choice) before it is finalised, and cannot export to Word or PDF at all today.
- **Expected:** Add an editable stage between report generation and export — the user should be able to see the drafted report (tables, plots, text) and make edits before committing to a final export, and be able to export the edited version to Word, PDF, and HTML.
- **Why deferred:** this is new capability. PDF export is already explicitly planned for v0.3.9 (`render_report(format = "pdf")` via pagedown, roadmap.md line ~225) — an editable pre-export stage and Word export are not currently in any version's deliverable list. Do not build this in the Phase A/C session; raise it as a candidate addition to v0.3.9 (or its own release) with the project owner instead.

### [open] `lane: defer` — Analyse tab's three sub-tabs need rework (Plan / Run preview / Report outline), and header nav bar needs a UX pass

- **Where:** SurveyBuilder (`launch_builder()`), Analyse tab — the "Plan" / "Run preview" / "Report outline" sub-tab strip, and separately the top header nav bar (Build / Preview / Analyse on the left; Settings / Open / Export survey / Save .sframe on the right). Likely `inst/builder/survey_builder.html`.
- **What happened:** The three Analyse sub-tabs don't currently match what their names imply or what would be most useful: "Plan" should hold the planning phase (adding/editing analysis plan cards, as it does now); "Run preview" should become an analysis queue where the plan cards can actually be drag-and-reordered; "Report outline" currently shows plan-card summaries with "Decision rule pending" placeholders rather than an actual skeleton of the eventual report (empty tables, plot placeholders). Separately, the header nav bar has three buttons grouped on the left and four on the right, which reads as visually unbalanced.
- **What happened (correction, 2026-07-08):** drag-and-reorder of analysis plan cards was checked directly in the source (`pStart`/`pOver`/`pDrop` acting on `S.analysis_plan`, wired to `#rqsBody .rq-card` on the Plan tab) and it does exist and appears functional on the Plan tab today. The original complaint stands for the *Run preview* tab specifically, which shows no plan cards or queue at all right now.
- **Expected:** Rework the three sub-tabs so each does the job its name implies. Decide whether "Report outline" is still the right name or whether "Report skeleton" / "Report preview" communicates it better. Separately, have a UI/UX pass on the header nav bar's left/right button grouping and balance.
- **Why deferred:** this is a redesign of existing surfaces, part of the "Design improvement arc" (below), not a bug fix.

### [open, suggestTest part fixed] `lane: 0.3.3-safe` (validation only) / `lane: defer` (rest) — Auto-draft Research question / Planned decision rule from selected variables; add a human-readable item label separate from Item ID

The suggestTest review ran in 0.3.3 and found two actual wrong suggestions, both fixed (see NEWS.md): Likert items were classified as categorical, so a Likert paired with a continuous variable suggested Mann-Whitney with a five-category grouping; and Mann-Whitney was suggested even when the grouping variable had more than two categories (now Kruskal-Wallis). Citation tags were checked against the ten references in CSHORT and are accurate. The auto-draft text generation and the human-readable item label remain `defer`.

- **Where:** SurveyBuilder (`launch_builder()`), Analyse tab, "Add Analysis Plan" modal — "Research question" and "Planned decision rule in Plan stage" free-text fields, populated after Grouping variable / Outcome variable / Variable X / Variable Y and Analysis method are chosen. Also Build tab, right-hand item panel, Identity section — "Item ID" field. Likely `inst/builder/survey_builder.html` and `R/analysis_plan.R`.
- **What happened:** "Research question" and "Planned decision rule" are currently blank free-text boxes the user must write from scratch, even though the grouping/outcome/X/Y variables and analysis method are already known at that point and could seed a sensible draft sentence. Separately, the only per-item label available in the Build panel is "Item ID" (e.g. `lik_1`, `rat_1`), a machine-safe identifier — there is no separate human-readable label field for an item, needed to print readable variable names in result tables and plots rather than raw IDs.
- **Also worth checking:** the builder already has a `suggestTest()` / suggestion-box feature that proposes a statistical test based on selected variable roles, and auto-populates reporting-citation tags (Field 2018, Cohen 1988, etc.) per method. Neither has been reviewed for quality of suggestion or citation accuracy.
- **Expected:** Auto-generate a draft "Research question" and "Planned decision rule" from the selected variables and method, editable by the user. Add a distinct human-readable label field per item.
- **Split:** if `suggestTest()` review turns up an actual wrong suggestion (not just "could be smarter"), that's a `0.3.3-safe` bug fix. The auto-draft text generation and the new item-label field are new capability — `defer`.

### [fixed] `lane: 0.3.3-safe` — Add Analysis Plan: no validation against picking the same variable for X and Y, and other logic gaps to review

Fixed in 0.3.3 (see NEWS.md): a variable can fill only one role per plan, covering X = Y, mediation X/M/Y conflicts, and dependent-in-predictors. The suggestTest review also found and fixed two wrong suggestions (Likert misclassified as a grouping candidate, and Mann-Whitney suggested for groupings with more than two categories). The processr/model-builder question stays open as its own future scoping item.

- **Where:** SurveyBuilder (`launch_builder()`), Analyse tab, "Add Analysis Plan" modal — Variable X / Variable Y selects for correlation-type methods, and the Analysis method dropdown (Association: Pearson, Spearman, Kendall tau, Partial correlation; Regression: Linear, Binary logistic, Ordinal logistic, Multinomial logistic, Mediation, Moderation; Measurement and models: Cronbach alpha, McDonald omega, Item diagnostics, EFA readiness, EFA solution, CFA lavaan syntax, ...). Likely `inst/builder/survey_builder.html` and the analysis-plan validation logic in `R/analysis_plan.R`.
- **What happened:** For Pearson correlation (and likely the other Association methods), Variable X and Variable Y can both be set to the same item with no warning, which is not a meaningful analysis. The modal's validation only checks "required roles are complete" and variable-type compatibility, not cross-field logical constraints.
- **Expected:** Add a validation rule preventing the same variable being assigned to both X and Y (and equivalent same-variable conflicts in other methods, e.g. mediation/moderation X/M/Y). Review the rest of the modal's methods for comparable logic holes.
- **Acceptance check:** in the Pearson correlation method, selecting the same item for X and Y produces a validation error/warning instead of a silently-accepted plan.
- **Separately raised, not in scope for this session:** whether to expand regression/modelling options by adopting an approach from cardiomoon/processr (https://github.com/cardiomoon/processr) or adding a point-and-click model-builder GUI. This needs a licence check before any adoption decision and is its own future scoping question — do not act on it in this session, just note it exists.

### [fixed, boundable half] `lane: 0.3.3-safe` — Builder startup flow skips survey settings, has no load-existing-survey path, and needs SHA-integrity handling surfaced — rethink against the Shiny (SurveyStudio) workflow

Fixed in 0.3.3 (see NEWS.md): opening a `.sframe` now verifies and reports SHA-256 integrity (verified / mismatch / no hash), and the empty canvas offers "Open an existing .sframe" and "Set up survey settings first" links. The full startup-sequence redesign (settings walkthrough before the canvas) remains `defer` as planned.

- **Where:** `surveyframe::launch_builder()` initial load state (blank canvas with "No questions yet" / "Select a question to edit"). Likely `inst/builder/survey_builder.html`, and worth comparing against `inst/shiny/app.R` (SurveyStudio) which already has an Upload/Open-existing-instrument flow.
- **What happened:** On startup the builder drops straight into an empty "Untitled Survey" build canvas with no questions and no prompt to configure the survey first. There is no visible option at startup to open/load an existing `.sframe` instrument (only "Open" in the header, not surfaced as a first-run choice), and no visible surfacing of the instrument's SHA-256 integrity hash when a survey is loaded or resumed.
- **Also confirmed present (not yet surfaced at startup):** the builder does have working SHA-256 hashing on save (`sframeHash()` in `inst/builder/survey_builder.html`, using `crypto.subtle` with a pure-JS RFC 6234 fallback). The mechanism exists; it's just never shown to the user at load/open time.
- **Expected:** (1) start by asking whether to create a new survey or open an existing `.sframe`, (2) for a new survey, walk through Survey Settings (or at least title/version/language) before landing on the empty build canvas, (3) when opening an existing instrument, verify and surface its SHA-256 integrity status rather than silently loading it. Design consistently with SurveyStudio's existing open/upload flow.
- **Note on lane:** the "open/load a survey at startup + surface SHA integrity on load" half is a straightforward, boundable fix — `0.3.3-safe`. The full startup-sequence redesign (settings walkthrough before the canvas) is closer to a UX redesign — if session time is short, do the load-path and integrity-surfacing half first and treat the rest as `defer`.

### [open] `lane: defer` — Survey settings has two separate entry points; consolidate into one prominent CTA in the left panel

- **Where:** SurveyBuilder (`launch_builder()`), Build tab — the gear icon next to "Demo 1" at the top of the left panel, and the "Settings" button in the header navigation bar. Likely `inst/builder/survey_builder.html`.
- **What happened:** Survey-level settings can be reached from two different places, which is likely to confuse users about which one to use or whether they do different things.
- **Expected:** Redesign into a single, prominent call-to-action button for survey settings, placed at the top of the left panel, above the Welcome/Logo/Thank You buttons. Remove or fold in the duplicate entry point in the header.
- **Why deferred:** layout redesign, part of the Design improvement arc below.

### [fixed] `lane: 0.3.3-safe` — New choice-based question inherits the previous question's choice set

Fixed in 0.3.3 (see NEWS.md): new choice questions start with their own sample set, and editing a shared set on a choice question forks it first.

- **Where:** SurveyBuilder (`launch_builder()`), Build tab, right-hand item panel, Configuration section — "Choice set" / "Choice labels" fields for a newly added Multiple choice / Single choice item. Likely `inst/builder/survey_builder.html`.
- **What happened:** Adding a new choice-based question pre-fills its Choice set / Choice labels with the previous question's choices (e.g. a new item showed `mul_1_choices (3 opts)` with Egg/Chicken/Soya carried over) instead of starting fresh.
- **Expected:** A newly added question of a choice-based type should start with either a blank choice set or a sample choice set appropriate to that specific question type, not the previous question's choices.
- **Acceptance check:** add a Multiple choice item after another Multiple/Single choice item exists; the new item's choice set is not the prior item's choices.

### [open] `lane: defer` (surfacing) / `lane: 0.3.3-safe` (default-choices bug above already covers the core defect) — "+ Add question" flow conflates type-picking, configuration, and choice-set selection

- **Where:** SurveyBuilder (`launch_builder()`), Build tab, "+ Add question" button and its adjacent "..." menu (bottom-left of the item list). Likely `inst/builder/survey_builder.html`.
- **What happened:** Clicking "+ Add question" immediately inserts a default question (an "Agreement item" / Likert type) instead of first asking what type of question to add. The type picker exists but is a separate control from the "+ Add question" button.
- **Also confirmed present (not yet surfaced up-front):** the choice-set modal already has quick-fill sample templates (5-pt agree, 7-pt agree, Yes/No, Frequency, Importance) plus "Include Other option" and "Randomise order" checkboxes — it's just buried inside the Choice Set modal rather than offered at add-question time.
- **Expected:** "+ Add question" should open the question-type dropdown directly rather than defaulting to Likert. Configuration options should live in their own dedicated panel/button, separate from the type-picker dropdown. Choice-set entry should surface the existing quick-fill templates at add-question time.
- **Why deferred:** the "+ Add question opens the type picker directly" change and moving configuration into its own panel is an interaction redesign. It's bundled with the Design improvement arc.

### [fixed] `lane: defer`, re-scoped by owner 2026-07-09 — Question-block designs need a standard design system, benchmarked against Formbricks

Resolved 2026-07-09 on the owner's instruction. Three mock directions were
built (Formbricks option cards, Typeform conversational, branded
editorial); the owner chose the conversational direction ("Theme B") and
asked for it to derive entirely from the builder's single theme-colour
selector. Applied to `inst/static_survey/template.html` (and re-inlined
into the builder): serif question typography, bordered option cards with
key chips and ticks, numbered Likert squares, underline text inputs,
topbar progress with a theme dot, per-question eyebrow in conversational
mode. All tints and shades derive from `--cp` via `color-mix()`, so any
picker colour re-skins the whole survey. Verified through the real export
path at phone width (teal, blue, violet variants), through SurveyStudio's
preview iframe, and by the headless branching suite (519/519). Touch
targets stay at 44px or better. The builder's own Preview tab still uses
its simplified renderer and will lag the new design; restyling it is the
remaining piece of this arc.

- **Where:** All rendered question types across the survey-taking surfaces (static survey template, SurveyStudio preview, builder preview) — multi-select checkboxes, single-select radios, rating/star scales, numeric scales.
- **What happened:** Reference screenshots supplied from formbricks.com/survey-templates (Employee Satisfaction and User Persona templates) show a consistent design language across block types: full-width selectable option rows/cards with visible borders and hover state, a top progress bar, consistent Back/Next button placement, a 1-5 button-style numeric scale, and a 5-star rating control. surveyframe's current blocks do not share one consistent visual system across types.
- **Expected:** Define one shared design system for all question-block types and apply it consistently. Formbricks templates are the reference benchmark, not a literal restyle target.
- **Why deferred:** this is exactly the kind of work the 0.3.4-0.3.9 visualisation/theming arc is for, but it is not one of v0.3.4's actual roadmap deliverables (which are ggplot2-analysis plots, not question-block CSS — see Phase C). Raise it as a candidate for its own slot in that arc, or as a v0.3.4.x addendum, with the project owner. Do not fold it into Phase C's ggplot2 work — they are unrelated code paths (client-side HTML/CSS vs. R/ggplot2).

### [fixed] `lane: 0.3.3-safe` — Header not shown on Welcome screen; inconsistent positioning on Survey screen

Fixed in 0.3.3 (see NEWS.md): the builder preview shows the branded header on Welcome, Survey, and Thank You, and both the preview and the static template give the logo a stable bounding box so the title no longer shifts with logo aspect ratio.

- **Where:** SurveyBuilder (`launch_builder()`), Preview tab — Welcome screen vs. Survey screen. Likely `inst/builder/survey_builder.html` and/or the shared header partial also used by `inst/static_survey/template.html` (`R.render.header`).
- **What happened:** The branded header (logo + title) does not render on the Welcome screen preview at all. It does render on the Survey screen, but its layout is not standard: the title text shifts position depending on the logo's proportions/aspect ratio.
- **Expected:** Header should render consistently on every screen (Welcome, Survey, Thank You), and its layout should be stable regardless of the logo's aspect ratio.
- **Why 0.3.3-safe:** this is a rendering bug in the same header/template code path A2 (mobile hardening) already touches for the AIC-RSAM instrument — fix it alongside A2 rather than as a separate pass, since it's plausible the AIC-RSAM instrument has a logo and hits this exact bug.

### Design improvement arc (all `lane: defer` items above, as one body of work)

These four items are one cohesive builder UX/design pass, not four unrelated
bugs. If/when the project owner scopes this as its own release or a v0.3.4.x
addendum, ship them together and re-verify item-list drag-to-reorder
(confirmed working, session log above) once this arc's markup/CSS changes
land:

1. Question-block design system, benchmarked against Formbricks.
2. Analyse tab's three sub-tabs rework + header nav bar balance.
3. Survey settings' two entry points consolidated to one CTA.
4. "+ Add question" flow reworked: type picker first, configuration and
   choice-set selection split into their own controls.

### Flagged for review — builder features not yet dogfooded

Compiled 2026-07-08 from a direct read of `R/builder.R` and
`inst/builder/survey_builder.html`. These exist in the builder today but
haven't been clicked through or commented on by a real user. Not bugs — an
inventory of what still needs eyes. If Fable 5 has session time left after
Phase A and the `0.3.3-safe` items above, exercising these (especially the
Google Sheets tab, which duplicates A7's scope from the builder side) is
higher value than starting Phase C early.

**Build tab — core editing**
- Item search box (`#itemSearch`) — live filter vs. requires Enter, unclear.
- Duplicate / Delete item, including the confirm dialog claiming deletion
  "removes the item from all scales, branches, and checks" — worth
  stress-testing that cross-reference cleanup actually happens correctly.
- Section break / Text block layout items beyond the label bug logged above.
- Individual question types not yet commented on: Matrix/grid, Numeric,
  Short text, Long text, Slider, Date, Ranking (in-survey drag reorder),
  Rating (surveyframe's own star control).

**Choice set / Scale / Branching / Attention check modals**
- Scale definer modal (mean/sum aggregation, min valid items, item picker,
  reverse-coded item picker) — untouched; feeds reliability/EFA downstream.
- Branching rule modal (target/controlling question, six condition
  operators, show/hide action) — untouched. **Relevant to A3** (AIC-RSAM
  skip logic) — review this modal while working A3.
- Attention check modal (attention/instructional/trap types, flag-vs-exclude
  fail action, correct-answer matching) — untouched.

**Analyse tab**
- Model Builder panel (lavaan CFA, lavaan CB-SEM, seminr PLS-SEM output
  engines; "Create model from scales"; path-from/path-to SEM diagram
  builder; "Export syntax") — a substantial, entirely untouched feature area.
  **Relevant to A4** (six-construct model syntax checks) — review this panel
  while working A4.
- Variable role classification (`varLevel()` in the builder script) — how
  item type maps to nominal/ordinal/likert/continuous/text/identifier;
  worth checking it classifies Slider and Date sensibly.

**Settings modal tabs**
- Welcome tab: consent checkbox + "require before starting" toggle,
  start-button label.
- Thank You tab: redirect URL, "Download my response" button toggle.
- Header tab: institution/study name field, progress-bar toggle.
- **Google Sheets tab: Sheet URL, "Generate collector (.gs)" button, Apps
  Script Web App URL — this is the builder-side surface for A7. Review it as
  part of A7, not separately.**
- Theme colour picker (swatch synced to hex text input).
- Presentation mode: Standard (all questions visible) vs Conversational (one
  question at a time) — changes the whole survey-taking UX, untested.

**Export / integrity**
- Export survey (self-contained deployable HTML via `exportSurveyHtml()`) —
  **this is the export path A2 needs for the AIC-RSAM mobile deployment.**
  Review it as part of A2, not separately.
- Open / Save `.sframe` round-trip end to end (beyond the hash mechanism
  itself, confirmed present above).

**Small polish**
- Toast notifications and the confirm-dialog overlay — no comments on
  wording/timing.
- Conversational-mode preview pagination (prev/next through one-question-
  at-a-time pages).

---

## Phase C — v0.3.4: visualisation foundation (target 2026-08-15)

Source of truth: `roadmap.md` lines ~160-172. **Start this phase only after
Phase A's exit criteria are met.** Patch scope rules apply: hard Imports stay
unchanged, ggplot2 goes in `Suggests` and every new capability is guarded
with `rlang::check_installed()`. Nothing here was dogfooded this session —
it's new implementation work from the roadmap deliverables, listed for
completeness so Fable 5 can execute both versions without switching context.

### C1. Add ggplot2 to Suggests

- **Where:** `DESCRIPTION` — current `Suggests:` block is `googlesheets4,
  shiny, psych, MASS, nnet, digest, lavaan, testthat, knitr, rmarkdown`. Add
  `ggplot2 (>= 3.4.0)` (confirm minimum version against what brand-theme work
  needs) to that list.
- **Guard pattern:** follow the existing `rlang::check_installed()` pattern
  already used for other optional packages in the codebase (check `R/` for
  precedent, e.g. how `lavaan` or `psych` are guarded) so plotting code
  degrades gracefully when ggplot2 isn't installed.

### C2. Brand theme: `theme_surveyframe()`

- Not started. A new exported `ggplot2::theme()` object matching the
  package's existing brand (colour palette, typography) used elsewhere
  (report tables, the builder's theme-colour picker default `#2563eb`,
  `man/figures/brand-preview.png` if that exists as a reference). Check
  `pkgdown`/brand source files referenced in `CLAUDE.md`'s ecosystem section
  for the canonical brand definition before inventing colours.

### C3. `plots = TRUE` argument on the main analysis runners

- Not started. Identify "the main analysis runners" precisely — likely the
  functions registered in `run_analysis_plan()`'s method registry
  (`R/analysis_plan.R`). Each needs a new `plots` argument, default `FALSE`
  (opt-in, per roadmap principle), that attaches a ggplot2 object (or list of
  them) to the result when `TRUE` and ggplot2 is installed.

### C4. First family of plots

- Not started. Two plot types per roadmap: bar charts for categorical
  runners (single/multiple choice, nominal association tests), and
  scatter/regression overlays for correlation and regression runners
  (Pearson/Spearman correlation, linear regression). Use `theme_surveyframe()`
  from C2.

### C5. `$table` slot on inferential runners

- Not started. Add a `$table` element to the return object of inferential
  runners (the same runners C3 touches) — a formatted `data.frame` suitable
  for `knitr::kable()`. Confirm the exact set of "inferential runners" by
  reading `R/analysis_plan.R` and `R/statistics_reports.R` (the two largest
  analysis files per `CLAUDE.md`'s key file map) rather than guessing from
  the roadmap's one-line description.

### Phase C exit criteria (from roadmap.md, verbatim intent)

Roadmap.md doesn't state an explicit exit-criteria line for v0.3.4 the way it
does for v0.3.3 — treat "all four deliverables (C1-C5) implemented, guarded,
tested, and documented" as the bar, and confirm with the project owner before
tagging a release if that reading is wrong.

---

## Ship checklist (run for whichever version(s) you actually complete)

Do not tag or announce either version as shipped without this. Adapted from
the `CLAUDE.md` continuation prompts and the 0.3.2 precedent in this file's
history (`revision_todo_0.3.md`, `cran-comments.md`).

1. `devtools::document()` — regenerate `man/` and `NAMESPACE` if any exported
   surface changed (Phase C almost certainly adds an export;
   `theme_surveyframe()` needs `@export`).
2. `devtools::test()` — full suite must pass. Current baseline is 368/368 at
   0.3.2 (see memory note "Test count 368" — verify this figure against
   `devtools::test()` output directly rather than trusting a stale number).
3. Bump `Version:` in `DESCRIPTION` (currently `0.3.2`) to `0.3.3` or `0.3.4`
   as appropriate, one version at a time — don't jump straight to 0.3.4 in
   `DESCRIPTION` while 0.3.3 hasn't been tagged/released.
4. Add a `NEWS.md` entry at the top, following the existing 0.3.2 entry's
   format and tone (see current top of `NEWS.md`) — describe what changed and
   why, no new hard dependencies for either version.
5. `R CMD build .` then `R CMD check --as-cran` on the resulting tarball.
   Target: 0 errors, 0 warnings, at most 1 NOTE (incoming feasibility).
6. Update `roadmap.md`: mark the version's status line as done, with the
   actual ship date, matching how prior versions in that file are marked
   (`done 2026-06-02` style).
7. Update or remove items in this file: anything actually fixed gets its
   status flipped to `fixed` (not deleted — the log stays for history) with
   a one-line note pointing at the NEWS.md entry. Anything explicitly
   decided against gets `wontfix` with the reason.
8. Follow the branch/remote convention exactly as documented in `CLAUDE.md`:
   package changes on `main`, pushed to both `origin` (private
   surveyframe-dev) and `public` (public surveyframe) per the *actual*
   `git remote -v` output — note `CLAUDE.md`'s prose names the remotes the
   other way around (`origin` = public, `private` = private); trust
   `git remote -v`, not the prose, if they disagree. Planning-file changes
   (this file, `roadmap.md`, etc.) stay on `dev`, pushed to the private
   remote only.
9. Only commit/push when the project owner asks — this rule from `CLAUDE.md`
   applies to Fable 5's session exactly as it does to any other.

## After this session

**Confirmed 2026-07-08: v0.3.5 through v0.4 are explicitly out of scope for
this session.** The project owner was asked whether to push the session all
the way to v0.4 and said no, given (a) A6's hard external blocker above and
(b) the six-patch 0.3.4-0.3.9 visualisation arc plus v0.4's small-sample
inference and RStudio add-in work is genuinely months of scoped,
21-day-cadence work in `roadmap.md` — not something to compress into one
session without a real quality cost. Once Phase C (v0.3.4) ships, stop.

Anything tagged `lane: defer` above, plus the Design improvement arc and the
"Flagged for review" inventory items that turn out to need real work, plus
v0.3.5 onward in general, should get written into `roadmap.md` as their own
scoped entry (a v0.3.4.x addendum, or a slot in the 0.3.5-0.3.9 arc) and
picked up in a future session, rather than live only in this dogfeed file
indefinitely or get started here. That's a decision for the project owner,
not something to self-assign mid-session.
