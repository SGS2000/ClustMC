# Nitrogen content of red clover plants

Includes the nitrogen content (mg) of 30 red clover plants inoculated
with one of four single-strain cultures of *Rhizobium trifolii* or a
composite of five *Rhizobium meliloti* strains, resulting in six
treatments in total.

## Usage

``` r
clover
```

## Format

A tibble with 30 rows and 2 columns:

- treatment:

  a factor denoting the treatment applied to each plant.

- nitrogen:

  a number denoting the nitrogen content of each plant (milligrams).

## Source

Steel, R., & Torrie, J. (1980). *Principles and procedures of
statistics: A biometrical approach (2nd ed.)*. San Francisco:
McGraw-Hill. Available at:
<https://archive.org/details/principlesproce00stee>

## Details

Data originally from an experiment by Erdman (1946), conducted in a
greenhouse using a completely random design. The current dataset was
presented by Steel and Torrie (1980) and later used by Bautista et al.
(1997) to illustrate their proposed procedure.

## References

Bautista, M. G., Smith, D. W., & Steiner, R. L. (1997). A Cluster-Based
Approach to Means Separation. *Journal of Agricultural, Biological, and
Environmental Statistics, 2*(2), 179-197.
[doi:10.2307/1400402](https://doi.org/10.2307/1400402)

Erdman, L. W. (1946). Studies to determine if antibiosis occurs among
rhizobia. *Journal of the American Society of Agronomy, 38*, 251-258.
[doi:10.2134/agronj1946.00021962003800030005x](https://doi.org/10.2134/agronj1946.00021962003800030005x)

## Examples

``` r
data(clover)
summary(clover)
#>      treatment    nitrogen    
#>  3DOk1    :5   Min.   : 9.10  
#>  3DOk13   :5   1st Qu.:16.07  
#>  3DOk4    :5   Median :19.25  
#>  3DOk5    :5   Mean   :19.89  
#>  3DOk7    :5   3rd Qu.:23.48  
#>  Composite:5   Max.   :33.00  
```
