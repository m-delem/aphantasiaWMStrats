# Is a clustering of the pooled sample the same clustering of v1?

The pooled sample is about a third floor-group where v1 is a quarter,
because later recruitment targeted aphantasics. Cluster centroids are
fitted to whatever sample they are given, so v1 participants' labels are
partly determined by participants who enter no other analysis.

This refits on the restricted sample and cross-tabulates, so the
question is answered rather than assumed. Substantial agreement means
the pooling is innocent and the larger sample can be kept; disagreement
means the pooled solution is describing the versions that were excluded
from everything else.

## Usage

``` r
cluster_stability(pooled, restricted)
```

## Arguments

- pooled, restricted:

  Cluster assignments for the same participants, from the two fits, as
  vectors of equal length.

## Value

A list with the cross-tabulation, the proportion of participants whose
label is preserved under the best matching of labels, and the adjusted
Rand index.
