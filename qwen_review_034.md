> **Verification appendix (added after fact-checking against the actual repository, 2026-07-18).** The original review below is preserved verbatim, unedited. Unlike a second review of this codebase (`kimi_review_034.md`), this one is written as forward-looking recommendations rather than quoted "bugs," is grounded in real git history, and its checkable factual claims held up. No code changes were made from this review — its items are genuine suggestions/audits, not confirmed defects.
>
> **Checked and confirmed accurate:**
> - The "0.3.0 preparation commit" reference is real: `git log` shows `3daf0a9 Prepare surveyframe 0.3.0 for CRAN submission`, `2fb8c3f Prepare surveyframe 0.3.0 CRAN submission`, and `511b910 Address CRAN reviewer feedback for 0.3.0 resubmission`.
> - `og:image` is a PNG (`pkgdown-wordmark-tagline.png`, confirmed in `docs/index.html`), not SVG.
> - The repeated-measures ANOVA point is directionally correct and was addressed this session: `sframe_run_repeated_anova()` (`R/statistics_reports.R`) now extracts F, both df, p, and partial eta-squared programmatically from the `Error()`-stratified fit's "Error: Within" stratum. Tested it against data with missingness (unbalanced-by-NA case) — it still returns a sane result rather than erroring. Sphericity corrections (Greenhouse-Geisser/Huynh-Feldt) are genuinely not implemented; the function's `prompt` field already flags "sphericity limitations" as a caveat for the report author rather than silently presenting an uncorrected F-test as final. Treat the correction itself as a real, reasonably-scoped future enhancement, not a bug.
> - The SurveyStudio dashboard does use plain `fluidPage()`, not a `bslib`-based responsive layout (`inst/shiny/dashboard/app.R`) — accurate as a polish item.
> - Parity between the Quarto and HTML-fallback report paths is structurally guaranteed rather than something that can silently drift: both call the same `run_analysis_plan()` and render whatever `$table`/`$plot`/`$syntax` it returns, just with different templating. This session's earlier pass (filling in every block's missing table/plot/syntax output) verified this directly against all 34 demo blocks in both paths.
>
> **Checked and found not applicable as stated:**
> - "Audit all vignettes... for the same [`requireNamespace`] pattern" — none of the vignettes call `library(shiny)` or reference shiny at all (the interactive/data-collection steps use `eval = FALSE`), so there's nothing to namespace-hygiene there.
> - The CSV download button in the dashboard (`inst/shiny/dashboard/app.R`) currently interpolates a real `THEME` variable into its inline `style` attribute (`background:%s`), not a `var(--undefined)` CSS custom property — whatever undefined-variable issue this refers to is not present in the current code (may describe an already-fixed past state, consistent with the 0.3.2 "GUI polish: brand theme" commit).
>
> **Not independently re-verified** (reasonable suggestions, not falsifiable against a single code read): the SEM identification "dry run" validator, attention-check auto-exclusion from measurement models, the small-sample inference roadmap documentation, S3/`@export` tag completeness audit, alt-text content quality, native date-picker cross-browser behaviour, JSON-LD structured-data validation, and the `devtools::check(remote = TRUE, manual = TRUE)` CRAN dry run. These are worth doing but require either browser testing or a full CRAN-style check run rather than a source read.
>
> Original review follows, unmodified.

Based on a review of the `surveyframe` repository, documentation, and recent development history, here is an assessment covering UI/UX, R programming, Quarto integration, full-stack architecture, and statistical methodology.

### Statistical Methodology & Research Design

*   **Syntax Generation vs. Model Fitting Decoupling:** The decision to make `lavaan` and `seminr` optional dependencies is architecturally sound for package distribution but introduces a validation gap. Users can generate syntactically correct SEM code that is statistically unidentified or misspecified without immediate feedback. Consider adding a lightweight "dry run" validator that checks degrees of freedom and basic identification rules using base R before requiring the heavy SEM backends.
*   **Repeated Measures ANOVA Extraction:** Recent commits indicate programmatic extraction of F-statistics from `Error()`-stratified `aov` fits. This approach is fragile because the internal structure of `aovlist` objects varies with design complexity and missing data handling. Verify this extraction logic against unbalanced designs and cases where sphericity corrections (Greenhouse-Geisser, Huynh-Feldt) are required, as these alter the denominator degrees of freedom and effect size calculations.
*   **Attention Check Integration:** The current implementation flags attention check failures at the row level. For PLS-SEM and CFA workflows common in your domain, consider adding an option to automatically exclude flagged cases from the measurement model estimation step while retaining them in descriptive summaries. This aligns with best practices for data screening in structural equation modeling.
*   **Small Sample Inference Roadmap:** The planned v0.4 small-sample helpers should explicitly document the boundary conditions where asymptotic assumptions fail. For blue economy research where sample collection is often constrained, providing clear guidance on when to use bootstrapping versus permutation tests versus Bayesian alternatives would add significant practical value.

### R Programming & Package Architecture

*   **Namespace Hygiene:** The shift from `library(shiny)` to `requireNamespace` with explicit namespacing in the dashboard app is correct for CRAN policy. Audit all vignettes and demo scripts for the same pattern. Vignette code runs in user sessions where namespace collisions are more likely than in package checks.
*   **S3 Method Dispatch Consistency:** New plot methods (`plot.sframe_validity_report`, `plot.sframe_analysis_results`) follow S3 conventions. Ensure all exported generics have corresponding `@export` roxygen tags and that non-exported helper methods use the dot-prefix convention consistently to avoid accidental method masking.
*   **Optional Dependency Handling:** Functions relying on `psych`, `MASS`, or `nnet` should fail gracefully with informative messages when those packages are absent. Check that error messages suggest the specific installation command rather than generic "package not found" warnings.
*   **Test Coverage for Edge Cases:** With 649 tests passing, coverage appears strong. Prioritize additional tests for malformed `sframe` objects, particularly those with mismatched analysis plan bindings or orphaned construct definitions. These states occur frequently during iterative instrument design and are common sources of silent failures.

### Quarto Integration & Reporting

*   **HTML Fallback Parity:** Recent work addressed syntax text rendering gaps between Quarto and HTML fallback reports. Conduct a systematic diff of all 34 analysis plan block outputs across both render paths. Any remaining discrepancies will confuse users who switch between interactive exploration and final manuscript preparation.
*   **Decision Rule Threading:** The interpretation-to-decision-rule linkage is a distinguishing feature. Verify that decision rule edits made in SurveyStudio propagate correctly to the Quarto template without requiring manual re-rendering. Stale decision rules in generated reports undermine the reproducibility promise.
*   **Code Block Rendering:** Syntax blocks in HTML fallback now render as code elements. Confirm that syntax highlighting and line wrapping behave identically to Quarto's native code chunk rendering. Inconsistent formatting breaks visual continuity when users compare interactive and static outputs.
*   **Figure Alt Text Compliance:** WCAG 2.2 AA compliance includes meaningful alt text for all plot chunks. Audit auto-generated alt text for statistical plots to ensure it conveys the finding rather than just describing chart type. Automated alt text like "bar chart showing validity metrics" is insufficient for accessibility; it should read "AVE values for three constructs exceed 0.5 threshold, CR values range 0.78-0.85."

### UI/UX Assessment

*   **SurveyBuilder Inspector Fields:** Date question bounds (`date_min`, `date_max`) were recently added. Test the native date picker behavior across Chrome, Firefox, and Safari. Native pickers have inconsistent support for min/max attributes, and fallback validation messages must be visible without JavaScript.
*   **Result Card Layout in SurveyStudio:** Analysis results now render as one card per research question. Evaluate whether this layout scales for instruments with 20+ research questions. Consider adding collapsible sections or a filterable index to prevent excessive scrolling during result review.
*   **CSS Variable Definitions:** The CSV download button previously used an undefined theme color variable. Audit all Shiny UI components for similar undefined CSS references. Undefined variables silently fail to apply styles, creating subtle visual inconsistencies that erode perceived quality.
*   **Tab Switch Plot Rendering:** The fix for `renderPlot` inside `renderUI` after tab switches addresses a known Shiny reactivity issue. Verify this fix works when multiple plots exist on the same tab and when switching rapidly between tabs. Race conditions in reactive rendering can still cause blank plot areas under load.

### Full Stack & Deployment Considerations

*   **Offline Operation Guarantee:** The README states the package works offline during examples and checks. Document explicitly which features require network access (e.g., Google Sheets integration) and provide clear offline alternatives. Users in field research contexts may have intermittent connectivity.
*   **pkgdown Structured Data:** JSON-LD metadata was added for search indexing. Validate this structured data using Google's Rich Results Test and Schema.org validator. Incorrect structured data can harm discoverability rather than improve it.
*   **Social Share Preview Images:** The switch from SVG to PNG for `og:image` was necessary. Verify the PNG renders correctly at all major platform dimensions (Twitter/X, LinkedIn, Slack). Test actual share previews rather than assuming correct rendering.
*   **CRAN Submission Readiness:** The 0.3.0 preparation commit references multiple CRAN policy fixes. Run `devtools::check(remote = TRUE, manual = TRUE)` with all optional dependencies installed and absent to catch conditional import issues that only surface during CRAN's multi-environment checks.

### Priority Recommendations

1.  Validate repeated measures ANOVA extraction against unbalanced designs with sphericity violations.
2.  Systematically diff all 34 analysis plan outputs between Quarto and HTML fallback render paths.
3.  Add lightweight SEM identification checking that operates without `lavaan` or `seminr`.
4.  Audit all Shiny UI components for undefined CSS variables and cross-browser date picker compatibility.
5.  Document offline capability boundaries and network-dependent feature alternatives explicitly.
