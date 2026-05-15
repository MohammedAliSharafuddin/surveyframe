# Sample-size and power planning helper

Sample-size and power planning helper

## Usage

``` r
sample_size_plan(
  type = c("proportion", "mean", "correlation", "t_test", "anova", "regression", "sem"),
  margin_error = NULL,
  sd = NULL,
  p = 0.5,
  r = NULL,
  alpha = 0.05,
  power = 0.8,
  groups = 2L,
  predictors = NULL
)
```

## Arguments

- type:

  Planning target: `"proportion"`, `"mean"`, `"correlation"`,
  `"t_test"`, `"anova"`, `"regression"`, or `"sem"`.

- margin_error:

  Margin of error for mean/proportion planning.

- sd:

  Standard deviation for mean planning.

- p:

  Expected proportion.

- r:

  Expected correlation.

- alpha:

  Significance level.

- power:

  Desired power.

- groups:

  Number of groups for ANOVA/t-test planning.

- predictors:

  Number of predictors for regression planning.

## Value

A list of planning estimates and warnings.
