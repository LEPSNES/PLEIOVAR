


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
#' # d <- path_package("PLEIOVAR") |>
#' #   path_dir() |>
#' #   path("../assembled/variants_by_gene/chrom_tst/vcf_output")
#' d <- "~/project/PLEIOVAR/assembled/variants_by_gene/chrom_tst/vcf_output"
#' plan(multisession, workers = 12)
#' cycle_through_genes_one_chrom(
#'   assembled_dir_one_chrom = d
#' )
#' plan(sequential)
#' toc()
#'
#' # Process multiple chroms
#' tic("Two tst chrom")
#' # assembled_dir <- path_package("PLEIOVAR") |>
#' #   path_dir() |>
#' #   path("../assembled/variants_by_gene")
#' assembled_dir <- "~/project/PLEIOVAR/assembled/variants_by_gene"
#' plan(multisession, workers = 72)
#' # dir_ls(assembled_dir, regexp = ".*chrom_[1-9].*") |>  # Uncomment this line to process chrom 1 through 22
#' dir_ls(assembled_dir, regexp = ".*chrom_tst.*") |>
#'   path("vcf_output") |>
#'   map(cycle_through_genes_one_chrom)
#'
#' plan(sequential)
#' toc()
#'
#'
#'
cycle_through_genes_one_chrom <- function(assembled_dir_one_chrom = "../../assembled/variants_by_gene/chrom_tst/vcf_output") {
  assembled_dir_one_chrom |>
    fs::dir_ls(glob = "*012*") |>
    purrr::map_chr(~ str_extract(path_file(.x), "[^.]+")) |>
    unique() |>
    # head(n=60) |>
    furrr::future_walk(
      ~ PLEIOVAR::unite_three_vcf_output_files_of_one_gene(
        assembled_dir_one_chrom = assembled_dir_one_chrom,
        gene = .x
      )
    )
}

