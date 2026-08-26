# Angular similarity via cosine

`similarity = (cos(2 * pi * error / period) + 1) / 2`, where `error` is
the circular distance between target and response on a circle of
circumference `period`. Returns 1 for a perfect match and 0 for a
maximally wrong answer, using the full \[0, 1\] range.

## Usage

``` r
score_angular(target, response, period)
```

## Arguments

- target, response:

  Numeric vectors of angles in degrees.

- period:

  Circumference of the angular space, in degrees.

## Value

Numeric vector in \[0, 1\].

## Choice of period

The two angular features have **different periods**, and were initially
treated as one case:

- **Colour** is a hue wheel: `period = 360`. Red at 5° and red at 355°
  are 10° apart, not 350°.

- **Orientation** is the tilt of a plain rectangle, which has 180°
  rotational symmetry: `period = 180`. A rectangle at +80° and one at
  -80° differ by 160° arithmetically but are only 20° apart as
  orientations, and both look near-horizontal. The response widget
  clamps to \[-90, 90\] (`normalizeAngle()` in `utils.js`), which is
  exactly one period.

Using `period = 360` for orientation would treat a 90° error —
perpendicular, the most wrong an orientation can be — as similarity 0.5
rather than 0, and would compress the observed range to \[0.13, 1\]. See
[`compute_scores()`](https://m-delem.github.io/aphantasiaWMStrats/reference/compute_scores.md)'s
`orientation_period` argument; this remains flagged for confirmation
against real distributions.
