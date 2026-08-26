# Participants clearing the engagement thresholds

Participants clearing the engagement thresholds

## Usage

``` r
engaged_ids(data, thresholds = wm_thresholds())
```

## Arguments

- data:

  Item-level data, typically `get_data("v1")` filtered to the test
  blocks.

- thresholds:

  Named integer vector, defaults to
  [`wm_thresholds()`](https://m-delem.github.io/aphantasiaWMStrats/reference/wm_thresholds.md).

## Value

A character vector of participant ids clearing every threshold.
