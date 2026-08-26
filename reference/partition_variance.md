# Variance carried by each ILR coordinate, under each partition

Shows what the choice of sequential binary partition does and does not
change. The **total** is invariant: any two-coordinate ILR basis is a
rotation of the same geometry. Only the split between the first and
second coordinate moves, which is why a partition should be chosen for
the contrast it names rather than for the variance it captures.

## Usage

``` r
partition_variance(
  parts,
  label = NA_character_,
  first = c("word", "color", "angle")
)
```

## Arguments

- parts:

  A data frame with `part_*` columns.

- label:

  A label for the sample.

- first:

  Which features to try as the first contrast.

## Value

A tibble with one row per candidate partition.
