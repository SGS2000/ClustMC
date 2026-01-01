# Jolliffe test for multiple comparisons

I.T. Jolliffe test for multiple comparisons. Implements a cluster-based
alternative closely linked to the Student-Newman-Keuls multiple
comparison method. Single-linkage cluster analysis is applied, using the
p-values obtained with the SNK test for pairwise mean comparison as a
similarity measure. Groups whose means join beyond \\1 - \alpha\\ are
statistically different. Alternatively, complete linkage cluster
analysis can also be applied.

## Usage

``` r
jolliffe_test(
  y,
  trt,
  alpha = 0.05,
  method = "single",
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

- method:

  `string` indicating the clustering method to be used. For single
  linkage (the default method) either `"single"` or `"slca"`. For
  complete linkage, either `"complete"` or `"clca"`.

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
  `n` is either the number of repetitions for all treatments or the
  harmonic mean of said repetitions, `MSE` is the mean standard error
  from the ANOVA table and `SEM` is an estimate of the standard error of
  the mean.

- dendrogram_data:

  object of class `hclust` with data used to build the dendrogram.

## References

Jolliffe, I. T. (1975). Cluster analysis as a multiple comparison
method. *Applied Statistics: Proceedings of Conference at Dalhousie
University, Halifax*, 159-168.

## Author

Santiago Garcia Sanchez

## Examples

``` r
data("PlantGrowth")
# Using vectors -------------------------------------------------------
weights <- PlantGrowth$weight
treatments <- PlantGrowth$group
jolliffe_test(y = weights, trt = treatments, alpha = 0.1, show_plot = FALSE)
#>      group
#> trt1     1
#> ctrl     1
#> trt2     2
#> Treatments within the same group are not significantly different
# Using a model -------------------------------------------------------
model <- lm(weights ~ treatments)
jolliffe_test(y = model, trt = "treatments", alpha = 0.1, show_plot = FALSE)
#>      group
#> trt1     1
#> ctrl     1
#> trt2     2
#> Treatments within the same group are not significantly different
```
