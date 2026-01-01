# Di Rienzo, Guzman and Casanoves test for multiple comparisons

Di Rienzo, Guzman and Casanoves (DGC) test for multiple comparisons.
Implements a cluster-based method for identifying groups of
nonhomogeneous means. Average linkage clustering is applied to a
distance matrix obtained from the sample means. The distribution of
\\Q\\ (distance between the source and the root node of the tree) is
used to build a test with a significance level of \\\alpha\\. Groups
whose means join above \\c\\ (the \\\alpha\\-level cut-off criterion)
are statistically different.

## Usage

``` r
dgc_test(
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

  Value equivalent to 0.05 or 0.01, corresponding to the significance
  level of the test. The default value is 0.05.

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
  total number of treatments, `alpha` is the significance level used,
  `c` is the cut-off criterion for the dendrogram (the height of the
  horizontal line on the dendrogram), `q` is the \\1 - \alpha\\ quantile
  of the distribution of \\Q\\ (distance from the root node) under the
  null hypothesis and `SEM` is an estimate of the standard error of the
  mean.

- dendrogram_data:

  object of class `hclust` with data used to build the dendrogram.

## References

Di Rienzo, J. A., Guzman, A. W., & Casanoves, F. (2002). A
Multiple-Comparisons Method Based on the Distribution of the Root Node
Distance of a Binary Tree. *Journal of Agricultural, Biological, and
Environmental Statistics, 7*(2), 129-142. \<jstor.org/stable/1400690\>

## Author

Santiago Garcia Sanchez

## Examples

``` r
data("PlantGrowth")
# Using vectors -------------------------------------------------------
weights <- PlantGrowth$weight
treatments <- PlantGrowth$group
dgc_test(y = weights, trt = treatments, show_plot = FALSE)
#>      group
#> ctrl     1
#> trt1     1
#> trt2     2
#> Treatments within the same group are not significantly different
# Using a model -------------------------------------------------------
model <- lm(weights ~ treatments)
dgc_test(y = model, trt = "treatments", show_plot = FALSE)
#>      group
#> ctrl     1
#> trt1     1
#> trt2     2
#> Treatments within the same group are not significantly different
```
