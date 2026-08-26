# The compositional model

Both ILR coordinates in one model with residual correlation estimated.
That is not cosmetic: any two-coordinate ILR basis is a rotation of the
same geometry, and the omnibus test and total variance are invariant to
the choice of partition only when the coordinates are fitted jointly
with `rescor` on. Two separate univariate fits lose that.

Given as two `bf()` calls rather than through `mvbind()`, which has to
be resolved from inside the formula and is fragile when the formula is
built from a string and brms is not attached.

## Usage

``` r
composition_formula(rhs)
```

## Arguments

- rhs:

  Right-hand side terms as a single string, for example
  `"vviq + complete_aphant + parity_rate"`.

## Value

A `brmsformula` object.
