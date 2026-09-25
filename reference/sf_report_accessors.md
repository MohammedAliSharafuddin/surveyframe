# Read the reportable parts of an analysis or quality result

[`sf_apa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_apa.md)
returns the APA-formatted sentence a result carries.
[`sf_flagged()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_flagged.md)
returns the rows a quality report flagged.

## Value

[`sf_apa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_apa.md)
returns a character vector: one element per block, named by block, for
analysis results, and one element for a single report.
[`sf_flagged()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_flagged.md)
returns an integer vector of row positions, sorted, each row once.

## Details

Given analysis results,
[`sf_apa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_apa.md)
answers for every block at once, as a character vector named by block.
Given one of the standalone reports that carry a sentence of their own,
an assumption report, a descriptives report, a missing-data report or a
validity report, it returns that single sentence. A result with no
sentence gives an empty string, so the shape of the answer follows the
number of blocks asked about.

The sentence is plain text. APA 7 asks for italic Latin statistical
symbols, so a manuscript needs `t`, `F`, `p`, `r`, `d` and the rest
italicised after pasting: a character vector cannot carry that styling.
Numbers are already APA-formatted, including no leading zero on `p` and
a labelled confidence interval.

[`sf_flagged()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_flagged.md)
returns row positions in the response data, as one sorted vector with
each row once, pooling every check the quality report ran: failed
attention checks, straight-lining, excess missingness, timing and
duplicates. Read the report itself for which check flagged a row.

## Examples

``` r
demo <- sframe_demo_data()
qr <- quality_report(demo$responses, demo$instrument)
head(sf_flagged(qr))
#> [1]  37  48  61  73 107 108
```
