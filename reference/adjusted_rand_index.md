# Adjusted Rand index

Agreement between two partitions of the same participants, corrected for
the agreement expected by chance. 1 is identical, 0 is chance.

Used here for the question the exploratory strand exists to answer: does
a clustering recover the imagery grouping, or find something else? An
index near 1 against the vividness split is a reportable null.

## Usage

``` r
adjusted_rand_index(a, b)
```

## Arguments

- a, b:

  Two partitions, as vectors of equal length.

## Value

A single numeric value.
