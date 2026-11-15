# Text and open-ended response analysis

## What this vignette covers

Text and textarea items collect open-ended responses, beyond what a
Likert scale records: the reason behind a rating, a complaint a closed
question never anticipated, a suggestion nobody thought to ask for
directly. surveyframe treats analysing that text the same way it treats
every other analysis: a research question, a technique, and the roles
that fill it, declared in the instrument’s analysis plan before the
numbers exist.

9 methods are available, from plain term counting through to topic
modelling. The base path (`term_freq`, `ngram_freq`, `term_context`,
`co_occurrence`) runs on the package alone. 5 more
(`co_occurrence_network`, `tidy_sentiment`, `quanteda_dfm`,
`topic_model_lda`, `stm_topics`) need one or more Suggests-only
packages, guarded with
[`rlang::check_installed()`](https://rlang.r-lib.org/reference/is_installed.html),
and every guarded section below knits cleanly on either kind of machine.

## A survey with an open-ended item beside a Likert scale

The worked example is a small hospitality feedback survey: a
satisfaction scale, a branch (region) respondents visited, and one
open-ended comments item asking what stood out about their visit.

``` r

satisfaction_cs <- sframe_choice_set(
  "agree5", values = 1:5,
  labels = c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree")
)
branch_cs <- sframe_choice_set(
  "branch", values = c("north", "south"),
  labels = c("North branch", "South branch")
)

instr <- sframe_instrument(
  title = "Hospitality feedback",
  version = "1.0.0",
  components = list(
    satisfaction_cs, branch_cs,
    sframe_item("satisfaction", "Overall, I was satisfied with my visit.",
            type = "likert", choice_set = "agree5"),
    sframe_item("branch", "Which branch did you visit?",
            type = "single_choice", choice_set = "branch_cs"),
    sframe_item("comments", "What stood out about your visit, good or bad?",
            type = "textarea")
  )
)
```

## Simulated responses

The comments are built from a small phrase bank, seeded so the example
is reproducible. The north branch’s simulated visits lean positive, the
south branch’s lean mixed, which gives the group-role examples below
something real to show, where an even split would leave only a
coincidence.

``` r

positive_pool <- c(
  "The staff were incredibly friendly and helpful.",
  "Check-in was quick and the room was spotless.",
  "Our server was attentive and the food arrived fast.",
  "The team went out of their way to help us.",
  "Friendly staff made the whole visit pleasant.",
  "The room was clean and comfortable throughout our stay.",
  "Quick service and a warm welcome from everyone.",
  "The staff were helpful whenever we needed anything."
)
negative_pool <- c(
  "We had to wait a long time for someone to help us.",
  "The staff seemed rude and unhelpful the whole time.",
  "The wait for a table was far too long.",
  "Our room was dirty and the service was slow.",
  "Staff were slow to respond and not very friendly.",
  "The long wait ruined an otherwise average visit.",
  "Service was poor and the staff seemed uninterested.",
  "We waited a long time and nobody apologised."
)

sample_comment <- function(p_positive) {
  n_sentences <- sample(1:2, 1)
  pools <- sample(c("pos", "neg"), n_sentences, replace = TRUE,
                  prob = c(p_positive, 1 - p_positive))
  sentences <- vapply(pools, function(p) {
    if (p == "pos") sample(positive_pool, 1) else sample(negative_pool, 1)
  }, character(1))
  paste(sentences, collapse = " ")
}

n <- 60
branch <- sample(c("north", "south"), n, replace = TRUE)
comments <- vapply(branch, function(b) {
  sample_comment(if (b == "north") 0.8 else 0.35)
}, character(1))

responses <- data.frame(
  satisfaction = sample(3:5, n, replace = TRUE, prob = c(0.2, 0.35, 0.45)),
  branch = branch,
  comments = comments,
  stringsAsFactors = FALSE
)

kable(head(responses, 4), row.names = FALSE,
      caption = "The first 4 simulated responses.")
```

## Cleaning a text item

[`sframe_clean_text()`](https://surveyframe.org/reference/sframe_clean_text.md)
pulls one item’s responses out of the data, drops blank and missing
entries, and applies light, configurable cleaning. It keeps a
`respondent` attribute mapping each cleaned entry back to its original
row, so anything built on top (a concordance, a representative quote)
can still cite where a response came from.

``` r

cleaned <- sframe_clean_text(responses, "comments", instrument = instr)
length(cleaned)
head(attr(cleaned, "respondent"))
```

## Term and n-gram frequency

[`sframe_term_frequency()`](https://surveyframe.org/reference/sframe_term_frequency.md)
tokenises, lower-cases, strips punctuation, removes stop words (a
built-in English list ships with the package, so this stage runs on base
surveyframe), and counts.
[`sframe_ngram_frequency()`](https://surveyframe.org/reference/sframe_ngram_frequency.md)
does the same for 2-word and 3-word phrases, which surface a complaint
like “long wait” that single-word counts would split apart.

``` r

terms <- sframe_term_frequency(cleaned, top_n = 10)
kable(terms, row.names = FALSE, caption = "The 10 most frequent terms.")
```

``` r

bigrams <- sframe_ngram_frequency(cleaned, n = 2, top_n = 8)
kable(bigrams, row.names = FALSE, caption = "The 8 most frequent bigrams.")
```

Both run through the analysis plan the same way any other method does.
Here, `term_freq` also takes an optional `group` role (covered below),
which splits the table and facets the chart by a nominal or ordinal
covariate.

``` r

sframe_plan(instr) <- list(
  list(id = "RQ1",
       research_question = "What themes recur in the open-ended comments?",
       family = "text", method = "term_freq",
       roles = list(item = "comments"),
       options = list()),
  list(id = "RQ2",
       research_question = "Do the leading themes differ by branch?",
       family = "text", method = "term_freq",
       roles = list(item = "comments", group = "branch"),
       options = list())
)

results <- run_analysis_plan(responses, instr, plots = has_ggplot)
kable(results[["RQ1"]]$table, row.names = FALSE,
      caption = "Term frequency across all branches.")
```

``` r

results[["RQ1"]]$plot
```

A word cloud is available as an opt-in alternative to the bar chart
(`options$wordcloud = TRUE`), useful in a slide deck where a bar chart’s
axis would be redundant.

``` r

sframe_plot_term_frequency(
  list(test = "term_freq", variable = "comments", table = terms,
       options = list(wordcloud = TRUE))
)
```

## The group role: comparing branches

`RQ2` above declared the same method with a `group` role added. The
table gains a `group` column, one block of rows per branch, and the plot
facets instead of drawing a single panel.

``` r

kable(results[["RQ2"]]$table, row.names = FALSE,
      caption = "Term frequency split by branch.")
```

``` r

results[["RQ2"]]$plot
```

North’s simulated comments lean toward “friendly”, “helpful”, and
“clean”. South’s lean toward “wait”, “slow”, and “staff” in a different
sense, the complaint sense of the word, where the North uses the
compliment. A group split like this is what turns “the comments mention
staff a lot” into a specific, actionable finding.

The `group` role applies the same minimum-response guard per group as it
does overall: a branch with too few usable responses is flagged in the
table’s `note` column, which keeps a handful of comments from reading as
a trend.

## Keyword in context

[`sframe_term_context()`](https://surveyframe.org/reference/sframe_term_context.md)
builds a concordance for one keyword: every place it appears, with a
window of surrounding words on each side. It is the fastest way to read
what a keyword actually means in context, and it settles whether a
frequent term keeps one sense throughout.

``` r

kwic <- sframe_term_context(cleaned, term = "wait", window = 5)
kable(kwic, row.names = FALSE, caption = 'Every occurrence of "wait" in context.')
```

## Co-occurrence

The analysis-plan method `co_occurrence` counts how often pairs of
frequent terms appear together within the same response, and renders as
a heatmap.

``` r

sframe_plan(instr) <- c(sframe_plan(instr), list(list(
  id = "RQ3",
  research_question = "Which terms tend to appear together in the same comment?",
  family = "text", method = "co_occurrence",
  roles = list(item = "comments"),
  options = list()
)))
results <- run_analysis_plan(responses, instr, plots = has_ggplot)

kable(head(results[["RQ3"]]$table, 8), row.names = FALSE,
      caption = "The strongest co-occurring term pairs.")
```

``` r

results[["RQ3"]]$plot
```

## Co-occurrence network

The same co-occurrence structure, clustered and laid out as a network,
needs the optional `igraph` package.
[`igraph::cluster_louvain()`](https://r.igraph.org/reference/cluster_louvain.html)
groups terms into thematic clusters and
[`igraph::layout_with_fr()`](https://r.igraph.org/reference/layout_with_fr.html)
positions them with a force-directed layout. Both are seeded, so the
same `options$seed` always produces the same clusters and the same
layout.

``` r

sframe_plan(instr) <- c(sframe_plan(instr), list(list(
  id = "RQ4",
  research_question = "Do the frequent terms form distinct thematic clusters?",
  family = "text", method = "co_occurrence_network",
  roles = list(item = "comments"),
  options = list(seed = 42)
)))
results <- run_analysis_plan(responses, instr, plots = has_ggplot)

kable(results[["RQ4"]]$table, row.names = FALSE,
      caption = "Term co-occurrence network: one row per node.")
results[["RQ4"]]$apa
```

``` r

results[["RQ4"]]$plot
```

## Sentiment

`tidy_sentiment` needs the optional `tidytext` package. It uses the
bundled `"bing"` positive/negative lexicon, which arrives with tidytext
itself. Like `term_freq`, it accepts an optional `group` role.

``` r

sframe_plan(instr) <- c(sframe_plan(instr), list(list(
  id = "RQ5",
  research_question = "Is sentiment in the comments more positive or negative, and does it differ by branch?",
  family = "text", method = "tidy_sentiment",
  roles = list(item = "comments", group = "branch"),
  options = list()
)))
results <- run_analysis_plan(responses, instr, plots = has_ggplot)

kable(results[["RQ5"]]$table, row.names = FALSE,
      caption = "Sentiment counts, split by branch.")
results[["RQ5"]]$apa
```

``` r

results[["RQ5"]]$plot
```

The diverging bar answers “how many responses leaned positive.” A
different question, “which *words* drove that,” has its own opt-in view:
a comparison cloud (`options$wordcloud = TRUE`, the same toggle
`term_freq`’s word cloud uses), negative-sentiment words to the left of
centre and positive-sentiment words to the right, matching the diverging
bar’s own left-negative/right-positive convention, each sized and shaded
(dark for frequent, light for rare) by how often it occurred.

``` r

instr_cloud <- instr
plan <- sframe_plan(instr_cloud)
plan[[which(vapply(plan, `[[`, "", "id") == "RQ5")]]$options <- list(wordcloud = TRUE)
sframe_plan(instr_cloud) <- plan

result_cloud <- run_analysis_plan(responses, instr_cloud, plots = TRUE)
result_cloud[["RQ5"]]$plot
```

## Document-feature matrix

`quanteda_dfm` needs the optional `quanteda` package. It is a
descriptive summary ahead of an analysis: feature count, sparsity, and
the leading features provide a sanity check before a heavier method.

``` r

sframe_plan(instr) <- c(sframe_plan(instr), list(list(
  id = "RQ6",
  research_question = "What does the document-feature matrix of the comments look like?",
  family = "text", method = "quanteda_dfm",
  roles = list(item = "comments"),
  options = list()
)))
results <- run_analysis_plan(responses, instr)

kable(results[["RQ6"]]$table, row.names = FALSE,
      caption = "Document-feature matrix summary.")
kable(head(results[["RQ6"]]$top_features, 8), row.names = FALSE,
      caption = "The leading features.")
```

## Topic modelling and representative quotes

`stm_topics` fits a structural topic model via the optional `stm`
package (tokenising uses `tidytext`, so both are needed). A small `k`
keeps this example fast. A real study would try 3 to 6 values of `k` and
compare fit. `k = 3` (or `topic_model_lda`’s default `k = 4`) is a
demonstration value chosen to keep the example fast, with a fit
criterion left out of it. The accepted way to choose `k` is to fit a
range of candidate values and compare them on held-out likelihood or a
coherence metric:
[`stm::searchK()`](https://rdrr.io/pkg/stm/man/searchK.html) does this
directly for `stm_topics`’s underlying model (pass it the same
`documents`/`vocab`
[`stm::prepDocuments()`](https://rdrr.io/pkg/stm/man/prepDocuments.html)
would produce), and
[`topicmodels::perplexity()`](https://rdrr.io/pkg/topicmodels/man/perplexity.html)
on a held-out split serves the same purpose for `topic_model_lda`. Both
stay in their own packages. `k` selection is a modelling decision for
the researcher to make and report, not a default to trust unexamined.

``` r

sframe_plan(instr) <- c(sframe_plan(instr), list(list(
  id = "RQ7",
  research_question = "What topics organise the open-ended comments?",
  family = "text", method = "stm_topics",
  roles = list(item = "comments"),
  options = list(k = 3, seed = 42)
)))
results <- run_analysis_plan(responses, instr, plots = has_ggplot)

kable(results[["RQ7"]]$table, row.names = FALSE,
      caption = "Top terms per topic.")
results[["RQ7"]]$apa
```

``` r

results[["RQ7"]]$plot
```

[`sframe_extract_quotes()`](https://surveyframe.org/reference/sframe_extract_quotes.md)
reads the fitted model back off the result and returns the most
representative response for each topic, with the **original** respondent
index (not a document or matrix row number), so a quote can be traced
back to the response that produced it.

``` r

quotes <- sframe_extract_quotes(results[["RQ7"]], text = cleaned, n_quotes = 2)
kable(quotes, row.names = FALSE,
      caption = "The 2 most representative comments per topic.")
```

## The rendered report

Because every block above is declared in the instrument’s analysis plan,
the whole thing renders as one report in the order it was declared,
exactly like any other family of methods. A topic model’s representative
quotes attach to its result as `$quotes` and render as their own table
beneath the topic terms, using the same generic table renderer every
other result’s `$table` uses.

``` r

render_report(instr, responses, output_file = "hospitality-feedback.html")
```

## What surveyframe does not do here

This is algorithmic counting and clustering, not interpretation. Term
frequency, co-occurrence, and topic modelling surface *candidate*
themes. A human reader still decides what they mean and whether they
answer the research question.

surveyframe also does not build a qualitative coding interface. Manual,
inductive coding (code-and-retrieve, memos, a hierarchical code scheme,
the qcoder or RQDA style of analysis) is a different paradigm from the
algorithmic methods here, resting on human interpretation where these
methods count and cluster, and is out of scope by design.
[`sframe_extract_quotes()`](https://surveyframe.org/reference/sframe_extract_quotes.md)’s
output is deliberately a plain data frame, clean enough to export and
take into a dedicated qualitative coding tool for that next step, which
surveyframe leaves to the tools built for it.
