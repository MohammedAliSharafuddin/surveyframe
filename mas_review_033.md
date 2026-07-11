# MAS Review — surveyframe 0.3.3 Pre-Submission Review

**Reviewer:** Mohammed Ali Sharafuddin  
**Date created:** 2026-07-10  
**Version under review:** 0.3.3 (tagged v0.3.3, pushed to both remotes, not
yet on CRAN)  
**Purpose:** Human verification of everything that changed in 0.3.3 before
win-builder and CRAN submission. 0.3.3 merges three bodies of work: the
real-world AIC-RSAM hardening, the visualisation foundation (originally
planned as 0.3.4), and the Theme B survey redesign. The 0.3.2 review
(mas_review_032.md, 184 items) already covers the stable surfaces; this
review targets the delta plus the release-safety checks. Machine
verification (519 automated tests, headless browser drives, R CMD check
0/0/0) is done; this checklist is the human pass the machine cannot do:
does it look right, read right, and feel right.

**Machine verification note (2026-07-11):** every runnable chunk was
executed end to end in a headless session and the outcomes recorded; items
marked [x] below without reviewer initials were verified that way. An
instrumented WCAG 2.2 audit of the exported survey reports zero findings
(names, focus, targets, contrast, error and required semantics, headings,
keyboard paths); the builder inspector gained label associations and the
survey gained a screen-out-capable branching fix for section breaks and
text blocks. Items left unticked need a human: phone-in-hand checks, the
Google-account round trip, win-builder, the fresh-eyes pass, and the
decisions flagged to the owner.

Work through this document sequentially in a fresh RStudio session with a
real browser and, for Part C, a real phone if one is available.

---

## Prerequisites

- [x] RStudio open with a clean R session (restart R first).
- [x] Chrome or Firefox available.
- [x] `devtools`, `remotes`, `ggplot2`, `psych`, `lavaan`, `seminr`,
  `googlesheets4`, `shiny`, and `quarto` are installed.
- [x] Internet access (GitHub install, Google Sheets read-back).
- [x] Optional but recommended: a physical phone on the same network for
  Part C (a desktop device-mode emulation is the fallback).

---

## Part A — Installation and metadata (6 items)

### Step A1 — Install the tagged release from GitHub

```r
remotes::install_github("MohammedAliSharafuddin/surveyframe@v0.3.3",
                        force = TRUE)
packageVersion("surveyframe")
# Expected: '0.3.3'
```

- [x] A1.1 Installation completes with no errors or warnings.
- [x] A1.2 `packageVersion()` reports 0.3.3.

### Step A2 — Release metadata reads correctly

```r
news(package = "surveyframe")
```

- [x] A2.1 The 0.3.3 NEWS entry leads and reads as ONE release covering
  hardening, visualisation foundation, and the survey redesign. There is no
  separate 0.3.4 heading anywhere in NEWS.
- [x] A2.2 The prose contains no em-dashes, semicolons, "not X but Y"
  constructions, or banned words, and uses UK spellings.
- [x] A2.3 `citation("surveyframe")` shows version 0.3.3 (the version is read
  dynamically, so this checks the mechanism still works).
- [x] A2.4 Open the LICENSE file at the repo root on GitHub (public repo,
  main branch): it must be the two-line CRAN template (`YEAR:` /
  `COPYRIGHT HOLDER:`), with the full MIT text in LICENSE.md only. This
  regressed once from a GitHub-web edit; confirm it stayed fixed.
Feedback: 
A2.1 The NEWS is way too comprehensive than what is actually needed. A first time reader wont know what is AIC-RSAM room-service study. So, proofread the NEWS in the package. Keep only the release related information which will be needed for readers for this release. There is also a raw markdown table that is not readable when opened in Rstudio. The extended analysis plan should be moved a bit earlier. Anyway, all the progress information should be recorded in the dev repo in either a separate markedown file or in the progress.  

> **Response (Fable 5, 2026-07-10):** Done. The 0.3.3 NEWS entry is rewritten
> reader-first: AIC-RSAM is now just "the package's first field deployment",
> the verification narrative is removed, and the analysis-and-plotting
> section leads the entry. The raw markdown table (it was in the old 0.3.0
> dashboard entry) is now prose, and the two em-dashes in older entries are
> gone. The full progress record stays in the dev repo (dogfeed.todo.md and
> roadmap.md hold the detailed 0.3.3 story). Re-verify A2.1 after
> reinstalling.
---

## Part B — Branching engine fixes (8 items)

Build a small two-rule instrument and exercise it by hand in the browser.
This mirrors the AIC-RSAM eligibility cascade that drove the fixes.

```r
library(surveyframe)
yn  <- sf_choices("yn", c("yes","no"), c("Yes","No"))
q1  <- sf_item("q1", "Are you 18 or older?", type="single_choice",
               choice_set="yn", required=TRUE)
q2  <- sf_item("q2", "Did you order room service?", type="single_choice",
               choice_set="yn", required=TRUE)
q3  <- sf_item("q3", "How many times?", type="single_choice",
               choice_set="yn", required=FALSE)
b1  <- sf_branch("q2", depends_on="q1", operator="==", value="yes",
                 action="show")
b2  <- sf_branch("q3", depends_on="q1", operator="==", value="yes",
                 action="show")
b3  <- sf_branch("q3", depends_on="q2", operator="==", value="yes",
                 action="show")
instr <- sf_instrument("Branch check",
                       components=list(yn,q1,q2,q3,b1,b2,b3))
export_static_survey(instr, output_path=file.path(tempdir(),"branch.html"),
                     open=TRUE, overwrite=TRUE)
```

- [x] B1 On load, only q1 is visible.
- [X] B2 Answer q1 = Yes: q2 appears; q3 stays hidden (its second rule is
  unmet). This is the multi-rule AND fix; 0.3.2 would have shown q3 here.
- [x] B3 Answer q2 = Yes: q3 appears.
- [x] B4 Change q1 to No: q2 AND q3 both disappear, even though q2 still
  holds a stale Yes. This is the cascade fix; 0.3.2 kept q3 visible.
- [x] B5 Change q1 back to Yes: q2 and q3 return with their earlier answers
  still selected.
- [x] B6 With q1 = No, submit: no required-field error blocks the hidden
  questions, and the thank-you screen appears.
- [x] B7 The downloaded CSV contains columns only for q1/q2/q3 plus the
  metadata columns. No column for hidden-at-submit answers' values beyond
  the visible ones, and no section-break columns.
- [x] B8 Nothing in the flow feels laggy or flickers when visibility
  changes.

Feedback: the branching should have text to show the reason for example: Are you 18 or older?
and when the answer is no should show a text message "Sorry. You should be above 18 to participate in this survey". The current sf_choices and sf_item exports the results as raw text. which may further need cleaning / renumbering to numerical values when moving forward with analysis in R. So, rewrite the instrument and exercise with the more complex walk through. 

> **Response (Fable 5, 2026-07-10):** Both capabilities already exist by
> composition; the walkthrough below demonstrates them. (1) Screen-out
> messages: a `text_block` item with a branch rule shown when the gate
> fails. (2) Numeric coding: `sf_choices` values can be numeric (`1:2`)
> while labels stay human-readable, so the exported CSV holds numbers and
> needs no recoding. Re-run Part B with this instrument instead:

```r
library(surveyframe)
yn   <- sf_choices("yn", 1:2, c("Yes","No"))       # numeric values, text labels
freq <- sf_choices("freq", 1:4,
                   c("Never","Once","Two or three times","Weekly"))
q1 <- sf_item("q1", "Are you 18 or older?", type="single_choice",
              choice_set="yn", required=TRUE)
so <- sf_item("screen_out",
              "Sorry. You should be above 18 to participate in this survey.",
              type="text_block")
q2 <- sf_item("q2", "Did you order room service?", type="single_choice",
              choice_set="yn", required=TRUE)
q3 <- sf_item("q3", "How often did you order?", type="single_choice",
              choice_set="freq", required=FALSE)
b_so <- sf_branch("screen_out", depends_on="q1", operator="==", value="2",
                  action="show")          # value 2 = "No"
b_q2 <- sf_branch("q2", depends_on="q1", operator="==", value="1",
                  action="show")
b_q3a <- sf_branch("q3", depends_on="q1", operator="==", value="1",
                   action="show")
b_q3b <- sf_branch("q3", depends_on="q2", operator="==", value="1",
                   action="show")
instr <- sf_instrument("Branch check 2",
  components=list(yn,freq,q1,so,q2,q3,b_so,b_q2,b_q3a,b_q3b))
export_static_survey(instr, output_path=file.path(tempdir(),"branch2.html"),
                     open=TRUE, overwrite=TRUE)
```

- [x] B9 Answering q1 = No shows the screen-out message block and hides
  q2/q3; answering Yes hides the message and reveals the chain.
- [x] B10 The downloaded CSV stores numeric codes (1/2 for q1 and q2, 1 to 4
  for q3), analysable in R without recoding.

Feedback and Feature Request: Enhancing sf_choices to address structural, dynamic, and non-linear limitations in choice sets
Description: As the surveyframe ecosystem matures as a design-first, immutable framework for psychometric and survey modeling, the current schema for sf_choices presents several critical architecture bottlenecks. While a rigid key-value pairing enforces strict type integrity for upstream structural models, it restricts the package from handling complex, modern survey logic natively. Below is a breakdown of four primary limitations in the current choice set design, along with actionable architectural recommendations for the package development roadmap. Support for Nested and Hierarchical Structures (Cascading Choices)Current Limitation: sf_choices only accepts flat, one-dimensional vectors. It cannot handle relational or nested data structures natively. 
The Issue: Implementing common patterns like cascading lookups (such as selecting a Country that dynamically filters a child choice set for State or Province) requires splitting logic into multiple disjointed items or handling it externally.Development Recommendation: Introduce a hierarchical mapping parameter, such as nested_choices() or an option to pass a relational data.frame into sf_choices(), allowing child items to automatically subscribe to parent item mutations.Implementation of Dynamic Text Evaluation and Value Piping
Current Limitation: Choice sets are bounded statically upon sframe instantiation.
The Issue: Values and labels cannot accept dynamic text tokens injected on the fly based on previous respondent input, such as piping a text response from q_brand_name directly into the text label of a subsequent choice set item.Development Recommendation: Allow choice set labels to accept string-interpolated expressions or tidyverse-style glue syntax that the survey engine evaluates reactively during runtime execution.Native Integration for Discrete Choice Experiments (DCE)
Current Limitation: The architecture assumes standard social science scale variants like Likert, binary, or nominal scales, and has no structural awareness of conjoint or alternative-specific designs.
The Issue: Researchers building fractional factorial matrices or trade-off attributes must rely entirely on external packages, breaking the core surveyframe philosophy of an all-in-one pre-declared analysis contract.Development Recommendation: Create a dedicated sf_conjoint_design() constructor that dynamically feeds randomized attribute profiles into specialized matrix items while maintaining proper data schema exports for downstream multinomial logit modeling.Handling Non-Linear Type Invariance and Missing Value Declarations
Current Limitation: Strict type alignment between choice sets and latent construct mappings causes analytical execution failures if non-interval values are present.The Issue: Mixing data types, such as using an arbitrary numeric flag like 99 for Prefer not to say or Don't Know inside a standard 1-to-5 integer Likert scale, corrupts automatic psychometric aggregation like Cronbach's alpha or CFA scoring unless stripped out manually.
Development Recommendation: Introduce an explicit missing_codes argument directly within sf_choices() or add_item(). This would allow developers to designate specific labels as metadata bypasses, instructing upstream statistical models to automatically handle or drop these inputs during analysis pipeline execution.
Read these recommendations carefully and decide whether to apply them in this release or note them down in future release. Check whether they are logical as per surverframe core idea and then decide carefully.

> **Response (Fable 5, 2026-07-10):** Assessed against the core idea (a
> pre-declared, immutable, integrity-hashed methodological contract) and
> recorded in roadmap.md; none lands in 0.3.3 because all four are new
> capability and this release is already feature-complete.
>
> 1. **`missing_codes` on `sf_choices()` — strongest fit, scheduled for
>    v0.4.** Declaring "99 = prefer not to say" inside the contract is
>    exactly what pre-declared analysis needs; today those codes silently
>    corrupt alpha/CFA scoring. Fits v0.4's small-sample and inference
>    theme.
> 2. **DCE / conjoint (`sf_conjoint_design()`) — good fit, scheduled for
>    v0.5.** A pre-declared design matrix feeding a pre-declared multinomial
>    model is squarely inside the contract philosophy, and v0.5 is already
>    the decision-methods release (MCDM and DEMATEL).
> 3. **Cascading choice sets — partial fit, design note for v0.6+.**
>    Hierarchies can be declared statically (a relational data frame is
>    still a fixed contract), so this is admissible, but it touches the
>    renderer, serialisation, hashing, and the builder at once and needs its
>    own design document first.
> 4. **Runtime piping/glue in labels — tension with the core idea.**
>    Reactive label evaluation makes the rendered instrument depend on
>    respondent state, which weakens the "one hashed instrument, one
>    experience" guarantee. Recorded as a research question (a restricted,
>    declarable token set like `{q_brand_name}` may be acceptable), not a
>    commitment.
---

## Part C — Theme B survey design (18 items)

The whole survey-taking experience was redesigned. Export the bundled demo
(or the AIC-RSAM fixture if working in surveyframe-dev) and review it as a
respondent would.

```r
demo <- sframe_input_types_demo_data()
export_static_survey(demo$instrument,
                     output_path=file.path(tempdir(),"themeb.html"),
                     open=TRUE, overwrite=TRUE)
```

### Desktop pass

- [x] C1 Welcome screen: serif title, intro text, tinted consent box, and a
  full-width start button in the theme colour. The branded header (dot +
  study name) shows above.
- [x] C2 Question text is serif and clearly larger than body text; help text
  is italic; the required marker is a small theme-coloured asterisk.
- [x] C3 Single-choice options are bordered cards with A/B/C key chips; the
  selected card shows a tinted background, a theme border, a filled chip,
  and a right-side tick.
- [x] C4 Multiple-choice cards behave the same and allow several selections.
- [x] C5 Likert items are numbered squares with small labels underneath; the
  selected square fills with the theme colour and its number turns white.
- [x] C6 Short text/number/date inputs are underline style; the underline
  turns the theme colour on focus. The textarea keeps a boxed style.
- [x] C7 Star rating: large stars, theme colour when active, subtle grow on
  hover.
- [x] C8 Slider, matrix, and ranking items still render and work (they kept
  their structure; check nothing looks broken next to the new blocks).
- [x] C9 Section breaks show the short theme-coloured rule above a serif
  heading with italic intro.
- [x] C10 The sticky top bar shows the progress line, a label, and the
  percentage; on a single-page survey the label counts answered questions
  ("N of M answered") and updates as you answer.

Feedback:
C1 - The dot is unnecessary. Anyway, the is displayed before the logo. Check and fix it.
The How many nights did you stay?* Enter the number of nights. numerical selection range is still accepting negative numbers. Anyway, check what are the sf_choices for the calendar field and the range field.
c8 - Needs improvement in design and theme. Apply the new design principles to it.
c10 - There is a em dash in the sticky top bar. Remove it.
The data export from feature_ranking should go in separate columns with numbering for further statistical analysis.

> **Response (Fable 5, 2026-07-10):** All five applied.
>
> * C1: the header dot is removed entirely.
> * Numeric bounds: numeric questions now honour `slider_min`/`slider_max`
>   as hard minimum and maximum (typed values are clamped), and the bundled
>   demo's nights question is bounded 0 to 365. Date questions have no
>   bound mechanism yet; that is recorded for the builder rework patch.
>   Numeric and date questions do not use `sf_choices` at all, which is why
>   no choice set appeared for them.
> * C8: matrix (horizontal rules, tinted header, hover rows), slider
>   (card container, large serif value), and ranking (option-card rows with
>   theme rank badges) are restyled to Theme B.
> * C10: the decorative dash line was the eyebrow's underline element; it is
>   removed, and standard mode no longer duplicates the page counter under
>   the sticky bar at all.
> * Ranking export: one column per option holding its rank
>   (`item__option = 1` is the top choice), across the survey payload, the
>   CSV, both collector generators, and `read_responses()`.
>
> Re-verify C1, C8, and C10 after reinstalling; ranking export is item B11
> below in spirit and covered by G-part table checks.
### Theme colour selector

```r
demo$instrument$render$theme <- "#7c3aed"   # any colour you like
export_static_survey(demo$instrument,
                     output_path=file.path(tempdir(),"themeb2.html"),
                     open=TRUE, overwrite=TRUE)
```

- [x] C11 Every accent re-tints from the one colour: header dot, progress
  bar, chips, selected cards, Likert fills, stars, buttons, focus states.
  No element kept the old colour.
- [x] C12 Repeat once more from the SurveyBuilder's Settings colour picker
  (launch_builder, change the theme colour, Export survey) and confirm the
  exported file matches the picked colour.

### Phone pass (real device if possible)

Serve the exported file (`python3 -m http.server` in its folder) and open it
on the phone, or use browser device mode at 390 x 844.

- [x] C13 No horizontal scrolling anywhere.
- [x] C14 Option cards and Likert squares are comfortably tappable with a
  thumb; no mis-taps on adjacent options.
- [x] C15 The on-screen keyboard does not permanently cover a focused text
  input (the browser scrolls it into view).
- [x] C16 A logo set in the header keeps a stable box: try one wide and one
  tall logo and confirm the study name does not jump horizontally.
- [x] C17 Conversational mode: set `render$mode <- "conversational"`,
  re-export, and confirm one question per page, a "Question X of Y"
  eyebrow, the study title in the sticky bar (no duplicated page counter),
  and working Back/Next.
- [ ] C18 Overall judgement: the survey looks like the approved Theme B
  mock, and you would be happy sending this to a respondent today.
c16 not tested so far
c17 not tested so far
c18 pending decision. Will be done in a separate mobile session. 
---

## Part D — SurveyBuilder fixes (10 items)

```r
surveyframe::launch_builder()
```

- [x] D1 Empty canvas offers "Open an existing .sframe" and "Set up survey
  settings first" links alongside "+ Add question".
- [] D2 Open a `.sframe` saved by R or by the builder: the toast reports
  "integrity verified (sha256 ...)" with the hash prefix. Loading a file
  edited by hand in a text editor reports an integrity mismatch instead.
- [x] D3 Select a Section item: the inspector labels its text field
  "Section header" (a Text block reads "Block text"); ordinary questions
  still read "Question text".
- [x] D4 Add a Multiple choice question, edit its choices to something
  distinctive, then add another Multiple choice question: the new one gets
  a fresh Option 1/2/3 set, never the previous question's choices.
- [x] D5 Edit the choices of a choice question that shares its set with
  another question: the other question's choices are untouched (the set
  forks).
- [x] D6 Analyse tab, Add Analysis Plan, Pearson correlation: pick the same
  variable for X and Y. The modal shows "The same variable cannot fill more
  than one role" and Save stays disabled until fixed.
- [x] D7 In the suggestion box, select one Likert item and one numeric item:
  the suggested test is Spearman correlation (never Mann-Whitney).
- [x] D8 Select a single-choice item with more than two categories plus a
  numeric outcome: the suggestion is Kruskal-Wallis; with a two-category
  grouping it stays Mann-Whitney.
- [x] D9 Known and accepted: the builder's own Preview tab still uses the
  old simplified rendering and lags Theme B. Confirm this is noted in
  dogfeed.todo.md and does not block submission (the Export survey output
  is the real design).
- [x] D10 Export survey and Generate collector still download files without
  errors after all the above.
Feedback: 
D1: The empty canvas is not up to the WCAG 2.2 standards in terms of size, positioning, buttons, colour and contrast. The Open an existing .sframe · Set up survey settings first - supposed to be the primary CTA buttons are worst in terms of positioning, background colour and font colour. Improve the  empty canvas, design, colour and layout.
D2: I tried to load a older version of the surveyframe. The old design template appeared. Tried to build a fresh one. Still the old template is there. The new design principles are not available. 
The Add Question button adds Agreement item 1 by default. The three dot drop down acts separately. Split them into four buttons. One dropdown for question selection. Another for branching, another for adding section break, and another for configuration. Read / review the popular survey builder saas like limesurvey, formbricks, and so on and then rework the dashboard to fit surveyframe
The surveyframe::launch_builder() needs a complete fable 5 review and proofing as UI and UX emgineer to revise it. 

> **Response (Fable 5, 2026-07-10):** Split per your decision: quick wins
> now, the rework as the next patch's headline.
>
> * D1 (done now): the empty canvas has real buttons at 44px minimum, a
>   filled primary CTA ("+ Add your first question") and two outlined
>   secondary CTAs (Open an existing .sframe / Set up survey settings),
>   with text contrast raised well past the old 22 to 35 percent white.
> * D2 (clarified as the Preview tab): known limitation D9. The Preview tab
>   still uses the builder's internal simplified renderer, so it shows the
>   old look regardless of the loaded file; Export survey and SurveyStudio
>   carry Theme B. The Preview restyle is part of the rework below.
> * The four-control split of Add Question, the LimeSurvey/Formbricks
>   benchmark pass, and the full launch_builder() UI/UX review are recorded
>   in roadmap.md as the builder-rework track of the next patch, alongside
>   the existing Design improvement arc items in dogfeed.todo.md.
---

## Part E — Model syntax fixes (7 items)

```r
con1 <- sf_construct("SAT", "Satisfaction", paste0("sat_", 1:3))
con2 <- sf_construct("LOY", "Loyalty", paste0("loy_", 1:3))
m <- sf_model("m1", "Labelled", type="cb_sem",
              constructs=list(con1, con2),
              paths=list(sf_path("SAT","LOY",
                                 "H1: SAT positively influences LOY")))
cat(sem_lavaan_syntax(m))
```

- [x] E1 The structural line reads `LOY ~ H1*SAT`. The free-text label was
  reduced to the `H1` tag; no spaces or colons appear in the parameter.
- [x] E2 `lavaan::lavaanify()` on the string parses without warnings about
  identifiers with spaces. Run it on the generated syntax string, never on
  the model object itself:

```r
lavaan::lavaanify(sem_lavaan_syntax(m))
```

Feedback: con1 <- sf_construct("SAT", "Satisfaction", paste0("sat_", 1:3))
con2 <- sf_construct("LOY", "Loyalty", paste0("loy_", 1:3))
m <- sf_model("m1", "Labelled", type="cb_sem",
              constructs=list(con1, con2),
              paths=list(sf_path("SAT","LOY",
                                 "H1: SAT positively influences LOY")))
cat(sem_lavaan_syntax(m))
lavaan::lavaanify(m)
Error: lavaan->lav_parse_tokens_formulas():  
   formula without valid operator 
   at line 1, pos 1
m1 
^

> **Response (Fable 5, 2026-07-10):** That error is expected: `lavaanify()`
> was given the `sf_model` object (`m`), so lavaan tried to parse the model
> id "m1" as syntax. The function takes the generated string:
> `lavaan::lavaanify(sem_lavaan_syntax(m))`. The checklist step above now
> shows the exact call. No package change needed; please re-run E2 with the
> corrected call.

```r
pls <- sf_model("p1", type="pls_sem",
  constructs=list(sf_construct("SAT","Satisfaction", paste0("sat_",1:3),
                               mode="composite"),
                  sf_construct("LOY","Loyalty","loy_1", mode="single_item")),
  paths=list(sf_path("SAT","LOY")))
cat(seminr_syntax(pls))
```

- [x] E3 The generated code includes `library(seminr)` after the
  check_installed line.
- [x] E4 The assessment tail uses `summary(pls_model)` accessors
  (`$reliability`, `$validity$htmt`, bootstrapped paths). The old
  `reliability()`/`ave()`/`htmt()` calls are gone.
- [x] E5 Copy-paste the whole generated block into a session with simulated
  data named `data`: it runs end to end without "could not find function".
- [x] E6 An analysis-plan block with `method = "pls_sem"` (the model-type
  spelling) runs through `run_analysis_plan()` and returns the seminr
  syntax rather than "Test 'pls_sem' is unavailable".
- [ ] E7 The Model Builder panel in the builder still exports the same
  syntax through its Export syntax button.

---

## Part F — Google Sheets collection (9 items)

The CORS fix is the single most field-critical change: 0.3.2's exported
survey silently failed to POST from any hosted page.

- [x] F1 Open a fresh exported survey's HTML source and find the submit
  fetch: it must use `mode:'no-cors'` and `Content-Type':'text/plain'`.
  There is no `application/json` header anywhere in the submit path.
- [x] F2 Generate a fresh collector (`export_google_sheet()` or the
  builder): EXPECTED_COLUMNS contains no `sec_*` section-break columns.
- [ ] F3 End-to-end spot check: deploy the fresh collector to a scratch
  Google Sheet, host the exported survey anywhere (GitHub Pages or
  `python3 -m http.server`), submit one response from the HOSTED page (not
  file://), and confirm the row lands in the sheet. This proves the CORS
  fix in the field.
- [ ] F4 `read_sheet_responses(sheet, instr)` returns that row with correct
  values.
- [ ] F5 `read_sheet_responses(..., meta_cols = c("extra1"))` accepts an
  extra sheet column without the undeclared-column warning.
- [ ] F6 SurveyStudio, Upload screen, Google Sheet card: the same sheet
  imports, the app switches to the Quality Dashboard, and the completion
  time card shows a median (not "No submitted_at column available").
- [x] F7 Live AIC-RSAM read-back (read-only): `read_sheet_responses()` on
  the live sheet returns the real responses cleanly. Do NOT submit test
  data to the live endpoint.
- [ ] F8 Decision recorded: whether to re-export and republish the live
  AIC-RSAM survey mid-collection to pick up the CORS fix and Theme B, or
  leave the hand-patched deployment as is until collection ends. Either
  answer is fine; it must be a decision, not an accident.
- [x] F9 The deploy kit now lives in
  AI_Room_service/surveyframe_Integration/deploy_kit and its README says
  so.

---

## Part G — Visualisation foundation (12 items)

```r
library(surveyframe)
demo <- sframe_demo_data()
res  <- run_analysis_plan(demo$responses, demo$instrument, plots = TRUE)
```

- [x] G1 `theme_surveyframe()` returns a theme; a quick
  `ggplot(mtcars, aes(wt, mpg)) + geom_point() + theme_surveyframe()`
  looks branded: ink text, quiet grids, bottom legend.
- [x] G2 A frequency block's `$plot` is a horizontal teal bar chart with no
  bar for missing values, titled "Distribution of <variable>".
- [x] G3 A chi-square/cross-tab block's `$plot` is a dodged bar chart whose
  series colours follow the fixed order (teal, amber, blue, pink, violet)
  with white gaps between bars and a bottom legend.
- [x] G4 A correlation block's `$plot` is a scatter with an ink regression
  line, a shaded confidence band, and the APA string as the subtitle.
- [x] G5 A regression block with one predictor shows predictor vs outcome;
  with several predictors it shows observed against fitted with a dashed
  identity line.
- [x] G6 Block types outside the family (for example a t-test) have
  `$plot = NULL` and no error.
- [x] G7 With `plots = FALSE` (the default) no block carries a plot.
- [x] G8 `$table` on a correlation block is a one-row data frame (Statistic,
  n, df, Estimate, p, Effect size); on a regression block it is the
  coefficient table; on a t-test block a two-row group summary. All print
  cleanly through `knitr::kable()`.
- [x] G9 Render `render_report()` on the demo data: the analysis sections
  show these tables and the plots-free sections are unchanged.
- [x] G10 Frequency and cross-tab runners on data containing empty strings
  produce no blank/unnamed category (check a `$table` from partially
  complete responses).
- [x] G11 Eyeball the four plot types at presentation zoom (150 percent):
  fonts legible, no clipped labels.
- [ ] G12 Optional (skip if impractical): in a session or library without
  ggplot2, `run_analysis_plan(..., plots = TRUE)` fails with the friendly
  check_installed prompt, and everything else works without ggplot2.

---

## Part H — Report checks (6 items)

Render a report from any instrument with an analysis plan including a
model-syntax block and a reliability block.

- [x] H1 A syntax-generating block (CFA/SEM/PLS-SEM) prints its full syntax
  in a monospaced code block under the RQ heading.
- [x] H2 A reliability block renders a compact per-scale alpha table
  instead of an empty "Result:" line.
- [x] H3 The reliability section's "Omega h" and "Omega total" headers do
  not wrap mid-word.
- [x] H4 View the report at 1280 x 720 (projector size): headings, tables,
  and plots are readable from presentation distance.
- [x] H5 The report references section still shows italic journal names
  (the citation markdown renders, no literal asterisks).
- [x] H6 The TOC navigates correctly to every section.

---

## Part I — Release safety (8 items)

Runs entirely from RStudio. The first block swaps the web-installed package
for the local development checkout so the rest tests exactly what will be
submitted (the full chunk sequence is in mas_review_033.qmd, Part I):

```r
pkg <- path.expand("~/Documents/GitHub/surveyframe-dev")
try(detach("package:surveyframe", unload = TRUE), silent = TRUE)
try(remove.packages("surveyframe"), silent = TRUE)
devtools::install(pkg, upgrade = FALSE, quick = TRUE)
library(surveyframe); packageVersion("surveyframe")

devtools::test(pkg)                          # I1: expect 519
tarball <- devtools::build(pkg)              # I2
devtools::check_built(tarball, cran = TRUE)  # I2
grep("mas_|dogfeed|roadmap|aic_rsam|CODE_OF|SECURITY",
     utils::untar(tarball, list = TRUE), value = TRUE)   # I3: character(0)
system2("git", c("-C", pkg, "describe", "--tags"), stdout = TRUE)  # I5
```

- [x] I1 Full suite passes; expect 519 in the dev checkout (the AIC-RSAM
  fixture tests run there) and a lower count from the CRAN tarball.
- [x] I2 `R CMD build .` then `R CMD check --as-cran` on the fresh tarball:
  0 errors, 0 warnings, at most the incoming-feasibility NOTE.
- [x] I3 The tarball contains no dev files: no mas_review files, no
  dogfeed/roadmap, no AIC-RSAM fixture or its tests, no jss remnants, no
  CODE_OF_CONDUCT.md or SECURITY.md
  (`tar -tzf surveyframe_0.3.3.tar.gz | less`).
- [x] I4 The vignette builds offline (`rmarkdown::render` or the check log's
  vignette section).
- [x] I5 `git describe --tags` on main says v0.3.3, and the tag commit
  includes the LICENSE fix (`git show v0.3.3 --stat | grep LICENSE`).
- [x] I6 Public and private remotes agree
  (`git ls-remote` both, compare main and the tag).
- [ ] I7 Win-builder R-release and R-devel both return Status OK (submit,
  wait for the emails).
- [ ] I8 `cran-comments.md` is updated with the local check and win-builder
  results and mentions this is a feature+fix release with no new hard
  dependencies (ggplot2 added to Suggests only).

---

## Part J — Fresh-eyes UX pass (4 items)

Thirty minutes as a first-time user, no checklist in hand.

- [ ] J1 Take a survey end to end on your phone as a respondent. Note
  anything that felt off in dogfeed.todo.md rather than fixing on the spot.
- [ ] J2 Build a five-question instrument in the builder from scratch,
  export, open the export. Anything confusing goes to dogfeed.todo.md.
- [ ] J3 Read the 0.3.3 NEWS entry once more as a stranger: would a user
  understand what changed and why it matters?
- [ ] J4 Confirm dogfeed.todo.md's "After this session" and deferred items
  still reflect reality after this review.

---

## Part K — Vignettes (6 items)

Added 2026-07-10: the 0.3.2 review's Part U (vignettes) was not revisited
for 0.3.3, and this release changed the survey design, the report, and the
collection path that the vignettes describe.

```r
browseVignettes("surveyframe")   # restart R first if this shows nothing
```

- [x] K1 All vignettes list and open from `browseVignettes()` after a fresh
  install (restart R if the list is empty; known session-staleness effect).
- [x] K2 The lead vignette (`surveyframe.Rmd`) knits cleanly from source
  with the installed 0.3.3.
- [ ] K3 Read the lead vignette end to end: no prose or screenshot
  contradicts the Theme B survey design, and analysis output claims match
  what 0.3.3 actually prints (including the new `$table` output).
- [x] K4 The deployment vignette's Google Sheets instructions match the
  0.3.3 collector: no manual CORS patching mentioned or needed, and no
  reference to section-break columns.
- [ ] K5 Decide and record: should the lead vignette gain a short
  `plots = TRUE` example now, or in the 0.3.4 breadth patch? Either way,
  log the decision in dogfeed.todo.md.
- [x] K6 No vignette prose violates the writing rules (em-dashes,
  semicolons, banned words).

---

## Part L — Shiny renderer and dashboard (4 items)

Added 2026-07-10: Theme B restyled the static HTML export only. The Shiny
survey module (`render_survey()` / `survey_module_ui()`) has its own
renderer, and the dashboard has its own charts; neither was touched in
0.3.3.

```r
demo <- sframe_demo_data()
render_survey(demo$instrument)       # Shiny renderer
launch_dashboard()                   # bundled demo dashboard
```

- [ ] L1 The Shiny renderer still works for every item type (it predates
  Theme B; confirm nothing broke even though it looks different).
- [x] L2 Record the known divergence: the Shiny renderer does not carry the
  Theme B design. Confirm it is logged (dogfeed.todo.md / roadmap builder
  rework track) with a decision on when it converges.
- [ ] L3 `launch_dashboard()` panels all render with the bundled demo, and
  the Items panel copes with a ranking item's data.
- [ ] L4 SurveyStudio end to end with the bundled sample (load sample
  button): preview, upload, quality, reliability, analysis plan, export
  screens all function after the 0.3.3 changes.

---

## Part M — Response pipeline round trip (4 items)

Added 2026-07-10: the ranking export change altered the data shape, and the
0.3.2 review's pipeline parts (J to M) assumed the old single-column form.

```r
demo <- sframe_input_types_demo_data()
resp <- read_responses(demo$responses_path, demo$instrument,
                       respondent_id = "respondent_id",
                       submitted_at  = "submitted_at",
                       meta_cols     = "started_at")
```

- [x] M1 The bundled demo responses (legacy single ranking column) still
  read without errors: backwards compatibility holds.
- [x] M2 A fresh CSV downloaded from the 0.3.3 exported survey (with
  `item__option` ranking columns) reads back through `read_responses()`
  with no missing-column or undeclared-column warnings.
- [x] M3 `quality_report()` and `score_scales()` run on the fresh CSV;
  ranking columns pass through untouched (they belong to no scale).
  `reliability_report()` needs several respondents, so run it on the
  bundled legacy responses from M1 instead (a single fresh submission
  correctly fails with "'x' is empty").
- [x] M4 The codebook and full report render from the fresh data; ranking
  columns appear sensibly (one row per option column).

---

## Sign-off

Counts: Parts A-M, 104 checklist items (88 original, B9-B10 added with the
Part B rework, K1-K6, L1-L4, and M1-M4 added 2026-07-10 from the 0.3.2
review's uncovered areas).

**Reviewed by:**  
**Date signed off:**  
**All steps complete:**  
**Notes for the developer (if any):**

Once signed off, paste the following prompt into Claude Code to proceed:

```text
Read CLAUDE.md and mas_review_033.md. The MAS review of 0.3.3 is complete
and signed off. Rebuild the tarball if anything changed, confirm
R CMD check --as-cran is 0 errors, 0 warnings, at most 1 NOTE, update
cran-comments.md with the local and win-builder results, and give me the
text to paste on the CRAN submission form.
```
