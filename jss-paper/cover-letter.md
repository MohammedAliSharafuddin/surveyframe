# Cover comment to the JSS editor (revised resubmission)

Originally submitted to the Journal of Statistical Software on 2026-06-02. OJS
submission ID 6454. Returned with a revise-and-resubmit invitation. This is the
revised resubmission.

---

Dear Editors,

Thank you for the opportunity to revise "surveyframe: A Proactive Survey
Research Workflow for R" for the Journal of Statistical Software. We are
grateful for the feedback, which improved both the package and the manuscript.

The package changes you identified are now released in surveyframe 0.3.2, which
is on CRAN. The manuscript and the replication script describe this version. The
submitted tarball is surveyframe_0.3.2.tar.gz.

We made the following changes in response to the review.

Package changes (released in 0.3.2 on CRAN):

1. Corrected `inst/CITATION` so it reports the correct package title and reads
   the version dynamically from the package metadata.
2. Added `print()`, `format()`, and `summary()` methods for all six component
   classes (`sf_choices`, `sf_item`, `sf_scale`, `sf_branch`, `sf_check`, and
   `sf_model`).
3. Added lavaan to Suggests so the CFA syntax workflow declares its optional
   dependency.
4. Corrected the replication script `replicate.R` and confirmed it runs end to
   end with no external data or network access.
5. Fixed attention-check rendering in the exported survey.

Manuscript changes:

1. Moved the `export_static_survey()` demonstration into the prose and added a
   screenshot of the rendered survey (Figure 1), with three further screenshots
   of the Likert item, the required-field validation, and the mobile layout
   (Figures 2 to 4).
2. Added the `methods(class = "sf_choices")` output to demonstrate the S3 method
   system.
3. Added a runnable demonstration of the SHA-256 integrity hash: `write_sframe()`
   records the hash, the manuscript shows the stored value, and `read_sframe()`
   recomputes and verifies it on load.
4. Added two SurveyBuilder screenshots (Figures 5 and 6) with descriptive
   captions, so all six figures carry captions and alternative-text
   descriptions.
5. Updated every package version reference from 0.3.0 to 0.3.2.

The submission includes the three required components: the JSS-class manuscript
PDF, the package source tarball, and the standalone replication script,
`replicate.R`, that reproduces every result in the paper with no external data
or network access. The software is released under the MIT licence, which is
GPL-compatible.

The work is original, has not appeared elsewhere, and is not under review at
another venue. Both authors have approved the resubmission.

Thank you for your consideration.

Mohammed Ali Sharafuddin, on behalf of both authors
