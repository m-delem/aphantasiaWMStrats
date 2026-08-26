# Isometric log-ratio coordinates for a three-part composition

The balanced ILR transform, with the sequential binary partition (SBP)
given explicitly by `first`. This choice belongs to the researcher and
should not be made on statistical grounds: picking whichever partition
maximises a contrast selects a split nobody has a substantive interest
in. It is therefore an explicit argument with a default matching the
study's own decision, rather than a hidden constant.

Convention, identical to the one used in
`inst/scripts/06a-reliability.R`, so that the split-half stability
estimates computed there apply to these coordinates unchanged:

\$\$ilr_1 = \sqrt{2/3} \log(p_1 / \sqrt{p_2 p_3})\$\$ \$\$ilr_2 =
\sqrt{1/2} \log(p_2 / p_3)\$\$

where \\p_1\\ is `first` and \\p_2, p_3\\ are the remaining two parts in
the canonical order `word, color, angle`. For the default
(`first = "word"`), `ilr1` is verbal versus non-verbal allocation and
`ilr2` is colour versus orientation.

Any two-coordinate ILR basis is a rotation of the same geometry: the
omnibus test, the Aitchison distances and the total variance do not
depend on `first`. What depends on it is which single-coordinate claim
can be stated.

## Usage

``` r
ilr_coords(parts, first = c("word", "color", "angle"))
```

## Arguments

- parts:

  A data frame or matrix with the three closed parts, named either
  `part_word`/`part_angle`/`part_color` or `word`/`angle`/`color`.

- first:

  The feature contrasted against the other two in the first coordinate.
  One of `"word"` (default), `"color"`, `"angle"`.

## Value

A tibble with `ilr1` and `ilr2`, and attributes `first` and `balance`
recording which partition produced them.
