# Loaf volumes from a bread-baking experiment

Includes the volumes (ml) of 85 loaves of bread made under controlled
conditions from 100-gram batches of dough made with 17 different
varieties of wheat flour and 5 levels of potassium bromate (mg).

## Usage

``` r
bread
```

## Format

A tibble with 85 rows and 3 columns:

- variety:

  a factor indicating the variety of flour used.

- bromate:

  a number denoting the amount of potassium bromate used (milligrams).

- volume:

  a number denoting the volume of the loaf made under each condition
  (milliliters).

## Source

Larmour, R. K. (1941). A comparison of hard red spring and hard red
winter wheats. *Cereal Chemistry, 18*(6), 778-789. Available at:
<https://archive.org/details/sim_cereal-chemistry_1941-11_18_6>

## Details

Data from a bread-baking experiment by Larmour (1941). Later reproduced
by Scheffe (1959) and then used by Duncan (1965) to contrast different
multiple comparison methods. Jolliffe (1975) applies this dataset to
illustrate his cluster-based test.

## References

Duncan, D. B. (1965). A bayesian approach to multiple comparisons.
*Technometrics, 7*(2), 171-222.
[doi:10.2307/1266670](https://doi.org/10.2307/1266670)

Jolliffe, I. T. (1975). Cluster analysis as a multiple comparison
method. *Applied Statistics: Proceedings of Conference at Dalhousie
University, Halifax*, 159-168.

Scheffe, H. (1950).*The analysis of variance*. Wiley-Interscience
Publication.

## Examples

``` r
data(bread)
summary(bread)
#>     variety      bromate      volume      
#>  A      : 5   Min.   :0   Min.   : 615.0  
#>  B      : 5   1st Qu.:1   1st Qu.: 795.0  
#>  C      : 5   Median :2   Median : 870.0  
#>  D      : 5   Mean   :2   Mean   : 868.6  
#>  E      : 5   3rd Qu.:3   3rd Qu.: 955.0  
#>  F      : 5   Max.   :4   Max.   :1075.0  
#>  (Other):55                               
```
