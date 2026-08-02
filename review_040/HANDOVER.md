# Handover: finishing the 0.4.0 review suite

Written 2026-08-02. Paste the prompt in section 1 into a new session. Everything
below it is reference material that new session will need, and that cost real
tokens to derive the first time. Do not re-derive it.

---

## 1. The prompt

```
Read CLAUDE.md, then review_040/HANDOVER.md in full before doing anything else.

Nine files of the 0.4.0 review suite are written, render with 0 errors, and
report 203 comparisons all reading `match`. Ten remain: 02, 03, 10, 11, 15,
16, 17, 18, 19, 20. File 19 is a release blocker (H2, the RStudio add-in).

Work in /home/maxx/Documents/GitHub/surveyframe-dev/review_040. Follow the
established file template exactly (section 3 of HANDOVER.md). Use the verified
field names in section 5 rather than guessing, and read the reference-call
traps in section 6 before writing any comparison.

Render each file with `quarto render <file>.qmd --to html` and confirm 0
errors and 0 DIFFERS before moving to the next. Do not commit until a file
renders clean.

Three defects are already logged in dogfeed.todo.md and need owner decisions.
Do not fix them. If you find a fourth, log it there and keep going.
```

---

## 2. What is already done

| File | Covers | Comparisons |
|---|---|---|
| `00_start_here.qmd` | index, how to read a verdict, environment check | 3 |
| `01_first_workflow.qmd` | the whole package in one sitting | 17 |
| `04_categorical.qmd` | chi-square, Fisher, McNemar, Cochran Q | 23 |
| `05_two_group.qmd` | t, Mann-Whitney, paired t, Wilcoxon | 28 |
| `06_multi_group.qmd` | ANOVA, Kruskal, two-way, ANCOVA, repeated, Friedman | 30 |
| `07_correlation.qmd` | Pearson, Spearman, Kendall, partial | 16 |
| `08_regression.qmd` | linear, logistic, ordinal, multinomial, Firth | 32 |
| `09_psychometrics.qmd` | alpha, omega, item diagnostics, EFA, validity | 23 |
| `12_small_sample.qmd` | the whole small-sample track | 19 |
| `13_mcdm.qmd` | all 10 MCDM methods | 15 |

`_setup.R` holds every shared helper. Read it once at the start. Do not
duplicate its helpers inside a `.qmd`.

### What is left

| File | Covers | Difficulty |
|---|---|---|
| `02_field_types.qmd` | one demo per item type, 13 of them | low, template |
| `03_descriptives.qmd` | frequency, descriptives, scale_descriptives, missing_data, quality | low, template |
| `10_model_syntax.qmd` | cfa_lavaan_syntax, sem_lavaan_syntax, seminr_syntax, pls_sem | medium |
| `11_mediation_moderation.qmd` | moderation, mediation | medium |
| `15_sensitivity_conjoint.qmd` | sensitivity_analysis(), sf_conjoint_design() | medium |
| `16_collection_routes.qmd` | static, Shiny, Google Sheets, branching | medium |
| `17_reporting.qmd` | render_report, PDF, codebook, interpretations | low |
| `18_guis.qmd` | builder, SurveyStudio, dashboard | manual, needs a keyboard |
| `19_rstudio_addin.qmd` | **H2, release blocker** | manual, needs RStudio |
| `20_release_safety.qmd` | R CMD check, win-builder, owner decisions | partly manual |

After the last file, update the tables in `00_start_here.qmd` so the index
matches reality.

---

## 3. The file template

Every file follows the same 5-part shape. Copy `05_two_group.qmd` as the
model, which is the cleanest example.

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

Close every file with:

```r
sf_verdict()
```

YAML header, copy verbatim from any existing file. `error: true` matters: a
chunk that fails must show its error rather than stopping the render.

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

This session burned most of its budget on avoidable loops. Do these.

**Use the Write tool, never a shell heredoc, to edit a `.qmd`.** Editing a
file through `python3 - <<'PY'` or `sed` makes the harness detect an external
modification and echo the **entire file** back into context. On a 400-line
`.qmd` that is thousands of tokens per edit, and it happened 4 times this
session. `Write` and `Edit` do not do this.

**Probe field names in one batch before writing, not through render cycles.**
A render takes 40 to 90 seconds and its failure output is long. One
`Rscript -e` that prints `names()` for 20 result objects costs less than 2
failed renders. Section 5 below is the output of exactly that, so most of the
probing is already done.

**Trim every R and render output.** These 2 idioms were used throughout:

```bash
timeout 900 quarto render FILE.qmd --to html 2>&1 | tail -3
Rscript -e '...' 2>&1 | grep -v "^Loading\|^ℹ" | tail -20
```

**Check a render with a one-line grep, not by reading the HTML.** The rendered
files are 1.5 to 2 MB each.

```bash
python3 -c "
import re,html
t=re.sub(r'<[^>]+>',' ',open('FILE.html',encoding='utf-8').read())
t=re.sub(r'\s+',' ',html.unescape(t)); i=t.find(' comparisons:'); print(t[i-4:i+400])
for e in sorted(set(re.findall(r'Error in [^<]{0,100}|Error: [^<]{0,100}',t)))[:6]: print('ERR:',e)"
```

**Do not re-read a file after editing it.** The tools error if an edit fails.

**Do not render the whole suite to check one file.** Render only what changed.

**The rendered `.html` files are gitignored.** Do not add them, and do not
paste their contents anywhere.

### Which model for which file

The house rule is a 3-tier Haiku, Sonnet, Opus split. Applied here:

- **Haiku** for `02`, `03`, `17`, and the manual files `18`, `19`, `20`. These
  follow the template with no adjudication: build an instrument, run the
  route helpers, compare against an obvious base R call. The manual files are
  mostly prose and click paths with few live chunks.
- **Sonnet** for `10`, `11`, `15`, `16`. These need moderate judgement about
  what the right reference is (`lavaan` and `seminr` for model syntax, a
  hand-built mediation for `11`), but the shape is settled.
- **Opus** for anything where a comparison reads `DIFFERS` and somebody has to
  decide whether the package is wrong or the reference call is. That judgement
  is where this session's value was: 4 of the 5 apparent defects turned out to
  be mismatched reference calls, and the 1 that was real (`item_report()`
  keying) only surfaced because both the raw and the reversed reference were
  computed side by side.

A cheaper model should escalate rather than guess when a `DIFFERS` appears. A
loosened tolerance with no stated reason is the failure mode to avoid, because
it hides a real difference and looks like a pass.

---

## 5. Verified result field names

Derived by running each runner directly. **Use these rather than `$` partial
matching**, which silently worked for `rq2$F` matching `F_stat` and would have
broken on any rename.

| Method | Fields |
|---|---|
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
| MCDM ranking methods | `scores ranks alternatives criteria criteria_types weights table ideal anti_ideal separation_positive separation_negative` |
| `ahp` | `weights criteria cr lambda_max consistency_warning table` |
| `dematel` | `criteria D R prominence relation role threshold total_relation normalised` |

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
```

### Signatures worth knowing

```r
sample_size_plan(type = c("proportion","mean","correlation","t_test","anova",
                          "regression","sem"), margin_error, sd, p, r, alpha,
                 power, groups, predictors)     # no `n`, no `method`
assumption_report(data, variables, group, outcome, predictors, table_vars)
                                                 # everything keys off `variables`
export_static_survey(instrument, output_path, open, endpoint_url, overwrite)
render_survey(instrument, mode = "shiny", ...)   # returns a shiny.appobj, not UI
validity_report(loadings, construct_scores, items_by_construct)
                                                 # loadings needs `construct` and `loading`
sensitivity_analysis(x, weights, criteria_types, method, delta, alternatives, criteria)
sf_conjoint_design(id, attributes, method, n_profiles, n_alternatives, n_tasks,
                   blocks, seed, profiles, label)
```

### MCDM internals used in file 13

```r
sframe_assemble_pairwise(data, instrument, item_id)  # $matrices $items $scale
sframe_aggregate_judgements(matrices)                # $matrix $consistency
sframe_principal_eigen(m)                            # $weights $lambda_max  (a list)
sframe_consistency_ratio(m)                          # numeric
sframe_rated_matrix(data, instrument, items)         # $matrix $alternatives $criteria
```

`result$matrix_source` is a **label** such as `"collected"`, not a matrix.
Rebuild the matrix with `sframe_rated_matrix()`.

---

## 6. Reference-call traps

Every one of these produced a `DIFFERS` that was the comparison's fault, not
the package's. Check this list before investigating any new one.

| Trap | Correct reference call |
|---|---|
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

---

## 7. Open defects, do not fix

All 3 are in `dogfeed.todo.md` and need owner decisions.

1. **`item_report()` ignores `reverse = TRUE`** while `score_scales()` and
   `reliability_report()` honour it, lane 0.4.0. A reverse-keyed item reports
   a strongly negative item-rest correlation on a scale with alpha 0.84, and
   depresses every other item in the scale. Shown in `09` section 5.
2. **Correlation roles.** `variables` works for Kendall, fails with
   `Test failed.` for Pearson and Spearman, leaks `undefined columns selected`
   for partial correlation, while 9 other methods accept it. Lane 0.4.0.
   Noted in `07`.
3. **`assumption_report()`** prints "Assumption checks were computed." when no
   check ran. Lane 0.4.1. Noted in `05` section 8.

---

## 8. Release context

0.4.0 engineering is complete. Two things stand between here and CRAN
submission, plus this suite:

- **D6.** `inst/CITATION` needs the MCDM preprint DOI. CRAN will not accept a
  placeholder. This is the hard blocker.
- **H2.** The owner must verify the RStudio add-in in a real RStudio session.
  File `19` carries the click path and cannot be automated.

Branch is `v0.5-dev` in the worktree `../surveyframe-v0.5-dev`, and it builds
CRAN **0.4.0**. Do not rename anything to match. `DESCRIPTION` goes to `0.4.0`
only at release time, task E1.

Push `dev` to `origin` only. `origin` is the private surveyframe-dev repo and
`public` is the CRAN one, which is the reverse of what CLAUDE.md's prose
implies.
