# Flag which parity probes were actually answered

`parity_1_acc` and `parity_2_acc` score an unanswered probe as 0, the
same convention the recall columns use, and with the same consequence: a
zero conflates a wrong answer with no answer. In v1 the conflation is
near-total. Of 3315 zeros on `parity_1_acc`, 3046 are probes where
`parity_1_resp` and `parity_1_rt` are both `NA`, and only 269 are
answered-and-wrong. A participant-level mean of the raw column
correlates 0.989 with the proportion of probes answered and 0.215 with
accuracy among those answered: it is a propensity measure wearing an
accuracy label.

The two components are close to orthogonal (r = 0.043 across v1
participants), so collapsing them does not blur two related quantities,
it discards one. This function adds the flags that let a caller separate
them, exactly as `responded_word` and friends do for recall.

The parity columns are optional. Data without them passes through
unchanged, since
[`compute_scores()`](https://m-delem.github.io/aphantasiaWMStrats/reference/compute_scores.md)
is also useful on frames that carry recall responses alone.

## Usage

``` r
flag_parity_responses(data)
```

## Arguments

- data:

  A stimulus-level data frame.

## Value

`data` with `responded_parity_1` and `responded_parity_2` appended when
the corresponding `parity_*_resp` columns are present.
