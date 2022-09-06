


#' Process genes in one chrom
#'
#' Paralelly unite the three vcftool files of one gene into one rds for all genes on one chrom by calling the one gene processing function
#' unite_vcftools_output_one_gene().
#'
#' @param vcftools_output Dir path storing assembled files output by vcftools
#'
#' @return The exit status of future_walk function
#' @export
#'
#' @examples
#'
#' # Process one chrom
#' tic("One tst chrom")
#' d <- "result/chrom_20/vcftools_output"
#' plan(multisession, workers = 12)
#' unite_vcftools_output_one_chrom(
#'   vcftools_output = d
#' )
#' plan(sequential)
#' toc()
#'
#' # Process multiple chroms
#' # Set up workers. But use function walk(), not future_walk(), to avoid double paralleling at both chrom and gene levels.
#' tic("Multiple chroms")
#' assembled_dir <- "result"
#' plan(multisession, workers = 72)
#' dir_ls(assembled_dir, regexp = ".*chrom_[1-9].*") |>
#'   path("vcf_output") |>
#'     walk(function(chrom) {
#'       tic(chrom)
#'       unite_vcftools_output_one_chrom(chrom)
#'       toc()
#'      })
#'
#' plan(sequential)
#' toc()
#'
#'
unite_vcftools_output_one_chrom <-
  function(vcftools_output = "result/chrom_20/vcftools_output") {
    vcftools_output |>
      # Get the list of files with "012" in the name
      fs::dir_ls(glob = "*012*") |>
      # Get gene name
      purrr::map_chr( ~ stringr::str_remove(fs::path_file(.x), ".012$|.012.indv$|.012.pos$")) |>
      # Get uniqe genes, since each gene has three files
      unique() |>
      furrr::future_walk(
        ~ PLEIOVAR::unite_vcftools_output_one_gene(vcftools_output = vcftools_output,
                                                   gene = .x)
      )
  }

