
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `randolist` <img src='man/figures/logo.png' align="right" width="200">

<!-- badges: start -->

[![](https://img.shields.io/badge/dev%20version-0.0.1.9000-blue.svg)](https://github.com/CTU-Bern/randolist)
[![R-CMD-check](https://github.com/CTU-Bern/randolist/workflows/R-CMD-check/badge.svg)](https://github.com/CTU-Bern/randolist/actions)

<!-- badges: end -->

`randolist` contains home-grown functions for creating randomisation
lists in R.

## Installation

You can install the development version of `randolist` from github with:

<!-- install.packages("randolist") -->

``` r
remotes::install_github("CTU-Bern/randolist")
```

<!-- Or from CTU Bern's package universe -->
<!-- ``` r -->
<!-- install.packages("randolist", repos = c('https://ctu-bern.r-universe.dev', 'https://cloud.r-project.org')) -->
<!-- ``` -->

## Generating randomization lists

Load the package

``` r
library(randolist)
```

### Unstratified randomization

Where no strata are defined, the `blockrand` function can be used to
create a randomization list.

``` r
blockrand(n = 10, 
          blocksizes = 1:2)
#>    seq_in_list block blocksize seq_in_block arm
#> 1            1     1         4            1   B
#> 2            2     1         4            2   B
#> 3            3     1         4            3   A
#> 4            4     1         4            4   A
#> 5            5     2         2            1   A
#> 6            6     2         2            2   B
#> 7            7     3         2            1   B
#> 8            8     3         2            2   A
#> 9            9     4         4            1   B
#> 10          10     4         4            2   A
#> 11          11     4         4            3   A
#> 12          12     4         4            4   B
```

The treatment label is set via the `arms` argument.

Block sizes are defined via the `blocksizes` argument. The above example
creates a randomization list with blocks of 1 or 2 *of each arm* (so in
practice, the block sizes are 2 and 4).

Allocation schemes beyond 1:1 randomization are possible by specifying
the `arms` argument, specifically by using the same arm label multiple
times.

``` r
blockrand(n = 10, 
          blocksizes = 1:2,
          arms = c("A", "A", "B"))
#>    seq_in_list block blocksize seq_in_block arm
#> 1            1     1         3            1   A
#> 2            2     1         3            2   B
#> 3            3     1         3            3   A
#> 4            4     2         6            1   A
#> 5            5     2         6            2   A
#> 6            6     2         6            3   A
#> 7            7     2         6            4   B
#> 8            8     2         6            5   A
#> 9            9     2         6            6   B
#> 10          10     3         6            1   A
#> 11          11     3         6            2   B
#> 12          12     3         6            3   A
#> 13          13     3         6            4   A
#> 14          14     3         6            5   A
#> 15          15     3         6            6   B
```
