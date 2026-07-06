# surveyframe dogfeed log

Excluded from the CRAN build (via .Rbuildignore) and from the public repo
(via .gitignore). Lives only in the dev workspace.

Running log of feedback from using surveyframe as a real user (dogfeeding):
bugs, rough edges, confusing copy, missing affordances, anything that would
trip up someone new to the package. Each item gets a status so nothing raised
in a session gets lost before triage.

Status key: `open` (raised, not yet triaged), `planned` (assigned to a version
in roadmap.md), `fixed` (done, needs a note in NEWS.md), `wontfix` (decided
against, with reason).

---

## Session log

### 2026-07-06 — session opened

Fresh dogfeed session started via `surveyframe::launch_builder()`. Source
files are not to be edited until this session is declared complete; items are
logged only.

---

## Items

<!-- Add new items above this line as they come in, newest first. Format:

### [status] Short title

- **Where:** file/screen/function
- **What happened:**
- **Expected:**
- **Version target:** (roadmap version, or "triage")

-->

### [open] Survey settings has two separate entry points; consolidate into one prominent CTA in the left panel

- **Where:** SurveyBuilder (`launch_builder()`), Build tab — the gear icon next to "Demo 1" at the top of the left panel, and the "Settings" button in the header navigation bar. Likely `inst/builder/survey_builder.html`.
- **What happened:** Survey-level settings can be reached from two different places (left-panel gear icon and header "Settings" button), which is likely to confuse users about which one to use or whether they do different things.
- **Expected:** Redesign this into a single, prominent call-to-action button for survey settings, placed at the top of the left panel, above the Welcome/Logo/Thank You buttons. Remove or fold in the duplicate entry point in the header.
- **Version target:** triage

### [open] New choice-based question inherits the previous question's choice set

- **Where:** SurveyBuilder (`launch_builder()`), Build tab, right-hand item panel, Configuration section — "Choice set" / "Choice labels" fields for a newly added Multiple choice / Single choice item. Likely `inst/builder/survey_builder.html`.
- **What happened:** Adding a new choice-based question pre-fills its Choice set / Choice labels with the previous question's choices (e.g. a new item showed `mul_1_choices (3 opts)` with Egg/Chicken/Soya carried over) instead of starting fresh.
- **Expected:** A newly added question of a choice-based type should start with either a blank choice set or a sample choice set appropriate to that specific question type, not the previous question's choices.
- **Version target:** triage

### [open] "+ Add question" flow conflates type-picking, configuration, and choice-set selection

- **Where:** SurveyBuilder (`launch_builder()`), Build tab, "+ Add question" button and its adjacent "..." menu (bottom-left of the item list). Likely `inst/builder/survey_builder.html`.
- **What happened:** Clicking "+ Add question" immediately inserts a default question (an "Agreement item" / Likert type) instead of first asking what type of question to add. The type picker (Likert scale, Single choice, Multiple choice, Matrix/grid, Numeric, Short text, Long text, Slider, Ranking, Rating, ...) exists but is a separate control from the "+ Add question" button, so the two flows don't match user expectation: clicking "+ Add question" should be the moment the type list appears.
- **Expected:** "+ Add question" should open the question-type dropdown directly (Likert, single choice, multiple choice, etc.) rather than defaulting to Likert. Once a type is picked, its configuration options should live in their own dedicated panel/button, separate from the type-picker dropdown. Choice-set entry (the option list for choice-based types) should have its own button with a comprehensive set of ready-made sample choice sets (e.g. Yes/No, Agree-Disagree scales, common demographic lists) that the user can pick from, rather than starting blank every time.
- **Version target:** triage

### [open] Question-block designs need a standard design system, benchmarked against Formbricks

- **Where:** All rendered question types across the survey-taking surfaces (static survey template, SurveyStudio preview, builder preview) — multi-select checkboxes, single-select radios, rating/star scales, numeric scales.
- **What happened:** Reference screenshots supplied from formbricks.com/survey-templates (Employee Satisfaction and User Persona templates) show a consistent design language across block types: full-width selectable option rows/cards with visible borders and hover state, a top progress bar, consistent Back/Next button placement (Next bottom-right, Back bottom-left, appearing once past the first question), a 1-5 button-style numeric scale, and a 5-star rating control. surveyframe's current blocks do not share one consistent visual system across types (plain checkboxes/radios, no progress bar, no consistent card/row treatment).
- **Expected:** Define one shared design system for all question-block types (spacing, option-row/card treatment, selected/hover states, progress indicator, Back/Next placement) and apply it consistently, rather than each block type having its own ad hoc look. Formbricks templates are the reference benchmark, not a literal restyle target.
- **Version target:** triage (likely a 0.3.4+ visualisation/theming arc item — confirm against roadmap.md when triaged)

### [open] Header not shown on Welcome screen; inconsistent positioning on Survey screen

- **Where:** SurveyBuilder (`launch_builder()`), Preview tab — Welcome screen vs. Survey screen. Likely `inst/builder/survey_builder.html` and/or the shared header partial also used by `inst/static_survey/template.html` (`R.render.header`).
- **What happened:** The branded header (logo + "Surveyframe" title) does not render on the Welcome screen preview at all. It does render on the Survey screen, but its layout is not standard: the title text shifts position depending on the logo's proportions/aspect ratio, rather than sitting in a fixed layout slot.
- **Expected:** Header should render consistently on every screen (Welcome, Survey, Thank You), and its layout should be stable regardless of the logo's aspect ratio.
- **Version target:** triage
