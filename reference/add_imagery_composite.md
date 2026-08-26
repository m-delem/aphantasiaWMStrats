# Collapse the imagery scales into one composite

Three instruments here measure imagery vividness in three different
formats: VVIQ, OSIVQ's object subscale, and NIEQ's mental-imagery
dimension. In this sample they correlate around 0.86 with each other
against 0.15 to 0.38 for the other OSIVQ subscales, giving an alpha near
0.97. That is one construct measured three ways.

Left separate they would **triple-weight imagery** in any distance
metric, so a clustering would find imagery groups by construction and
the exploratory strand could not say anything the confirmatory strand
did not. Collapsing them is what makes "is there structure beyond
vividness" answerable.

## Usage

``` r
add_imagery_composite(
  scales,
  components = c("vviq", "osivq_object", "nieq_imagery")
)
```

## Arguments

- scales:

  A standardised frame from
  [`standardise_scales()`](https://m-delem.github.io/aphantasiaWMStrats/reference/standardise_scales.md).

- components:

  Which columns form the composite.

## Value

The frame with the components replaced by `imagery`.
