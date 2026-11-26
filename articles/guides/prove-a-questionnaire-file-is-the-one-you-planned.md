# How to prove a questionnaire file is the one you planned

Check that a questionnaire file matches the hash recorded when it was
saved.

The example in this guide is *Event feedback*. A short feedback survey
for a one-day professional event, run to describe who attended and to
check the quality of the answers before the programme is planned again.

## In SurveyStudio

1.  Open [Verify a file](https://surveyframe.org/verify/) in your
    browser and drop the `.sframe` file on it. The check runs in the
    browser and the file stays on your computer.
2.  The page reports whether the content matches its recorded hash, and
    reads the disclosed-amendment log if the file has one.
3.  To identify a registered version, compare the hash with the one in
    the plan you preserved, such as on OSF.

![The Design screen with the Event feedback study
open.](../../templates/verification/design.png)

The Design screen with the Event feedback study open.

## In R

``` r

d <- sframe_demo("verification")
read_sframe(d$instrument_path)   # verifies the hash as it reads
tampered <- file.path(dirname(d$instrument_path), "verification_tampered.sframe")
try(read_sframe(tampered))       # a changed file reports the mismatch
```

## Related

- [Questionnaire
  templates](https://surveyframe.org/articles/templates.md)
- [All how-to guides](https://surveyframe.org/articles/guides.md)
