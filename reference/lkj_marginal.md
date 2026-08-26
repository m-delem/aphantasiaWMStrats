# Marginal prior on a single correlation under an LKJ prior

`lkj(eta)` is a prior on a whole correlation matrix, so "how strong is
it" is not answerable without fixing the dimension. The marginal on any
one off-diagonal element is `Beta(a, a)` rescaled to (-1, 1), with
`a = eta + (d - 2) / 2`.

Use it to check which correlations actually moved off their prior. A
posterior no narrower than this is not a finding, and with 15
correlations some of them will not be.

## Usage

``` r
lkj_marginal(n, eta, dimension)
```

## Arguments

- n:

  Number of draws.

- eta:

  The LKJ shape parameter.

- dimension:

  The size of the correlation matrix.

## Value

A numeric vector of draws on (-1, 1).

## References

Lewandowski, D., Kurowicka, D., & Joe, H. (2009). Generating random
correlation matrices based on vines and extended onion method. *Journal
of Multivariate Analysis*, 100(9), 1989-2001.

## Examples

``` r
stats::sd(lkj_marginal(1e4, eta = 4, dimension = 6))
#> [1] 0.2750162
```
