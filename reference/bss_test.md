# Bautista, Smith and Steiner test for multiple comparisons

Bautista, Smith and Steiner (BSS) test for multiple comparisons.
Implements a procedure for grouping treatments following the
determination of differences among them. First, a cluster analysis of
the treatment means is performed and the two closest means are grouped.
A nested analysis of variance from the original ANOVA is then
constructed with the treatment source now partitioned into "groups" and
"treatments within groups". This process is repeated until there are no
differences among the group means or there are differences among the
treatments within groups.

## Usage

``` r
bss_test(
  y,
  trt,
  alpha = 0.05,
  show_plot = TRUE,
  console = TRUE,
  abline_options,
  ...
)
```

## Arguments

- y:

  Either a model (created with [`lm()`](https://rdrr.io/r/stats/lm.html)
  or [`aov()`](https://rdrr.io/r/stats/aov.html)) or a numerical vector
  with the values of the response variable for each unit.

- trt:

  If `y` is a model, a string with the name of the column containing the
  treatments. If `y` is a vector, a vector of the same length as `y`
  with the treatments for each unit.

- alpha:

  Numeric value corresponding to the significance level of the test. The
  default value is 0.05.

- show_plot:

  Logical value indicating whether the constructed dendrogram should be
  plotted or not.

- console:

  Logical value indicating whether the results should be printed on the
  console or not.

- abline_options:

  `list` with optional arguments for the line in the dendrogram.

- ...:

  Optional arguments for the
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) function.

## Value

A list with three `data.frame` and one `hclust`:

- stats:

  `data.frame` containing summary statistics by treatment.

- groups:

  `data.frame` indicating the group to which each treatment is assigned.

- parameters:

  `data.frame` with the values used for the test. `treatments` is the
  total number of treatments and `alpha` is the significance level used.

- dendrogram_data:

  object of class `hclust` with data used to build the dendrogram.

## References

Bautista, M. G., Smith, D. W., & Steiner, R. L. (1997). A Cluster-Based
Approach to Means Separation. *Journal of Agricultural, Biological, and
Environmental Statistics, 2*(2), 179-197.
[doi:10.2307/1400402](https://doi.org/10.2307/1400402)

## Author

Santiago Garcia Sanchez

## Examples

``` r
data("PlantGrowth")
# Using vectors -------------------------------------------------------
weights <- PlantGrowth$weight
treatments <- PlantGrowth$group
bss_test(y = weights, trt = treatments, show_plot = FALSE)
#> # A tibble: 3 × 2
#>   treatment group
#>   <fct>     <dbl>
#> 1 trt1          1
#> 2 ctrl          1
#> 3 trt2          2
#> Treatments within the same group are not significantly different
# Using a model -------------------------------------------------------
model <- lm(weights ~ treatments)
bss_test(y = model, trt = "treatments", show_plot = FALSE)
#> # A tibble: 3 × 2
#>   treatment group
#>   <fct>     <dbl>
#> 1 trt1          1
#> 2 ctrl          1
#> 3 trt2          2
#> Treatments within the same group are not significantly different
```
