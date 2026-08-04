# Handover: the 0.4.0 review suite

Started 2026-08-02, finished 2026-08-04. **The suite is complete.** All 19
numbered files plus `00_start_here.qmd` are written and render with 0 errors,
0 DIFFERS, and 0 CHECK.

Sections 1 and 2 are what a reader needs now. Sections 3 to 6 are the
reference material that cost real tokens to derive, kept because the next
person to touch these files will need it. Do not re-derive it.

---

## 1. What exists

| File | Covers | Comparisons |
|---|---|---|
| `00_start_here.qmd` | index, how to read a verdict, environment check | 3 |
| `01_first_workflow.qmd` | the whole package in one sitting | 17 |
| `02_field_types.qmd` | one demo per collecting item type, 13 of them | 64 |
| `03_descriptives.qmd` | frequency, descriptives, missingness, quality, outliers | 60 |
| `04_categorical.qmd` | chi-square, Fisher, McNemar, Cochran Q | 23 |
| `05_two_group.qmd` | t, Mann-Whitney, paired t, Wilcoxon | 28 |
| `06_multi_group.qmd` | ANOVA, Kruskal, two-way, ANCOVA, repeated, Friedman | 30 |
| `07_correlation.qmd` | Pearson, Spearman, Kendall, partial | 16 |
| `08_regression.qmd` | linear, logistic, ordinal, multinomial, Firth | 32 |
| `09_psychometrics.qmd` | alpha, omega, item diagnostics, EFA, validity | 23 |
| `10_model_syntax.qmd` | CFA, CB-SEM, PLS-SEM, the model-type guard | 50 |
| `11_mediation_moderation.qmd` | indirect effects and interactions | 38 |
| `12_small_sample.qmd` | the whole small-sample track | 19 |
| `13_mcdm.qmd` | all 10 MCDM methods | 17 |
| `15_sensitivity_conjoint.qmd` | weight sensitivity, conjoint designs | 57 |
| `16_collection_routes.qmd` | static, Shiny, Sheets, branching, the hash | 46 |
| `17_reporting.qmd` | reports, codebook, PDF, interpretations | 46 |
| `18_guis.qmd` | the 3 GUIs, mostly click paths | 23 |
| `19_rstudio_addin.qmd` | task **H2**, release blocker | 0 here, 12 on the add-in branch |
| `20_release_safety.qmd` | pre-flight, `R CMD check`, owner decisions | 22 |

566 checked numbers across the 16 automated statistical files, plus 48 in
`00`, `18`, and `20`. There is no file `14`: the numbering left room for a
second decision-analysis file that `13` and `15` between them made
unnecessary.

`_setup.R` holds every shared helper. Read it once. Do not duplicate its
helpers inside a `.qmd`.

### Running against an installed build rather than the worktree

`remotes::install_github("MohammedAliSharafuddin/surveyframe", build_vignettes = TRUE)`
installs `main`, which carries the whole 0.4.0 release plus the add-in.
`_setup.R` only falls back to `devtools::load_all("../surveyframe-v0.5-dev")`
when no 0.4.0 build is already loaded, so **installing silently switches
which build the suite reviews**. That is usually what you want, since it is
the tarball-shaped thing.

Two caveats.

- Four reference packages the suite uses are not in Suggests and need
  installing separately: `DescTools`, `car`, `e1071`, `seminr`.
- **Files `19` and `20` read the source tree and cannot fully run against an
  installed package.** Installation drops `.Rbuildignore`, compiles `R/*.R`
  into a lazy-load database, strips the `inst/` prefix so
  `inst/rstudio/addins.dcf` becomes `rstudio/addins.dcf`, and renames
  `vignettes/` to `doc/`. File `19` detects this and skips cleanly. File `20`
  does not, and would error reading `.Rbuildignore`. Run those 2 from a
  source checkout of `main`.

### What is left for the owner, not for a model

1. **H2.** File `19` section 4, at a keyboard in RStudio. Release blocker.
2. **File `18`** sections 4 to 7, in a browser.
3. **File `20`** section 6, `R CMD check --as-cran` after the E1 version bump,
   and sections 7 and 8, the decisions.
4. **D6**, the MCDM preprint DOI for `inst/CITATION`. The other hard blocker.

---

## 2. The 8 findings

All in `dogfeed.todo.md` with evidence and a suggested fix. None is fixed:
that is the dogfeed protocol. File `20` section 7 is where decisions get
recorded.

| # | Finding | Lane | File |
|---|---|---|---|
| 1 | `item_report()` ignores `reverse = TRUE` | 0.4.0 | `09` |
| 2 | Correlation roles: `variables` works for Kendall only | 0.4.0 | `07` |
| 3 | `assumption_report()` reports checks that never ran | 0.4.1 | `05` |
| 4 | Display-only items get a Shiny column, and it counts as missing | 0.4.0 | `02`, `16` |
| 5 | `sem_lavaan_syntax()` writes an indirect effect lavaan cannot parse | 0.4.0 | `10` |
| 6 | Conjoint `"balanced"` is rewarded for dropping a level | 0.4.0 | `15` |
| 7 | `render_results(citation_format = )` is validated then ignored | 0.4.0 | `17` |
| 8 | `codebook_report()` omits the item help text | 0.4.1 | `17` |

Findings 1 to 3 came from the first sitting, 4 to 8 from the second. Four of
the last 5 have the same shape as B11 and B13 before them: **software
returning something plausible instead of saying it has no answer.** Where a
result looks clean, ask whether it is clean or merely quiet.

**5 and 6 are the ones to take first.** 5 is a hard error in the single case
a `cb_sem` model is most often declared for. 6 cannot be repaired after
collection, because a fielded design with an unseen level is partly
inestimable, and `"balanced"` is measurably worse than `"random"` at
avoiding it.

### Two ways this suite was wrong about itself

Both produced a confident `match` that meant nothing. Both are fixed, and
both are worth remembering.

1. **A field that does not exist compares equal to itself.** File `13`'s
   hash gate read `hotel$integrity$hash` twice. There is no `$integrity`
   element on an `sframe`, so it compared `NULL` to `NULL`, which passes
   whatever the package does. The hash lives in the `.sframe` file's JSON and
   `read_sframe()` verifies it on the way in. `13` and `16` now read the
   stored value and carry a mutation check. The integrity mechanism itself is
   sound, and `validate = FALSE` does not bypass it.
2. **A mismatched reference looks exactly like a defect.** An apparent ninth
   finding, that `descriptives_report()` used a non-standard skewness
   denominator, was wrong. surveyframe reports the b1 and b2 estimators,
   which is `psych`'s **default** and `e1071`'s type 3. Comparing against
   `psych::skew(type = 1)` gives a gap of exactly `((n-1)/n)^1.5`.

**The rule both point at: every new claim needs a mutation check.** Revert
the thing being tested and confirm the test fails. A check that cannot fail
is not a check. Every finding above was established that way.

---

## 3. The file template

Every file follows the same 5-part shape. Copy `05_two_group.qmd`, which is
the cleanest example.

1. **Questionnaire.** Build a small instrument with `sf_instrument()`. Never
   load a fixture unless the fixture is the point (only `13` does).
2. **Analysis plan.** Declare the research questions inside the instrument,
   before any data exists. Every file must exercise this.
3. **Both collection routes.** One chunk: `sf_both_routes(instrument, answers, n)`.
4. **Dummy data.** Simulate with a real effect built in, so the tests have
   something to find. Always `set.seed()`.
5. **Accuracy, one section per method.** Each section ends with
   `compare_report(tab, caption = ...)` then `sf_log(tab)`, then a plot, then
   markdown checkboxes.

Close every file with `sf_verdict()`.

YAML header, copy verbatim from any existing file. `error: true` matters: a
chunk that fails must show its error rather than stopping the render.

### Recording a defect without a false `DIFFERS`

`DIFFERS` means "stop and investigate". A known, logged defect is already
investigated, so it must not read `DIFFERS`. The pattern used throughout:
write the row so it asserts **the defect as it stands**, and say so.

```r
compare_row("balanced drops a level on most seeds",
            as.numeric(rates[["balanced"]] > 0.5), 1,
            "DEFECT, 30 seeds")
```

Then a checkbox saying the row reading `match` means the defect is present,
and a flip to `DIFFERS` is the signal to rewrite the section. Files `02`,
`10`, `15`, `16`, and `17` all do this.

### Helpers in `_setup.R`

| Helper | Use |
|---|---|
| `compare_row(quantity, sf_value, ref_value, source, tol = 1e-6)` | one comparison |
| `compare_table(...)` | stack rows |
| `compare_report(tab, caption)` | print the table and the plot |
| `sf_log(tab)` | add to the file's running verdict |
| `sf_verdict()` | the closing summary line |
| `sf_both_routes(inst, answers, n)` | HTML plus Shiny in one table |
| `sf_html_route(inst)` | export and check, path in `attr(x, "path")` |
| `sf_shiny_widgets(inst)` | build every widget as an R object |
| `sf_shiny_roundtrip(inst, answers, n)` | drive the real collector, read back |
| `sf_answer_template(inst)` | what to name the `answers` list elements |
| `sf_columns(inst)` | the full column contract |
| `sf_fixture(name)` | path to a bundled file |

---

## 4. Saving tokens

**Use the Write tool, never a shell heredoc, to edit a `.qmd`.** Editing
through `python3 - <<'PY'` or `sed` makes the harness detect an external
modification and echo the **entire file** back into context. On a 400-line
`.qmd` that is thousands of tokens per edit.

**Probe field names in one batch before writing, not through render cycles.**
A render takes 40 to 90 seconds and its failure output is long. One
`Rscript -e` that prints `names()` for 20 result objects costs less than 2
failed renders. Section 5 is the output of exactly that.

**`cd` into `review_040` in every Bash call.** The working directory resets
between calls, and `quarto render` fails with "No valid input files" rather
than anything informative.

**Trim every R and render output.**

```bash
cd .../review_040 && timeout 900 quarto render FILE.qmd --to html 2>&1 | tail -3
Rscript -e '...' 2>&1 | grep -v "^Loading\|^ℹ" | tail -20
```

**Check a render with a one-line grep, not by reading the HTML.** The
rendered files are 1.5 to 2 MB each.

```bash
python3 -c "
import re,html
t=re.sub(r'<[^>]+>',' ',open('FILE.html',encoding='utf-8').read())
t=re.sub(r'\s+',' ',html.unescape(t)); i=t.find(' comparisons:'); print(t[i-4:i+400])
for e in sorted(set(re.findall(r'Error in [^<]{0,120}|Error: [^<]{0,120}',t)))[:6]: print('ERR:',e)"
```

Read the `ERR:` lines even when the verdict says 0 DIFFERS. **A chunk that
errors never logs its comparisons**, so an errored section is invisible in
the verdict line. That happened once in `10` and the verdict read
"43 match, 0 DIFFERS" with a whole section dead.

**Do not re-read a file after editing it.** The tools error if an edit fails.

**Do not render the whole suite to check one file.** Render only what changed.

**The rendered `.html` files are gitignored.** Do not add them.

### Which model for which file

The house rule is a 3-tier Haiku, Sonnet, Opus split.

- **Haiku** for template-following work with no adjudication.
- **Sonnet** where the right reference needs moderate judgement.
- **Opus** for anything where a comparison reads `DIFFERS` and somebody has
  to decide whether the package is wrong or the reference call is. That
  judgement is where this work's value was. Across both sittings, 9 apparent
  defects turned out to be mismatched reference calls and 8 were real.

A cheaper model should escalate rather than guess when a `DIFFERS` appears. A
loosened tolerance with no stated reason is the failure mode to avoid,
because it hides a real difference and looks like a pass.

---

## 5. Verified result field names

Derived by running each runner directly. **Use these rather than `$` partial
matching.**

| Method | Fields |
|---|---|
| `frequency` | `test variable weights n table weighted_table apa prompt`; `table` columns `Value Frequency Percent` |
| `descriptives` | `method variables split_by weights table apa prompt`; `table` columns `variable group n valid_n missing_n mean sd median iqr min max skewness kurtosis se ci_low ci_high weighted_mean` |
| `missing_data` | `method item_missing respondent_missing patterns deletion scale_missing_rules mcar apa prompt` |
| `quality` | `summary attention timing straightline missing duplicates` |
| `t_test_ind` | `t df p d d_ci mean1 mean2 sd1 sd2 n1 n2 groups effect_label apa` |
| `t_test_pair` | `t df p d_z d_ci n mean_x mean_y mean_diff sd_diff` |
| `mann_whitney` | `U z p r r_ci hl_shift hl_conf_int median1 median2 n1 n2` |
| `wilcoxon_pair` | `V z p r r_ci pseudomedian pseudomedian_conf_int median_x median_y n` |
| `anova_one` | `F_stat df1 df2 p eta2 eta_ci group_means tukey n k` |
| `kruskal_wallis` | `H df p eta2 eta_ci` |
| `anova_two` | `table` only, columns `effect df sum_sq mean_sq F p partial_eta_sq` |
| `ancova` | `table` only, columns `effect Df "Sum Sq" "Mean Sq" "F value" "Pr(>F)"`, plus `slope_warning` |
| `repeated_anova` | `F_stat df1 df2 p eta2 n table fit_summary` |
| `friedman` | `statistic df p n` |
| `crosstab`, `chi_square` | `chi_sq df p cramer_v v_ci phi n table expected effect effect_label` |
| `fisher_exact` | `p odds_ratio odds_ratio_conf_int n table effect` |
| `mcnemar` | `statistic df p table` |
| `cochran_q` | `Q df p n` |
| `correlation_*` | `r df p ci n method`, where `ci` is named `c(estimate, lower, upper)` |
| `partial_correlation` | `r p n controls`, **no `ci`** |
| `regression_linear` | `r2 adj_r2 F df1 df2 p n coefficients diagnostics` (note `F`, not `F_stat`) |
| `regression_logistic_binary` | `mcFadden_r2 chi_sq chi_df chi_p n coefficients classification_table` |
| `regression_logistic_ordinal` | `coefficients AIC pseudo_r2 n` |
| `regression_logistic_multinomial` | `coefficients odds_ratios AIC pseudo_r2 classification_table n` |
| `firth_logistic` | `coefficients conf_int p_values likelihood_ratio conf_level n` |
| `mediation` | `test vars n direct indirect total a_path b_path indirect_ci bootstrap apa prompt` |
| `moderation` | `test vars n coefficients conditional_effects interaction_plot_data apa prompt` |
| `cfa_lavaan_syntax`, `sem_lavaan_syntax`, `seminr_syntax` | `test syntax apa prompt` |
| MCDM ranking methods | `scores ranks alternatives criteria criteria_types weights table ideal anti_ideal separation_positive separation_negative` |
| `ahp` | `weights criteria cr lambda_max consistency_warning table` |
| `dematel` | `criteria D R prominence relation role threshold total_relation normalised` |
| `sensitivity_analysis()` | `table method delta base_ranks alternatives criteria stable degenerate n_changed n_top_changed`; `table` columns `criterion direction weight rho rank_changed top_changed` |
| `sf_conjoint_design()` | `id label attributes method seed blocks n_alternatives n_tasks profiles tasks balance` |

### Coefficient matrix column names

```
lm       : Estimate, "Std. Error", "t value", "Pr(>|t|)"
glm      : Estimate, "Std. Error", "z value", "Pr(>|z|)", odds_ratio, or_ci_low, or_ci_high
polr     : Value, "Std. Error", "t value", odds_ratio, or_ci_low, or_ci_high
logistf  : Estimate, ci_low, ci_high, p, odds_ratio, or_ci_low, or_ci_high
```

### Report objects

```
reliability_report(d, i)$<scale_id>   : scale_id label n_items n alpha alpha_std omega_h omega_t
item_report(d, i)$<scale_id>$diagnostics : item_id mean sd item_rest_r floor_pct ceiling_pct n_missing
efa_report(d, i)   : kmo bartlett parallel suggested_nfactors rotation_note n_items n
                     kmo$MSA, kmo$MSAi, bartlett$chisq, bartlett$df, bartlett$p.value
efa_solution(...)  : loadings (has an item_id column!), loadings_long (item_id factor loading),
                     communalities (named numeric), variance_table, item_flags, rotation
assumption_report(): normality (variable n shapiro_w shapiro_p skewness kurtosis),
                     homogeneity (variable test F p; test is "Levene" or "Brown-Forsythe"),
                     advisory, apa
outlier_report()   : method variables table flagged_rows prompt
                     table columns: row variable value statistic threshold flagged
```

### Signatures worth knowing

```r
sample_size_plan(type = c("proportion","mean","correlation","t_test","anova",
                          "regression","sem"), margin_error, sd, p, r, alpha,
                 power, groups, predictors)     # no `n`, no `method`
assumption_report(data, variables, group, outcome, predictors, table_vars)
                                                 # everything keys off `variables`
export_static_survey(instrument, output_path, open, endpoint_url, overwrite)
export_google_sheet(instrument, sheet_url, output_dir)
render_survey(instrument, mode = "shiny", ...)   # returns a shiny.appobj, not UI
render_report(instrument, data, output_file, output_path, format,
              include_*, plot_palette, interpretations)
render_results(results, instrument, output_file, output_path,
               citation_format, title, interpretations)
codebook_report(instrument, format = c("html", "md"))
validity_report(loadings, construct_scores, items_by_construct)
                                                 # loadings needs `construct` and `loading`
sensitivity_analysis(x, weights, criteria_types, method, delta, alternatives, criteria)
sf_conjoint_design(id, attributes, method, n_profiles, n_alternatives, n_tasks,
                   blocks, seed, profiles, label)
sf_model(id, label, type, engine, constructs, paths, covariances, indirect, options)
sf_path(from, to, label = NULL)                  # ALWAYS pass label, see finding 5
sf_branch(item_id, depends_on, operator, value, action)
```

### MCDM internals used in files 13 and 15

```r
sframe_assemble_pairwise(data, instrument, item_id)  # $matrices $items $scale
sframe_aggregate_judgements(matrices)                # $matrix $consistency
sframe_principal_eigen(m)                            # $weights $lambda_max  (a list)
sframe_consistency_ratio(m)                          # numeric
sframe_rated_matrix(data, instrument, items)         # $matrix $alternatives $criteria
sframe_collected_weights(data, instrument, item_id)  # $weights
```

`result$matrix_source` is a **label** such as `"collected"`, not a matrix.
Rebuild the matrix with `sframe_rated_matrix()`.

---

## 6. Reference-call traps

Every one produced a `DIFFERS` that was the comparison's fault, not the
package's. Check this list before investigating any new one.

| Trap | Correct reference call |
|---|---|
| `psych::skew()` and `kurtosi()` default to **type 3**, which is what surveyframe reports | pass no `type`, or `type = 3`. `type = 1` differs by exactly `((n-1)/n)^1.5` |
| `wilcox.test()` picks the exact method at small n | surveyframe fixes `exact = FALSE`, so pass it |
| `car::leveneTest()` centres on the median by default | that is the **Brown-Forsythe** row, not the Levene row. Use `center = mean` for Levene |
| `mcnemar.test()` corrects by default, and so does surveyframe | pass nothing. `correct = FALSE` on one side only gives 45.02 against 47 |
| `jmv::ttestIS()` orders groups the other way | compare magnitudes, then assert the signs are opposite |
| `jmv` column names are suffixed | `stat[welc]`, `df[welc]`, `p[welc]`, `es[welc]`, `value[chiSq]`, `p[chiSq]`, `v[cra]` |
| `jmv::corrMatrix()` returns a character matrix | `as.numeric(jm[["sleep[r]"]][2])`, the off-diagonal cell |
| `psych::alpha()` rekeys items on its own | always `check.keys = FALSE`, and reverse the declared items yourself |
| `psych::omega()` is not bit-stable | tolerance `1e-3`, with the reason stated in the chunk |
| EFA factor order and sign are arbitrary | compare **communalities**, which are invariant to both |
| `RMCDA:::find.weight()` returns a 2-element list | `[[2]]` is the weights. It also approximates the eigenvector differently, so cross-check AHP on a **consistent** matrix with a known answer |
| `RMCDA::apply.WASPAS()` breaks with more than 1 beneficial criterion | check WASPAS against its own definition instead |
| `fisher.test()` reports the conditional MLE odds ratio | it is not `(a*d)/(b*c)`. Show both |
| `read_responses()` rejects collector timestamps | `meta_cols = c("started_at", "submitted_at")` |
| `read.csv()` rewrites headers | `check.names = FALSE` on any expansion-column file |
| Matrix Shiny inputs are **positional** | `svc__1`, `svc__2`, while the output columns are `svc__North`. Use `sf_answer_template()` |
| `validate_sframe()` aborts on failure | wrap in `tryCatch()`. It returns `$problems` only when it returns at all |
| Result tables speak **labels**, not codes | `frequency$table$Value` is `"Yes"`, not `"yes"`; `descriptives$table$variable` is the item **label**. Indexing by id returns an empty row and a table of `CHECK` |
| Rated-matrix criteria are named after **items** | `rate_service`, while `sframe_collected_weights()` returns `service`. Align by position, not by name |
| The sensitivity table rounds `weight` to 4 places | tolerance `5e-5` on that column only, and say so |
| `sframe_model_constructs` is not `model$constructs` | `model$constructs` is `NULL`. The constructs live under the serialised `measurement` block |
| `<` is JSON-escaped in an exported page | grep for `<`, not `<` |
| HTML entities in a rendered report | unescape `&lt;` before searching for an APA sentence containing `p < .001` |
| `getNamespaceInfo(pkg, "path")` under `load_all()` **is** the package root | `dirname(dirname())` lands 2 levels too high. Walk up until a `DESCRIPTION` appears |
| `$integrity` does not exist on an `sframe` | the hash is in the `.sframe` JSON. `identical(NULL, NULL)` is a vacuous pass |
| `readLines()` takes one path | `lapply()` over `list.files()`, do not hand it the vector |
| `lavaan::` inside a roxygen `@examples` block | strip comments before counting a package as "called" |

---

## 7. Release context

- **D6.** `inst/CITATION` needs the MCDM preprint DOI. CRAN will not accept a
  placeholder. Hard blocker.
- **H2.** The owner must verify the RStudio add-in in a real RStudio session.
  File `19` carries the click path and cannot be automated. Hard blocker.
- **E1.** `DESCRIPTION` goes to `0.4.0` at release time. It reads `0.3.4`
  now and that is correct.
- **The add-in branch.** `feature/rstudio-addin` at `0194ffb` is 1 ahead of
  `v0.5-dev` and 1 behind. Merge both ways before building anything.

Branch is `v0.5-dev` in the worktree `../surveyframe-v0.5-dev`, and it builds
CRAN **0.4.0**. Do not rename anything to match.

Push `dev` to `origin` only. `origin` is the private surveyframe-dev repo and
`public` is the CRAN one, which is the reverse of what CLAUDE.md's prose
implies.
