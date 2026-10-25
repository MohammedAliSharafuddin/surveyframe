# Building a survey instrument: questions, plan, and model

An `sframe` instrument records the research design, not only the
questions. This vignette builds a slice of the published Thailand
digital marketing study (Sharafuddin, Madhavan, and Wangtueai 2024) with
the constructors shown one at a time, then adds the analysis plan and a
measurement model. The full study is assembled in the worked-study
vignette.

## Choice sets

Choice sets define reusable response options. Items reference them
through `choice_set`.

``` r

likert5 <- sf_choices(
  "likert5",
  values = 1:5,
  labels = c("Strongly disagree", "Disagree",
             "Neither agree nor disagree", "Agree", "Strongly agree")
)

visitor <- sf_choices("visitor", c("first_time", "repeat"),
                      c("First-time visitor", "Repeat visitor"))
```

## Items and item types

Items are response variables unless their type is `section_break` or
`text_block`. Required items carry `required = TRUE`. Item IDs should
stay stable, because response columns reuse them and the analysis plan
refers to them. These items measure perceived value (DMPV) and tourist
satisfaction (TS).

``` r

intro <- sf_item(
  "intro", "About your trip",
  type          = "section_break",
  section_intro = "Please rate your experience of digital booking and your visit."
)

dmpv_1 <- sf_item("dmpv_1", "The destination's online content was trustworthy.",
  type = "likert", required = TRUE, choice_set = "likert5", scale_id = "DMPV")
dmpv_2 <- sf_item("dmpv_2", "The online information was consistent across platforms.",
  type = "likert", required = TRUE, choice_set = "likert5", scale_id = "DMPV")
dmpv_3 <- sf_item("dmpv_3", "The digital channels offered good value for money.",
  type = "likert", required = TRUE, choice_set = "likert5", scale_id = "DMPV")
dmpv_4 <- sf_item("dmpv_4", "I was aware of the destination through digital channels.",
  type = "likert", required = TRUE, choice_set = "likert5", scale_id = "DMPV")

ts_1 <- sf_item("ts_1", "The trip met my expectations.",
  type = "likert", required = TRUE, choice_set = "likert5", scale_id = "TS")
ts_2 <- sf_item("ts_2", "My overall travel experience was satisfying.",
  type = "likert", required = TRUE, choice_set = "likert5", scale_id = "TS")
ts_3 <- sf_item("ts_3", "I felt comfortable at the destination.",
  type = "likert", required = TRUE, choice_set = "likert5", scale_id = "TS")

visitor_type <- sf_item("visitor_type", "I am a",
  type = "single_choice", required = TRUE, choice_set = "visitor")

repeat_change <- sf_item(
  "repeat_change", "What changed most since your previous visit?",
  type = "textarea", required = FALSE
)

attention <- sf_item("attention", "For quality control, please select Agree.",
  type = "single_choice", required = TRUE, choice_set = "likert5")
```

## Scales, reverse coding, and minimum valid items

A scale records item membership, the scoring method, any reverse-coded
items, and the minimum number of valid items needed to compute a score.

``` r

dmpv <- sf_scale("DMPV", "Digital marketing perceived value",
  items = c("dmpv_1", "dmpv_2", "dmpv_3", "dmpv_4"), method = "mean", min_valid = 3)

ts <- sf_scale("TS", "Tourist satisfaction",
  items = c("ts_1", "ts_2", "ts_3"), method = "mean", min_valid = 2)
```

## Attention checks

Checks keep the quality-control logic with the instrument.

``` r

attention_check <- sf_check(
  id = "attention_agree", item_id = "attention", type = "attention",
  pass_values = 4, fail_action = "flag", label = "Instructional attention check"
)
```

## Branching

A branch shows or hides an item based on an earlier answer. Branch a
dedicated follow-up, not an item from a shared scale, or groups may
receive different versions of the scale being compared.

``` r

repeat_branch <- sf_branch(
  item_id    = "repeat_change",
  depends_on = "visitor_type",
  operator   = "==",
  value      = "repeat",
  action     = "show"
)
```

## The analysis plan

Each block binds a research question to a technique and to the variables
that fill each role. A reliability check expects `items`. A group
comparison expects a `group` and an `outcome`.

``` r

analysis_plan <- list(
  list(id = "M1", research_question = "Is perceived value internally consistent?",
       family = "measurement", method = "reliability_alpha",
       roles = list(items = c("dmpv_1", "dmpv_2", "dmpv_3", "dmpv_4"))),
  list(id = "RQ1", research_question = "Do repeat visitors report higher satisfaction?",
       family = "group_comparison", method = "mann_whitney",
       roles = list(group = "visitor_type", outcome = "TS"),
       options = list(alpha = 0.05))
)
```

## Assemble the instrument

[`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md)
takes the questions through `components` and the research design through
`analysis_plan` and `models`. The model is added with
[`add_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/add_model.md),
which checks each indicator against the instrument items.

``` r

instr <- sf_instrument(
  title       = "Digital marketing study (teaching slice)",
  version     = "1.0.0",
  description = "A slice of the published Thailand study for teaching the constructors.",
  authors     = "Research team",
  languages   = "en",
  components  = list(
    likert5, visitor,
    intro, dmpv_1, dmpv_2, dmpv_3, dmpv_4, ts_1, ts_2, ts_3,
    visitor_type, repeat_change, attention, dmpv, ts, attention_check,
    repeat_branch
  ),
  analysis_plan = analysis_plan
)

ts_model <- sf_model(
  id    = "ts_cfa",
  label = "Satisfaction measurement model",
  type  = "cfa",
  constructs = list(
    sf_construct("DMPV", "Perceived value", c("dmpv_1", "dmpv_2", "dmpv_3", "dmpv_4")),
    sf_construct("TS",   "Tourist satisfaction", c("ts_1", "ts_2", "ts_3"))
  )
)

instr <- add_model(instr, ts_model)
```

## Validate the instrument

[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
returns a diagnostic. Print it to read the result, and use the accessors
to get at the parts.

``` r

validate_sframe(instr, strict = FALSE)
#> <sframe validation>
#>   Instrument:  Digital marketing study (teaching slice) (1.0.0)
#>   Status:      valid
#>   Checks:      29 run, 0 with problems
```

``` r

validation <- validate_sframe(instr, strict = FALSE)
sf_is_valid(validation)
#> [1] TRUE
sf_problems(validation)
#> character(0)
```

In production, strict validation stops with a structured error when
anything is wrong. When it passes,
[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md)
recovers the instrument with its validated stamp set.

``` r

instr <- as_sframe(validate_sframe(instr))
sf_meta(instr)$validated
#> [1] TRUE
```

## Cite the sources the instrument draws on

An instrument rests on published work: the source of each scale, and the
method behind each plan block.
[`sf_reference()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_reference.md)
records a work as CSL-JSON, the format Zotero, Mendeley and pandoc
share, and `cited_by` says where the instrument cites it: `"instrument"`
as a whole, or `"item:<id>"`, `"scale:<id>"`, `"plan:<block id>"` or
`"model:<id>"`.

``` r

cronbach <- sf_reference(
  id = "cronbach_1951",
  title = "Coefficient alpha and the internal structure of tests",
  author = "Cronbach, L. J.", year = 1951,
  container = "Psychometrika", volume = "16", issue = "3", pages = "297-334",
  cited_by = "plan:M1"
)
```

A reference copied from Google Scholar, Zotero or a journal page arrives
as BibTeX, and
[`read_bibtex()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_bibtex.md)
reads it with base R alone.

``` r

likert <- read_bibtex(text = "@article{likert_1932,
  author  = {Likert, Rensis},
  title   = {A technique for the measurement of attitudes},
  journal = {Archives of Psychology},
  year    = {1932}, volume = {22}, number = {140}, pages = {1--55}
}", cited_by = "instrument")

instr <- add_references(instr, cronbach, likert)
names(sframe_references(instr))
#> [1] "cronbach_1951" "likert_1932"
names(sframe_references(instr, cited_by = "plan:M1"))
#> [1] "cronbach_1951"
```

[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
checks that every key is unique and that each `cited_by` target exists.
The references travel inside the `.sframe` file. Citing a source is
disclosure, outside the design, so the content hash that
[`amend_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amend_sframe.md)
records leaves `references` out, and a source can be added to a
published instrument directly.

[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
cites each work in text, as author and year, and lists every work once,
in a References section at the end. That list holds the instrument’s own
references and the references of every method the plan ran, formatted by
pandoc in APA 7th edition, which ships with the package, or in any
Citation Style Language file given as `csl =`. A written interpretation
can cite a work as `[@key]`, and `references =` adds works cited there.
[`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md)
lists its references once at the end in the same way. In SurveyBuilder,
the References tab of Survey settings takes pasted BibTeX or a typed
reference, and SurveyStudio has a References screen that does the same.

## Write and read `.sframe` files

The `.sframe` file is the portable instrument file. It keeps the
validated metadata, the analysis plan, and the model in one place.

``` r

path <- tempfile(fileext = ".sframe")
write_sframe(instr, path, overwrite = TRUE)

loaded <- read_sframe(path)
inherits(loaded, "sframe")
#> [1] TRUE
sf_meta(loaded)$title
#> [1] "Digital marketing study (teaching slice)"
length(sf_plan(loaded))
#> [1] 2
length(loaded$models)
#> [1] 1
length(sframe_references(loaded))
#> [1] 2
```

## GUI option

The same instrument, plan, and model can be authored in SurveyBuilder,
which saves a `.sframe` file for use in R.

``` r

launch_builder()
launch_builder_demo(open = FALSE)
```
