
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PLEIOVAR

<!-- badges: start -->
<!-- badges: end -->

The goal of PLEIOVAR is to …

## Installation

You can install the development version of PLEIOVAR from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("LEPSNES/PLEIOVAR")
```

## Example

This is a basic example which shows you how to solve a common problem:

### PC-SNP

This is one step of PLEIOVAR pipeline to generate genewise principle
components.

``` r
library(PLEIOVAR)
infolder <- system.file("extdata", "pc_snp", package = "PLEIOVAR")
outfolder <- "dev/func_output"
OPF_snp <-  0.75
freq_cut <-  0.005
block_name <-  "blocktest"
pc_snp(infolder, outfolder, OPF_snp, freq_cut, block_name)
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene1_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene2_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene3_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene4_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene5_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene6_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene7_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene8_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene9_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene10_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene11_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene12_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene13_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene14_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene15_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene16_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene17_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene18_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene19_assembled"
#> [1] "/tmp/RtmpsBlE2z/temp_libpathbe3a57cb569ca/PLEIOVAR/extdata/pc_snp/Assemble/gene20_assembled"
```

To get help

``` r
?pc_snp
```
