


#' Process genes in one chrom
#'
#' Paralelly unite the three vcftool files of one gene into one rds for all genes on one chrom by calling the one gene processing function
#' unite_three_vcf_output_files_of_one_gene().
#'
#' @param assembled_dir_one_chrom Dir path storing assembled files output by vcftools
#'
#' @return The exit status of future_walk function
#' @export
#'
#' @examples
#'
#' # Process one chrom
#' tic("One tst chrom")
#' d <- "tmpout/chrom_20/vcf_output"
#' plan(multisession, workers = 12)
#' cycle_through_genes_one_chrom(
#'   assembled_dir_one_chrom = d
#' )
#' plan(sequential)
#' toc()
#'
#' # Process multiple chroms
#' tic("Multiple chroms")
#' assembled_dir <- "tmpout"
#' plan(multisession, workers = 72)
#' dir_ls(assembled_dir, regexp = ".*chrom_[1-9].*") |>
#'   path("vcf_output") |>
#'     walk(function(chrom) {
#'       tic(chrom)
#'       cycle_through_genes_one_chrom(chrom)
#'       toc()
#'      })
#'
#' plan(sequential)
#' toc()
#'
#'
#'
cycle_through_genes_one_chrom <- function(assembled_dir_one_chrom = "tmpout/chrom_20/vcf_output") {
  assembled_dir_one_chrom |>
    # Get the list of files with "012" in the name
    fs::dir_ls(glob = "*012*") |>
    # Get gene name
    # purrr::map_chr(~ str_extract(path_file(.x), "[^.]+")) |>
    purrr::map_chr(~ stringr::str_remove(fs::path_file(.x), ".012$|.012.indv$|.012.pos$")) |>
    # Get uniqe genes, since each gene has three files
    unique() |>
    furrr::future_walk(
      ~ PLEIOVAR::unite_three_vcf_output_files_of_one_gene(
        assembled_dir_one_chrom = assembled_dir_one_chrom,
        gene = .x
      )
    )
}

