# Minimum responded items per feature

A participant contributes to a feature only if the standard error of
their mean is at most half the between-person SD. That criterion needs
22 responded items for orientation and 29 for colour. For word it asks
for 93 of the 63 items that exist, because word's between-person
variance is small relative to its item-level noise, so word falls back
to a floor of 32 responded items. That floor is a data-sufficiency rule
and **not** a precision guarantee: no achievable item count makes a
participant's word mean precise enough to rank against another's.

Hard-coded rather than recomputed, because the rule was fixed before any
contact with VVIQ and must not drift with the sample it is applied to.

## Usage

``` r
wm_thresholds()
```

## Value

A named integer vector, one threshold per feature.
