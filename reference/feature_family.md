# Response families used for each recall feature

The three features need three different families, and each choice
follows from what the boundary of that feature's scale means rather than
from convenience.

- **Word: zero-one-inflated Beta.** About 91% of responded word items
  score exactly 1, because a recalled word either matches the target or
  does not. That is a genuine point mass and earns an inflation
  component, as do the 3% scoring exactly 0.

- **Orientation: Beta.** No boundary mass at all once non-responders are
  removed.

- **Colour: Beta.** Boundary mass exists but is negligible and is an
  artifact: colour score is cosine similarity on a continuous wheel, so
  an exact 1 is an error of exactly zero degrees, which is pixel
  resolution rather than a behaviour. Handle it with
  [`squeeze_boundaries()`](https://m-delem.github.io/aphantasiaWMStrats/reference/squeeze_boundaries.md)
  rather than an inflation component.

## Usage

``` r
feature_family(feature = c("word", "angle", "color"))
```

## Arguments

- feature:

  One of `"word"`, `"angle"`, `"color"`.

## Value

A brms family object.
