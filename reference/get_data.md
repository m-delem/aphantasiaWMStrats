# Get CFA-WM data, optionally filtered by version

Convenience accessor for
[all_data](https://m-delem.github.io/aphantasiaWMStrats/reference/all_data.md).
Returns the full combined dataset by default, or a subset restricted to
one or more study versions.

## Usage

``` r
get_data(version = "all", data = aphantasiaWMStrats::all_data)
```

## Arguments

- version:

  Character vector. One or more of `"v1"`, `"v2"`, `"v3"`, or `"all"`
  (the default). `"all"` is equivalent to `c("v1", "v2", "v3")` and
  cannot be combined with the others.

- data:

  Internal. The data frame to filter; defaults to
  [all_data](https://m-delem.github.io/aphantasiaWMStrats/reference/all_data.md)
  and is not meant to be set by end users. Exposed as an argument
  (rather than referencing
  [all_data](https://m-delem.github.io/aphantasiaWMStrats/reference/all_data.md)
  directly in the function body) so the filtering/validation logic can
  be tested against a small synthetic stand-in without touching the real
  package data.

## Value

A tibble with the same columns as
[all_data](https://m-delem.github.io/aphantasiaWMStrats/reference/all_data.md),
filtered to the requested version(s).

## Examples

``` r
get_data()
#> # A tibble: 8,614 × 69
#>    id                version language   age gender vviq_total_score vviq_group_2
#>    <chr>             <chr>   <chr>    <int> <chr>             <int> <chr>       
#>  1 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#>  2 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#>  3 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#>  4 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#>  5 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#>  6 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#>  7 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#>  8 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#>  9 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#> 10 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#> # ℹ 8,604 more rows
#> # ℹ 62 more variables: vviq_group_4 <chr>, nieq_mental_imagery <dbl>,
#> #   nieq_inner_voice <dbl>, nieq_emotions <dbl>, nieq_sensory_focus <dbl>,
#> #   nieq_unsymbolised <dbl>, object_mean <dbl>, spatial_mean <dbl>,
#> #   verbal_mean <dbl>, expe_phase <chr>, trial_number <int>,
#> #   response_order <chr>, item_number <int>, target_word <chr>,
#> #   target_angle <int>, target_color_angle <dbl>, target_color <chr>, …
get_data(version = "v3")
#> # A tibble: 1,533 × 69
#>    id                version language   age gender vviq_total_score vviq_group_2
#>    <chr>             <chr>   <chr>    <int> <chr>             <int> <chr>       
#>  1 mnva884126606547… v3      fr          47 f                    76 typical     
#>  2 mnva884126606547… v3      fr          47 f                    76 typical     
#>  3 mnva884126606547… v3      fr          47 f                    76 typical     
#>  4 mnva884126606547… v3      fr          47 f                    76 typical     
#>  5 mnva884126606547… v3      fr          47 f                    76 typical     
#>  6 mnva884126606547… v3      fr          47 f                    76 typical     
#>  7 mnva884126606547… v3      fr          47 f                    76 typical     
#>  8 mnva884126606547… v3      fr          47 f                    76 typical     
#>  9 mnva884126606547… v3      fr          47 f                    76 typical     
#> 10 mnva884126606547… v3      fr          47 f                    76 typical     
#> # ℹ 1,523 more rows
#> # ℹ 62 more variables: vviq_group_4 <chr>, nieq_mental_imagery <dbl>,
#> #   nieq_inner_voice <dbl>, nieq_emotions <dbl>, nieq_sensory_focus <dbl>,
#> #   nieq_unsymbolised <dbl>, object_mean <dbl>, spatial_mean <dbl>,
#> #   verbal_mean <dbl>, expe_phase <chr>, trial_number <int>,
#> #   response_order <chr>, item_number <int>, target_word <chr>,
#> #   target_angle <int>, target_color_angle <dbl>, target_color <chr>, …
get_data(version = c("v1", "v2"))
#> # A tibble: 7,081 × 69
#>    id                version language   age gender vviq_total_score vviq_group_2
#>    <chr>             <chr>   <chr>    <int> <chr>             <int> <chr>       
#>  1 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#>  2 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#>  3 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#>  4 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#>  5 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#>  6 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#>  7 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#>  8 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#>  9 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#> 10 aacu640913909790… v1      fr          41 f                    16 aphantasia  
#> # ℹ 7,071 more rows
#> # ℹ 62 more variables: vviq_group_4 <chr>, nieq_mental_imagery <dbl>,
#> #   nieq_inner_voice <dbl>, nieq_emotions <dbl>, nieq_sensory_focus <dbl>,
#> #   nieq_unsymbolised <dbl>, object_mean <dbl>, spatial_mean <dbl>,
#> #   verbal_mean <dbl>, expe_phase <chr>, trial_number <int>,
#> #   response_order <chr>, item_number <int>, target_word <chr>,
#> #   target_angle <int>, target_color_angle <dbl>, target_color <chr>, …
```
