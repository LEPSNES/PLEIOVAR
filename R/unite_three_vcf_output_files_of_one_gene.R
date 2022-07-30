


#' Unite the three output files of vcftools of one gene
#'
#' Three files are output by vcftools for each gene, gene.012 containing individual x SNP matrix, gene.012.indv containing
#' individual IDs in one column, gene.012.pos containing chrom and SNP coordinate in two columns
#'
#' @param assembled_dir_one_chrom  Dir path storing assembled files output by vcftools
#' @param gene character, the name of a single gene
#'
#' The assembled dir path should follow the rule parent_dirs/vcf_output. The three files of a gene will be located according to the
#' naming rule mentioned above. The united file is saved as rds at parent_dirs/rds and create this dir if it has not existed. The genes
#' with zero SNPs are not converted to rds.
#'
#' @return The status of write_rds function
#' @export
#'
#' @examples
#' # The rds file is saved at "../../assembled/variants_by_gene/chrom_tst/rds"
#' d <- path_package("PLEIOVAR") |>
#'   path_dir() |>
#'   path("../assembled/variants_by_gene/chrom_tst/vcf_output")
#'
#' unite_three_vcf_output_files_of_one_gene(
#'     assembled_dir_one_chrom = d,
#'     gene = "ABCC13"
#'   )
#'
#' # Gene "MIR155" has no SNPs, so no rds file saved
#' unite_three_vcf_output_files_of_one_gene(
#'     assembled_dir_one_chrom = d,
#'     gene = "MIR155"
#'   )
#'
#'

unite_three_vcf_output_files_of_one_gene <- function(
    assembled_dir_one_chrom = "../../assembled/variants_by_gene/chrom_21",
    gene = "ABCC13"
) {
  # Get variant position
  posi <-
    readr::read_tsv(
      file = fs::path(assembled_dir_one_chrom, gene, ext = "012.pos"),
      col_names = c("chrom", "posi"),
      col_types = readr::cols(
        .default = readr::col_integer()
      )
    )

  if (nrow(posi) > 0) { # The gene has > 0 SNPs
    # Get individual ID
    indv <-
      readr::read_tsv(
        file = fs::path(assembled_dir_one_chrom, gene, ext = "012.indv"),
        col_names = c("id"),
        col_types = readr::cols(
          .default = readr::col_integer()
        )
      )
    # Read in variant data with column name as variant position
    # Attach individual ID
    d <-
      readr::read_tsv(
        file = fs::path(assembled_dir_one_chrom, gene, ext = "012"),
        col_names = c("order", as.character(posi$posi)),
        col_select = -1, # Remove the first "order" column
        col_types = readr::cols(
          .default = readr::col_integer()
        )
      ) |>
      dplyr::mutate( # Add inidividual id as the first column
        id = indv$id,
        .before = 1
      )

    # Save as rds
    # rds_out_dir = fs::path(assembled_dir_one_chrom, "rds")
    rds_out_dir <-
      assembled_dir_one_chrom |>
      fs::path_dir() |>
      fs::path("rds")
    if (!fs::dir_exists(rds_out_dir)) fs::dir_create(rds_out_dir)
    readr::write_rds(d, file = fs::path(rds_out_dir, gene, ext = "rds"))
  }
}



