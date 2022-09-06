#' Extend the gene range for a bed file
#'
#' The bed file should have four columns, "chrom", "start", "end", "gene", but has no column names.
#'
#' @param gene_bed_file    The original gene bed file path
#' @param gene_extended_dir The directory to store the extended bed file
#' @param extension   An integer, extend equal amount at both sides, start - extension and end + extension
#'
#' @return The path to the extended bed file
#' @export
#'
#' @examples
#'
#' # Store the extended gene bed file in a temp directory
#' gene_extended_dir <-
#'   path_temp("gene_extended") |>
#'   dir_create()
#' # Function to extent a gene bed file
#' gene_dir=fs::path_package("PLEIOVAR", "extdata", "gene")
#' gene_bed_file <- path(gene_dir, "chrom_20.bed")
#' extension <- 50000
#'
#' extend_gene_bed(gene_bed_file, gene_extended_dir, extension)
#'
extend_gene_bed <- function(gene_bed_file, gene_extended_dir, extension){
  fs::dir_create(gene_extended_dir)   # Create dir if not already existed
  gene_bed_extended <- fs::path(gene_extended_dir, fs::path_file(gene_bed_file))   # The extended file path
  readr::read_delim(gene_bed_file,
                    col_names = c("chrom", "start", "end", "gene"),        # Read in the original bed
                    show_col_types = FALSE) |>
    dplyr::mutate(
      start = start - extension,                                           # Make extension
      end = end + extension
    ) |>
    readr::write_tsv(
      file = gene_bed_extended,                                           # Write out
      col_names = FALSE
    )

  return(gene_bed_extended)                                               # Return the extended file path
}




