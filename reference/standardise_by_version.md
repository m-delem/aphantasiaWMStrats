# Z-score columns within version, using experimental-block moments

Z-score columns within version, using experimental-block moments

## Usage

``` r
standardise_by_version(data, cols)
```

## Arguments

- data:

  Frame carrying `version` and `expe_phase`.

- cols:

  Character vector of columns to standardise; each gains a `_z`
  counterpart.

## Value

`data` with the `_z` columns appended.
