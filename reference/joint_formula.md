# The joint propensity and accuracy model

Six responses: three Bernoulli gates for whether a feature was reported
at all, three bounded accuracies for how well it was reported when it
was, sharing a 6x6 correlated participant random-intercept matrix.

The 15 correlations are the reason the model exists. They fall into four
families: propensity against accuracy within a feature (whether
conditioning on responding is legitimate), accuracy against accuracy
across features (whether doing well on one costs another), propensity
against propensity (whether people who skip one feature skip others),
and the six cross terms.

[`subset()`](https://rdrr.io/r/base/subset.html) on each accuracy arm is
what lets one row carry six responses with independent non-response, and
what lets a participant contribute to a gate whether or not they ever
answered that feature. Participants who never answered a feature are
invisible to any responders-only analysis and highly informative here.

`parity_rate` belongs on the accuracy arms only. It is the dual-task
load a participant actually incurred, and it does not predict recall
non-response, so there is no reason to put it on the gates. It must be
the proportion of parity probes answered, computed from
`responded_parity_*`, not a mean of `parity_*_acc`, which scores an
unanswered probe as 0 and is a response rate wearing an accuracy name.

## Usage

``` r
joint_formula(
  parity = TRUE,
  features = c("word", "angle", "color"),
  accuracy_features = features
)
```

## Arguments

- parity:

  Whether to include `parity_rate` on the accuracy arms.

- features:

  Feature stems, in the order the responses should appear. Gates are
  built for all of them.

- accuracy_features:

  Which features get an accuracy arm. Defaults to all of them. Pass
  `character(0)` for the gates alone, which is the response-propensity
  model in its own right, or drop `"word"` to keep its gate without its
  accuracy: word's accuracy is excluded from individual-differences
  inference anyway, on reliability grounds.

## Value

A `brmsformula` object. Print it to see every response.

## See also

[`joint_priors()`](https://m-delem.github.io/aphantasiaWMStrats/reference/joint_priors.md),
which must be built with matching arguments.
