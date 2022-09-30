
true

<!-- README.md is generated from README.Rmd. Please edit that file -->

# PLEIOVAR

<!-- badges: start -->
<!-- badges: end -->

The goal of PLEIOVAR is to measure the joint association between a set
of SNPs within each gene and a set of traits. By using principal
component analysis (PCA) on both traits and SNPs, we are able to perform
the joint association (based on a chi-squared distribution) resulting in
a fast and efficient estimation. In addition, the application of PCA
dimension reduction on PC-SNPs within a gene, sharply reduces the number
of degrees of freedom, thereby lowering the multiple testing burden and
revealing more candidate pleiotropic interactions. In addition, the
method can also be used to score a set of genes (perhaps within a
pathway), providing a more scalable scoring method than most software
applications which are mostly based on Fisher’s Exact Test, making the
method suited to detect pleiotropic enriched pathways.

## Installation

You can install the development version of PLEIOVAR from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("LEPSNES/PLEIOVAR")
```

## Required files

PLEIOVAR needs to two directories, one includes the compressed vcf files
and another includes gene bed file. The vcf files should be compressed,
chromosome-separated, and include chrom information in the file names in
the format “chr\[om\_\]\d+”, such as CARDIAstudy_chr20.vcf.gz, or
CARDIAstudy_chrom_20.vcf.gz. The gene bed files should include four
columns, “chrom”, “start”, “end”, “gene”, but has no title row, saved
with names like “chrom_i.bed”. The vcf and gene files have to both exist
to process a chromosome.

PLEIOVAR comes with exemplar vcf and gene files.

``` r
library(PLEIOVAR)
library(fs)
library(furrr)
#> Loading required package: future
library(tictoc)
library(tidyverse, quietly = TRUE)
#> ── Attaching packages
#> ───────────────────────────────────────
#> tidyverse 1.3.2 ──
#> ✔ ggplot2 3.3.6     ✔ purrr   0.3.4
#> ✔ tibble  3.1.8     ✔ dplyr   1.0.9
#> ✔ tidyr   1.2.0     ✔ stringr 1.4.0
#> ✔ readr   2.1.2     ✔ forcats 0.5.1
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
# Example vcf files
path_package("PLEIOVAR", "extdata", "vcf") |> 
  dir_ls()
#> /tmp/RtmpyoLrqo/temp_libpath3726b3534d40b2/PLEIOVAR/extdata/vcf/Sardinia.b37.ss2120.FAref.impv4.chr20.vcf.gz
#> /tmp/RtmpyoLrqo/temp_libpath3726b3534d40b2/PLEIOVAR/extdata/vcf/Sardinia.b37.ss2120.FAref.impv4.chr21.vcf.gz
#> /tmp/RtmpyoLrqo/temp_libpath3726b3534d40b2/PLEIOVAR/extdata/vcf/Sardinia.b37.ss2120.FAref.impv4.chr22.vcf.gz
# Example gene files
path_package("PLEIOVAR", "extdata", "gene") |> 
  dir_ls()
#> /tmp/RtmpyoLrqo/temp_libpath3726b3534d40b2/PLEIOVAR/extdata/gene/chrom_20.bed
#> /tmp/RtmpyoLrqo/temp_libpath3726b3534d40b2/PLEIOVAR/extdata/gene/chrom_21.bed
#> /tmp/RtmpyoLrqo/temp_libpath3726b3534d40b2/PLEIOVAR/extdata/gene/chrom_22.bed
```

## Workflow

### Genewise genotype

The chromosome level vcf file includes genotype for all the SNP
positions detected in a study. This step extracts the genotypes for
every gene based on the gene start and end positions defined in the bed
file. The function, `get_genewise_genotype()`, aligns the vcf and gene
files by chromosome and then call a shell script, which parallellize
[`vcftools`](https://vcftools.github.io/man_latest.html) using
[`GNU parallel`](https://www.gnu.org/software/parallel/) utility, to do
the genotype extraction.

The outputs are saved into *vcftools_out* and organized by chromosome
like *out_dir/chrom_i/vcftools_output*.

``` r
# Get the dir path
vcf_dir <- path_package("PLEIOVAR", "extdata", "vcf")
gene_dir <- path_package("PLEIOVAR", "extdata", "gene")
out_dir <- "result"
job_num <- 30
extension <- 50000
# Pull variants from vcf files
get_genewise_genotype(vcf_dir, gene_dir, out_dir, job_num, extension)
```

`job_num` indicate the number of CPU cores to pull genewise genotypes.
On Unix-like platform, `htop` shows the CPUs that are running the jobs.
`iostat -x 5` shows disk reading/writing per 5 seconds.

### Assembled files

`vcftools` generates three files for one gene, gene.012 including
individual x SNP genotype matrix, gene.012.indv including individual
IDs, and gene.012.pos including SNP positions. This steps unite the
three files into one [`tibble`](https://tibble.tidyverse.org/) and save
as `rds`.

The function, `unite_vcftools_output_one_chrom()`, takes as input the
directory holding vcftools outputs, and generates as outputs the united
`rds` files. It is internally parallized via
[`furrr`](https://furrr.futureverse.org/) package which makes use of
[`future`](https://future.futureverse.org/) framework.

The `rds` files are saved into *assembled_file* directory alongside
*vcftools_output*.

``` r
# Process one chrom
tic("One tst chrom")
d <- "/home/liz30/project/PLEIOVAR/PLEIOVAR_rpkg/result/chrom_20/vcftools_output"
plan(multisession, workers = 12)
unite_vcftools_output_one_chrom(
  vcftools_output = d
)
plan(sequential)
toc()
#> One tst chrom: 29.265 sec elapsed

# Process multiple chroms
# Set up workers. But use function walk(), not future_walk(), to avoid double paralleling at both chrom and gene levels.
tic("Multiple chroms")
assembled_dir <- "/home/liz30/project/PLEIOVAR/PLEIOVAR_rpkg/result"
plan(multisession, workers = 72)
dir_ls(assembled_dir, regexp = ".*chrom_[1-9].*") |>
path("vcftools_output") |>
    walk(function(chrom) {
      tic(chrom)
      unite_vcftools_output_one_chrom(chrom)
      toc()
     })
#> /home/liz30/project/PLEIOVAR/PLEIOVAR_rpkg/result/chrom_20/vcftools_output: 25.603 sec elapsed
#> /home/liz30/project/PLEIOVAR/PLEIOVAR_rpkg/result/chrom_21/vcftools_output: 1.298 sec elapsed
#> /home/liz30/project/PLEIOVAR/PLEIOVAR_rpkg/result/chrom_22/vcftools_output: 5.703 sec elapsed

plan(sequential)
toc()
#> Multiple chroms: 38.664 sec elapsed
```

### PC_SNP

One of the advantages PLEIOVAR bears is using the independent genotypes
of a gene to conduct genome-wide association study (GWAS), which is
achieved by project the genotype information from the original space to
principal components space. The function, `pc_snp_one_chrom()`, runs
principal component analysis (PCA), by calling `prcomp()`, and save the
eigenvalues, sometimes called lambda, into *eigenvalue* directory,
loading, sometimes called rotation, into *loading* directory, and score,
i.e., the rotated data, into *pc_snp_score* directory. All these three
directories are under *pc_snp*, which is alongside with
*vcftools_output* and *assembled_file*.

``` r
# Process one chrom
# Set up workers. Parallel framework, future, is called internally via furrr
tic("One chrom")
gene_bed_file <-  fs::path_package("PLEIOVAR", "extdata", "gene", "chrom_20.bed")
out_dir <-  "result"
plan(multisession, workers = 12)
pc_snp_one_chrom(gene_bed_file, out_dir)
plan(sequential)
toc()
#> One chrom: 12.852 sec elapsed

# Process multiple chroms
# Set up workers. But use function walk(), not future_walk(), to avoid double paralleling at both chrom and gene levels.
tic("Multiple chroms")
gene_bed_dir <-  fs::path_package("PLEIOVAR", "extdata", "gene")
out_dir <-  "result"
plan(multisession, workers = 12)
dir_ls(gene_bed_dir, regexp = ".*chrom_[1-9].*") |>
  walk(function(gene_bed_file) {
    tic(gene_bed_file)
    pc_snp_one_chrom(gene_bed_file, out_dir)
    toc()
  })
#> /tmp/RtmpyoLrqo/temp_libpath3726b3534d40b2/PLEIOVAR/extdata/gene/chrom_20.bed: 13.403 sec elapsed
#> /tmp/RtmpyoLrqo/temp_libpath3726b3534d40b2/PLEIOVAR/extdata/gene/chrom_21.bed: 1.108 sec elapsed
#> /tmp/RtmpyoLrqo/temp_libpath3726b3534d40b2/PLEIOVAR/extdata/gene/chrom_22.bed: 3.57 sec elapsed
plan(sequential)
toc()
#> Multiple chroms: 18.836 sec elapsed
```

## NOTE

The [Open Source Edition R studio
server](https://www.rstudio.com/products/workbench/comparison/) has a
limit of 4,096 for maximum open file descriptors, which causes an error
`ulimit:21: value exceeds hard limit` as recorded in `vcftools.log`. The
Professional Edition user can increase the limit by adding
`max-open-files = 1048576` to the file `/etc/rstudio/profiles`. See
`5.2 User and Group Profiles` in [Rstudio Server Administation
Guide](https://docs.rstudio.com/ide/server-pro/1.0.153/index.html) for
details. The limit can be checked at **Terminal** tab in a R session by
`ulimit -n` for soft limit and `ulimit -Hn` for hard limit. One
workaround is to run `R` in the terminal. Check the limit. If too small,
increase it by `ulimit -n 1000000`. If failed, adding the following two
lines to the file `/etc/security/limits.conf` – root privilege is
required. Sign out and back in, the limit will be updated.

    *                hard    nofile          1048576
    *                soft    nofile          1048576
