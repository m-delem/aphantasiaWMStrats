# Damerau-Levenshtein distance (optimal string alignment)

Local implementation rather than a `stringdist` dependency, consistent
with this project's preference for self-contained code with the
reasoning attached. Also unit-testable against known values, which
matters here: the front end's own edit distance turned out to be broken
(see
[all_data](https://m-delem.github.io/aphantasiaWMStrats/reference/all_data.md)),
and the failure was invisible precisely because nothing tested it.

## Usage

``` r
damerau_levenshtein(a, b)
```

## Arguments

- a, b:

  Single strings.

## Value

Integer distance. `NA` if either input is `NA`.

## Details

This is the *restricted* variant (optimal string alignment): adjacent
transpositions cost 1, but a substring may not be edited more than once.
For single short words the restricted and unrestricted variants agree
except in contrived cases, and Gonthier (2022) does not distinguish
them.
