# Smithson-Verkuilen squeeze

Beta has zero density at exactly 0 and 1, so a single boundary value
gives the likelihood a zero and the fit errors rather than degrades.
Smithson and Verkuilen (2006) pull the whole variable a hair inside the
open interval:

\$\$y' = \frac{y(n-1) + 0.5}{n}\$\$

Monotone, order-preserving, and on this data it moves every value by
about one ten-thousandth. Use it where the boundary mass is a
measurement artifact; use an inflation component where it is real.

## Usage

``` r
squeeze_boundaries(x, n = sum(!is.na(x)))
```

## Arguments

- x:

  A numeric vector on \[0, 1\].

- n:

  The sample size to scale by. Defaults to the number of non-missing
  values in `x`, which is the usual choice.

## Value

`x`, squeezed into the open interval.

## References

Smithson, M., & Verkuilen, J. (2006). A better lemon squeezer?
Maximum-likelihood regression with beta-distributed dependent variables.
*Psychological Methods*, 11(1), 54-71.
