# Normalise a string for edit-distance comparison

Lowercases, strips all whitespace, and removes diacritics by decomposing
to NFKD and dropping combining marks. This deliberately mirrors the
front end's preprocessing (`plugin-colored-rotated-label-feedback.js`),
so that the only difference between
[`score_word()`](https://m-delem.github.io/aphantasiaWMStrats/reference/score_word.md)
and the task's own live feedback is the distance metric itself, not the
input handling.

## Usage

``` r
normalise_word(x)
```

## Arguments

- x:

  Character vector.

## Value

Character vector, normalised. `NA` in, `NA` out.
