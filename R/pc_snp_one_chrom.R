#' Paralelly generate pc_snp for each gene of one chrom
#'
#' Genes are read from a chrom bed file, remove the ones without the corresponding assembled file, which is stored at
#' out_dir/chrom/gene_name.rds, and paralelly generate pc snps for all the genes using future framework via furrr package.
#'
#' @param gene_bed_file Include genes from one chrom with 4 columns "chr", "start", "end", "gene".
#' @param out_dir  The directory containing the outputs of different steps, and at least chrom-partitioned assembled files
#'
#' @return The exit status of future_walk function
#' @export
#'
#' @examples
#'
#' # Process one chrom
#' # Set up workers. Parallel framework, future, is called internally via furrr
#' tic("One chrom")
#' gene_bed_file <-  fs::path_package("PLEIOVAR", "extdata", "gene", "chrom_20.bed")
#' out_dir <-  "result"
#' plan(multisession, workers = 12)
#' pc_snp_one_chrom(gene_bed_file, out_dir)
#' plan(sequential)
#' toc()
#'
#' # Process multiple chroms
#' # Set up workers. But use function walk(), not future_walk(), to avoid double paralleling at both chrom and gene levels.
#' tic("Multiple chroms")
#' gene_bed_dir <-  fs::path_package("PLEIOVAR", "extdata", "gene")
#' out_dir <-  "result"
#' plan(multisession, workers = 12)
#' dir_ls(gene_bed_dir, regexp = ".*chrom_[1-9].*") |>
#'   walk(function(gene_bed_file) {
#'     tic(gene_bed_file)
#'     pc_snp_one_chrom(gene_bed_file, out_dir)
#'     toc()
#'   })
#' plan(sequential)
#' toc()
#'
pc_snp_one_chrom <- function(
    gene_bed_file = fs::path_package("PLEIOVAR", "extdata", "gene", "chrom_20.bed"),
    out_dir = "result"
){

  chrom <- stringr::str_extract(gene_bed_file, "chrom_\\d+")
  assembled_dir <- fs::path(out_dir, chrom, "assembled_file")
  pc_snp_dir <- fs::path(out_dir, chrom, "pc_snp")
  # Read in gene bed
  gene_bed <-
    readr::read_delim(gene_bed_file, col_names = FALSE, show_col_types=FALSE) %>%  # Read in
    rlang::set_names(c("chr", "start", "end", "gene")) |>                          # Set column name
    dplyr::filter(fs::file_exists(fs::path(assembled_dir, gene, ext = "rds")))   # Only keep the genes that has correspoding assembled file
  # Parallelly processing
  gene_bed$gene |>
    furrr::future_walk(
      pc_snp_one_gene,
      assembled_dir,
      pc_snp_dir,
      .options = furrr_options(seed = TRUE)
    )
}



